#include "am_types.h"

configuration DVExchange {
    provides interface DVExchange;
}

implementation {
    components DVExchangeP;

    components new AMReceiverC(AM_DV) as Receiver;
    components new AMSenderC(AM_DV) as Sender;

    DVExchange = DVExchange.DVExchange;

    DVExchangeP.Receive -> Receiver.Receive;
    DVExchangeP.Sender -> Sender.SimpleSend;
}
