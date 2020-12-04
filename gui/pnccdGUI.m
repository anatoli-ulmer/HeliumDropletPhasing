function handles = pnccdGUI(paths, varargin)

fprintf('\n\n\n\n\nStarting pnCCD GUI _/^\\_/^\\_\n\t\t\t... please be patient ...\n\n\n\n\n')

%% Databases

db = loadDatabases(paths);

%% Figure creation & initialization of grapical objects

h.main.figure = findobj('Type','Figure','Name','ASR - main Window');
if isgraphics(h.main.figure)
    clf(h.main.figure);
else
    h.main.figure = figure;
end

h.main.axes = gobjects(1,2);
h.main.image = gobjects(1);
h.main.colorbar = gobjects(1);
h.main.plot.pnccdRings = gobjects(1);
h.main.plot.nLitPixel = gobjects(1,3);
h.main.plot.nPhotons = gobjects(1,3);

h.centering.figure = gobjects(1);
h.centering.axes = gobjects(1,4);
h.centering.plot = gobjects(1,3);

h.shape(1).figure = gobjects(1);
h.shape(2).figure = gobjects(1);
h.shape(1).axes = gobjects(1,4);
h.shape(2).axes = gobjects(1,3);

%% Declarations

run = 450;
hit = 68;
pnccd = [];

hData.trainId = nan;
hData.filepath = paths.pnccd;
hData.shape = [];
hData.filename = '';

hData.par.nPixelFull = [1100,1050];
hData.par.nPixel = [1024, 1024];
hData.par.datatype = 'single';
hData.par.cLims = [0.1, 100];
hData.par.cMap = ihesperia;
hData.par.nRings = 10;
hData.par.ringwidth = .5;
hData.par.nSimCores = 1;
hData.par.centeringMinRadius = 70;
hData.par.centeringWindowSize = 300;
hData.par.litPixelThreshold = 4e3;
hData.par.nPhotonsThreshold = 4e4;
hData.par.radiusThresholdInNm = 20;

% Hard coded custom Gaps and Shifts for different shifts for testing geometry
% consistency:
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

handles.run = run;
handles.hit = hit;
handles.pnccd = pnccd;
handles.paths = paths;
handles.db = db;
handles.h = h;
% handles.hAx = hAx;
% handles.h.image = h.image;
% handles.h.plot = h.plot;
handles.hData = hData;
handles.hPrevData = hPrevData;
handles.hSave = hSave;
handles.hRecon = hRecon;
handles.hIPR = hIPR;
handles.hSimu = hSimu;

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

initFcn();

