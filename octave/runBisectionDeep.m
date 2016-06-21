function runBisectionDeep()

delete(getOutputFile('spice-deepstep-*.bin'));

bisectionResultsDeep = [];

load(getOutputFile('bisection-output.mat'));

initStepLow = 31;

initStepHigh = 32;

if bisectionResults(initStepLow, 4) ~= 0
    
    error('initStepLow is not a low state');
    
end

if bisectionResults(initStepHigh, 4) ~= 1
    
    error('initStepHigh is not a high state');
    
end

% loading low and high states

binL = getOutputFile(sprintf('spice-step-%03d.bin', initStepLow));
binH = getOutputFile(sprintf('spice-step-%03d.bin', initStepHigh));

simL = readSpiceBin(binL);
simH = readSpiceBin(binH);

strErr = sprintf('Different signal names in files %s and %s!', ...
    binL, binH);

assert(isequal(simL.sigNames, simH.sigNames), strErr);

tRestart = 5.2e-9;

tL = simL.getSignals('time');
tH = simH.getSignals('time');

kL = find(tL >= tRestart, 1, 'first');
kH = find(tH >= tRestart, 1, 'first');

stateL = simL.signals(:, kL);
stateH = simH.signals(:, kH);

% prepare figure

plotRange = [4.8 6] * 1e-9;

clf; drawnow

% start bisection

grid on; box on;

hold on;

xlim(plotRange);

L = 0; H = 1;

plot(simL.getSignals('time'), simL.getSignals('q'), 'k');
plot(simL.getSignals('time'), simL.getSignals('qn'), 'k');

for i=1:50
    
    binFile = getOutputFile(sprintf('spice-deepstep-%03d.bin', i));
    
    m = (L + H) / 2;
    
    stateM = stateL + (stateH-stateL) * m;
    
    genInitialConditions(simL.sigNames, simL.sigTypes, stateM, tRestart)
    
    simM = simSpice('testbench-restart.cir', binFile);
    
    [t, q, qn] = simM.getSignals('time', 'q', 'qn');
    
    if q(end) > qn(end)
        
        stateH = stateM; H = m; R = 1;
        
    else
        
        stateL = stateM; L = m; R = 0;
        
    end
    
    plot(t, [q; qn], 'linewidth', 2);
    
    ts = getSettlingTime(t, q, qn);
    
    bisectionResultsDeep(end+1, :) = [H L m R ts]; %#ok<AGROW>
    
    plot([1 1] * ts, [0 1], '-k');
    
    title(sprintf('m = %1.10f', m));
    
    drawnow
    
end

save(getOutputFile('bisection-deep-output.mat'), 'bisectionResultsDeep');

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
