function runBisection(dutFile)

if exist(getOutputFile('spice-step-001.bin'), 'file')

    delete(getOutputFile('spice-step-*.bin'));

end

% parameters

plotRange = [4.8 6] * 1e-9;

skipChecks = 0;

% lower and upper bounds of bisection window:

L = 0; H = 10e-9;

prepareIncludeDUT(dutFile);

if ~skipChecks; runChecks(); end

% prepare figure

clf; drawnow

% start bisection

bisectionResults = [];

grid on; box on;

hold on;

xlim(plotRange);

rounds = 50;

ts = inf;

disp('starting bisection ...');

for i=1:rounds

    fprintf('round (%2d/%2d), window size = %1.2e sec, settling time = %1.2e sec\n', ...
        i, rounds, H-L, ts);

    binFile = getOutputFile(sprintf('spice-step-%03d.bin', i));

    m = (H+L) / 2;

    prepareBisectionParams(m); % set new transition time

    sim = simSpice('spice/testbench.cir', binFile, 1);

    [t, q, qn] = getSignals(sim, 'time', 'q', 'qn');

    R = 1 * (q(end) > qn(end)); % settling state

    plot(t, [q; qn]);

    ts = getSettlingTime(t, q, qn);

    bisectionResults(end+1, :) = [H L m R ts]; %#ok<AGROW>

    plot(ts, 0, 'ok');

    title(sprintf('m = %1.10f ns', m * 1e9));

    drawnow

    if q(end) > qn(end)

        H = m;

    else

        L = m;

    end

end

save(getOutputFile('bisection-output.mat'), 'bisectionResults');

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