%% Methods
    
    %% Key and Button Callbacks
    
    function thisKeyPressFcn(src,evt)
        src.Pointer = 'watch'; drawnow;
        switch evt.Key
            case 'alt', h.main.figure.UserData.isRegisteredAlt = true;
            case 'control', h.main.figure.UserData.isRegisteredControl = true;
            case 'shift', h.main.figure.UserData.isRegisteredShift = true;
            case 'escape', h.main.figure.UserData.isRegisteredEscape = true;
        end
    end % thisKeyPressFcn

    function thisKeyReleaseFcn(src,evt)
        switch evt.Key
            case 'escape',              h.main.figure.UserData.stopScript = true;
            case 'leftarrow',           loadNextHit(src,evt,-1);
            case 'rightarrow',          loadNextHit(src,evt,1);
            case 's'
                if h.main.figure.UserData.isRegisteredShift, startSimulation;
                elseif h.main.figure.UserData.isRegisteredControl, saveImgFcn;
                else, saveDataBaseFcn;
                end
            case 'l',                   getFileFcn;
            case 'c'
                fprintf('\n\n\n\n\n\n\n\n\n\n'); src.Pointer = 'arrow'; drawnow;
            case {'1','numpad1'}
                if h.main.figure.UserData.isRegisteredShift
                    centerImgFcn([],[],5,0.25);
                else
                    centerImgFcn();
                end
            case {'2','numpad2'},       findShapeFcn();
            case {'w'},                 startSimulation();
            case {'3','numpad3'},       initIPR();
            case {'e'},                 initIPRsim();
            case {'4','numpad4'},       addToPlanER();
            case {'5','numpad5'},       addToPlanDCDI();
            case {'6','numpad6'},       addToPlanNTDCDI();
            case {'7','numpad7'},       addToPlanNTHIO();
            case {'8','numpad8'},       addToPlanHIO();
            case {'9','numpad9'},       addToPlanRAAR();       
            case {'return'},            runRecon();
            case {'0','numpad0'},       resetRecon();
            case 't'
                centerImgFcn([],[],3);
                findShapeFcn();
                initIPR();
                addToPlanDCDI();
                runRecon();
            case 'y'
                centerImgFcn([],[],3);
                findShapeFcn();
                initIPR();
                addToPlanNTDCDI();
                runRecon();
            case 'k',                   reconANDsave();
            case 'j'
                %% automated phasing code testing by usage of simulated data
                alphaScanArray = (0.9:0.01:1.09);
                deltaFactorScanArray = (0:1:19);
                
                for photonsOnDetector = [1e5,1e6,1e7]
                    hSimu.editObjArray(12).String = photonsOnDetector;
                    hSimu.startSimulation();
                    drawnow;
                    reset(gpuDevice)
                   
                    % DCDI
                    initIPRsim;
                    addToPlanDCDI;
                    hIPR.scanParameter('alpha', alphaScanArray, ...
                        fullfile(hSave.folder, 'scans', ...
                        sprintf('%.2e',photonsOnDetector) ));
                    initIPRsim;
                    addToPlanDCDI;
                    hIPR.scanParameter('deltaFactor', deltaFactorScanArray, ...
                        fullfile(hSave.folder, 'scans',...
                        sprintf('%.2e',photonsOnDetector) ));
                    initIPRsim;
                    
                    % NTDCDI
                    addToPlanNTDCDI;
                    hIPR.scanParameter('alpha', alphaScanArray, ...
                        fullfile(hSave.folder, 'scans',...
                        sprintf('%.2e',photonsOnDetector) ));
                    initIPRsim;
                    addToPlanNTDCDI;
                    hIPR.scanParameter('deltaFactor', deltaFactorScanArray, ...
                        fullfile(hSave.folder, 'scans',...
                        sprintf('%.2e',photonsOnDetector) ));
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 'f12'
                hIPR.scanParameter('alpha', (0.8:0.025:1.175), ...
                    fullfile(hSave.folder, 'scans'));
            case 'f11'
                hIPR.scanParameter('deltaFactor', (0:2:20), ...
                    fullfile(hSave.folder, 'scans'));
        end
        unregisterKeys(h.main.figure);
        src.Pointer = 'arrow'; drawnow;
        h.main.figure.UserData.registeredKey = '';
    end % thisKeyReleaseFcn
    
    function unregisterKeys(src)
        src.UserData.isRegisteredAlt = false;
        src.UserData.isRegisteredControl = false;
        src.UserData.isRegisteredShift = false;
        src.UserData.isRegisteredEscape = false;
    end % unregisterKeys
    
    function thisWindowButtonDownFcn(src,~)
        if strcmp(src.SelectionType, 'open')
            if src.CurrentAxes==h.main.axes(2)
                hit = round(src.CurrentAxes.CurrentPoint(2));
                h.ui.indexText.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
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
        createGUI();
        h.ui.CMinEdit.String = num2str(hData.par.cLims(1));
        h.ui.CMaxEdit.String = num2str(hData.par.cLims(2));
        h.ui.indexText.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
        h.ui.nRingsEdit.String = sprintf('%i', hData.par.nRings);
        h.ui.ringWidthEdit.String = sprintf('%.2g', hData.par.ringwidth);
        h.ui.nStepsEdit.String = sprintf('%i', hData.var.nSteps);
        h.ui.nLoopsEdit.String = sprintf('%i', hData.var.nLoops);
        
        loadImageData();
        createPlots();
    end % initFcn
    
    function thisCloseRequestFcn(~,~)
        questAnswer = questdlg('Do you want to save the current databases before closing?',...
            'Save db files?', 'Yes', 'No', 'No');
        if strcmp(questAnswer,'Yes')
            saveDataBaseFcn();
        end
        try
            close(hIPR.go.figure);
        catch
        end
        try
            close(hSimu.figObj);
        catch
        end
            delete(h.main.figure);
        fprintf('bye bye\n')
    end % thisCloseRequestFcn

    function createGUI(~,~)
        h.main.figure.Visible = 'off';
        h.main.figure.Name = 'ASR - main Window';
        h.main.figure.Tag = 'asrMainWindow';
        %%% for performance reasons:
        h.main.figure.GraphicsSmoothing=false;
        %%%
        h.main.figure.NumberTitle='off';
        h.main.figure.KeyPressFcn = @thisKeyPressFcn;
        h.main.figure.KeyReleaseFcn = @thisKeyReleaseFcn;
        h.main.figure.WindowButtonDownFcn = @thisWindowButtonDownFcn;
        h.main.figure.CloseRequestFcn = @thisCloseRequestFcn;
        h.main.figure.UserData.dragging = false;
        h.main.figure.UserData.stopScript = false;
        h.main.figure.UserData.isRegisteredAlt = false;
        h.main.figure.UserData.isRegisteredControl = false;
        h.main.figure.UserData.isRegisteredShift = false;
        h.main.figure.UserData.isRegisteredEscape = false;
        h.main.figure.UserData.isValidSimulation = false;
        
        h.main.axes(1) = axes('OuterPosition', [.0 .0 .55 .95]);
        h.main.axes(1).Tag = 'pnccd';
        h.main.axes(2) = axes('OuterPosition', [.5 .01 .5 .45]);
        h.main.axes(2).Tag = 'nLitPixel';
        
        h.ui.CMinEdit = uicontrol(h.main.figure, 'Style', 'edit', 'String', '0.1',...
            'Units', 'normalized', 'Position', [.445 .02 .045 .045], 'Callback', @manualCLimChange);
        h.ui.CMaxEdit = uicontrol(h.main.figure, 'Style', 'edit', 'String', '60',...
            'Units', 'normalized', 'Position', [.445 .92 .045 .045], 'Callback', @manualCLimChange);
        
        h.ui.logScaleCheckbox = uicontrol(h.main.figure, 'Style', 'checkbox', 'String', 'log10', 'Value', true,...
            'Units', 'normalized', 'Position', [.53 .75 .07 .04], 'Callback', @scaleChangeFcn,...
            'Backgroundcolor', h.main.figure.Color);
        h.ui.autoScaleCheckbox = uicontrol(h.main.figure, 'Style', 'checkbox', 'String', 'autoScale', 'Value', false,...
            'Units', 'normalized', 'Position', [.53 .8 .1 .04], 'Callback', @scaleChangeFcn,...
            'Backgroundcolor', h.main.figure.Color);
        h.ui.ringCheckbox = uicontrol(h.main.figure, 'Style', 'checkbox', 'String', 'plot rings', 'Value', false,...
            'Units', 'normalized', 'Position', [.53 .7 .1 .04], 'Callback', @ringCbxCallback,...
            'Backgroundcolor', h.main.figure.Color);
        
        h.ui.prevButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '<', 'FontWeight', 'bold', ...
            'Units', 'normalized', 'Position', [.6 .9 .05 .05], 'Callback', @loadNextHit);
        h.ui.nextButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '>', 'FontWeight', 'bold', ...
            'Units', 'normalized', 'Position', [.7 .9 .05 .05], 'Callback', @loadNextHit);
        h.ui.indexText = uicontrol(h.main.figure, 'Style', 'text', 'String', '1',...
            'Units', 'normalized', 'Position', [.65 .89 .05 .05],...
            'Backgroundcolor', h.main.figure.Color);
        
        h.ui.fileButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(l) load run',...
            'Units', 'normalized', 'Position', [.8 .9 .075 .05], 'Callback', @getFileFcn);
        h.ui.saveImgButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', 'save image',...
            'Units', 'normalized', 'Position', [.9 .9 .075 .05], 'Callback', @saveImgFcn);
        
        h.ui.nRingsEdit = uicontrol(h.main.figure, 'Style', 'edit', 'String', '15',...
            'Units', 'normalized', 'Position', [.53 .65 .03 .04], 'Callback', @plotRings);
        h.ui.nRingsText = uicontrol(h.main.figure, 'Style', 'text', 'String', '# rings',...
            'Units', 'normalized', 'Position', [.57 .65 .06 .04],...
            'Backgroundcolor', h.main.figure.Color);
        h.ui.ringWidthEdit = uicontrol(h.main.figure, 'Style', 'edit', 'String', '1',...
            'Units', 'normalized', 'Position', [.53 .6 .03 .04], 'Callback', @plotRings);
        h.ui.ringWidthText = uicontrol(h.main.figure, 'Style', 'text', 'String', 'ring width',...
            'Units', 'normalized', 'Position', [.57 .6 .06 .04],...
            'Backgroundcolor', h.main.figure.Color);
        h.ui.cMapEdit = uicontrol(h.main.figure, 'Style', 'edit', 'String', 'ihesperia',...
            'Units', 'normalized', 'Position', [.53 .49 .06 .04],...
            'Backgroundcolor', h.main.figure.Color, 'Callback', @setCMap);
        h.ui.cMapText = uicontrol(h.main.figure, 'Style', 'text', 'String', 'colormap',...
            'Units', 'normalized', 'Position', [.53 .53 .06 .04],...
            'Backgroundcolor', h.main.figure.Color);
        
        h.ui.findCenterButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(1) find center',...
            'Units', 'normalized', 'Position', [.65 .8 .1 .05], 'Callback', @centerImgFcn);
        h.ui.findShapeButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(2) find shape',...
            'Units', 'normalized', 'Position', [.77 .8 .1 .05], 'Callback', @findShapeFcn);
        h.ui.startSimulationButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(w) start simulation',...
            'Units', 'normalized', 'Position', [.77 .74 .10 .05], 'Callback', @startSimulation);
        h.ui.initIPRButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(3) init IPR data',...
            'Units', 'normalized', 'Position', [.65 .68 .1 .05], 'Callback', @initIPR);
        h.ui.initIPRsimButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(e) init IPR sim',...
            'Units', 'normalized', 'Position', [.77 .68 .1 .05], 'Callback', @initIPRsim);
        h.ui.addERButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(4) add ER',...
            'Units', 'normalized', 'Position', [.65 .57 .1 .05], 'Callback', @addToPlanER);
        h.ui.addDCDIButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(5) add DCDI',...
            'Units', 'normalized', 'Position', [.77 .57 .1 .05], 'Callback', @addToPlanDCDI );
        h.ui.addNTDCDIButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(6) add ntDCDI',...
            'Units', 'normalized', 'Position', [.65 .51 .1 .05], 'Callback', @addToPlanNTDCDI );
        h.ui.addNTHIOButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(7) add ntHIO',...
            'Units', 'normalized', 'Position', [.77 .51 .1 .05], 'Callback', @addToPlanNTHIO);
        h.ui.resetReconButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(0) reset IPR',...
            'Units', 'normalized', 'Position', [.65 .45 .1 .05], 'Callback', @resetRecon );
        h.ui.runReconButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(enter) start plan',...
            'Units', 'normalized', 'Position', [.77 .45 .1 .05], 'Callback', @runRecon );
        
        h.ui.nStepsEdit = uicontrol(h.main.figure, 'Style', 'edit',...
            'Units', 'normalized', 'Position', [.89 .57 .035 .04], 'String', '100',...
            'Callback', @setNSteps);
        h.ui.nLoopsEdit = uicontrol(h.main.figure, 'Style', 'edit',...
            'Units', 'normalized', 'Position', [.89 .51 .035 .04], 'String', '1',...
            'Callback', @setNLoops);
        h.ui.nStepsText = uicontrol(h.main.figure, 'Style', 'text',...
            'Units', 'normalized', 'Position', [.93 .57 .035 .03], 'String', 'steps',...
            'Backgroundcolor', h.main.figure.Color);
        h.ui.nLoopsText = uicontrol(h.main.figure, 'Style', 'text',...
            'Units', 'normalized', 'Position', [.93 .51 .035 .03], 'String', 'loops',...
            'Backgroundcolor', h.main.figure.Color);
        
        h.ui.nCoresButtonGroup = uicontrol(h.main.figure, 'Style', 'text', ...
            'Units', 'normalized', 'Position', [.87 .69 .04 .03], 'String', 'with',...
            'BackgroundColor', h.main.figure.Color);
        h.ui.nCoresButtonGroup = uibuttongroup(h.main.figure,...
            'Position',[.91 .67 .07 .07],'SelectionChangedFcn',@setNSimCores);
        h.ui.oneCoreToggleButton = uicontrol(h.ui.nCoresButtonGroup,...
            'Style','radiobutton','Units','normalized','Position',[0,.5,1,.5],'String','1 Core','Callback',@setNSimCores);
        h.ui.twoCoresToggleButton = uicontrol(h.ui.nCoresButtonGroup,...
            'Style','radiobutton','Units','normalized','Position',[0,0,1,.5],'String','2 Cores');
        
       handles = h;
    end % createGUI
    
    function createPlots(~,~)
        
        %% PNCCD Axes
        cla(h.main.axes(1));
        h.main.image(1) = imagesc(nan(hData.par.nPixelFull), ...
            'parent', h.main.axes(1));
        axis(h.main.axes(1), 'image');
        
        h.main.axes(1).Title.String = sprintf('run #%03i train id %i', ...
            run, hData.trainId);
        h.main.axes(1).CLimMode = 'manual';
        h.main.axes(1).CLim = iif(hData.bool.autoScale, ...
            [nanmin(hData.img.data(:)),nanmax(hData.img.data(:))], ...
            logS(hData.par.cLims));
        colormap(h.main.axes(1), hData.par.cMap);
        drawnow;
        h.main.colorbar(1) = colorbar(h.main.axes(1));
        h.main.axes(1).UserData.origXLim = h.main.axes(1).XLim;
        h.main.axes(1).UserData.origYLim = h.main.axes(1).YLim;
        plotRings();
        
        %% Lit Pixel Axes
        cla(h.main.axes(2)); 
        hold(h.main.axes(2), 'off');
        
        h.main.plot.nLitPixel(1) = stem(h.main.axes(2), ...
            db.runInfo(run).nlit_smooth, 'LineWidth', 1);
        
        hold(h.main.axes(2), 'on');
        grid(h.main.axes(2), 'on');
        
        h.main.plot.nPhotons(1) = stem(h.main.axes(2), ...
            db.data(run).nPhotons, ...
            '--', 'LineWidth', 1, 'Color', colorOrder(5));
        
        h.main.plot.nLitPixel(2) = stem(h.main.axes(2), ...
            hit, hData.var.nLitPixel, ...
            'r', 'LineWidth', 1);
        
        h.main.plot.nPhotons(2) = stem(h.main.axes(2), hit, ...
            db.data(run).nPhotons(hit), 'r--', 'LineWidth', 1);

        h.main.axes(2).YScale = 'log';
        h.main.axes(2).XLim = [.75, numel(db.runInfo(run).nlit_smooth)+.25];
        h.main.axes(2).Title.String = 'lit pixel over hit index';
        h.main.axes(2).UserData.origXLim = h.main.axes(2).XLim;
        h.main.axes(2).UserData.origYLim = h.main.axes(2).YLim;
        
        h.main.plot.nLitPixel(3) = plot(h.main.axes(2), h.main.axes(2).XLim, ...
            [1,1] * hData.par.litPixelThreshold, ':', 'Color', colorOrder(1));
        h.main.plot.nPhotons(3) = plot(h.main.axes(2), h.main.axes(2).XLim, ...
            [1,1] * hData.par.nPhotonsThreshold, ':', 'Color', colorOrder(5));
        
        legend(h.main.axes(2), {'# lit pixel', '# photons'});
        
        %% Update plots
        updatePlotsFcn();
        
    end % createPlots

    %% Plot Functions

    function updatePlotsFcn(~,~)
        
        h.main.axes(2).Legend.Location = 'northoutside';
        h.main.axes(2).Legend.NumColumns = 6;
        h.main.axes(2).Legend.String = {'# lit pixel', '# photons'};
        
        updateImgData();
        h.main.image(1).CData = hData.img.data;
        h.main.image(1).XData = size(hData.img.data,2) * [-.5, .5] - [0,1];
        h.main.image(1).YData = size(hData.img.data,1) * [-.5, .5] - [0,1];
        h.main.axes(1).CLim = iif(hData.bool.autoScale, ...
            [nanmin(h.main.image(1).CData(:)), nanmax(h.main.image(1).CData(:))], ...
            hData.par.cLims);
        h.main.axes(1).ColorScale = iif(hData.bool.logScale, 'log', 'linear');

        h.main.axes(2).XLim = [.5, numel(db.runInfo(run).nlit_smooth)+.5];
        
        h.main.plot.nLitPixel(1).XData = (1:numel(db.runInfo(run).nlit_smooth)) - 0.2;
        h.main.plot.nLitPixel(1).YData = db.runInfo(run).nlit_smooth;
        h.main.plot.nLitPixel(2).XData = hit - 0.2;
        h.main.plot.nLitPixel(2).YData = hData.var.nLitPixel;
        h.main.plot.nLitPixel(3).XData = h.main.axes(2).XLim;
        h.main.plot.nLitPixel(3).YData = [1,1] * hData.par.litPixelThreshold;
        
        h.main.plot.nPhotons(1).XData = h.main.plot.nLitPixel(1).XData + 0.2*2;
        h.main.plot.nPhotons(1).YData = db.data(run).nPhotons;
        h.main.plot.nPhotons(2).XData = hit + 0.2;
        h.main.plot.nPhotons(2).YData = db.data(run).nPhotons(hit);
        h.main.plot.nPhotons(3).XData = h.main.axes(2).XLim;
        h.main.plot.nPhotons(3).YData = [1,1] * hData.par.nPhotonsThreshold;

        h.main.axes(1).Title.String = sprintf(...
            'run #%03i - id %i - hit %i, R = %.0fnm', ...
            run, hData.trainId, hit , db.sizing(run).R(hit)*1e9);
        h.main.axes(2).Title.String = sprintf(...
            '%.3g lit pixel // %.3g photons', ...
            hData.var.nLitPixel, hData.var.nPhotonsOnDetector);
        plotRings();
        
        h.main.figure.Visible = 'on';
        h.main.figure.Pointer = 'arrow';
        drawnow limitrate;
    end % updatePlotsFcn
    
    function plotRings(~,~)
        if hData.bool.drawRings
            hData.par.nRings = str2num_fast(...
                h.ui.nRingsEdit.String);
            hData.par.ringwidth = str2num_fast(...
                h.ui.ringWidthEdit.String);
