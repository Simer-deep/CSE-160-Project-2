#include "packet.h"

module DVExchangeP {
    provides interface DVExchange;


    uses interface Receive;
    uses interface AMPacket;
    uses interface SimpleSend as Sender;
}

implementation {

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {

        uint16_t neighbor;

        pack* incoming;

        if(len != sizeof(pack)) {
            return msg;
        }

        incoming = (pack*) payload;

        if(incoming->protocol != PROTOCOL_DV || incoming->dest != TOS_NODE_ID){
            return msg;
        }

        neighbor = call AMPacket.source(msg); //(this is who sent it we need to know)

        dbg(ROUTING_CHANNEL, "Node %d received a DV packet from Node %d\n", TOS_NODE_ID, neighbor);

        return msg;
    }


}