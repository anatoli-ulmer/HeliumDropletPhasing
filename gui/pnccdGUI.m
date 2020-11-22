function handles = pnccdGUI(paths, varargin)

fprintf('\n\n\n\n\nStarting pnCCD GUI _/^\\_/^\\_\n\t\t\t... please be patient ...\n\n\n\n\n')

%% Databases

db = loadDatabases(paths);

%% Figure creation & initialization of grapical objects

hFig.main = findobj('Type','Figure','Name','ASR - main Window');
if isgraphics(hFig.main)
    clf(hFig.main);
else
    hFig.main = figure;
end

hFig.centering = gobjects(1);
hFig.shape1 = gobjects(1);
hFig.shape2 = gobjects(1);
hFig.simu = gobjects(1);
hFig.simupol = gobjects(1);

% hTL.shape1 = gobjects(1);
% hTL.shape2 = gobjects(1);

hAx.pnccd = gobjects(1);
hAx.pnccd_CBar = gobjects(1);
hAx.lit = gobjects(1);
hAx.centering = gobjects(1);
hAx.shape1 = gobjects(4);
hAx.shape2 = gobjects(3);

hPlt.pnccd = gobjects(1);
hPlt.lit = gobjects(1);
hPlt.lit_current = gobjects(1);
hPlt.rings = gobjects(1);
hPlt.centering = gobjects(1);

hImg = [];

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
hData.par.nRings = 15;
hData.par.ringwidth = 1;
hData.par.nSimCores = 1;

