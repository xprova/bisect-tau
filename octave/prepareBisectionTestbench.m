function testbench = prepareBisectionTestbench(dutFile, d_time, testbenchTemplateFile)

if nargin < 3

    testbenchTemplateFile = './spice/testbench.cir';

end

testbench = getFile(testbenchTemplateFile);

replacePat = {
    {'{D_TIME}', sprintf('%1.15e', d_time)}
    {'{DUT_FILE}', dutFile}
    };

n = length(testbench);

m = length(replacePat);

for i=1:n

    for j=1:m

        testbench{i} = strrep(testbench{i}, ...
            replacePat{j}{1}, replacePat{j}{2});

    end

end

end