function pnccdGUI(paths, varargin)

fprintf('\n\n\n\n\nStarting pnCCD GUI _/^\\_/^\\_\n\t\t\t... please be patient ...\n\n\n\n\n')

%% Databases
% paths = mypaths;
db = loadDatabases(paths);

%% Figure creation & initialization of grapical objects

h.main.figure = findobj('Type','Figure','Name','ASR - main Window');
if isgraphics(h.main.figure)
    clf(h.main.figure);
else
    h.main.figure = figure;
    hUnits = h.main.figure.Units;
    h.main.figure.Units = 'pixels';
    % h.main.figure.Position = [2561 1072.2 1080 543.2];
    h.main.figure.Position(3:4) = [1080 543.2];
    h.main.figure.Units = hUnits;
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

h.centerstat.figure = gobjects(1);
h.centerstat.axes = gobjects(1,2);
h.centerstat.hist = gobjects(1,2);
h.centerstat.scatter = gobjects(1,2);
h.centerstat.yline = gobjects(2,2);

h.shape(1).figure = gobjects(1);
h.shape(2).figure = gobjects(1);
h.shape(1).axes = gobjects(1,4);
h.shape(2).axes = gobjects(1,3);

h.guinier.figure = gobjects(1);
h.guinier.axes = gobjects(1);

h.deconvolution.figure = gobjects(1);
h.imagecopies.figure = gobjects(1);
h.savepattern.figure = gobjects(1);

%% Declarations

run = 450;
hit = 68;
pnccd = [];
runningBg = [];

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
hData.par.centeringMinRadius = 85;
hData.deconvolution.par.minRadius = 85;
hData.par.centeringWindowSize = 300;
hData.par.litPixelThreshold = 4e3;
hData.par.nPhotonsThreshold = 4e4;
hData.par.radiusThresholdInNm = 20;
hData.par.doRunningBg = false;
hData.par.interpolate = true;
hData.par.centerofmass = true;

% Hard coded custom Gaps and Shifts for different shifts for testing geometry
% consistency:
hData.par.addCenter = [0,0];
hData.par.addGap = 0;
hData.par.addShift = 0;
hData.par.addGapArray = zeros(1,6);
hData.par.addShiftArray = zeros(1,6);

hData.const.detector.px = 75e-6;
hData.const.detector.dist = 0.37;
hData.const.px2m = 6e-9;
hData.const.detector.pxAngle = hData.const.detector.px/hData.const.detector.dist; % small angle approx
hData.const.detector.pxArea = hData.const.detector.px^2;
hData.const.detector.pxSolidangle = hData.const.detector.pxArea/hData.const.detector.dist^2; % small angle approx
hData.const.fel.wavelength = 1.2398e-9;
hData.const.fel.k = 2*pi/hData.const.fel.wavelength;
hData.const.dq = hData.const.fel.k*hData.const.detector.px/hData.const.detector.dist;

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
hData.img.radial.wedgeMask = [];
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

% handles.run = run;
% handles.hit = hit;
% handles.pnccd = pnccd;
% handles.paths = paths;
% handles.db = db;
% handles.h = h;
% % handles.hAx = hAx;
% % handles.h.image = h.image;
% % handles.h.plot = h.plot;
% handles.hData = hData;
% handles.hPrevData = hPrevData;
% handles.hSave = hSave;
% handles.hRecon = hRecon;
% handles.hIPR = hIPR;
% handles.hSimu = hSimu;

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
            case 'alt', src.UserData.isRegisteredAlt = true;
            case 'control', src.UserData.isRegisteredControl = true;
            case 'shift', src.UserData.isRegisteredShift = true;
            case 'escape', src.UserData.isRegisteredEscape = true;
        end
    end % thisKeyPressFcn

    function thisKeyReleaseFcn(src,evt)
        switch evt.Key
            case 'escape',              h.main.figure.UserData.stopScript = true;
            case 'leftarrow',           loadNextHit(src,evt,-1);
            case {'rightarrow', 'space'},          loadNextHit(src,evt,1);
            case 's'
                if h.main.figure.UserData.isRegisteredShift, startSimulation;
                elseif h.main.figure.UserData.isRegisteredControl,  saveRecon();
                else, saveDataBaseFcn();
                end
            case {'uparrow', 'downarrow'}
                figure(h.centering.figure)
                centeringWindowKeyReleaseFcn([],evt)
            case 'l',                   getFileFcn;
            case 'c'
                fprintf('\n\n\n\n\n\n\n\n\n\n'); src.Pointer = 'arrow'; drawnow;
            case {'1','numpad1'}
                if h.main.figure.UserData.isRegisteredControl
%                     centerImgFcn([],[],1,1);
                    hData.var.center = hData.var.centerRunMedian;
                    centerImgFcn();
                else
%                     centerImgFcn([],[],1,1);
%                     centerImgFcn([],[],[2 2 2],[1 .5 .25]);
%                     shiftStrength = linspace(1,0.1,10);
                    centerImgFcn();%[],[], ones(size(shiftStrength)), shiftStrength);
%                     centerImgFcn([],[],5,0.25);
                end
                updatePlotsFcn();
            case 'q'
                inputData = {num2str(hData.var.center(1)),num2str(hData.var.center(2))};
                inputData = inputdlg({'center y [px]','center x [px]'}, 'Set center manually', [1,10; 1,10], inputData);
                if numel(inputData) == 2
                    if ~isempty(inputData{1}) && ~isempty(inputData{2})
                        hData.var.center = [str2double(inputData{1}), str2double(inputData{2})];
                        db.center(run).center(hit).data = hData.var.center;
                        hData.img.dataCropped = centerAndCropFcn(...
                            hData.img.dataCorrected, hData.var.center,...
                            hData.par.interpolate);
                        hData.bool.isCropped=true;
                        centerImgFcn([],[],1,0)
%                         updateImgData();
%                         updatePlotsFcn();
                    end
                end
            case {'2','numpad2'}
            fprintf('\tshift #%i, addShift = %i\n', db.runInfo(run).shift, hData.par.addShift)
                findShapeFcn();
                updatePlotsFcn();
            case {'w'},                 startSimulation();
            case {'3','numpad3'},       initIPR();
            case {'e'},                 initIPRsim();
            case {'4','numpad4'},       addToPlan([],[],'er');
            case {'5','numpad5'},       addToPlan([],[],'dcdi');
            case {'6','numpad6'},       addToPlan([],[],'ntdcdi');
            case {'7','numpad7'},       addToPlan([],[],'nthio');
            case {'8','numpad8'},       addToPlan([],[],'hio');
            case {'9','numpad9'},       addToPlan([],[],'raar');       
            case {'return'},            runRecon();
            case {'0','numpad0'},       resetRecon();
            case {'delete'}
                hData.shape.a = 2;
                hData.shape.b = 2;
%                 hData.shape.aspectRatio = nan;
                hData.shape.manual = true;
                hData.shape.valid = ~hData.shape.valid;
                setShapeFcn();
                loadNextHit(src,evt,1)
            case 'pagedown'
                fprintf('%.1f\t%.1f\n', hData.shape.R, db.shape(run).shape(hit).R)
                hData.shape.R = hData.shape.R - 5;
                hData.shape.a = 2*hData.shape.R;
                hData.shape.b = 2*hData.shape.R;
                setShapeFcn();
% %                 if numel(db.sizing(run).R) >= hit 
% %                     if ~isnan(db.sizing(run).R(hit))
% %                         db.shape(run).shape(hit).R = db.sizing(run).R(hit)*1e9/6;
% %                     else
% %                         db.shape(run).shape(hit).R = db.sizing(run).R_airy(hit)*1e9/6;
% %                     end
% %                 end
%                 db.shape(run).shape(hit).R = 5;
%                 db.shape(run).shape(hit).a = 2*db.shape(run).shape(hit).R;
%                 db.shape(run).shape(hit).b = 2*db.shape(run).shape(hit).R;
%                 hData.shape.R = db.shape(run).shape(hit).R;
%                 hData.shape.a = db.shape(run).shape(hit).a;
%                 hData.shape.b = db.shape(run).shape(hit).b;
%                 setShapeFcn();
% %                 findShapeFcn();
%                 findShapeFcn();
            case 'pageup'
                fprintf('%.1f\t%.1f\n', hData.shape.R, db.shape(run).shape(hit).R)
                hData.shape.R = hData.shape.R + 5;
                hData.shape.a = 2*hData.shape.R;
                hData.shape.b = 2*hData.shape.R;
                setShapeFcn();
%                 findShapeFcn();
            case {'d'}
                computeDeconvolution();
%             otherwise
%                 disp(evt.Key)
            case 'r'
%                 hRecon = [];
%                 centerArrayShiftMean = [0 0; 546.15 515.55; 537.69 512.65; 535.38 510.11; 535.05 510.39; 538.51 512.18];
% %                 hData.var.center =  [535.5 510.5];
%                 if run>450
%                     centerArrayShiftMean(6,:) = [539.9182  512.1045];
%                 else
%                     centerArrayShiftMean(6,:) = [535.0667  512.3778];
%                 end
%                 hData.var.center = centerArrayShiftMean(db.runInfo(run).shift,:);
%                 hData.var.center = hData.var.centerRunMedian;
%                 centerImgFcn([],[],[2],[1])
%                 centerImgFcn([],[],[3 3],[.5 .25])
%                 shiftStrength = linspace(1,0.1,10);
                hData.var.center = hData.var.centerRunMedian;
                centerImgFcn();
                updatePlotsFcn();
                findShapeFcn();
                findShapeFcn();
                computeDeconvolution();
                initIPR();
                addToPlan([],[],'dcdi');
                runRecon();
            case 't'
                calcTransferFunction();
                
            case 'g'
%                 findShapeFcn();
                findShapeFcn();
                updatePlotsFcn();
                initIPR();
                addToPlan([],[],'dcdi');
                runRecon();
            case 'f'
                initIPR();
                addToPlan([],[],'dcdi');
                runRecon();
            case 'v'
                centerImgFcn();
                findShapeFcn();
            case 'z'
                hData.var.center = hData.var.centerRunMedian;
                centerImgFcn([],[],1,0)
                findShapeFcn();
            case 'b'
                hData.par.doRunningBg = ~hData.par.doRunningBg;
                fprintf('\nDo running BG subtraction = %d\n\n', hData.par.doRunningBg)
                loadImageData();
                updatePlotsFcn();
            case 'm'
                hData.shape.manual = false;
                hData.shape.valid = true;
                fprintf('\tshift #%i, addShift = %i\n', db.runInfo(run).shift, hData.par.addShift)
                findShapeFcn();
                updatePlotsFcn();
            case 'o'
                computeSNR();
%                 thisRun = run;
%                 thisHit = hit;
%                 fprintf('.\n')
%                 fprintf('\t\t\t\tsse = %.2f\n', db.sizing(thisRun).fit(thisHit).gof.sse)
%                 fprintf('\t\t\t\trsquare = %.2f\n', db.sizing(thisRun).fit(thisHit).gof.rsquare)
%                 fprintf('\t\t\t\tdfe = %.0f\n', db.sizing(thisRun).fit(thisHit).gof.dfe)
%                 fprintf('\t\t\t\tadjrsquare = %.2f\n', db.sizing(thisRun).fit(thisHit).gof.adjrsquare)
%                 fprintf('\t\t\t\trmse = %.3f\n', db.sizing(thisRun).fit(thisHit).gof.rmse)
            case 'p'
%                 f3553345 = figure(3553345);
%                 imagesc(hData.img.dataCropped, [0.1, 100]);
%                 set(gca, 'ColorScale', 'log');
%                 colorbar;
%                 print(f3553345, sprintf('tmp/r%03d.%03d_%d.png', run, hit, pnccd.trainid(hit)), '-dpng')
                computeRadialProfile();
            case 'leftbracket'
                computeGuinierProfile();
            case 'rightbracket'
                computeGuinierProfile();
                saveRadialProfile();
            case 'i'
                savePattern([],[],[430,344,260], hData.par.cMap)
            case 'backslash'
                if src.UserData.isRegisteredAlt
                    initIPR();
                    addToPlan([],[],'dcdi');
                    runRecon();
                    saveImgFcn();
                elseif src.UserData.isRegisteredControl
                    makePixForSelectedHits();
                else
                    saveImgFcn();
                end
            case 'end'
                while true
                    if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                    saveImgFcn();
                    loadNextHit(src,evt,1)
