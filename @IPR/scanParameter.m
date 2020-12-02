function obj = scanParameter(obj, scanVariable, scanArray, savePath)

    fprintf('starting scan for %s=[%.3g', scanVariable, scanArray(1))
    arrayfun( @(a) fprintf(',%.3g', a), gather(scanArray(2:end)) )
    fprintf(']\n')
    
    
    %% make sure that output folder exists
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    
    %% prepare figure objects
    gObj.ErrorPlots.Figure = getFigure([], 'NumberTitle', 'off', ...
        'Name', 'Parameter Scan Figure #1 - Fourier Space');
    gObj.FourierSpace.Figure = getFigure([], 'NumberTitle', 'off', ...
        'Name', 'Parameter Scan Figure #2 - Real Space');
    gObj.RealSpace.Figure = getFigure([], 'NumberTitle', 'off', ...
        'Name', 'Parameter Scan Figure #3 - Error Plots');
    
    clf(gObj.ErrorPlots.Figure);
    clf(gObj.FourierSpace.Figure);
    clf(gObj.RealSpace.Figure);
    
    set(gObj.ErrorPlots.Figure, 'Units', 'normalized', ...
        'Position', [0,0.033,0.7,0.9067]);
    set(gObj.FourierSpace.Figure, 'Units', 'normalized', ...
        'Position', [0,0.033,0.7,0.9067]);
    set(gObj.RealSpace.Figure, 'Units', 'normalized', ...
        'Position', [0.7,0.033,0.3,0.9067]);
    
    gObj.FourierSpace.TiledLayout = tiledlayout(gObj.ErrorPlots.Figure, ...
        'flow', 'TileSpacing', 'none', 'Padding', 'none');
    gObj.RealSpace.TiledLayout = tiledlayout(gObj.FourierSpace.Figure, ...
        'flow', 'TileSpacing', 'none', 'Padding', 'none');
    gObj.tiledLayout(3) = tiledlayout(gObj.RealSpace.Figure, 3, 1);
    
    gObj.ErrorPlots.Axes(1) = nexttile(gObj.tiledLayout(3));
    gObj.ErrorPlots.Axes(2) = nexttile(gObj.tiledLayout(3));
    gObj.ErrorPlots.Axes(3) = nexttile(gObj.tiledLayout(3));
    
    colormap(gObj.FourierSpace.Figure, b2r);
    gObj.xyData = [obj.yy(1),obj.yy(end)]*6;
    gObj.xyLims = obj.go.axes(6).XLim;
    gObj.yLabels = {obj.go.axes(1).Legend.String{1}, ...
        obj.go.axes(1).Legend.String{2}, ...
        obj.go.axes(2).Legend.String{1}};
    gObj.yLims = {[0,0.05], [0,0.2], [0,0.5]};
    
    %% run the reconstructions
    nPoints = numel(scanArray);
    thisReconPlan = obj.reconPlan;
    
    for i=1:nPoints
        
        %% set parameter
        obj=resetIPR(obj,scanVariable,scanArray(i));
        
        %% run reconstruction
        obj.reconPlan=thisReconPlan;
        obj.reconRunPlan();
        
        %% copy parameter and results
        scanData(i).errors = obj.errors; %#ok<*AGROW>
        % last entry of real space error:
        scanData(i).errorReal = obj.errors(1,end-1); 
        % last entry of real space deviation of reconstruction from simulation 
        % input:
        scanData(i).errorSim = obj.errors(2,end-1);
        % last entry of fourier space error:
        scanData(i).errorFourier = obj.errors(3,end-1);
        scanData(i).alpha = obj.alpha;
        scanData(i).delta = obj.delta;
        scanData(i).deltaFactor = obj.deltaFactor;
        scanData(i).w = obj.w;
        scanData(i).W = obj.W;
        scanData(i).reconPlan = thisReconPlan;
        
        %% plot images in array
        fourierData=log10(abs(obj.W));
        fourierPlotRange=obj.clims_scatt;
        realData=real(obj.w - obj.rho0);
        realPlotRange=[-1,1]*max(abs(realData(:)));
        
        gObj.FourierSpace.Axes(i) = nexttile(gObj.FourierSpace.TiledLayout);
        gObj.RealSpace.Axes(i) = nexttile(gObj.RealSpace.TiledLayout);
        
        gObj.FourierSpace.Image(i) = imagesc(gObj.FourierSpace.Axes(i), ...
            fourierData, fourierPlotRange);
        gObj.RealSpace.Image(i) = imagesc(gObj.RealSpace.Axes(i), ...
            gObj.xyData, gObj.xyData, realData, realPlotRange);
        
        hold(gObj.RealSpace.Axes(i), 'on');
        
        gObj.RealSpace.Plot(i) = plot(gObj.RealSpace.Axes(i), ...
            obj.dropletOutline.x, obj.dropletOutline.y, 'k--');
        
        hold(gObj.RealSpace.Axes(i), 'off');
        
        gObj.FourierSpace.Title(i)=title(gObj.FourierSpace.Axes(i),...
            sprintf('%s=%.2f',scanVariable,scanArray(i)));
        gObj.RealSpace.Title(i)=title(gObj.RealSpace.Axes(i),...
            sprintf('%s=%.2f',scanVariable,scanArray(i)));
        
        set(gObj.FourierSpace.Axes(i),'XTickLabel',[],'YTickLabel',[]);
        set(gObj.RealSpace.Axes(i),'XTickLabel',[],'YTickLabel',[],...
            'XLim',gObj.xyLims,'YLim',gObj.xyLims);
        
        drawnow;     
    end
    
    %% plot results for error metrics

    gObj.ErrorPlots.Plot(1) = plot(gObj.ErrorPlots.Axes(1), ...
        [scanData(:).(scanVariable)], ...
        [scanData(:).errorReal], 'o--');
