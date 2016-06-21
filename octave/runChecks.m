function runChecks()

checks = {
    {'checking if ngspice is installed ...', @checkSpice}
    {'checking DUT behavior (test Case 1) ...', @checkCase1DUT}
    {'checking DUT behavior (test Case 2) ...', @checkCase2DUT}
    };

n = length(checks);

checkResults = {'pass', 'FAIL'};

for i=1:n

    fprintf('%0s ', checks{i}{1});

    checkFun = checks{i}{2};

    [result, errMsg] = checkFun();

    fprintf('%s\n', checkResults{result+1});

    if result ~= 0;

        error(errMsg);

        return;

    end

end

disp('All checks passed successfully');

end

function [result, errMsg] = checkSpice()

if ispc

    [exitCode, ~] = system('where ngspice');

else

    [exitCode, ~] = system('which ngspice');

end

if exitCode == 0

    result = 0;

    errMsg = '';

else

    result = 1;

    errMsg = 'Could not find ngspice. Make sure it is installed and setup in PATH correctly';

end

end

function [result, errMsg] = checkCase1DUT()

L = 0;

% check that q(L) < qn(L):

prepareBisectionParams(L);

sim = simSpice('spice/testbench.cir', getOutputFile('spice-check-low.bin'), 1);

if ~isempty(sim)

    [q, qn] = getSignals(sim, 'q', 'qn');

    if ~isempty(q)

        if q(end) < qn(end)

            result = 0; errMsg = ''; return;

        end

    end

end

result = 1;

errMsg = 'The specified DUT failed test Case 1, for details refer to https://github.com/xprova/bisect-tau';

end

function [result, errMsg] = checkCase2DUT()

H = 10e-9;

% check that q(H) > qn(H):

prepareBisectionParams(H);

sim = simSpice('spice/testbench.cir', getOutputFile('spice-check-high.bin'), 1);

if ~isempty(sim)

    [q, qn] = getSignals(sim, 'q', 'qn');

    if ~isempty(q)

      if q(end) > qn(end)

          result = 0; errMsg = ''; return

      end

    end

end

result = 1;

errMsg = 'The specified DUT failed test Case 2, for details refer to https://github.com/xprova/bisect-tau';

end