% Hard coded custom Gaps and Shifts for different shifts if for testing geometry
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
handles.hFig = hFig;
handles.hAx = hAx;
handles.hImg = hImg;
handles.hPlt = hPlt;
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
            case 'alt', hFig.main.UserData.isRegisteredAlt = true;
            case 'control', hFig.main.UserData.isRegisteredControl = true;
            case 'shift', hFig.main.UserData.isRegisteredShift = true;
            case 'escape', hFig.main.UserData.isRegisteredEscape = true;
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
                fprintf('\n\n\n\n\n\n\n\n\n\n'); src.Pointer = 'arrow'; drawnow;
            case {'1','numpad1'},       centerImgFcn;
            case {'2','numpad2'},       findShapeFcn;
            case {'w'},                 startSimulation;
            case {'3','numpad3'},       initIPR;
            case {'e'},                 initIPRsim;
            case {'4','numpad4'},       addToPlanER;
            case {'5','numpad5'},       addToPlanDCDI;
            case {'6','numpad6'},       addToPlanNTDCDI;
            case {'7','numpad7'},       addToPlanNTHIO;
            case {'8','numpad8'},       addToPlanHIO;
            case {'9','numpad9'},       addToPlanRAAR;       
            case {'return'},            runRecon;
            case {'0','numpad0'},       resetRecon;
            case 't'
                centerImgFcn;
                findShapeFcn;
                initIPR;
                addToPlanDCDI;
                runRecon;
            case 'k',                   reconANDsave;
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
        unregisterKeys(hFig.main);
        src.Pointer = 'arrow'; drawnow;
        hFig.main.UserData.registeredKey = '';
    end % thisKeyReleaseFcn
    
    function unregisterKeys(src)
        src.UserData.isRegisteredAlt = false;
        src.UserData.isRegisteredControl = false;
        src.UserData.isRegisteredShift = false;
        src.UserData.isRegisteredEscape = false;
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
        hFig.main.Name = 'ASR - main Window';
        hFig.main.Tag = 'asrMainWindow';
        % for performance reasons:
        hFig.main.GraphicsSmoothing=false;
        hFig.main.NumberTitle='off';
        hFig.main.KeyPressFcn = @thisKeyPressFcn;
        hFig.main.KeyReleaseFcn = @thisKeyReleaseFcn;
        hFig.main.WindowButtonDownFcn = @thisWindowButtonDownFcn;
        hFig.main.CloseRequestFcn = @thisCloseRequestFcn;
        hFig.main.UserData.dragging = false;
        hFig.main.UserData.stopScript = false;
        hFig.main.UserData.isRegisteredAlt = false;
        hFig.main.UserData.isRegisteredControl = false;
        hFig.main.UserData.isRegisteredShift = false;
        hFig.main.UserData.isRegisteredEscape = false;
        hFig.main.UserData.isValidSimulation = false;
        
        hAx.pnccd = axes('OuterPosition', [.0 .0 .55 .95]);
        hAx.pnccd.Tag = 'pnccd';
        hAx.lit = axes('OuterPosition', [.525 .025 .5 .35]);
        hAx.lit.Tag = 'lit';
        
        hFig.main_uicontrols.CMin_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', '0.1',...
            'Units', 'normalized', 'Position', [.445 .02 .045 .045], 'Callback', @manualCLimChange);
        hFig.main_uicontrols.CMax_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', '60',...
            'Units', 'normalized', 'Position', [.445 .92 .045 .045], 'Callback', @manualCLimChange);
        
        hFig.main_uicontrols.logScale_cbx = uicontrol(hFig.main, 'Style', 'checkbox', 'String', 'log10', 'Value', true,...
            'Units', 'normalized', 'Position', [.53 .75 .07 .04], 'Callback', @scaleChangeFcn,...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.autoScale_cbx = uicontrol(hFig.main, 'Style', 'checkbox', 'String', 'autoScale', 'Value', false,...
            'Units', 'normalized', 'Position', [.53 .8 .1 .04], 'Callback', @scaleChangeFcn,...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.ring_cbx = uicontrol(hFig.main, 'Style', 'checkbox', 'String', 'plot rings', 'Value', false,...
            'Units', 'normalized', 'Position', [.53 .7 .1 .04], 'Callback', @ringCbxCallback,...
            'Backgroundcolor', hFig.main.Color);
        
        hFig.main_uicontrols.prev_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '<', 'FontWeight', 'bold', ...
            'Units', 'normalized', 'Position', [.6 .9 .05 .05], 'Callback', @loadNextHit);
        hFig.main_uicontrols.next_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '>', 'FontWeight', 'bold', ...
            'Units', 'normalized', 'Position', [.7 .9 .05 .05], 'Callback', @loadNextHit);
        hFig.main_uicontrols.index_txt = uicontrol(hFig.main, 'Style', 'text', 'String', '1',...
            'Units', 'normalized', 'Position', [.65 .89 .05 .05],...
            'Backgroundcolor', hFig.main.Color);
        
        hFig.main_uicontrols.file_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(l) load run',...
            'Units', 'normalized', 'Position', [.8 .9 .075 .05], 'Callback', @getFileFcn);
        hFig.main_uicontrols.saveImg_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', 'save image',...
            'Units', 'normalized', 'Position', [.9 .9 .075 .05], 'Callback', @saveImgFcn);
        
        hFig.main_uicontrols.nRings_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', '15',...
            'Units', 'normalized', 'Position', [.53 .65 .03 .04], 'Callback', @plotRings);
        hFig.main_uicontrols.nRings_txt = uicontrol(hFig.main, 'Style', 'text', 'String', '# rings',...
            'Units', 'normalized', 'Position', [.57 .65 .06 .04],...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.ringWidth_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', '1',...
            'Units', 'normalized', 'Position', [.53 .6 .03 .04], 'Callback', @plotRings);
        hFig.main_uicontrols.ringWidth_txt = uicontrol(hFig.main, 'Style', 'text', 'String', 'ring width',...
            'Units', 'normalized', 'Position', [.57 .6 .06 .04],...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.cMap_edt = uicontrol(hFig.main, 'Style', 'edit', 'String', 'ihesperia',...
            'Units', 'normalized', 'Position', [.53 .49 .06 .04],...
            'Backgroundcolor', hFig.main.Color, 'Callback', @setCMap);
        hFig.main_uicontrols.cMap_txt = uicontrol(hFig.main, 'Style', 'text', 'String', 'colormap',...
            'Units', 'normalized', 'Position', [.53 .53 .06 .04],...
            'Backgroundcolor', hFig.main.Color);
        
        hFig.main_uicontrols.findCenter_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(1) find center',...
            'Units', 'normalized', 'Position', [.65 .8 .1 .05], 'Callback', @centerImgFcn);
        hFig.main_uicontrols.findShape_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(2) find shape',...
            'Units', 'normalized', 'Position', [.77 .8 .1 .05], 'Callback', @findShapeFcn);
        hFig.main_uicontrols.startSimulation_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(w) start simulation',...
            'Units', 'normalized', 'Position', [.77 .74 .10 .05], 'Callback', @startSimulation);
        hFig.main_uicontrols.initIPR_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(3) init IPR data',...
            'Units', 'normalized', 'Position', [.65 .68 .1 .05], 'Callback', @initIPR);
        hFig.main_uicontrols.initIPRsim_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(e) init IPR sim',...
            'Units', 'normalized', 'Position', [.77 .68 .1 .05], 'Callback', @initIPRsim);
        hFig.main_uicontrols.addER_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(4) add ER',...
            'Units', 'normalized', 'Position', [.65 .57 .1 .05], 'Callback', @addToPlanER);
        hFig.main_uicontrols.addDCDI_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(5) add DCDI',...
            'Units', 'normalized', 'Position', [.77 .57 .1 .05], 'Callback', @addToPlanDCDI );
        hFig.main_uicontrols.addNTDCDI_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(6) add ntDCDI',...
            'Units', 'normalized', 'Position', [.65 .51 .1 .05], 'Callback', @addToPlanNTDCDI );
        hFig.main_uicontrols.addNTHIO_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(7) add ntHIO',...
            'Units', 'normalized', 'Position', [.77 .51 .1 .05], 'Callback', @addToPlanNTHIO);
        hFig.main_uicontrols.resetRecon_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(0) reset IPR',...
            'Units', 'normalized', 'Position', [.65 .45 .1 .05], 'Callback', @resetRecon );
        hFig.main_uicontrols.runRecon_btn = uicontrol(hFig.main, 'Style', 'pushbutton', 'String', '(enter) start plan',...
            'Units', 'normalized', 'Position', [.77 .45 .1 .05], 'Callback', @runRecon );
        
        hFig.main_uicontrols.nSteps_edt = uicontrol(hFig.main, 'Style', 'edit',...
            'Units', 'normalized', 'Position', [.89 .57 .035 .04], 'String', '100',...
            'Callback', @setNSteps);
        hFig.main_uicontrols.nLoops_edt = uicontrol(hFig.main, 'Style', 'edit',...
            'Units', 'normalized', 'Position', [.89 .51 .035 .04], 'String', '1',...
            'Callback', @setNLoops);
        hFig.main_uicontrols.nSteps_txt = uicontrol(hFig.main, 'Style', 'text',...
            'Units', 'normalized', 'Position', [.93 .57 .035 .03], 'String', 'steps',...
            'Backgroundcolor', hFig.main.Color);
        hFig.main_uicontrols.nLoops_txt = uicontrol(hFig.main, 'Style', 'text',...
            'Units', 'normalized', 'Position', [.93 .51 .035 .03], 'String', 'loops',...
            'Backgroundcolor', hFig.main.Color);
        
        hFig.main_uicontrols.nCores_bg = uicontrol(hFig.main, 'Style', 'text', ...
            'Units', 'normalized', 'Position', [.87 .69 .04 .03], 'String', 'with',...
            'BackgroundColor', hFig.main.Color);
        hFig.main_uicontrols.nCores_bg=uibuttongroup(hFig.main,...
            'Position',[.91 .67 .07 .07],'SelectionChangedFcn',@setNSimCores);
        hFig.main_uicontrols.oneCore_tb=uicontrol(hFig.main_uicontrols.nCores_bg,...
            'Style','radiobutton','Units','normalized','Position',[0,.5,1,.5],'String','1 Core','Callback',@setNSimCores);
        hFig.main_uicontrols.twoCores_tb=uicontrol(hFig.main_uicontrols.nCores_bg,...
            'Style','radiobutton','Units','normalized','Position',[0,0,1,.5],'String','2 Cores');
        
       handles = hFig;
    end % createGUI
    
    function createPlots(~,~)
        cla(hAx.pnccd);
        hPlt.pnccd = imagesc(nan(hData.par.nPixelFull), 'parent', hAx.pnccd);
        axis(hAx.pnccd, 'image');
        
        hAx.pnccd.Title.String = sprintf('run #%03i train id %i', run, hData.trainId);
        hAx.pnccd.CLimMode = 'manual';
        hAx.pnccd.CLim = iif(hData.bool.autoScale, ([nanmin(hData.img.data(:)),nanmax(hData.img.data(:))]), logS(hData.par.cLims));
        colormap(hAx.pnccd, hData.par.cMap);
        drawnow;
        hAx.pnccd_CBar = colorbar(hAx.pnccd);
        plotRings();
        
        cla(hAx.lit); 
        hold(hAx.lit, 'off');
        hPlt.lit = stem(hAx.lit, db.runInfo(run).nlit_smooth, 'LineWidth', 1);
        hold(hAx.lit, 'on'); 
        grid(hAx.lit, 'on');
        hPlt.lit_current = stem(hAx.lit, hit, hData.var.nLitPixel, 'r', ...
            'LineWidth', 1);
