#include "packet.h"

module DVExchangeP {
    provides interface DVExchange;


    uses interface Receive;
    uses interface SimpleSend as Sender;
}

implementation {

    event message_t* Receive.recieve(message_t* msg, void* payload, uint8_t len) {

        pack* incoming;

        if(len != sizeof(pack)) {
            return msg;
        }

        incoming = (pack*) payload;

        if(incoming->protocol != PROTOCOL_DV || incoming->dest != TOS_NODE_ID){
            return msg;
        }

        dbg(ROUTING_CHANNEL, "Node %d received a DV packet\n", TOS_NODE_ID);

        return msg;
    }


}