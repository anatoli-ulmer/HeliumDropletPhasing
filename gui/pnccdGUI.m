function pnccdGUI(varargin)

%% Source paths
fprintf('\n\n\n\n\nStarting pnCCD GUI _/^\\_/^\\_\n\t\t\t... please be patient ...\n\n\n\n\n')
pnccdGUIPaths = getXfelPaths;
pnccdGUIPaths.pnccd = pnccdGUIPaths.pnccd_dcg;
thisPath = fileparts(fullfile(mfilename('fullpath')));
addpath(genpath(fullfile(thisPath,'\..')));

%% Figure creation & initifullfile(mfilename('fullpath'),'..')alization of grapical objects
hFig.main = figure(1010101); 
clf(hFig.main);
% for performance reasons:
hFig.main.GraphicsSmoothing=false;

hFig.centering = gobjects(1);
hFig.shape1 = gobjects(1);
hFig.shape2 = gobjects(1);
hFig.simu = gobjects(1);
hFig.simupol = gobjects(1);

hAx.pnccd = gobjects(1);
hAx.pnccd_CBar = gobjects(1);
hAx.lit = gobjects(1);
hAx.centering = gobjects(1);
hAx.shape = gobjects(1);

hPlt.pnccd = gobjects(1);
hPlt.lit = gobjects(1);
hPlt.lit_current = gobjects(1);
hPlt.rings = gobjects(1);
hPlt.centering = gobjects(1);

%% Declarations
run = 450;
hit = 68;
hData.trainId = nan;
hData.filepath = pnccdGUIPaths.pnccd;
pnccd = [];

db.runInfo = [];
db.center = [];
db.shape = [];
% db.sizing = [];

hData.shape = [];
hData.filename = '';

hData.par.nPixelFull = [1100,1050];
hData.par.nPixel = [1024, 1024];
hData.par.datatype = 'single';
hData.par.cLims = [0.1, 100];
hData.par.cMap = imorgen;
hData.par.nRings = 15;
hData.par.ringwidth = 1;
hData.par.nSimCores = 1;
% Hard coded custom Gaps and Shifts for different shifts if for testing geometry
% consistency
hData.par.addCenter = [0,0];
hData.par.addGap = 0;
hData.par.addShift = 0;
hData.par.addGapArray = zeros(1,6);
hData.par.addShiftArray = zeros(1,6);

hData.bool.logScale = true;
hData.bool.drawRings = false;
hData.bool.autoScale = false;
hData.bool.simulationMode = false;
hData.bool.isCropped=false;

hData.var.nHits = nan;
hData.var.nSteps = 100;
hData.var.nLoops = 1;
hData.var.radiusInPixel = nan;
hData.var.radiusInNm = nan;
hData.var.gapSize = nan;
hData.var.shiftSize = nan;
hData.var.center = hData.par.nPixelFull/2;
hData.var.center_sim = hData.var.center;
hData.var.nPhotonsOnDetector = nan;

hData.img.input = nan(hData.par.nPixel, hData.par.datatype);
hData.img.mask = ones(hData.par.nPixel, hData.par.datatype);
hData.img.data = nan(hData.par.nPixelFull, hData.par.datatype);
hData.img.dataSimulated = nan(hData.par.nPixelFull, hData.par.datatype);
hData.img.dataCorrected = nan(hData.par.nPixel, hData.par.datatype);
hData.img.dataCropped = nan(hData.par.nPixel, hData.par.datatype);
hData.img.support = nan(hData.par.nPixel, hData.par.datatype);
hData.img.dropletdensity = nan(hData.par.nPixel, hData.par.datatype);
hData.img.dropletOutline.x=nan(1,100);
hData.img.dropletOutline.y=nan(1,100);

hPrevData.run = nan;
hPrevData.hit = nan;
hPrevData.filename = '';
hPrevData.pnccd = [];
hPrevData.hRecon = [];
hSave = [];
hSave.folder = pnccdGUIPaths.img;
hRecon = [];
hIPR = [];
hSimu = [];

%% Input parser
if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'run', run = varargin{ni+1};
            case 'hit', hit = varargin{ni+1};
            case 'pnccdpath'
                hData.filepath = varargin{ni+1};
                pnccdGUIPaths.pnccd = hData.filepath;
            case 'clims', hData.par.cLims = varargin{ni+1};
            case 'nsteps', hData.var.nSteps = varargin{ni+1};
            case 'nloops', hData.var.nLoops = varargin{ni+1};
            case 'db_run_info', db.runInfo = varargin{ni+1};
            case 'db_sizing', db.sizing = varargin{ni+1};
            case 'db_center', db.center = varargin{ni+1};
            case 'db_shape', db.shape = varargin{ni+1};
        end
    end
end
if isempty(db.runInfo)
    db.runInfo = load(fullfile(thisPath,'/db/db_run_info.mat'));
end
if isempty(db.sizing)
    db.sizing = load(fullfile(thisPath,'/db/db_sizing.mat'));
end
if isempty(db.center)
    db.center = load(fullfile(thisPath,'/db/db_center.mat'));
end
if isempty(db.shape)
    db.shape = load(fullfile(thisPath,'/db/db_shape.mat'));
end

%% Init
initFcn;

