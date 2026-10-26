#include "../../includes/packet.h"
#include "../../includes/dv.h"

module DVExchangeP {
    provides interface DVExchange;


    uses interface Receive;
    uses interface AMPacket;
    uses interface SimpleSend as Sender;

    uses interface DistanceVector as DV;
}

implementation {

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {

        uint8_t i;
        uint8_t destination;
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

        count = incoming->payload[0];

        if(count > DV_MAX_ENTRIES) {
            dbg(ROUTING_CHANNEL, "Invalid DV packet\n");
            return msg;
        }

        for(i = 0; i < count; i+=){

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

            call DV.acceptUpdate(neighbor, destination, cost);
        }

        dbg(ROUTING_CHANNEL, "Node %d received a DV packet from Node %d\n", TOS_NODE_ID, neighbor);

        return msg;
    }


}