function xfelPaths = getXfelPaths()
    try
        paths = mypaths();
        xfelPaths = paths.xfel;
    catch
        warning('Function "mypaths()" not found. Using build in file paths.')
        xfelPaths.storage = 'storage\';
        xfelPaths.analysis = fullfile(xfelPaths.storage, 'analysis');
        xfelPaths.db = fullfile(xfelPaths.storage, 'db');
        xfelPaths.img = fullfile(xfelPaths.storage, 'img');
        xfelPaths.recon = fullfile(xfelPaths.storage, 'recon');
        xfelPaths.pnccd_dcg = fullfile(xfelPaths.storage, 'all_hits_corrected_dark_cm_gain');
        xfelPaths.pnccd_dcgb = fullfile(xfelPaths.storage, 'all_hits_corrected_dark_cm_gain_bg');
        xfelPaths.pnccd = xfelPaths.pnccd_dcg;
    end
end
