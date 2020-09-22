function obj = updateGUI(obj,~,~)
    
    for i=1:size(obj.errors,1)
        obj.plt.err(i).YData = gather(obj.errors(i,:));
    end
     
    %             obj.ax.err(1).XLim=[0,max(1, obj.nTotal)];
    %             obj.ax.err(2).XLim=[0,max(1, obj.nTotal)];
    %             obj.ax.err(1).YLim=[0,gather(nanmax([1, obj.errors(1,:)]))];
    %             obj.ax.err(2).YLim=[0,gather(nanmax([1, obj.errors(2,:), obj.errors(3,:)]))];

    obj.plt.int(1).img.CData = gather(getScatteringPart(obj.W, obj.intpart));
    obj.plt.int(2).img.CData = gather(getScatteringPart(obj.WS, obj.intpart));

    if obj.normalize_shape
        obj.plt.rec(1).img.CData = gather(getReconstructionPart(obj.ws./obj.rho, obj.reconpart));
        obj.plt.rec(2).img.CData = gather(getReconstructionPart(obj.w./obj.rho, obj.reconpart));
    elseif obj.substract_shape
        obj.plt.rec(1).img.CData = gather(getReconstructionPart( obj.ws, obj.reconpart) - (obj.rho0 .* obj.subscale) );
        obj.plt.rec(2).img.CData = gather(getReconstructionPart( obj.w, obj.reconpart) - (obj.rho0 .* obj.subscale) );
    else
        obj.plt.rec(1).img.CData = gather(getReconstructionPart(obj.ws, obj.reconpart));
        obj.plt.rec(2).img.CData = gather(getReconstructionPart(obj.w, obj.reconpart));
    end
    obj.setPlotRange;
    obj.axesArray(3).Title.String = sprintf('reconstructed - %i steps', obj.nTotal);
    obj.axesArray(5).Title.String = sprintf('before constraints - %i steps', obj.nTotal);
    obj.figureArray(1).Pointer = 'arrow';
    drawnow limitrate;
end