%             if isgraphics(h.main.plot.pnccdRings)
%                 delete(h.main.plot.pnccdRings)
%             end
            h.main.plot.pnccdRings = draw_rings(h.main.axes(1), [0,0], hData.par.nRings, ...
                hData.minimaPositionsInPixel, hData.par.ringwidth, ...
                [1 1 1]*.5, '--', h.main.plot.pnccdRings);
        end
    end % plotRings
    
    function setCMap(~,~)
        hData.par.cMap = h.ui.cMapEdit.String;
        colormap(h.main.axes(1), hData.par.cMap);
    end % setCMap
    
    function manualCLimChange(~,~)
        hData.par.cLims = [str2num_fast(h.ui.CMinEdit.String), str2num_fast(h.ui.CMaxEdit.String)];
        updatePlotsFcn;
    end % manualCLimChange
    
    function scaleChangeFcn(~,~)
        hData.bool.autoScale = h.ui.autoScaleCheckbox.Value;
        hData.bool.logScale = h.ui.logScaleCheckbox.Value;
        updatePlotsFcn;
    end % scaleChangeFcn
    
    function val = logS(val)
        if hData.bool.logScale
            val(val<=0) = nan;
            val = log10(val);
        end
    end % logS
    
    function setNSteps(~,~)
        hData.var.nSteps = str2num_fast(h.ui.nStepsEdit.String);
    end % setNSteps
    
    function setNLoops(~,~)
        hData.var.nLoops = str2num_fast(h.ui.nLoopsEdit.String);
    end % setNLoops
    
    function ringCbxCallback(~,~)
        hData.bool.drawRings = h.ui.ringCheckbox.Value;
        if hData.bool.drawRings
            plotRings;
            h.main.plot.pnccdRings.Visible = 'on';
        elseif isgraphics(h.main.plot.pnccdRings)
            h.main.plot.pnccdRings.Visible = 'off';
        end
    end % ringCbxCallback

    %% Load Data Functions

    function loadImageData(~,~)
        fprintf('\tLoading run #%03d hit %01d ...\n', run, hit)
        
        % Reset data & parameter
        hData.bool.simulationMode = false;
        hData.bool.isCropped=false;
        hData.shape = [];
        hData.var.center = [547, 513];

        % Get data from databases
        hData.img.input = pnccd.data(hit).image;
        hData.trainId = pnccd.trainid(hit);
        
        % Check if run was background subtracted (folder name ends with "ButtonGroup").
        % Do Subtraction if not. TO DO: introduce another criterium or do
        % subtraction beforehand in all cases!
        if ~strcmp(paths.pnccd(end-2:end-1),'bg')
            hData.img.input = hData.img.input - pnccd.bg_corr;
        end
        
        % Old correction needs to be made
        if ~db.sizing(run).ok(hit); db.sizing(run).R(hit) = nan; end
        hData.var.radiusInNm = db.sizing(run).R(hit);
        hData.var.radiusInPixel = db.sizing(run).R(hit)*1e9/6;
        hData.var.nLitPixel = db.runInfo(run).nlit_smooth(hit);        
        
        % Custom masking
        hData.img.input(hData.img.mask==0) = nan;
        hData.img.mask = ~isnan(hData.img.input);