%         hPlt.photons = stem(hAx.lit, db.data(run).nPhotons, '--', ...
%             'LineWidth', 1);
%         hPlt.nPhotons_current = stem(hAx.lit, hit, ...
%             db.data(run).nPhotons(hit), 'r--', 'LineWidth', 1);

        hAx.lit.XLim = [.75, numel(db.runInfo(run).nlit_smooth)+.25];
        hAx.lit.Title.String = 'lit pixel over hit index';
        hAx.pnccd.UserData = [hAx.pnccd.XLim; hAx.pnccd.YLim];
        hAx.lit.UserData = [hAx.lit.XLim; hAx.lit.YLim];
        updatePlotsFcn;
    end % createPlots
    
    function thisCloseRequestFcn(~,~)
        questAnswer = questdlg('Do you want to save the current databases before closing?',...
            'Save db files?', 'Yes', 'No', 'No');
        if strcmp(questAnswer,'Yes')
            saveDBFcn();
        end
        try
            close(hIPR.figureArray);
        catch
        end
        try
            close(hSimu.figObj);
        catch
        end
        delete(hFig.main);
    end % thisCloseRequestFcn

    %% Plot Functions

    function updatePlotsFcn(~,~)
        updateImgData();
        hPlt.pnccd.CData = logS(hData.img.data);
        hPlt.pnccd.XData = size(hData.img.data,2) * [-.5, .5] - [0,1];
        hPlt.pnccd.YData = size(hData.img.data,1) * [-.5, .5] - [0,1];
