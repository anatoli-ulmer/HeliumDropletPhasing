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
    gObj.hFigF = figure(12520);
    gObj.hFigR = figure(12521);
    gObj.hTLF = tiledlayout(gObj.hFigF, 'flow');
    gObj.hTLR = tiledlayout(gObj.hFigR, 'flow');
    %% run the reconstructions
    nPoints = numel(sArray);
    thisReconPlan = obj.reconPlan;
    for i=1:nPoints
        %% set parameter
%         obj=initIPR(obj,[],sVar,sArray(i));
        obj=resetIPR(obj,sVar,sArray(i));
%         obj.(sVar) =sArray(i);
%         fprintf('\t%s = %.3g\n', sVar, sArray(i))
        %% run reconstruction
%         obj.iterate(nSteps, method);
        obj.reconPlan=thisReconPlan;
        obj.reconRunPlan();
        %% copy parameter and results
        scanData(i).errors = obj.errors; %#ok<*AGROW>
        scanData(i).realSpaceError = obj.errors(1,end-1);
        scanData(i).simError = obj.errors(2,end-1);
        scanData(i).fourierSpaceError = obj.errors(3,end-1);
        scanData(i).alpha = obj.alpha;
        scanData(i).delta = obj.delta;
        scanData(i).deltaFactor = obj.deltaFactor;
        scanData(i).w = obj.w;
        scanData(i).WS = obj.WS;
        scanData(i).reconPlan = thisReconPlan;
        %% plot images in array
        fData=log10(abs(obj.WS));
        fPlotRange=obj.clims_scatt;
        rData=real(obj.w - obj.rho0);
        rPlotRange=[-1,1]*max(abs(rData(:)));
        gObj.hAxArrayF(i)=nexttile(gObj.hTLF);
        gObj.hAxArrayR(i)=nexttile(gObj.hTLR);
        gObj.hImgArrayF(i)=imagesc(gObj.hAxArrayF(i),fData,fPlotRange);
        gObj.hImgArrayR(i)=imagesc(gObj.hAxArrayR(i),rData,rPlotRange);
        gObj.hTitArrayF(i)=title(gObj.hAxArrayF(i),...
            sprintf('%s=%.2f',sVar,sArray(i)));
        gObj.hTitArrayR(i)=title(gObj.hAxArrayR(i),...
            sprintf('%s=%.2f',sVar,sArray(i)));
%         gObj.hAxArrayR(i).XLim=[-1,1]*250;
%         gObj.hAxArrayR(i).YLim=[-1,1]*250;
        zoom(gObj.hAxArrayR(i),5);
        colormap(gObj.hAxArrayR(i), b2r);
        drawnow;
        %% save images directly
%         myImwrite(log10(abs(obj.WS)), imorgen, [-1,3], ...
%             fullfile(savePath, sprintf('%s%02.3f-1.png', ...
%             sVar, sArray(i))));
%         myImwrite((real(obj.w)-obj.rho0), igray, [], ...
%             fullfile(savePath, sprintf('%s%02.3f-2.png', ...
%             sVar, sArray(i))));        
    end
    %% plot results for error metrics
    gObj.fig = figure(12523);
    gObj.tl = tiledlayout(gObj.fig, 3, 1);
    gObj.ax(1) = nexttile(gObj.tl);
    gObj.ax(2) = nexttile(gObj.tl);
    gObj.ax(3) = nexttile(gObj.tl);
    gObj.plt(1) = semilogy(gObj.ax(1), ...
        [scanData(:).(sVar)], ...
        [scanData(:).realSpaceError], 'o--');
%     hold(gObj.ax(1), 'on');
    gObj.plt(2) = semilogy(gObj.ax(2), ...
        [scanData(:).(sVar)], ...
        [scanData(:).simError], 'o:');
%     hold(gObj.ax(1), 'off');
    gObj.plt(3) = semilogy(gObj.ax(3), ...
        [scanData(:).(sVar)], ...
        [scanData(:).fourierSpaceError], 'x--');
%     legend(gObj.ax(1), obj.axesArray(1).Legend.String{1}, 'Interpreter', 'latex');
%     legend(gObj.ax(2), obj.axesArray(1).Legend.String{2}, 'Interpreter', 'latex');
%     legend(gObj.ax(3), obj.axesArray(2).Legend.String, 'Interpreter', 'latex');
    gObj.ax(1).XLabel.String = sVar;
    gObj.ax(2).XLabel.String = sVar;
    gObj.ax(3).XLabel.String = sVar;
    ylabel(gObj.ax(1), obj.axesArray(1).Legend.String{1}, 'Interpreter', 'latex');
    ylabel(gObj.ax(2), obj.axesArray(1).Legend.String{2}, 'Interpreter', 'latex');
    ylabel(gObj.ax(3), obj.axesArray(2).Legend.String{1}, 'Interpreter', 'latex');
    axis(gObj.ax, 'tight');
%     gObj.ax(1).XLim = [min(gObj.plt(1).XData), max(gObj.plt(1).XData)];
%     gObj.ax(2).XLim = [min(gObj.plt(2).XData), max(gObj.plt(2).XData)];
%     gObj.ax(3).XLim = [min(gObj.plt(3).XData), max(gObj.plt(3).XData)];
%     gObj.ax(1).YLim = [min(gObj.plt(1).YData),max(gObj.plt(1).YData)].*[0.9, 1.1];
%     gObj.ax(2).YLim = [min(gObj.plt(2).YData),max(gObj.plt(2).YData)].*[0.9, 1.1];
%     gObj.ax(3).YLim = [min(gObj.plt(3).YData),max(gObj.plt(3).YData)].*[0.9, 1.1];
%     gObj.ax(2).YLabel.String = obj.axesArray(1).Legend.String{2};
%     gObj.ax(3).YLabel.String = obj.axesArray(2).Legend.String;
%     gObj.leg = legend(gObj.ax, 'Real Space Error', 'Fourier Space Error');
    %% copy results into scanObj
    scanObj.scanVariable = sVar;
    scanObj.scanArray = sArray;
    scanObj.imageSavePath = savePath;
    scanObj.reconPlan = thisReconPlan;
    scanObj.scanData = scanData;
    scanObj.gObj = gObj;
    %% saving
    saveTime = string(datetime('now','TimeZone','local',...
        'Format','dd-MM-yyyy_HH-mm-ss'));
    saveName = sprintf('%s-scan_%s_%s', sVar, thisReconPlan{1}, saveTime);
    save(fullfile(savePath, ['Obj_', saveName, '.mat']), 'scanObj');
    exportgraphics(gObj.hFigF, fullfile(savePath, ['scattering_', saveName, '.png']))
    exportgraphics(gObj.hFigR, fullfile(savePath, ['reconstruction_', saveName, '.png']))
    exportgraphics(gObj.fig, fullfile(savePath, ['errors_', saveName, '.png']))
    dlmwrite(fullfile(savePath, ['data_',saveName, '.csv']), [[scanData(:).(sVar)]; [scanData(:).simError]]);
    %% copy scanObj for return
    obj.scanObj = scanObj;
end
