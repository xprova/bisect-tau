function plotExample()

L = 0;

testbench = prepareBisectionTestbench('./example/latch.cir', L, './spice/testbench-example2.cir');

sim = simSpice(testbench, getOutputFile('spice-example-2.bin'));

[t, reset, q, qn, clk, d] = sim.getSignals('time', 'reset', 'q', 'qn', 'clk', 'd');

t = t * 1e9;

%% plots

cols = lines(10);

clf

n = 4;

sp = @(i) subplot(n, 1, i);

sp(1); plot(t, reset, 'r'); legend('reset');

sp(2); plot(t, clk, 'color', cols(4, :)); legend('clk');

sp(3); plot(t, d, 'color', cols(5, :)); legend('d');

sp(4); plot(t, [q; qn]); legend('q', 'qn');

for i=1:n
    
    sp(i);
    
    ylim([-0.2 1.2]); grid on;
    
    xlabel('Time (ns)');
    
    ylabel('Voltage');
    
end

for i=1:n-1
    
    sp(i); set(gca, 'xticklabel', []);
    
    xlabel('');
    
end

% makeLines1pt();
% ppng('e:\example1.png', [8 12]);
% psvg('example1.svg', [8 12]);

end