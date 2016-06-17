function genInitialConditions(sigNames, sigICs)

if ~nargin
    
    tRestart = 5.25e-9;
    
    [t, signals, sigNames, sigTypes] = readSpiceBin('./output/spice-output.bin');
    
    k = find(t > tRestart, 1, 'first');
    
    sigICs = signals(:, k);
    
end 

nSigs = length(sigICs);

lines1 = {};
lines2 = {};

for i=1:nSigs
    
    cond(1) = ~endsWith(sigNames{i}, '#body');
    cond(2) = ~endsWith(sigNames{i}, '#sbody');
    cond(3) = ~endsWith(sigNames{i}, '#dbody');
    cond(4) = ~endsWith(sigNames{i}, '#gate');
    cond(5) = isequal(sigTypes{i}, 'voltage');
    cond(6) = ~isequal(sigNames{i}, 'reset');
    cond(7) = ~isequal(sigNames{i}, 'vdd');
    cond(8) = ~isequal(sigNames{i}, 'd');
    cond(9) = ~isequal(sigNames{i}, 'dn');
    
    if all(cond)
        
        %fprintf(fid, '.ic v(%20s) = %+1.25f\n', sigNames{i}, sigICs(i));
        
        n = sigNames{i};
        
        vSet = sprintf('V_set_%s', n);
        
        nSet = sprintf('n_set_%s', n);
        
        sSet = sprintf('S_set_%s', n);
        
        lines1{end+1} = sprintf('%-20s %-20s 0 %+1.25f\n', ...
            vSet, nSet, sigICs(i)); %#ok<AGROW>
        
        lines2{end+1} = sprintf('%-20s %-20s %-20s V_SWITCH_ON 0\n', ...
            sSet, nSet, n); %#ok<AGROW>
        
    end
    
end

fid = fopen('ic.cir', 'w');

fprintf(fid, '* voltage sources:\n\n');

for i=1:length(lines1); fprintf(fid, '%s', lines1{i}); end

fprintf(fid, '\n* switches:\n\n');

for i=1:length(lines2); fprintf(fid, '%s', lines2{i}); end

fprintf(fid, '\n\nV_SET_MASTER V_SWITCH_ON 0 PULSE (0 1 %1.10e 0 0 1e-15 1e9)\n\n', tRestart);

fclose(fid);

end

function y = endsWith(str1, str2)

n1 = length(str1);
n2 = length(str2);

if n2 > n1
    
    y = false;
    
else
    
    y = isequal(str1(end-n2+1 : end), str2);
    
end

end