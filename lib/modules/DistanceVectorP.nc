#include "../../includes/dv.h"

module DistanceVectorP 
{
    provides interface DistanceVector;
}

implementation 
{

    dv_route_t routingTable[DV_MAX_ROUTES];

    uint8_t routeCount = 0;

    command uint8_t DistanceVector.getRouteCount() 
    {
        return routeCount;
    }

    command bool DistanceVector.getRouteAt(uint8_t index, dv_route_t* route)
    {
        if (index >= routeCount || route == NULL) 
        {
            return FALSE;
        }

        *route = routingTable[index];
        return TRUE;
    }
    
    command bool DistanceVector.lookupRoute(
        uint16_t destination,
        uint16_t* nextHop,
        uint8_t* cost
    ) {
        uint8_t i;

        if (nextHop == NULL || cost == NULL) 
        {
            return FALSE;
        }

        for (i = 0; i < routeCount; i++) 
        {
            if (routingTable[i].destination == destination &&
                routingTable[i].state == DV_ROUTE_VALID &&
                routingTable[i].cost < DV_INFINITY) 
                {

                    *nextHop = routingTable[i].nextHop;
                    *cost = routingTable[i].cost;

                    return TRUE;
                }
        }

        return FALSE;
    }

    command void DistanceVector.printTable() 
    {
        uint8_t i;

        dbg(ROUTING_CHANNEL,
            "Node %d Routing Table\n", TOS_NODE_ID);

        dbg(ROUTING_CHANNEL,
            "Dest NextHop Cost State\n");

        for (i = 0; i < routeCount; i++) 
        {
            dv_route_t* route = &routingTable[i];

            if (route->state == DV_ROUTE_VALID &&
                route->cost < DV_INFINITY) 
                {
                    dbg(ROUTING_CHANNEL,
                        "%d %d %d VALID\n",
                        route->destination,
                        route->nextHop,
                        route->cost);
                }
            else if (route->state == DV_ROUTE_WITHDRAWN) 
            {

                dbg(ROUTING_CHANNEL,
                    "%d NONE INF WITHDRAWN\n",
                    route->destination);
            }
        }
    }

    
    command void DistanceVector.acceptEntry(
        uint16_t from,
        uint16_t destination,
        uint8_t cost
    ) {
        uint8_t newCost;
        uint8_t i;

        if (destination == TOS_NODE_ID) 
        {
            return;
        }

        if (cost >= DV_INFINITY) 
        {
            newCost = DV_INFINITY;
        }

        else 
        {
            newCost = cost + 1;
        }

        for (i = 0; i < routeCount; i++) 
        {
            if (routingTable[i].destination == destination) 
            {
                break;
            }
        }

        if (i == routeCount) 
        {
            if (newCost == DV_INFINITY ||
                routeCount >= DV_MAX_ROUTES) 
                {
                    return;
                }

            routingTable[i].destination = destination;
            routingTable[i].nextHop = from;
            routingTable[i].cost = newCost;
            routingTable[i].state = DV_ROUTE_VALID;

            routeCount++;
            return;
        }
    }
}