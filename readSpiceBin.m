function varargout = readSpiceBin(file1)

if nargin == 0
    
    file1 = 'output/spice-output.bin';
    
end

fid = fopen(file1, 'r');

variableSection = 0;

varNames = {};

varTypes = {};

while 1
    
    str = fgetl(fid);
    
    if startsWith(str, 'No. Points:');
        
        timePoints = sscanf(str, 'No. Points: %d');
        
    end
    
    if isequal(str, 'Binary:')
        
        break;
        
    end
    
    if variableSection
        
        k = find(str == 9); % tab char
        
        varNames{end+1} = str(k(2)+1 : k(3)-1); %#ok<AGROW>
        
        varTypes{end+1} = str(k(3)+1:end); %#ok<AGROW>
        
    end
    
    if isequal(str, 'Variables:')
        
        variableSection = 1;
        
    end
    
end

nvars = length(varNames);

fileData = fread(fid, [nvars timePoints], 'double');

fclose(fid);

t = fileData(1, :);

signals = fileData(2:end, :);

sigNames = varNames(2:end);

sigTypes = varTypes(2:end);

if nargout; varargout = {t, signals, sigNames, sigTypes}; end

end

function y = startsWith(str1, str2)

% returns 1 if str1 starts with str2

n1 = length(str1);
n2 = length(str2);

if n1 < n2
    
    y = 0; return
    
end

y = isequal(str1(1:n2), str2);

end