%% Methods
    %% Key and Button Callbacks
    function thisKeyPressFcn(src,evt)
        src.Pointer = 'watch'; drawnow;
        switch evt.Key
            case 'alt', hFig.main.UserData.isRegisteredAlt = true;
            case 'control', hFig.main.UserData.isRegisteredControl = true;
            case 'shift', hFig.main.UserData.isRegisteredShift = true;
        end
    end % thisKeyPressFcn
    function thisKeyReleaseFcn(src,evt)
        switch evt.Key
            case 'escape',              hFig.main.UserData.stopScript = true;
            case 'leftarrow',           loadNextHit(src,evt,-1);
            case 'rightarrow',          loadNextHit(src,evt,1);
            case 's'
                if hFig.main.UserData.isRegisteredShift, startSimulation;
                elseif hFig.main.UserData.isRegisteredControl, saveImgFcn;
                else saveDBFcn;
                end
            case 'l',                   getFileFcn;
            case 'c'
                clc; src.Pointer = 'arrow'; drawnow;
            case {'1','numpad1'},       centerImgFcn;
            case {'2','numpad2'},       findShapeFcn
            case {'3','numpad3'}
                if ~hFig.main.UserData.isRegisteredShift
                    initIPR
                else
                    initIPRsim
                end
            case {'4','numpad4'}
                hIPR.addReconPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
            case {'5','numpad5'}
                hIPR.addReconPlan('er',hData.var.nSteps,hData.var.nLoops);
            case {'6','numpad6'}
                hIPR.addReconPlan('hio',hData.var.nSteps,hData.var.nLoops);
            case {'7','numpad7'}
                hIPR.addReconPlan('nthio',hData.var.nSteps,hData.var.nLoops);
            case {'8','numpad8'}
                hIPR.addReconPlan('raar',hData.var.nSteps,hData.var.nLoops);
            case {'9','numpad9'},       oneShotRecon
            case {'return'},       hIPR.startRecon;
            case 'k', reconANDsave
            case 'f12'
                hIPR.scanParameter('alpha', (0.5:0.05:1.5), hSave.folder);
            case 'f11'
                hIPR.scanParameter('deltaFactor', (0:1:11), hSave.folder);
            case {'r','numpad0'}
                hIPR.resetIPR();
                %             otherwise, disp(evt.Key);
        end
        unregisterKeys(hFig.main);
        src.Pointer = 'arrow'; drawnow;
        hFig.main.UserData.registeredKey = '';
    end % thisKeyReleaseFcn
    function unregisterKeys(src)
        src.UserData.isRegisteredAlt = false;
        src.UserData.isRegisteredControl = false;
        src.UserData.isRegisteredShift = false;
    end % unregisterKeys
    function thisWindowButtonDownFcn(src,~)
        if strcmp(src.SelectionType, 'open')
            if src.CurrentAxes==hAx.lit
                %hFig.main.UserData.origMousePos = src.CurrentAxes.CurrentPoint;
                %hit = round(hFig.main.UserData.origMousePos(2));
                hit = round(src.CurrentAxes.CurrentPoint(2));
                hFig.main_uicontrols.index_txt.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
                loadImageData;
                updatePlotsFcn;
                return
            end
        end
    end % thisWindowButtonDownFcn
    %% Initialization Functions
    function initFcn(~,~)
        %%%%%%%%%%% databases %%%%%%%%%%%
        db = loadDatabases(pnccdGUIPaths, db);
        if db.runInfo(run).isData
            %             hData.filename = sprintf('%04i_hits.mat', run);
            %             hData.matObj = matfile(fullfile(paths.pnccd, hData.filename));
            %             load(fullfile(pnccdGUIPaths.pnccd, hData.filename), '-mat', 'pnccd');
            [pnccd, hData.filename, hData.var.nHits] = pnccd_load_run(run, pnccdGUIPaths.pnccd);
        else
            error('Warning: run #%i is not a data run and was not loaded!', run);
        end
        %%%%%%%%%%% gui objects %%%%%%%%%%%
        createGUI;
        hFig.main_uicontrols.CMin_edt.String = num2str(hData.par.cLims(1));
        hFig.main_uicontrols.CMax_edt.String = num2str(hData.par.cLims(2));
        hFig.main_uicontrols.index_txt.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
        hFig.main_uicontrols.nRings_edt.String = sprintf('%i', hData.par.nRings);
        hFig.main_uicontrols.ringWidth_edt.String = sprintf('%i', hData.par.ringwidth);
        hFig.main_uicontrols.nSteps_edt.String = sprintf('%i', hData.var.nSteps);
        hFig.main_uicontrols.nLoops_edt.String = sprintf('%i', hData.var.nLoops);
        
        %%%%%%%%%%% parameters %%%%%%%%%%%
