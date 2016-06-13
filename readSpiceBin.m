function [t, signals, sigNames] = readSpiceBin(file1)

if nargin == 0

    file1 = 'C:\cygwin64\home\ngt15\ngspice-test\traces.bin';

end

fid = fopen(file1, 'r');

variableSection = 0;

varNames = {};

while 1
    
    str = fgetl(fid);
    
    if isequal(str, 'Binary:')
        
        break;
        
    end
    
    if variableSection
        
        k = find(str == 9); % tab char
        
        varNames{end+1} = str(k(2)+1 : k(3)-1);
        
    end
    
    if isequal(str, 'Variables:')
        variableSection = 1;
    end
    

    
end

fileData = fread(fid, [3 10011], 'double');

t = fileData(1, :);

signals = fileData(2:end, :);

sigNames = varNames(2:end);

plot(t, signals)

legend(sigNames);

end