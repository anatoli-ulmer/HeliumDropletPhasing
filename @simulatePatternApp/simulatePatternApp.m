classdef simulatePatternApp < handle
    %% SIMPATTERN Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties that correspond to app components
    properties (Access = public)
        figObj = gobjects(1,1)
        axesObjArray = gobjects(5,1)
        cBarArray = gobjects(5,1)
        imgObjArray = gobjects(7,1)
        cbxObjArray = gobjects(1,1)
        popupObjArray = gobjects(1,1)
        editObjArray = gobjects(13,1)
        textObjArray = gobjects(12,1)
        CallingApp
        simData
        simParameter
    end
   
    methods (Static)
        function simParameter = initParameter(app)
            % Positions
            simParameter.aDrop = 184;
            simParameter.bDrop = 188;
            simParameter.rotationDrop = 191/180*pi;
            simParameter.aCore = 17;
            simParameter.bCore = 8;
            simParameter.rotationCore = 150/180*pi;
            simParameter.x1 = -93;
            simParameter.y1 = -108;
            simParameter.x2 = 93;
            simParameter.y2 = 108;
            % Scattering
            simParameter.ratio = 7;
            simParameter.nPhotonsOnDetector = 1e7;
            simParameter.nDroplet = ( (simParameter.aDrop+simParameter.bDrop) /2/0.222 )^3;
            simParameter.nDopants = ( (simParameter.aCore+simParameter.bCore) /2/0.222 )^3;
            % Geometry
            simParameter.nPixel = [1024,1024];
            simParameter.center = 0.5*simParameter.nPixel + 0.5;
            % Graphics
            simParameter.cLims = [-1,2];
            simParameter.cMap = imorgen;
            simParameter.subtractionScale = 0.9;
            simParameter.YData = 6 * ( [-0.5*simParameter.nPixel(1)+1, 0.5*simParameter.nPixel(1)] );
            simParameter.XData = 6 * ( [-0.5*simParameter.nPixel(2)+1, 0.5*simParameter.nPixel(2)] );
            simParameter.ellipse = ellipse_outline(simParameter.aDrop, simParameter.bDrop, simParameter.rotationDrop);
            simParameter.xyLim = 1.2*max(simParameter.aDrop, simParameter.bDrop)*[-1,1] + [0,6];
            % Rest
            simParameter.isValidApp = false;
            simParameter.savepath = 'C:\Users\Toli\Google Drive\dissertation\2.helium\xfel-img\scattering_simulations';
        end
    end
    
    methods (Access = private)
        function app = startSimulation(app,src,evt) %#ok<*INUSD>
            fprintf('Starting scattering simulation ...\n')
            drawnow;
            app = updateParameter(app);
            app.simData = dopecore_scatt(app.simData, app.simParameter);
            
            app.simData.scatt1 = app.simData.scatt1/sum(app.simData.scatt1(:) .* double(app.simData.mask(:))) * app.simParameter.nPhotonsOnDetector;
            app.simData.scatt2 = app.simData.scatt2/sum(app.simData.scatt2(:) .* double(app.simData.mask(:))) * app.simParameter.nPhotonsOnDetector;
            
            app.simData.scatt1 = imnoise(app.simData.scatt1/1e12,'poisson')*1e12;
            app.simData.scatt2 = imnoise(app.simData.scatt2/1e12,'poisson')*1e12;
            
            if app.cbxObjArray(1).Value
                app.simData.scatt1(~app.simData.mask) = nan;
                app.simData.scatt2(~app.simData.mask) = nan;
            end
            
            app = updatePlot(app);
        end
        function app = updateParameter(app,src,evt)
            % Positions
            app.simParameter.aDrop = str2num_fast(app.editObjArray(1).String);
            app.simParameter.bDrop = str2num_fast(app.editObjArray(2).String);
            app.simParameter.rotationDrop = str2num_fast(app.editObjArray(3).String)/180*pi;
            app.simParameter.aCore = str2num_fast(app.editObjArray(4).String);
            app.simParameter.bCore = str2num_fast(app.editObjArray(5).String);
            app.simParameter.rotationCore = str2num_fast(app.editObjArray(6).String)/180*pi;
            app.simParameter.x1 = str2num_fast(app.editObjArray(7).String);
            app.simParameter.y1 = str2num_fast(app.editObjArray(9).String);
            app.simParameter.x2 = str2num_fast(app.editObjArray(8).String);
            app.simParameter.y2 = str2num_fast(app.editObjArray(10).String);
            % Scattering
            app.simParameter.ratio = str2num_fast(app.editObjArray(11).String);
            app.simParameter.nPhotonsOnDetector = str2num_fast(app.editObjArray(12).String);
            app.simParameter.nDroplet = ( (app.simParameter.aDrop+app.simParameter.bDrop) /2/0.222 )^3;
            app.simParameter.nDopants = ( (app.simParameter.aCore+app.simParameter.bCore) /2/0.222 )^3;
            % Geometry
            app.simParameter.nPixel = size(app.simData.dataCorrected);
            app.simParameter.center = 0.5*app.simParameter.nPixel + 0.5;
            % Graphics
            app.simParameter.subtractionScale = 0.9;
            app.simParameter.YData = 6 * ( [-0.5,0.5]*app.simParameter.nPixel(1) + [0,1] );
            app.simParameter.XData = 6 * ( [-0.5,0.5]*app.simParameter.nPixel(2) + [0,1] );
            app.simParameter.ellipse = ellipse_outline(app.simParameter.aDrop, app.simParameter.bDrop, app.simParameter.rotationDrop);
            app.simParameter.xyLim = 1.2*max(app.simParameter.aDrop,app.simParameter.bDrop)*[-1,1];
            % Rest
            app.simParameter.isValidApp = true;
            app.simParameter.savepath = app.editObjArray(13).String;
        end
        function app = updateEditFields(app,evt)
            % Positions
            app.editObjArray(1).String = app.simParameter.aDrop;
            app.editObjArray(2).String = app.simParameter.bDrop;
            app.editObjArray(3).String = app.simParameter.rotationDrop/pi*180;
            app.editObjArray(4).String = app.simParameter.aCore;
            app.editObjArray(5).String = app.simParameter.bCore;
            app.editObjArray(6).String = app.simParameter.rotationCore/pi*180;
            app.editObjArray(7).String = app.simParameter.x1;
            app.editObjArray(9).String = app.simParameter.y1;
            app.editObjArray(8).String = app.simParameter.x2;
            app.editObjArray(10).String = app.simParameter.y2;
            % Scattering
            app.editObjArray(11).String = app.simParameter.ratio;
            app.editObjArray(12).String = app.simParameter.nPhotonsOnDetector;
            % Rest
            app.editObjArray(13).String = app.simParameter.savepath;
        end
        function app = updatePlot(app,evt)
            app.imgObjArray(1).CData = app.simData.scene1 - app.simParameter.subtractionScale*app.simData.droplet;
            app.imgObjArray(2).CData = app.simData.scene2 - app.simParameter.subtractionScale*app.simData.droplet;
            app.imgObjArray(3).CData = log10(abs(app.simData.scatt1));
            app.imgObjArray(4).CData = log10(abs(app.simData.dataCorrected));
            app.imgObjArray(5).CData = log10(abs(app.simData.scatt2));
            app.imgObjArray(6).XData = app.simParameter.ellipse.x;
            app.imgObjArray(6).YData = app.simParameter.ellipse.y;
            app.imgObjArray(7).XData = app.simParameter.ellipse.x;
            app.imgObjArray(7).YData = app.simParameter.ellipse.y;
            
            app.axesObjArray(1).XLim = app.simParameter.xyLim;
            app.axesObjArray(1).YLim = app.simParameter.xyLim;
            app.axesObjArray(1).CLim = max(abs(app.imgObjArray(1).CData(:)))*[-1 1];
            app.axesObjArray(2).XLim = app.simParameter.xyLim;
            app.axesObjArray(2).YLim = app.simParameter.xyLim;
            app.axesObjArray(2).CLim = max(abs(app.imgObjArray(2).CData(:)))*[-1 1];
            app.axesObjArray(3).CLim = log10(app.simParameter.cLims);
            app.axesObjArray(4).CLim = log10(app.simParameter.cLims);
            app.axesObjArray(5).CLim = log10(app.simParameter.cLims);
            fprintf('\tdone!\n')
        end
        function app = createSaveFig(app,evt)