%         hData.img.mask(491-3:534+3, 483-5:542+5) = 0;
%         hData.img.mask(508:512, 548:552) = 0;
%         hData.img.mask(569:571, 549:551) = 0;
%         hData.img.mask(510:512, 474:477) = 0;
%         hData.img.mask(569:571, 549:551) = 0;
        loadImageData;
        createPlots;
    end % initFcn
    function createGUI(~,~)
        hFig.main.Visible = 'off';
        hFig.main.Name = 'pnccdGUI';
        hFig.main.KeyPressFcn = @thisKeyPressFcn;
        hFig.main.KeyReleaseFcn = @thisKeyReleaseFcn;
        hFig.main.WindowButtonDownFcn = @thisWindowButtonDownFcn;
        hFig.main.UserData.dragging = false;
        hFig.main.UserData.stopScript = false;
        hFig.main.UserData.isRegisteredAlt = false;
        hFig.main.UserData.isRegisteredControl = false;
        hFig.main.UserData.isRegisteredShift = false;
        
        hAx.pnccd = axes('OuterPosition', [.0 .0 .55 .95]);
        hAx.pnccd.Tag = 'pnccd';
        hAx.lit = axes('OuterPosition', [.525 .025 .5 .5]);
        hAx.lit.Tag = 'lit';
        
        hFig.main_uicontrols.CMin_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', '0.1',...
            'Units', 'normalized', 'Position', [.445 .02 .045 .045], 'Callback', @manualCLimChange);
        hFig.main_uicontrols.CMax_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', '60',...
            'Units', 'normalized', 'Position', [.445 .92 .045 .045], 'Callback', @manualCLimChange);
        hFig.main_uicontrols.logScale_cbx = uicontrol(hFig.main, 'Style', 'checkbox', 'String', 'log10', 'Value', true,...
            'Units', 'normalized', 'Position', [.55 .75 .07 .04], 'Callback', @scaleChangeFcn,...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.autoScale_cbx = uicontrol(hFig.main, 'Style', 'checkbox', 'String', 'autoScale', 'Value', false,...
            'Units', 'normalized', 'Position', [.55 .8 .1 .04], 'Callback', @scaleChangeFcn,...
            'Backgroundcolor', hFig.main.Color);
        
        hFig.main_uicontrols.prev_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '-',...
            'Units', 'normalized', 'Position', [.6 .9 .05 .05], 'Callback', @loadNextHit);
        hFig.main_uicontrols.next_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '+',...
            'Units', 'normalized', 'Position', [.7 .9 .05 .05], 'Callback', @loadNextHit);
        hFig.main_uicontrols.index_txt = uicontrol(hFig.main, 'Style', 'text', 'String', '1',...
            'Units', 'normalized', 'Position', [.65 .89 .05 .05],...
            'Backgroundcolor', hFig.main.Color);
        
        hFig.main_uicontrols.file_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'load run',...
            'Units', 'normalized', 'Position', [.8 .9 .075 .05], 'Callback', @getFileFcn);
        hFig.main_uicontrols.saveImg_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'save image',...
            'Units', 'normalized', 'Position', [.9 .9 .075 .05], 'Callback', @saveImgFcn);
        
        hFig.main_uicontrols.ring_cbx = uicontrol(hFig.main, 'Style', 'checkbox', 'String', 'plot rings', 'Value', false,...
            'Units', 'normalized', 'Position', [.55 .7 .1 .04], 'Callback', @ringCbxCallback,...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.nRings_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', '15',...
            'Units', 'normalized', 'Position', [.55 .65 .03 .04], 'Callback', @plotRings);
        hFig.main_uicontrols.ringWidth_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', '1',...
            'Units', 'normalized', 'Position', [.55 .6 .03 .04], 'Callback', @plotRings);
        hFig.main_uicontrols.nRings_txt = uicontrol(hFig.main, 'Style', 'text', 'String', '# rings',...
            'Units', 'normalized', 'Position', [.59 .65 .06 .04],...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.ringWidth_txt = uicontrol(hFig.main, 'Style', 'text', 'String', 'ring width',...
            'Units', 'normalized', 'Position', [.59 .6 .06 .04],...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.cMap_txt = uicontrol(hFig.main, 'Style', 'edit', 'String', 'imorgen',...
            'Units', 'normalized', 'Position', [.59 .55 .06 .04],...
            'Backgroundcolor', hFig.main.Color, 'Callback', @setCMap );
        
        hFig.main_uicontrols.findCenter_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'find center',...
            'Units', 'normalized', 'Position', [.7 .76 .07 .05], 'Callback', @centerImgFcn);
        hFig.main_uicontrols.findShape_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'find shape',...
            'Units', 'normalized', 'Position', [.7 .69 .07 .05], 'Callback', @findShapeFcn);
        hFig.main_uicontrols.initIPR_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'init phasing',...
            'Units', 'normalized', 'Position', [.7 .62 .07 .05], 'Callback', @initIPR);
        hFig.main_uicontrols.ER_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'add DCDI',...
            'Units', 'normalized', 'Position', [.8 .76 .07 .05], 'Callback', @addDCDI );
        hFig.main_uicontrols.HIO_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'add ntHIO',...
            'Units', 'normalized', 'Position', [.8 .69 .07 .05], 'Callback', @addHIO );
        hFig.main_uicontrols.finish_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'start plan',...
            'Units', 'normalized', 'Position', [.8 .62 .07 .05], 'Callback', @runRecon );
        hFig.main_uicontrols.nSteps_edt = uicontrol(hFig.main, 'Style', 'edit',...
            'Units', 'normalized', 'Position', [.9 .76 .035 .05], 'String', '100',...
            'Callback', @setNSteps);
        hFig.main_uicontrols.nLoops_edt = uicontrol(hFig.main, 'Style', 'edit',...
            'Units', 'normalized', 'Position', [.9 .69 .035 .05], 'String', '1',...
            'Callback', @setNLoops);
        hFig.main_uicontrols.nSteps_txt = uicontrol(hFig.main, 'Style', 'text',...
            'Units', 'normalized', 'Position', [.95 .76 .035 .05], 'String', 'steps',...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.nLoops_txt = uicontrol(hFig.main, 'Style', 'text',...
            'Units', 'normalized', 'Position', [.95 .69 .035 .05], 'String', 'loops',...
            'Backgroundcolor', hFig.main.Color);
        
        hFig.main_uicontrols.startSimulation_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'start simulation',...
            'Units', 'normalized', 'Position', [.705 .55 .10 .05], 'Callback', @startSimulation);
        
        hFig.main_uicontrols.nCores_bg=uibuttongroup(hFig.main,...
            'Position',[.81 .54 .08 .07],'SelectionChangedFcn',@setNSimCores);
        hFig.main_uicontrols.oneCore_tb=uicontrol(hFig.main_uicontrols.nCores_bg,...
            'Style','radiobutton','Units','normalized','Position',[0,.5,1,.5],'String','1 Core','Callback',@setNSimCores);
        hFig.main_uicontrols.twoCores_tb=uicontrol(hFig.main_uicontrols.nCores_bg,...
            'Style','radiobutton','Units','normalized','Position',[0,0,1,.5],'String','2 Cores');
    end % createGUI
    function createPlots(~,~)
        cla(hAx.pnccd);
        hPlt.pnccd = imagesc(nan(hData.par.nPixelFull), 'parent', hAx.pnccd);
        axis(hAx.pnccd, 'image');
        
        hAx.pnccd.Title.String = sprintf('run #%03i train id %i', run, hData.trainId);
        hAx.pnccd.CLimMode = 'manual';
        hAx.pnccd.CLim = iif(hData.bool.autoScale, ([nanmin(hData.img.data(:)),nanmax(hData.img.data(:))]), logS(hData.par.cLims));
        hAx.pnccd_CBar = colorbar(hAx.pnccd);
        colormap(hAx.pnccd, hData.par.cMap);
        plotRings;
        
        cla(hAx.lit); hold(hAx.lit, 'off');
        hPlt.lit = stem(hAx.lit, db.runInfo(run).nlit_smooth);
        %         hPlt.lit.ButtonDownFcn = @thisWindowButtonDownFcn;
        hold(hAx.lit, 'on'); grid(hAx.lit, 'on');
        hPlt.lit_current = stem(hAx.lit, hit, hData.var.nLitPixel, 'r');
        
        hAx.lit.XLim = [.75, numel(db.runInfo(run).nlit_smooth)+.25];
        hAx.lit.Title.String = 'lit pixel over hit index';
        hAx.pnccd.UserData = [hAx.pnccd.XLim; hAx.pnccd.YLim];
        hAx.lit.UserData = [hAx.lit.XLim; hAx.lit.YLim];
        updatePlotsFcn;
    end % createPlots
    %% Plot Functions
    function updatePlotsFcn(~,~)
        updateImgData();
        hPlt.pnccd.CData = logS(hData.img.data);
        hPlt.pnccd.XData = (1:size(hData.img.data,2))-hData.var.center(2);
        hPlt.pnccd.YData = (1:size(hData.img.data,1))-hData.var.center(1);
        hAx.pnccd.CLim = iif(hData.bool.autoScale, ([nanmin(hData.img.data(:)),nanmax(hData.img.data(:))]), logS(hData.par.cLims));
        hAx.pnccd_CBar.TickLabels = iif(hData.bool.logScale, sprintf('10^{%.0g}\n', (hAx.pnccd_CBar.Ticks)), hAx.pnccd_CBar.Ticks);
        
        hPlt.lit.XData = 1:numel(db.runInfo(run).nlit_smooth);
        hPlt.lit.YData = db.runInfo(run).nlit_smooth;
        hPlt.lit_current.XData = hit;
        hPlt.lit_current.YData = hData.var.nLitPixel;
        
        hAx.pnccd.Title.String = sprintf('run #%03i - id %i - hit %i, R = %.0fnm', run, hData.trainId, hit , db.sizing(run).R(hit)*1e9);
        hAx.lit.Title.String = sprintf('%.3g lit pixel // %.3g photons', hData.var.nLitPixel, hData.var.nPhotonsOnDetector);
        %         scaleChangeFcn;
        plotRings;
        
        hFig.main.Visible = 'on';
        hFig.main.Pointer = 'arrow';
        drawnow limitrate;
    end % updatePlotsFcn
    function plotRings(~,~)
        if hData.bool.drawRings
            hold(hAx.pnccd, 'on');
            hData.par.nRings = str2num_fast(hFig.main_uicontrols.nRings_edt.String);
            hData.par.ringwidth = str2num_fast(hFig.main_uicontrols.ringWidth_edt.String);
            hPlt.rings = draw_rings(hAx.pnccd, [0,0], hData.par.nRings, [], hData.par.ringwidth);
            grid(hAx.pnccd, 'off');
            hold(hAx.pnccd, 'off');
        end
    end % plotRings
    function setCMap(~,~)
        hData.par.cMap = hFig.main_uicontrols.cMap_txt.String;
        colormap(hAx.pnccd, hData.par.cMap);
    end % setCMap
    function manualCLimChange(~,~)
        hData.par.cLims = [str2num_fast(hFig.main_uicontrols.CMin_edt.String), str2num_fast(hFig.main_uicontrols.CMax_edt.String)];
        updatePlotsFcn;
    end % manualCLimChange
    function scaleChangeFcn(~,~)
        hData.bool.autoScale = hFig.main_uicontrols.autoScale_cbx.Value;
        hData.bool.logScale = hFig.main_uicontrols.logScale_cbx.Value;
        updatePlotsFcn;
    end % scaleChangeFcn
    function val = logS(val)
        if hData.bool.logScale
            val(val<=0) = nan;
            val = log10(val);
        end
    end % logS
    function setNSteps(~,~)
        hData.var.nSteps = str2num_fast(hFig.main_uicontrols.nSteps_edt.String);
    end % setNSteps
    function setNLoops(~,~)
        hData.var.nLoops = str2num_fast(hFig.main_uicontrols.nLoops_edt.String);
    end % setNLoops
    function ringCbxCallback(~,~)
        hData.bool.drawRings = hFig.main_uicontrols.ring_cbx.Value;
        if hData.bool.drawRings
            plotRings;
        elseif isvalid(hPlt.rings)
            delete(hPlt.rings);
        end
    end % ringCbxCallback
    %% Load Data Functions
    function loadImageData(~,~)
        fprintf('Loading run #%03d hit %01d ...\n', run, hit)
        % Get data from databases
        hData.bool.simulationMode = false;
        hData.bool.isCropped=false;
        hData.img.input = pnccd.data(hit).image;
        hData.trainId = pnccd.trainid(hit);
        % Old correction needs to be made
        if ~db.sizing(run).ok(hit); db.sizing(run).R(hit) = nan; end
        hData.var.radiusInNm = db.sizing(run).R(hit);
        hData.var.radiusInPixel = db.sizing(run).R(hit)*1e9/6;
        hData.var.nLitPixel = db.runInfo(run).nlit_smooth(hit);
        hData.var.nPhotonsOnDetector = nansum(hData.img.data(:));
        
        % Check if run was background subtracted (folder name ends with "_bg").
        % Do Subtraction if not. TO DO: introduce another criterium or do
        % subtraction beforehand in all cases!
        if ~strcmp(pnccdGUIPaths.pnccd(end-2:end-1),'bg')
            hData.img.input = hData.img.input - pnccd.bg_corr;
        end
        % Custom masking
        hData.img.input(hData.img.mask==0) = nan;
        hData.img.mask = ~isnan(hData.img.input);
        hData.par.addCenter = -1*[1,1];
        hData.par.addGapArray = [0 0 -2 -3 -1 1];
        hData.par.addShiftArray = [0 0 -2 1 0 -1];
        hData.par.addGap = hData.par.addGapArray(db.runInfo(run).shift);
        hData.par.addShift = hData.par.addShiftArray(db.runInfo(run).shift);
        % Automatic correction of relative geometry (gap size and left/right
        % shift) from calculated values based on the motor encoder values of
        % the pnCCDs, and manual calibration for some images.
        [hData.img.dataCorrected,hData.var.gapSize,hData.var.shiftSize,~,...
            hData.var.center]=pnccdGeometryFcn(hData.img.input,db.runInfo,...
            pnccd.run,hData.par.nPixelFull,hData.par.addGap,hData.par.addShift);
        if ~isempty(db.center(run).center)
            if hit <= numel(db.center(run).center)
                if ~isempty(db.center(run).center(hit).data)
                    hData.var.center = db.center(run).center(hit).data...
                        + hData.par.addCenter;
                    hData.img.dataCropped = centerAndCropFcn(...
                        hData.img.dataCorrected, hData.var.center);
                    hData.bool.isCropped=true;
                    fprintf('...centered\t...cropped\n');
                end
            end
        end
        hData.shape = [];
        if ~isempty(db.shape(run).shape)
            if hit <= numel(db.shape(run).shape)
