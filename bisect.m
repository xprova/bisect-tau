function bisect()

% parameters

plotRange = [4.8 6] * 1e-9;

% body

clf; drawnow

% lower and upper bounds of bisection window:

L = 0; H = 10e-9;

% check that q(L) < qn(L):

[~, q, qn] = simSpice(L);

assert(q(end) < qn(end), 'q(L) must be < qn(L)');

% check that q(H) > qn(H):

[~, q, qn] = simSpice(H);

assert(q(end) > qn(end), 'q(H) must be > qn(L)');

% start bisection

grid on; box on;

hold on;

xlim(plotRange);

for i=1:50
    
    m = (H+L) / 2;
    
    [t, q, qn] = simSpice(m);
    
    if q(end) > qn(end)
        
        H = m;
        
    else
        
        L = m;
        
    end
    
    plot(t, [q; qn]);
    
    title(sprintf('m = %1.10f ns', m * 1e9));
    
    drawnow
    
end

end

function [t, q, qn] = simSpice(d_time)

fid = fopen('bisection-params.cir', 'w');

fprintf(fid, '.param d_time = %1.10fn', d_time / 1e-9);

fclose(fid);

system('ngspice runTestbench.cmd');

[t, signals, sigNames] = readSpiceBin('spice-output/traces2.bin');

q_ind = getSignalIndex(sigNames, 'q');

qn_ind = getSignalIndex(sigNames, 'qn');

q = signals(q_ind, :);

qn = signals(qn_ind, :);

end