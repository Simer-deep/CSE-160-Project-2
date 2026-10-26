interface NeighborDiscovery {
   command void start();
   command void printNeighbors();
   command void isNeighbor(uint16_t nodeId);
}