%                 if ~isempty(db.shape(run).shape(hit).data)
                    hData.shape = db.shape(run).shape(hit).data;
                    [hData.img.dropletdensity, hData.img.support] = ...
                        ellipsoid_density(hData.shape.a/2,hData.shape.b/2,...
                        (hData.shape.a/2+hData.shape.b/2)/2,hData.shape.rot,...
                        [513,513], [1024,1024]);
                    fprintf('...shape found\t...got support & density\n');
                    %% BEGIN: DETECTOR GEOMETRY CORRECTION
                    %                     dataScatt = hData.img.dataCorrected;
                    %                     simScatt = abs(ft2(hData.img.dropletdensity)).^2;
                    %                     refineDetectorGeometry(dataScatt, simScatt)
                    %% END: DETECTOR GEOMETRY CORRECTION
%                 end
            end
        end
        updateImgData();
    end % loadImageData
    function updateImgData(~,~)
        if hData.bool.simulationMode, hData.img.data=hData.img.dataSimulated;
        elseif hData.bool.isCropped, hData.img.data=hData.img.dataCropped;
        else, hData.img.data=hData.img.dataCorrected;
        end
    end % updateImgData
    function loadNextHit(src,evt,direction)
        if nargin<3
            switch src.String
                case 43, direction = -1;
                case 45, direction = 1;
                otherwise
                    error('Error in pnccdGUI/loadNextHit: direction not defined and caller function is not the "+" or "-" button callback.')
            end
        end
        if hit+direction<1 || hit+direction>numel(pnccd.trainid)
            loadNextFile(src,evt,hData.filepath, run+direction, direction);
        else
            hit = hit+direction;
            hFig.main_uicontrols.index_txt.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
            loadImageData;
        end
        createPlots;
    end % loadNextHit
    function loadNextFile(~,~,filepath,nextRun,direction)
        saveDBFcn
        %         fprintf('saving recon file ...'); drawnow;
        %         save(fullfile(paths.recon, sprintf('r%04d_recon_%s.mat', run, db.runInfo(run).doping.dopant{:})), 'hRecon', '-v7.3');
        %         fprintf('done!\n'); drawnow;
        if ~exist('direction','var')
            direction = 1;
        end
        
        nextFile = fullfile(filepath, sprintf('%04i_hits.mat', nextRun));
        while ~db.runInfo(nextRun).isData || ~exist(nextFile, 'file')
            warning(['Run #%03d is not a data run and was not loaded.\n',...
                'Trying next: run #%03d\n'], nextRun, nextRun+direction);
            nextRun = nextRun + direction;
            nextFile = fullfile(pnccdGUIPaths.pnccd, sprintf('%04i_hits.mat', nextRun));
            if nextRun>489 || nextRun<200; return; end
        end
        fprintf('loading file %s\n', nextFile)
        % Save previous data for faster loading of the last viewed file
        [run, hPrevData.run] = swap(run, hPrevData.run);
        [hit, hPrevData.hit] = swap(hit, hPrevData.hit);
        [pnccd, hPrevData.pnccd] = swap(pnccd, hPrevData.pnccd);
        [hRecon, hPrevData.hRecon] = swap(hRecon, hPrevData.hRecon);
        [hData.filename, hPrevData.filename] = swap(hData.filename, hPrevData.filename);
        
        % Check if new path folder was selected
        if ~strcmp(filepath, hData.filepath)
            hData.filepath = filepath;
            hPrevData.run = nan;
        end
        
        % Check if requested run is stored in hPrevData, otherwise load it.
        if run ~= nextRun
            [pnccd, hData.filename, hData.var.nHits] = pnccd_load_run(nextRun, pnccdGUIPaths.pnccd);
            run = pnccd.run;
            %             hRecon = load_recon(nextrun, paths.recon);
        end
        hit = iif(direction>0,1,numel(db.runInfo(run).nlit_smooth));
        loadImageData;
    end % loadNextFile
    function getFileFcn(src,evt)
        [fn, fp] = uigetfile(fullfile(pnccdGUIPaths.pnccd, hData.filename));
        if isequal(fn,0)
            disp('User selected Cancel')
        else
            pnccdGUIPaths.pnccd = fp;
            hAx.pnccd.Title.String = sprintf('loading run #%si ...', fn(1:4)); drawnow;
            nextrun = str2num_fast(fn(1:4));
            loadNextFile(src, evt, fp, nextrun);
            createPlots;
        end
    end % getFileFcn
    %% Centering und Shape Determination
    function centerImgFcn(~,~)
        hFig.main.Pointer = 'watch'; drawnow;
        if ~isgraphics(hFig.centering)
            hFig.centering=figure('IntegerHandle',1010102,'Tag','centerFigure');
            figure(hFig.main);
            hFig.centering.KeyPressFcn = @centerkeyfun;
            hFig.centering.Name = 'centering';
        end
        %         if hit<=numel(db.center(run).center)
        %             if isfield(db.center(run).center(hit),'data')
        %                 if ~isempty(db.center(run).center(hit).data)
        %                     hData.var.center = db.center(run).center(hit).data;
        %                     hData.var.center = hData.var.center + [hData.par.addGap/2, -hData.par.addShift/2];
        %                     hFig.main.Pointer = 'arrow'; drawnow;
        %                     %                     centrosymmetric
        %                     updatePlotsFcn;
        %                     return
        %                 end
        %             end
        %         end
        if any( (hData.var.center-size(hData.img.dataCorrected)/2) > 100)
            hData.var.center=size(hData.img.dataCorrected)/2;
        end
        [hData.var.center, hAx.centering, hPlt.centering] = findCenterFcn(...
            hData.img.dataCorrected,'figure',hFig.centering,'center',...
            hData.var.center,'nWedges',16,'movMeanPixel',3,'rMin',70,...
            'rMax',160,'displayflag',1,'nIterations',7);
        db.center(run).center(hit).data = hData.var.center;
        hFig.main.Pointer = 'arrow'; drawnow;
        hData.img.dataCropped = centerAndCropFcn(...
            hData.img.dataCorrected, hData.var.center);
        hData.bool.isCropped=true;
        updateImgData();
        updatePlotsFcn();
        %% INCLUDE THIS AGAIN!
