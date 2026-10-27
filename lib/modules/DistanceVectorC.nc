configuration DistanceVectorC {
    provides interface DistanceVector;
}

implementation {
    components DistanceVectorP;
    components NeighborDiscoveryC;

    DistanceVector = DistanceVectorP.DistanceVector;
    DistanceVectorP.ND -> NeighborDiscoveryC.NeighborDiscovery;
}