%         hPlt.pnccd.XData = (1:size(hData.img.data,2))-hData.var.center(2);
%         hPlt.pnccd.YData = (1:size(hData.img.data,1))-hData.var.center(1);
        hAx.pnccd.CLim = iif(hData.bool.autoScale, ...
            [nanmin(hPlt.pnccd.CData(:)), nanmax(hPlt.pnccd.CData(:))], ...
            logS(hData.par.cLims));
        hAx.pnccd_CBar.TickLabels = iif(hData.bool.logScale, ...
            sprintf('10^{%.1g}\n', (hAx.pnccd_CBar.Ticks)), hAx.pnccd_CBar.Ticks);
        
        hPlt.lit.XData = 1:numel(db.runInfo(run).nlit_smooth);
        hPlt.lit.YData = db.runInfo(run).nlit_smooth;
%         hPlt.nPhotons.XData = hPlt.lit.XData;
%         hPlt.nPhotons.YData = db.data(run).nPhotons;
        hAx.lit.XLim = [.75, numel(db.runInfo(run).nlit_smooth)+.25];
        
        hPlt.lit_current.XData = hit;
        hPlt.lit_current.YData = hData.var.nLitPixel;
%         hPlt.nPhotons_current.XData = hit;
%         hPlt.nPhotons_current.YData = db.data(run).nPhotons(hit);
        
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
            hData.par.nRings = str2num_fast(...
                hFig.main_uicontrols.nRings_edt.String);
            calcMinimaPixelPos();
            hData.par.ringwidth = str2num_fast(...
                hFig.main_uicontrols.ringWidth_edt.String);
            if isgraphics(hPlt.rings)
                delete(hPlt.rings)
            end
            hold(hAx.pnccd, 'on');
            hPlt.rings = draw_rings(hAx.pnccd, [0,0], hData.par.nRings, ...
                hData.pixelMinima, hData.par.ringwidth, 'k');
            grid(hAx.pnccd, 'off');
            hold(hAx.pnccd, 'off');
        end
    end % plotRings
    
    function setCMap(~,~)
        hData.par.cMap = hFig.main_uicontrols.cMap_edt.String;
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
        fprintf('\tLoading run #%03d hit %01d ...\n', run, hit)
        
        % Reset data & parameter
        hData.bool.simulationMode = false;
        hData.bool.isCropped=false;
        hData.shape = [];
        hData.var.center = [547, 513];

        % Get data from databases
        hData.img.input = pnccd.data(hit).image;
        hData.trainId = pnccd.trainid(hit);
        
        % Check if run was background subtracted (folder name ends with "_bg").
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
        hData.var.nPhotonsOnDetector = nansum(hData.img.data(:));
        
        % Automatic correction of relative geometry (gap size and left/right
        % shift) from calculated values based on the motor encoder values of
        % the pnCCDs, and manual calibration for some images.
        [hData.img.dataCorrected,hData.var.gapSize,hData.var.shiftSize,~,...
            hData.var.center]=pnccdGeometryFcn(hData.img.input,db.runInfo,...
            pnccd.run,hData.par.nPixelFull,hData.par.addGap,hData.par.addShift);
        
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
        
        if hit <= numel(db.shape(run).shape)
            if ~isempty(db.shape(run).shape(hit).data)
                hData.shape = db.shape(run).shape(hit).data;
                [hData.img.dropletdensity, hData.img.support] = ...
                    ellipsoid_density(hData.shape.a/2,hData.shape.b/2,...
                    (hData.shape.a/2+hData.shape.b/2)/2,hData.shape.rot,...
                    [513,513], [1024,1024]);
                hData.img.dropletOutline = ellipse_outline(...
                    hData.shape.a/2*6, hData.shape.b/2*6, hData.shape.rot);
                fprintf('...shape found\t...got support & density\n')
                %% BEGIN: DETECTOR GEOMETRY CORRECTION
                %                     dataScatt = hData.img.dataCorrected;
                %                     simScatt = abs(ft2(hData.img.dropletdensity)).^2;
                %                     refineDetectorGeometry(dataScatt, simScatt)
                %% END: DETECTOR GEOMETRY CORRECTION
            end
        end
        db.center(run).center(hit).data = hData.var.center;
        db.shape(run).shape(hit).data = hData.shape;
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
            hFig.main_uicontrols.index_txt.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
            loadImageData;
        end
        updatePlotsFcn();
    end % loadNextHit
    
    function loadNextFile(~,~,filepath,nextRun,direction)
