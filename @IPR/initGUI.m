function obj = initGUI(obj)
if any(strcmp(fieldnames(obj.objectHandle), 'figureArray'))
    obj.figureArray = obj.objectHandle.figureArray;
    obj.axesArray = obj.objectHandle.axesArray;
    obj.plt = obj.objectHandle.plt;
    obj.popupArray = obj.objectHandle.popupArray;
    obj.cBoxArray = obj.objectHandle.cBoxArray;
    obj.editArray = obj.objectHandle.editArray;
    obj.scanObj = obj.objectHandle.scanObj;
end
if ~isgraphics(obj.figureArray)
    %% figure
    obj.figureArray(1) = getFigure(obj.figureArray(1), ...
        'NumberTitle', 'off', ...
        'Name', 'Iterative Phasing GUI', ...
        'Tag', 'figure_IPR', ...
        'GraphicsSmoothing', 'off', ...
        'KeyPressFcn', obj.parentfig.KeyPressFcn, ...
        'KeyReleaseFcn', obj.parentfig.KeyReleaseFcn);
    %     obj.figureArray(1).Visible = 'on';
    
    %% popups
    cMaps=const.colormaps;
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
    
    %% Real Space Error
    obj.axesArray(1) = subplot(2,3,1,'Parent',obj.figureArray);
    obj.plt.err(1) = plot(obj.axesArray(1),...
        1:numel(obj.errors(1,:)), obj.errors(1,:), '--');
    hold(obj.axesArray(1), 'on');
    
    obj.plt.err(2) = plot(obj.axesArray(1),...
        1:numel(obj.errors(2,:)), obj.errors(2,:), ':');
    hold(obj.axesArray(1), 'off');
    grid(obj.axesArray(1), 'on');
    legend(obj.axesArray(1), ...
        {'$||\mathbf{\overline{P}_S}\rho_n|| / ||\mathbf{P_S} \rho_n||$',...
        '$||\rho_n - \rho_{sim}|| / ||\rho_{sim}||$'}, 'Interpreter','latex');
    
    %% Fourier Space Error
    obj.axesArray(2) = subplot(2,3,4,'Parent',obj.figureArray);
    obj.plt.err(3) = plot(obj.axesArray(2), ...
        1:numel(obj.errors(1,:)), obj.errors(1,:), '--');
    %     hold(obj.axesArray(2), 'on');
    %     obj.plt.err(4) = plot(obj.axesArray(2), ...
    %         1:numel(obj.errors(1,:)), obj.errors(1,:), '-o');
    %     obj.plt.err(5) = plot(obj.axesArray(2), ...
    %         1:numel(obj.errors(1,:)), obj.errors(1,:), '-x');
    %     hold(obj.axesArray(2), 'off');
    grid(obj.axesArray(2), 'on');
    legend(obj.axesArray(2), ...
        {'$|| \left|\tilde{\rho}_n\right| - \sqrt{I_0}|| / || \sqrt{I_0} ||$'},...
        'Interpreter','latex');
    
    %% create images
    obj.axesArray(3) = subplot(2,3,2,'Parent',obj.figureArray);
    
    obj.plt.int(1).img = imagesc(obj.axesArray(3), (log10(abs(obj.AMP).^2)));
    colorbar(obj.axesArray(3));
    
    obj.axesArray(4) = subplot(2,3,5,'Parent',obj.figureArray);
    obj.plt.int(2).img = imagesc(obj.axesArray(4), (log10(abs(obj.W).^2)));
    colorbar(obj.axesArray(4));
    
    obj.axesArray(5) = subplot(2,3,3,'Parent',obj.figureArray);
    obj.plt.rec(1).img = imagesc(obj.axesArray(5), (real(obj.ws)));
    colorbar(obj.axesArray(5));
    
    obj.axesArray(6) = subplot(2,3,6,'Parent',obj.figureArray);
    obj.plt.rec(2).img = imagesc(obj.axesArray(6), (real(obj.w)));
    colorbar(obj.axesArray(6));
    drawnow;
    
    %% plot ellipse
    if isempty(obj.dropletOutline)
        obj.dropletOutline.x = nan;
        obj.dropletOutline.y = nan;
    end
    hold(obj.axesArray(5:6), 'on');
    obj.plt.rec(1).ell = plot(obj.axesArray(5), obj.dropletOutline.x, ...
        obj.dropletOutline.y, 'k--');
    obj.plt.rec(2).ell = plot(obj.axesArray(6), obj.dropletOutline.x, ...
        obj.dropletOutline.y, 'k--');
    hold(obj.axesArray(5:6), 'off');
    
    axis(obj.axesArray(1:2), 'tight');
    axis(obj.axesArray(3:6), 'image');
    
    obj.axesArray(1).Title.String = 'real space error';
    obj.axesArray(2).Title.String = 'fourier space error';
    obj.axesArray(3).Title.String = sprintf('current guess - %i steps', ...
        obj.nTotal);
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
    
    obj.setPlotRange();
    obj.setIPRColormaps();
    drawnow;
    %     arrayfun(@(a) colorbar(obj.axesArray(a)),3:6);
    %     obj.figureArray(1).Visible = 'on';
end

anglebound = atan([obj.yy(1),obj.yy(end)]*75e-6/0.37/obj.binFactor)/2/pi*360;
obj.plt.int(1).img.XData = anglebound;
obj.plt.int(1).img.YData = anglebound;
obj.plt.int(2).img.XData = anglebound;
obj.plt.int(2).img.YData = anglebound;
obj.plt.rec(1).img.XData = [obj.xx(1),obj.xx(end)]*6;
obj.plt.rec(1).img.YData = [obj.yy(1),obj.yy(end)]*6;
obj.plt.rec(2).img.XData = [obj.xx(1),obj.xx(end)]*6;
obj.plt.rec(2).img.YData = [obj.yy(1),obj.yy(end)]*6;
obj.plt.rec(1).ell.XData = obj.dropletOutline.x;
obj.plt.rec(1).ell.YData = obj.dropletOutline.y;
obj.plt.rec(2).ell.XData = obj.dropletOutline.x;
obj.plt.rec(2).ell.YData = obj.dropletOutline.y;
vf = gather([-1,1]*1.5*abs(obj.support_radius)*6);
obj.axesArray(5).XLim = vf;
obj.axesArray(6).YLim = vf;
obj.axesArray(3).XLim = obj.plt.int(1).img.XData([1,end]);
obj.axesArray(4).YLim = obj.plt.int(1).img.YData([1,end]);
end
