function runBisection(dutFile)

resFile = getOutputFile('bisection-output.mat');

if exist(resFile, 'file')

    delete(resFile);

end

if exist(getOutputFile('spice-step-001.bin'), 'file')

    delete(getOutputFile('spice-step-*.bin'));

end

% parameters

plotRange = [4.8 6] * 1e-9;

skipChecks = 0;

% lower and upper bounds of bisection window:

L = 0; H = 10e-9;

% prepareIncludeDUT(dutFile);

if ~skipChecks; runChecks(dutFile); end

% prepare figure

fh = figure();

clf; drawnow

title('Simulation Waveforms');

xlabel('Time (sec)');

ylabel('Voltage')

% start bisection

bisectionResults = [];

grid on; box on;

hold on;

xlim(plotRange);

rounds = 50;

ts = inf;

colorQ = [0 114 189]/255;

colorQn = [119 172 48] / 255;

t = 0:1;

h1 = plot(t, t * nan, 'color', colorQ);

h2 = plot(t, t * nan, 'color', colorQn);

legend([h1 h2], {'q', 'qn'});

disp('starting bisection ...');

for i=1:rounds

    if ~ishandle(fh)

        fprintf('Figure window closed, aborting ...\n'); return;

    end

    strProgress = sprintf( ...
        'round (%2d/%2d), window size = %1.2e sec, settling time = %1.2e sec', ...
        i, rounds, H-L, ts);

    fprintf('%s\n', strProgress);

    set(fh, 'Name', strProgress);

    binFile = getOutputFile(sprintf('spice-step-%03d.bin', i));

    m = (H+L) / 2;

    testbench = prepareBisectionTestbench(dutFile, m);

    sim = simSpice(testbench, binFile, 1);

    [t, q, qn] = getSignals(sim, 'time', 'q', 'qn');

    R = 1 * (q(end) > qn(end)); % settling state

    plot(t, q, 'color', colorQ);

    plot(t, qn, 'color', colorQn)

    ts = getSettlingTime(t, q, qn);

    bisectionResults(end+1, :) = [H L m R ts]; %#ok<AGROW>

    save(resFile, 'bisectionResults');

    plot(ts, 0, 'ok');

    %title(sprintf('m = %1.10f ns', m * 1e9));

    drawnow

    if q(end) > qn(end)

        H = m;

    else

        L = m;

    end

end

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