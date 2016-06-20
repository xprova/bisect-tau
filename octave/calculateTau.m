function calculateTau()

useHigh = 1; % use high-resolving or low-resolving bisection steps

forceMeasureRange = []; % range to measure tau over (empty for auto)

load('output/bisection-output.mat');

h = bisectionResults;

k = (h(:, 4) == useHigh) & ~isinf(h(:, 5));

h = h(k, :);

ts = h(:, 5); % settling time

te = ts - min(ts); % delay extension

windowSize = abs(h(:, 3) - h(end, 1)); % input event window size

if isempty(forceMeasureRange)

    forceMeasureRange = range(te) * [0.05 0.95];

end

% fitting

k = (te > forceMeasureRange(1)) & (te < forceMeasureRange(2));

windowSizeLog = log(windowSize);

f = polyfit(te(k), windowSizeLog(k), 1);

tau = -1/f(1);

Tw = f(2);

winFun = @(clktoq) exp(Tw) * exp(-clktoq/tau);

% plotting

t = linspace(forceMeasureRange(1), forceMeasureRange(2), 100);

clf; hold on;

h1 = plot(te * 1e9, windowSize, 'o');

h2 = plot(t * 1e9, winFun(t), '-k');

xlabel('Increase in clk-to-q Delay (ns)');

ylabel('Size of Input Event Window');

set(gca, 'yscale', 'log');

legend([h1 h2], {'Simulation Results', 'Exponential Fit'});

grid on; box on;

strTitle = sprintf('Tau = %1.3f ps', tau * 1e12);

title(strTitle);

end