%         fprintf('\tSaving DB file ...\n')
%         saveDBFcn();
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
            hAx.pnccd.Title.String = sprintf('Loading run #%s ...', fn(1:4)); drawnow;
            nextrun = str2num_fast(fn(1:4));
            loadNextFile(src, evt, fp, nextrun);
            createPlots;
        end
    end % getFileFcn
    
    %% Centering und Shape Determination
    
    function centerImgFcn(~,~)
        hFig.main.Pointer = 'watch'; drawnow;
        fprintf('Calculating center ...\n')
        if any( (hData.var.center-size(hData.img.dataCorrected)/2) > 20)
            hData.var.center=size(hData.img.dataCorrected)/2+1;
        end
        
%%%%%%         OLD METHOD
%         hFig.centering = getFigure(hFig.centering, ...
%             'NumberTitle', 'off', ...
%             'Name', 'Centering pattern',...
%             'KeyPressFcn', @centerkeyfun);
% % %         %         if hit<=numel(db.center(run).center)
% % %         %             if isfield(db.center(run).center(hit),'data')
% % %         %                 if ~isempty(db.center(run).center(hit).data)
% % %         %                     hData.var.center = db.center(run).center(hit).data;
% % %         %                     hData.var.center = hData.var.center + [hData.par.addGap/2, -hData.par.addShift/2];
% % %         %                     hFig.main.Pointer = 'arrow'; drawnow;
% % %         %                     %                     centrosymmetric
% % %         %                     updatePlotsFcn;
% % %         %                     return
% % %         %                 end
% % %         %             end
% % %         %         end
        
        
%         hData.var.center=size(hData.img.dataCorrected)/2;
%         [hData.var.center, hAx.centering, hPlt.centering] = findCenterFcn(...
%             smoothImg,'figure', hFig.centering, 'center',...
%             hData.var.center,'nWedges', 12, 'movMeanPixel', 1, 'rMin', 80,...
%             'rMax', 200, 'displayflag', 1, 'nIterations', 5,...
%             'ringradii', hData.pixelMinima, 'nPixShift', 1);

