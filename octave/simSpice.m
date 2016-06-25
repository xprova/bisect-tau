function [sim, errMsg] = simSpice(testbenchCode, binFile, quiet)

if nargin < 3; quiet = 0; end

cmdFile = getOutputFile('runTestbench.cmd');

testbenchCirFile = getOutputFile('testbench.cir');

fid = fopen(testbenchCirFile, 'w');

if fid == -1

    error('cannot output to file %s', testbenchCirFile)

else

    for i=1:length(testbenchCode)

        fprintf(fid, '%s\n', testbenchCode{i});

    end

end

fclose(fid);

prepareCommandFile(cmdFile, testbenchCirFile, binFile);

cmd = sprintf('ngspice %s', cmdFile);

if quiet

    if isunix

        %cmd = strcat(cmd, ' >> /dev/null 2>&1');

        cmd = strcat(cmd, ' 2>&1');

    end

    [exitCode, errMsg] = system(cmd);

else

    exitCode = system(cmd);

end

if exitCode

    %error('ngspice terminated with non-zero exit code');

    sim = [];

else

    sim = readSpiceBin(binFile);

end

delete(cmdFile);

end

function prepareCommandFile(cmdFile, testbenchFile, binFile)

simLength = 10e-9;

cmds = {

'* Testbench'
''
'.control'
'	source {TESTBENCH}'
'	tran 1ps {LENGTH}'
'	write {BIN}'
'	quit'
'.endc'

};

n = length(cmds);

fid = fopen(cmdFile, 'w');

for i=1:n

    c = cmds{i};

    c = strrep(c, '{TESTBENCH}', testbenchFile);
    c = strrep(c, '{BIN}', binFile);
    c = strrep(c, '{LENGTH}', sprintf('%1.10e', simLength));

    fprintf(fid, '%s\n', c);

end

fclose(fid);

end