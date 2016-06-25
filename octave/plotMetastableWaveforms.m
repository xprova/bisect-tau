function plotMetastableWaveforms()

dir1 = 'C:\cygwin64\tmp\bisect-tau\output';

clf; hold on

for i=1:30
   
    binFile = fullfile(dir1, sprintf('spice-step-%03d.bin', i));
    
    sim = readSpiceBin(binFile);
    
    [t, q, qn] = getSignals(sim, 'time', 'q', 'qn');
    
    plot(t * 1e9, [q; qn]');
    
end

xlabel('Time (ns)');

ylabel('Voltage');

legend('q', 'qn');

grid on; box on;

xlim([4.9 5.5]);

ylim([-0.2 1.4]);

title('Metastable Latch Outputs');

makeLines1pt();

% ppng('fig_metastable.png', [10 8]);

psvg('fig_metastable.svg', [10 8]);

end