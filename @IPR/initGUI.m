function obj = initGUI(obj)
    %% figure
    obj.figureArray(1) = figure(20000002); clf
    obj.figureArray(1).Visible = 'off';
    
    obj.figureArray(1).Tag = 'recFigure';
    obj.figureArray(1).GraphicsSmoothing = 'off';
    obj.figureArray(1).Name = 'Iterative Phasing GUI';
    obj.figureArray(1).KeyPressFcn = obj.parentfig.KeyPressFcn;
    obj.figureArray(1).KeyReleaseFcn = obj.parentfig.KeyReleaseFcn;
    %% popups
    cMaps={'imorgen','morgenstemning','wjet',...
        'r2b','r2b2','parula','jet','hsv','hot','cool','gray',...
        'igray','redmap','redmap2','bluemap','bluemap2','b2r','b2r2',...
        'hslcolormap'};
    obj.popupArray(1)=uicontrol('parent',obj.figureArray(1),'Style','popup');
    obj.popupArray(1).String=cMaps;
    obj.popupArray(1).Value=find(strcmp(obj.popupArray(1).String,obj.int_cm));
    obj.popupArray(1).Units='normalized';
    obj.popupArray(1).Position=[.57,.94,.05,.05];
    obj.popupArray(1).Callback = @obj.setColormaps;
    
    obj.popupArray(2)=uicontrol('parent',obj.figureArray(1),'Style','popup');
    obj.popupArray(2).String=cMaps;
    obj.popupArray(2).Value=find(strcmp(obj.popupArray(2).String, obj.rec_cm));
    obj.popupArray(2).Units='normalized';
    obj.popupArray(2).Position=[.92,.94,.05,.05];
    obj.popupArray(2).Callback = @obj.setColormaps;
    
    obj.popupArray(3)=uicontrol('parent',obj.figureArray(1),'Style','popup');
    obj.popupArray(3).String={'','linear','semilogx','semilogy','loglog'};
    obj.popupArray(3).Value=1;
    obj.popupArray(3).Units='normalized';
	obj.popupArray(3).Position=[.23,.94,.05,.05];
    obj.popupArray(3).Callback = @obj.setScaleErrorPlot;
    
    obj.popupArray(4)=uicontrol('parent', obj.figureArray(1),'Style','popup');
    obj.popupArray(4).String={'autoscale','0:max(abs)','-max(abs):max(abs)',...
        '20%:100%','-max:max','-pi:pi','-pi/2:pi/2','-pi/4:pi/4',...
        '-pi/8:pi/8','-0.1:0.1'};
    obj.popupArray(4).Value=obj.reconrange;
	obj.popupArray(4).Units='normalized';
    obj.popupArray(4).Position=[.92,.88,.05,.05];
    obj.popupArray(4).Callback = @obj.setPlotRange;
    
    obj.popupArray(5)=uicontrol('parent',obj.figureArray(1),'Style','popup');
    obj.popupArray(5).String={'log10(abs(IMG).^2)','abs(IMG)','real(IMG)',...
        'imag(IMG)','angle(IMG)','log10(abs(real(IMG)))','sign(real(IMG))'};
    obj.popupArray(5).Units='normalized';
    obj.popupArray(5).Position=[.57,.01,.05,.05];
    obj.popupArray(5).Value=obj.intpart;
    obj.popupArray(5).Callback = @obj.setImageParts;
    
    obj.popupArray(6)=uicontrol('parent',obj.figureArray(1),'Style','popup');
    obj.popupArray(6).String={'real','imag','abs','angle'};
    obj.popupArray(6).Value=find(strcmp(obj.popupArray(6).String,...
        obj.reconpart));
    obj.popupArray(6).Units='normalized';
    obj.popupArray(6).Position=[.92,.01,.05,.05];
    obj.popupArray(6).Callback = @obj.setImageParts;
    %% checkboxes
    obj.cBoxArray(1)=uicontrol('parent',obj.figureArray(1),'Style','checkbox');
    obj.cBoxArray(1).String='subtract ellipsoid';
    obj.cBoxArray(1).Value=obj.substract_shape;
    obj.cBoxArray(1).Units='normalized';
    obj.cBoxArray(1).Position=[.92,.07,.05,.05];
    obj.cBoxArray(1).Callback = @obj.setSubtractionScale;
    
    obj.cBoxArray(2)=uicontrol('parent',obj.figureArray(1),'Style','checkbox');
    obj.cBoxArray(2).String='normalize ellipsoid';
    obj.cBoxArray(2).Value=obj.normalize_shape;
	obj.cBoxArray(2).Units='normalized';
    obj.cBoxArray(2).Position=[.92,.12,.05,.05];
    obj.cBoxArray(2).Callback = @obj.setSubtractionScale;
    %% edits
    obj.editArray(1)=uicontrol('parent',obj.figureArray(1),'Style','edit');
    obj.editArray(1).String=num2str(obj.clims_scatt(1));
    obj.editArray(1).Units='normalized';
    obj.editArray(1).Position=[.57,.07,.025,.025];
    obj.editArray(1).Callback = @obj.setPlotRange;
    
    obj.editArray(2)=uicontrol('parent',obj.figureArray(1),'Style','edit');
    obj.editArray(2).String=num2str(obj.clims_scatt(2));
    obj.editArray(2).Units='normalized';
    obj.editArray(2).Position=[.6,.07,.025,.025];
    obj.editArray(2).Callback = @obj.setPlotRange;
    
    obj.editArray(3)=uicontrol('parent',obj.figureArray(1),'Style','edit');
    obj.editArray(3).String=num2str(obj.subscale);
    obj.editArray(3).Units='normalized';
    obj.editArray(3).Position=[.92,.82,.025,.025];
    obj.editArray(3).Callback = @obj.setSubtractionScale;
    %% axes & plots
    obj.tiledLayout = tiledlayout(obj.figureArray(1), 2,3);
    obj.axesArray(1) = nexttile(obj.tiledLayout,1);
    obj.axesArray(2) = nexttile(obj.tiledLayout,4);
    obj.axesArray(3) = nexttile(obj.tiledLayout,2);
    obj.axesArray(4) = nexttile(obj.tiledLayout,5);
    obj.axesArray(5) = nexttile(obj.tiledLayout,3);
    obj.axesArray(6) = nexttile(obj.tiledLayout,6);

    obj.plt.err(1) = plot(obj.axesArray(1), obj.errors(1,:), '--'); 
    grid(obj.axesArray(1), 'on'); hold(obj.axesArray(1), 'on');
    obj.plt.err(2) = plot(obj.axesArray(1), obj.errors(2,:), ':');
    obj.plt.err(3) = plot(obj.axesArray(2), obj.errors(3,:), '-o'); 
    grid(obj.axesArray(2), 'on'); hold(obj.axesArray(2), 'on');
    obj.plt.err(4) = plot(obj.axesArray(2), obj.errors(4,:), ':');
    obj.plt.err(5) = plot(obj.axesArray(2), obj.errors(5,:), 'x');
    legend(obj.axesArray(2), 'NRMSD', 'sqrt(I)');
    % create images
    anglebound = atan([obj.yy(1),obj.yy(end)]*75e-6/0.37/obj.binFactor)/2/pi*360;
    obj.plt.int(1).img = imagesc(obj.axesArray(3), (log10(abs(obj.AMP).^2)), ...
        'XData', anglebound,'YData', anglebound);
    obj.plt.int(2).img = imagesc(obj.axesArray(4), (log10(abs(obj.W).^2)), ...
        'XData', anglebound,'YData', anglebound);
    obj.plt.rec(1).img = imagesc(obj.axesArray(5), (real(obj.ws)),...
        'XData', [obj.xx(1),obj.xx(end)]*6,'YData', [obj.yy(1),obj.yy(end)]*6);
    obj.plt.rec(2).img = imagesc(obj.axesArray(6), (real(obj.w)), ...
        'XData', [obj.xx(1),obj.xx(end)]*6,'YData', [obj.yy(1),obj.yy(end)]*6);
    % plot ellipse
    if ~isempty(obj.dropletOutline)
        hold(obj.axesArray(5:6),'on');
        obj.plt.rec(1).ell = plot(obj.axesArray(5),obj.dropletOutline.x,...
            obj.dropletOutline.y,'k--');
        obj.plt.rec(2).ell = plot(obj.axesArray(6),obj.dropletOutline.x,...
            obj.dropletOutline.y,'k--');
        hold(obj.axesArray(5:6),'off');
    end

    axis(obj.axesArray(1:2), 'tight');
    axis(obj.axesArray(3:6), 'image');

    obj.axesArray(1).Title.String = 'real space error';
    obj.axesArray(2).Title.String = 'fourier space error';
    obj.axesArray(3).Title.String = sprintf('current guess - %i steps', obj.nTotal);
    obj.axesArray(4).Title.String = 'measured';
    obj.axesArray(5).Title.String = 'before constraints';
    obj.axesArray(6).Title.String = 'after constraints';

    obj.axesArray(3).YLabel.String = 'scattering angle';
    obj.axesArray(4).YLabel.String = 'scattering angle';
    obj.axesArray(5).YLabel.String = 'nanometers';
    obj.axesArray(6).YLabel.String = 'nanometers';

    grid(obj.axesArray(3:6), 'off');
    linkaxes(obj.axesArray(3:4), 'xy');
    linkaxes(obj.axesArray(5:6), 'xy');

    vf = gather([-1,1]*1.5*abs(obj.support_radius)*6);
    obj.axesArray(5).XLim = vf;
    obj.axesArray(6).YLim = vf;

    obj.setPlotRange();
    obj.setColormaps();
    obj.figureArray(1).Visible = 'on';
end