%         hData.par.addCenter = -1*[1,1];
%         hData.par.addGapArray = [0 0 -2 -3 -1 1];
%         hData.par.addShiftArray = [0 0 -2 1 0 -1];
        hData.par.addCenter = [0,0];
        hData.par.addGapArray = [0,0,0,0,0,0];
        hData.par.addShiftArray = [0,0,0,0,0,0];
        hData.par.addGap = hData.par.addGapArray(db.runInfo(run).shift);
        hData.par.addShift = hData.par.addShiftArray(db.runInfo(run).shift);
        hData.var.nPhotonsOnDetector = nansum(hData.img.input(hData.img.input>0));
        
        % Automatic correction of relative geometry (gap size and left/right
        % shift) from calculated values based on the motor encoder values of
        % the pnCCDs, and manual calibration for some images.
        [hData.img.dataCorrected,hData.var.gapSize,hData.var.shiftSize,~,...
            hData.var.center]=pnccdGeometryFcn(hData.img.input,db.runInfo,...
            pnccd.run,hData.par.nPixelFull,hData.par.addGap,hData.par.addShift);
       
        
%         if hit <= numel(db.center(run).center)
%             if ~isempty(db.center(run).center(hit).data)
%                 hData.var.center = db.center(run).center(hit).data...
%                     + hData.par.addCenter;
%                 hData.img.dataCropped = centerAndCropFcn(...
%                     hData.img.dataCorrected, hData.var.center);
%                 hData.bool.isCropped=true;
%                 fprintf('\t\t...centered\t...cropped\n');
%             end
%         end
%         
%         if hit <= numel(db.shape(run).shape)
%             if ~isempty(db.shape(run).shape(hit).data)
%                 hData.shape = db.shape(run).shape(hit).data;
%                 [hData.img.dropletdensity, hData.img.support] = ...
%                     ellipsoid_density(hData.shape.a/2,hData.shape.b/2,...
%                     (hData.shape.a/2+hData.shape.b/2)/2,hData.shape.rot,...
%                     [513,513], [1024,1024]);
%                 hData.img.dropletOutline = ellipse_outline(...
%                     hData.shape.a/2*6, hData.shape.b/2*6, -hData.shape.rot);
%                 fprintf('\t\t...shape found\t...got support & density\n')
%                 %% BEGIN: DETECTOR GEOMETRY CORRECTION
%                 %                     dataScatt = hData.img.dataCorrected;
%                 %                     simScatt = abs(ft2(hData.img.dropletdensity)).^2;
%                 %                     refineDetectorGeometry(dataScatt, simScatt)
%                 %% END: DETECTOR GEOMETRY CORRECTION
%             end
%         end
%         db.center(run).center(hit).data = hData.var.center;
%         db.shape(run).shape(hit).data = hData.shape;

        db.center(run).center(hit).data = nan(1,2);
        db.shape(run).shape(hit).data = [];
        db.data(run).nPhotons(hit) = hData.var.nPhotonsOnDetector;
        
        updateImgData();
    end % loadImageData
    
    function updateImgData(~,~)
        calcMinimaPixelPos();
        if hData.bool.simulationMode, hData.img.data=hData.img.dataSimulated;
        elseif hData.bool.isCropped, hData.img.data=hData.img.dataCropped;
        else, hData.img.data=hData.img.dataCorrected;
        end
    end % updateImgData
    
    function loadNextHit(src,evt,direction)
        if nargin<3
            switch src.String
                case 60, direction = -1;
                case 62, direction = 1;
                otherwise
                    error('Error in pnccdGUI/loadNextHit: direction not defined and caller function is not the "+" or "-" button callback.')
            end
        end
        if hit+direction<1 || hit+direction>numel(pnccd.trainid)
            loadNextFile(src,evt,hData.filepath, run+direction, direction);
        else
            hit = hit+direction;
            h.ui.indexText.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
            loadImageData();
        end
        updatePlotsFcn();
    end % loadNextHit
    
    function loadNextFile(~,~,filepath,nextRun,direction)
