function runBisection()

% parameters

plotRange = [4.8 6] * 1e-9;

skipChecks = 1;

% lower and upper bounds of bisection window:
    
L = 0; H = 10e-9;

if ~skipChecks
        
    % check that q(L) < qn(L):
    
    [~, q, qn] = simSpice(L);
    
    assert(q(end) < qn(end), 'q(L) must be < qn(L)');
    
    % check that q(H) > qn(H):
    
    [~, q, qn] = simSpice(H);
    
    assert(q(end) > qn(end), 'q(H) must be > qn(L)');
    
end

% prepare output directory

if ~exist('output', 'dir')
    
    mkdir('output');
    
end

% prepare figure

clf; drawnow

% start bisection

bisectionResults = [];

grid on; box on;

hold on;

xlim(plotRange);

for i=1:50
    
    m = (H+L) / 2;
    
    [t, q, qn] = simSpice(m);
    
    if q(end) > qn(end)
        
        H = m;
        
        R = 1;
        
    else
        
        L = m;
        
        R = 0;
        
    end
    
    plot(t, [q; qn]);
    
    ts = getSettlingTime(t, q, qn);
    
    bisectionResults(end+1, :) = [m R ts]; %#ok<AGROW>
    
    plot([1 1] * ts, [0 1], '-k');
    
    title(sprintf('m = %1.10f ns', m * 1e9));
    
    drawnow
    
end

save('output/bisection-output.mat', 'bisectionResults');

end

function ts = getSettlingTime(t, q, qn)

A = [q - q(end); qn - qn(end)];

d = mean(abs(A), 1);

ind = find(d > 0.1, 1, 'last');

if isempty(ind)
    
    ts = inf;
    
else

    ts = t(ind);
    
end

end

function [t, q, qn] = simSpice(d_time)

fid = fopen('bisection-params.cir', 'w');

fprintf(fid, '.param d_time = %1.10fn', d_time / 1e-9);

fclose(fid);

exitCode = system('ngspice runTestbench.cmd');

if exitCode
    
    error('Could not run ngspice. Make sure it is installed and added to PATH');
    
end

[t, signals, sigNames] = readSpiceBin('output/spice-output.bin');

q_ind = getSignalIndex(sigNames, 'q');

qn_ind = getSignalIndex(sigNames, 'qn');

q = signals(q_ind, :);

qn = signals(qn_ind, :);

end

function y = getSignalIndex(sigNames, signal)

y = find(strcmp(sigNames, signal));

end