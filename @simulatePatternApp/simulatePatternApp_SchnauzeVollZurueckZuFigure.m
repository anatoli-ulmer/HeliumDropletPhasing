classdef simulatePatternApp
    %SIMPATTERN Summary of this class goes here
    %   Detailed explanation goes here
    
    % Properties that correspond to app components
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
            simParameter.center = 0.5*simParameter.nPixel + 1;
            % Graphics
            simParameter.cLims = [-1,2];
            simParameter.cMap = imorgen;
            simParameter.subtractionScale = 0.9;
            simParameter.YData = 6 * ( [-0.5*simParameter.nPixel(1)+1, 0.5*simParameter.nPixel(1)] );
            simParameter.XData = 6 * ( [-0.5*simParameter.nPixel(2)+1, 0.5*simParameter.nPixel(2)] );
            simParameter.ellipse = ellipse_outline(simParameter.aDrop, simParameter.bDrop, simParameter.rotationDrop);
            simParameter.xyLim = 1.2*max(simParameter.aDrop, simParameter.bDrop)*[-1,1];
            % Rest
            simParameter.isValidApp = false;
            simParameter.savepath = 'C:\Users\Toli\Google Drive\dissertation\2.helium\xfel-img\scattering_simulations';
        end
    end
    
    methods (Access = private)
        function app = startSimulation(app,evt) %#ok<*INUSD>
            app = updateParameter(app);
            app.simData = dopecore_scatt(app.simData, app.simParameter);
            
            app.simData.scatt1 = app.simData.scatt1/sum(app.simData.scatt1(:) .* double(app.simData.mask(:))) * app.simParameter.nPhotonsOnDetector;
            app.simData.scatt2 = app.simData.scatt2/sum(app.simData.scatt2(:) .* double(app.simData.mask(:))) * app.simParameter.nPhotonsOnDetector;
            
            app.simData.scatt1 = imnoise(app.simData.scatt1/1e12,'poisson')*1e12;
            app.simData.scatt2 = imnoise(app.simData.scatt2/1e12,'poisson')*1e12;
            
            if app.cbxObjArray(1).Value
                app.simData.scatt1 = app.simData.scatt1 .* double(app.simData.mask);
                app.simData.scatt2 = app.simData.scatt2 .* double(app.simData.mask);
            end
            
            app = updatePlot(app);
        end
        function app = updateParameter(app,src,evt)
            % Positions
            app.simParameter.aDrop = app.editObjArray(1).Value;
            app.simParameter.bDrop = app.editObjArray(2).Value;
            app.simParameter.rotationDrop = app.editObjArray(3).Value/180*pi;
            app.simParameter.aCore = app.editObjArray(4).Value;
            app.simParameter.bCore = app.editObjArray(5).Value;
            app.simParameter.rotationCore = app.editObjArray(6).Value/180*pi;
            app.simParameter.x1 = app.editObjArray(7).Value;
            app.simParameter.y1 = app.editObjArray(9).Value;
            app.simParameter.x2 = app.editObjArray(8).Value;
            app.simParameter.y2 = app.editObjArray(10).Value;
            % Scattering
            app.simParameter.ratio = app.editObjArray(11).Value;
            app.simParameter.nPhotonsOnDetector = app.editObjArray(12).Value;
            app.simParameter.nDroplet = ( (app.simParameter.aDrop+app.simParameter.bDrop) /2/0.222 )^3;
            app.simParameter.nDopants = ( (app.simParameter.aCore+app.simParameter.bCore) /2/0.222 )^3;
            % Geometry
            app.simParameter.nPixel = size(app.simData.dataCorrected);
            app.simParameter.center = 0.5*app.simParameter.nPixel + 1;
            % Graphics
            app.simParameter.subtractionScale = 0.9;
            app.simParameter.YData = 6 * ( [-0.5*app.simParameter.nPixel(1)+1, 0.5*app.simParameter.nPixel(1)] );
            app.simParameter.XData = 6 * ( [-0.5*app.simParameter.nPixel(2)+1, 0.5*app.simParameter.nPixel(2)] );
            app.simParameter.ellipse = ellipse_outline(app.simParameter.aDrop, app.simParameter.bDrop, app.simParameter.rotationDrop);
            app.simParameter.xyLim = 1.2*max(app.simParameter.aDrop,app.simParameter.bDrop)*[-1,1];
            % Rest
            app.simParameter.isValidApp = true;
            app.simParameter.savepath = app.editObjArray(13).Value;
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
            app.axesObjArray(3).CLim = app.simParameter.cLims;
            app.axesObjArray(4).CLim = app.simParameter.cLims;
            app.axesObjArray(5).CLim = app.simParameter.cLims;
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
    
    % Callbacks that handle component events
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
        function app = thisKeyPressFcn(app,~,evt)
            switch evt.Key
                case 'c'
                    clc
                case 'm'
