function [pnccd, filename, nHits] = pnccd_load_run(run, datapath) 

if nargin < 2
    paths = mypaths();
    datapath = paths.xfel.pnccd;
end

filename = sprintf('%04i_hits.mat', run);
load(fullfile(datapath, filename), 'pnccd');
nHits = numel(pnccd.data);