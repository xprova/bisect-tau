function runBisection()

delete('output/spice-step-*.bin');

% parameters

plotRange = [4.8 6] * 1e-9;

skipChecks = 1;

% lower and upper bounds of bisection window:
    
L = 0; H = 10e-9;

if ~skipChecks
        
    % check that q(L) < qn(L):
    
    prepareBisectionParams(L);
    
    sim = simSpice('testbench.cir', 'output/spice-check-low.bin');
    
    [q, qn] = sim.getSignals('q', 'qn');
    
    assert(q(end) < qn(end), 'q(L) must be < qn(L)');
    
    % check that q(H) > qn(H):
    
    prepareBisectionParams(H);
    
    sim = simSpice('testbench.cir', 'output/spice-check-high.bin');
    
    [q, qn] = sim.getSignals('q', 'qn');
    
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
    
    binFile = sprintf('output/spice-step-%03d.bin', i);
    
    m = (H+L) / 2;
    
    prepareBisectionParams(m); % set new transition time
    
    sim = simSpice('testbench.cir', binFile);
    
    [t, q, qn] = sim.getSignals('time', 'q', 'qn');
    
    R = 1 * (q(end) > qn(end)); % settling state
    
    plot(t, [q; qn]);
    
    ts = getSettlingTime(t, q, qn);
    
    bisectionResults(end+1, :) = [H L m R ts]; %#ok<AGROW>
    
    plot([1 1] * ts, [0 1], '-k');
    
    title(sprintf('m = %1.10f ns', m * 1e9));
    
    drawnow
    
    if q(end) > qn(end)
        
        H = m;
        
    else
        
        L = m;
        
    end
    
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

function prepareBisectionParams(d_time)

fid = fopen('bisection-params.cir', 'w');

fprintf(fid, '.param d_time = %1.10fn', d_time / 1e-9);

fclose(fid);

end