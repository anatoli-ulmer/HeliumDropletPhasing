function app = createComponents_BU(app)
    app.UIFigure = uifigure; %('Visible', 'off');
    app.UIFigure.Color = [0.94 0.94 0.94];
    app.UIFigure.Position = [600 100 392 248];
    app.UIFigure.Name = 'Simulate Scattering';
    app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @simPatternCloseRequest, true);
%     app.UIFigure.KeyPressFcn = @keypressfun;
    
    app.colormapDropDown = uidropdown(app.UIFigure);
    app.colormapDropDown.Items = {'imorgen', 'morgenstemning', 'wjet','r2b',...
        'parula','jet','hsv','hot','cool','gray','igray'};
%     app.colormapDropDown.Position = [191 102 100 22];
    app.colormapDropDown.Value = 'Parula';
    
    app.maskCheckBox = uicheckbox(app.UIFigure);

    app.aDropEditField = uieditfield(app.UIFigure, 'numeric');
    app.bDropEditField = uieditfield(app.UIFigure, 'numeric');
    app.rotationDropEditField = uieditfield(app.UIFigure, 'numeric');
    app.aDopeEditField = uieditfield(app.UIFigure, 'numeric');
    app.bDopeEditField = uieditfield(app.UIFigure, 'numeric');
    app.rotationDopeEditField = uieditfield(app.UIFigure, 'numeric');
    app.x1DopeEditField = uieditfield(app.UIFigure, 'numeric');
    app.y1DopeEditField = uieditfield(app.UIFigure, 'numeric');
    app.x2DopeEditField = uieditfield(app.UIFigure, 'numeric');
    app.y2DopeEditField = uieditfield(app.UIFigure, 'numeric');
    app.scatteringRatioEditField = uieditfield(app.UIFigure, 'numeric');
    app.nPhotonsEditField = uieditfield(app.UIFigure, 'numeric');
    app.savepathEditField = uieditfield(app.UIFigure, 'text');

    app.aFieldLabel = uilabel(app.UIFigure);
    app.bFieldLabel = uilabel(app.UIFigure);
    app.rotationFieldLabel = uilabel(app.UIFigure);
    app.xFieldLabel = uilabel(app.UIFigure);
    app.yFieldLabel = uilabel(app.UIFigure);
    app.dropFieldLabel = uilabel(app.UIFigure);
    app.dopeFieldLabel = uilabel(app.UIFigure);
    app.pos1FieldLabel = uilabel(app.UIFigure);
    app.pos2FieldLabel = uilabel(app.UIFigure);
    app.scatteringRatioFieldLabel = uilabel(app.UIFigure);
    app.nPhotonsFieldLabel = uilabel(app.UIFigure);
    app.savepathEditFieldLabel = uilabel(app.UIFigure);
    
    set(app.colormapDropDown, 'Units', 'normalized', 'Position', [.575,.94,.1,.05], 'Value', 'imorgen', 'Callback', @setmap);
    set(app.maskCheckBox, 'Text', 'show mask', 'Value', true,'Units', 'normalized', 'Position', [.55 .5 .04 .04], 'Callback', @updateParameter);
    
    set(app.aDropEditField, 'String', app.par.aHe,'Units', 'normalized', 'Position', [.45 .85 .04 .04], 'Callback', @updateParameter);
    set(app.bDropEditField, 'String', app.par.bHe, 'Units', 'normalized', 'Position', [.5 .85 .04 .04], 'Callback', @updateParameter);
    set(app.rotationDropEditField, 'String', app.par.rotHe, 'Units', 'normalized', 'Position', [.55 .85 .04 .04], 'Callback', @updateParameter);
    set(app.aDopeEditField, 'String', app.par.aDope, 'Units', 'normalized', 'Position', [.45 .8 .04 .04], 'Callback', @updateParameter);
    set(app.bDopeEditField, 'String', app.par.bDope, 'Units', 'normalized', 'Position', [.5 .8 .04 .04], 'Callback', @updateParameter);
    set(app.rotationDopeEditField, 'String', app.par.rotDope, 'Units', 'normalized', 'Position', [.55 .8 .04 .04], 'Callback', @updateParameter);
    set(app.x1DopeEditField, 'String', app.par.x1, 'Units', 'normalized', 'Position', [.45 .7 .04 .04], 'Callback', @updateParameter);
    set(app.y1DopeEditField, 'String', app.par.y1, 'Units', 'normalized', 'Position', [.5 .7 .04 .04], 'Callback', @updateParameter);
    set(app.x2DopeEditField, 'String', app.par.x2, 'Units', 'normalized', 'Position', [.45 .65 .04 .04], 'Callback', @updateParameter);
    set(app.y2DopeEditField, 'String', app.par.y2, 'Units', 'normalized', 'Position', [.5 .65 .04 .04], 'Callback', @updateParameter);
    set(app.scatteringRatioEditField, 'String', app.par.ratio, 'Units', 'normalized', 'Position', [.5 .55 .04 .04], 'Callback', @updateParameter);
    set(app.nPhotonsEditField, 'String', app.par.nPhotonsOnDetector, 'Units', 'normalized', 'Position', [.5 .5 .04 .04], 'Callback', @updateParameter);
    
    set(app.aFieldLabel, 'Text', 'a', 'Units', 'normalized', 'Position', [.45 .9 .04 .03]);
    set(app.bFieldLabel, 'Text', 'b', 'Units', 'normalized', 'Position', [.5 .9 .04 .03]);
    set(app.rotationFieldLabel, 'Text', 'rot', 'Units', 'normalized', 'Position', [.55 .9 .04 .03]);
    set(app.xFieldLabel, 'Text', 'x', 'Units', 'normalized', 'Position', [.45 .75 .04 .03]);
    set(app.yFieldLabel, 'Text', 'y', 'Units', 'normalized', 'Position', [.5 .75 .04 .03]);
    set(app.dropFieldLabel, 'Text', 'Droplet', 'Units', 'normalized', 'Position', [.4 .85 .04 .04]);
    set(app.dopeFieldLabel, 'Text', 'Dopi', 'Units', 'normalized', 'Position', [.4 .8 .04 .04]);
    set(app.pos1FieldLabel, 'Text', 'Dope 1', 'Units', 'normalized', 'Position', [.4 .7 .04 .04]);
    set(app.pos2FieldLabel, 'Text', 'Dope 2', 'Units', 'normalized', 'Position', [.4 .65 .04 .04]);
    set(app.ratio_txt, 'Text', 'scattering power ratio', 'Units', 'normalized', 'Position', [.4 .55 .09 .04]);
    set(app.nPhotonsOnDetector_txt, 'Text', '# photons on detector', 'Units', 'normalized', 'Position', [.4 .5 .09 .04]);
    
    app.singleRealUIAxes = uiaxes(app.UIFigure);
    app.singleRealUIAxes.Position = [0 0.5 0.3 0.5];
    
    app.doubleRealUIAxes = uiaxes(app.UIFigure);
    app.doubleRealUIAxes.Position = [0.67 0.5 0.3 0.5];
    
    app.singleFourierUIAxes = uiaxes(app.UIFigure);
    app.singleFourierUIAxes.Position = [0 0 0.3 0.5];
    
    app.scatteringUIAxes = uiaxes(app.UIFigure);
    app.scatteringUIAxes.Position = [0.33 0 0.3 0.5];
    
    app.doubleFourierUIAxes = uiaxes(app.UIFigure);
    app.doubleFourierUIAxes.Position = [0.67 0.5 0.3 0.5];
end

