function sim = simSpice(testbenchCirFile, binFile)

cmdFile = 'runTestbench.cmd';

prepareCommandFile(cmdFile, testbenchCirFile, binFile);

cmd = sprintf('ngspice %s', cmdFile);

exitCode = system(cmd);

delete(cmdFile);

if exitCode
    
    disp('Error encountered while running ngspice');
    
    disp('Make sure ngspice is installed and added to PATH');
    
    error('fatal error');
    
end

sim = readSpiceBin(binFile);

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