function plotSignals()

[t, signals, sigNames] = readSpiceBin('spice-output/traces2.bin');

signalGroups = {
    {'clk', 'reset'}
    {'d', 'dn'}
    {'q', 'qn'}
    {'x1.a', 'x1.an'}
    };

clc; sigNames'
    
nSignals = length(sigNames);

nGroups = length(signalGroups);

clf;

for i=1:nGroups
    
    subplot(nGroups, 1, i);
    
    g = signalGroups{i};
    
    nSigs = length(g);
    
    k = zeros(1, nSignals);
    
    for j=1:nSigs
        
        k = k + strcmp(sigNames, g{j});        
        
    end
    
    if ~sum(k)
        
        clf
        
        error('no signals found in group %d', i);
        
    end
    
    plot(t * 1e9, signals(k>0, :), 'linewidth', 2);
    
    legend(sigNames(k>0));
    
    grid; box on;
    
    ylim([-0.2 1.2]);
    
    xlim([0 max(t)*1e9]);
    
    xlabel('Time (ns)');
    
end

end