%             app.save.fig = figure('Units', 'inches',...
%                 'Position', [fWidth, fHeight, fWidth, fHeight].*[1,1,size(app.simData.dataCorrected,2)/size(app.simData.dataCorrected,1)*3,3],...
%                 'PaperUnits', 'inches', 'PaperSize', [size(app.simData.dataCorrected,2)/size(app.simData.dataCorrected,1)*3,3],...
%                 'PaperPosition', [0,0,size(app.simData.dataCorrected,2)/size(app.simData.dataCorrected,1)*3,3]);
%             app.save.ax = axes( 'Position', [fWidth, fHeight, fWidth, fHeight].*[0,0,1,1]);
%             app.save.plt = imagesc(zeros(app.simParameter.nPixel), 'parent', app.save.ax, app.simParameter.cLims);
%             colormap(app.save.ax, app.cmap_popup.String{app.cmap_popup.String}); colorbar(app.save.ax, 'off');
%             set(app.save.ax,'visible','off'); grid(app.save.ax, 'off');
%             drawnow;
        end
        function setColormap(app,src,evt)
            app.simParameter.cMap = app.popupObjArray(1).String{app.popupObjArray(1).Value};
            colormap(app.axesObjArray(3), app.simParameter.cMap);
            colormap(app.axesObjArray(4), app.simParameter.cMap);
            colormap(app.axesObjArray(5), app.simParameter.cMap);
        end
        function argout = getSimulation(app)
            argout = app.simData.scatt1 ;
        end
    end
    
    %% Callbacks that handle component events
    methods (Access = private)
        % Code that executes after component creation
        function app = StartupFcn(app, newData, newMask, newParameter, newSavepath, mainapp)
            if exist('newData','var')
                app.simData.dataCorrected = newData;
            else
                app.simData.dataCorrected = zeros(app.simParameter.nPixel);
            end
            if exist('newMask','var')
                app.simData.mask = newMask;
            else
                app.simData.mask = ~isnan(app.simData.dataCorrected);
            end
            if exist('newParameter','var')
                app.simParameter = copyFields(app.simParameter, newParameter);
            end
            if exist('newSavepath','var')
                app.simParameter.savepath = newSavepath;
            end
            if exist('mainapp','var')
                % Store main app in property for CloseRequestFcn to use
                app.CallingApp = mainapp;
            end
            
            app.simData.dataCorrected(~app.simData.mask) = nan;
            app = updateEditFields(app);
            app = startSimulation(app);
            app.simParameter.isValidApp = true;
        end
        function app = thisKeyReleaseFcn(app,~,evt)
            switch evt.Key
                case 'c'
                    clc
                case 'm'