%         [hData.var.center, hAx.centering, hPlt.centering] = findCenterFcn(...
%             hData.img.dataCorrected,'figure',hFig.centering,'center',...
%             hData.var.center,'nWedges',16,'movMeanPixel',3,'rMin',70,...
%             'rMax',150,'displayflag',1,'nIterations',7,...
%             'ringradii', hData.pixelMinima, 'nPixShift', 1);

%%%%%%

        % NEW METHOD
        smoothImg = imgaussfilt(hData.img.dataCorrected, 1);
%         smoothImg = hData.img.dataCorrected;
        windowSize = 300;
        imgSize = size(smoothImg);
        [xx,yy] = meshgrid( 1:imgSize(2), 1:imgSize(1) );
        centerMaskRadius = 60;
        smoothImg((xx - hData.var.center(2)).^2 + ...
            (yy - hData.var.center(1)).^2 <= centerMaskRadius^2) = nan;
%         figure(3434); clf; 
%         mysubplot(2,2,1); imagesc(xx.^2+yy.^2 <= centerMaskRadius^2)
%         mysubplot(2,2,2); imagesc(smoothImg)
%         
%                 smoothImg = smoothImg .* (xx.^2+yy.^2 <= centerMaskRadius^2);
%         mysubplot(2,2,3); imagesc(smoothImg)
%         mysubplot(2,2,4); imagesc(xx.^2+yy.^2 <= centerMaskRadius^2)
        
%         hData.var.center = size(smoothImg)/2+1;
        hData.var.center = findCenterXcorr(smoothImg, hData.var.center, ...
            windowSize, hData.pixelMinima);
        figure(hFig.main)
        % end NEW MOTHOD
        
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

    function calcMinimaPixelPos()
        %% calculate minima positions from radius (in SI units)
        qMinima = nan(1,hData.par.nRings);
        qMinima(1) = 1.55*pi/hData.var.radiusInNm;
        wavelength = 1.2398e-9;
        for iMinimum=2:hData.par.nRings
            qMinima(iMinimum) = qMinima(iMinimum-1) + 3.24/hData.var.radiusInNm;
        end
        thetaMinima = 2*asin(qMinima*wavelength/4/pi);
        hData.pixelMinima = tan(thetaMinima)*370e-3/75e-6;
    end % calcMinimaPixelPos
    
    function centerkeyfun(~,evt)
        hFig.main.Pointer = 'watch'; drawnow;
        dc = 1;
        switch evt.Key
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
            case {'2', 'numpad2'}
                findShapeFcn();
            case {'3', 'numpad3'}
                initIPR();
            case {'0', 'numpad0'}
                initIPRsim
        end
        db.center(run).center(hit).data = hData.var.center;
        try delete(hPlt.centering.black); end %#ok<TRYNC>
        hPlt.centering.black = draw_rings(hAx.centering, ...
            (hData.var.center), 0, hData.pixelMinima, ...
            hData.par.ringwidth, [.3 .3 .3]);
        hFig.main.Pointer = 'arrow'; drawnow;
    end % centerkeyfun
    
    function findShapeFcn(~,~)
        hFig.main.Pointer = 'watch'; drawnow;
        fprintf('Estimating shape ...\n')
        hFig.shape1 = getFigure(hFig.shape1, ...
            'NumberTitle', 'off', 'Name', 'shape figure #1');
        hFig.shape2 = getFigure(hFig.shape2, ...
            'NumberTitle', 'off', 'Name', 'shape figure #2');
        if ~isgraphics(hAx.shape1(1))
            hAx.shape1(1)=subplot(1,4,1,'Parent',hFig.shape1);
            imagesc(hAx.shape1(1), nan(1));
            hAx.shape1(2)=subplot(1,4,2,'Parent',hFig.shape1);
            imagesc(hAx.shape1(2), nan(1));
            hAx.shape1(3)=subplot(1,4,3,'Parent',hFig.shape1);
            imagesc(hAx.shape1(3), nan(1));
            hAx.shape1(4)=subplot(1,4,4,'Parent',hFig.shape1);
            imagesc(hAx.shape1(4), nan(1));
        end
        if ~isgraphics(hAx.shape2(1))
            hAx.shape2(1)=mysubplot(1,3,1,'Parent',hFig.shape2);
            hAx.shape2(2)=mysubplot(1,3,2,'Parent',hFig.shape2);
            hAx.shape2(3)=mysubplot(1,3,3,'Parent',hFig.shape2);
            
            hImg.shape2(1) =  imagesc(hAx.shape2(1), 1);
            hImg.shape2(2) =  imagesc(hAx.shape2(2), 1);
            hImg.shape2(3) =  imagesc(hAx.shape2(3), 1);
            title(hAx.shape2(3), 'calculated droplet density');
            title(hAx.shape2(3), 'calculated droplet density');
            hold(hAx.shape2(3), 'on');
            hPlt.shape2(3) = plot(hAx.shape2(3), nan, nan, 'r--');
            
            drawnow; % necessary before creating colorbars
            colorbar(hAx.shape2(1),'Location','southoutside');
            colorbar(hAx.shape2(2),'Location','southoutside');
            colorbar(hAx.shape2(3),'Location','southoutside');
            colormap(hAx.shape2(1),r2b);
            colormap(hAx.shape2(2),r2b);
            colormap(hAx.shape2(3),'igray');
        end
        
        % SHAPE FIT
