%% INIT
close all
clear
clc
paths.main = fileparts(fullfile(mfilename('fullpath')));

%% define your storage path here if necessary:
paths.storage = '.\storage\';

try
    tmpPaths = mypaths();
    tmpPaths = tmpPaths.xfel;
    pNames=fieldnames(tmpPaths);
    for i=1:numel(pNames)
        paths.(pNames{i}) = tmpPaths.(pNames{i});
    end
catch
    warning('Function "mypaths()" not found. Using build in file paths.')
    if ~isfield(paths,'storage')
        paths.storage = 'storage\';
    end
    paths.analysis = fullfile(paths.storage, 'analysis');
    paths.db = fullfile(paths.main, 'db');
    paths.img = fullfile(paths.storage, 'img');
    paths.recon = fullfile(paths.storage, 'recon');
    paths.pnccd_dcg = fullfile(paths.storage, 'all_hits_corrected_dark_cm_gain');
    paths.pnccd_dcgb = fullfile(paths.storage, 'all_hits_corrected_dark_cm_gain_bg');
    paths.pnccd = paths.pnccd_dcg;
end

addpath(paths.main);

%% for performance reasons:
% set(groot,'DefaultFigureGraphicsSmoothing','off')

%% first doped: 283

pnccdGUI(paths,...
    'run',301, ...
    'hit', 1);





