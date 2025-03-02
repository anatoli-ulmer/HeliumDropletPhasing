function [callerPath, callerFile, thisPath, thisFile] = getThisPath(n)

% n = 0 (default) | 1 | 2
% Flag to add path to search path:
%     0 - just returns the path and name of caller function
%     1 - adds the folder of the caller function to the searchpath
%     2 - adds the folder of the caller function and all subfolders to the
% search path
%
% If it doesn't work, the fastes solution:
%     addpath(genpath(fileparts(mfilename('fullpath'))));

[thisPath, thisFile] = fileparts(mfilename('fullpath'));
ST = dbstack('-completenames', 1);
[callerPath, callerFile] = fileparts(ST(1).file);

if nargin>0
    switch n
        case 0
        case 1
            addpath(callerPath);
        case 2
            addpath(genpath(callerPath));
        otherwise
            error('n has to be 0,1 or 2.');
    end
end
end