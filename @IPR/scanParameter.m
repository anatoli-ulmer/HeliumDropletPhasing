function obj = scanParameter(obj, sVar, sArray, savePath)

    fprintf('starting scan for %s=[%.3g',sVar,sArray(1))
    arrayfun(@(a)fprintf(',%.3g',a),gather(sArray(2:end)))
    fprintf(']\n')
    
    %% copy existing scanObj
    scanObj = obj.scanObj;
    
    %% make sure that output folder exists
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    
    %% prepare figure objects
    gObj.hFigArray = gobjects(1,3);
    gObj.hFigArray(1) = getFigure(gObj.hFigArray(1),...
        'NumberTitle', 'off', 'Name', 'Parameter Scan Figure #1 - Fourier Space');
    gObj.hFigArray(2) = getFigure(gObj.hFigArray(2),...
        'NumberTitle', 'off', 'Name', 'Parameter Scan Figure #2 - Real Space');
    gObj.hFigArray(3) = getFigure(gObj.hFigArray(3),...
        'NumberTitle', 'off', 'Name', 'Parameter Scan Figure #3 - Error Plots');
    
    set(gObj.hFigArray(1), 'Units', 'normalized', 'Position', [0,0.033,0.7,0.9067]);
    set(gObj.hFigArray(2), 'Units', 'normalized', 'Position', [0,0.033,0.7,0.9067]);
    set(gObj.hFigArray(3), 'Units', 'normalized', 'Position', [0.7,0.033,0.3,0.9067]);
    
    gObj.hTLArray(1) = tiledlayout(gObj.hFigArray(1), 'flow', ...
        'TileSpacing', 'none', 'Padding', 'none');
    gObj.hTLArray(2) = tiledlayout(gObj.hFigArray(2), 'flow',...
        'TileSpacing', 'none', 'Padding', 'none');
    gObj.hTLArray(3) = tiledlayout(gObj.hFigArray(3), 3, 1);
    
    colormap(gObj.hFigArray(2), b2r);
    gObj.xyData = [obj.yy(1),obj.yy(end)]*6;
    gObj.xyLims = obj.axesArray(6).XLim;
    gObj.yLabels = {obj.axesArray(1).Legend.String{1}, ...
        obj.axesArray(1).Legend.String{2}, ...
        obj.axesArray(2).Legend.String{1}};
    gObj.yLims = {[0,0.05], [0,0.2], [0,0.5]};
    gObj.ax(1) = nexttile(gObj.hTLArray(3));
    gObj.ax(2) = nexttile(gObj.hTLArray(3));
    gObj.ax(3) = nexttile(gObj.hTLArray(3));
    
    %% run the reconstructions
    nPoints = numel(sArray);
    thisReconPlan = obj.reconPlan;
    
    for i=1:nPoints
        
        %% set parameter
        obj=resetIPR(obj,sVar,sArray(i));
        
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
        fData=log10(abs(obj.W));
        fPlotRange=obj.clims_scatt;
        rData=real(obj.w - obj.rho0);
        rPlotRange=[-1,1]*max(abs(rData(:)));
        gObj.hAxArrayF(i)=nexttile(gObj.hTLArray(1));
        gObj.hAxArrayR(i)=nexttile(gObj.hTLArray(2));
        
        gObj.hImgArrayF(i)=imagesc(gObj.hAxArrayF(i),fData,fPlotRange);
        gObj.hImgArrayR(i)=imagesc(gObj.hAxArrayR(i),gObj.xyData,gObj.xyData,...
            rData,rPlotRange);
        hold(gObj.hAxArrayR(i), 'on');
        gObj.outline(i)=plot(gObj.hAxArrayR(i), ...
            obj.dropletOutline.x, obj.dropletOutline.y, 'k--');
        hold(gObj.hAxArrayR(i), 'off');
        
        gObj.hTitArrayF(i)=title(gObj.hAxArrayF(i),...
            sprintf('%s=%.2f',sVar,sArray(i)));
        gObj.hTitArrayR(i)=title(gObj.hAxArrayR(i),...
            sprintf('%s=%.2f',sVar,sArray(i)));
        set(gObj.hAxArrayF(i),'XTickLabel',[],'YTickLabel',[]);
        set(gObj.hAxArrayR(i),'XTickLabel',[],'YTickLabel',[],...
            'XLim',gObj.xyLims,'YLim',gObj.xyLims);
        drawnow;     
    end
    
    %% plot results for error metrics

    gObj.plt(1) = plot(gObj.ax(1), ...
        [scanData(:).(sVar)], ...
        [scanData(:).errorReal], 'o--');
%     hold(gObj.ax(1), 'on');
    gObj.plt(2) = plot(gObj.ax(2), ...
        [scanData(:).(sVar)], ...
        [scanData(:).errorSim], 'o:', 'Color', colorOrder(2));
%     hold(gObj.ax(1), 'off');
    gObj.plt(3) = plot(gObj.ax(3), ...
        [scanData(:).(sVar)], ...
        [scanData(:).errorFourier], 'x--', 'Color', colorOrder(3));
%     arrayfun(@(a) legend(gObj.ax(a), gObj.yLabels{a}, 'Interpreter', ...
%         'latex'), 1:3, 'UniformOutput', false);

    arrayfun(@(a) xlabel(gObj.ax(a), sVar), 1:3, ...
        'UniformOutput', false);
    arrayfun(@(a) ylabel(gObj.ax(a), gObj.yLabels{a}, ...
        'Interpreter', 'latex'), 1:3, 'UniformOutput', false);
    ylabel(gObj.ax(1), obj.axesArray(1).Legend.String{1}, 'Interpreter', 'latex');

%     axis(gObj.ax, 'tight');
    arrayfun(@(a) set(gObj.ax(a), ...
        'XLim', [min(gObj.plt(1).XData), max(gObj.plt(1).XData)], ...
        'YLim', [gObj.yLims{a}(1), max([gObj.yLims{a}(2), gObj.plt(a).YData])]), ...
        1:3, 'UniformOutput', false);

    %% copy results into scanObj
    scanObj.scanVariable = sVar;
    scanObj.scanArray = sArray;
    scanObj.imageSavePath = savePath;
    scanObj.reconPlan = thisReconPlan;
    scanObj.scanData = scanData;
    scanObj.gObj = gObj;
    %% saving
    saveTime = string(datetime('now','TimeZone','local',...
        'Format','yyyy-MM-dd-_HH.mm'));
    saveName = sprintf('%s-scan_%s_%s', sVar, thisReconPlan{1}, saveTime);
    save(fullfile(savePath, ['Obj_', saveName, '.mat']), 'scanObj');
    exportgraphics(gObj.hFigArray(1), fullfile(savePath, ['scattering_', saveName, '.png']))
    exportgraphics(gObj.hFigArray(2), fullfile(savePath, ['reconstruction_', saveName, '.png']))
    exportgraphics(gObj.hFigArray(3), fullfile(savePath, ['errors_', saveName, '.png']))
    exportgraphics(gObj.ax(2), fullfile(savePath, ['sim_error_', saveName, '.png']))
    dlmwrite(fullfile(savePath, ['data_',saveName, '.csv']), [[scanData(:).(sVar)]; [scanData(:).errorSim]]);
    %% copy scanObj for return
    obj.scanObj = scanObj;
end
