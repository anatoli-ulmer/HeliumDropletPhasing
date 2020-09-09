function gObj = simulateScattering(newData, newMask, newParameter, newSavepath, mainapp)

gObj = [];
simData.data = newData;
simData.data(isnan(simData.data)) = 0;
simData.mask = newMask;
simParam = newParameter;
simParam.nPixel = size(simData.data);

if exist('newSavepath', 'var')
    savepath = newSavepath;
else
    savepath = 'C:\Users\Toli\Google Drive\dissertation\2.helium\xfel-img\scattering_simulations';
end
if exist('mainapp', 'var')
    callerHandle = mainapp;
end

initParameter();
initSimuPlots();

        
    function initParameter(obj)
        simParam.aHe = 184;
        simParam.bHe = 188;
        simParam.rotHe = 191;
        simParam.aDope = 17;
        simParam.bDope = 8;
        simParam.rotDope = 150;
        simParam.x1 = -93;
        simParam.y1 = -108;
        simParam.x2 = 93;
        simParam.y2 = 108;
        simParam.ratio = 7;
        simParam.nPhotonsOnDetector = nansum(simData.data(:));
        simParam.nDroplet = ( (simParam.aHe+simParam.bHe) /2/0.222 )^3;
        simParam.nDopants = ( (simParam.aDope+simParam.bDope) /2/0.222 )^3;
        if ~isfield(simParam, 'cLims')
            simParam.cLims = [-1,2];
        end
    end
    function updateParameter(~,~)
        pnames = fields(simParam);
        for f=1:numel(pnames)
            gObj.([pnames{f},'_edt']).String = num2str(simParam.(pnames{f}));
        end
    end
    function thisKeyPressFcn(~,evt)
        switch evt.Key
            case 'c'
                clc
            case 'm'
                gObj.x2_edt.String = num2str(-str2num_fast(gObj.x1_edt.String));
                gObj.y2_edt.String = num2str(-str2num_fast(gObj.y1_edt.String));
                startSimulation;
            case '+'
                createsavefig();
            case '*'
                save_plot(savepath, 'test.png')
        end
    end
    function startSimulation(src,evt) %#ok<*INUSD>
        simParam.aHe = str2num_fast(gObj.aHe_edt.String)/6;
        simParam.bHe = str2num_fast(gObj.bHe_edt.String)/6;
        simParam.rotHe = str2num_fast(gObj.rotHe_edt.String)/360*2*pi;
        simParam.aDope = str2num_fast(gObj.aDope_edt.String)/6;
        simParam.bDope = str2num_fast(gObj.bDope_edt.String)/6;
        simParam.rotDope = str2num_fast(gObj.rotDope_edt.String)/360*2*pi;
        simParam.x1 = str2num_fast(gObj.x1_edt.String)/6;
        simParam.y1 = str2num_fast(gObj.y1_edt.String)/6;
        simParam.x2 = str2num_fast(gObj.x2_edt.String)/6;
        simParam.y2 = str2num_fast(gObj.y2_edt.String)/6;
        simParam.ratio = str2num_fast(gObj.ratio_edt.String);
        simParam.nPhotonsOnDetector = str2num_fast(gObj.nPhotonsOnDetector_edt.String);
        simParam.N = simParam.nPixel;
        simParam.center = simParam.nPixel/2+1;
        
        [simData, simParam] = dopecore_scatt(simData, simParam);
        simData.scatt1 = simData.scatt1/sum(simData.scatt1(:) .* double(simData.mask(:))) * simParam.nPhotonsOnDetector;
        simData.scatt2 = simData.scatt2/sum(simData.scatt2(:) .* double(simData.mask(:))) * simParam.nPhotonsOnDetector;
        
        simData.scatt1 = imnoise(simData.scatt1/1e12,'poisson')*1e12;
        simData.scatt2 = imnoise(simData.scatt2/1e12,'poisson')*1e12;
        
        if gObj.mask_cbx.Value
            simData.scatt1 = simData.scatt1 .* double(simData.mask);
            simData.scatt2 = simData.scatt2 .* double(simData.mask);
        end
        %         data.polimg = rot90(polar_matrix(data.simData.data,'xcenter', size(simu.scatt1,2)/2+1,'ycenter',size(simu.scatt1,1)/2+1));
        %         simu.pol1 = rot90(polar_matrix(simu.scatt1,'xcenter', size(simu.scatt1,2)/2+1,'ycenter',size(simu.scatt1,1)/2+1));
        %         simu.pol2 = rot90(polar_matrix(simu.scatt2,'xcenter', size(simu.scatt1,2)/2+1,'ycenter',size(simu.scatt1,1)/2+1));
        arrayfun(@(a) set(gObj.axesArray(a), 'CLim', simParam.cLims), [3:5]);
        updatePlot;
    end
    function argout = getSimulation(~,~)
        argout = simData.scatt1 ;
    end
    function obj = updatePlot(obj)
        subscale = 1.0;
        gObj.imgArray(1).CData = simData.scene1 - subscale*simData.droplet;
        gObj.imgArray(2).CData = simData.scene2 - subscale*simData.droplet;
        gObj.imgArray(3).CData = log10(abs(simData.scatt1));
        gObj.imgArray(4).CData = log10(abs(simData.scatt2));
        gObj.imgArray(5).CData = log10(abs(round(simData.data)));
        %         gObj.imgArray(11).CData = log10(abs(simu.pol1));
        %         gObj.imgArray(12).CData = log10(abs(data.polimg));
        %         gObj.imgArray(13).CData = log10(abs(simu.pol2));
        el = ellipse_outline(simParam.aHe*6,simParam.bHe*6,-simParam.rotHe);
        arrayfun(@(a) set(gObj.ellipseArray(a), 'XData', el.x, 'YData', el.y), 1:2)
        arrayfun(@(a) set(gObj.axesArray(a), 'CLim', max(gObj.imgArray(a).CData(:))*[-1 1]), 1:2)
        arrayfun(@(a) colormap(gObj.axesArray(a), r2b), 1:2)
    end
    function createsavefig(~,~)
        gObj.save.fig = figure('Units', 'inches',...
            'Position', [1,1,size(simData.data,2)/size(simData.data,1)*3,3],...
            'PaperUnits', 'inches', 'PaperSize', [size(simData.data,2)/size(simData.data,1)*3,3],...
            'PaperPosition', [0,0,size(simData.data,2)/size(simData.data,1)*3,3]);
        gObj.save.ax = axes('Units', 'normalized', 'Position', [0,0,1,1]);
        gObj.save.plt = imagesc(zeros(simParam.nPixel), 'parent', gObj.save.ax, simParam.cLims);
        colormap(gObj.save.ax, gObj.cmap_popup.String{gObj.cmap_popup.Value}); colorbar(gObj.save.ax, 'off');
        set(gObj.save.ax,'visible','off'); grid(gObj.save.ax, 'off');
        drawnow;
    end
    function save_plot(savepath, savename)
        if ~exist(savepath, 'dir')
            mkdir(savepath);
        end
        print(gObj.save.fig, fullfile(savepath,savename),...
            sprintf('-r%i', size(simData.data,1)) , '-dpng')
    end
    function setmap(src,evt)
        simParam.cLims = src.String{src.Value};
        arrayfun(@(a) set(gObj.axesArray(a), 'CLim', simParam.cLims), [3:5]);
    end
    function initSimuPlots(src,evt)
        gObj.fig = figure(55554); clf
        gObj.fig.KeyPressFcn = @thisKeyPressFcn;
        gObj.fig.CloseRequestFcn = @thisCloseRequestFcn;
        
        gObj.axesArray(1) = mysubplot(2,3,1,'parent',gObj.fig);
        gObj.imgArray(1) = imagesc(gObj.axesArray(1), ones(simParam.nPixel), 'XData', [-simParam.nPixel/2,simParam.nPixel/2-1]*6, 'YData', [-simParam.nPixel/2,simParam.nPixel/2-1]*6);
        gObj.axesArray(2) = mysubplot(2,3,3,'parent',gObj.fig);
        gObj.imgArray(2) = imagesc(gObj.axesArray(2), ones(simParam.nPixel), 'XData', [-simParam.nPixel/2,simParam.nPixel/2-1]*6, 'YData', [-simParam.nPixel/2,simParam.nPixel/2-1]*6);
        gObj.axesArray(3) = mysubplot(2,3,4,'parent',gObj.fig);
        gObj.imgArray(3) = imagesc(gObj.axesArray(3), ones(simParam.nPixel), simParam.cLims);
        gObj.axesArray(4) = mysubplot(2,3,6,'parent',gObj.fig);
        gObj.imgArray(4) = imagesc(gObj.axesArray(4), ones(simParam.nPixel), simParam.cLims);
        gObj.axesArray(5) = mysubplot(2,3,5,'parent',gObj.fig);
        gObj.imgArray(5) = imagesc(gObj.axesArray(5), ones(simParam.nPixel), simParam.cLims);
        
        gObj.cmap_popup = uicontrol(gObj.fig, 'Style', 'popupmenu',...
            'String', {'imorgen', 'morgenstemning', 'wjet','r2b',...
            'parula','jet','hsv','hot','cool','gray','igray'}, 'Units', 'normalized', ...
            'Position', [.575,.94,.1,.05], 'Value', 1, 'Callback', @setmap);
        
        gObj.mask_cbx = uicontrol(gObj.fig, 'Style', 'checkbox');
        
        gObj.aHe_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.bHe_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.rotHe_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.aDope_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.bDope_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.rotDope_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.x1_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.y1_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.x2_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.y2_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.ratio_edt = uicontrol(gObj.fig, 'Style', 'edit');
        gObj.nPhotonsOnDetector_edt = uicontrol(gObj.fig, 'Style', 'edit');
        
        gObj.a_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.b_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.rot_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.x_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.y_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.He_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.Dope_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.pos1_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.pos2_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.ratio_txt = uicontrol(gObj.fig, 'Style', 'text');
        gObj.nPhotonsOnDetector_txt = uicontrol(gObj.fig, 'Style', 'text');
        
        linkaxes(gObj.axesArray(1:2),'xy')
        linkaxes(gObj.axesArray(3:5),'xy')
        xyLim = 1.3*max(simParam.aHe,simParam.bHe)*[-1,1];
        set(gObj.axesArray(1), 'XLim', xyLim, 'YLim', xyLim)
        
        %             arrayfun(@(a) set(gObj.axesArray(a), 'XLim', xyLim, 'YLim', xyLim), 1:2);
        arrayfun(@(a) hold(gObj.axesArray(a),'on'), 1:2)
        arrayfun(@(a) colormap(gObj.axesArray(a), simParam.cMap), 3:5);
        
        simParam.elllipse = ellipse_outline(simParam.aHe, simParam.bHe, simParam.rotHe);
        gObj.ellipseArray(1) = plot(gObj.axesArray(1), simParam.elllipse.x, simParam.elllipse.y, 'k--', 'linewidth', 2);
        gObj.ellipseArray(2) = plot(gObj.axesArray(2), simParam.elllipse.x, simParam.elllipse.y, 'k--', 'linewidth', 2);
        
        set(gObj.mask_cbx, 'String', 'show mask',...
            'Value', true,'Units', 'normalized', 'Position', [.55 .5 .04 .04], 'Callback', @updateParameter);
        
        set(gObj.aHe_edt, 'String', simParam.aHe,'Units', 'normalized', 'Position', [.45 .85 .04 .04], 'Callback', @updateParameter);
        set(gObj.bHe_edt, 'String', simParam.bHe, 'Units', 'normalized', 'Position', [.5 .85 .04 .04], 'Callback', @updateParameter);
        set(gObj.rotHe_edt, 'String', simParam.rotHe, 'Units', 'normalized', 'Position', [.55 .85 .04 .04], 'Callback', @updateParameter);
        set(gObj.aDope_edt, 'String', simParam.aDope, 'Units', 'normalized', 'Position', [.45 .8 .04 .04], 'Callback', @updateParameter);
        set(gObj.bDope_edt, 'String', simParam.bDope, 'Units', 'normalized', 'Position', [.5 .8 .04 .04], 'Callback', @updateParameter);
        set(gObj.rotDope_edt, 'String', simParam.rotDope, 'Units', 'normalized', 'Position', [.55 .8 .04 .04], 'Callback', @updateParameter);
        set(gObj.x1_edt, 'String', simParam.x1, 'Units', 'normalized', 'Position', [.45 .7 .04 .04], 'Callback', @updateParameter);
        set(gObj.y1_edt, 'String', simParam.y1, 'Units', 'normalized', 'Position', [.5 .7 .04 .04], 'Callback', @updateParameter);
        set(gObj.x2_edt, 'String', simParam.x2, 'Units', 'normalized', 'Position', [.45 .65 .04 .04], 'Callback', @updateParameter);
        set(gObj.y2_edt, 'String', simParam.y2, 'Units', 'normalized', 'Position', [.5 .65 .04 .04], 'Callback', @updateParameter);
        set(gObj.ratio_edt, 'String', simParam.ratio, 'Units', 'normalized', 'Position', [.5 .55 .04 .04], 'Callback', @updateParameter);
        set(gObj.nPhotonsOnDetector_edt, 'String', simParam.nPhotonsOnDetector, 'Units', 'normalized', 'Position', [.5 .5 .04 .04], 'Callback', @updateParameter);
        
        set(gObj.a_txt, 'String', 'a', 'Units', 'normalized', 'Position', [.45 .9 .04 .03]);
        set(gObj.b_txt, 'String', 'b', 'Units', 'normalized', 'Position', [.5 .9 .04 .03]);
        set(gObj.rot_txt, 'String', 'rot', 'Units', 'normalized', 'Position', [.55 .9 .04 .03]);
        set(gObj.x_txt, 'String', 'x', 'Units', 'normalized', 'Position', [.45 .75 .04 .03]);
        set(gObj.y_txt, 'String', 'y', 'Units', 'normalized', 'Position', [.5 .75 .04 .03]);
        set(gObj.He_txt, 'String', 'Droplet', 'Units', 'normalized', 'Position', [.4 .85 .04 .04]);
        set(gObj.Dope_txt, 'String', 'Dopi', 'Units', 'normalized', 'Position', [.4 .8 .04 .04]);
        set(gObj.pos1_txt, 'String', 'Dope 1', 'Units', 'normalized', 'Position', [.4 .7 .04 .04]);
        set(gObj.pos2_txt, 'String', 'Dope 2', 'Units', 'normalized', 'Position', [.4 .65 .04 .04]);
        set(gObj.ratio_txt, 'String', 'scattering power ratio', 'Units', 'normalized', 'Position', [.4 .55 .09 .04]);
        set(gObj.nPhotonsOnDetector_txt, 'String', '# photons on detector', 'Units', 'normalized', 'Position', [.4 .5 .09 .04]);
    end
    function thisCloseRequestFcn(~,~,~)
        try
            callerHandle.bool.isValidSimulationFigure = false;
        end
        clear simData simParam savepath
        delete(gObj.fig.Children)
        delete(gObj.fig)
        clear gObj
    end
end