%                     app.x2_edt.String = num2str(-str2double(app.x1_edt.String));
%                     app.y2_edt.String = num2str(-str2double(app.y1_edt.String));
                    app = startSimulation(app);
            end
        end
        function simPatternCloseRequest(app, event)
            app.simParameter.isValidApp = false;
            % Delete the dialog box
            delete(app)
        end
    end
    
    % Component initialization
    methods (Access = private)
        % Create figObj and components
        function app = createComponents(app)
            fWidth = 1024;
            fHeight = 768;
            
            app.figObj = uifigure('Visible', 'off');
            app.figObj.Color = [0.94 0.94 0.94];
            app.figObj.Position = [200 200 fWidth fHeight];
            app.figObj.Name = 'Simulate Scattering';
            app.figObj.CloseRequestFcn = createCallbackFcn(app, @simPatternCloseRequest, true);
            app.figObj.KeyPressFcn = @app.thisKeyPressFcn;
            
            app.popupObjArray(1) = uidropdown(app.figObj);
            app.popupObjArray(1).Items = {'imorgen', 'morgenstemning', 'wjet','r2b',...
                'parula','jet','hsv','hot','cool','gray','igray'};
            app.popupObjArray(1).Position = [fWidth, fHeight, fWidth, fHeight].*[.575,.94,.1,.05];
            app.popupObjArray(1).Value = 1;
            app.popupObjArray(1).ValueChangedFcn = @app.setColormap;
            
            app.cbxObjArray(1) = uicheckbox(app.figObj);
            
            app.editObjArray(1) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(2) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(3) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(4) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(5) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(6) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(7) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(9) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(8) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(10) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(11) = uieditfield(app.figObj, 'numeric');
            app.editObjArray(12) = uieditfield(app.figObj, 'numeric');
            
            app.editObjArray(13) = uieditfield(app.figObj, 'text');
            app.editObjArray(13).Position = [fWidth, fHeight, fWidth, fHeight].*[0.13 0.01 0.7 0.04];
            
            app.textObjArray(1) = uilabel(app.figObj);
            app.textObjArray(2) = uilabel(app.figObj);
            app.textObjArray(3) = uilabel(app.figObj);
            app.textObjArray(6) = uilabel(app.figObj);
            app.textObjArray(7) = uilabel(app.figObj);
            app.textObjArray(4) = uilabel(app.figObj);
            app.textObjArray(5) = uilabel(app.figObj);
            app.textObjArray(8) = uilabel(app.figObj);
            app.textObjArray(9) = uilabel(app.figObj);
            app.textObjArray(10) = uilabel(app.figObj);
            app.textObjArray(11) = uilabel(app.figObj);
            
            app.textObjArray(12) = uilabel(app.figObj);
            app.textObjArray(12).Position = [fWidth, fHeight, fWidth, fHeight].*[0.03 0.01 0.1 0.04];
            app.textObjArray(12).Text = 'Savepath: ';
            
            set(app.cbxObjArray(1), 'Text', 'show mask', 'Value', true, 'Position', [fWidth, fHeight, fWidth, fHeight].*[.55 .5 .04 .04]); %, 'Callback', @app.updateParameter);
            
            set(app.editObjArray(1), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.45 .85 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(2), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.5 .85 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(3), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.55 .85 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(4), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.45 .8 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(5), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.5 .8 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(6), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.55 .8 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(7), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.45 .7 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(9), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.5 .7 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(8), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.45 .65 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(10), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.5 .65 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(11), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.5 .55 .04 .04]); %, 'Callback', @app.updateParameter);
            set(app.editObjArray(12), 'Position', [fWidth, fHeight, fWidth, fHeight].*[.5 .5 .04 .04]); %, 'Callback', @app.updateParameter);
            
            set(app.textObjArray(1), 'Text', 'a',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.45 .9 .04 .03]);
            set(app.textObjArray(2), 'Text', 'b',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.5 .9 .04 .03]);
            set(app.textObjArray(3), 'Text', 'rot',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.55 .9 .04 .03]);
            set(app.textObjArray(6), 'Text', 'x',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.45 .75 .04 .03]);
            set(app.textObjArray(7), 'Text', 'y',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.5 .75 .04 .03]);
            set(app.textObjArray(4), 'Text', 'Droplet',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.4 .85 .04 .04]);
            set(app.textObjArray(5), 'Text', 'Dopi',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.4 .8 .04 .04]);
            set(app.textObjArray(8), 'Text', 'Core 1',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.4 .7 .04 .04]);
            set(app.textObjArray(9), 'Text', 'Core 2',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.4 .65 .04 .04]);
            set(app.textObjArray(10), 'Text', 'scattering power ratio',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.4 .55 .09 .04]);
            set(app.textObjArray(11), 'Text', '# photons on detector',  'Position', [fWidth, fHeight, fWidth, fHeight].*[.4 .5 .09 .04]);
            
            app.axesObjArray(1) = axes(app.figObj);
            app.axesObjArray(2) = axes(app.figObj);
            app.axesObjArray(3) = axes(app.figObj);
            app.axesObjArray(4) = axes(app.figObj);
            app.axesObjArray(5) = axes(app.figObj);
            
            app.imgObjArray(1) = imagesc(app.axesObjArray(1), 'CData', ones(app.simParameter.nPixel), 'XData', app.simParameter.XData, 'YData', app.simParameter.YData);
            app.imgObjArray(2) = imagesc(app.axesObjArray(2), 'CData', ones(app.simParameter.nPixel), 'XData', app.simParameter.XData, 'YData', app.simParameter.YData);
            app.imgObjArray(3) = imagesc(app.axesObjArray(3), 'CData', ones(app.simParameter.nPixel), app.simParameter.cLims);
            app.imgObjArray(4) = imagesc(app.axesObjArray(4), 'CData', ones(app.simParameter.nPixel), app.simParameter.cLims);
            app.imgObjArray(5) = imagesc(app.axesObjArray(5), 'CData', ones(app.simParameter.nPixel), app.simParameter.cLims);
            