%         fprintf('\tSaving DB file ...\n')
%         saveDataBaseFcn();
        %         fprintf('saving recon file ...'); drawnow;
        %         save(fullfile(paths.recon, sprintf('r%04d_recon_%s.mat', run, db.runInfo(run).doping.dopant{:})), 'hRecon', '-v7.3');
        %         fprintf('done!\n'); drawnow;
        if ~exist('direction','var')
            direction = 1;
        end
        
        nextFile = fullfile(filepath, sprintf('%04i_hits.mat', nextRun));
        if nextRun < 209 || nextRun > 489
            fprintf('Aborting loading next file. Only runs between 209 & 489 exist')
            return;
        end
        while ~db.runInfo(nextRun).isData || ~exist(nextFile, 'file')
            warning(['Run #%03d is not a data run and was not loaded.\n',...
                'Trying next: run #%03d\n'], nextRun, nextRun+direction);
            nextRun = nextRun + direction;
            nextFile = fullfile(paths.pnccd, sprintf('%04i_hits.mat', nextRun));
            if nextRun>489 || nextRun<209; return; end
        end
        fprintf('Loading next file: %s\n', nextFile)
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
            clear pnccd;
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
            h.main.axes(1).Title.String = sprintf('Loading run #%s ...', fn(1:4)); drawnow;
            nextrun = str2num_fast(fn(1:4));
            loadNextFile(src, evt, fp, nextrun);
            updatePlotsFcn();
        end
    end % getFileFcn
    
    %% Centering und Shape Determination
    
    function centerImgFcn(~,~,nIterations,shiftStrength)
        if nargin < 4
            shiftStrength = 1;
        end
        if nargin < 3
            nIterations = 1;
        end
        h.main.figure.Pointer = 'watch'; drawnow;
        fprintf('\tCalculating center ...\n')
        
        if ~isgraphics(h.centering.figure)    
            h.centering.figure = getFigure(h.centering.figure, 'NumberTitle', 'off', ...
                'Name', 'centering figure');
            clf(h.centering.figure);
        
            h.centering.axes(1) = subplot(3,3,[1:2,4:5,7:8]);
            h.centering.image(1) = imagesc(h.centering.axes(1), nan);
            hold(h.centering.axes(1), 'on')
            
            h.centering.axes(2) = mysubplot(3,3,3);
            h.centering.image(2) = imagesc(h.centering.axes(2), nan);
            hold(h.centering.axes(2), 'on')
            
            h.centering.axes(3) = mysubplot(3,3,6);
            h.centering.image(3) = imagesc(h.centering.axes(3), nan);
            hold(h.centering.axes(3), 'on')
            
            h.centering.axes(4) = mysubplot(3,3,9);
            h.centering.image(4) = imagesc(h.centering.axes(4), nan);
            hold(h.centering.axes(4), 'on')
            
            h.centering.plot(1) = plot(h.centering.axes(1), nan, nan, 'g+', ...
                'LineWidth', .5, 'MarkerSize', 50);
            h.centering.plot(2) = plot(h.centering.axes(3), nan, nan, 'g+', ...
                'LineWidth', .5, 'MarkerSize', 50);
            h.centering.plot(3) = gobjects(1);
        end
                    
        for i = 1:nIterations
            if any( (hData.var.center-size(hData.img.dataCorrected)/2) > 20)
                hData.var.center=size(hData.img.dataCorrected)/2+1;
            end
            
            smoothedImage = imgaussfilt(hData.img.dataCorrected, 1);
            
            hData.par.centeringWindowSize = 300;
            imgSize = size(smoothedImage);
            [xx,yy] = meshgrid( 1:imgSize(2), 1:imgSize(1) );
            smoothedImage( ( (xx - hData.var.center(2)).^2 + ...
                (yy - hData.var.center(1)).^2 ) ...
                < hData.par.centeringMinRadius^2 ) = nan;
            
            [hData.var.center, h.centering] = findCenterXcorr(...
                h.centering, ...
                smoothedImage, ...
                hData.var.center, ...
                hData.par.centeringWindowSize, ...
                hData.minimaPositionsInPixel, ...
                shiftStrength);
