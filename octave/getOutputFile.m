function oFile = getOutputFile(file)

toolTempDir = fullfile(tempdir, 'bisect-tau');

outputDir = fullfile(toolTempDir, 'output');

if ~exist(toolTempDir, 'dir')
    
    mkdir(toolTempDir);
    
end

if ~exist(outputDir, 'dir')
    
    mkdir(outputDir);
    
end

oFile = fullfile(outputDir, file);

end