%         hData.var.radiusInPixel = hData.var.radiusInPixel*2;
        [hData.shape, hData.goodnessOfFit, hAx.shape2] = findShapeFit(...
            hData.img.dataCropped, hData.var.radiusInPixel, ...
            'hAxesFig1', hAx.shape1, 'hAxesFig2', hAx.shape2);
        
        db.shape(run).shape(hit).data = hData.shape;
        db.shape(run).shape(hit).R = 6*(hData.shape.a/2 + hData.shape.b/2)/2;
        db.shape(run).shape(hit).ar = iif(hData.shape.a>hData.shape.b, ...
            hData.shape.a/hData.shape.b, hData.shape.b/hData.shape.a);
        hData.var.radiusInNm = db.shape(run).shape(hit).R*1e-9;
        db.sizing(run).R(hit) = hData.var.radiusInNm;
        calcMinimaPixelPos();
        
        % DROPLET DENSITY FROM SHAPE FIT
        [hData.img.dropletdensity, hData.img.support] = ellipsoid_density(...
            hData.shape.a/2, hData.shape.b/2, ...
            (hData.shape.a/2+hData.shape.b/2)/2, ...
            hData.shape.rot, [513,513], [1024,1024]);
        
        % DROPLET OUTLINE FROM SHAPE FIT
        hData.img.dropletOutline = ellipse_outline(...
            hData.shape.a/2*6, hData.shape.b/2*6, hData.shape.rot);
        
        fprintf('\tellipse parameters: \n')
        fprintf('\t\t[a, b, rot] = [%.2fpx, %.2fpx, %.2frad]\n', ...
            hData.shape.a/2,hData.shape.b/2,hData.shape.rot)
        fprintf('\t\t[a, b, rot] = [%.2fnm, %.2fnm, %.2fdegree]\n', ...
            hData.shape.a/2*6,hData.shape.b/2*6,hData.shape.rot/2/pi*360)
        fprintf('\t\t\t-> shape found\n')
        
        % PLOTTING
        xData=6*( size(hData.img.dropletdensity,2)*[-0.5,0.5]-[0,1]);
        yData=6*( size(hData.img.dropletdensity,1)*[-0.5,0.5]-[0,1]);
        xyLims=db.shape(run).shape(hit).R*1.5*[-1,1];
        
        hImg.shape2(3).XData = xData;
        hImg.shape2(3).YData = yData;
        hImg.shape2(3).CData = hData.img.dropletdensity;
        hPlt.shape2(3).XData = hData.img.dropletOutline.x;
        hPlt.shape2(3).YData = hData.img.dropletOutline.y;
        set(hAx.shape2(3), 'XLim', xyLims, 'YLim', xyLims);
        
        figure(hFig.main)
        hFig.main.Pointer = 'arrow'; drawnow;