%             figure(h.main.figure)
            
            db.center(run).center(hit).data = hData.var.center;
            h.main.figure.Pointer = 'arrow'; drawnow;
            hData.img.dataCropped = centerAndCropFcn(...
                hData.img.dataCorrected, hData.var.center);
            hData.bool.isCropped=true;
            updateImgData();
        end
        updatePlotsFcn();
        
        fprintf('\t\t-> centered\n')
    end % centerImgFcn

    function calcMinimaPixelPos()
        % calculate minima positions from radius (in SI units)
        qMinima = nan(1,hData.par.nRings);
%         qMinima(1) = 1.43*pi/hData.var.radiusInNm;
        qMinima(1) = 1.43*pi/hData.var.radiusInNm;
        wavelength = 1.2398e-9;
        for iMinimum=2:hData.par.nRings
            qMinima(iMinimum) = qMinima(iMinimum-1) + 3.24/hData.var.radiusInNm;
        end
        thetaMinima = 2*asin(qMinima*wavelength/4/pi);
        hData.minimaPositionsInPixel = tan(thetaMinima)*370e-3/75e-6;
    end % calcMinimaPixelPos
    
    function centeringWindowButtonUpFcn(~,evt)
        h.main.figure.Pointer = 'watch'; drawnow;
        deltaC = 1;
        if h.main.figure.UserData.isRegisteredShift
            deltaC = 10;
        end
        switch evt.Key
            case 'uparrow'
                hData.var.center(1)=hData.var.center(1)+deltaC;
            case 'downarrow'
                hData.var.center(1)=hData.var.center(1)-deltaC;
            case 'leftarrow'
                hData.var.center(2)=hData.var.center(2)-deltaC;
            case 'rightarrow'
                hData.var.center(2)=hData.var.center(2)+deltaC;
        end
        db.center(run).center(hit).data = hData.var.center;
%         try delete(h.centering.plot.black); end %#ok<TRYNC>
%         h.centering.plot.black = draw_rings(h.centering.axes, ...
%             (hData.var.center), 0, hData.minimaPositionsInPixel, ...
%             hData.par.ringwidth, [.3 .3 .3]);
        h.main.figure.Pointer = 'arrow'; drawnow;
    end % centeringWindowButtonUpFcn
    
    function findShapeFcn(~,~)
        h.main.figure.Pointer = 'watch'; drawnow;
        fprintf('\tEstimating shape ...\n')
        
        h.shape(1).figure = getFigure(h.shape(1).figure, ...
            'NumberTitle', 'off', 'Name', 'shape figure #1');
        h.shape(2).figure = getFigure(h.shape(2).figure, ...
            'NumberTitle', 'off', 'Name', 'shape figure #2');
        if ~isgraphics(h.shape(1).axes(1))
            h.shape(1).axes(1)=subplot(1,4,1,'Parent',h.shape(1).figure);
            imagesc(h.shape(1).axes(1), nan(1));
            h.shape(1).axes(2)=subplot(1,4,2,'Parent',h.shape(1).figure);
            imagesc(h.shape(1).axes(2), nan(1));
            h.shape(1).axes(3)=subplot(1,4,3,'Parent',h.shape(1).figure);
            imagesc(h.shape(1).axes(3), nan(1));
            h.shape(1).axes(4)=subplot(1,4,4,'Parent',h.shape(1).figure);
            imagesc(h.shape(1).axes(4), nan(1));
        end
        if ~isgraphics(h.shape(2).axes(1))
            h.shape(2).axes(1)=mysubplot(1,3,1,'Parent',h.shape(2).figure);
            h.shape(2).axes(2)=mysubplot(1,3,2,'Parent',h.shape(2).figure);
            h.shape(2).axes(3)=mysubplot(1,3,3,'Parent',h.shape(2).figure);
            
            h.shape(2).image(1) =  imagesc(h.shape(2).axes(1), 1);
            h.shape(2).image(2) =  imagesc(h.shape(2).axes(2), 1);
            h.shape(2).image(3) =  imagesc(h.shape(2).axes(3), 1);
            title(h.shape(2).axes(3), 'calculated droplet density');
            title(h.shape(2).axes(3), 'calculated droplet density');
            hold(h.shape(2).axes(3), 'on');
            h.shape(2).plot(3) = plot(h.shape(2).axes(3), nan, nan, 'r--');
            
            drawnow; % necessary before creating colorbars
            colorbar(h.shape(2).axes(1),'Location','southoutside');
            colorbar(h.shape(2).axes(2),'Location','southoutside');
            colorbar(h.shape(2).axes(3),'Location','southoutside');
            colormap(h.shape(2).axes(1),r2b);
            colormap(h.shape(2).axes(2),r2b);
            colormap(h.shape(2).axes(3),'igray');
        end
        
        % SHAPE FIT