%                     app.x2_edt.String = num2str(-str2double(app.x1_edt.String));
%                     app.y2_edt.String = num2str(-str2double(app.y1_edt.String));
                    app = startSimulation(app);
            end
        end
        function thisCloseRequestFcn(app,src,evt)
            app.simParameter.isValidApp = false;
            % Delete the dialog box
            delete(app)
        end
    end
    
    %% Component initialization
    methods (Access = private)
        %% Create figObj and components
        function app = createComponents(app)
            app.figObj = findobj(groot,'Tag','simFigure');
            if isgraphics(app.figObj), return; end
            
            fWidth = 1280;
            fHeight = 800;
            
            app.figObj = figure('Visible', 'off');
            app.figObj.Color = [1 1 1];
            app.figObj.Position = [200 200 fWidth fHeight];
            app.figObj.Name = 'Simulate Scattering';
            app.figObj.Tag = 'simFigure';
            app.figObj.CloseRequestFcn = @app.thisCloseRequestFcn;
            app.figObj.KeyReleaseFcn = @app.thisKeyReleaseFcn;
            
            
            app.axesObjArray(1) = mysubplot(2,3,1,'parent',app.figObj);
            app.axesObjArray(2) = mysubplot(2,3,3,'parent',app.figObj);
            app.axesObjArray(3) = mysubplot(2,3,4,'parent',app.figObj);
            app.axesObjArray(4) = mysubplot(2,3,5,'parent',app.figObj);
            app.axesObjArray(5) = mysubplot(2,3,6,'parent',app.figObj);
            
            app.imgObjArray(1) = imagesc(app.axesObjArray(1), 'CData', ones(app.simParameter.nPixel), 'XData', app.simParameter.XData, 'YData', app.simParameter.YData);
            app.imgObjArray(2) = imagesc(app.axesObjArray(2), 'CData', ones(app.simParameter.nPixel), 'XData', app.simParameter.XData, 'YData', app.simParameter.YData);
            app.imgObjArray(3) = imagesc(app.axesObjArray(3), 'CData', ones(app.simParameter.nPixel), app.simParameter.cLims);
            app.imgObjArray(4) = imagesc(app.axesObjArray(4), 'CData', ones(app.simParameter.nPixel), app.simParameter.cLims);
            app.imgObjArray(5) = imagesc(app.axesObjArray(5), 'CData', ones(app.simParameter.nPixel), app.simParameter.cLims);
            
            hold(app.axesObjArray(1),'on'); hold(app.axesObjArray(2),'on');
            app.imgObjArray(6) = plot(app.axesObjArray(1), app.simParameter.ellipse.x, app.simParameter.ellipse.y, 'k--', 'linewidth', 2);
            app.imgObjArray(7) = plot(app.axesObjArray(2), app.simParameter.ellipse.x, app.simParameter.ellipse.y, 'k--', 'linewidth', 2);
            
            %             app.cBarArray(1) = colorbar(app.axesObjArray(1));
            %             app.cBarArray(2) = colorbar(app.axesObjArray(2));
            %             app.cBarArray(3) = colorbar(app.axesObjArray(3));
            %             app.cBarArray(4) = colorbar(app.axesObjArray(4));
            %             app.cBarArray(5) = colorbar(app.axesObjArray(5));
            linkaxes([app.axesObjArray(1), app.axesObjArray(2)], 'xy')
            linkaxes([app.axesObjArray(3), app.axesObjArray(4), app.axesObjArray(5)], 'xy')
            %             app.axesObjArray(1).Toolbar.Visible = false;
            
            app.axesObjArray(1).Colormap = r2b;
            app.axesObjArray(2).Colormap = r2b;
            app.axesObjArray(3).Colormap = app.simParameter.cMap;
            app.axesObjArray(4).Colormap = app.simParameter.cMap;
            app.axesObjArray(5).Colormap = app.simParameter.cMap;
            
            app.popupObjArray(1) = uicontrol('parent', app.figObj, 'Style', 'popup', 'String', ...
                {'imorgen', 'morgenstemning', 'wjet','r2b','parula','jet','hsv','hot','cool','gray','igray'},...
                'Units', 'normalized', 'Position', [.575,.94,.1,.05], 'Callback', @app.setColormap, 'Value', 1);
            
            app.editObjArray(1) = uicontrol(app.figObj, 'Style', 'edit', ...'String', app.parameter.aDrop,...
                'Units', 'normalized', 'Position', [.45 .85 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(2) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.bHe,...
                'Units', 'normalized', 'Position', [.5 .85 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(3) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.rotHe,...
                'Units', 'normalized', 'Position', [.55 .85 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(4) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.aDope,...
                'Units', 'normalized', 'Position', [.45 .8 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(5) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.bDope,...
                'Units', 'normalized', 'Position', [.5 .8 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(6) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.rotDope,...
                'Units', 'normalized', 'Position', [.55 .8 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(7) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.x1,...
                'Units', 'normalized', 'Position', [.45 .7 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(8) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.y1,...
                'Units', 'normalized', 'Position', [.5 .7 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(9) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.x2,...
                'Units', 'normalized', 'Position', [.45 .65 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(10) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.y2,...
                'Units', 'normalized', 'Position', [.5 .65 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(11) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.ratio,...
                'Units', 'normalized', 'Position', [.5 .55 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(12) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.nPhot,...
                'Units', 'normalized', 'Position', [.5 .5 .04 .04], 'Callback', @app.startSimulation);
            app.editObjArray(13) = uicontrol(app.figObj, 'Style', 'edit', ...'String', params.nPhot,...
                'Units', 'normalized', 'Position', [.13 .01 .7 .04], 'Callback', @app.startSimulation);
            
            app.cbxObjArray(1) = uicontrol(app.figObj, 'Style', 'checkbox', 'String', 'show mask',...
                'Value', true,'Units', 'normalized', 'Position', [.55 .5 .08 .04], 'Callback', @app.startSimulation);
            
            app.textObjArray(1) = uicontrol(app.figObj, 'Style', 'text', 'String', 'a',...
                'Units', 'normalized', 'Position', [.45 .9 .04 .03], 'Callback', @app.startSimulation);
            app.textObjArray(2) = uicontrol(app.figObj, 'Style', 'text', 'String', 'b',...
                'Units', 'normalized', 'Position', [.5 .9 .04 .03], 'Callback', @app.startSimulation);
            app.textObjArray(3) = uicontrol(app.figObj, 'Style', 'text', 'String', 'angle',...
                'Units', 'normalized', 'Position', [.55 .9 .04 .03], 'Callback', @app.startSimulation);
            app.textObjArray(4) = uicontrol(app.figObj, 'Style', 'text', 'String', 'x',...
                'Units', 'normalized', 'Position', [.45 .75 .04 .03], 'Callback', @app.startSimulation);
            app.textObjArray(5) = uicontrol(app.figObj, 'Style', 'text', 'String', 'y',...
                'Units', 'normalized', 'Position', [.5 .75 .04 .03], 'Callback', @app.startSimulation);
            app.textObjArray(6) = uicontrol(app.figObj, 'Style', 'text', 'String', 'Droplet',...
                'Units', 'normalized', 'Position', [.4 .85 .04 .04], 'Callback', @app.startSimulation);
            app.textObjArray(7) = uicontrol(app.figObj, 'Style', 'text', 'String', 'Dopi',...
                'Units', 'normalized', 'Position', [.4 .8 .04 .04], 'Callback', @app.startSimulation);
            app.textObjArray(8) = uicontrol(app.figObj, 'Style', 'text', 'String', 'Dope 1',...
                'Units', 'normalized', 'Position', [.4 .7 .04 .04], 'Callback', @app.startSimulation);
            app.textObjArray(9) = uicontrol(app.figObj, 'Style', 'text', 'String', 'Dope 2',...
                'Units', 'normalized', 'Position', [.4 .65 .04 .04], 'Callback', @app.startSimulation);
            app.textObjArray(10) = uicontrol(app.figObj, 'Style', 'text', 'String', 'scattering power ratio',...
                'Units', 'normalized', 'Position', [.4 .55 .09 .04], 'Callback', @app.startSimulation);
            app.textObjArray(11) = uicontrol(app.figObj, 'Style', 'text', 'String', '# photons on detector',...
                'Units', 'normalized', 'Position', [.4 .5 .09 .04], 'Callback', @app.startSimulation);
            
            app = updateEditFields(app);
            
            app.figObj.Visible = 'on';
        end
    end
    %% App creation and deletion
    methods (Access = public)
        %% Construct app
        function app = simulatePatternApp(varargin)
            
            % Initialize default parameter
            app.simParameter = app.initParameter();
            
            % Create figObj and components
            createComponents(app)
            
            % Execute the startup function
            StartupFcn(app, varargin{:})
            
            if nargout == 0
                clear app
            end
        end
        %% Code that executes before app deletion
        function delete(app)
            
            % Delete figObj when app is deleted
            delete(app.figObj)
        end
    end
    
end