%         save(fullfile(thisPath, 'db/db.mat'), 'db');
        fprintf('    -> centered\n')
    end % centerImgFcn
    function centerkeyfun(~, eventdata)
        hFig.main.Pointer = 'watch'; drawnow;
        dc = 1;
        switch eventdata.Key
            case 'uparrow'
                hData.var.center(1)=hData.var.center(1)+dc;
            case 'downarrow'
                hData.var.center(1)=hData.var.center(1)-dc;
            case 'leftarrow'
                hData.var.center(2)=hData.var.center(2)-dc;
            case 'rightarrow'
                hData.var.center(2)=hData.var.center(2)+dc;
            case 's'
                db.center(run).center(hit).data = hData.var.center;
                %                 save('E:\XFEL2019_He\db_center.mat','db.center')
            case {'1', 'numpad1'}
                centerImgFcn;
                figure(1010102);
            case {'2', 'numpad2'}
                findShapeFcn;
                figure(1010102);
            case {'3', 'numpad3'}
                initIPR
            case {'0', 'numpad0'}
                initIPRsim
        end
        db.center(run).center(hit).data = hData.var.center;
        try delete(hPlt.centering.black); end %#ok<TRYNC>
        try delete(hPlt.centering.red); end %#ok<TRYNC>
        hPlt.centering.black = draw_rings(hAx.centering, flipud(hData.var.center), 0, 70:20:150, 2, [0,.9,.9]);
        hPlt.centering.red = draw_rings(hAx.centering, flipud(hData.var.center), 0, 80:20:150, 2, 'r', '--');
        hFig.main.Pointer = 'arrow'; drawnow;
    end % centerkeyfun
    function findShapeFcn(~,~)
        hFig.main.Pointer = 'watch'; drawnow;
        if ~isgraphics(hFig.shape1)
            hFig.shape1 = figure(1010103);
            hFig.shape1.Name = 'shape figure #1';
        end
        if ~isgraphics(hFig.shape2)
            hFig.shape2 = figure(1010104); 
            hFig.shape2.Name = 'shape figure #2';
        end
        if ~isgraphics(hAx.shape)
            hAx.shape=mysubplot(1,2,2,'parent',hFig.shape2); 
        end
        [hData.shape, hAx.shape] = findShapeFit(hData.img.dataCropped, hData.var.radiusInPixel, 'fig1', hFig.shape1, 'fig2', hFig.shape2, 'ax', hAx.shape);
        db.shape(run).shape(hit).data = hData.shape;
        db.shape(run).shape(hit).R = 6*(hData.shape.a/2 + hData.shape.b/2)/2;
        db.shape(run).shape(hit).ar = iif(hData.shape.a>hData.shape.b, hData.shape.a/hData.shape.b, hData.shape.b/hData.shape.a);
        [hData.img.dropletdensity, hData.img.support] = ellipsoid_density(hData.shape.a/2, hData.shape.b/2, (hData.shape.a/2+hData.shape.b/2)/2, hData.shape.rot, [512.5,512.5], [1024,1024]);
        hData.img.dropletOutline = ellipse_outline(hData.shape.a/2*6, hData.shape.b/2*6, -hData.shape.rot);
        fprintf('ellipse parameters: \n[a, b, rot] = [%.2fpx, %.2fpx, %.2frad]\n', hData.shape.a/2,hData.shape.b/2,hData.shape.rot)
        fprintf('[a, b, rot] = [%.2fnm, %.2fnm, %.2fdegree]\n', hData.shape.a/2*6,hData.shape.b/2*6,hData.shape.rot/2/pi*360)
        %         hData.img.support = imopen(hData.img.support,strel('disk',2,0));
        %         hData.img.support =
        %         imdilate(hData.img.support,strel('square',2));
        %         hData.img.support = imerode(hData.img.support,strel('disk',1,0));
        %         hData.img.support = imopen(hData.img.support,strel('disk',4,0));
        figure(4949494); clf
%         hAxSupport=mysubplot(1,2,1); imagesc(hData.img.support); title('reconstruction support');
%         hAxDensity=mysubplot(1,2,2);
        limy=6*size(hData.img.dropletdensity,1)/2*[-1,1]-[0,1];
        limx=6*size(hData.img.dropletdensity,2)/2*[-1,1]-[0,1];
        imagesc(hData.img.dropletdensity,'XData',limx,'YData',limy); title('calculated droplet density');
        colormap('igray'); hold('on');
        plot(hData.img.dropletOutline.x,hData.img.dropletOutline.y,'r--');