%         updatePlotsFcn;
    end % findShapeFcn
    
    %% Reconstruction Functions
    
    function initIPR(~,~)
        hFig.main.Pointer = 'watch'; drawnow limitrate;
        hIPR = IPR(hData.img.dataCropped, ...
            'objectHandle', hIPR, ...
            'support0', hData.img.support, ...
            'support_radius', db.sizing(run).R(hit)*1e9/6, ...
            'dropletOutline', hData.img.dropletOutline, ...    
            'rho0', hData.img.dropletdensity,...
            'parentfig', hFig.main);
        hFig.main.Pointer = 'arrow';
        hIPR.figureArray(1).Pointer = 'arrow'; drawnow;
        %         figure(hFig.main)
    end % initIPR
    
    function initIPRsim(~,~)
        if ~hFig.main.UserData.isValidSimulation
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
        hFig.main.Pointer = 'watch'; drawnow limitrate;
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
            'parentfig', hFig.main,...
            'simScene', simScene);
        hFig.main.Pointer = 'arrow';
        hIPR.figureArray(1).Pointer = 'arrow'; drawnow;
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
        hFig.main.Pointer = 'arrow';
        hIPR.figureArray(1).Pointer = 'arrow'; drawnow;
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
        drawnow;
    end % startSimulation
    
    function setNSimCores(~,~)
        hData.par.nSimCores = hFig.main_uicontrols.oneCore_tb.Value;
    end % setNSimCores
    
    %% Process and Save Data
    
    function saveDBFcn(~,~)
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
    end % saveDBFcn

    function saveImgFcn(~,~,axesToSave)
        if nargin<3
            axesToSave=gca;
        end
        saveName = getSaveName;
        fprintf('Saving current axes to %s\n\t... ', saveName)
        exportgraphics(axesToSave,saveName,'Resolution',const.printRes)
        fprintf('done!\n')
    end % saveImgFcn

    function fullpath = getSaveName
        hSave.folder=fullfile(paths.img,...
            sprintf('%s',datetime('now','Format','yyyy-MM-dd')),...
            sprintf('r%03d',run));
        if ~exist(hSave.folder,'dir'),mkdir(hSave.folder); end
        hSave.fileFormat='png';
        hSave.fileName=sprintf('r%03d-h%03d-%s.%s',run,hit,...
        datetime('now','Format','yyyy-MM-dd_hhmmss-SSS'),hSave.fileFormat);
        hSave.fullpath=fullfile(hSave.folder,hSave.fileName);
        fullpath=hSave.fullpath;
    end % getSaveName

    function reconANDsave(~,~)       
        %         try d = load(fullfile(paths.db, 'db_recon.mat')); db_recon = d.db_recon; clear d;
        %         catch; fprintf('could not load db_recon\n'); end
        while true
            if hFig.main.UserData.isRegisteredEscape
                fprintf('Loop aborted by user.\n')
                break;
            end
            %             try
%             if strcmp(db.runInfo(run).doping.dopant,'none')
%                 fprintf('run %i is not doped. Continuing...\n',run)
%                 loadNextFile([],[],paths.pnccd, run+1,1);
%                 continue
%             end
            if db.runInfo(run).nlit_smooth(hit)<2e3 ...
                    || isnan(db.sizing(run).R(hit)) ...
                    || db.sizing(run).R(hit)*1e9<20
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
            
            centerImgFcn();
            centerImgFcn();
            findShapeFcn();
            
            if strcmp(db.runInfo(run).doping.dopant,'none')
                fprintf('run %i is not doped. Continuing without phasing ...\n',run)
                loadNextHit([],[],1);
%                 loadNextFile([],[],paths.pnccd, run+1,1);
                continue
            end
            initIPR();
            hIPR.reconAddToPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
%             hIPR.reconAddToPlan('nthio',hData.var.nSteps,hData.var.nLoops);
            hIPR.reconRunPlan();
            exportgraphics(hIPR.figureArray(1), getSaveName)
%             print(hIPR.figureArray(1), ...
%                 fullfile(paths.img, 'reconstructions', '2020-11-12', ...
%                 sprintf('run%04d_hit%04d_dcdi.png',run,hit)),'-dpng')
%                     end
            loadNextHit([],[],1)
        end
    end % reconAndSave

end % pnccdGUI
