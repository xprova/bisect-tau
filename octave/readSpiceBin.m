function simulation = readSpiceBin(binFile)

if nargin == 0

    binFile = 'output/spice-output.bin';

end

fid = fopen(binFile, 'r');

if fid == -1

    error('could not open file %s', binFile);

end

variableSection = 0;

sigNames = {};

sigTypes = {};

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

        sigNames{end+1} = str(k(2)+1 : k(3)-1); %#ok<AGROW>

        sigTypes{end+1} = str(k(3)+1:end); %#ok<AGROW>

    end

    if isequal(str, 'Variables:')

        variableSection = 1;

    end

end

nSignals = length(sigNames);

fileData = fread(fid, [nSignals timePoints], 'double');

fclose(fid);

simulation = struct;

simulation.signals = fileData;

simulation.sigNames = sigNames;

simulation.sigTypes = sigTypes;

simulation.getSignals = @getSignals;

simulation.getType = @getType;

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