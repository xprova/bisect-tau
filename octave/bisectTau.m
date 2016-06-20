% this function is called from the shell script wrapper ./bisect-tau
%
% it is passed the working dir (output of pwd) and a list of the command
% line options supplied by the user
%
% note about working directories:
%
% - octave will use the tool's home directory as its working directory
% - this will also be ngspice's working directory (inherited from octave)
% - relative paths in testbench circuits and includes are specified
%   according to the above

function bisectTau(varargin)

% first, change Octave's work dir to the tool's home dir

mPath = fileparts(mfilename('fullpath'));

toolPath = fullfile(mPath, '..');

cd(toolPath);

workDir = varargin{1};

iseq = @(a) isequal(varargin{2}, a);

if iseq('--help') || iseq('-h')
    
    printUsage(); return;
    
elseif iseq('--version') || iseq('-v')
    
    printVersion(); return;
    
elseif iseq('bisect')

    if nargin>2
    
        dutFile = fullfile(workDir, varargin{3});
        
        runBisection(dutFile);
        
        return;
        
    end
    
elseif iseq('check')
    
    if nargin>2
        
        dutFile = fullfile(workDir, varargin{3});
        
        prepareIncludeDUT(dutFile);
        
        runChecks();
        
        return;
        
    end
    
elseif iseq('calculate')
    
    calculateTau();    
    
    return;
   
end

fprintf('Error parsing command line arguments. Run bisect-tau --help for help\n');

end

function printUsage()

usage = {
    'bisect-tau'
    ''
    'Usage:'
    '  bisect-tau check <dut>'
    '  bisect-tau bisect <dut>'
    '  bisect-tau calculate'
    '  bisect-tau -h | --help'
    '  bisect-tau --version'
    ''
    'Options:'
    '  -h --help     Show this screen.'
    '  --version     Show version.'    
    };

for i=1:length(usage);

    fprintf('%s\n', usage{i});
    
end

end


function printVersion()

disp('bisect-tau v0.1');

end