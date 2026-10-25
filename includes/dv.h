#ifndef DV_H
#define DV_H

#include "packet.h"

enum{
    DV_INFINITY = 16,
    DV_ENTRY_SIZE = 2,
    DV_MAX_ENTRIES = (PACKET_MAX_PAYLOAD_SIZE - 1) / DV_ENTRY_SIZE
};

#endif