from TestSim import TestSim

def main():
    # Get simulation ready to run.
    s = TestSim()

    # Simulate the network being off initially.
    s.runTime(1)

    # Load the long-line topology.
    s.loadTopo("long_line.topo")

    # Add noise model.
    s.loadNoise("no_noise.txt")

    # Boot all motes.
    s.bootAll()

    # Enable debug channels before testing.
    s.addChannel(s.COMMAND_CHANNEL)
    s.addChannel(s.GENERAL_CHANNEL)
    s.addChannel(s.FLOODING_CHANNEL)
    s.addChannel(s.NEIGHBOR_CHANNEL)

    # Give the network some time to start up.
    s.runTime(4)

    # -------------------------------------------------
    # 1. FLOODING TEST
    # -------------------------------------------------

    # Short ping.
    s.ping(2, 17, "Hi")
    s.runTime(2)

    # Multi-hop ping across the long-line topology.
    # s.ping(1, 10, "Hi!")
    s.runTime(10)

    # -------------------------------------------------
    # 2. NEIGHBOR TABLE TEST
    # -------------------------------------------------

    # Allow neighbor discovery to run for a few rounds.
    s.runTime(12)

    # Print Node 3's neighbor table.
    # In a long-line topology, Node 3 should see Nodes 2 and 4.
    s.neighborDMP(3)
    s.runTime(1)

    # -------------------------------------------------
    # 3. MOTE-OFF TEST
    # -------------------------------------------------

    # Turn off Node 4.
    s.moteOff(4)

    # Wait long enough for Node 3 to miss Node 4
    # for 3 discovery rounds.
    s.runTime(20)

    # Print Node 3's neighbor table again.
    # Node 4 should now be removed.
    s.neighborDMP(3)
    s.runTime(1)


if __name__ == '__main__':
    main()