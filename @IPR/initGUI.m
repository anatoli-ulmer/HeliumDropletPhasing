function obj = initGUI(obj)

    %% Create graphics objects if they don't exist
    if isempty(obj.go)
        obj.go.figure = gobjects(1);
    end
    if ~isgraphics(obj.go.figure)
        %% figure
        obj.go.figure(1) = getFigure([], ...
            'NumberTitle', 'off', ...
            'Name', 'Iterative Phasing GUI', ...
            'Tag', 'figure_IPR');
        
        obj.go.figure(1).GraphicsSmoothing = 'off';

        %% popups
        cMaps=const.colormaps;
        obj.go.popup(1)=uicontrol('parent',obj.go.figure(1),'Style','popup');
        obj.go.popup(1).String=cMaps;
        obj.go.popup(1).Value=find(strcmp(obj.go.popup(1).String,obj.int_cm));
        obj.go.popup(1).Units='normalized';
        obj.go.popup(1).Position=[.57,.94,.05,.05];

        obj.go.popup(2)=uicontrol('parent',obj.go.figure(1),'Style','popup');
        obj.go.popup(2).String=cMaps;
        obj.go.popup(2).Value=find(strcmp(obj.go.popup(2).String, obj.rec_cm));
        obj.go.popup(2).Units='normalized';
        obj.go.popup(2).Position=[.92,.94,.05,.05];

        obj.go.popup(3)=uicontrol('parent',obj.go.figure(1),'Style','popup');
        obj.go.popup(3).String={'','linear','semilogx','semilogy','loglog'};
        obj.go.popup(3).Value=1;
        obj.go.popup(3).Units='normalized';
        obj.go.popup(3).Position=[.23,.94,.05,.05];

        obj.go.popup(4)=uicontrol('parent', obj.go.figure(1),'Style','popup');
        obj.go.popup(4).String={'autoscale','0:max(abs)','-max(abs):max(abs)',...
            '20%:100%','-max:max','-pi:pi','-pi/2:pi/2','-pi/4:pi/4',...
            '-pi/8:pi/8','-0.1:0.1'};
        obj.go.popup(4).Value=obj.reconrange;
        obj.go.popup(4).Units='normalized';
        obj.go.popup(4).Position=[.92,.88,.05,.05];

        obj.go.popup(5)=uicontrol('parent',obj.go.figure(1),'Style','popup');
        obj.go.popup(5).String={'log10(abs(IMG).^2)','abs(IMG)','real(IMG)',...
            'imag(IMG)','angle(IMG)','log10(abs(real(IMG)))','sign(real(IMG))'};
        obj.go.popup(5).Units='normalized';
        obj.go.popup(5).Position=[.57,.01,.05,.05];
        obj.go.popup(5).Value=obj.intpart;

        obj.go.popup(6)=uicontrol('parent',obj.go.figure(1),'Style','popup');
        obj.go.popup(6).String={'real','imag','abs','angle'};
        obj.go.popup(6).Value=find(strcmp(obj.go.popup(6).String,...
            obj.reconpart));
        obj.go.popup(6).Units='normalized';
        obj.go.popup(6).Position=[.92,.01,.05,.05];

        %% checkboxes
        obj.go.checkbox(1)=uicontrol('parent',obj.go.figure(1),'Style','checkbox');
        obj.go.checkbox(1).String='subtract ellipsoid';
        obj.go.checkbox(1).Value=obj.substract_shape;
        obj.go.checkbox(1).Units='normalized';
        obj.go.checkbox(1).Position=[.92,.07,.05,.05];

        %% edits
        obj.go.edit(1)=uicontrol('parent',obj.go.figure(1),'Style','edit');
        obj.go.edit(1).String=num2str(obj.clims_scatt(1));
        obj.go.edit(1).Units='normalized';
        obj.go.edit(1).Position=[.57,.07,.025,.025];

        obj.go.edit(2)=uicontrol('parent',obj.go.figure(1),'Style','edit');
        obj.go.edit(2).String=num2str(obj.clims_scatt(2));
        obj.go.edit(2).Units='normalized';
        obj.go.edit(2).Position=[.6,.07,.025,.025];

        obj.go.edit(3)=uicontrol('parent',obj.go.figure(1),'Style','edit');
        obj.go.edit(3).String=num2str(obj.subscale);
        obj.go.edit(3).Units='normalized';
        obj.go.edit(3).Position=[.92,.82,.025,.025];

        %% axes & plots

        %% Real Space Error
        obj.go.axes(1) = subplot(2,3,1,'Parent',obj.go.figure);
        obj.go.plot.error(1) = plot(obj.go.axes(1),...
            1:numel(obj.errors(1,:)), obj.errors(1,:), '--');
        hold(obj.go.axes(1), 'on');

        obj.go.plot.error(2) = plot(obj.go.axes(1),...
            1:numel(obj.errors(2,:)), obj.errors(2,:), ':');
        hold(obj.go.axes(1), 'off');
        grid(obj.go.axes(1), 'on');
        legend(obj.go.axes(1), ...
            {'$||\mathbf{\overline{P}_S}\rho_n|| / ||\mathbf{P_S} \rho_n||$',...
            '$||\rho_n - \rho_{sim}|| / ||\rho_{sim}||$'}, 'Interpreter','latex');

        %% Fourier Space Error
        obj.go.axes(2) = subplot(2,3,4,'Parent',obj.go.figure);
        obj.go.plot.error(3) = plot(obj.go.axes(2), nan, nan, '--');
        %     hold(obj.go.axes(2), 'on');
        %     obj.go.plot.error(4) = plot(obj.go.axes(2), ...
        %         1:numel(obj.errors(1,:)), obj.errors(1,:), '-o');
        %     obj.go.plot.error(5) = plot(obj.go.axes(2), ...
        %         1:numel(obj.errors(1,:)), obj.errors(1,:), '-x');
        %     hold(obj.go.axes(2), 'off');
        grid(obj.go.axes(2), 'on');
        legend(obj.go.axes(2), ...
            {'$|| \left|\tilde{\rho}_n\right| - \sqrt{I_0}|| / || \sqrt{I_0} ||$'},...
            'Interpreter','latex');

        %% create images
        obj.go.axes(3) = subplot(2,3,2,'Parent',obj.go.figure);

        obj.go.image(1,1) = imagesc(obj.go.axes(3), nan);
        colorbar(obj.go.axes(3));

        obj.go.axes(4) = subplot(2,3,5,'Parent',obj.go.figure);
        obj.go.image(1,2) = imagesc(obj.go.axes(4), nan);
        colorbar(obj.go.axes(4));

        obj.go.axes(5) = subplot(2,3,3,'Parent',obj.go.figure);
        obj.go.image(2,1) = imagesc(obj.go.axes(5), nan);
        colorbar(obj.go.axes(5));

        obj.go.axes(6) = subplot(2,3,6,'Parent',obj.go.figure);
        obj.go.image(2,2) = imagesc(obj.go.axes(6), nan);
        colorbar(obj.go.axes(6));
        drawnow;

        %% plot ellipse

        hold(obj.go.axes(5:6), 'on');
        obj.go.plot.ellipse(1) = plot(obj.go.axes(5), nan, nan, 'k--');
        obj.go.plot.ellipse(2) = plot(obj.go.axes(6), nan, nan, 'k--');
        hold(obj.go.axes(5:6), 'off');

        axis(obj.go.axes(1:2), 'tight');
        axis(obj.go.axes(3:6), 'image');

        obj.go.axes(1).Title.String = 'real space error';
        obj.go.axes(2).Title.String = 'fourier space error';
        obj.go.axes(3).Title.String = sprintf('current guess - %i steps', ...
            obj.nTotal);
        obj.go.axes(4).Title.String = 'measured';
        obj.go.axes(5).Title.String = 'before constraints';
        obj.go.axes(6).Title.String = 'after constraints';

        obj.go.axes(3).YLabel.String = 'scattering angle';
        obj.go.axes(4).YLabel.String = 'scattering angle';
        obj.go.axes(5).YLabel.String = 'nanometers';
        obj.go.axes(6).YLabel.String = 'nanometers';

        grid(obj.go.axes(3:6), 'off');
        linkaxes(obj.go.axes(3:4), 'xy');
        linkaxes(obj.go.axes(5:6), 'xy');

        obj.setPlotRange();
        obj.setIPRColormaps();
        drawnow;
        %     arrayfun(@(a) colorbar(obj.go.axes(a)),3:6);
        %     obj.go.figure(1).Visible = 'on';
    end
    
    %% Update Callbacks
    
    obj.go.figure(1).KeyPressFcn = obj.parentfig.KeyPressFcn;
    obj.go.figure(1).KeyReleaseFcn = obj.parentfig.KeyReleaseFcn;
    obj.go.figure(1).CloseRequestFcn = @(onj,evt) delete(obj.go.figure(1));
    obj.go.popup(1).Callback = @obj.setIPRColormaps;
    obj.go.popup(2).Callback = @obj.setIPRColormaps;
    obj.go.popup(3).Callback = @obj.setScaleErrorPlot;
    obj.go.popup(4).Callback = @obj.setPlotRange;
    obj.go.popup(5).Callback = @obj.setImageParts;
    obj.go.popup(6).Callback = @obj.setImageParts;
    obj.go.checkbox(1).Callback = @obj.setSubtractionScale;
    obj.go.edit(1).Callback = @obj.setPlotRange;
    obj.go.edit(2).Callback = @obj.setPlotRange;
    obj.go.edit(3).Callback = @obj.setSubtractionScale;
    
    %% Update graphics objects
    
    if isempty(obj.dropletOutline)
        obj.dropletOutline.x = nan;
        obj.dropletOutline.y = nan;
    end
    
    anglebound = atan([obj.yy(1),obj.yy(end)]*75e-6/0.37/obj.binFactor)/2/pi*360;
    obj.go.image(1,1).XData = anglebound;
    obj.go.image(1,1).YData = anglebound;
    obj.go.image(1,2).XData = anglebound;
    obj.go.image(1,2).YData = anglebound;
    obj.go.image(2,1).XData = [obj.xx(1),obj.xx(end)]*6;
    obj.go.image(2,1).YData = [obj.yy(1),obj.yy(end)]*6;
    obj.go.image(2,2).XData = [obj.xx(1),obj.xx(end)]*6;
    obj.go.image(2,2).YData = [obj.yy(1),obj.yy(end)]*6;
    obj.go.plot.ellipse(1).XData = obj.dropletOutline.x;
    obj.go.plot.ellipse(1).YData = obj.dropletOutline.y;
    obj.go.plot.ellipse(2).XData = obj.dropletOutline.x;
    obj.go.plot.ellipse(2).YData = obj.dropletOutline.y;
    vf = gather([-1,1]*1.5*abs(obj.support_radius)*6);
    obj.go.axes(5).XLim = vf;
    obj.go.axes(6).YLim = vf;
    obj.go.axes(3).XLim = obj.go.image(1,1).XData([1,end]);
    obj.go.axes(4).YLim = obj.go.image(1,1).YData([1,end]);
    
    obj.setScaleErrorPlot(obj.go.popup(3));
    obj.setImageParts([],[],true);
    obj.setIPRColormaps();
    obj.setPlotRange();
    obj.setSubtractionScale([],[],true);
    
end