%                     if db.runInfo(209).doping.dopant
                end
                
            otherwise
                fprintf('''%s'' key pressed.\n', evt.Key);
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
                hit = max([hit, 1]); 
                hit = min([hit, numel(pnccd.trainid)]);
                h.ui.indexText.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
                loadImageData();
                updatePlotsFcn();
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
            if hData.par.doRunningBg, runningBg = running_bg_load_run(run, paths.runningBg);
            else, runningBg = []; end
           
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
        
        createPlots();
        loadImageData();
        updatePlotsFcn();
    end % initFcn
    
    function thisCloseRequestFcn(~,~)
        questAnswer = questdlg('Do you want to save the current databases before closing?',...
            'Save db files?', 'Yes', 'No', 'No');
        if strcmp(questAnswer,'Yes')
            saveDataBaseFcn();
        end
        try close(hIPR.go.figure); end
        try close(hSimu.figObj); end %#ok<*TRYNC> 
        try close(h.centering.figure); end
        try close(h.shape(1).figure); end
        try close(h.shape(2).figure); end
        try close(h.deconvolution.figure); end
        try close(h.radial.figure); end
        try close(h.centerstat.figure); end
        
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
        h.main.figure.MenuBar = 'none';
        
        h.main.uimenu.centerAndShape.menu = uimenu(h.main.figure, 'Text', 'center & shape');
        h.main.uimenu.reconstruction.menu = uimenu(h.main.figure, 'Text', 'phasing');
        h.main.uimenu.simulation.menu = uimenu(h.main.figure, 'Text', 'simulation');
        h.main.uimenu.deconvolution.menu = uimenu(h.main.figure, 'Text', 'deconvolution');

        h.main.uimenu.centerAndShape.shot.menu = uimenu(h.main.uimenu.centerAndShape.menu, 'Text', 'this image', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,[],true,true,'shot','none'));
        h.main.uimenu.centerAndShape.run.menu = uimenu(h.main.uimenu.centerAndShape.menu, 'Text', 'this run', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,[],true,true,'run','none'));
        h.main.uimenu.centerAndShape.all.menu = uimenu(h.main.uimenu.centerAndShape.menu, 'Text', 'all runs', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,[],true,true,'all','none'));
        
        h.main.uimenu.reconstruction.shot.menu = uimenu(h.main.uimenu.reconstruction.menu, 'Text', 'this image');
        h.main.uimenu.reconstruction.run.menu = uimenu(h.main.uimenu.reconstruction.menu, 'Text', 'this run');
        h.main.uimenu.reconstruction.all.menu = uimenu(h.main.uimenu.reconstruction.menu, 'Text', 'all runs');
        
        h.main.uimenu.reconstruction.shot.DCDI = uimenu(h.main.uimenu.reconstruction.shot.menu, 'Text', 'DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',false,false,'shot'));
%         h.main.uimenu.reconstruction.shot.NTDCDI = uimenu(h.main.uimenu.reconstruction.shot.menu, 'Text', 'NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',false,false,'shot'));
        h.main.uimenu.reconstruction.shot.shapeDCDI = uimenu(h.main.uimenu.reconstruction.shot.menu, 'Text', 'shape + DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',false,true,'shot'));
%         h.main.uimenu.reconstruction.shot.shapeNTDCDI = uimenu(h.main.uimenu.reconstruction.shot.menu, 'Text', 'shape + NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',false,true,'shot'));
        h.main.uimenu.reconstruction.shot.centerShapeDCDI = uimenu(h.main.uimenu.reconstruction.shot.menu, 'Text', 'center + shape + DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',true,true,'shot'));
%         h.main.uimenu.reconstruction.shot.centerShapeNTDCDI = uimenu(h.main.uimenu.reconstruction.shot.menu, 'Text', 'center + shape + NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',true,true,'shot'));

        h.main.uimenu.reconstruction.run.DCDI = uimenu(h.main.uimenu.reconstruction.run.menu, 'Text', 'DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',false,false,'run'));
%         h.main.uimenu.reconstruction.run.NTDCDI = uimenu(h.main.uimenu.reconstruction.run.menu, 'Text', 'NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',false,false,'run'));        
        h.main.uimenu.reconstruction.run.shapeDCDI = uimenu(h.main.uimenu.reconstruction.run.menu, 'Text', 'shape + DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',false,true,'run'));
%         h.main.uimenu.reconstruction.run.shapeNTDCDI = uimenu(h.main.uimenu.reconstruction.run.menu, 'Text', 'shape + NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',false,true,'run'));
        h.main.uimenu.reconstruction.run.centerShapeDCDI = uimenu(h.main.uimenu.reconstruction.run.menu, 'Text', 'center + shape + DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',true,true,'run'));
%         h.main.uimenu.reconstruction.run.centerShapeNTDCDI = uimenu(h.main.uimenu.reconstruction.run.menu, 'Text', 'center + shape + NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',true,true,'run'));

        h.main.uimenu.reconstruction.all.DCDI = uimenu(h.main.uimenu.reconstruction.all.menu, 'Text', 'DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',false,false,'all'));
%         h.main.uimenu.reconstruction.all.NTDCDI = uimenu(h.main.uimenu.reconstruction.all.menu, 'Text', 'NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',false,false,'all'));        
        h.main.uimenu.reconstruction.all.shapeDCDI = uimenu(h.main.uimenu.reconstruction.all.menu, 'Text', 'shape + DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',false,true,'all'));
%         h.main.uimenu.reconstruction.all.shapeNTDCDI = uimenu(h.main.uimenu.reconstruction.all.menu, 'Text', 'shape + NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',false,true,'all'));
        h.main.uimenu.reconstruction.all.centerShapeDCDI = uimenu(h.main.uimenu.reconstruction.all.menu, 'Text', 'center + shape + DCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'DCDI',true,true,'all'));
%         h.main.uimenu.reconstruction.all.centerShapeNTDCDI = uimenu(h.main.uimenu.reconstruction.all.menu, 'Text', 'center + shape + NTDCDI', 'MenuSelectedFcn', @(src,evt) centerShapeAndRecon(src,evt,'NTDCDI',true,true,'all'));
        
        h.main.uimenu.simulation.itemScanAlpha = uimenu(h.main.uimenu.simulation.menu, 'Text', 'scan alpha', 'MenuSelectedFcn', @simulationScanAlpha);
        h.main.uimenu.simulation.itemScanDeltaFactor = uimenu(h.main.uimenu.simulation.menu, 'Text', 'scan delta factor', 'MenuSelectedFcn', @simulationScanDeltaFactor);
        h.main.uimenu.simulation.itemScanAlphaAndDeltaFactor = uimenu(h.main.uimenu.simulation.menu, 'Text', 'scan alpha and delta factor', 'MenuSelectedFcn', @simulationScanAlphaAndDeltaFactor);

        h.main.uimenu.deconvolution.itemRunDecon = uimenu(h.main.uimenu.deconvolution.menu, 'Text', 'run deconvolution', 'MenuSelectedFcn', @computeDeconvolution);
        
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
            'Units', 'normalized', 'Position', [.65 .8 .1 .05], 'Callback', @findCenterButtonCallbackFcn);
        h.ui.findShapeButton = uicontrol(h.main.figure, 'Style', 'pushbutton', 'String', '(2) find shape',...
            'Units', 'normalized', 'Position', [.77 .8 .1 .05], 'Callback', @findShapeButtonCallbackFcn);
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
        
        h.ui.nCoresText = uicontrol(h.main.figure, 'Style', 'text', ...
            'Units', 'normalized', 'Position', [.87 .69 .04 .03], 'String', 'with',...
            'BackgroundColor', h.main.figure.Color);
        h.ui.nCoresButtonGroup = uibuttongroup(h.main.figure,...
            'Position',[.91 .67 .07 .07],'SelectionChangedFcn',@setNSimCores);
        h.ui.oneCoreToggleButton = uicontrol(h.ui.nCoresButtonGroup,...
            'Style','radiobutton','Units','normalized','Position',[0,.5,1,.5],'String','1 Core','Callback',@setNSimCores);
        h.ui.twoCoresToggleButton = uicontrol(h.ui.nCoresButtonGroup,...
            'Style','radiobutton','Units','normalized','Position',[0,0,1,.5],'String','2 Cores');
        
%        handles = h;
    end % createGUI

    function findCenterButtonCallbackFcn(src,evt)
       shiftStrength = linspace(1.5,0.1,6);
       centerImgFcn([],[], ones(size(shiftStrength)), shiftStrength);
       updatePlotsFcn(); 
    end

    function findShapeButtonCallbackFcn(src,evt)
       findShapeFcn();
       updatePlotsFcn();
    end
    
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
            logS(hData.par.cLims)); %#ok<NANMAX,NANMIN>
        colormap(h.main.axes(1), hData.par.cMap);
        drawnow;
        h.main.colorbar(1) = colorbar(h.main.axes(1));
        h.main.axes(1).UserData.origXLim = h.main.axes(1).XLim;
        h.main.axes(1).UserData.origYLim = h.main.axes(1).YLim;
        plotRings();
        
        %% Lit Pixel Axes
        plotLineWidth = 1.5;
        cla(h.main.axes(2)); 
        hold(h.main.axes(2), 'off');
        
        h.main.plot.nLitPixel(1) = stem(h.main.axes(2), ...
            1, 'LineWidth', plotLineWidth);
        
        hold(h.main.axes(2), 'on');
        grid(h.main.axes(2), 'on');
        
        h.main.plot.nPhotons(1) = stem(h.main.axes(2), ...
            1, ...
            '--', 'LineWidth', plotLineWidth, 'Color', colorOrder(5));
        
        h.main.plot.nLitPixel(2) = stem(h.main.axes(2), ...
            1, 1, ...
            'r', 'LineWidth', plotLineWidth);
        
        h.main.plot.nPhotons(2) = stem(h.main.axes(2), 1, ...
            1, 'r--', 'LineWidth', plotLineWidth);
        
        h.main.axes(2).YScale = 'log';
        h.main.axes(2).XLim = [.75, 1.25];
        h.main.axes(2).Title.String = 'lit pixel over hit index';
        h.main.axes(2).UserData.origXLim = h.main.axes(2).XLim;
        h.main.axes(2).UserData.origYLim = h.main.axes(2).YLim;
        
        h.main.plot.nLitPixel(3) = plot(h.main.axes(2), h.main.axes(2).XLim, ...
            [1,1] * 1, '--', 'Color', colorOrder(1)/2);
        h.main.plot.nPhotons(3) = plot(h.main.axes(2), h.main.axes(2).XLim, ...
            [1,1] * 1, '--', 'Color', colorOrder(5)/2);       
        
        legend(h.main.axes(2), {'# lit pixel', '# photons'});
        
%         %% Update plots
%         updatePlotsFcn();
        
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
            hData.par.cLims); %#ok<NANMAX,NANMIN>
        h.main.image(1).AlphaData = hData.img.data > h.main.axes(1).CLim(1);
        h.main.axes(1).ColorScale = iif(hData.bool.logScale, 'log', 'linear');
        
        h.main.plot.nLitPixel(1).XData = (1:numel(db.runInfo(run).nlit_smooth)) - 0.1;
        h.main.plot.nLitPixel(1).YData = db.runInfo(run).nlit_smooth;
        h.main.plot.nLitPixel(2).XData = hit - 0.1;
        h.main.plot.nLitPixel(2).YData = hData.var.nLitPixel;
        h.main.plot.nLitPixel(3).XData = h.main.axes(2).XLim;
        h.main.plot.nLitPixel(3).YData = [1,1] * hData.par.litPixelThreshold;
        
        h.main.plot.nPhotons(1).XData = h.main.plot.nLitPixel(1).XData + 0.1*2;
        h.main.plot.nPhotons(1).YData = db.data(run).nPhotons;
        h.main.plot.nPhotons(2).XData = hit + 0.1;
        h.main.plot.nPhotons(2).YData = db.data(run).nPhotons(hit);
        h.main.plot.nPhotons(3).XData = h.main.axes(2).XLim;
        h.main.plot.nPhotons(3).YData = [1,1] * hData.par.nPhotonsThreshold;
        
        h.main.axes(2).XLim = [.5, numel(db.runInfo(run).nlit_smooth)+.5];
%         if isempty(db.doping(run).dopant)
            db.doping(run).dopant = db.runInfo(run).doping.dopant{:};
%         end
        h.main.axes(1).Title.String = sprintf(...
            'run \\#%03i - id %i - hit %i, R = %.0fnm, dope = %s', ...
            run, hData.trainId, hit , db.sizing(run).R(hit)*1e9, db.doping(run).dopant);
        h.main.axes(1).Title.Interpreter = 'latex';
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

    function loadImageData(~,~,direction)
        if nargin<3
            direction = 1;
        end
        fprintf('\tLoading ...\n\t\trun: %03d, \thit: %03d, \tid: %d \t shift #%i\n\t\tT = %.0fK, \tp = %.0fbar, \tdopant: %s\n', ...
            run, hit, pnccd.trainid(hit), db.runInfo(run).shift, db.runInfo(run).source.T, db.runInfo(run).source.p, db.runInfo(run).doping.dopant{:})
        
        % Reset data & parameter
        hData.bool.simulationMode = false;
        hData.bool.isCropped=false;
        hData.shape = [];
        hData.var.center = [540, 513];

        % Get data from databases
        hData.img.input = pnccd.data(hit).image;
        hData.trainId = pnccd.trainid(hit);
        
        % Check if run was background subtracted (folder name ends with "ButtonGroup").
        % Do Subtraction if not. TO DO: introduce another criterium or do
        % subtraction beforehand in all cases!
        if hData.par.doRunningBg
            if isempty(runningBg)
                paths.runningBg = 'E:\XFEL2019_He\bg_running_all_hits';
                runningBg = running_bg_load_run(run, paths.runningBg);
            end
            hData.img.input = hData.img.input - squeeze(runningBg(hit,:,:));
            if strcmp(paths.pnccd(end-2:end-1),'bg')
                hData.img.input = hData.img.input + pnccd.bg_corr;
            end
        elseif ~strcmp(paths.pnccd(end-2:end-1),'bg')
%             hData.img.input = hData.img.input - pnccd.bg_corr;
        end
        
        

        % Old correction needs to be made
        if ~db.sizing(run).ok(hit); db.sizing(run).R(hit) = nan; end
        if ~isfield(db.shape(run).shape(hit), 'R')
            db.shape(run).shape(hit).R = nan;
        end
        if isnan(db.shape(run).shape(hit).R)
            db.shape(run).shape(hit).R = db.sizing(run).R(hit)*1e9;
            if isnan(db.shape(run).shape(hit).R)
                db.shape(run).shape(hit).R = db.sizing(run).R_airy(hit)*1e9;
            end
        end
        hData.var.radiusInPixel = db.shape(run).shape(hit).R/6;
        hData.var.radiusInNm = hData.var.radiusInPixel*1e-9*6;
        hData.var.nLitPixel = db.runInfo(run).nlit_smooth(hit);        
        
        % Custom masking
        hData.img.mask = ones(1024);
        hData.img.mask(512-23:512+25,513-32:512+32) = 0;
        hData.img.input(hData.img.mask(:)<1) = nan;
        hData.img.mask = ~isnan(hData.img.input);

        hData.par.addCenter = [0,0];
        hData.par.addGapArray = [0,0,0,0,0,0];
        hData.par.addShiftArray = [0,0,0,0,0,0];
        hData.par.addShiftArray = [0 0 -3 1 0 0];
%         hData.par.addGapArray = 4*[1 1 1 1 1 1];

%         hData.par.addShiftArray = [0 0 -2 1 1 1];
        hData.par.addGapArray = [4 4 4 4 4 4];

%         disp(db.runInfo(run).shift)
        hData.par.addGap = hData.par.addGapArray(db.runInfo(run).shift);

        hData.par.addShift = hData.par.addShiftArray(db.runInfo(run).shift);
        hData.var.nPhotonsOnDetector = nansum(hData.img.input(hData.img.input>0)); %#ok<NANSUM>
        
        % Automatic correction of relative geometry (gap size and left/right
        % shift) from calculated values based on the motor encoder values of
        % the pnCCDs, and manual calibration forad some images.
        [hData.img.dataCorrected,hData.var.gapSize,hData.var.shiftSize,~,...
            hData.var.center]=pnccdGeometryFcn(hData.img.input,db.runInfo,...
            pnccd.run,hData.par.nPixelFull,hData.par.addGap,hData.par.addShift);
        
        if ~isfield(hData.var, 'centerRunMedian') || ~isfield(hData.var, 'centerList')
            hData.var.centerList = reshape([db.center(run).center(:).data], 2, []);
            hData.var.centerRunMedian = median(hData.var.centerList, 2, 'omitnan')';
        end
        
        if hit <= numel(db.center(run).center)
            if ~isempty(db.center(run).center(hit).data)
                if ~isnan(db.center(run).center(hit).data)
                    hData.var.center = db.center(run).center(hit).data...
                        + hData.par.addCenter;
                    hData.img.dataCropped = centerAndCropFcn(...
                        hData.img.dataCorrected, hData.var.center,...
                        hData.par.interpolate);
                    hData.bool.isCropped=true;
                    fprintf('\t\t... centered at [%.1f %.1f]\t... cropped\n', hData.var.center(1), hData.var.center(2));
                end
            end
        end
        try
            if hit <= numel(db.shape(run).shape)
                if ~isempty(db.shape(run).shape(hit).data)
                    hData.shape = db.shape(run).shape(hit).data;
                    [hData.img.dropletdensity, hData.img.support] = ...
                        ellipsoid_density(hData.shape.a/2,hData.shape.b/2,...
                        (hData.shape.a/2+hData.shape.b/2)/2,hData.shape.rot,...
                        [513,513], [1024,1024]);
                    hData.img.dropletOutline = ellipse_outline(...
                        hData.shape.a/2*6, hData.shape.b/2*6, hData.shape.rot);
%                     fprintf('\t\t... shape found\t... got support & density\n')
                    %% BEGIN: DETECTOR GEOMETRY CORRECTION
                    %                     dataScatt = hData.img.dataCorrected;
                    %                     simScatt = abs(ft2(hData.img.dropletdensity)).^2;
                    %                     refineDetectorGeometry(dataScatt, simScatt)
                    %% END: DETECTOR GEOMETRY CORRECTION
                end
            end
        catch
            warning('\t\t... shape determination failed!\n')
        end

        db.data(run).nPhotonsBgSubstracted(hit) = hData.var.nPhotonsOnDetector;
        db.data(run).nLitPixel(hit) = hData.var.nLitPixel;
        
        updateImgData();
               
        if ~isfield(hData.shape, 'manual')
            hData.shape.manual = false;
        end
        if isempty(hData.shape.manual)
            hData.shape.manual = false;
        end
        if ~isfield(db.shape(run).shape(hit), 'manual')
            db.shape(run).shape(hit).manual = false;
        end
        if isempty(db.shape(run).shape(hit).manual)
            db.shape(run).shape(hit).manual = false;
        end
        
%         if isnan(db.sizing(run).R(hit))
%             db.shape(run).shape(hit).R = 6;
%             db.shape(run).shape(hit).a = 2*db.shape(run).shape(hit).R;
%             db.shape(run).shape(hit).b = 2*db.shape(run).shape(hit).R;
%             db.shape(run).shape(hit).manual = false;
%             hData.shape.R = db.shape(run).shape(hit).R;
%             hData.shape.a = db.shape(run).shape(hit).a;
%             hData.shape.b = db.shape(run).shape(hit).b;
%             hData.shape.manual = db.shape(run).shape(hit).manual;
%             setShapeFcn();
%         end
        
%         try
%             computeRadialProfile();
%         end
%         figure(h.main.figure);

%         if ( db.runInfo(run).nlit_smooth(hit) < hData.par.litPixelThreshold ...
%                 || db.data(run).nPhotons(hit) < hData.par.nPhotonsThreshold)
%             hData.shape.valid = false;
%             db.shape(run).shape(hit).valid = false;
%             fprintf('\t\tinvalid shot!\n')
%             loadNextHit([],[],direction)
%         else
%             calcMinimaPixelPos();
%             centerImgFcn([],[],[2,2,2],[1,.5,.25]);
%             findShapeFcn();
%         end

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
        if ~exist('pnccd','var')
            pnccd.trainid=nan;
            run=473;
            hPrevData.run=0;
        end
        if hit+direction<1 || hit+direction>numel(pnccd.trainid)
            loadNextFile(src,evt,hData.filepath, run+direction, direction);
            hit = iif(direction>0,1,numel(db.runInfo(run).nlit_smooth));
        else
            hit = hit+direction;
        end
        h.ui.indexText.String = sprintf('%i/%i', hit, numel(pnccd.trainid));

        if ((db.runInfo(run).nlit_smooth(hit) >= hData.par.litPixelThreshold) ...
                && (db.data(run).nPhotons(hit) >= hData.par.nPhotonsThreshold)) ...
                || h.main.figure.UserData.isRegisteredControl

            loadImageData([],[],direction);
            updatePlotsFcn();
        else
            loadNextHit(src,evt,direction);
        end

%         if db.shape(run).shape(hit).valid
%             loadImageData([],[],direction);
%             updatePlotsFcn();
%             db.shape(run).shape(hit).valid = true;
%             findShapeFcn();
%             findShapeFcn();
%         else
%             loadNextHit(src,evt,direction);
%         end
    end % loadNextHit
    
    function loadNextFile(~,~,filepath,nextRun,direction)
%         fprintf('\tSaving DB file ...\n')
%         saveDataBaseFcn();
        %         fprintf('saving recon file ...'); drawnow;
        %         save(fullfile(paths.recon, sprintf('r%04d_recon_%s.mat', run, db.runInfo(run).doping.dopant{:})), 'hRecon', '-v7');
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
%         pnccd = hPrevData.pnccd;
        [pnccd, hPrevData.pnccd] = swap(pnccd, hPrevData.pnccd);
        if ~exist('hRecon', 'var'), hRecon = []; end
        [hReconTmp, hPrevDatahReconTmp] = swap(hRecon, hPrevData.hRecon);
        clear hRecon; hRecon = hReconTmp; clear hReconTmp;
        hPrevData.hRecon = []; hPrevData.hRecon = hPrevDatahReconTmp; clear hPrevDatahReconTmp;
        [hData.filename, hPrevData.filename] = swap(hData.filename, hPrevData.filename);
        
        % Check if new path folder was selected
        if ~strcmp(filepath, hData.filepath)
            hData.filepath = filepath;
            hPrevData.run = nan;
        end
        
        % Check if requested run is stored in hPrevData, otherwise load it.
        if run ~= nextRun
            [newpnccd, hData.filename, hData.var.nHits] = pnccd_load_run(nextRun, paths.pnccd);
            clear pnccd;
            pnccd = newpnccd;
            if hData.par.doRunningBg, runningBg = running_bg_load_run(nextRun, paths.runningBg);
            else, runningBg = []; end
            run = pnccd.run;
            %             hRecon = load_recon(nextrun, paths.recon);
        end
        
        %%%%% plotting centers %%%%%
        while numel([db.shape(run).shape.valid]) < numel(db.runInfo(run).nlit_smooth)
            db.shape(run).shape(end+1).valid = true;
        end
        hData.var.hitList = [];
        try
            for jHit=1:numel(db.runInfo(run).nlit_smooth)
                if db.shape(run).shape(jHit).valid ...
                        && (db.runInfo(run).nlit_smooth(jHit) >= hData.par.litPixelThreshold) ...
                        && (db.data(run).nPhotons(jHit) >= hData.par.nPhotonsThreshold)
                    hData.var.hitList = [hData.var.hitList, jHit];
                end
            end
        catch
           fprintf('%d\n', jHit);
        end
%         hData.var.hitList = find([db.shape(run).shape.valid]...
%             & (db.runInfo(run).nlit_smooth >= hData.par.litPixelThreshold) ...
%             & (db.data(run).nPhotons >= hData.par.nPhotonsThreshold));
        try
            hData.var.centerList = reshape([db.center(run).center(hData.var.hitList).data], 2, []);
        catch
            for iHit = hData.var.hitList
                if size(db.center(run).center(iHit).data, 1) > 1
                    db.center(run).center(iHit).data = db.center(run).center(iHit).data(1,:);
                end
            end
            hData.var.centerList = reshape([db.center(run).center(hData.var.hitList).data], 2, []);
        end
            
        hData.var.centerRunMean = nanmean(hData.var.centerList,2)';
        hData.var.centerRunMedian = nanmedian(hData.var.centerList,2)';
        hData.var.centerDistanceToMedian = sqrt(sum((hData.var.centerRunMedian-hData.var.center).^2));
%         if i==1 && j==1
        
        if ~isgraphics(h.centerstat.figure)
            % init graphics objectsr
            h.centerstat.figure = getFigure(h.centerstat.figure, 'NumberTitle', 'off', ...
                'Name', 'center statistics');
            clf(h.centerstat.figure);
            h.centerstat.axes(1)=subplot(1,2,1,'parent',h.centerstat.figure);
            h.centerstat.hist(1)=histogram(h.centerstat.axes(1), hData.var.centerList(1,:), 'DisplayName', 'center y'); hold on;
            h.centerstat.hist(2)=histogram(h.centerstat.axes(1), hData.var.centerList(2,:), 'DisplayName', 'center x');
            legend(h.centerstat.axes(1), 'Location', 'north')
            h.centerstat.axes(2)=subplot(1,2,2,'parent',h.centerstat.figure);
            h.centerstat.scatter(1)=scatter(h.centerstat.axes(2), db.runInfo(run).nlit_smooth(hData.var.hitList), hData.var.centerList(1,:), 'DisplayName', 'center y'); hold on;
            h.centerstat.scatter(2)=scatter(h.centerstat.axes(2), db.runInfo(run).nlit_smooth(hData.var.hitList), hData.var.centerList(2,:), 'DisplayName', 'center x'); hold on;
            legend(h.centerstat.axes(2), 'Location', 'east')
            h.centerstat.yline(1,1:2)=yline([0,0],':', 'DisplayName', 'run mean');
            h.centerstat.yline(2,1:2)=yline([0,0],'--', 'DisplayName', 'run median');
            h.centerstat.axes(2).XScale = 'log';
        end
        %             currFig = get(0,'CurrentFigure');
        
%         h.centerstat.axes(1).NextPlot='replace';
        h.centerstat.hist(1).Data = hData.var.centerList(1,:);
        h.centerstat.hist(2).Data = hData.var.centerList(2,:);
        h.centerstat.axes(1).Title.String = sprintf( ...
            'mean = [%.1f, %.1f] - median = [%.1f, %.1f]', hData.var.centerRunMean, hData.var.centerRunMedian);
        h.centerstat.scatter(1).XData=db.runInfo(run).nlit_smooth(hData.var.hitList);
        h.centerstat.scatter(1).YData=hData.var.centerList(1,:);
        h.centerstat.scatter(2).XData=db.runInfo(run).nlit_smooth(hData.var.hitList);
        h.centerstat.scatter(2).YData=hData.var.centerList(2,:);
        if ~isnan(hData.var.centerRunMean), h.centerstat.yline(1,1).Value=hData.var.centerRunMean(1); h.centerstat.yline(1,2).Value=hData.var.centerRunMean(2); end
        if ~isnan(hData.var.centerRunMedian), h.centerstat.yline(2,1).Value=hData.var.centerRunMedian(1); h.centerstat.yline(2,2).Value=hData.var.centerRunMedian(2); end
        
%         end
        %%%%% plotting %%%%%
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
            hit = 1;
            loadImageData();
            updatePlotsFcn();
        end
    end % getFileFcn
    
    %% Centering und Shape Determination
    
    function centerImgFcn(~,~,nIterations,shiftStrength)
%         hData.var.center = [528, 518];
%         hData.var.center = [534.5, 510];
        if nargin<4 || isempty(shiftStrength)
            shiftStrength = 1:-0.1:0.2;
            nIterations = ones(size(shiftStrength));
        end
%         if nargin < 4
%             shiftStrength = 1;
%         end
%         if nargin < 3
%             nIterations = 1;
%         end
        h.main.figure.Pointer = 'watch'; drawnow;
%         fprintf('\tCalculating center ...\n')
        
        if ~isgraphics(h.centering.figure)
            h.centering.figure = getFigure(h.centering.figure, 'NumberTitle', 'off', ...
                'Name', 'centering figure');
            clf(h.centering.figure);
            hUnits = h.centering.figure.Units;
            h.centering.figure.Units = 'pixels';
            % h.centering.figure.Position = [1.2818e+03 741.8000 1.2784e+03 616.8000];
            h.centering.figure.Position(3:4) = [1.2784e+03 616.8000];
            h.centering.figure.Units = hUnits;
            h.centering.axes = gobjects(1,4);
            
            h.centering.figure.WindowKeyReleaseFcn = @centeringWindowKeyReleaseFcn;
            h.centering.figure.WindowKeyPressFcn = @(src,evt) thisKeyPressFcn(src,evt);
            h.centering.figure.Interruptible = 'off';
            h.centering.figure.UserData.isRegisteredAlt = false;
            h.centering.figure.UserData.isRegisteredControl = false;
            h.centering.figure.UserData.isRegisteredShift = false;
            h.centering.figure.UserData.isRegisteredEscape = false;
        
%             h.centering.axes(1) = subplot(3,3,[1:2,4:5,7:8]);
%             h.centering.axes(1) = axes(h.centering.figure, 'Position', [0 .25 .5 .75] + [1 0 -2 -2]*0.01);
            h.centering.axes(1) = mysubplot(1,2,1, 'parent', h.centering.figure);
            h.centering.image(1) = imagesc(h.centering.axes(1), nan);
            hold(h.centering.axes(1), 'on')
            
% %             h.centering.axes(2) = mysubplot(3,3,3);
%             h.centering.axes(2) = axes(h.centering.figure, 'Position', [0 0 .25 .25]+[1 1 -2 -2]*0.01);
%             h.centering.image(2) = imagesc(h.centering.axes(2), nan);
%             hold(h.centering.axes(2), 'on')
            
%             h.centering.axes(3) = mysubplot(3,3,6);
%             h.centering.axes(3) = axes(h.centering.figure, 'Position', [.5 0 .5 1]+[1 1 -2 -2]*0.05);
            h.centering.axes(3) = mysubplot(1,2,2, 'parent', h.centering.figure);
            h.centering.image(3) = imagesc(h.centering.axes(3), nan);
            colormap(h.centering.axes(3), 'wjet')
            hold(h.centering.axes(3), 'on')
            
% %             h.centering.axes(4) = mysubplot(3,3,9);
%             h.centering.axes(4) = axes(h.centering.figure, 'Position', [.25 0 .25 .25]+[1 1 -2 -2]*0.01);
%             h.centering.image(4) = imagesc(h.centering.axes(4), nan);
%             hold(h.centering.axes(4), 'on')
            
            h.centering.plot(1) = plot(h.centering.axes(1), nan, nan, 'k+', ...
                'LineWidth', .5, 'MarkerSize', 30);%, 'Color', [0.00,0.45,0.74]);
            h.centering.plot(2) = plot(h.centering.axes(1), nan, nan, 'k--');%, 'Color', [0.00,0.45,0.74]);
            h.centering.line(1) = yline(h.centering.axes(3), 0, '--', 'Color', [0 0 0]);
            h.centering.line(2) = xline(h.centering.axes(3), 0, '--', 'Color', [0 0 0]);
        end

        %         abortCenterSearch = false;
        hGapPx = 30;
        imgSize = size(hData.img.dataCorrected);
        [hData.img.xxFull,hData.img.yyFull] = meshgrid( 1:imgSize(2), 1:imgSize(1) );
        wedgeAngles = 15/180*pi*[-1 1; -1 1;-1 1; -1 1] + pi*[0 0; 1 -1; 0 0; 1 -1];
        wedgeCenters = [hGapPx 0; hGapPx 0; -hGapPx 0; -hGapPx 0];
        wedgeCentersShifted = wedgeCenters;




        smoothedImage = (hData.img.dataCorrected);
        hData.par.centeringSmoothSigma = .5;
        %         smoothedImage = imgaussfilt(hData.img.dataCorrected, hData.par.centeringSmoothSigma);

        for j = 1:numel(nIterations)
%             [hData.var.center, h.centering, centerShift] = findCenterPhaseRamps(...
%                 h.centering, ...
%                 smoothedImage, ...
%                 hData.var.center, ...
%                 nan, ...
%                 hData.minimaPositionsInPixel, ...
%                 1, ...
%                 0,...
%                 0,...
%                 1, ...
%                 db.shape(run).shape(hit).R_nm/6);

            for i = 1:nIterations(j)
                if any( (hData.var.center-size(hData.img.dataCorrected)/2) > 15)
                    hData.var.center=size(hData.img.dataCorrected)/2+1;
                end
                sImage = smoothedImage;

%                         hData.par.centeringMinRadius = 85;
%                 hData.par.centeringMaskDilation = 10;
                hData.par.centeringMinRadius = 70;
%                 hData.par.centeringMinRadius = 60;
                firstMinPos = find(hData.minimaPositionsInPixel>hData.par.centeringMinRadius, 1);
                if ~isempty(firstMinPos)
                    hData.par.centeringMinRadius = hData.minimaPositionsInPixel(firstMinPos);
                end
%                 hData.par.centeringMinRadius = 70;
%                 hData.par.centeringMinRadius = 0;
                
                
%                 hData.par.centeringMinRadius = 50;
                hData.par.centeringMaskDilation = 0;
                hData.par.centeringWindowSize = 300;
% 
                sImage( ( (hData.img.xxFull - hData.var.center(2)).^2 + ...
                    (hData.img.yyFull - hData.var.center(1)).^2 ) ...
                    < hData.par.centeringMinRadius^2 ) = nan;

                wedgeCentersShifted(:,1) = hData.var.center(1)+wedgeCenters(:,1);
                wedgeCentersShifted(:,2) = hData.var.center(2)+wedgeCenters(:,2);
                wedgeMask = computeRadialMask(imgSize, wedgeAngles, wedgeCentersShifted);
                sImage(~wedgeMask) = nan;
                sImage(imgSize(1)-hGapPx:imgSize(1)+hGapPx>100) = nan;
%                 sImage(sImage>100) = nan;
                
                hData.par.centerofmass=0;
                hData.par.interpolate=1;

                if ~hData.par.interpolate, hData.var.center = round(hData.var.center); end
%                 [hData.var.center, h.centering, centerShift] = findCenterPhaseRamps(...
%                     h.centering, ...
%                     sImage, ...
%                     hData.var.center, ...
%                     hData.par.centeringWindowSize, ...
%                     hData.minimaPositionsInPixel, ...
%                     shiftStrength(j), ...
%                     hData.par.centeringMaskDilation,...
%                     hData.par.centerofmass,...
%                     hData.par.interpolate, ...
%                     db.shape(run).shape(hit).R_nm/6);

% % % 
                [hData.var.center, h.centering, centerShift] = findCenterXcorr(...
                    h.centering, ...
                    sImage, ...
                    hData.var.center, ...
                    hData.par.centeringWindowSize, ...
                    hData.minimaPositionsInPixel, ...
                    shiftStrength(j), ...
                    hData.par.centeringMaskDilation,...
                    hData.par.centerofmass,...
                    hData.par.interpolate);

                if all(abs(centerShift) <= 0.1), break; end
            end
            if all(abs(centerShift) <= 0.1), break; end
            
        end
%         hData.var.center = hData.var.center - [1,1]*.5;

%         [smoothedImage, newShift] = findShiftPhaseRamps(...
%             h.centering, ...
%             sImage, ...
%             hData.var.center, ...
%             hData.par.centeringWindowSize, ...
%             hData.minimaPositionsInPixel, ...
%             shiftStrength(j), ...
%             hData.par.centeringMaskDilation,...
%             hData.par.centerofmass,...
%             hData.par.interpolate);
%         figure(h.centering.figure);
%         hData.img.dataCorrected(imgSize/2+1:end, :) = circshift(hData.img.dataCorrected(imgSize/2+1:end, :), newShift);


        % FILTER FOR OUTLIERS AND SET CENTER TO MEDIAN OF HIT LIST
        hData.var.hitList = [];
        for jHit=1:numel(db.runInfo(run).nlit_smooth)
            if db.shape(run).shape(jHit).valid ...
                    && (db.runInfo(run).nlit_smooth(jHit) >= hData.par.litPixelThreshold) ...
                    && (db.data(run).nPhotons(jHit) >= hData.par.nPhotonsThreshold)
                hData.var.hitList = [hData.var.hitList, jHit];
            end
        end
        
        hData.var.centerList = reshape([db.center(run).center(hData.var.hitList).data], 2, []);
        hData.var.centerRunMean = mean(hData.var.centerList,2, 'omitnan')';
        hData.var.centerRunMedian = median(hData.var.centerList,2, 'omitnan')';
        hData.var.centerDistanceToMedian = sqrt(sum((hData.var.centerRunMedian-hData.var.center).^2));
        
        if hData.var.centerDistanceToMedian > 10
%             abortCenterSearch = true;
            hData.var.center = hData.var.centerRunMedian;
            fprintf('\tCenter too far from run median. Set back to mean value [%.1f, %.1f]\n', ...
                hData.var.centerRunMean(1), hData.var.centerRunMean(2))
            centerImgFcn([],[],1,0)
        else
            h.main.figure.Pointer = 'arrow'; drawnow;
            hData.img.dataCropped = centerAndCropFcn(...
                hData.img.dataCorrected, hData.var.center,...
                hData.par.interpolate);
            hData.bool.isCropped=true;
        end
        db.center(run).center(hit).data = hData.var.center;
        updateImgData();
        updatePlotsFcn();
%         fprintf('\t\t-> centered\n')
    end % centerImgFcn

    function calcMinimaPixelPos()
        % calculate minima positions from radius (in SI units)
        hData.par.nRings = str2double(h.ui.nRingsEdit.String);
        qMinima = nan(1,hData.par.nRings);
        if isempty(hData.var.radiusInNm)
            hData.var.radiusInNm = nan;
        end
        if isnan(hData.var.radiusInNm)
            if ~isempty(db.shape(run).shape(hit).R)
                hData.var.radiusInNm = db.shape(run).shape(hit).R;
            end
        end
        qMinima(1) = 1.4303*pi/hData.var.radiusInNm;
        qDiff = ones(1, hData.par.nRings) * pi;
        qDiff(1:10) = pi*[1.4303, 1.0287, 1.0119, 1.0065, 1.0041, 1.0029, 1.0021, 1.0016, 1.0013, 1.0010];
        qDiff(hData.par.nRings+1:end) = [];
        for iMin=2:hData.par.nRings
            qMinima(iMin) = qMinima(iMin-1) + qDiff(iMin)/hData.var.radiusInNm;
        end
        thetaMinima = 2*asin(qMinima*hData.const.fel.wavelength/4/pi);
        hData.minimaPositionsInPixel = tan(thetaMinima)*370e-3/75e-6;
        hData.minimaPositionsInPixel(hData.minimaPositionsInPixel>512) = nan;
    end % calcMinimaPixelPos
    
    function centeringWindowKeyReleaseFcn(~,evt)
        if h.centering.figure.UserData.isRegisteredControl
            shiftStrength = 3;
        else
            if hData.par.interpolate
                shiftStrength = 0.5;
            else
                shiftStrength = 1;
            end
        end
        doUpdateShape = false;
        switch evt.Key
            case 'uparrow'
                hData.var.center(1)=hData.var.center(1)-shiftStrength;
%                 computeDeconvolution();
%                 doUpdateShape = true;
            case 'downarrow'
                hData.var.center(1)=hData.var.center(1)+shiftStrength;
%                 computeDeconvolution();
%                 doUpdateShape = true;
            case 'leftarrow'
                hData.var.center(2)=hData.var.center(2)+shiftStrength;
%                 computeDeconvolution();
%                 doUpdateShape = true;
            case 'rightarrow'
                hData.var.center(2)=hData.var.center(2)-shiftStrength;
%                 computeDeconvolution();
%                 doUpdateShape = true;
            case '1'
                if h.centering.figure.UserData.isRegisteredControl
%                     centerImgFcn([],[],5,0.25);
                    centerImgFcn([],[],1,1);
                elseif h.centering.figure.UserData.isRegisteredShift
                    centerImgFcn();
                else
%                     centerImgFcn([],[],1,1);
%                     centerImgFcn([],[],5,0.25);
%                     centerImgFcn([],[],[2 2 2],[1 .5 .25]);
                    centerImgFcn();
                end
                updatePlotsFcn();
            case {'2','numpad2'}
                findShapeFcn();
                updatePlotsFcn();
                figure(h.centering.figure)
                return
            case {'3','numpad3'}, initIPR(); return
            case {'5','numpad5'}, addToPlan([],[],'dcdi'); updatePlotsFcn(); return
            case {'return'}, runRecon(); return
            case 'z'
                hData.var.center = hData.var.centerRunMean;
                centerImgFcn([],[],1,0)
                findShapeFcn();
            case 'r'
                hData.var.center = hData.var.centerRunMedian;
                centerImgFcn();
                findShapeFcn();
                findShapeFcn();
                computeDeconvolution();
                updatePlotsFcn();
                initIPR();
                addToPlan([],[],'dcdi');
                runRecon();
            case 'v'
                centerImgFcn();
                findShapeFcn();
            case 'f'
                initIPR();
                addToPlan([],[],'dcdi');
                runRecon();
            case 'g'
                findShapeFcn();
                findShapeFcn();
                updatePlotsFcn();
                initIPR();
                addToPlan([],[],'dcdi');
                runRecon();
            case {'d'}
                computeDeconvolution();
            case 'p'
                computeRadialProfile();
            case 'control'
                h.centering.figure.UserData.isRegisteredControl = false;
            case 'space'
                figure(h.main.figure);
            otherwise
                return
        end
        if doUpdateShape
            findShapeFcn();
%             findShapeFcn();
            figure(h.centering.figure);
        end
        db.center(run).center(hit).data = hData.var.center;
        centerImgFcn([],[],1,0)

%         hData.img.dataCropped = centerAndCropFcn(...
%             hData.img.dataCorrected, hData.var.center,...
%             hData.par.interpolate);
%         hData.bool.isCropped=true;
%         findShapeFcn();
%         updatePlotsFcn();
%         figure(h.centering.figure)
    end % centeringWindowButtonUpFcn
    
    function findShapeFcn(~,~)
        h.main.figure.Pointer = 'watch'; drawnow;
        fprintf('\tEstimating shape ...\n')

        h.shape(1).figure = getFigure(h.shape(1).figure, ...
            'NumberTitle', 'off', 'Name', 'shape figure #1');
        h.shape(2).figure = getFigure(h.shape(2).figure, ...
            'NumberTitle', 'off', 'Name', 'shape figure #2');
        if ~isgraphics(h.shape(1).axes(1))
            hUnits = h.shape(1).figure.Units;
            h.shape(1).figure.Units = 'pixels';
            % h.shape(1).figure.Position = [1.8	41.8 1278.4 616.8];
            h.shape(1).figure.Position(3:4) = [1278.4 616.8];
            h.shape(1).figure.Units = hUnits;
            nAxes = 3;
            for iAx = 1:nAxes
                h.shape(1).axes(iAx) = subplot(1, nAxes, iAx, 'Parent', h.shape(1).figure);
                h.shape(1).img(iAx) = imagesc(h.shape(1).axes(iAx), nan);
            end
%             h.shape(1).axes(1)=subplot(1,4,1,'Parent',h.shape(1).figure);
%             imagesc(h.shape(1).axes(1), nan(1));
%             h.shape(1).axes(2)=subplot(1,4,2,'Parent',h.shape(1).figure);
%             imagesc(h.shape(1).axes(2), nan(1));
%             h.shape(1).axes(3)=subplot(1,4,3,'Parent',h.shape(1).figure);
%             imagesc(h.shape(1).axes(3), nan(1));
%             h.shape(1).axes(4)=subplot(1,4,4,'Parent',h.shape(1).figure);
%             imagesc(h.shape(1).axes(4), nan(1));
        end
        if ~isgraphics(h.shape(2).axes(1))
            hUnits = h.shape(2).figure.Units;
            h.shape(2).figure.Units = 'pixels';
            % h.shape(2).figure.Position = [1.8,741.8,1278.4,616.8];
            h.shape(2).figure.Position(3:4) = [1278.4 616.8];
            h.shape(2).figure.Units = hUnits;
            h.shape(2).figure.KeyPressFcn = @thisKeyPressFcn;
            h.shape(2).figure.KeyReleaseFcn = @thisKeyReleaseFcn;
            h.shape(2).uit = uitable(h.shape(2).figure, 'Units', 'normalized', ...
                'Position', [.02 .02 .96 .1], 'ColumnEditable', true, ...
                'CellEditCallback', @shapeUitCellEditCallback);

            h.shape(2).axes(1)=mysubplot(1,3,1,'Parent',h.shape(2).figure);
            h.shape(2).image(1) = imagesc(h.shape(2).axes(1), [0, 1], 'XData', [-512, 511]*6, 'YData', [-512, 511]*6);
            colormap(h.shape(2).axes(1),ihesperia);
            colorbar(h.shape(2).axes(1),'Location','southoutside');
%             h.shape(2).axes(1).Colorbar.Label.String = 'real(autocorrelation)';
            h.shape(2).axes(2)=mysubplot(1,3,2,'Parent',h.shape(2).figure);
            h.shape(2).image(2) =  imagesc(h.shape(2).axes(2), [0, 1], 'XData', [-512, 511]*6, 'YData', [-512, 511]*6);
            colormap(h.shape(2).axes(2),ihesperia);
            colorbar(h.shape(2).axes(2),'Location','southoutside');
%             h.shape(2).axes(2).Colorbar.Label.String = 'real(autocorrelation)';
            h.shape(2).axes(3)=mysubplot(1,3,3,'Parent',h.shape(2).figure);
            h.shape(2).image(3) =  imagesc(h.shape(2).axes(3), [0, 1], 'XData', [-512, 511]*6, 'YData', [-512, 511]*6);
            colormap(h.shape(2).axes(3), dropletWjet(256, 0.5));
            colorbar(h.shape(2).axes(3),'Location','southoutside'); 
            h.shape(2).axes(3).Colorbar.Label.String = 'calculated droplet density';
            
            hold(h.shape(2).axes(1), 'on');
            h.shape(2).plot(1,1) = plot(h.shape(2).axes(1), nan, nan, 'g--');

%             h.shape(2).plot(1,2) = plot(h.shape(2).axes(2), nan, nan, 'r.', 'MarkerSize',5,'LineWidth',1);
%             h.shape(2).plot(1,3) = plot(h.shape(2).axes(2), nan, nan, 'b.', 'MarkerSize',5);


            hold(h.shape(2).axes(2), 'on');
            h.shape(2).plot(2,1) = plot(h.shape(2).axes(2), nan, nan, 'k--', 'DisplayName', 'ellipse fit');
%             h.shape(2).plot(2,2) = plot(h.shape(2).axes(2), nan, nan, 'g.', 'MarkerSize',5,'LineWidth', 1, 'DisplayName', 'droplet border');
            h.shape(2).plot(2,3) = plot(h.shape(2).axes(2), nan, nan, 'r.', 'MarkerSize', 5, 'DisplayName', 'excluded');
            h.shape(2).plot(2,2) = scatter(h.shape(2).axes(2), nan, nan, 'g', 'DisplayName', 'droplet border');
%             h.shape(2).plot(2,3) = scatter(h.shape(2).axes(2), nan, nan, 'color', [.8,0,0], 'DisplayName', 'excluded');

            h.shape(2).axes(1).Title.String = 'real (autocorrelation)';
%             title(h.shape(2).axes(3), 'calculated droplet density');
            hold(h.shape(2).axes(3), 'on');
            h.shape(2).plot(3,1) = plot(h.shape(2).axes(3), nan, nan, 'r--');
            
            drawnow; % necessary before creating colorbars
            
            
            
            
            h.shape(2).axes(1).Colorbar.Label.String = 'real(autocorrelation)';
            h.shape(2).axes(2).Colorbar.Label.String = 'real(autocorrelation)';
            h.shape(2).axes(3).Colorbar.Label.String = 'calculated droplet density';

            h.shape(2).axes(3).Colorbar.Ruler.TickLabelFormat = '%g%%';
            h.shape(2).plot(1,1).Visible = false;

%             arrayfun(@(a) set(h.shape(2).axes(a), 'FontSize', 11), 1:3);
%             arrayfun(@(a) set(h.shape(2).axes(a).Colorbar, 'FontSize', 11), 1:3);
%             arrayfun(@(a) set(h.shape(2).axes(a).Colorbar.Label, 'FontSize', 12), 1:3);
            h.shape(2).axes(1).YLabel.String = 'nm';
            h.shape(2).axes(2).YLabel.String = 'nm';
            h.shape(2).axes(3).YLabel.String = 'nm';
        end
        
        if isnan(db.shape(run).shape(hit).R)
            if ~isnan(db.sizing(run).R(hit))
                db.shape(run).shape(hit).R = db.sizing(run).R(hit);
            else
                db.shape(run).shape(hit).R = 10;
                hData.shape.valid = false;
                db.shape(run).shape(hit).valid = false;
                fprintf('\t\tinvalid shot!\n')
%             return                
            end
        end
        
        % SHAPE FIT
%         hData.var.radiusInPixel = db.sizing(run).R(hit)*1e9/6;
        hData.var.radiusInPixel = db.shape(run).shape(hit).R/6;
        if isnan(hData.var.radiusInPixel)
            hData.var.radiusInPixel = db.sizing(run).R(hit)*1e9/6;
        end
        if isempty(hData.var.radiusInPixel)
            db.shape(run).shape(hit).R = 2;
            return
        end
        
        doAutocorrShape = 1;
        doGuinierShape = 0;
        doPorodShape = 0;
        gshape.nFits = 20;
        gshape.rRange = 0.2;
        gshape.doCenterFitting = 0;
        gshape.expandPixel = 0;
        gshape.expandPercent = 0;
        gshape.exSigma = 1.5;
        gshape.qmin = 0.08e9;
        gshape.px2m = hData.const.px2m;
        gshape.angleThresh = 15/180*pi;
        
        if doAutocorrShape
            [newShape, hData.shapeFitting, h.shape] = findShapeFit(...
                hData.img.dataCropped, hData.var.radiusInPixel, 'real', h.shape);
            hData.var.radiusInPixel = newShape.R;
        end
        if doGuinierShape
            [newShape, hData.shapeFitting, h.shape, centerShift] = findShapeGuinierFit(...
                hData.img.dataCropped, hData.var.radiusInPixel, hData.const.dq, h.shape, gshape);
        end
        
        if doPorodShape
            [newShape, hData.shapeFitting, h.shape, centerShift] = findShapePorodFit(...
                hData.img.dataCropped, hData.var.radiusInPixel, hData.const.dq, h.shape, gshape);
%             hData.var.center =  hData.var.center - centerShift;
%             fprintf('\tcentershift = [%.1f, %.1f]\n', centerShift(1), centerShift(2))
%             hData.img.dataCropped = centerAndCropFcn(...
%                 hData.img.dataCorrected, hData.var.center,...
%                 hData.par.interpolate);
%             [newShape, hData.shapeFitting, h.shape, centerShift] = findShapePorodFit(...
%                 hData.img.dataCropped, hData.var.radiusInPixel, hData.const.dq, h.shape, gshape);
            
        end
% %         fprintf('\t\t\tcenterShift = [%.1f, %.1f]f\n', centerShift(1), centerShift(2));
% %         hData.var.center = hData.var.center + centerShift;
        if ~hData.shape.manual
            hData.shape = newShape;
        end
%         hData.shapeFitting.goodnessOfFit
        
        if ~(isfield(hData.shape, 'valid') && ~hData.shape.valid)
            if ~isfield(db.shape(run).shape(hit), 'valid')
                hData.shape.valid = true;
            elseif isempty(db.shape(run).shape(hit).valid)
                hData.shape.valid = true;
            else
                hData.shape.valid = db.shape(run).shape(hit).valid;
            end
        end
        db.shape(run).shape(hit).valid = hData.shape.valid;
        
        fn = fieldnames(hData.shape);
        h.shape(2).uit.ColumnName = fn;
        for iFn=1:numel(fn); h.shape(2).uit.Data(iFn) = hData.shape.(fn{iFn}); end
        setShapeFcn();
%         centerShift
%         if any(abs(centerShift)>0.25)
%             hData.var.center = hData.var.center+centerShift;
%             hData.img.dataCropped = centerAndCropFcn(...
%                 hData.img.dataCorrected, hData.var.center,...
%                 hData.par.interpolate);
%             findShapeFcn();
%         end
    end % findShapeFcn

    function shapeUitCellEditCallback(~,~)
        fn = h.shape(2).uit.ColumnName;
        for iFn=1:numel(fn); hData.shape.(fn{iFn}) = h.shape(2).uit.Data(iFn); end
%         hData.shape.manual = true;
        
        if hData.shape.valid
            hData.shape.R = (hData.shape.a/2 + hData.shape.b/2)/2;
            hData.shape.aspectRatio = iif(hData.shape.a>hData.shape.b, ...
                hData.shape.a/hData.shape.b, hData.shape.b/hData.shape.a);
        else
            hData.shape.R = nan;
            hData.shape.aspectRatio = nan;
        end
        for iFn=1:numel(fn); h.shape(2).uit.Data(iFn) = hData.shape.(fn{iFn}); end
        setShapeFcn();
    end % shapeUitCellEditCallback

    function setShapeFcn(~,~)
        if ~isfield(hData.shape, 'manual'), hData.shape.manual = false; end
        if ~isfield(hData.shape, 'valid'), hData.shape.valid = false; end
        if ~isfield(hData.shape, 'rot'), hData.shape.rot = 0; end
        if hData.shape.manual, bgCol = [.6 .6 0.9];
        else
            if hData.shape.valid, bgCol = [.6 .9 0.6];
            else, bgCol = [1 0.6 0.6];
            end
        end
        h.shape(2).uit.BackgroundColor = bgCol;
        
        db.shape(run).shape(hit).data = hData.shape;
        db.shape(run).shape(hit).a_nm = 6*(hData.shape.a/2);
        db.shape(run).shape(hit).b_nm = 6*(hData.shape.a/2);
        db.shape(run).shape(hit).rot_radian = hData.shape.rot;
        db.shape(run).shape(hit).rot_degree = hData.shape.rot/pi*180;
        db.shape(run).shape(hit).R = 6*(hData.shape.a/2 + hData.shape.b/2)/2;
        db.shape(run).shape(hit).R_nm = 6*(hData.shape.a/2 + hData.shape.b/2)/2;
        db.shape(run).shape(hit).ar = iif(hData.shape.a>hData.shape.b, ...
            hData.shape.a/hData.shape.b, hData.shape.b/hData.shape.a);
        db.shape(run).shape(hit).valid = hData.shape.valid;                                     
        db.shape(run).shape(hit).manual = hData.shape.manual;
        hData.var.radiusInNm = db.shape(run).shape(hit).R*1e-9;
%         db.sizing(run).R(hit) = hData.var.radiusInNm;
        calcMinimaPixelPos();
        
        % DROPLET DENSITY FROM SHAPE FIT
        [hData.img.dropletdensity, hData.img.support] = ellipsoid_density(...
            hData.shape.a/2, hData.shape.b/2, ...
            (hData.shape.a/2+hData.shape.b/2)/2, ...
            hData.shape.rot, [513,513], [1024,1024]);
        
        % DROPLET OUTLINE FROM SHAPE FIT
        shapeFitOutline = ellipse_outline(...
            hData.shape.a, hData.shape.b, hData.shape.rot);
        hData.img.dropletOutline = ellipse_outline(...
            hData.shape.a/2*6, hData.shape.b/2*6, hData.shape.rot);
        
%         fprintf('\t\tellipse parameters: \n')
        fprintf('\t\t[a, b, rot] = [%.1fpx, %.1fpx, %.1frad] = [%.0fnm, %.0fnm, %.0fdeg]\n', ...
            hData.shape.a/2,hData.shape.b/2,hData.shape.rot, ...
            hData.shape.a/2*6,hData.shape.b/2*6,hData.shape.rot/2/pi*360)
        if hData.shape.valid
            fprintf('\t\t-> shape found\n');
        else
            fprintf('\t\t-> shape invalid!\n')
        end
        
        % PLOTTING
%         xData=6*( size(hData.img.dropletdensity,2)*[-0.5,0.5]-[0,1]);
%         yData=6*( size(hData.img.dropletdensity,1)*[-0.5,0.5]-[0,1]);
        xyLims=db.shape(run).shape(hit).R_nm*1.5*[-1,1];
        
%         h.shape(2).image(3).XData = xData;
%         h.shape(2).image(3).YData = yData;
        h.shape(2).image(3).CData = hData.img.dropletdensity/max(hData.img.dropletdensity(:))*100;
%         h.shape(2).image(3).AlphaData = hData.img.dropletdensity>0;
%         h.shape(2).plot(1,1).XData = 6*shapeFitOutline.x;%1+size(hData.img.dropletdensity,2)/2+shapeFitOutline.x;
%         h.shape(2).plot(1,1).YData = 6*shapeFitOutline.y;%1+size(hData.img.dropletdensity,1)/2+shapeFitOutline.y;
        h.shape(2).plot(2,1).XData = 6*shapeFitOutline.x;%1+size(hData.img.dropletdensity,2)/2+shapeFitOutline.x;
        h.shape(2).plot(2,1).YData = 6*shapeFitOutline.y;%1+size(hData.img.dropletdensity,1)/2+shapeFitOutline.y;
        h.shape(2).plot(3,1).XData = hData.img.dropletOutline.x;%hData.img.dropletOutline.x;
        h.shape(2).plot(3,1).YData = hData.img.dropletOutline.y;%hData.img.dropletOutline.y;
        xyLims=db.shape(run).shape(hit).R_nm*[-1,1];
        set(h.shape(2).axes(1), 'XLim', 3*xyLims, 'YLim', 3*xyLims);
        set(h.shape(2).axes(2), 'XLim', 3*xyLims, 'YLim', 3*xyLims);
        set(h.shape(2).axes(3), 'XLim', 1.5*xyLims, 'YLim', 1.5*xyLims);
        
%         h.shape(2).plot(1,1).Visible = 0;
%         h.shape(2).plot(2,1)
        h.shape(2).plot(2,1).Visible = 1;
        h.shape(2).plot(3,1).Visible = 1;
%         legend(h.shape(2).axes(2), [h.shape(2).plot(2,1), h.shape(2).plot(2,2), h.shape(2).plot(2,3)], 'Location', 'southoutside', 'Orientation', 'horizontal')
%         h.shape(2).axes(2).Colorbar.Visible = 'off';
%         h.shape(2).axes(2).Position(2) = h.shape(2).axes(1).Position(2);
%         centerImgFcn([],[],1,0);
%         if isgraphics(h.centering.figure)
%             draw_rings(h.centering.axes(1), db.center(run).center(hit).data, [], ...
%                 hData.minimaPositionsInPixel, 1, h.centering.plot(2).Color, [], h.centering.plot(2));
%         end

%         figure(h.main.figure)
        h.main.figure.Pointer = 'arrow'; drawnow;
    end % setShapeFcn
    
    %% Reconstruction Functions
    
    function initIPR(~,~)
        h.main.figure.Pointer = 'watch'; drawnow limitrate;
        graphicsObj = [];
        if exist('hIPR', 'var') && ~isempty(hIPR)
            if any(find(strcmp(fieldnames(hIPR), 'go')))
                graphicsObj = hIPR.go;
            end
            % remove all fields except the graphics object
            fnIPR = fieldnames(hIPR);
            for ifn = 1:numel(fnIPR)
                %                     if strcmp(fnIPR{ifn}, 'go'), continue; end
                %                     if strcmp(fnIPR{ifn}, 'parentFig'), continue; end
                hIPR.(fnIPR{ifn}) = [];
            end
        end

        clear hIPR;
        alpha = alphaConfig(run, db.doping(run).dopant);
        
        hIPR = IPR(hData.img.dataCropped, ...
            'runID', run, ...
            'hitID', hit, ...
            'trainID', hData.trainId, ...
            'go', graphicsObj, ...
            'support0', hData.img.support, ...
            'support_radius', db.shape(run).shape(hit).R/6, ...
            'dropletOutline', hData.img.dropletOutline, ...    
            'rho0', hData.img.dropletdensity,...
            'parentfig', h.main.figure, ...
            'alpha', alpha);
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
        simScatt=centerAndCropFcn(simScatt,[513,513],hData.par.interpolate);
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
    
    function addToPlan(~,~,recAlg)
        hIPR.reconAddToPlan(recAlg,hData.var.nSteps,hData.var.nLoops);
    end % addToPlanER
       
    function resetRecon(~,~)
        hIPR.resetIPR();
    end % resetRecon
    
    function runRecon(~,~)
        hIPR.reconRunPlan();
        h.main.figure.Pointer = 'arrow';
        hIPR.go.figure(1).Pointer = 'arrow'; drawnow;
    end % runRecon

    function calcTransferFunction(~,~)
%         [hData.radial.average, hData.radial.px] = rmean(...
%             rImg, [1, 512], rCenter);
        [Wmean, px] = rmean(abs(hIPR.W));
        MASK = hIPR.MASK;
        MASK(~MASK) = nan;
        [AMPmean, px] = rmean(abs(hIPR.WS.*MASK));
        TF = Wmean./AMPmean;
        theta = atan( px/hIPR.binFactor *75e-6/0.370 );
        q = 4*pi/1.24e-9 * sin(theta/2);
        res = 2*pi./q/2;

%         [TF2, px] = rmean(abs(hIPR.W-hIPR.WS)./abs(hIPR.W+hIPR.WS).*MASK);
        [TF2, px] = rmean((abs(hIPR.W)-abs(hIPR.WS))./(abs(hIPR.W) + abs(hIPR.WS)).*MASK);
        TF3 = (Wmean-AMPmean)./(Wmean+AMPmean);
        if ~isfield(h, 'tf') || ~isgraphics(h.tf.figure)
            h.tf.figure = figure(6623);
            h.tf.axes = axes(h.tf.figure);
            h.tf.plot = plot(h.tf.axes, nan);
            h.tf.xline = xline(h.tf.axes, 0, '--', 'Color', [0.4660 0.6740 0.1880]);
            h.tf.yline = yline(h.tf.axes, 0.5, 'r--');
            xlabel('scattering vector q in nm^{-1}')
            ylabel('transfer function TF(q)')
        end
        h.tf.plot.XData = q;
        h.tf.plot.YData = 1-TF2;
        h.tf.axes.XLim = [0, max(h.tf.plot.XData)];
        h.tf.axes.YLim(1) = 0;
        resIdx = find(h.tf.yline.Value>h.tf.plot.YData, 1);
        qRes = q(resIdx);
        resolution = res(resIdx);
        h.tf.xline.Value = qRes;
        h.tf.xline.Label = sprintf('%.1fnm', resolution*1e9);
        
%         semilogy(q, Wmean, q, AMPmean)

% figure; imagesc(abs(hIPR.W)./abs(hIPR.WS))
        
    end

    function centerShapeAndRecon(~,~,reconMethod,doCenter,doShape,shotSelector,dopant)
        h.main.figure.UserData.isRegisteredEscape = false;

        doRecon = ~isempty(reconMethod);
        doSavePattern = false;
        doSaveCentering = false;
        doSaveShape = false;
        doSaveRadialProfiles = false;
        doFilterForResolution = false;
        doComputeSNR = false;
        doCopyFigure = doShape & doRecon;


        doDoubleShape = false;
        doShapeManualFalse = false;

        doCenter = false;
%         clear dopant
        if ~exist('dopant', 'var')
            dopant = {'Ag', 'Xe', 'CH3I', 'CH3CN'};
        end

        if ~isempty(reconMethod)
            doRecon = true;
            if ~isfield(hRecon, 'parameter') || (numel(hRecon)>=hit && (~isfield(hRecon(hit).parameter, 'run') || hRecon(hit).parameter.run ~= run))
                clear hRecon;
                hRecon = [];
            end
        end

        switch shotSelector
            case 'shot'
                allRuns = false;
                allShots = false;
            case 'run'
                allRuns = false;
                allShots = true;
            case 'all'
                allRuns = true;
                allShots = true;
            otherwise
                return
        end
        
        if allRuns
            runList = [];
            skipRuns = [283, 363, 364]; % empty Xe
            skipRuns = [skipRuns, 294, 307, 373, 374, 408, 409, 467]; % empty Ag
            for thisRun = run:489
                if any(thisRun == skipRuns)
                    continue
                end
                if ~any(strcmpi(db.runInfo(thisRun).doping.dopant, dopant))
                    continue
                end
                if db.runInfo(thisRun).isData
                    runList = [runList, thisRun]; %#ok<AGROW>
                end
            end
        else
            runList = run;
        end
        
        for thisRun = runList
            
%             doCenter = iif(thisRun<288, true, false);
%             doCenter = iif(db.runInfo(run).shift == 3, true, false);
            
            if run ~= thisRun
                if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
%                 saveDataBaseFcn();
                if doRecon
                    if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                    saveRecon();
%                     saveDataBaseFcn();
                end
                if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                loadNextFile([],[],paths.pnccd, thisRun,1);
                hit = 1;
                if doRecon
                    clear hRecon;
                    hRecon = [];
                    loadRecon();
                end
            end
            
            if allShots
                nHits = numel(db.runInfo(thisRun).nlit_smooth);
                if nHits<1, continue; end
                hitList = hit:nHits;
%                 invalidShots = ~[db.shape(thisRun).shape.valid];
%                 shapeData = [db.shape(thisRun).shape.data];
%                 smallShots = [shapeData.a]<5;
%                 hitList(invalidShots(1:nHits) | smallShots (1:nHits)) = [];
%                 if ~doRecon
%                     hitList(hitList<hit) = [];
%                 end
                if doRecon
                    hitList = [];
                    for jHit=hit:numel(db.runInfo(thisRun).nlit_smooth)
                        if ~db.shape(thisRun).shape(jHit).valid, continue; end
                        if (db.runInfo(thisRun).nlit_smooth(jHit) < hData.par.litPixelThreshold), continue; end
                        if (db.data(thisRun).nPhotons(jHit) < hData.par.nPhotonsThreshold), continue; end
                        if (db.shape(thisRun).shape(jHit).data.a < 5), continue; end
                        hitList = [hitList, jHit]; %#ok<AGROW>
                    end 
                end
            else
                hitList = hit;
            end

            for thisHit = hitList
                if db.runInfo(thisRun).nlit_smooth < hData.par.litPixelThreshold, continue; end
                if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                fprintf('------------------------------------------------\n')
                fprintf('Running %s reconstruction for run %d hit %d\n', reconMethod, thisRun, thisHit)
                fprintf('------------------------------------------------\n')

                hit = thisHit;
                try
                    if isnan(db.radial(run).data(hit).resolution_SNR_nm) || ...
                            ( 2*db.shape(run).shape(hit).R_nm < 3*db.radial(run).data(hit).resolution_SNR_nm )
                        if doFilterForResolution && doRecon
                                continue
                        end
                    end
                end

                
                h.ui.indexText.String = sprintf('%i/%i', hit, numel(pnccd.trainid));
                loadImageData();

                if doCenter
                    if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end

                    if ~isfield(hData.var,'centerRunMedian')
                        hData.var.centerList = reshape([db.center(run).center(hData.var.hitList).data], 2, []);
                        hData.var.centerRunMedian = median(hData.var.centerList, 2, 'omitnan')';
                    end
%                     hData.var.center = hData.var.centerRunMedian;
% %                     centerImgFcn([],[],[1 2 2], [1 .5 .25]);
%                     shiftStrength = linspace(1,0.1,10);
%                      hData.var.center(1) = hData.var.center(1) + hData.par.addGap/2;
                    centerImgFcn();
%                     hData.var.center = hData.var.center - 1;
%                     centerImgFcn([],[],1,0)
                end


%                 hData.var.center = [534, 512];
%                 hData.img.dataCropped = centerAndCropFcn(...
%                     hData.img.dataCorrected, hData.var.center,...
%                     hData.par.interpolate);


                if doSavePattern, savePattern([],[],[430,344,260], hData.par.cMap); end

                if doShape
                    if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                    %                         centerImgFcn([],[],1,0)
%                     if numel(db.sizing(run).R) >= hit
%                         if ~isnan(db.sizing(run).R(hit))
%                             R_sizing = db.sizing(run).R(hit)*1e9;
%                         else 
%                             R_sizing = db.sizing(run).R_airy(hit)*1e9;
%                         end
%                         R_shape = db.shape(run).shape(hit).R;
%                         R_ratio = iif(R_shape>R_sizing, R_shape/R_sizing, R_sizing/R_shape);
%                         if R_ratio>1.2
%                             db.shape(run).shape(hit).R = R_sizing;
%                         end
%                     end
%                     if thisHit <= numel(db.sizing(run).R_fit) && ~isempty(db.sizing(run).R_fit(hit)) && ~isnan(db.sizing(run).R_fit(hit))
%                         db.shape(run).shape(hit).R = db.sizing(run).R_fit(hit)*1e9;
%                         fprintf('\t\t\tusing R_fit = %.0f\n', db.shape(run).shape(hit).R)
%                     end
                    if doShapeManualFalse, hData.shape.manual = false; end
                    findShapeFcn();
                    if doDoubleShape, findShapeFcn(); end

                    if doSaveShape
                        if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%% SAVING SHAPE
                        getSaveName('png');
                        savepath = fullfile(hSave.reconImageFolder, 'shape');
                        fprintf('\t\tsaving images in folder %s ...\n', savepath);
                        if ~exist(savepath,'dir'),mkdir(savepath); end
                        exportgraphics(h.shape(1).figure, fullfile(savepath, ...
                            ['shape1_', hSave.fileName]), 'Resolution', 150);
                        exportgraphics(h.shape(2).figure, fullfile(savepath, ...
                            ['shape2_', hSave.fileName]), 'Resolution', 150);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                    if doSaveCentering
                        if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                        centerImgFcn([],[],1,0)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%% SAVING CENTERING
                        getSaveName('png');
                        savepath = fullfile(hSave.reconImageFolder, 'centering');
                        fprintf('\t\tsaving images in folder %s ...\n', savepath);
                        if ~exist(savepath,'dir'),mkdir(savepath); end
                        exportgraphics(h.centering.figure, fullfile(savepath, ...
                            ['center_', hSave.fileName]), 'Resolution', 150);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                end
                if ~doSaveRadialProfiles && ~doRecon, continue; end

%                 if ~db.shape(thisRun).shape(hit).valid, continue; end

                if doComputeSNR, computeSNR(); end

                if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end

                if doRecon && doFilterForResolution
                    if isnan(db.radial(run).data(hit).resolution_SNR_nm) || ...
                            ( 2*db.shape(run).shape(hit).R_nm < 3*db.radial(run).data(hit).resolution_SNR_nm )
                        continue
                    end
                end
                updatePlotsFcn();
                
                if doSaveRadialProfiles, saveRadialProfile(); end

                if doRecon
                    if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                    computeDeconvolution();
                    initIPR();
                    switch reconMethod
                        case 'DCDI'
                            addToPlan([],[],'dcdi');
                        case 'NTDCDI'
                            addToPlan([],[],'ntdcdi');
                        otherwise
                            return
                    end
                    if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end

                    if ~doCopyFigure
                        runRecon();
                    else
                        copyImagesBeforeRecon();
                        runRecon();
                        copyImagesAfterRecon();

                        getSaveName('pdf');

                        if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end

                        savepath = fullfile(hSave.reconImageFolder, 'reconstructions');
                        fprintf('\t\tsaving images in folder %s ...\n', savepath);
                        if ~exist(savepath,'dir'),mkdir(savepath); end
                        exportgraphics(h.imagecopies.figure, fullfile(savepath, ...
                            ['+', hSave.fileName]), 'Resolution', 300);
                        fprintf('\t\t\tdone!\n')
                    end
                    
                    fprintf('\t\tadding hit to hRecon ...\n')

                    addHitToRecon();
                    fprintf('\t\t\tdone!\n')

                    if h.main.figure.UserData.isRegisteredEscape, fprintf('Loop aborted by user.\n'); unregisterKeys(h.main.figure); return; end
                    hIPR.go.doSaveIPRImages = true;
                    saveImgFcn();

                end
            end
        end
        if doRecon && allShots, saveRecon(); end
        if allShots, saveDataBaseFcn(); end
    end


    function copyImagesBeforeRecon()
        
        if ~isfield(h, 'imagecopies')
            h.imagecopies.figure = gobjects(1);
        end
        if ~isgraphics(h.imagecopies)
            h.imagecopies.figure = getFigure(h.imagecopies.figure, 'NumberTitle', 'off', ...
                'Name', 'image copy figure');
            clf(h.imagecopies.figure);
            nAxes = 6;
            ax = gobjects(1,nAxes);
            tl=tiledlayout('flow', 'parent', h.imagecopies.figure);
            for i=1:nAxes
                ax(i) = nexttile(tl);
            end
            h.imagecopies.axespositions = {ax.Position};
            
%             h.imagecopies.axes = gobjects(1,nAxes);
%             h.imagecopies.img = gobjects(1,nAxes);
%             h.imagecopies.tl = tiledlayout('flow', 'Parent', h.imagecopies.figure);
%
%             for iAx = 1:nAxes
%                 h.imagecopies.axes(iAx) = nexttile(h.imagecopies.tl);
%                 h.imagecopies.img(iAx) = imagesc(h.imagecopies.axes(iAx), nan);
%             end
        end
        clf(h.imagecopies.figure);
        
        h.imagecopies.axes(4) = copyobj(h.shape(2).axes(2), h.imagecopies.figure);
        colorbar(h.imagecopies.axes(4))
%         h.imagecopies.axes(2) = copyobj(hIPR.go.axes(4), h.imagecopies.figure);
%         colorbar(h.imagecopies.axes(2))
%         h.imagecopies.axes(3) = copyobj(hIPR.go.axes(6), h.imagecopies.figure);
%         h.imagecopies.axes(3).Title.String = 'inversion';
        h.imagecopies.axes(3) = copyobj(h.deconvolution.axes(3), h.imagecopies.figure);
        h.imagecopies.axes(3).Title.String = 'deconvolution';

        colorbar(h.imagecopies.axes(3))
    end

    function computeSNR(~,~)
        
%         computeRadialProfile();
        computeGuinierProfile();
                
%         fitResults = guinierFitFcn(db.radial(run).data(hit).q_nm, db.radial(run).data(hit).averageMovMean10, ...
%         db.shape(run).shape(hit).R_nm*1e-9, 100,  1e-4);
%         figure(6334); clf
%         semilogy(fitResults, db.radial(run).data(hit).q_nm, db.radial(run).data(hit).average);
%         plot(db.radial(run).data(hit).q_nm, db.radial(run).data(hit).averageMovMean10);
%         hold on;
%         plot( db.radial(run).data(hit).q_nm, guinier(db.radial(run).data(hit).q_nm, fitResults.a, fitResults.b, fitResults.c))
%         set(gca, 'YScale', 'log')
%         
        
        % subtracting base level
        db.radial(run).data(hit).averageBaseLevel = 0; %max([1e-3, min(db.radial(run).data(hit).averageMovMean10)]);
        db.radial(run).data(hit).averageBaseLevel = db.sizing(run).fit(hit).fit.c;
%         db.radial(run).data(hit).averageBaseLevel = mean(db.radial(run).data(hit).averageMovMean10(end-30:end));
        if db.radial(run).data(hit).averageBaseLevel > 0
            db.radial(run).data(hit).average = db.radial(run).data(hit).average - db.radial(run).data(hit).averageBaseLevel;
            db.radial(run).data(hit).average(db.radial(run).data(hit).average<0) = 0;
            db.radial(run).data(hit).averageMovMean10 = db.radial(run).data(hit).averageMovMean10 - db.radial(run).data(hit).averageBaseLevel;
            db.radial(run).data(hit).averageMovMean10(db.radial(run).data(hit).averageMovMean10<0) = 0;
        end
%         disp(db.radial(run).data(hit).averageBaseLevel)
        % calculate Shannon SNR
%         nShapes = 10;
%         gammaShades = 1/nShapes;
        % additional 1/sqrt(2) because half of the intensities area missing!
        db.radial(run).data(hit).dqShannon = pi/sqrt(2)/hData.var.radiusInNm/sqrt(2);
        
        db.radial(run).data(hit).intensityPerShannonPx = (hData.radial.average)/hData.const.dq^2*db.radial(run).data(hit).dqShannon^2;
        db.radial(run).data(hit).snrShannon = 2*sqrt(db.radial(run).data(hit).intensityPerShannonPx);
%         db.radial(run).data(hit).snrShannon = db.radial(run).data(hit).snrShannon-min(db.radial(run).data(hit).snrShannon);
%         db.radial(run).data(hit).snrShannonMovMean10 = movmean(db.radial(run).data(hit).snrShannon, 5);
        db.radial(run).data(hit).snrShannonMovMean10 = 2*sqrt(db.radial(run).data(hit).averageMovMean10)/hData.const.dq*db.radial(run).data(hit).dqShannon;

        backgroundLevel = mean(db.radial(run).data(hit).snrShannonMovMean10(end-50:end), 'omitnan');
        if isnan(backgroundLevel), backgroundLevel = 0; end
        backgroundLevel = 0;
        db.radial(run).data(hit).snrShannonMovMean10 = db.radial(run).data(hit).snrShannonMovMean10 - backgroundLevel;
        
        snr = 5;
        db.radial(run).resolution(hit).idx_SNR_shannon = find(db.radial(run).data(hit).snrShannonMovMean10 >= (snr/2)^2, 1, 'last');
        
        % FOR rebinning with factor 0.5:
        % because dq -> 2dq a factor of 4 
        db.radial(run).resolution(hit).idx_SNR = find(db.radial(run).data(hit).averageMovMean10 * 4 > (snr/2)^2, 1, 'last');
        
        if isempty(db.radial(run).resolution(hit).idx_SNR_shannon)
            db.radial(run).resolution(hit).idx_SNR_shannon = nan;
            db.radial(run).data(hit).resolution_SNR_shannon_nm = nan;
        else
            db.radial(run).data(hit).resolution_SNR_shannon_nm = db.radial(run).data(hit).nm(db.radial(run).resolution(hit).idx_SNR_shannon);
        end
        if isempty(db.radial(run).resolution(hit).idx_SNR)
            db.radial(run).resolution(hit).idx_SNR = nan;
            db.radial(run).data(hit).resolution_SNR_nm = nan;
        else
            db.radial(run).data(hit).resolution_SNR_nm = db.radial(run).data(hit).nm(db.radial(run).resolution(hit).idx_SNR);
        end
        
%         % PLOTTING
%         rMinimas = hData.minimaPositionsInPixel;
%         rMinimas(isnan(rMinimas)) = [];
%         phi = [linspace(0,2*pi,50),nan];
%         ringx = [];
%         ringy = [];
%         for ir = 1:numel(rMinimas)
%             ringx = [ringx, rCenter(2)+ rMinimas(ir)*cos(phi)];
%             ringy = [ringy, rCenter(1)+ rMinimas(ir)*sin(phi)];
%         end
        if ~isfield(h,'radial') || ~isfield(h.radial,'figure')
            h.radial.figure = gobjects(1);
        end
        if ~isgraphics(h.radial.figure)
            h.radial.figure = figure(2343); clf
            h.radial.ax = axes(h.radial.figure);
            h.radial.plt(1) = semilogy(h.radial.ax, nan, nan, '.', 'DisplayName', 'radial profile ');
            hold(h.radial.ax, 'on');
            h.radial.plt(2) = semilogy(h.radial.ax, nan, nan, '--', 'DisplayName', 'mov mean 10 ');
            h.radial.plt(3) = semilogy(h.radial.ax, nan, nan, '-.', 'DisplayName', 'Shannon SNR ');
            h.radial.plt(4) = semilogy(h.radial.ax, nan, nan, 'DisplayName', 'SNR for bin=0.5 ');
            h.radial.plt(3).Color = colorOrder(5);
            h.radial.xl(1) = xline(h.radial.ax, 0, 'LineStyle', '--', 'LineWidth', 1.5);
            h.radial.xl(2) = xline(h.radial.ax, 0, 'LineStyle', '--', 'LineWidth', 1.5);
%             h.radial.yl(1) = yline(h.radial.ax, 0, 'LineStyle', '--', 'LineWidth', 1);
%             h.radial.yl(2) = yline(h.radial.ax, 0, 'LineStyle', '--', 'LineWidth', 1);
            xlabel(h.radial.ax, 'q in nm$^{-1}$', 'Interpreter', 'latex')
            ylabel(h.radial.ax, 'photons/bin', 'Interpreter', 'latex')
            legend(h.radial.ax, 'location', 'east')
        end
        
        h.radial.plt(1).XData = db.radial(run).data(hit).q_nm*1e-9;
        h.radial.plt(1).YData = db.radial(run).data(hit).average;
        h.radial.plt(2).XData = db.radial(run).data(hit).q_nm*1e-9;
        h.radial.plt(2).YData = db.radial(run).data(hit).averageMovMean10;
%         h.radial.plt(2).YData = guinier(db.radial(run).data(hit).q_nm, fitResults.a, fitResults.b, 0);
        h.radial.plt(3).XData = db.radial(run).data(hit).q_nm*1e-9;
        h.radial.plt(3).YData = db.radial(run).data(hit).snrShannonMovMean10;
        h.radial.plt(4).XData = db.radial(run).data(hit).q_nm*1e-9;
        h.radial.plt(4).YData = db.radial(run).data(hit).averageMovMean10*4;
        
        if ~isnan(db.radial(run).resolution(hit).idx_SNR_shannon)
            h.radial.xl(1).Value = 1e-9*db.radial(run).data(hit).q_nm(db.radial(run).resolution(hit).idx_SNR_shannon);
        else
            h.radial.xl(1).Value = 0; % xline.Value can not be nan
        end
        if ~isnan(db.radial(run).resolution(hit).idx_SNR)
            h.radial.xl(2).Value = 1e-9*db.radial(run).data(hit).q_nm(db.radial(run).resolution(hit).idx_SNR);
        else
            h.radial.xl(2).Value = 0; % xline.Value can not be nan
        end
        h.radial.xl(1).Label = sprintf('Shannon = %.2gnm', db.radial(run).data(hit).resolution_SNR_shannon_nm);
%         h.radial.xl(1).DisplayName = 'SNR=5 for Shannon ';
        h.radial.xl(1).Color = h.radial.plt(3).Color;
        h.radial.xl(2).Label = sprintf('bin=0.5 = %.2gnm', db.radial(run).data(hit).resolution_SNR_nm);
%         h.radial.xl(2).DisplayName = 'SNR=5 for bin=0.5';
        h.radial.xl(2).LabelVerticalAlignment = 'bottom';
        h.radial.xl(2).Color = h.radial.plt(4).Color;
        h.radial.yl(1).Value = 5;
        h.radial.yl(1).Label = sprintf('SNR = %.0f', 5);
        h.radial.yl(1).DisplayName = 'SNR = 5';
        h.radial.yl(2).Value = 10;
        h.radial.yl(2).Label = sprintf('SNR = %.0f', 10);
        h.radial.yl(2).DisplayName = 'SNR = 10';
        h.radial.ax.XLim = [0,h.radial.plt(1).XData(end)];
        h.radial.ax.YLim(1) = 1e-4;
        h.radial.legend = legend(h.radial.ax, {h.radial.plt(1).DisplayName, h.radial.plt(2).DisplayName, h.radial.plt(3).DisplayName, h.radial.plt(4).DisplayName}, 'Location', 'northeast');
        h.radial.legend.Location = 'northoutside';
        h.radial.legend.Orientation = 'horizontal';
        h.radial.ax.Units = 'centimeters';
        h.radial.ax.Legend.Units = 'centimeters';
        h.radial.ax.Position(3) = h.radial.ax.Legend.Position(3);
        h.radial.ax.FontSize = 10;
        drawnow;

        % saving SNR profiles
        pbaspect(h.radial.ax, [sqrt(3) 1 1])
%         getSaveName('pdf');
%         savepath = fullfile(hSave.reconImageFolder, 'radial_profiles');
%         fprintf('\t\tsaving radial profile in folder %s ...\n', savepath);
%         if ~exist(savepath,'dir'),mkdir(savepath); end
%         exportgraphics(h.radial.ax, fullfile(savepath, hSave.fileName));
    end


    function computeRadialProfile()

        rImg = hData.img.dataCorrected;
        rImg(rImg<0.0) = 0;
        rImg(rImg>100) = nan;
        %         rImg = rImg - nanmean(rImg(rImg<1));
        imgSize = size(rImg);
        rCenter = db.center(run).center(hit).data;
        %         hData.img.radial.wedgeMask = [];
        if isempty(hData.img.radial.wedgeMask)
            hGapPx = hData.var.gapSize/2;
            %             wedgeAngles = [-15 15; 165 -165;-15 15; 165 -165; -105 -75 ; 75 105]/180*pi;
            wedgeAngle = 30;
            wedgeAngles = [0 0; 180 -180; 0 0; 180 -180]/180*pi ...
                + [-1 1; -1 1; -1 1; -1 1]*wedgeAngle/180*pi;
            wedgeAngles2 = [0 0; 180 -180; 0 0; 180 -180; 90 90; 90 90; -90 -90; -90 -90]/180*pi ...
                + [-1 1; -1 1; -1 1; -1 1; -1 1; -1 1; -1 1; -1 1]*wedgeAngle/2/180*pi;
            wedgeAngles = wedgeAngles2;
            wedgeCenters = [hGapPx 0; hGapPx 0; -hGapPx 0; -hGapPx 0; 0 0; 0 0];
            wedgeCenters2 = [hGapPx 0; hGapPx 0; -hGapPx 0; -hGapPx 0; 0 0; 0 0; 0 0; 0 0; 0 -hGapPx; 0 hGapPx; 0 -hGapPx; 0 hGapPx;0 0; 0 0];
            wedgeCenters = wedgeCenters2;
            wedgeCenters(:,1) = rCenter(1)+wedgeCenters(:,1);
            wedgeCenters(:,2) = rCenter(2)+wedgeCenters(:,2);
            hData.img.radial.wedgeMask = computeRadialMask(imgSize, wedgeAngles, wedgeCenters);
        end
        % figure(33455); imagesc(hData.img.radial.wedgeMask)
        rImg(hData.img.radial.wedgeMask(:)<1) = nan;
        %         rImg(size(rImg,1)/2+1:end,:) = nan;
        %         rImg(1:size(rImg,1)/2,:) = nan;
        %         rImg(:,size(rImg,2)/2+1:end) = nan;
        [hData.radial.average, hData.radial.px] = rmean(...
            rImg, [1, 512], rCenter);
        %         disp(var(hData.radial.average, 'omitnan'))
        %         figure(88672); imagesc(log10(rImg));

        % normalization on solid angle : dOmega=(dq/k)^2=A_px/det_dist^2
        % (dq)^2 = k^2 * dOmega

        % calculation per Shannon pixel dq=2pi/(s*2R)=pi/sR, with droplet
        % radius R and oversampling ratio s=>2^(1/dim)=2^(1/2)=sqrt(2)

        %         hData.radial.average = hData.radial.average/hData.const.dq^2;
        %         hData.radial.average = hData.radial.average*db.radial(run).data(hit).dqShannon^2;
        %         hData.radial.average = hData.radial.average/hData.const.dq*db.radial(run).data(hit).dqShannon;
        %         disp(db.radial(run).data(hit).dqShannon/hData.const.fel.k*hData.const.detector.dist/hData.const.detector.px)

        db.radial(run).data(hit).average = hData.radial.average;
        db.radial(run).data(hit).px = hData.radial.px;
        db.radial(run).data(hit).q_nm = db.radial(run).data(hit).px * hData.const.dq;
        db.radial(run).data(hit).nm = 1.2398e-9 ./ ( 4*sin(atan(db.radial(run).data(hit).px*75e-6/2/0.37)) ) * 1e9;
        db.radial(run).data(hit).averageMovMean10 = movmean(db.radial(run).data(hit).average, 10);
    end

    function computeGuinierProfile()
% %         % saving SNR profiles
        computeRadialProfile();
% %         pbaspect(h.radial.ax, [sqrt(3) 1 1])
% %         getSaveName('pdf');
% %         savepath = fullfile(hSave.reconImageFolder, 'radial_profiles');
% %         fprintf('\t\tsaving radial profile in folder %s ...\n', savepath);
% %         if ~exist(savepath,'dir'),mkdir(savepath); end
% %         exportgraphics(h.radial.ax, fullfile(savepath, hSave.fileName));
% % %         saveax(h.radial.ax, fullfile(savepath, hSave.fileName));


        % computing guinier profile
        q = db.radial(run).data(hit).q_nm*1e-9;
        rprof = db.radial(run).data(hit).average;
%         rprofMean = db.radial(run).data(hit).averageMovMean10; 
        R_shape = db.shape(run).shape(hit).R_nm;
        R_sizing = db.sizing(run).R(hit)*1e9;
%         R_sizing = iif(~isnan(R_sizing), R_sizing, db.sizing(run).R_guinier(hit)*1e9/1.03);
        if isnan(R_sizing), R_sizing = db.sizing(run).R_airy(hit)*1e9/1.22*1.43; end
%         R_sizing = db.sizing(run).R(hit)*1e9;
        
        compareProfile = db.radial(run).data(hit).average;
%         [minVal, ~] = min(compareProfile(compareProfile>0));
%         minVal = 1e-3;
%         minVal = max([1e-2, min(compareProfile)]);
        minVal = min(compareProfile(compareProfile>0));
%         compareProfile = compareProfile - minVal;
%         rmin = 80;
%         [maxVal, maxIdx] = max(compareProfile(rmin:end));
%         maxIdx=maxIdx+rmin-1;
%         qmin = 0.08;
        for qmin = 0.08:-0.01:0.06
            finitVals = ~isnan(compareProfile) & q>qmin;
            compareSum = sum(compareProfile(finitVals));

            [gfit, gof] = guinierFitFcn(q(finitVals), compareProfile(finitVals), R_shape, 1, minVal, nan);
%             minVal = gfit.c;
            guinierFit = guinierFromFit(q, gfit);
%             guinierFit = guinierFit + minVal;
            %         guinierFit = guinier(q, gfit.a, gfit.b, gfit.c, gfit.d);

            guinierShape = guinier(q, R_shape);
            guinierShape = guinierShape/sum(guinierShape(finitVals) + minVal)*compareSum;
            guinierShape = guinierShape + minVal;

            guinierSizing = guinier(q, R_sizing);
            guinierSizing = guinierSizing/sum(guinierSizing(finitVals) + minVal)*compareSum;
            guinierSizing = guinierSizing + minVal;

            R_fit = gfit.a;

            R_diff = abs(R_fit-R_shape)/(R_fit+R_shape);
            fprintf('\t\t\tqmin=%.2f, R_shape=%.0f, R_fit=%.0f, R_diff=%.2f\n', qmin, R_shape, R_fit, R_diff)
            if numel(db.sizing(run).fit)>=hit && ~isempty(db.sizing(run).fit(hit).gof)
                fprintf('\t\t\t\t\tsse = %.2f\t\trsquare = %.3f\t\tdfe = %.0f\t\tadjrsquare = %.3f\t\trmse = %.3f\n', ...
                    db.sizing(run).fit(hit).gof.sse, db.sizing(run).fit(hit).gof.rsquare, db.sizing(run).fit(hit).gof.dfe, db.sizing(run).fit(hit).gof.adjrsquare, db.sizing(run).fit(hit).gof.rmse)
            else
                fprintf('\t\t\t\t\tdb.sizing(run).fit(hit).gof is empty!\n')
            end
            if R_diff<=0.1
                break;
            end
        end
        db.sizing(run).R_fit(hit) = R_fit*1e-9;
        db.sizing(run).R_fit_nm(hit) = R_fit;
        db.sizing(run).fit(hit).fit = gfit;
        db.sizing(run).fit(hit).gof = gof;


        % plotting
        if ~isgraphics(h.guinier.figure)
            h.guinier.figure = getFigure(h.guinier.figure, 'NumberTitle', 'off', ...
                'Name', 'guinier figure');
            clf(h.guinier.figure);
            hUnits = h.guinier.figure.Units;
            h.guinier.figure.Units = 'pixels';
            % h.guinier.figure.Position = [2561	391.4	1080	598.4];
            h.guinier.figure.Position(3:4) = [1080	598.4];
            h.guinier.figure.Units = hUnits;
            h.guinier.axes = axes(h.guinier.figure);
            h.guinier.plt(1) = semilogy(h.guinier.axes, q, rprof, '.', 'DisplayName', 'radial profile');
            h.guinier.axes.NextPlot = 'add';
            h.guinier.plt(2) = plot(h.guinier.axes, q, guinierSizing, ':', 'DisplayName', 'guinier (minima)', 'Color', colorOrder(4));
            h.guinier.plt(3) = plot(h.guinier.axes, q, guinierShape, '--', 'DisplayName', 'guinier (AC)', 'Color', colorOrder(5));
            h.guinier.plt(4) = plot(h.guinier.axes, q, guinierFit, '-.', 'DisplayName', 'guinier (fit)', 'Color', colorOrder(2));
            xlabel(h.guinier.axes, 'scattering vector $q$ in nm$^{-1}$', 'Interpreter', 'latex')
            ylabel(h.guinier.axes, 'scattering intensity $I(q)$ in a.u.', 'Interpreter', 'latex')
            grid(h.guinier.axes, 1);
            pbaspect(h.guinier.axes, [sqrt(3) 1 1]);
            h.guinier.axes.FontSize = 9;
            h.guinier.ax.Units = 'centimeters';
            h.guinier.ax.Position(3) = 13;
            h.guinier.xline = xline(h.guinier.axes, qmin, '--', 'FontSize', h.guinier.axes.FontSize);
            legend([h.guinier.plt], {h.guinier.plt.DisplayName}, 'location', 'northeast')
            %         legend([h.guinier.plt([1,3,4])], {h.guinier.plt.DisplayName}, 'location', 'northeast')
        end

        %         h.guinier.plt(2).Visible = 1;
        %         h.guinier.plt(3).Visible = 1;
        h.guinier.plt(2).Visible = 0;

        % %         h.guinier.plt(3).Visible = 0;
%         legend([h.guinier.plt([1,3,4])], {h.guinier.plt.DisplayName}, 'location', 'northeast')

        h.guinier.plt(1).XData = q;
        h.guinier.plt(1).YData = rprof;
        h.guinier.plt(2).XData = q;
        h.guinier.plt(2).YData = guinierSizing;
        h.guinier.plt(3).XData = q;
        h.guinier.plt(3).YData = guinierShape;
        h.guinier.plt(4).XData = q;
        h.guinier.plt(4).YData = guinierFit;
        h.guinier.axes.XLim = q([1,end]);
        h.guinier.axes.YLim = [minVal/2, guinierShape(1)*1.5];
        h.guinier.plt(2).DisplayName = sprintf('R=%.0fnm (min)', R_sizing);
        h.guinier.plt(3).DisplayName = sprintf('R=%.0fnm (AC)', R_shape);
        h.guinier.plt(4).DisplayName = sprintf('R=%.0fnm (fit)\n\tr^2=%.2f', R_fit, db.sizing(run).fit(hit).gof.rsquare);
        h.guinier.xline.Value = qmin;       

        drawnow;

    end

    function saveRadialProfile()

        % saving
        getSaveName('png');
        savepath = fullfile(hSave.reconImageFolder, 'radial_profiles');
        fprintf('\t\tsaving radial profile in folder %s ...\n', savepath);
        if ~exist(savepath,'dir'),mkdir(savepath); end
        saveax(h.guinier.axes, fullfile(savepath, ['guinier_', hSave.fileName]), '-r150');
    end

    function copyImagesAfterRecon()
        h.imagecopies.axes(2) = copyobj(hIPR.go.axes(4), h.imagecopies.figure);
        colorbar(h.imagecopies.axes(2))

        h.imagecopies.axes(1) = copyobj(hIPR.go.axes(2), h.imagecopies.figure);
        pbaspect(h.imagecopies.axes(1), [const.goldenRatio, 1, 1])
        h.imagecopies.axes(1).Title.String = sprintf('run %03d - hit %03d - id %d', run, hit, pnccd.trainid(hit));
        h.imagecopies.axes(2).Title.String = sprintf('%s, T=%.1fK, p=%.0fbar', db.doping(run).dopant, db.runInfo(run).source.T, db.runInfo(run).source.p);
        h.imagecopies.axes(5) = copyobj(hIPR.go.axes(3), h.imagecopies.figure);
        colorbar(h.imagecopies.axes(5))
        h.imagecopies.axes(5).Title.String = sprintf('%d steps, $E_{F}$=%.3g, $E_{R}$=%.3g', hIPR.nTotal, hIPR.errors(1,hIPR.nTotal-1), hIPR.errors(2,hIPR.nTotal-1));
        if hIPR.plotting.drawDroplet
            h.imagecopies.axes(7) = copyobj(hIPR.go.droplet.axes(2), h.imagecopies.figure);
%             h.imagecopies.axes(7).Position = h.imagecopies.axespositions{6};
            h.imagecopies.axes(7).Title.String = 'DCDI reconstruction';
            h.imagecopies.axespositions{7} = h.imagecopies.axespositions{6};
        end
        h.imagecopies.axes(6) = copyobj(hIPR.go.axes(6), h.imagecopies.figure);
        h.imagecopies.axes(6).Title.String = sprintf('DCDI reconstruction');
        colorbar(h.imagecopies.axes(6))
        h.imagecopies.axes(3).XLim = h.imagecopies.axes(6).XLim;
        h.imagecopies.axes(3).YLim = h.imagecopies.axes(6).YLim;
        if ~hIPR.plotting.drawDroplet
            h.imagecopies.axes(6).Title.String = 'DCDI reconstruction';
        end
        
        nAxes = numel(h.imagecopies.axes);       
        for iAx = 1:nAxes
            h.imagecopies.axes(iAx).Units = 'normalized';
            h.imagecopies.axes(iAx).Position = h.imagecopies.axespositions{iAx};
        end
    end

    function saveRecon()
        if exist('hRecon','var') && ~isempty(hRecon)
            reconFullFileName = fullfile(paths.recon, ...
                sprintf('r%03d_recon_%s.mat', run, db.runInfo(run).doping.dopant{:}));
            if ~exist(paths.recon, 'dir'), mkdir(paths.recon); end
            fprintf('\tsaving recon in %s ...\n', reconFullFileName);
            
            save(reconFullFileName, 'hRecon');
            fprintf('\t\tdone!\n');
        else
            fprintf('hRecon is empty and was not saved\n')
        end
    end

    function loadRecon()
        reconFullFileName = fullfile(paths.recon, ...
            sprintf('r%03d_recon_%s.mat', run, db.runInfo(run).doping.dopant{:}));
        clear hRecon;
        if exist(reconFullFileName, 'file')
            load(reconFullFileName, 'hRecon');
        end
    end

    function addHitToRecon()
        
        hRecon(hit).w = gather(hIPR.w);
        hRecon(hit).ws = gather(hIPR.ws);
        hRecon(hit).W = gather(hIPR.W);
        hRecon(hit).WS = gather(hIPR.WS);
        hRecon(hit).rho = gather(hIPR.rho);
        hRecon(hit).rho0 = gather(hIPR.rho0);
        hRecon(hit).AMP0 = gather(hIPR.AMP0);
        hRecon(hit).dropletOutline = gather(hIPR.dropletOutline);
        hRecon(hit).oneshot = gather(hIPR.oneshot);
        hRecon(hit).ONESHOT = gather(hIPR.ONESHOT);
        hRecon(hit).errors = gather(hIPR.errors);
        hRecon(hit).MASK = gather(hIPR.MASK);
        hRecon(hit).dopant = gather(db.runInfo(run).doping.dopant{:});
        
        R_px = mean([db.shape(run).shape(hit).data.a,db.shape(run).shape(hit).data.b])/2;
        yLims = size(hData.img.deconvolution,1)/2 + 1 + round([-1,1]*R_px*1.5 + [0,-1]);
        xLims = size(hData.img.deconvolution,2)/2 + 1 + round([-1,1]*R_px*1.5 + [0,-1]);
        hRecon(hit).deconvolution = hData.img.deconvolution(yLims(1):yLims(2),xLims(1):xLims(2));
        
%         hRecon(hit).radial.average = hData.radial.average;
%         hRecon(hit).radial.px = hData.radial.px;
        
        parameter.run = run;
        parameter.hit = hit;
        parameter.T = db.runInfo(run).source.T;
        parameter.p = db.runInfo(run).source.p;
        parameter.delay = db.runInfo(run).source.delayTime;
        parameter.R_px = db.shape(run).shape(hit).R_nm/6;
        parameter.R_nm = db.shape(run).shape(hit).R_nm;
        parameter.a_nm = db.shape(run).shape(hit).a_nm;
        parameter.b_nm = db.shape(run).shape(hit).b_nm;
        parameter.rot = db.shape(run).shape(hit).data.rot;
        parameter.ar = db.shape(run).shape(hit).data.aspectRatio;
        parameter.center = db.center(run).center(hit);
        parameter.photonsOnDetector = db.data(run).nPhotons(hit);
        parameter.litPixel = db.runInfo(run).nlit_smooth(hit);
        parameter.dopant = db.runInfo(run).doping.dopant{:};
        parameter.depletion = nan;
        parameter.dopingPressure = nan;

        hRecon(hit).parameter = parameter;
    end
    %% Deconvolution Functions
    
    function computeDeconvolution(~,~)
        fprintf('\t\tdeconvolving ...\n')
        if ~isfield(h, 'deconvolution')
            h.deconvolution.figure = gobjects(1);
        end
        if ~isgraphics(h.deconvolution.figure)
            h.deconvolution.figure = getFigure(h.deconvolution.figure, 'NumberTitle', 'off', ...
                'Name', 'deconvolution figure');
            clf(h.deconvolution.figure);
            hUnits = h.deconvolution.figure.Units;
            h.deconvolution.figure.Units = 'pixels';
            % h.deconvolution.figure.Position = [2561	391.4	1080	598.4];
            h.deconvolution.figure.Position(3:4) = [1080	598.4];
            h.deconvolution.figure.Units = hUnits;
            h.deconvolution.axes = gobjects(1,4);
            h.deconvolution.img = gobjects(1,4);
        
            h.deconvolution.axes(1) = mysubplot(2,2,1, 'parent', h.deconvolution.figure);
            h.deconvolution.img(1) = imagesc(h.deconvolution.axes(1), nan);
            h.deconvolution.title(1) = title(h.deconvolution.axes(1), 'abs(deconvolution)');
            colorbar(h.deconvolution.axes(1));
            h.deconvolution.axes(2) = mysubplot(2,2,2, 'parent', h.deconvolution.figure);
            h.deconvolution.img(2) = imagesc(h.deconvolution.axes(2), nan);
            h.deconvolution.title(2) = title(h.deconvolution.axes(2), 'angle(deconvolution)');
            colorbar(h.deconvolution.axes(2));
            h.deconvolution.axes(3) = mysubplot(2,2,3, 'parent', h.deconvolution.figure);
            h.deconvolution.img(3) = imagesc(h.deconvolution.axes(3), nan);
            h.deconvolution.title(3) = title(h.deconvolution.axes(3), 'imag(deconvolution)');
            hold(h.deconvolution.axes(3), 'on');
            h.deconvolution.plt(3,1) = plot(h.deconvolution.axes(3), nan, nan, 'w--');
            h.deconvolution.plt(3,2) = rectangle(h.deconvolution.axes(3), 'Position', [0,0,.1,.1], 'Visible', 'off', 'Curvature', [1,1]);
            h.deconvolution.plt(3,3) = rectangle(h.deconvolution.axes(3), 'Position', [0,0,.1,.1], 'Visible', 'off', 'Curvature', [1,1]);
            colorbar(h.deconvolution.axes(3));
            h.deconvolution.axes(4) = mysubplot(2,2,4, 'parent', h.deconvolution.figure);
            h.deconvolution.img(4) = imagesc(h.deconvolution.axes(4), nan);         
            h.deconvolution.title(4) = title(h.deconvolution.axes(4), 'real(deconvolution)');
            colorbar(h.deconvolution.axes(4));
        end
        
        
        %%%%%%%%%%%
        % MASKING %
        %%%%%%%%%%%
        hData.deconvolution.masking.applyGapMask = 0;
        hData.deconvolution.masking.applyWedgeMask = 1;
        hData.deconvolution.masking.applyCenterMask = 0;
        hData.deconvolution.masking.applySmoothing = 0;
        hData.deconvolution.masking.showMask = 0;
        
        hData.deconvolution.par.minPhotons = 0;
        hData.deconvolution.par.minRadius = 0;
        hData.deconvolution.par.gapSize = 40;
        hData.deconvolution.par.wedgeAngle = 15;
        hData.deconvolution.par.dilutePx = 20;
        hData.deconvolution.par.smoothPx = hData.deconvolution.par.dilutePx*2;
        hData.deconvolution.par.diluteThreshold = 0.99; % not in use
        hData.deconvolution.par.useSimulatedData = 0;
        hData.deconvolution.par.scattRatio = 1;
        
        if hData.deconvolution.par.useSimulatedData
            hData.deconvolution.data.scattImg = hSimu.simData.scatt1;
        else
            hData.deconvolution.data.scattImg = hData.img.dataCropped;
        end
        hData.deconvolution.data.scattImg(hData.deconvolution.data.scattImg<hData.deconvolution.par.minPhotons) = 0;
        hData.deconvolution.data.mask = ~isnan(hData.deconvolution.data.scattImg);
        
        mask = ~isnan(hData.deconvolution.data.scattImg);
        imgSize = size(hData.deconvolution.data.scattImg);
        imgCenter = imgSize/2+1;
        
        % GAP mask
        if hData.deconvolution.masking.applyGapMask
            hGapPx = hData.deconvolution.par.gapSize/2;
            gapMask = mask;
            gapMask(imgCenter(1)-hGapPx-1:imgCenter(1)+hGapPx,:) = 0;
            %         gapMask(imgCenter(1)-hGapPx:imgCenter(1)+hGapPx-1,:) = 0;
            %         gapMask(imgCenter(1)-hGapPx:imgCenter(1)+hGapPx,:) = 0;
            mask(~gapMask) = 0;
        end

        % WEDGE mask
        if hData.deconvolution.masking.applyWedgeMask
            hGapPx = hData.deconvolution.par.gapSize/2;
            wedgeAngle = single(hData.deconvolution.par.wedgeAngle/180*pi);
            wedgeAngles = [0 0; 180 -180; 0 0; 180 -180]/180*pi ...
                + [-1 1; -1 1; -1 1; -1 1]*wedgeAngle;
            wedgeCenters = [hGapPx 0; hGapPx 0; -hGapPx 0; -hGapPx 0];
            wedgeCenters = wedgeCenters + imgCenter;
            wedgeMask = computeRadialMask(imgSize, wedgeAngles, wedgeCenters);
            mask(~wedgeMask) = 0;
        end
        
        % CENTER mask
        if hData.deconvolution.masking.applyCenterMask
            if ~isfield(hData.img, 'xx') || imgSize(1)~=size(hData.img.xx,1)
                [hData.img.xx, hData.img.yy] = meshgrid( (1:imgSize(2))-imgCenter(2), (1:imgSize(1))-imgCenter(1));
            end
            centerMask = hData.img.xx.^2 + hData.img.yy.^2 >= hData.deconvolution.par.minRadius.^2;
            mask(~centerMask) = 0;
        end
        
                               
        fieldScatt = hData.deconvolution.data.scattImg;
        fieldScatt = sqrt(abs(fieldScatt));
        
       
        
        if hData.deconvolution.masking.applySmoothing
            if isfield(db,'radial') && (hit<=numel(db.radial(run).data)) && ~isempty(db.radial(run).data(hit)) && isfield(db.radial(run).data(hit), 'resolution_SNR_nm') && ~isnan(db.radial(run).resolution(hit).idx_SNR) && ~isempty(db.radial(run).resolution(hit).idx_SNR)
                if ~isfield(hData.img, 'xx') || imgSize(1)~=size(hData.img.xx,1)
                    [hData.img.xx, hData.img.yy] = meshgrid( (1:imgSize(2))-imgCenter(2), (1:imgSize(1))-imgCenter(1));
                end
                hData.img.rr = sqrt(hData.img.xx.^2+hData.img.yy.^2);
                cutoffValue = db.radial(run).data(hit).px(db.radial(run).resolution(hit).idx_SNR);
                cutoff = hData.img.rr>cutoffValue;
                                
                fieldScatt(cutoff) = fieldScatt(cutoff) .* exp(-(hData.img.rr(cutoff)-cutoffValue).^2/2/cutoffValue.^2);
            end
                       
%             centerMask = hData.img.xx.^2 + hData.img.yy.^2 >= hData.deconvolution.par.minRadius.^2;
%         end
%             diluteMask = imdilate(double(~mask), offsetstrel('ball',hData.deconvolution.par.dilutePx,1));
%             filterMask = 2-diluteMask;
%             
% % %             diluteMask = imgaussfilt(double(mask), hData.deconvolution.par.dilutePx);
% % %             filterMask = diluteMask;
% % %             filterMask = 1-diluteMask;
%             
%             diluteMask = ~imdilate((~mask), strel('disk', hData.deconvolution.par.dilutePx));
% %             diluteMask = imgaussfilt(double(mask), hData.deconvolution.par.dilutePx) > hData.deconvolution.par.diluteThreshold;
%             filterMask = imgaussfilt(double(diluteMask), hData.deconvolution.par.smoothPx);
% 
%             fieldScatt = fieldScatt.*filterMask;
%             if hData.deconvolution.masking.showMask
%                 figure(35634); clf
%                 subplot(121); imagesc(mask); colorbar;
%                 subplot(122); imagesc(mask.*filterMask); colorbar;
%             end
        end

        fieldScatt(~mask) = 0;
        
        % END MASKING
        
        
        % DROPLET PARAMETER
        dropletOutline = hData.img.dropletOutline;
        
        dropletDensity = complex(hData.img.dropletdensity);
        R_nm = mean([db.shape(run).shape(hit).data.a,db.shape(run).shape(hit).data.b])/2*6;
%         dropletDensity = dropletDensity*8.424e-8 + 1i*dropletDensity*3.028e-5;
        fieldRef = ft2(dropletDensity);
        
        % SNR
        
%         if isfield(db,'radial') && (hit<=numel(db.radial(run).data)) && ~isempty(db.radial(run).data(hit)) && isfield(db.radial(run).data(hit), 'resolution_SNR_nm') && ~isempty(db.radial(run).data(hit).resolution_SNR_nm)
%             snr = 5;%db.radial(run).data(hit).resolution_SNR_shannon_nm;
            %         snr = 2*sqrt(scattImg);
%         else
%             snr = 2*fieldScatt;
%         end
%         snr = 2*fieldScatt;
        % DECONVOLUTION
        
        AMP0 = abs(fieldScatt);
        AMP0(~mask) = nan;
        imgSize = size(AMP0);
        imgCenter = imgSize/2+1;
        [radialAMP, ~] = rmean(AMP0, ceil(sqrt(2)*max(imgSize)/2+1));
        [xx, yy] = meshgrid( (1:imgSize(2))-imgCenter(2), (1:imgSize(1))-imgCenter(1));
        radialM = round(sqrt(xx.^2+yy.^2)+.5);
        radialM(radialM==0) = 1;
        avgAMP = radialAMP(radialM);

        snr = 2*sqrt(avgAMP);
        snr(isnan(snr)) = 0;
%         snr(avgAMP.^2>0.2) = 0.5;
%         snr = fieldScatt./snr;
        snr = 5;
        hData.deconvolution.par.scattRatio = 1;
        [fieldDeconvolved, fieldRef] = deconvolutionFcn(fieldScatt, fieldRef, mask, snr, hData.deconvolution.par.scattRatio);
        fieldDeconvolved(isnan(fieldDeconvolved)) = fieldRef(isnan(fieldDeconvolved));
%         fieldDeconvolved(isnan(fieldDeconvolved)) = 0;
        
%         [fieldDeconvolved, fieldRef] = setDropletPhase(scattImg, fieldRef, scattMask);
        
        imgDeconvolved = ift2(fieldDeconvolved);
        
        % removing density outside the droplet area for Plotting
%         imgDeconvolved(dropletDensity==0) = imgDeconvolved(dropletDensity==0)/2;
        
%             imR=real(imgDeconvolved);
%             imI=imag(imgDeconvolved);
%             imgDeconvolved=imR.*(imR>=0) +1i*imI.*(imI>=0);
                        
%             imRneg=imR.*(imR<0);
%             imRpos=imR.*(imR>=0);
%             imRnegFlipped=circshift(rot90(imRneg,2),[1,1]);
%             imRcor=imRpos-imRnegFlipped;
%             imIneg=imI.*(imI<0);
%             imIpos=imI.*(imI>=0);
%             imInegFlipped=circshift(rot90(imIneg,2),[1,1]);
%             imIcor=imIpos-imInegFlipped;
%             imgCorrected=imRcor+1i*imIcor;
            
%             imgCorrected=imRpos+1i*imIpos;
            
%             imSym=(imR.*imI)>=0;
%             imAsym=(imR.*imI)<0;
%             imNew1=(abs(imR) + 1i*abs(imI)).*imSym;
%             im2rot=(abs(imR) + 1i*abs(imI)).*imAsym;
%             imNew2=circshift(rot90(im2rot,2),[1 1]*1);
%             imgCorrected = ((imR.*imI).*((imR.*imI)>=0)) - 1i*circshift(rot90((imR.*imI).*((imR.*imI)<0),2),[1 1]);
%             imgCorrected=imNew1+imNew2;
%             imgCorrected=abs(imgCorrected).*exp(1i*abs(angle(imgCorrected)));
%             imgCorrected=(imR.*imI).*imgCorrected;
% %             imgCorrected=(imR.*imI).*imgCorrected;
            
%             imgCorrected = imR.*circshift(rot90(imR,2),[1,1]) ...
%                 + imI.*circshift(rot90(imI,2),[1,1]) ...
%                 + imR.^2 - imI.^2;
%             smoothSigma=1;
%             imgCorrected=imgaussfilt(real(imgCorrected),smoothSigma)...
%                 +1i*imgaussfilt(imag(imgCorrected),smoothSigma);

        
        % PLOTTING
        cLims = [0.1,1e2];

        h.deconvolution.img(1).CData = abs(imgDeconvolved);
%         imgNoise = rms(imgDeconvolved(dropletDensity==0));
%         h.deconvolution.img(1).CData = imag(imgDeconvolved).*(imag(imgDeconvolved)>=5*imgNoise);
        h.deconvolution.img(2).CData = angle(imgDeconvolved);
        h.deconvolution.img(3).CData = imag(imgDeconvolved);
        h.deconvolution.img(4).CData = real(imgDeconvolved);
%         disp(sum(imag(imgDeconvolved(:))))

        arrayfun(@(a) set(h.deconvolution.img(a), ...
            'XData', ([-1,1].*size(imgDeconvolved,2)/2 + [0,-1])*6, ...
            'YData', ([-1,1].*size(imgDeconvolved,1)/2 + [0,-1])*6), [1,2,3,4]); 
        xyLims = [-1,1]*R_nm*1.5;
        arrayfun(@(a) set(h.deconvolution.axes(a), 'XLim', xyLims, 'YLim', xyLims), [1,2,3,4]);
        h.deconvolution.plt(3,1).Color='k';
        
        if isfield(db,'radial') && (hit<=numel(db.radial(run).data)) && ~isempty(db.radial(run).data(hit)) && isfield(db.radial(run).data(hit), 'resolution_SNR_nm')
            h.deconvolution.plt(3,1).XData = dropletOutline.x;
            h.deconvolution.plt(3,1).YData = dropletOutline.y;
            if ~isnan(db.radial(run).data(hit).resolution_SNR_nm)
                h.deconvolution.plt(3,2).Position = R_nm/sqrt(2)*[1 1 0 0] + [0,0,1,1]*db.radial(run).data(hit).resolution_SNR_nm;
                h.deconvolution.plt(3,2).Visible = 'on';
                h.deconvolution.plt(3,2).FaceColor = colorOrder(1);
                h.deconvolution.plt(3,2).EdgeColor = colorOrder(1)/2;
            else
                h.deconvolution.plt(3,2).Visible = 'off';
            end
            if ~isnan(db.radial(run).data(hit).resolution_SNR_shannon_nm)
                centerPosition = R_nm/sqrt(2)*[1 1];
                if ~isnan(db.radial(run).data(hit).resolution_SNR_nm)
                    centerPosition = centerPosition + [1,1]*db.radial(run).data(hit).resolution_SNR_nm/2 - 0.5*[1,1]*db.radial(run).data(hit).resolution_SNR_shannon_nm;
                end 
                h.deconvolution.plt(3,3).Position = [centerPosition, 0, 0] + [0,0,1,1]*db.radial(run).data(hit).resolution_SNR_shannon_nm;
                h.deconvolution.plt(3,3).Visible = 'on';
                h.deconvolution.plt(3,3).FaceColor = colorOrder(2);
                h.deconvolution.plt(3,3).EdgeColor = [0,0,0];
            else
                h.deconvolution.plt(3,3).Visible = 'off';
            end
        end
        
%         h.deconvolution.axes(1).ColorScale = 'log';
%         h.deconvolution.axes(1).CLim = cLims;
%         cmap = colormapWhiteTransition(parula, 0.25);
%         cmap=pink;cmap=cmap(end:-1:1,:);
        cmap=ihesperia;
        arrayfun(@(a) colormap(h.deconvolution.axes(a), cmap), 1:4);
%         colormap()
%         h.deconvolution.axes(3).CLim(1) = h.deconvolution.axes(3).CLim(2)/4;
       
        h.deconvolution.img(1).AlphaData = 1;
        h.deconvolution.img(3).AlphaData = 1;
%         h.deconvolution.img(1).CData = abs(imgDeconvolved).*angle(imgDeconvolved)>0.*angle(imgDeconvolved)<pi/2;
%         h.deconvolution.img(1).CData = real(imgDeconvolved).*imag(imgDeconvolved)./abs(imgDeconvolved);
%          h.deconvolution.img(2).CData = constrain(angle(imgDeconvolved), 0, pi/2);
        h.deconvolution.axes(1).CLimMode = 'auto';
        h.deconvolution.axes(3).CLimMode = 'auto';
%         h.deconvolution.img(3).AlphaData = 1;
%         h.deconvolution.axes(3).CLim(1) = 0;
%         h.deconvolution.img(1).CData = real(imgDeconvolved);
%         h.deconvolution.axes(1).Colormap = dopantWjet;
        
%         alphadata = constrain(angle(imgDeconvolved), 0, pi/2).*angle(imgDeconvolved)>0.*angle(imgDeconvolved)<pi/2;
%         changeColorbarAlpha(h.deconvolution.axes(1), 0.25)
%         h.deconvolution.img(1).AlphaData = alphadata/max(alphadata(:));
%         h.deconvolution.img(3).AlphaData = constrain(real(imgDeconvolved).*(imag(imgDeconvolved))/0.25, 0,1).*(imag(imgDeconvolved)>0).*real(imgDeconvolved)>0;
        hData.img.deconvolution = imgDeconvolved;
        
        fprintf('\t\t\t\tdone!\n');
        
    end % computeDeconvolution

    function [fieldDeconvolved, fieldRef] = deconvolutionFcn(fieldScatt, fieldRef, maskScatt, snr, scattRatio)
        fieldRef = fieldRef/norm(fieldRef(maskScatt), 'fro');
        fieldRef = fieldRef*norm(fieldScatt(maskScatt), 'fro');
        fieldRef = fieldRef * scattRatio;

%         snr = 2*sqrt(abs(fieldScatt));
        fieldDeconvolved = fieldScatt .* conj(fieldRef) .* snr ./ (1 + abs(fieldRef).^2 .* snr);
%         fieldDeconvolved = fieldScatt .* conj(fieldRef) ./ (1./snr + abs(fieldRef).^2);
    end

    function [fieldImg, fieldRef] = setDropletPhase(scattImg, fieldRef, scattMask)
        fieldImg = sqrt(scattImg);
        fieldRef = fieldRef/norm(fieldRef(scattMask), 'fro');
        fieldRef = fieldRef*norm(fieldImg(scattMask), 'fro');
        fieldImg = fieldImg .* exp(1i*angle(fieldRef));
    end


    %% Simulation Functions
    
    function startSimulation(~,~)
%         if isgraphics(hSimu.figObj)
%             close(hSimu.figObj);
%         end
        hSimu = [];
        if exist('hSimu','var') 
            if isfield(hSimu,'figObj')
                if ~isvalid(hSimu.figObj)
                    clear hSimu;
                end
            end
        end
        
        nansum(hData.img.dataCropped(:))
        hData.par.binFactor = 0.5;
        dataRebinned = imresize(hData.img.dataCropped, hData.par.binFactor, 'bicubic')/hData.par.binFactor^2;
        maskRebinned = ~isnan(dataRebinned);
        nPhotonsOnDetector = nansum(hData.img.dataCropped(:));
        
        hSimu.simParameter = struct( ...
            'aDrop', db.shape(run).shape(hit).a_nm, ...
            'bDrop', db.shape(run).shape(hit).b_nm, ...
            'rotationDrop', hData.shape.rot, ...
            'aCore', 9, ...
            'bCore', 9, ...
            'rotationCore', 0,...
            'x1', cos(hData.shape.rot)*db.shape(run).shape(hit).R_nm/2/2, ...
            'y1', sin(hData.shape.rot)*db.shape(run).shape(hit).R_nm/2/2, ...
            'x2', -cos(hData.shape.rot)*db.shape(run).shape(hit).R_nm/2/2, ...
            'y2', -sin(hData.shape.rot)*db.shape(run).shape(hit).R_nm/2/2, ...
            'nPhotonsOnDetector', nPhotonsOnDetector,...
            'binFactor', hData.par.binFactor);
        fprintf('Starting simulation ...\n')
        hData.bool.simulationMode = true;
        
        hSimu = simulatePatternApp(dataRebinned, ...
            maskRebinned, ...
            hSimu.simParameter, ...
            fullfile(paths.img, 'scattering_simulations'), ...
            h.main.figure);
        fprintf('\tSimulation started!\n')
        drawnow;
    end % startSimulation
    
    function setNSimCores(~,~)
        hData.par.nSimCores = h.ui.oneCoreToggleButton.Value;
    end % setNSimCores

    function simulationScanAlpha(~,~)
        hIPR.scanParameter('alpha', (0.6:0.05:1), ...
            fullfile(hSave.folder, 'scans'));
    end

    function simulationScanDeltaFactor(~,~)
        hIPR.scanParameter('deltaFactor', (1:1:9), ...
            fullfile(hSave.folder, 'scans'));
    end
    
    function simulationScanAlphaAndDeltaFactor(~,~)
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
    end
    %% Process and Save Data
    
    function saveDataBaseFcn(~,~)
        saveName = fullfile(paths.db,'db.mat');
        fprintf('Saving database in %s\n ... ', saveName)
       save(saveName,'db','-v7')
        fprintf('done!\n')
    end % saveDataBaseFcn

    function savePattern(~,~,pxrange,cmap)
        if nargin<3
            pxrange=430; % [430, 344]=[5,4]degree | = tan(pxrange*75e-6/0.37)/pi*180
        end
        if nargin<4
            cmap=hData.par.cMap;
        end
%         h.savepattern.figure = gobjects(1);
        if ~isgraphics(h.savepattern.figure)
            h.savepattern.figure = getFigure(h.savepattern.figure, 'NumberTitle', 'off', ...
                    'Name', 'save pattern figure');
            clf(h.savepattern.figure);
            h.savepattern.axes = axes(h.savepattern.figure);
            h.savepattern.img = imagesc(h.savepattern.axes, nan);
        end
        
        for i=1:numel(pxrange)
            pxa=pxrange(i)*[-1,1] + [0,-1];
            thetarange=(pxrange(i)*75e-6/0.37)/pi*180;
            theta=(pxa*75e-6/0.37)/pi*180;
            xdata=round(hData.var.center(2))+ (pxa(1):pxa(end));
            ydata=round(hData.var.center(1))+ (pxa(1):pxa(end));
            img=hData.img.dataCorrected(ydata,xdata);
            img = imresize(img, 0.5)*4;
            img(img<=0.25)=nan;
            h.savepattern.img.CData=img;
            h.savepattern.img.AlphaData = ~isnan(img) & img>hData.par.cLims(1);
            h.savepattern.img.XData=theta;
            h.savepattern.img.YData=theta;
            h.savepattern.axes.XLim=h.savepattern.img.XData;
            h.savepattern.axes.YLim=h.savepattern.img.YData;
            truesize(h.savepattern.figure)
            colormap(h.savepattern.axes, cmap);
            h.savepattern.axes.CLim=hData.par.cLims;
            h.savepattern.axes.ColorScale='log';
            colorbar(h.savepattern.axes,'off');
            h.savepattern.axes.XTick=[];
            h.savepattern.axes.YTick=[];
            ax.XColor='none';
            ax.YColor='none';

            
            spath = fullfile(paths.img,...
                sprintf('%s',datetime('now','Format','yyyy-MM-dd')), 'pattern');
            if ~exist(spath,'dir'),mkdir(spath); end
            sext='.png';
            sname=sprintf('%s.r%03d.%03d_%03d%s',db.runInfo(run).doping.dopant{:}, run,hit,pxrange(i),sext);
            fullfilename=fullfile(spath,sname);
            fprintf('Saving scattering pattern to %s\n\t... ', fullfilename)
            exportgraphics(h.savepattern.axes,fullfilename)
            fprintf('done!\n')
        end

    end % savePattern

    function saveImgFcn(~,~,saveName,axesToSave,printRes)
        img.input = hData.img.input;
        img.assembled = hData.img.dataCorrected;
        img.centered = hData.img.dataCropped;

        imgToSave = img.centered;
        fprintf('.\n');
        saveName = getSaveName('png');
        [spath, sname, sext] = fileparts(saveName);
%         spath = fullfile(spath, '..\diffraction_pattern');
        idcs   = strfind(spath,'\');
        spath = spath(1:idcs(end)-1);
        spath = fullfile(spath, 'diffraction_pattern');
        if ~exist(spath, 'dir'), mkdir(spath); end
        saveName = fullfile(spath, [sname, sext]);
        crange = [.25,100];
        imgToSave(imgToSave<crange(1)) = nan;
        imgToSave(imgToSave>crange(2)) = crange(2);
        imgLog = log10(imgToSave);
        imgLog = imgLog / max(imgLog(:)) * 255;
        whitemap = isnan(imgLog) | isinf(imgLog);
%         imgToSave = imgToSave/crange(2)*255;
%         imgToSave(imgToSave>255) = 255;
        img8bit = uint8(imgLog);
        rgbImg = ind2rgb(img8bit, jet(256));
        r = rgbImg(:,:,1); r(whitemap) = 255;
        g = rgbImg(:,:,2); g(whitemap) = 255;
        b = rgbImg(:,:,3); b(whitemap) = 255;
        rgbImg = cat(3, r,g,b);
        imwrite(rgbImg, saveName)

% % %         save(sprintf('img_data_%03d_%03d.m', run, hit), "img")
% %         if ~isfield(hIPR.go, 'doSaveIPRImages'), hIPR.go.doSaveIPRImages = true; end
% %         if isgraphics(hIPR.go.figure) && hIPR.go.doSaveIPRImages
% %             getSaveName('png');
% %             hIPR.saveImages(fullfile(hSave.reconImageFolder,db.doping(run).dopant,hSave.fileName));
% %         else
% %             if nargin<5
% %                 printRes = const.printRes;
% %             end
% %             if nargin<4
% %                 axesToSave=gca;
% %             elseif isempty(axesToSave)
% %                 axesToSave=gca;
% %             end
% %             if nargin<3
% %                 saveName = getSaveName;
% %             elseif isempty(saveName)
% %                 saveName = getSaveName;
% %             end
% %             fprintf('Saving current axes to %s\n\t... ', saveName)
% %             exportgraphics(axesToSave,saveName,'Resolution',printRes)
% %             fprintf('done!\n')
% %         end
    end % saveImgFcn

    function fullpath = getSaveName(fileFormat)
        if nargin<1
            hSave.fileFormat='png';
        else
            hSave.fileFormat=fileFormat;
        end
        hSave.folder=fullfile(paths.img,...
            sprintf('%s',datetime('now','Format','yyyy-MM-dd')),...
            sprintf('r%03d',run));
        hSave.reconImageFolder =  fullfile(paths.img,...
            sprintf('%s',datetime('now','Format','yyyy-MM-dd')));
        hSave.reconFolder =  fullfile(paths.img,...
            sprintf('%s',datetime('now','Format','yyyy-MM-dd')));
%         if ~exist(hSave.folder,'dir'),mkdir(hSave.folder); end
        hSave.fileName=sprintf('%s.r%03d.%03d_trainid_%09d.%s',db.runInfo(run).doping.dopant{:}, run,hit,pnccd.trainid(hit), hSave.fileFormat);
%         hSave.fileName=sprintf('r%03d.%03d___%s.%s',run,hit,...
%             datetime('now','Format','yyyy.MM.dd-hh.mm.ss'),hSave.fileFormat);
        hSave.fullpath=fullfile(hSave.folder,hSave.fileName);
        fullpath=hSave.fullpath;
    end % getSaveName

    function printImages(~,~)

        getSaveName();
        if ~exist(hSave.folder,'dir'),mkdir(hSave.folder); end
        fprintf('\t\tsaving images in folder %s\n', hSave.folder);
            exportgraphics(h.centering.axes(1), fullfile(hSave.folder, ...
                ['center-', hSave.fileName]), 'Resolution', 100);
            exportgraphics(h.shape(2).figure,  fullfile(hSave.folder, ...
                ['shape-', hSave.fileName]), 'Resolution', 100);
            exportgraphics(hIPR.go.figure(1),  fullfile(hSave.folder, ...
                ['recon-', hSave.fileName]))
    end

    function makePixForSelectedHits(~,~)
%         alternativeSelection = [347 007; 358 105; 360 037; 360 039; 421 056; 421 072; 450 116; 450 068; 455 002; 457 052];
%         paperSelection = [347 007; 358 105; 360 037; 360 039; 421 056; 421 072; 450 116; 450 068; 455 002; 457 052];


        % the images currently in figure 2 of the paper
        paperSelection = [347,007; 358,105; 360,037; 360,039; 421,056; 421,072; 446,046; 447,015; 450,008; 450,068];

        % some alternatives
        alternativeSelection = [447,029; 450,060; 450,077; 450,083; 450,084; 450,124; 457,056; 454,029; 454,71; 457,006; 457,36];
        
        hitSelection = [paperSelection; alternativeSelection];
%         hitSelection = [446 046; 447 015; 450 008];
%         hitSelection = [446 041; 446 046; 447 006; 450 034; 450 038; 450 060; 450 068; 450 074;  454 056; 454 062; 457 049; 460 012; 478 038; 479 041; 479 052; 479 132];
        
%         hitSelection = [347 007; 358 105; 360 037; 360 039; 421 056; 421 072; 446 005; 446 017; 446 026; 446 27; 446 32; 446 46; 447 4; 447 6; 447 11; 447 15; 447 20; 447 22; 447 29; 447 30; 447 31; 450 8; 450 22; 450 38; 450 42; 450 47; 450 57; 450 60; 450 068; 450 74; 450 106; 450 124; 450 116; 454 21; 454 62; 454 70; 454 71; 454 85; 455 5; 455 7; 455 26; 455 002; 457 052; 457 1; 457 6; 457 36; 457 46; 457 49; 457 54; 460 12; 461 18; 461 22; 478 7; 478 10; 478 38; 478 45; 478 60; 478 145; 478 157; 478 164; 478 170; 478 185; 478 201; 479 16; 479 33; 479 37; 479 41; 479 52; 479 54; 479 101; 479 108; 479 120; 479 132];
%         hitSelection = [487,002];
        
        nHitsSelected = size(hitSelection,1);
%         fileName = 'tmp/figure2data.h5';
%         delete(fileName);
%         h5create(fileName,'/img/photon_countdown',[1024 1024, nHitsSelected],'Datatype','single', 'ChunkSize',[64 64, 1]);
% %         h5create(fileName,'/img/orig',[1024 1024, nHitsSelected],'Datatype','single', 'ChunkSize',[64 64, 1]);
% %         h5create(fileName,'/img/assembled',[1024 1024, nHitsSelected],'Datatype','single', 'ChunkSize',[64 64, 1]);
% %         h5create(fileName,'/img/running_bg',[1024 1024, nHitsSelected],'Datatype','single', 'ChunkSize',[64 64, 1]);
%         h5create(fileName,'/par/T0',nHitsSelected, 'Datatype','single')
%         h5create(fileName,'/par/p0',nHitsSelected, 'Datatype','single')
%         h5disp(fileName)

        for iS=1:nHitsSelected
            if h.main.figure.UserData.isRegisteredEscape
                clear hRecon;
                hRecon = [];
                fprintf('Loop aborted by user.\n')
                unregisterKeys(h.main.figure);
                return;
            end
                         
            newRun=hitSelection(iS,1);
            if run~=newRun
                loadNextFile([],[],hData.filepath, newRun, 1);
            end
            hit=hitSelection(iS,2);
            loadImageData();
            updatePlotsFcn();
%%%             hData.var.center = hData.var.centerRunMean;
%%             centerImgFcn([],[],[2 2 2 2],[1 .5 .25 .125])
            findShapeFcn();
            initIPR();
            addToPlan([],[],'dcdi');
            runRecon();
            saveImgFcn();
            
%             bg = squeeze(runningBg(hit,:,:));
%             origdata = hData.img.input;
            data = hData.img.dataCropped;
            p = db.runInfo(run).source.p;
            T = db.runInfo(run).source.T;
%             writematrix(data, sprintf('tmp/r%03d.%03d_%.0fbar_%.1fK.dat', run, hit, p, T), 'FileType','text');
%             writematrix(origdata, sprintf('tmp/orig_r%03d.%03d_%.0fbar_%.1fK.dat', run, hit, p, T), 'FileType','text');
%             writematrix(bg, sprintf('tmp/bg_r%03d.%03d_%.0fbar_%.1fK.dat', run, hit, p, T), 'FileType','text');
            writematrix(data, sprintf('tmp/r%03d.%03d_%.0fbar_%.1fK.dat', run, hit, p, T), 'FileType','text');

% %             h5write(fileName, '/img/orig', data, [1,1,iS], [1024,1024,1]);
% %             h5write(fileName, '/img/assembled', origdata, [1,1,iS], [1024,1024,1]);
% %             h5write(fileName, '/img/running_bg', bg, [1,1,iS], [1024,1024,1]);
%             h5write(fileName, '/img/photon_countdown', data, [1,1,iS], [1024,1024,1]);
%             h5write(fileName, '/par/T0', db.runInfo(run).source.T, iS, 1);
%             h5write(fileName, '/par/p0', db.runInfo(run).source.p, iS, 1);
            

        end
    end

    function reconANDsave(~,~)
%         hData.par.litPixelThreshold = 4e3;
%         hData.par.nPhotonsThreshold = 4e4;
%         hData.par.radiusThresholdInNm = 20;
%         
%         %         try d = load(fullfile(paths.db, 'db_recon.mat')); db_recon = d.db_recon; clear d;
%         %         catch; fprintf('could not load db_recon\n'); end
%         
%         while true
%             if h.main.figure.UserData.isRegisteredEscape
%                 fprintf('Loop aborted by user.\n')
%                 break;
%             end
%             %             try
% %             if strcmp(db.runInfo(run).doping.dopant,'none')
% %                 fprintf('run %i is not doped. Continuing...\n',run)
% %                 loadNextFile([],[],paths.pnccd, run+1,1);
% %                 hit = 1;
% %                 loadImageData();
% %                 continue
% %             end
%             if ( db.runInfo(run).nlit_smooth(hit) < hData.par.litPixelThreshold ...
%                     || db.data(run).nPhotons(hit) < hData.par.nPhotonsThreshold ...
%                     || isnan(db.sizing(run).R(hit)) ...
%                     || db.sizing(run).R(hit)*1e9<hData.par.radiusThresholdInNm )
%                 loadNextHit([],[],1);
%                 continue
%             end
%             if run>=437 && db.runInfo(run).nlit_smooth(hit)<1e4
%                 loadNextHit([],[],1);
%                 continue
%             end
% 
%             db.shape(run).shape(hit).a = nan;
%             db.shape(run).shape(hit).b = nan;
%             db.shape(run).shape(hit).rot = nan;
%             db.shape(run).shape(hit).R = nan;
%             db.shape(run).shape(hit).aspectRatio = nan;
%             
%             centerImgFcn([],[],5,.25);
%             findShapeFcn();
%             updatePlotsFcn();
%             initIPR();
%             
%             if strcmp(db.runInfo(run).doping.dopant,'none')
%                 fprintf('run %i is not doped. Continuing without phasing ...\n',run)
% %                 loadNextHit([],[],1);
% % %                 loadNextFile([],[],paths.pnccd, run+1,1);
% %                 continue
%             else
%                 hIPR.reconAddToPlan('dcdi',hData.var.nSteps,hData.var.nLoops);
%                 hIPR.reconRunPlan();
%             end
%             printImages();
%             loadNextHit([],[],1)
%         end
    end % reconAndSave

end % pnccdGUI
