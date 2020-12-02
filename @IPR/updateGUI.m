function obj = updateGUI(obj,~,~)
    
    for i=1:size(obj.errors,1)
        obj.go.plot.error(i).XData = 1:numel(gather(obj.errors(i,:)));
        obj.go.plot.error(i).YData = gather(obj.errors(i,:));
    end

    obj.go.image(1,1).CData = gather(getScatteringPart(obj.W, obj.intpart));
    obj.go.image(1,2).CData = gather(getScatteringPart(obj.WS, obj.intpart));
    
    if ~obj.masking.fillMask
        obj.go.image(1,2).CData(~obj.MASK) = nan;
    end
    if obj.go.checkbox(1).Value
        obj.subscale = str2num_fast(obj.go.edit(3).String);
        obj.go.image(2,1).CData = gather(getReconstructionPart( obj.ws, obj.reconpart) - (obj.rho0 .* obj.subscale) );
        obj.go.image(2,2).CData = gather(getReconstructionPart( obj.w, obj.reconpart) - (obj.rho0 .* obj.subscale) );
    else
        obj.go.image(2,1).CData = gather(getReconstructionPart(obj.ws, obj.reconpart));
        obj.go.image(2,2).CData = gather(getReconstructionPart(obj.w, obj.reconpart));
    end
    obj.setPlotRange();
    obj.go.axes(3).Title.String = sprintf('reconstructed - %i steps', obj.nTotal);
    obj.go.axes(5).Title.String = sprintf('before constraints - %i steps', obj.nTotal);
    obj.go.figure(1).Pointer = 'arrow';
    drawnow limitrate;
end