%         linkaxes([hAxSupport,hAxDensity],'xy');
        xlim([-1,1]*mean([hData.shape.a,hData.shape.a])/2*1.2*6); ylim(xlim);
        figure(hFig.main)
        hFig.main.Pointer = 'arrow'; drawnow;
        updatePlotsFcn;
        fprintf('    -> shape found\n')
    end % findShapeFcn
    %% Reconstruction Functions
    function initIPR(~,~)
        hFig.main.Pointer = 'watch'; drawnow limitrate;
        clear hIPR;
        hIPR = IPR(hData.img.dataCropped, ...%             'objectHandle', hIPR, ...
            'support0', hData.img.support, ...
            'support_radius', db.sizing(run).R(hit)*1e9/6, ...
            'dropletOutline', hData.img.dropletOutline, ...    
            'rho0', hData.img.dropletdensity,...
            'parentfig', hFig.main);
        hFig.main.Pointer = 'arrow'; drawnow limitrate;
        hIPR.figureArray.Pointer = 'arrow'; drawnow limitrate;
        %         figure(hFig.main)
    end % initIPR
    function initIPRsim(~,~)
        hFig.main.Pointer = 'watch'; drawnow limitrate;
        if isempty(hData)
            error(['No simulation data available. ',...
                'Please start a simulation first.'])
        end
        clear hIPR;
        if hData.par.nSimCores, simData=hSimu.simData.scatt1;
        else, simData=hSimu.simData.scatt2;
        end
        simData=centerAndCropFcn(simData,[512.5,512.5]);
        hIPR = IPR(simData, ...%             'objectHandle', hIPR, ...
            'support0', hSimu.simData.droplet>0, ...
            'support_radius', (hSimu.simParameter.aDrop+hSimu.simParameter.bDrop)/2/6, ...
            'dropletOutline', hData.img.dropletOutline, ...
            'rho0', hSimu.simData.droplet,...
            'parentfig', hFig.main);
        hIPR.plotAll;
        hFig.main.Pointer = 'arrow'; drawnow limitrate;
    end % initIPRsim
    function addDCDI(~,~)
        hIPR.addReconPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
    end % addDCDI
    function addHIO(~,~)
        hIPR.addReconPlan('nthio',hData.var.nSteps,hData.var.nLoops);
    end % addHIO
    function runRecon(~,~)
        hIPR.startRecon();
    end % runRecon
    function oneShotRecon(~,~)
        DENSITY = fftshift(fft2(fftshift(hData.img.dropletdensity)));
        if isempty(hIPR)
            img_int = hData.img.data;
            img_int(img_int<0)=0;
            img_int(isnan(img_int)) = 0;
            img_int = sqrt(img_int);
            mmm = isnan(hData.img.data);
            scaleFactor = nansum( img_int.*~mmm ) / nansum( abs( DENSITY.*~mmm ) );
            ONEShot = (img_int.*~mmm) + ( abs(DENSITY.*mmm) ) * scaleFactor;
            ONEShot = ONEShot.*exp(1i*angle(DENSITY));
            oneShot = fftshift(ifft2(fftshift(ONEShot)));
            oneShot = (oneShot-density*scaleFactor).*hData.img.support;
        else
            DENSITY = fftshift(fft2(fftshift(hIPR.hData.img.dropletdensity)));
            img_int = abs(gather(hIPR.WS));
            img_angle = angle(gather(hIPR.WS));
            ONEShot = ( ( (1-hIPR.MASK).* abs(DENSITY) ) + ( hIPR.MASK .* abs(gather(hIPR.WS)) ) )...
                .* angle(hIPR.WS);
            oneShot = fftshift(ifft2(fftshift(ONEShot)));
            oneShot = (oneShot-hIPR.density).*hIPR.hData.img.support;
        end
        
        
        figure(847847)
        subplot(221); imagesc(log10(abs(ONEShot).^2), [-2,2])
        subplot(222); imagesc(real(oneshot))
        subplot(223); imagesc((angle(DENSITY)))
        subplot(224); imagesc(log10(abs(ONEShot).^2), [-2,2]);
    end % oneShotRecon
    %% Simulation Functions
    function startSimulation(~,~)
        fprintf('Starting simulation ...\n')
        hData.bool.simulationMode = true;
        hSimu = simulatePatternApp(hData.img.dataCorrected, ...
            ~isnan(hData.img.dataCorrected), ...
            hData.par, ...
            fullfile(pnccdGUIPaths.img, 'scattering_simulations'), ...
            hFig.main);
        fprintf('\tSimulation started!\n')
    end % startSimulation
    function setNSimCores(~,~)
        hData.par.nSimCores = hFig.main_uicontrols.oneCore_tb.Value;
    end % setNSimCores
    %% Process and Save Data
    function saveDBFcn(~,~)
        dbCenter=db.center;
        dbSizing=db.sizing;
        dbShape=db.shape;
        dbRunInfo=db.runInfo;
       save(fullfile(thisPath,'\..\db\db.mat'),'db','-v7.3','-nocompression')
       save(fullfile(thisPath,'\..\db\db-center.mat'),'dbCenter','-v7.3','-nocompression')
       save(fullfile(thisPath,'\..\db\db-run-info.mat'),'dbRunInfo','-v7.3','-nocompression')
       save(fullfile(thisPath,'\..\db\db-shape.mat'),'dbShape','-v7.3','-nocompression')
       save(fullfile(thisPath,'\..\db\db-sizing.mat'),'dbSizing','-v7.3','-nocompression')
    end
    function saveImgFcn(~,~)
        exportgraphics(gca,getSaveName,const.printRes)
    end
    function fullpath = getSaveName
        hSave.folder=fullfile(pnccdGUIPaths.img,...
            sprintf('%s',datetime('now','Format','yyyy-MM-dd')),...
            sprintf('r03d-h03d-%s.%s'));
        if ~exist(hData.folder,'dir'),mkdir(hData.folder); end
        hSave.fileFormat='png';
        hSave.fileName=sprintf('r03d-h03d-%s.%s',run,hit,...
        datetime('now','Format','yyyy-MM-dd_hhmmss-SSS'),hSave.fileFormat);
        hSave.fullpath=fullfile(hSave.folder,hSave.fileName);
        fullpath=hSave.fullpath;
    end
    function reconANDsave(~,~)
        %         try d = load(fullfile(paths.db, 'db_recon.mat')); db_recon = d.db_recon; clear d;
        %         catch; fprintf('could not load db_recon\n'); end
        while true
            %             try
            if strcmp(db.runInfo(run).doping.dopant,'none')
                fprintf('run %i is not doped. Continuing...\n',run)
                loadNextFile([],[],pnccdGUIPaths.pnccd, run+1,1);
                continue
            end
            if hData.var.nPhotonsOnDetector<5e4 ...
                    || isnan(db.sizing(run).R(hit)) ...
                    || db.sizing(run).R(hit)*1e9<30
                loadNextHit([],[],1);
                continue
            end
            if run>=437 && hData.var.nPhotonsOnDetector<1e5
                loadNextHit([],[],1);
                continue
            end
            %             centerImgFcn;
            %             findShapeFcn;
            
            initIPR();
            hIPR.addReconPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
            hIPR.addReconPlan('nthio',hData.var.nSteps,hData.var.nLoops);
            hIPR.startRecon();
            print(figure(20000002),fullfile('C:\Users\Toli\Google Drive\dissertation\2.helium\xfel-img\2020-09-07',...
                sprintf('run%04d_hit%04d_dcdi.png',run,hit)),'-dpng')
            %         end
            loadNextHit([],[],1)
        end
    end % reconAndSave
%% Methods - NOT IN USE
%     function iterateIPR(method)
%         for i=1:hData.var.nLoops
%             if hFig.main.UserData.stopScript; hFig.main.UserData.stopScript = false; break; end
%             hIPR.iterate(hData.var.nSteps,method);
%             hIPR.plotAll;
%         end
% %         figure(hFig.main)
%     end
%     function finishRecon
%         hIPR.fig.rec.Pointer = 'watch'; drawnow;
%         hIPR.zeroBorders;
%         hIPR.fig.rec.Pointer = 'arrow'; drawnow;
%     end
%     function reconANDsave(~,~)
% %         %         try d = load(fullfile(paths.db, 'db_recon.mat')); db_recon = d.db_recon; clear d;
% %         %         catch; fprintf('could not load db_recon\n'); end
%         while true
% %             try
%                 if strcmp(db.runInfo(run).doping.dopant,'none')
%                     fprintf('run %i is not doped. Continuing...\n',run)
%                     loadNextFile([],[],pnccdGUIPaths.pnccd, run+1,1);
%                     continue
%                 end
%                 if hData.var.nPhotonsOnDetector<5e4 ...
%                         || isnan(db.sizing(run).R(hit)) ...
%                         || db.sizing(run).R(hit)*1e9<30
%                     loadNextHit([],[],1);
%                     continue
%                 end
%                 if run>=437 && hData.var.nPhotonsOnDetector<1e5
%                     loadNextHit([],[],1);
%                     continue
%                 end
%                 %             centerImgFcn;
%                 %             findShapeFcn;
%
%                 initIPR();
%                 hIPR.addReconPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
%                 hIPR.addReconPlan('nthio',hData.var.nSteps,hData.var.nLoops);
%                 hIPR.startRecon();
%                 print(figure(20000002),fullfile('C:\Users\Toli\Google Drive\dissertation\2.helium\xfel-img\2020-09-07',...
%                     sprintf('run%04d_hit%04d_dcdi.png',run,hit)),'-dpng')
% %             end
%             loadNextHit([],[],1)
%         end
%     end

