function compareRestartSim()

[t1, signals1, sigNames1] = readSpiceBin('./output/spice-output.bin');

[t2, signals2, sigNames2] = readSpiceBin('./output/spice-output-restart.bin');

s1 = getSignalIndex(sigNames1, 'q');
s2 = getSignalIndex(sigNames1, 'qn');

s3 = getSignalIndex(sigNames2, 'q');
s4 = getSignalIndex(sigNames2, 'qn');

clf; hold on;

plot(t1, signals1([s1 s2], :));

tRestart = 5.25e-9;

plot(tRestart + t2, signals2([s3 s4], :)+0.00);

end


function y = getSignalIndex(sigNames, signal)

y = find(strcmp(sigNames, signal));

end