%     hold(gObj.ErrorPlots.Axes(1), 'on');
    gObj.ErrorPlots.Plot(2) = plot(gObj.ErrorPlots.Axes(2), ...
        [scanData(:).(scanVariable)], ...
        [scanData(:).errorSim], 'o:', 'Color', colorOrder(2));
%     hold(gObj.ErrorPlots.Axes(1), 'off');
    gObj.ErrorPlots.Plot(3) = plot(gObj.ErrorPlots.Axes(3), ...
        [scanData(:).(scanVariable)], ...
        [scanData(:).errorFourier], 'x--', 'Color', colorOrder(3));
%     arrayfun(@(a) legend(gObj.ErrorPlots.Axes(a), gObj.yLabels{a}, 'Interpreter', ...
%         'latex'), 1:3, 'UniformOutput', false);

    arrayfun(@(a) xlabel(gObj.ErrorPlots.Axes(a), scanVariable), 1:3, ...
        'UniformOutput', false);
    arrayfun(@(a) ylabel(gObj.ErrorPlots.Axes(a), gObj.yLabels{a}, ...
        'Interpreter', 'latex'), 1:3, 'UniformOutput', false);
    ylabel(gObj.ErrorPlots.Axes(1), obj.go.Results.Axes(1).Legend.String{1}, 'Interpreter', 'latex');

%     axis(gObj.axes, 'tight');
    arrayfun(@(a) set(gObj.ErrorPlots.Axes(a), ...
        'XLim', [min(gObj.ErrorPlots.Plot(1).XData), max(gObj.ErrorPlots.Plot(1).XData)], ...
        'YLim', [gObj.yLims{a}(1), max([gObj.yLims{a}(2), gObj.ErrorPlots.Plot(a).YData])]), ...
        1:3, 'UniformOutput', false);

    %% copy results into obj.scanObj
    
    obj.scanObj.scanVariable = scanVariable;
    obj.scanObj.scanArray = scanArray;
    obj.scanObj.imageSavePath = savePath;
    obj.scanObj.reconPlan = thisReconPlan;
    obj.scanObj.scanData = scanData;
    obj.scanObj.gObj = gObj;
    
    %% saving
    
    saveTime = string(datetime('now','TimeZone','local',...
        'Format','yyyy-MM-dd-_HH.mm'));
    saveName = sprintf('%s-scan_%s_%s', ...
        scanVariable, thisReconPlan{1}, saveTime);
    
    save(fullfile(savePath, ['obj.scanObj_', saveName, '.mat']), 'obj.scanObj');
    
    exportgraphics(gObj.ErrorPlots.Figure, ...
        fullfile(savePath, ['scattering_', saveName, '.png']))
    exportgraphics(gObj.FourierSpace.Figure, ...
        fullfile(savePath, ['reconstruction_', saveName, '.png']))
    exportgraphics(gObj.RealSpace.Figure, ...
        fullfile(savePath, ['errors_', saveName, '.png']))
    exportgraphics(gObj.ErrorPlots.Axes(2), ...
        fullfile(savePath, ['sim_error_', saveName, '.png']))
    dlmwrite(fullfile(savePath, ['data_',saveName, '.csv']), ...
        [[scanData(:).(scanVariable)]; [scanData(:).errorSim]]);
    
end
