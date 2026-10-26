#include "../../includes/am_types.h"
#include <Timer.h>

configuration DVExchange {
    provides interface DVExchange;

    uses interface DistanceVector as DV;
    uses interface NeighborDiscovery as ND;

    components new TimerMilliC() as Timer;
    components RandomC;
}

implementation {
    components DVExchangeP;

    components new AMReceiverC(AM_DV) as Receiver;
    components new AMSenderC(AM_DV) as Sender;

    components ActiveMessageC;

    DVExchange = DVExchange.DVExchange;

    DVExchangeP.Receive -> Receiver.Receive;
    DVExchangeP.Sender -> Sender.SimpleSend;
    
    DVExchangeP.AMPacket -> ActiveMessageC.AMPacket;

    DVExchangeP.DV -> DV;
    DVExchangeP.ND -> ND;
    
    DVExchangeP.Timer -> Timer.Timer;
    DVExchangeP.Random -> RandomC.Random;
}