%             app.cBarArray(1) = colorbar(app.axesObjArray(1));
%             app.cBarArray(2) = colorbar(app.axesObjArray(2));
%             app.cBarArray(3) = colorbar(app.axesObjArray(3));
%             app.cBarArray(4) = colorbar(app.axesObjArray(4));
%             app.cBarArray(5) = colorbar(app.axesObjArray(5));
            
            hold(app.axesObjArray(1),'on');
            hold(app.axesObjArray(2),'on');
            
            app.imgObjArray(6) = plot(app.axesObjArray(1), app.simParameter.ellipse.x, app.simParameter.ellipse.y, 'k--', 'linewidth', 2);
            app.imgObjArray(7) = plot(app.axesObjArray(2), app.simParameter.ellipse.x, app.simParameter.ellipse.y, 'k--', 'linewidth', 2);
            
            app.axesObjArray(1).Position =	[0     0.5 0.3 0.5];
            app.axesObjArray(2).Position =  [0.67  0.5 0.3 0.5];
            app.axesObjArray(3).Position =	[0     0   0.3 0.5];
            app.axesObjArray(4).Position =	[0.33  0   0.3 0.5];
            app.axesObjArray(5).Position =	[0.67  0   0.3 0.5];
            
            app.axesObjArray(1).Toolbar.Visible = false;
            
            app.axesObjArray(1).Colormap = r2b;
            app.axesObjArray(2).Colormap = r2b;
            app.axesObjArray(3).Colormap = app.simParameter.cMap;
            app.axesObjArray(4).Colormap = app.simParameter.cMap;
            app.axesObjArray(5).Colormap = app.simParameter.cMap;
            
            app = updateEditFields(app);
            
            linkaxes([app.axesObjArray(1), app.axesObjArray(2)], 'xy')
            linkaxes([app.axesObjArray(3), app.axesObjArray(4), app.axesObjArray(5)], 'xy')
            
            app.figObj.Visible = 'on';
            drawnow;
            
            
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        % Construct app
        function app = simulatePatternApp(varargin)
            
            % Initialize default parameter
            app.simParameter = app.initParameter();
            
            % Create figObj and components
            createComponents(app)
            
            % Register the app with App Designer
%             registerApp(app, app.figObj)
            
            % Execute the startup function
            runStartupFcn(app, @(app)StartupFcn(app, varargin{:}))
            
            if nargout == 0
                clear app
            end
        end
        % Code that executes before app deletion
        function delete(app)
            
            % Delete figObj when app is deleted
            delete(app.figObj)
        end
    end
    
end

