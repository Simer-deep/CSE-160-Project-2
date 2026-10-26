#include "../../includes/dv.h"

interface DistanceVector {

    command uint8_t getRouteCount();

    command bool getRouteAt(
        uint8_t index,
        dv_route_t* route
    );

    command void acceptEntry(
        uint16_t from,
        uint16_t destination,
        uint8_t cost
    );

    command bool lookupRoute(
        uint16_t destination,
        uint16_t* nextHop,
        uint8_t* cost
    );

    command void printTable();
}
