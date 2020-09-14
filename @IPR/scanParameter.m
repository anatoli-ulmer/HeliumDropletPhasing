function obj = scanParameter(obj, sVar, sArray, savePath)
    fprintf('starting scan for %s=[%.2g',sVar,sArray(1))
    arrayfun(@(a)fprintf(',%.2g',a),gather(sArray(2:end)))
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
        obj=resetIPR(obj,sVar,sArray(i));
%         obj.(sVar) = sArray(i);
%         fprintf('\t%s = %.3g\n', sVar, sArray(i))
        %% run reconstruction
%         obj.iterate(nSteps, method);
        obj.reconPlan=thisReconPlan;
        obj.startRecon();
        %% copy parameter and results
        scanData(i).errors = obj.errors; %#ok<*AGROW>
        scanData(i).realSpaceError = obj.errors(1,end-1);
        scanData(i).fourierSpaceError = obj.errors(4,end-1);
        scanData(i).NRMSD = obj.errors(3,end-1);
        scanData(i).alpha = obj.alpha;
        scanData(i).delta = obj.delta;
        scanData(i).w = obj.w;
        scanData(i).WS = obj.WS;
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
    gObj.tl = tiledlayout(gObj.fig, 'flow');
    gObj.ax = nexttile(gObj.tl);
    gObj.plt = semilogy(gObj.ax, ...
        [scanData(:).(sVar)], ...
        [scanData(:).realSpaceError], 'x--', ... 
        [scanData(:).(sVar)], ...
        [scanData(:).fourierSpaceError], 'x--', ...
        [scanData(:).(sVar)], ...
        [scanData(:).NRMSD], 'o');
    gObj.ax.XLabel.String = sVar;
    gObj.ax.YLabel.String = 'error metrics';
    gObj.leg = legend(gObj.ax, 'Real Space Error', 'Fourier Space Error', 'NRMSD', ...
        'Huang et al.');
    %% copy results into scanObj
    scanObj.scanVariable = sVar;
    scanObj.scanArray = sArray;
    scanObj.imageSavePath = savePath;
    scanObj.reconPlan = thisReconPlan;
    scanObj.scanData = scanData;
    scanObj.gObj = gObj;
    %% copy scanObj for return
    obj.scanObj = scanObj;
end