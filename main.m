%% INIT
close all
clear
clc
reset(0)
beep off

%% Setup paths

paths.main = fileparts(fullfile(mfilename('fullpath')));
addpath(genpath(paths.main));
pathFile = fullfile(paths.main,'paths.mat');
if exist(pathFile,'file')
    load(pathFile)
else
    warning('Function path config file not found. Using standard values.')
    %% define your storage path here if necessary:
    paths.storage = fullfile(paths.main,'storage');
    paths.analysis = fullfile(paths.storage, 'analysis');
    paths.db = fullfile(paths.main, 'db');
    paths.img = fullfile(paths.storage, 'img');
    paths.recon = fullfile(paths.storage, 'recon');
    paths.pnccd_dcg = fullfile(paths.storage, 'all_hits_corrected_dark_cm_gain');
    paths.pnccd_dcgb = fullfile(paths.storage, 'all_hits_corrected_dark_cm_gain_bg');
    paths.pnccd = paths.pnccd_dcg;
    save(pathFile, 'paths')
end

%% Change some default parameter

set(0, 'defaultFigureColor', [1 1 1])
scrSize = get(0,'ScreenSize');
scrW = scrSize(3)-scrSize(1);
scrH = scrSize(4)-scrSize(2);
set(0, 'defaultFigurePosition', [.25 .25 .5 .5].*[scrW scrH scrW scrH])
set(0, 'defaultFigurePaperUnits', 'centimeters')
set(0, 'defaultFigurePaperSize', [29.6774316979100, 20.9840419481200])
set(0, 'defaultFigurePaperPosition', [0, 0, 29.6774316979100, 20.9840419481200])
set(0, 'defaultFigureColormap', ihesperia)
set(0, 'defaultAxesOuterPosition', [.0 .01 1 .99])
set(0, 'defaultAxesBox', 'on')
set(0, 'defaultAxesXGrid', 'on')
set(0, 'defaultAxesYGrid', 'on')
set(0, 'defaultAxesZGrid', 'on')
set(0, 'defaultImageCreateFcn', @newImageFcn)
set(0, 'defaultLineLineWidth', 2)
set(0, 'defaultUicontrolBackgroundcolor', [1 1 1])
close(get(groot,'CurrentFigure'));

% switch off for performance reasons if necessary:
% set(groot,'DefaultFigureGraphicsSmoothing','off')

%% first doped run: 283

asrHandles = pnccdGUI(paths,...
    'run',301, ...
    'hit', 1);

function newImageFcn(src,~)
    axis(src.Parent, 'image');
    set(src.Parent,'YDir','normal','XGrid','off','YGrid','off','ZGrid','off');
end

