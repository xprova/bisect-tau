function tp = getType(sim, signal)

ind = getIndex(sim.sigNames, signal);

tp = sim.sigTypes{ind};

end