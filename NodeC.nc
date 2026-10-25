/**
 * ANDES Lab - University of California, Merced
 * This class provides the basic functions of a network node.
 *
 * @author UCM ANDES Lab
 * @date   2013/09/03
 *
 */

configuration NodeC {
}
implementation {
   components MainC, Node, ActiveMessageC, CommandHandlerC;
   components NeighborDiscoveryC, FloodingC;

   Node.Boot -> MainC.Boot;
   Node.AMControl -> ActiveMessageC.SplitControl;
   Node.CommandHandler -> CommandHandlerC.CommandHandler;
   Node.NeighborDiscovery -> NeighborDiscoveryC.NeighborDiscovery;
   Node.Flooding -> FloodingC.Flooding;
}