%         hData.var.radiusInPixel = hData.var.radiusInPixel*2;
%         hData.var.radiusInPixel = hData.var.radiusInPixel/2;
        hData.var.radiusInPixel = db.sizing(run).R(hit)*1e9/6;
        [hData.shape, hData.goodnessOfFit, h.shape(2).axes] = findShapeFit(...
            hData.img.dataCropped, hData.var.radiusInPixel, ...
            'hAxesFig1', h.shape(1).axes, 'hAxesFig2', h.shape(2).axes,...
            'fittingPart', 'real');
        
        db.shape(run).shape(hit).data = hData.shape;
        db.shape(run).shape(hit).R = 6*(hData.shape.a/2 + hData.shape.b/2)/2;
        db.shape(run).shape(hit).ar = iif(hData.shape.a>hData.shape.b, ...
            hData.shape.a/hData.shape.b, hData.shape.b/hData.shape.a);
        hData.var.radiusInNm = db.shape(run).shape(hit).R*1e-9;
%         db.sizing(run).R(hit) = hData.var.radiusInNm;
        calcMinimaPixelPos();
        
        % DROPLET DENSITY FROM SHAPE FIT
        [hData.img.dropletdensity, hData.img.support] = ellipsoid_density(...
            hData.shape.a/2, hData.shape.b/2, ...
            (hData.shape.a/2+hData.shape.b/2)/2, ...
            hData.shape.rot, [513,513], [1024,1024]);
        
        % DROPLET OUTLINE FROM SHAPE FIT
        hData.img.dropletOutline = ellipse_outline(...
            hData.shape.a/2*6, hData.shape.b/2*6, -hData.shape.rot);
        
        fprintf('\t\tellipse parameters: \n')
        fprintf('\t\t\t[a, b, rot] = [%.2fpx, %.2fpx, %.2frad]\n', ...
            hData.shape.a/2,hData.shape.b/2,hData.shape.rot)
        fprintf('\t\t\t[a, b, rot] = [%.2fnm, %.2fnm, %.2fdegree]\n', ...
            hData.shape.a/2*6,hData.shape.b/2*6,hData.shape.rot/2/pi*360)
        fprintf('\t\t-> shape found\n')
        
        % PLOTTING
        xData=6*( size(hData.img.dropletdensity,2)*[-0.5,0.5]-[0,1]);
        yData=6*( size(hData.img.dropletdensity,1)*[-0.5,0.5]-[0,1]);
        xyLims=db.shape(run).shape(hit).R*1.5*[-1,1];
        
        h.shape(2).image(3).XData = xData;
        h.shape(2).image(3).YData = yData;
        h.shape(2).image(3).CData = hData.img.dropletdensity;
        h.shape(2).plot(3).XData = hData.img.dropletOutline.x;
        h.shape(2).plot(3).YData = hData.img.dropletOutline.y;
        set(h.shape(2).axes(3), 'XLim', xyLims, 'YLim', xyLims);
        
        figure(h.main.figure)
        h.main.figure.Pointer = 'arrow'; drawnow;
        updatePlotsFcn;
    end % findShapeFcn
    
    %% Reconstruction Functions
    
    function initIPR(~,~)
        h.main.figure.Pointer = 'watch'; drawnow limitrate;
        graphicsObj = [];
        if exist('hIPR', 'var')
            if ~isempty(hIPR)
                if any(find(strcmp(fieldnames(hIPR), 'go')))
                    graphicsObj = hIPR.go;
                end
            end
        end
        
        clear hIPR;
        
        hIPR = IPR(hData.img.dataCropped, ...
            'go', graphicsObj, ...
            'support0', hData.img.support, ...
            'support_radius', db.sizing(run).R(hit)*1e9/6, ...
            'dropletOutline', hData.img.dropletOutline, ...    
            'rho0', hData.img.dropletdensity,...
            'parentfig', h.main.figure);
        h.main.figure.Pointer = 'arrow';
        hIPR.go.figure(1).Pointer = 'arrow'; drawnow;
        %         figure(h.main.figure)
    end % initIPR
    
    function initIPRsim(~,~)
        if ~h.main.figure.UserData.isValidSimulation
            dialogAnswer = questdlg('No valid simulation window found. Would you like to start a simulation?', ...
                'No simulation window detected.', ...
                'Yes','Cancel','Yes');
            % Handle response
            switch dialogAnswer
                case 'Yes'
                    startSimulation();
                case 'Cancel'
                    return;
            end
        end
        h.main.figure.Pointer = 'watch'; drawnow limitrate;
        if isempty(hData)
            error(['No simulation data available. ',...
                'Please start a simulation first.'])
        end
        clear hIPR;
        if hData.par.nSimCores
            simScene=hSimu.simData.scene1;
            simScatt=hSimu.simData.scatt1;
        else
            simScene=hSimu.simData.scene2;
            simScatt=hSimu.simData.scatt2;
        end
        simScatt=centerAndCropFcn(simScatt,[513,513]);
        hIPR = IPR(simScatt, ...%             'objectHandle', hIPR, ...
            'support0', hSimu.simData.droplet>0, ...
            'support_radius', (hSimu.simParameter.aDrop+hSimu.simParameter.bDrop)/2/6, ...
            'dropletOutline', hSimu.simParameter.ellipse, ...
            'rho0', hSimu.simData.droplet,...
            'parentfig', h.main.figure,...
            'simScene', simScene);
        h.main.figure.Pointer = 'arrow';
        hIPR.go.figure(1).Pointer = 'arrow'; drawnow;
    end % initIPRsim
    
    function addToPlanER(~,~)
        hIPR.reconAddToPlan('er',hData.var.nSteps,hData.var.nLoops);
    end % addToPlanER
    
    function addToPlanDCDI(~,~)
        hIPR.reconAddToPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
    end % addToPlanDCDI
    
    function addToPlanNTDCDI(~,~)
        hIPR.reconAddToPlan('ntdcdi',hData.var.nSteps,hData.var.nLoops);
    end % addToPlanNTDCDI
    
    function addToPlanNTHIO(~,~)
        hIPR.reconAddToPlan('nthio',hData.var.nSteps,hData.var.nLoops);
    end % addToPlanNTHIO
    
    function addToPlanRAAR(~,~)
        hIPR.reconAddToPlan('raar',hData.var.nSteps,hData.var.nLoops);
    end % addToPlanRAAR
    
    function addToPlanHIO(~,~)
        hIPR.reconAddToPlan('hio',hData.var.nSteps,hData.var.nLoops);
    end % addToPlanHIO
    
    function resetRecon(~,~)
        hIPR.resetIPR();
    end % resetRecon
    
    function runRecon(~,~)
        hIPR.reconRunPlan();
        h.main.figure.Pointer = 'arrow';
        hIPR.go.figure(1).Pointer = 'arrow'; drawnow;
    end % runRecon
    
    %% Simulation Functions
    
    function startSimulation(~,~)
        fprintf('Starting simulation ...\n')
        hData.bool.simulationMode = true;
        hSimu = simulatePatternApp(hData.img.dataCropped, ...
            ~isnan(hData.img.dataCropped), ...
            hData.par, ...
            fullfile(paths.img, 'scattering_simulations'), ...
            h.main.figure);
        fprintf('\tSimulation started!\n')
        drawnow;
    end % startSimulation
    
    function setNSimCores(~,~)
        hData.par.nSimCores = h.ui.oneCoreToggleButton.Value;
    end % setNSimCores
    
    %% Process and Save Data
    
    function saveDataBaseFcn(~,~)
        saveName = fullfile(paths.db,'db.mat');
        fprintf('Saving database in %s\n ... ', saveName)
