function pnccdGUI(paths, varargin)

fprintf('\n\n\n\n\nStarting pnCCD GUI _/^\\_/^\\_\n\t\t\t... please be patient ...\n\n\n\n\n')
%% Databases
db = loadDatabases(paths);
%% Figure creation & initifullfile(mfilename('fullpath'),'..')alization of grapical objects
hFig.main = findobj('Type','Figure','Name','pnccdGUI');
if isempty(hFig.main)
    hFig.main = figure;
end
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
hData.filepath = paths.pnccd;
pnccd = [];
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
hData.var.center = hData.par.nPixelFull/2+1;
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
hSave.folder = paths.img;
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
            case 'clims', hData.par.cLims = varargin{ni+1};
            case 'nsteps', hData.var.nSteps = varargin{ni+1};
            case 'nloops', hData.var.nLoops = varargin{ni+1};
        end
    end
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
                else, saveDBFcn;
                end
            case 'l',                   getFileFcn;
            case 'c'
                clc; src.Pointer = 'arrow'; drawnow;
            case {'1','numpad1'},       centerImgFcn;
            case {'2','numpad2'},       findShapeFcn
            case {'3','numpad3'},       initIPR
            case {'e'},       initIPRsim
            case {'4','numpad4'}
                hIPR.reconAddToPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
            case {'5','numpad5'}
                hIPR.reconAddToPlan('er',hData.var.nSteps,hData.var.nLoops);
            case {'6','numpad6'}
                hIPR.reconAddToPlan('mdcdi',hData.var.nSteps,hData.var.nLoops);
            case {'7','numpad7'}
                hIPR.reconAddToPlan('nthio',hData.var.nSteps,hData.var.nLoops);
            case {'8','numpad8'}
                hIPR.reconAddToPlan('ntdcdi',hData.var.nSteps,hData.var.nLoops);
            case {'9','numpad9'}       
            case {'return'},       hIPR.reconRunPlan;
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
        if db.runInfo(run).isData
            %             hData.filename = sprintf('%04i_hits.mat', run);
            %             hData.matObj = matfile(fullfile(paths.pnccd, hData.filename));
            %             load(fullfile(paths.pnccd, hData.filename), '-mat', 'pnccd');
            [pnccd, hData.filename, hData.var.nHits] = pnccd_load_run(run, paths.pnccd);
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
        if ~strcmp(paths.pnccd(end-2:end-1),'bg')
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
            nextFile = fullfile(paths.pnccd, sprintf('%04i_hits.mat', nextRun));
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
            [pnccd, hData.filename, hData.var.nHits] = pnccd_load_run(nextRun, paths.pnccd);
            run = pnccd.run;
            %             hRecon = load_recon(nextrun, paths.recon);
        end
        hit = iif(direction>0,1,numel(db.runInfo(run).nlit_smooth));
        loadImageData;
    end % loadNextFile
    function getFileFcn(src,evt)
        [fn, fp] = uigetfile(fullfile(paths.pnccd, hData.filename));
        if isequal(fn,0)
            disp('User selected Cancel')
        else
            paths.pnccd = fp;
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
            hFig.centering=findobj('Type','Figure','Tag','centerFigure');
            if isempty(hFig.centering)
                hFig.centering=figure('Tag','centerFigure');
            end
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
%         save(fullfile(paths.db, 'db.mat'), 'db');
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
            hFig.shape2 = findobj('Type','Figure','Name','shape figure #2');
            if isempty(hFig.shape2)
                hFig.shape2 = figure;
                hFig.shape2.Name = 'shape figure #2';
            end
        end
        if ~isgraphics(hAx.shape)
            hAx.shape=subplot(1,2,2,'parent',hFig.shape2); 
        end
        [hData.shape, hAx.shape] = findShapeFit(hData.img.dataCropped, hData.var.radiusInPixel, 'fig1', hFig.shape1, 'fig2', hFig.shape2, 'ax', hAx.shape);
        db.shape(run).shape(hit).data = hData.shape;
        db.shape(run).shape(hit).R = 6*(hData.shape.a/2 + hData.shape.b/2)/2;
        db.shape(run).shape(hit).ar = iif(hData.shape.a>hData.shape.b, hData.shape.a/hData.shape.b, hData.shape.b/hData.shape.a);
        [hData.img.dropletdensity, hData.img.support] = ellipsoid_density(hData.shape.a/2, hData.shape.b/2, (hData.shape.a/2+hData.shape.b/2)/2, hData.shape.rot, [513,513], [1024,1024]);
        hData.img.dropletOutline = ellipse_outline(hData.shape.a/2*6, hData.shape.b/2*6, hData.shape.rot);
        fprintf('ellipse parameters: \n[a, b, rot] = [%.2fpx, %.2fpx, %.2frad]\n', hData.shape.a/2,hData.shape.b/2,hData.shape.rot)
        fprintf('[a, b, rot] = [%.2fnm, %.2fnm, %.2fdegree]\n', hData.shape.a/2*6,hData.shape.b/2*6,hData.shape.rot/2/pi*360)
        %         hData.img.support = imopen(hData.img.support,strel('disk',2,0));
        %         hData.img.support =
        %         imdilate(hData.img.support,strel('square',2));
        %         hData.img.support = imerode(hData.img.support,strel('disk',1,0));
        %         hData.img.support = imopen(hData.img.support,strel('disk',4,0));
        figure(4949494); clf
