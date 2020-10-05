%% INIT
close all
clear
clc

paths.main = fileparts(fullfile(mfilename('fullpath')));
pathFile = fullfile(paths.main,'paths.mat');
if exist(pathFile,'file')
    load(pathFile)
else
    warning('Function path config file not found. Using standard values.')
    %% define your storage path here if necessary:
    paths.storage = fullfile(paths.main,'storage\');
    paths.analysis = fullfile(paths.storage, 'analysis');
    paths.db = fullfile(paths.main, 'db');
    paths.img = fullfile(paths.storage, 'img');
    paths.recon = fullfile(paths.storage, 'recon');
    paths.pnccd_dcg = fullfile(paths.storage, 'all_hits_corrected_dark_cm_gain');
    paths.pnccd_dcgb = fullfile(paths.storage, 'all_hits_corrected_dark_cm_gain_bg');
    save(pathFile, 'paths')
end
%% switch off for performance reasons if necessary:
% set(groot,'DefaultFigureGraphicsSmoothing','off')

%% first doped run: 283

pnccdGUI(paths,...
    'run',301, ...
    'hit', 1);





