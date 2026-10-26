#include "../../includes/packet.h"
#include "../../includes/dv.h"
#include "Timer.h"
#include <string.h>

module DVExchangeP {
    provides interface DVExchange;


    uses interface Receive;
    uses interface AMPacket;
    uses interface SimpleSend as Sender;

    uses interface DistanceVector as DV;
    uses interface NeighborDiscovery as ND;
    uses interface Timer<TMilli> as Timer;
    uses interface Random as Random;
}

implementation {

    //timer functions for sending updates

    bool started = FALSE;

    command void DVExchange.start() {
        
        uint16_t delay; 

        if(started) {
            return;
        }

        started = TRUE;
    
        delay = 5000 + (call Random.rand16() % 1000);

        call Timer.startOneShot(delay);

    }

    event void Timer.fired(){

        uint16_t delay;

        dbg(ROUTING_CHANNEL, "Node %d timer fired\n", TOS_NODE_ID);

        delay = 5000 + (call Random.rand16() % 1000);

        call Timer.startOneShot(delay);
    }

    //send update function
    command void DVExchange.sendUpdate(){

        uint8_t routeCount;

        uint16_t i;
        uint16_t destination;
        uint8_t cost;
        uint16_t nextHop;

        uint8_t neighborCount;
        uint8_t neighborIndex;
        uint16_t neighbor;

        uint8_t sendCost;

        pack outgoing;
        uint8_t entryCount;

        routeCount = call DV.count();

        neighborCount = call ND.getNeighborCount();

        dbg(ROUTING_CHANNEL, "Node %d has %d routes to send\n", TOS_NODE_ID, routeCount);

        for(neighborIndex = 0; neighborIndex < neighborCount; neighborIndex++){

            if(!call ND.getNeighborAt(neighborIndex, &neighbor)){
                continue;
            }

            memset(&outgoing, 0, sizeof(pack));

            outgoing.src = TOS_NODE_ID;
            outgoing.dest = neighbor;
            outgoing.TTL = 1;
            outgoing.protocol = PROTOCOL_DV;
            outgoing.seq = 0;

            entryCount = 0;
            outgoing.payload[0] = entryCount;

            dbg(ROUTING_CHANNEL, "Node %d preparing update for neighbor %d\n", TOS_NODE_ID, neighbor);

                

            for(i = 0; i < routeCount; i++) {

                if(call DV.entryAt(i, &destination, &cost, &nextHop)) {

                    sendCost = cost;

                    if(nextHop == neighbor) {
                        sendCost = DV_INFINITY;
                    }

                    outgoing.payload[1 + entryCount * 2] = (uint8_t)destination;
                    outgoing.payload[2 + entryCount * 2] = sendCost;

                    entryCount++;
                    outgoing.payload[0] = entryCount;

                    dbg(ROUTING_CHANNEL,
                        "To neighbor %d: Dest %d Advertised Cost %d\n",
                        neighbor, destination, sendCost);

                    if(entryCount == DV_MAX_ENTRIES) {

                        if(call Sender.send(outgoing, neighbor) != SUCCESS) {
                            dbg(ROUTING_CHANNEL,
                                "Node %d failed to queue DV packet for neighbor %d\n",
                                TOS_NODE_ID, neighbor);
                            return;
                        }

                        memset(outgoing.payload, 0, sizeof(outgoing.payload));

                        entryCount = 0;
                    }
                }
            }
            
        }

    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {

        uint16_t i;
        uint16_t destination;
        uint8_t cost;

        uint16_t neighbor;
        uint8_t count;

        pack* incoming;

        if(len != sizeof(pack)) {
            return msg;
        }

        incoming = (pack*) payload;

        if(incoming->protocol != PROTOCOL_DV || incoming->dest != TOS_NODE_ID){
            return msg;
        }

        neighbor = call AMPacket.source(msg); //(this is who sent it we need to know (neighbor not source btw))

        if(!call ND.isNeighbor(neighbor)) {
            dbg(ROUTING_CHANNEL, "Received DV packet from non-neighbor %d\n", neighbor);
            return msg;
        }

        count = incoming->payload[0];

        if(count > DV_MAX_ENTRIES) {
            dbg(ROUTING_CHANNEL, "Invalid DV packet\n");
            return msg;
        }

        for(i = 0; i < count; i++){

            cost = incoming->payload[2 + i * 2];

            if(cost > DV_INFINITY) {
                dbg(ROUTING_CHANNEL, "Invalid cost in DV packet\n");
                return msg;
            }
        }

        for(i = 0; i < count; i++) {

            destination = incoming->payload[1 + i * 2];
            cost = incoming->payload[2 + i * 2];

            dbg(ROUTING_CHANNEL, "Destination: %d, Cost: %d\n", destination, cost);

            call DV.acceptEntry(neighbor, destination, cost);
        }

        dbg(ROUTING_CHANNEL, "Node %d received a DV packet from Node %d\n", TOS_NODE_ID, neighbor);

        return msg;
    }


}