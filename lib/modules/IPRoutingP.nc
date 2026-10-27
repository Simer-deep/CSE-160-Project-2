#include "../../includes/packet.h"
#include "../../includes/protocol.h"
#include "../../includes/channels.h"
#include "../../includes/dv.h"
#include <string.h>

module IPRoutingP {

    provides interface IPRouting;

    uses interface Receive;
    uses interface SimpleSend as Sender;

    uses interface DistanceVector as DV;
    uses interface NeighborDiscovery as ND;
}

implementation {


    uint16_t sequenceNum = 0;

    command void IPRouting.ping(uint16_t destination, uint8_t* payload) {

        pack outgoing;
        uint16_t nextHop;
        uint8_t cost;

        if(destination == TOS_NODE_ID) {
            dbg(ROUTING_CHANNEL, "Node %d is already the destination\n", TOS_NODE_ID);
            return;
        }

        if(!call DV.lookup(destination, &nextHop, &cost)) {
            dbg(ROUTING_CHANNEL, "Node %d has no route to %d\n", TOS_NODE_ID, destination);
            return;
        }

        if(cost >= DV_INFINITY || !call ND.isNeighbor(nextHop)) {
            dbg(ROUTING_CHANNEL, "Node %d cannot reach %d\n", TOS_NODE_ID, destination);
            return;
        }

        memset(&outgoing, 0, sizeof(outgoing));

        outgoing.src = TOS_NODE_ID;
        outgoing.dest = destination;
        outgoing.seq = sequenceNum++;
        outgoing.TTL = MAX_TTL;
        outgoing.protocol = PROTOCOL_PING;

        if(payload != NULL) {
            memcpy(outgoing.payload, payload, PACKET_MAX_PAYLOAD_SIZE);
        }

        if(call Sender.send(outgoing, nextHop) != SUCCESS) {
            dbg(ROUTING_CHANNEL, "Node %d failed to queue ping\n", TOS_NODE_ID);
            return;
        }

        dbg(ROUTING_CHANNEL,
            "Node %d sending ping to %d through next hop %d\n",
            TOS_NODE_ID, destination, nextHop);
    }

    
    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {

        pack* incoming;

        if(len != sizeof(pack)) {
            return msg;
        }

        incoming = (pack*)payload;

        if(incoming->protocol != PROTOCOL_PING &&
        incoming->protocol != PROTOCOL_PINGREPLY) {
            return msg;
        }

        if(incoming->TTL == 0) {
            return msg;
        }

        if(incoming->dest == TOS_NODE_ID) {

            if(incoming->protocol == PROTOCOL_PING) {

                dbg(ROUTING_CHANNEL,
                    "Node %d received PING from Node %d\n",
                    TOS_NODE_ID, incoming->src);

            } else {

                dbg(ROUTING_CHANNEL,
                    "Node %d received PING REPLY from Node %d\n",
                    TOS_NODE_ID, incoming->src);
            }

        } else {

            dbg(ROUTING_CHANNEL,
                "Node %d needs to forward packet from %d to %d\n",
                TOS_NODE_ID, incoming->src, incoming->dest);
        }

        return msg;
    }


}
