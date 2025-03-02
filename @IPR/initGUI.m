function obj = initGUI(obj)

%% Create graphics objects if they don't exist
if isempty(obj.go)
    obj.go.figure = gobjects(1);
    obj.go.axes = gobjects(1, 6);
    obj.go.droplet.axes = gobjects(1, 2);
    obj.go.image = gobjects(2, 2);
    obj.go.droplet.image = gobjects(1, 2);
end
if ~isgraphics(obj.go.figure)

    %% figure
    obj.go.figure(1) = getFigure([], ...
        'NumberTitle', 'off', ...
        'Name', 'Iterative Phasing GUI', ...
        'Tag', 'figure_IPR');

    obj.go.figure(1).GraphicsSmoothing = 'off';
    obj.go.figure(1).Interruptible = 'off';

    hUnits = obj.go.figure.Units;
    obj.go.figure.Units = 'pixels';
    obj.go.figure.Position = [1281.8, 41.8, 1278.4, 616.8];
    obj.go.figure.Units = hUnits;

    %% popups
    cMaps = const.colormaps;
    cMaps{end+1} = 'wjet2';

    obj.go.popup(1) = uicontrol('parent', obj.go.figure(1), 'Style', 'popup');
    obj.go.popup(1).String = cMaps;
    obj.go.popup(1).Value = find(strcmp(obj.go.popup(1).String, obj.int_cm));
    obj.go.popup(1).Units = 'normalized';
    obj.go.popup(1).Position = [.57, .94, .05, .05];

    obj.go.popup(2) = uicontrol('parent', obj.go.figure(1), 'Style', 'popup');
    obj.go.popup(2).String = cMaps;
    obj.go.popup(2).Value = find(strcmp(obj.go.popup(2).String, obj.rec_cm));
    obj.go.popup(2).Units = 'normalized';
    obj.go.popup(2).Position = [.92, .94, .05, .05];

    obj.go.popup(3) = uicontrol('parent', obj.go.figure(1), 'Style', 'popup');
    obj.go.popup(3).String = {'', 'linear', 'semilogx', 'semilogy', 'loglog'};
    obj.go.popup(3).Value = 1;
    obj.go.popup(3).Units = 'normalized';
    obj.go.popup(3).Position = [.01, .94, .05, .05];

    obj.go.popup(4) = uicontrol('parent', obj.go.figure(1), 'Style', 'popup');
    obj.go.popup(4).String = {'autoscale', '0:max(abs)', '-max(abs):max(abs)', ...
        '20%:100%', '-max:max', '-pi:pi', '-pi/2:pi/2', '-pi/4:pi/4', ...
        '-pi/8:pi/8', '-0.1:0.1', '0%:50%'};
    obj.go.popup(4).Value = obj.reconrange;
    obj.go.popup(4).Units = 'normalized';
    obj.go.popup(4).Position = [.92, .88, .05, .05];

    obj.go.popup(5) = uicontrol('parent', obj.go.figure(1), 'Style', 'popup');
    obj.go.popup(5).String = {'abs(IMG)^2', 'abs(IMG)', 'real(IMG)', ...
        'imag(IMG)', 'angle(IMG)', 'abs(real(IMG))', 'sign(real(IMG))'};
    obj.go.popup(5).Units = 'normalized';
    obj.go.popup(5).Position = [.58, .025, .05, .025];
    obj.go.popup(5).Value = obj.intpart;

    obj.go.popup(6) = uicontrol('parent', obj.go.figure(1), 'Style', 'popup');
    obj.go.popup(6).String = {'real', 'imag', 'abs', 'angle', 'complex'};
    obj.go.popup(6).Value = find(strcmp(obj.go.popup(6).String, ...
        obj.reconpart));
    obj.go.popup(6).Units = 'normalized';
    obj.go.popup(6).Position = [.92, .01, .05, .05];

    %% checkboxes
    obj.go.checkbox(1) = uicontrol('parent', obj.go.figure(1), 'Style', 'checkbox');
    obj.go.checkbox(1).String = 'subtract ellipsoid';
    obj.go.checkbox(1).Value = obj.substract_shape;
    obj.go.checkbox(1).Units = 'normalized';
    obj.go.checkbox(1).Position = [.92, .14, .05, .05];

    obj.go.checkbox(2) = uicontrol('parent', obj.go.figure(1), 'Style', 'checkbox');
    obj.go.checkbox(2).String = 'log scale';
    obj.go.checkbox(2).Value = iif(strcmp('log', obj.cscale_scatt), 1, 0);
    obj.go.checkbox(2).Units = 'normalized';
    obj.go.checkbox(2).Position = [.52, .01, .05, .05];

    obj.go.checkbox(3) = uicontrol('parent', obj.go.figure(1), 'Style', 'checkbox');
    obj.go.checkbox(3).String = 'show droplet';
    obj.go.checkbox(3).Value = obj.plotting.drawDroplet;
    obj.go.checkbox(3).Units = 'normalized';
    obj.go.checkbox(3).Position = [.92, .07, .05, .05];

    %% edits
    obj.go.edit(1) = uicontrol('parent', obj.go.figure(1), 'Style', 'edit');
    obj.go.edit(1).String = num2str(obj.clims_scatt(1));
    obj.go.edit(1).Units = 'normalized';
    obj.go.edit(1).Position = [.43, .02, .025, .025];

    obj.go.edit(2) = uicontrol('parent', obj.go.figure(1), 'Style', 'edit');
    obj.go.edit(2).String = num2str(obj.clims_scatt(2));
    obj.go.edit(2).Units = 'normalized';
    obj.go.edit(2).Position = [.47, .02, .025, .025];

    obj.go.edit(3) = uicontrol('parent', obj.go.figure(1), 'Style', 'edit');
    obj.go.edit(3).String = num2str(obj.subscale);
    obj.go.edit(3).Units = 'normalized';
    obj.go.edit(3).Position = [.92, .21, .025, .025];

    %% axes & plots

    %% ERRORS
    obj.go.axes(1) = subplot(2, 3, 1, 'Parent', obj.go.figure);
    obj.go.plot.error = gobjects(1,4);
    obj.go.text.error = gobjects(1,4);
    obj.plotting.LineWidth = 2;

    % Fourier Space Error
    obj.go.plot.error(1, 1) = plot(obj.go.axes(1), nan, nan, '--', ...
        'DisplayName', '$|| \left|\tilde{\rho}_n\right| - \sqrt{I_0}|| / || \sqrt{I_0} ||$', 'Color',colorOrder(1), 'LineWidth',obj.plotting.LineWidth);
    hold(obj.go.axes(1), 'on');

    % NRMSD
    obj.go.plot.error(1, 4) = plot(obj.go.axes(1), ...
        1:numel(obj.errors(4, :)), obj.errors(4, :), '-', 'DisplayName', ...
        '$|| \left|\tilde{\rho}_n\right|^2 - I_0|| / || I_0 ||$', 'Color',colorOrder(5), 'LineWidth',obj.plotting.LineWidth);

    % Real Space Error
    obj.go.plot.error(1, 2) = plot(obj.go.axes(1), ...
        1:numel(obj.errors(1, :)), obj.errors(1, :), '--', ...
        'DisplayName', '$||\mathbf{\overline{P}_S}\rho_n|| / ||\mathbf{P_S} \rho_n||$', 'Color',colorOrder(2), 'LineWidth',obj.plotting.LineWidth);

    % Simulation Error
    obj.go.plot.error(1, 3) = plot(obj.go.axes(1), ...
        1:numel(obj.errors(2, :)), obj.errors(2, :), '-', 'DisplayName', ...
        '$||\rho_n - \rho_{sim}|| / ||\rho_{sim}||$', 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth',obj.plotting.LineWidth);

    hold(obj.go.axes(1), 'off');
    
    plotErrorsIdx = 1:4;
    if ~obj.plotting.NRSMD, plotErrorsIdx(4) = []; obj.go.plot.error(1, 4).Visible = false; end
    if isempty(obj.simScene), plotErrorsIdx(3) = []; obj.go.plot.error(1, 3).Visible = false; end
    
    [obj.go.legend(1), hLegObjs] = legend(obj.go.axes(1), obj.go.plot.error([plotErrorsIdx(:)]), 'Interpreter', 'latex', 'Location','south', 'Orientation','horizontal');
    

    obj.go.axes(2) = subplot(2, 3, 4, 'Parent', obj.go.figure);
    cla(obj.go.axes(2));
    obj.go.plot.error(2, 1) = copyobj(obj.go.plot.error(1, 1), obj.go.axes(2));
    obj.go.plot.error(2, 4) = copyobj(obj.go.plot.error(1, 4), obj.go.axes(2));
    obj.go.plot.error(2, 2) = copyobj(obj.go.plot.error(1, 2), obj.go.axes(2));
    obj.go.plot.error(2, 3) = copyobj(obj.go.plot.error(1, 3), obj.go.axes(2));


    grid(obj.go.axes(1), 'on');
    grid(obj.go.axes(2), 'on');

%     obj.go.legend(2) = legend(obj.go.axes(2), 'Interpreter', 'latex', 'Location','northeast', 'NumColumns',1);



%     shrinkLegend(obj.go.legend(1), hLegObjs);
%     flipLegend(obj.go.legend(1), hLegObjs, .75)
%     obj.go.legend(1).Box = 'on';
    obj.go.axes(1).OuterPosition = [0.01,.51,0.35,.44];
    obj.go.axes(2).OuterPosition = [0.01,.01,0.35,.44];
    obj.go.legend(1).Location = 'none';
    obj.go.legend(1).Position = [0.0353    0.4613    0.3403    0.0324];
%     obj.go.legend(1).obj.plotting.LineWidth = 2;
%     obj.go.axes(2).LineWidth = obj.go.axes(1).LineWidth;

    for i=1:2
        for j=1:numel(obj.go.plot.error(i,:))
            obj.go.text.error(i,j) =  text(obj.go.axes(i), 0, 0, 0, '', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
                'Visible', obj.go.plot.error(i,j).Visible);
        end
    end
   
    %% create images

    obj.go.axes(3) = subplot(2, 3, 2, 'Parent', obj.go.figure);
    obj.go.image(1, 1) = imagesc(obj.go.axes(3), nan);
    obj.go.colorbar(1) = colorbar(obj.go.axes(3));
    obj.go.axes(3).ColorScale = obj.cscale_scatt;

    obj.go.axes(4) = subplot(2, 3, 5, 'Parent', obj.go.figure);
    obj.go.image(1, 2) = imagesc(obj.go.axes(4), nan);
    obj.go.colorbar(2) = colorbar(obj.go.axes(4));
    obj.go.axes(4).ColorScale = obj.cscale_scatt;


    obj.go.droplet.axes(1) = axes(obj.go.figure);
    obj.go.droplet.image(1) = imagesc(obj.go.droplet.axes(1), nan);
    %         obj.go.droplet.colorbar(1) = colorbar(obj.go.droplet.axes(1));
    obj.go.droplet.axes(1).Position = obj.go.axes(3).Position; % needed to avoid weird axes deleting error
    %         obj.go.droplet.axes(1).Color = 'none';
    %         obj.go.droplet.axes(1).XAxis.Color = 'none';
    %         obj.go.droplet.axes(1).YAxis.Color = 'none';
    %         obj.go.droplet.axes(1).Box = 'off';


    obj.go.axes(5) = subplot(2, 3, 3, 'Parent', obj.go.figure);
    obj.go.image(2, 1) = imagesc(obj.go.axes(5), nan);
    obj.go.colorbar(3) = colorbar(obj.go.axes(5));
    obj.go.droplet.axes(1).Position = obj.go.axes(5).Position;

    obj.go.droplet.axes(2) = axes(obj.go.figure);
    obj.go.droplet.image(2) = imagesc(obj.go.droplet.axes(2), nan);
    %         obj.go.droplet.colorbar(2) = colorbar(obj.go.droplet.axes(2));
    obj.go.droplet.axes(2).Position = obj.go.axes(4).Position; % needed to avoid weird axes deleting error
    %         obj.go.droplet.axes(2).Color = 'none';
    %         obj.go.droplet.axes(2).XAxis.Color = 'none';
    %         obj.go.droplet.axes(2).YAxis.Color = 'none';
    %         obj.go.droplet.axes(2).Box = 'off';

    obj.go.axes(6) = subplot(2, 3, 6, 'Parent', obj.go.figure);
    obj.go.image(2, 2) = imagesc(obj.go.axes(6), nan);
    obj.go.colorbar(4) = colorbar(obj.go.axes(6));
    obj.go.droplet.axes(2).Position = obj.go.axes(6).Position;

    %         arrayfun(@(a) colormap(obj.go.droplet.axes(a), obj.plotting.colormap.droplet), 1:2, 'uni', 0);
    %         obj.go.droplet.axes(2).Colormap = obj.plotting.colormap.droplet;


    % %         arrayfun(@(a) set(obj.go.droplet.colorbar(a), 'Color', 'none'), 1:2, 'uni', 0);
    %         arrayfun(@(a) set(obj.go.droplet.axes(a), 'Color', 'none', 'Box', 'off'), 1:2, 'uni', 0);
    %         arrayfun(@(a) set(obj.go.droplet.axes(a).XAxis, 'Color', 'none'), 1:2, 'uni', 0);
    %         arrayfun(@(a) set(obj.go.droplet.axes(a).YAxis, 'Color', 'none'), 1:2, 'uni', 0);
    %         arrayfun(@(a) set(obj.go.droplet.axes(a), 'Position', obj.go.axes(a+4).Position), 1:2, 'uni', 0);

    linkaxes([obj.go.axes(5), obj.go.droplet.axes(1)], 'xy');
    linkaxes([obj.go.axes(6), obj.go.droplet.axes(2)], 'xy');

    drawnow;

    obj.go.colorbar(1).Label.String = '# photons';
    obj.go.colorbar(2).Label.String = '# photons';

    %% plot ellipse

    hold(obj.go.axes(5:6), 'on');
    obj.go.plot.ellipse(1) = plot(obj.go.axes(5), nan, nan, 'k--');
    obj.go.plot.ellipse(2) = plot(obj.go.axes(6), nan, nan, 'k--');
    hold(obj.go.axes(5:6), 'off');

    %         set(obj.go.axes(1:2), 'XLimSpec', 'Tight');
    obj.go.axes(1).YLim = [0.01, 1];
    obj.go.axes(2).YLim = [0, 1];
    obj.go.axes(1).YScale = 'log';
    obj.go.axes(2).YScale = 'linear';
    axis(obj.go.axes(3:6), 'image');

    %obj.go.axes(1).Title.String = 'real space error';
    %obj.go.axes(2).Title.String = 'fourier space error';
    obj.go.axes(3).Title.String = sprintf('current guess - %i steps', ...
        obj.nTotal);
    obj.go.axes(4).Title.String = 'measured';
    obj.go.axes(5).Title.String = 'before constraints';
    obj.go.axes(6).Title.String = 'after constraints';

    obj.go.axes(1).XLabel.String = 'iterations';
    obj.go.axes(2).XLabel.String = 'iterations';
    obj.go.axes(3).XRuler.TickLabelFormat = iif(strcmp(obj.go.axes(3).XRuler.TickLabelInterpreter, 'latex'), '$%g^\\circ$', '%g\x00B0');
    obj.go.axes(4).XRuler.TickLabelFormat = iif(strcmp(obj.go.axes(4).XRuler.TickLabelInterpreter, 'latex'), '$%g^\\circ$', '%g\x00B0');
    obj.go.axes(3).XLabel.String = 'scattering angle';
    obj.go.axes(4).XLabel.String = 'scattering angle';
    obj.go.axes(5).XLabel.String = 'x (nm)';
    obj.go.axes(6).XLabel.String = 'x (nm)';
    obj.go.droplet.axes(1).XLabel.String = 'x (nm)';
    obj.go.droplet.axes(2).XLabel.String = 'x (nm)';

    obj.go.axes(1).YLabel.String = 'reconstruction error';
    obj.go.axes(2).YLabel.String = 'reconstruction error';
    obj.go.axes(3).YLabel.String = 'scattering angle';
    obj.go.axes(4).YLabel.String = 'scattering angle';
    obj.go.axes(3).YRuler.TickLabelFormat = iif(strcmp(obj.go.axes(3).YRuler.TickLabelInterpreter, 'latex'), '$%g^\\circ$', '%g\x00B0');
    obj.go.axes(4).YRuler.TickLabelFormat = iif(strcmp(obj.go.axes(4).YRuler.TickLabelInterpreter, 'latex'), '$%g^\\circ$', '%g\x00B0');
    obj.go.axes(5).YLabel.String = 'y (nm)';
    obj.go.axes(6).YLabel.String = 'y (nm)';
    obj.go.droplet.axes(1).YLabel.String = 'y (nm)';
    obj.go.droplet.axes(2).YLabel.String = 'y (nm)';

    obj.go.axes(1).PlotBoxAspectRatio = [1.618, 1, 1];
    obj.go.axes(2).PlotBoxAspectRatio = [1.618, 1, 1];
    grid(obj.go.axes(3:6), 'off');
    grid(obj.go.droplet.axes(1:2), 'off');
    %         linkaxes(obj.go.axes(3:4), 'xy');
    %         linkaxes(obj.go.axes(5:6), 'xy');

    obj.setPlotRange();
    obj.setIPRColormaps();
    drawnow;
    %     arrayfun(@(a) colorbar(obj.go.axes(a)),3:6);
    %     obj.go.figure(1).Visible = 'on';
end

%% Update Callbacks

obj.go.figure(1).KeyPressFcn = obj.parentfig.KeyPressFcn;
obj.go.figure(1).KeyReleaseFcn = obj.parentfig.KeyReleaseFcn;
obj.go.figure(1).CloseRequestFcn = @(onj, evt) delete(obj.go.figure(1));
obj.go.popup(1).Callback = @obj.setIPRColormaps;
obj.go.popup(2).Callback = @obj.setIPRColormaps;
obj.go.popup(3).Callback = @obj.setScaleErrorPlot;
obj.go.popup(4).Callback = @obj.setPlotRange;
obj.go.popup(5).Callback = @obj.setImageParts;
obj.go.popup(6).Callback = @obj.setImageParts;
obj.go.checkbox(1).Callback = @obj.setSubtractionScale;
obj.go.checkbox(2).Callback = @(src, evt) arrayfun(@(a) set(obj.go.axes(a), 'ColorScale', iif(obj.go.checkbox(2).Value, 'log', 'linear')), 3:4, 'uni', 0);
obj.go.checkbox(3).Callback = @obj.updateGUI;
obj.go.edit(1).Callback = @obj.setPlotRange;
obj.go.edit(2).Callback = @obj.setPlotRange;
obj.go.edit(3).Callback = @obj.setSubtractionScale;

%% Update graphics objects

if isempty(obj.dropletOutline)
    obj.dropletOutline.x = nan;
    obj.dropletOutline.y = nan;
end

anglebound = atan([obj.yy(1), obj.yy(end)]*75e-6/0.37/obj.binFactor) / 2 / pi * 360;
obj.go.image(1, 1).XData = anglebound;
obj.go.image(1, 1).YData = anglebound;
obj.go.image(1, 2).XData = anglebound;
obj.go.image(1, 2).YData = anglebound;
obj.go.droplet.image(1).XData = [obj.xx(1), obj.xx(end)] * 6;
obj.go.droplet.image(1).YData = [obj.xx(1), obj.xx(end)] * 6;
obj.go.droplet.image(2).XData = [obj.xx(1), obj.xx(end)] * 6;
obj.go.droplet.image(2).YData = [obj.xx(1), obj.xx(end)] * 6;
obj.go.image(2, 1).XData = [obj.xx(1), obj.xx(end)] * 6;
obj.go.image(2, 1).YData = [obj.yy(1), obj.yy(end)] * 6;
obj.go.image(2, 2).XData = [obj.xx(1), obj.xx(end)] * 6;
obj.go.image(2, 2).YData = [obj.yy(1), obj.yy(end)] * 6;
obj.go.plot.ellipse(1).XData = obj.dropletOutline.x;
obj.go.plot.ellipse(1).YData = obj.dropletOutline.y;
obj.go.plot.ellipse(2).XData = obj.dropletOutline.x;
obj.go.plot.ellipse(2).YData = obj.dropletOutline.y;
%     vf = gather([-1,1]*1.5*abs(obj.support_radius)*6);
%     obj.go.axes(5).XLim = vf;
%     obj.go.axes(6).YLim = vf;

%     scaleArray = [200 500 1000 2000];
%     scaleIndex = find(scaleArray > abs(obj.support_radius)*6, 1);
%     scaleNumber = scaleArray(scaleIndex);
%
scaleNumber = gather(1.5*abs(obj.support_radius)*6);
%
%     obj.go.droplet.axes(1).XLim = [-1,1]*scaleNumber;
%     obj.go.droplet.axes(1).YLim = [-1,1]*scaleNumber;
%     obj.go.droplet.axes(2).XLim = [-1,1]*scaleNumber;
%     obj.go.droplet.axes(2).YLim = [-1,1]*scaleNumber;
linkaxes([obj.go.axes(5), obj.go.droplet.axes(1)], 'xy')
linkaxes([obj.go.axes(6), obj.go.droplet.axes(2)], 'xy')
obj.go.axes(5).XLim = [-1, 1] * scaleNumber;
obj.go.axes(5).YLim = [-1, 1] * scaleNumber;
obj.go.axes(6).YLim = [-1, 1] * scaleNumber;
obj.go.axes(6).XLim = [-1, 1] * scaleNumber;

obj.go.axes(3).XLim = obj.go.image(1, 1).XData([1, end]);
obj.go.axes(4).YLim = obj.go.image(1, 1).YData([1, end]);

obj.go.axes(1).Title.String = sprintf('run #%i - hit %i - train ID %i', obj.runID, obj.hitID, obj.trainID);
obj.go.axes(1).InnerPosition(3:4) = obj.go.axes(2).InnerPosition(3:4);
obj.setScaleErrorPlot(obj.go.popup(3));
obj.setImageParts([], [], true);
obj.setIPRColormaps();
obj.setPlotRange();
obj.setSubtractionScale([], [], true);

arrayfun(@(b) arrayfun(@(a) set(obj.go.plot.error(b, a), 'LineWidth', obj.plotting.LineWidth), 1:size(obj.go.plot.error,2), 'uni', 0), 1:size(obj.go.plot.error, 1), 'uni', 0);

end
