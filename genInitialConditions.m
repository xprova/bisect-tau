function genInitialConditions(sigNames, sigICs)

if ~nargin
    
    tRestart = 5.25e-9;
    
    [t, signals, sigNames, sigTypes] = readSpiceBin('./output/spice-output.bin');
    
    k = find(t > tRestart, 1, 'first');
    
    sigICs = signals(:, k);
    
end

nSigs = length(sigICs);

fid = fopen('ic.cir', 'w');

for i=1:nSigs
    
    cond(1) = ~endsWith(sigNames{i}, '#body');
    cond(2) = ~endsWith(sigNames{i}, '#sbody');
    cond(3) = ~endsWith(sigNames{i}, '#dbody');
    cond(4) = ~endsWith(sigNames{i}, '#gate');
    cond(5) = isequal(sigTypes{i}, 'voltage');
    
    if all(cond)
        
        fprintf(fid, '.ic v(%20s) = %+1.25f\n', sigNames{i}, sigICs(i));
        
    end
    
end

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