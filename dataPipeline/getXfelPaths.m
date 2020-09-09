function xfelPaths = getXfelPaths()

% paths.source = fileparts(mfilename('fullpath'));
% addpath(genpath(paths.source));
% global PATHS
try
    paths = mypaths();
    xfelPaths = paths.xfel;
catch
%     fprintf('No global paths detected! Using standard paths. This might result in chaos...\n');
    warning('Function "mypaths()" not found. Using build in file paths.')
    xfelPaths.gDrive = 'C:\Users\Toli\Google Drive\';
    xfelPaths.storage = fullfile('E:\XFEL2019_He');
    xfelPaths.analysis = fullfile(PATHS.gDrive, 'dissertation\2.helium\xfel-analysis\');
    xfelPaths.db = fullfile(PATHS.gDrive, 'dissertation\2.helium\xfel-data\');
    xfelPaths.img = fullfile(PATHS.gDrive, 'dissertation\2.helium\xfel-img');
    xfelPaths.recon = fullfile(xfelPaths.db, 'recondata');
    xfelPaths.pnccd_dcg = fullfile(xfelPaths.storage, 'all_hits_corrected_dark_cm_gain');
    xfelPaths.pnccd_dcgb = fullfile(xfelPaths.storage, 'all_hits_corrected_dark_cm_gain');
    xfelPaths.pnccd = fullfile(xfelPaths.storage, 'all_hits_corrected_dark_cm_gain_bg');
end

end