%         hAxSupport=subplot(1,2,1); imagesc(hData.img.support); title('reconstruction support');
%         hAxDensity=subplot(1,2,2);
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
        hFig.main.Pointer = 'arrow';
        hIPR.figureArray.Pointer = 'arrow'; drawnow;
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
        simData=centerAndCropFcn(simData,[513,513]);
        hIPR = IPR(simData, ...%             'objectHandle', hIPR, ...
            'support0', hSimu.simData.droplet>0, ...
            'support_radius', (hSimu.simParameter.aDrop+hSimu.simParameter.bDrop)/2/6, ...
            'dropletOutline', hSimu.simParameter.ellipse, ...
            'rho0', hSimu.simData.droplet,...
            'parentfig', hFig.main);
        hFig.main.Pointer = 'arrow';
        hIPR.figureArray.Pointer = 'arrow'; drawnow;
    end % initIPRsim
    function addDCDI(~,~)
        hIPR.reconAddToPLan('dcdi',hData.var.nSteps,hData.var.nLoops);
    end % addDCDI
    function addHIO(~,~)
        hIPR.reconAddToPLan('nthio',hData.var.nSteps,hData.var.nLoops);
    end % addHIO
    function runRecon(~,~)
        hIPR.reconRunPlan();
    end % runRecon
    %% Simulation Functions
    function startSimulation(~,~)
        fprintf('Starting simulation ...\n')
        hData.bool.simulationMode = true;
        hSimu = simulatePatternApp(hData.img.dataCropped, ...
            ~isnan(hData.img.dataCropped), ...
            hData.par, ...
            fullfile(paths.img, 'scattering_simulations'), ...
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
       save(fullfile(paths.db,'\db.mat'),'db','-v7.3')
       save(fullfile(paths.db,' \db-center.mat'),'dbCenter','-v7.3')
       save(fullfile(paths.db, '\db-run-info.mat'),'dbRunInfo','-v7.3')
       save(fullfile(paths.db, '\db-shape.mat'),'dbShape','-v7.3')
       save(fullfile(paths.db, '\db-sizing.mat'),'dbSizing','-v7.3')
    end
    function saveImgFcn(~,~)
        exportgraphics(gca,getSaveName,const.printRes)
    end
    function fullpath = getSaveName
        hSave.folder=fullfile(paths.img,...
            sprintf('%s',datetime('now','Format','yyyy-MM-dd')),...
            sprintf('r%03d-h%03d',run,hit));
        if ~exist(hData.folder,'dir'),mkdir(hData.folder); end
        hSave.fileFormat='png';
        hSave.fileName=sprintf('r%03d-h%03d-%s.%s',run,hit,...
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
                loadNextFile([],[],paths.pnccd, run+1,1);
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
            hIPR.reconAddToPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
            hIPR.reconAddToPlan('nthio',hData.var.nSteps,hData.var.nLoops);
            hIPR.reconRunPlan();
            print(figure(20000002),fullfile('C:\Users\Toli\Google Drive\dissertation\2.helium\xfel-img\2020-09-07',...
                sprintf('run%04d_hit%04d_dcdi.png',run,hit)),'-dpng')
            %         end
            loadNextHit([],[],1)
        end
    end % reconAndSave
end % pnccdGUI