%             %                 startDCDI
%             %                 startHIO
%             startHPR
%             %                 finishReconstruction
%
%             %%%% FIGURES %%%%
%             hSaveObj.fig = figure(601); hSaveObj.fig.Name = 'save figure #1'; clf(hSaveObj.fig);
%             hSaveObj.fig.PaperSize = [29.6774   20.9840].*[4/3,1];
%             hSaveObj.fig.PaperPosition = [0 0 hSaveObj.fig.PaperSize];
%             hSaveObj.uit = uitable(hSaveObj.fig, 'Units', 'normalized', 'Position', [0,.5,.25,.5], ...
%                 'FontSize', 10, 'ColumnWidth', {100,230}, 'RowName', [], ...
%                 'ColumnName', []);
%             hSaveObj.fig2 = figure(602); hSaveObj.fig2.Name = 'save figure #2'; clf(hSaveObj.fig2);
%             hSaveObj.fig2.PaperSize = [29.6774   20.9840];
%             hSaveObj.fig2.PaperPosition = [0,0,hSaveObj.fig2.PaperSize];
%             hSaveObj.ax2 = axes('parent', hSaveObj.fig2);
%
%             hIPR.ws = hIPR.ws .* hIPR.support;
%             hIPR.oneshot = hIPR.oneshot .* hIPR.support;
%             %                 hIPR.density = hIPR.density .* mode( real(hIPR.w(hIPR.support>0))./hIPR.density(hIPR.support>0) );
%
%             % scattering image
%             hSaveObj.ax(1) = mysubplot(2,4,2, 'parent', hSaveObj.fig);
%             hSaveObj.img(1) = imagesc(hIPR.plt.int(2).img.CData, ...
%                 'XData', hIPR.plt.int(2).img.XData, ...
%                 'YData', hIPR.plt.int(2).img.YData, ...
%                 'parent', hSaveObj.ax(1), [-2 ,3]);
%             colormap(hSaveObj.ax(1), imorgen);
%             hSaveObj.ax(1).YLabel.String = 'scattering angle';
%             hSaveObj.ax(1).Title.String = 'measured intensity';
%
%             % reconstructed intensity
%             hSaveObj.ax(2) = mysubplot(2,4,6, 'parent', hSaveObj.fig);
%             hSaveObj.img(2) = imagesc(hIPR.plt.int(1).img.CData, ...
%                 'XData', hIPR.plt.int(1).img.XData, ...
%                 'YData', hIPR.plt.int(1).img.YData, ...
%                 'parent', hSaveObj.ax(2), [-2,3]);
%             colormap(hSaveObj.ax(2), imorgen);
%             hSaveObj.ax(2).YLabel.String = 'scattering angle';
%             hSaveObj.ax(2).Title.String = 'reconstructed intensity';
%
%             % real part of reconstruction
%             hSaveObj.ax(3) = mysubplot(2,4,3, 'parent', hSaveObj.fig);
%             hSaveObj.img(3) = imagesc(real(hIPR.ws)-hIPR.density*hIPR.subscale, ...
%                 'XData', hIPR.plt.rec(2).img.XData, ...
%                 'YData', hIPR.plt.rec(2).img.YData, ...
%                 'parent', hSaveObj.ax(3));
%             colormap(hSaveObj.ax(3), b2r);
%             set(hSaveObj.ax(3), 'XLim', hIPR.ax.rec(2).XLim, 'YLim', hIPR.ax.rec(2).YLim,...
%                 'CLim', [-1,1]*max(abs(hSaveObj.img(3).CData(:))));
%             hSaveObj.ax(3).YLabel.String = 'nanometer';
%             hSaveObj.ax(3).Title.String = 'real part (shape substracted)';
%
%             % imag part of reconstruction
%             hSaveObj.ax(4) = mysubplot(2,4,7, 'parent', hSaveObj.fig);
%             hSaveObj.img(4) = imagesc(imag(hIPR.w), ...
%                 'XData', hIPR.plt.rec(2).img.XData, ...
%                 'YData', hIPR.plt.rec(2).img.YData, ...
%                 'parent', hSaveObj.ax(4));
%             colormap(hSaveObj.ax(4), igray);
%             set(hSaveObj.ax(4), 'XLim', hIPR.ax.rec(2).XLim, 'YLim', hIPR.ax.rec(2).YLim,...
%                 'CLim', [-1,1]*max(abs(hSaveObj.img(4).CData(:))));
%             hSaveObj.ax(4).YLabel.String = 'nanometer';
%             hSaveObj.ax(4).Title.String = 'imaginary part';
%
%             % real oneshot part of reconstruction
%             hSaveObj.ax(5) = mysubplot(2,4,4, 'parent', hSaveObj.fig);
%             %                 hSaveobj.img(5) = imagesc(imag(hIPR.ws), ...
%             hSaveObj.img(5) = imagesc(real(hIPR.oneshot) - hIPR.density*hIPR.subscale, ...
%                 'XData', hIPR.plt.rec(2).img.XData, ...
%                 'YData', hIPR.plt.rec(2).img.YData, ...
%                 'parent', hSaveObj.ax(5));
%             colormap(hSaveObj.ax(5), b2r);
%             set(hSaveObj.ax(5), 'XLim', hIPR.ax.rec(2).XLim, 'YLim', hIPR.ax.rec(2).YLim,...
%                 'CLim', [-1,1]*max(abs(hSaveObj.img(5).CData(:))));
%             hSaveObj.ax(5).YLabel.String = 'nanometer';
%             %                 hSaveobj.ax(5).Title.String = 'reconstructed imag part';
%             hSaveObj.ax(5).Title.String = 'oneshot - real part';
%
%
%             % imaginary oneshot of reconstruction
%             hSaveObj.ax(6) = mysubplot(2,4,8, 'parent', hSaveObj.fig);
%             %                 hSaveobj.img(6) = imagesc(angle(hIPR.ws), ...
%             hSaveObj.img(6) = imagesc(imag(hIPR.oneshot), ...
%                 'XData', hIPR.plt.rec(2).img.XData, ...
%                 'YData', hIPR.plt.rec(2).img.YData, ...
%                 'parent', hSaveObj.ax(6));
%             colormap(hSaveObj.ax(6), igray);
%             set(hSaveObj.ax(6), 'XLim', hIPR.ax.rec(2).XLim, 'YLim', hIPR.ax.rec(2).YLim,...
%                 'CLim', [-1,1]*max(abs(hSaveObj.img(6).CData(:))));
%             hSaveObj.ax(6).YLabel.String = 'nanometer';
%             %                 hSaveobj.ax(6).Title.String = 'reconstructed phase';
%             hSaveObj.ax(6).Title.String = 'oneshot - imaginary part';
%
%             % shape reconstruction
%             hSaveObj.ax(7) = mysubplot(2,4,5, 'parent', hSaveObj.fig);
%             hSaveObj.img(7) = imagesc(hAx.shape.Children(5).CData, ...
%                 'parent', hSaveObj.ax(7));
%             arrayfun(@(a) copyobj(hAx.shape.Children(a),hSaveObj.ax(7)), 1:4)
%             colormap(hSaveObj.ax(7), r2b);
%             set(hSaveObj.ax(7), 'XLim', [512-db.sizing(run).R(hit)*1e9/6*3, ...
%                 512+db.sizing(run).R(hit)*1e9/6*3],...
%                 'YLim', [512-db.sizing(run).R(hit)*1e9/6*3, ...
%                 512+db.sizing(run).R(hit)*1e9/6*3]);
%             hSaveObj.ax(7).YLabel.String = 'pixel';
%             hSaveObj.ax(7).Title.String = 'reconstructed shape';
%
%             % data table
%             hSaveObj.uit.Data = {'run #', run;...
%                 'train id', hData.trainId;...
%                 'hit', hit;...
%                 'T [K]', db.runInfo(run).source.T;...
%                 'p [bar]', db.runInfo(run).source.p;...
%                 'delay [ms]', db.runInfo(run).source.delayTime;...
%                 'R [nm]', db.sizing(run).R(hit)*1e9;...
%                 'a [nm]', hData.shape.a/2*6;...
%                 'b [nm]', hData.shape.b/2*6;...
%                 'rot [°]', mod(shape.rot,2*pi)/pi*180;...
%                 'center_x [px]', hData.var.center(2);...
%                 'center_y [px]', hData.var.center(1);...
%                 'photons #', round(hData.var.nPhotonsOnDetector);...
%                 'lit pixel #', hData.var.nLitPixel;...
%                 'dopant', db.runInfo(run).doping.dopant{:};...
%                 'depletion [%]', db.runInfo(run).doping.depletion;...
%                 'AR', db.shape(run).shape(hit).ar;...
%                 };
%             %                 hSaveobj.uit.Data = {'run #', sprintf('%03d',run);...
%             %                     'train id', sprintf('%d',pnccd.trainid(hit));...
%             %                     'hit', sprintf('%d',hit);...
%             %                     'T', sprintf('%.1f K', db.runInfo(run).source.T);...
%             %                     'p', sprintf('%.1f bar', db.runInfo(run).source.p);...
%             %                     'delay', sprintf('%.1f ms', db.runInfo(run).source.delayTime);...
%             %                     'R', sprintf('%.1f nm',db.sizing(run).R(hit)*1e9);...
%             %                     'a', sprintf('%.1f nm',shape.a/2*6);...
%             %                     'b', sprintf('%.1f nm',shape.b/2*6);...
%             %                     'rotation angle', sprintf('%.1f °',mod(shape.rot/pi*180,2*pi));...
%             %                     'center', sprintf('[%.1f, %.1f] px', center(1), center(2));...
%             %                     'photons #', sprintf('%.0f', hData.var.nPhotonsOnDetector);...
%             %                     'lit pixel #', sprintf('%.0f', hData.var.nLitPixel);...
%             %                     'dopant', sprintf('%s', db.runInfo(run).doping.dopant{:});...
%             %                     'depletion', sprintf('%d %%', db.runInfo(run).doping.depletion);...
%             %                     };
%
%             % saving
%             subpath = sprintf('%s%\\02.0fK_%02.0fbar', db.runInfo(run).doping.dopant{:},...
%                 round(db.runInfo(run).source.T),...
%                 round(db.runInfo(run).source.p));
%             savepath = fullfile(pnccdGUIPaths.img, 'reconstructions\png\',subpath);
%             if ~exist(savepath, 'dir'); mkdir(savepath); end
%             sname = sprintf('r%04d_id%d_hit%04d.png', run, hData.trainId, hit);
%             saveas(hSaveObj.fig, fullfile(savepath,sname));
%
%             hSaveObj.img2 = imagesc(hIPR.support.*abs(hIPR.oneshot-hIPR.density*~strcmp(db.runInfo(run).doping.dopant,'none')),...
%                 'XData', hIPR.plt.rec(2).img.XData, ...
%                 'YData', hIPR.plt.rec(2).img.YData, ...
%                 'parent', hSaveObj.ax2);
%             limrange = ceil(hIPR.ax.rec(2).XLim(2)/100)*100;
%             set(hSaveObj.ax2, 'XLim', limrange*[-1,1], 'YLim', limrange*[-1,1]);
%             colorbar(hSaveObj.ax2); colormap(hSaveObj.ax2, igray); drawnow;
%             savepath = fullfile('E:\XFEL2019_He\reconstructions\png_recon_igray\',subpath);
%             if ~exist(savepath, 'dir'); mkdir(savepath); end
%             sname = sprintf('r%04d_id%d_hit%04d_modulus.png', run, hData.trainId, hit);
%             saveas(hSaveObj.fig2, fullfile(savepath, sname))
%
%             colormap(hSaveObj.ax2, wjet); drawnow;
%             savepath = fullfile('E:\XFEL2019_He\reconstructions\png_recon_wjet\',subpath);
%             if ~exist(savepath, 'dir'); mkdir(savepath); end
%             sname = sprintf('r%04d_id%d_hit%04d_modulus.png', run, hData.trainId, hit);
%             saveas(hSaveObj.fig2, fullfile(savepath, sname))
%
%             hRecon(hit).recon = (hIPR.ws); %#ok<*AGROW>
%             hRecon(hit).W = (hIPR.W);
%             hRecon(hit).scatt = ( exp(1i*hIPR.PHASE) .* ( ( hIPR.INT .* (1-hIPR.MASK) ) + ( hIPR.SCATT.* hIPR.MASK ) ) );
%             hRecon(hit).droplet_shape = (hIPR.density);
%             hRecon(hit).oneshot = (hIPR.oneshot);
%             hRecon(hit).errorR = (hIPR.errReal);
%             hRecon(hit).errorF = (hIPR.errFourier);
%             hRecon(hit).parameter.run = run;
%             hRecon(hit).parameter.hit = hit;
%             hRecon(hit).parameter.T = db.runInfo(run).source.T;
%             hRecon(hit).parameter.p = db.runInfo(run).source.p;
%             hRecon(hit).parameter.delay =  db.runInfo(run).source.delayTime;
%             hRecon(hit).parameter.R_guinier = db.sizing(run).R(hit)*1e9;
%             hRecon(hit).parameter.a = hData.shape.a/2*6;
%             hRecon(hit).parameter.b = hData.shape.b/2*6;
%             hRecon(hit).parameter.rot = mod(shape.rot,2*pi);
%             hRecon(hit).parameter.center = hData.var.center;
%             hRecon(hit).parameter.photonsOnDetector = int32(hData.var.nPhotonsOnDetector);
%             hRecon(hit).parameter.litPixel = int32(hData.var.nLitPixel);
%             hRecon(hit).parameter.dopant = db.runInfo(run).doping.dopant{:};
%             hRecon(hit).parameter.depletion = db.runInfo(run).doping.depletion;
%             hRecon(hit).parameter.ar = db.shape(run).shape(hit).ar;
%             hRecon(hit).parameter.uit = hSaveObj.uit.Data;
%             loadNextHit(src,evt,1);
%         end
%     end
end % pnccdGUI