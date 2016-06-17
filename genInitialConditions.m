function genInitialConditions(sigNames, sigTypes, sigICs, tRestart)

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
    
    conds = [
        isequal(sigTypes{i}, 'voltage')
        ~endsWith(sigNames{i}, '#body')
        ~endsWith(sigNames{i}, '#sbody')
        ~endsWith(sigNames{i}, '#dbody')
        ~endsWith(sigNames{i}, '#gate')
%         ~isequal(sigNames{i}, 'reset')
%         ~isequal(sigNames{i}, 'clk')
        ~isequal(sigNames{i}, 'vdd')
%         ~isequal(sigNames{i}, 'd')
%         ~isequal(sigNames{i}, 'dn')
        ~isequal(sigNames{i}, 'time');
        ];
    
    if all(conds)
        
        %fprintf(fid, '.ic v(%20s) = %+1.25f\n', sigNames{i}, sigICs(i));
        
        n = sigNames{i};
        
        vSet = sprintf('V_set_%s', n);
        
        nSet = sprintf('n_set_%s', n);
        
        sSet = sprintf('S_set_%s', n);
        
        lines1{end+1} = sprintf(...
            '%-20s %-20s 0 %+1.25f\n', ...
            vSet, nSet, sigICs(i)); %#ok<AGROW>
        
        lines2{end+1} = sprintf(...
            '%-20s %-20s %-20s V_SWITCH_ON 0 switch1 OFF\n', ...
            sSet, nSet, n); %#ok<AGROW>
        
    end
    
end

fid = fopen('ic.cir', 'w');

fprintf(fid, '* voltage sources:\n\n');

for i=1:length(lines1); fprintf(fid, '%s', lines1{i}); end

fprintf(fid, '\n* switches:\n\n');

fprintf(fid, '.model switch1 sw vt=0.5e-3 vh=0 ron=1e-9 roff=1e9\n\n');

for i=1:length(lines2); fprintf(fid, '%s', lines2{i}); end

%fprintf(fid, '\n\nV_SET_MASTER v_switch_on 0 PULSE (0 1 %1.10e 0 0 1e-15 1e9)\n\n', tRestart);

fprintf(fid, '\n\nV_SET_MASTER v_switch_on 0 PULSE (1 0 %1.10e 0 0 1 1e9)\n\n', tRestart);

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