%         db_center=db.center;
%         db_sizing=db.sizing;
%         db_shape=db.shape;
%         db_run_info=db.runInfo;
       save(saveName,'db','-v7.3')
%        save(fullfile(paths.db, 'db_center.mat'),'db_center','-v7.3')
%        save(fullfile(paths.db, 'db_run_info.mat'),'db_run_info','-v7.3')
%        save(fullfile(paths.db, 'db_shape.mat'),'db_shape','-v7.3')
%        save(fullfile(paths.db, 'db_sizing.mat'),'db_sizing','-v7.3')
        fprintf('done!\n')
    end % saveDataBaseFcn

    function saveImgFcn(~,~,saveName,axesToSave,printRes)
        if nargin<5
            printRes = const.printRes;
        end
        if nargin<4
            axesToSave=gca;
        elseif isempty(axesToSave)
            axesToSave=gca;
        end
        if nargin<3
            saveName = getSaveName;
        elseif isempty(saveName)
            saveName = getSaveName;
        end
        fprintf('Saving current axes to %s\n\t... ', saveName)
        exportgraphics(axesToSave,saveName,'Resolution',printRes)
        fprintf('done!\n')
    end % saveImgFcn

    function fullpath = getSaveName()
        hSave.folder=fullfile(paths.img,...
            sprintf('%s',datetime('now','Format','yyyy-MM-dd')),...
            sprintf('r%03d',run));
        if ~exist(hSave.folder,'dir'),mkdir(hSave.folder); end
        hSave.fileFormat='png';
        hSave.fileName=sprintf('r%03d.%03d___%s.%s',run,hit,...
            datetime('now','Format','yyyy.MM.dd-hh.mm.ss'),hSave.fileFormat);
        hSave.fullpath=fullfile(hSave.folder,hSave.fileName);
        fullpath=hSave.fullpath;
    end % getSaveName

    function reconANDsave(~,~)
        
        hData.par.litPixelThreshold = 4e3;
        hData.par.nPhotonsThreshold = 4e4;
        hData.par.radiusThresholdInNm = 20;
        
        %         try d = load(fullfile(paths.db, 'db_recon.mat')); db_recon = d.db_recon; clear d;
        %         catch; fprintf('could not load db_recon\n'); end
        
        while true
            if h.main.figure.UserData.isRegisteredEscape
                fprintf('Loop aborted by user.\n')
                break;
            end
            %             try
%             if strcmp(db.runInfo(run).doping.dopant,'none')
%                 fprintf('run %i is not doped. Continuing...\n',run)
%                 loadNextFile([],[],paths.pnccd, run+1,1);
%                 continue
%             end
            if ( db.runInfo(run).nlit_smooth(hit) < hData.par.litPixelThreshold ...
                    || db.data(run).nPhotons(hit) < hData.par.nPhotonsThreshold ...
                    || isnan(db.sizing(run).R(hit)) ...
                    || db.sizing(run).R(hit)*1e9<hData.par.radiusThresholdInNm )
                loadNextHit([],[],1);
                continue
            end
            if run>=437 && db.runInfo(run).nlit_smooth(hit)<1e4
                loadNextHit([],[],1);
                continue
            end

            db.shape(run).shape(hit).a = nan;
            db.shape(run).shape(hit).b = nan;
            db.shape(run).shape(hit).rot = nan;
            db.shape(run).shape(hit).R = nan;
            db.shape(run).shape(hit).aspectRatio = nan;
            
            centerImgFcn([],[],5,.5);
            findShapeFcn();
            getSaveName();
            
            exportgraphics(h.centering.axes(1), fullfile(hSave.folder, ...
                ['center-', hSave.fileName]), 'Resolution', 100);
            exportgraphics(h.shape(2).figure,  fullfile(hSave.folder, ...
                ['shape-', hSave.fileName]), 'Resolution', 100);
            
% % %             if strcmp(db.runInfo(run).doping.dopant,'none')
% % %                 fprintf('run %i is not doped. Continuing without phasing ...\n',run)
% % %                 loadNextHit([],[],1);
% % % %                 loadNextFile([],[],paths.pnccd, run+1,1);
% % %                 continue
% % %             end
% % %             initIPR();
% % %             hIPR.reconAddToPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
% % %             hIPR.reconRunPlan();
% % %             exportgraphics(hIPR.go.figure(1),  fullfile(hSave.folder, ...
% % %                 ['recon-', hSave.fileName]))

            loadNextHit([],[],1)
        end
    end % reconAndSave

end % pnccdGUI
