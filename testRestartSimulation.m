function testRestartSimulation()

tRestart = 5.25e-9;

[t, signals, sigNames, sigTypes] = readSpiceBin('./output/spice-output.bin');

k = find(t > tRestart, 1, 'first');

sigVals = signals(:, k);

nSigs = length(sigNames);

fid = fopen('ic.cir', 'w');

for i=1:nSigs
    
    if isequal(sigTypes{i}, 'voltage')
    
        fprintf(fid, '.ic v(%20s) = %+1.25f\n', sigNames{i}, sigVals(i));
        
    end
    
end

fclose(fid);

end

