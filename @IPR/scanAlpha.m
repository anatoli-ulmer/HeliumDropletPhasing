function obj = scanAlpha(obj, nsteps, method)

    nAlphas = numel(obj.alphaArray);
    for i=1:nAlphas
        obj.resetIPR();
        obj.alpha = obj.alphaArray(i);
        fprintf('\talpha = %.3g\n', obj.alpha)
        
        obj.iterate(nsteps, method);
        
        obj.scanAlphaData(i).errors = obj.errors;
        obj.scanAlphaData(i).realSpaceError = obj.errors(1,end-1);
        obj.scanAlphaData(i).fourierSpaceError = obj.errors(2,end-1);
%         obj.scanAlphaData(i).NRMSD = obj.errors(3,end-1);
        obj.scanAlphaData(i).nsteps = nsteps;
        obj.scanAlphaData(i).alpha = obj.alpha;
        obj.scanAlphaData(i).delta = obj.delta;
        obj.scanAlphaData(i).w = obj.w;
        obj.scanAlphaData(i).WS = obj.WS;
        if ~exist(obj.imageSavePath, 'dir'), mkdir(obj.imageSavePath); end
        myImwrite(log10(abs(obj.WS)), wjet, ...
            fullfile(obj.imageSavePath, sprintf('alpha%.2f-1.png',obj.alpha)));
        myImwrite((abs(obj.w)-obj.rho), wjet, ...
            fullfile(obj.imageSavePath, sprintf('alpha%.2f-2.png',obj.alpha)));
    end
    scanObj.fig = figure(12523);
    scanObj.tl = tiledlayout(scanObj.fig, 'flow');
    scanObj.ax = nexttile(scanObj.tl);
    scanObj.plot = plot(scanObj.ax, ...
        [obj.scanAlphaData(:).alpha], ...
        [obj.scanAlphaData(:).realSpaceError], 'x--', ... 
        [obj.scanAlphaData(:).alpha], ...
        [obj.scanAlphaData(:).fourierSpaceError], 'x--', ...
        [obj.scanAlphaData(:).alpha], ...
        [obj.scanAlphaData(:).NRMSD], 'o');
    scanObj.ax.XLabel.String = 'alpha';
    scanObj.ax.YLabel.String = 'error metrics';
    legend(scanObj.ax, 'Real Space Error', 'Fourier Space Error', 'NRMSD', ...
        'Huang et al.');
    obj.scanObj = scanObj;
end
