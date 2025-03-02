function obj = updateGUI(obj,~,~)

    for i=1:size(obj.go.plot.error,1)
        for j=1:size(obj.errors,1)
            obj.go.plot.error(i,j).XData = 1:(numel(gather(obj.errors(j,:)))-1);
            obj.go.plot.error(i,j).YData = gather(obj.errors(j,1:end-1));
            if ~isempty(obj.go.plot.error(1,j).XData) && ~isempty(obj.go.plot.error(1,j).YData)
                obj.go.text.error(i,j).Position(1:2) = nan2zero([obj.go.plot.error(i,j).XData(end-1), obj.go.plot.error(i,j).YData(end-1)]);
                obj.go.text.error(i,j).Visible = obj.go.plot.error(1,j).Visible;
                switch j
                    case 1, obj.go.text.error(i,j).String = sprintf('$E_F$=%.3f', obj.go.plot.error(1,j).YData(end-1));
                    case 2, obj.go.text.error(i,j).String = sprintf('$E_R$=%.3f', obj.go.plot.error(1,j).YData(end-1));
                    case 3, obj.go.text.error(i,j).String = sprintf('$E_S$=%.3f ', obj.go.plot.error(1,j).YData(end-1));
                    case 4, obj.go.text.error(i,j).String = sprintf('$E_{NRMSD}$=%.3f ', obj.go.plot.error(1,j).YData(end-1));
                end
                obj.go.text.error(i,j).Interpreter = 'latex';
            end
        end
    end

    if obj.plotting.poissonNoise
        obj.go.image(1,1).CData = gather(getScatteringPart( ...
            exp(1i.*obj.PHASE) .* (...
            sqrt(imnoise(obj.AMP.^2/1e6/obj.binFactor^2,'poisson') *1e6*obj.binFactor^2 ) ...
            ), obj.intpart));
        
        %     obj.go.image(1,2).CData = gather(getScatteringPart( ...
        %         exp(1i.*obj.PHASE) .* (...
        %         sqrt(imnoise(obj.AMP.^2*4/1e6,'poisson')*1e6/4).*(~obj.MASK) + obj.AMP0.*obj.MASK ...
        %         ) , obj.intpart));
        obj.go.image(1,2).CData = gather(getScatteringPart(obj.WS, obj.intpart));
    else
        obj.go.image(1,1).CData = gather(getScatteringPart(obj.W, obj.intpart));
        obj.go.image(1,2).CData = gather(getScatteringPart(obj.WS, obj.intpart));
    end
    
    
    if obj.masking.fillMask
        obj.go.image(1,2).CData(obj.MASK==0) = obj.go.image(1,1).CData(obj.MASK==0);
    else
        obj.go.image(1,2).CData(~obj.MASK) = nan;
    end
        
    if obj.go.checkbox(1).Value
        obj.subscale = str2double(obj.go.edit(3).String);
        img1Data = (obj.ws - (obj.rho .* obj.subscale));
        img2Data = (obj.w - (obj.rho .* obj.subscale));
%         img1Alpha = 
%         img2Alpha = 
%         obj.go.image(2,1).CData = gather();
%         obj.go.image(2,2).CData = gather(compleximagedata(obj.w - (obj.rho0 .* obj.subscale)));
%         obj.go.image(2,1).AlphaData=gather(abs(obj.ws - (obj.rho0 .* obj.subscale)));
%         obj.go.image(2,2).AlphaData=gather(abs(obj.w - (obj.rho0 .* obj.subscale)));
%         obj.go.image(2,1).CData = gather(getReconstructionPart( obj.ws, obj.reconpart) - (obj.rho0 .* obj.subscale) );
%         obj.go.image(2,2).CData = gather(getReconstructionPart( obj.w, obj.reconpart) - (obj.rho0 .* obj.subscale) );

    else
        img1Data = obj.ws;
        img2Data = obj.w;
%         obj.go.image(2,1).CData = gather(getReconstructionPart(obj.ws, obj.reconpart));
%         obj.go.image(2,2).CData = gather(getReconstructionPart(obj.w, obj.reconpart));
%         obj.go.image(2,1).CData = gather(compleximagedata(obj.ws));
%         obj.go.image(2,2).CData = gather(compleximagedata(obj.w));
%         obj.go.image(2,1).AlphaData=gather(abs(obj.ws));
%         obj.go.image(2,2).AlphaData=gather(abs(obj.w));
    end
    

    obj.plotting.drawDroplet = obj.go.checkbox(3).Value;
    if obj.plotting.drawDroplet
        arrayfun(@(a) set(obj.go.droplet.axes(a), 'Visible', 'on'), 1:2, 'uni', 0);
        arrayfun(@(a) set(obj.go.axes(a), 'Visible', 'off'), 5:6, 'uni', 0);
        arrayfun(@(a) set(obj.go.plot.ellipse(a), 'Visible', 'off'), 1:2, 'uni', 0);
        obj.go.droplet.image(1).CData = gather(getReconstructionPart(obj.rho, obj.reconpart));
        obj.go.droplet.image(2).CData = obj.go.droplet.image(1).CData;
        obj.go.droplet.image(1).AlphaData = obj.plotting.alpha.droplet;
        obj.go.droplet.image(2).AlphaData = obj.plotting.alpha.droplet;
        
        
        [img1CData, img1AlphaData] = getReconstructionPart(img1Data, obj.reconpart, obj.plotting.alpha.dopant);
        [img2CData, img2AlphaData] = getReconstructionPart(img2Data, obj.reconpart, obj.plotting.alpha.dopant);
%         
%         arrayfun(@(a) set(obj.go.droplet.axes(a).Colorbar, 'Visible', 'off'), 1:2, 'uni', 0);
        arrayfun(@(a) set(obj.go.droplet.image(a), 'XData', obj.go.image(2,a).XData, 'YData', obj.go.image(2,a).YData), 1:2, 'uni', 0);
%         arrayfun(@(a) set(obj.go.droplet.axes(a), 'XLim', obj.go.axes(4+a).XLim, 'YLim', obj.go.axes(4+a).YLim), 1:2, 'uni', 0);
%         
        arrayfun(@(a) set(obj.go.droplet.axes(a), 'InnerPosition', obj.go.axes(a+4).InnerPosition), 1:2, 'uni', 0);
        arrayfun(@(a) colormap(obj.go.droplet.axes(a), obj.plotting.colormap.droplet), 1:2, 'uni', 0);
%         arrayfun(@(a) colormap(obj.go.axes(a+4), obj.plotting.colormap.dopant), 1:2, 'uni', 0);
         
    else
        arrayfun(@(a) set(obj.go.droplet.axes(a), 'Visible', 'off'), 1:2, 'uni', 0);
        arrayfun(@(a) set(obj.go.axes(a), 'Visible', 'on'), 5:6, 'uni', 0);
%         disp(obj.go.axes(5))
%         arrayfun(@(a) set(obj.go.axes(a), 'Color', [1, 1, 0]), 5:6, 'uni', 0);
        arrayfun(@(a) set(obj.go.plot.ellipse(a), 'Visible', 'on'), 1:2, 'uni', 0);
%         obj.go.plot.ellipse(1).Visible = 'on';
%         obj.go.plot.ellipse(2).Visible = 'on';
%         arrayfun(@(a) set(obj.go.droplet.axes(a).Colorbar, 'Visible', 'off'), 1:2, 'uni', 0);
%         arrayfun(@(a) set(obj.go.droplet.axes(a), 'Visible', 'off'), 1:2, 'uni', 0);
%         obj.go.droplet.axes(1).Colorbar.Visible = 'off';
%         obj.go.droplet.axes(2).Colorbar.Visible = 'off';
        img1CData = getReconstructionPart(img1Data, obj.reconpart);
        img2CData = getReconstructionPart(img2Data, obj.reconpart);
        img1AlphaData = 1.0;
        img2AlphaData = 1.0;
        
%         arrayfun(@(a) set(obj.go.axes(a), 'Color', [1 1 1], 'Box', 'on'), 5:6, 'uni', 0)
%         arrayfun(@(a) set(obj.go.axes(a).XAxis, 'Color', [1 1 1]), 5:6, 'uni', 0)
%         arrayfun(@(a) set(obj.go.axes(a).YAxis, 'Color', [1 1 1]), 5:6, 'uni', 0)
    end
    obj.go.image(2,1).CData = gather(img1CData);
    obj.go.image(2,2).CData = gather(img2CData);
    obj.go.image(2,1).AlphaData=gather(img1AlphaData);
    obj.go.image(2,2).AlphaData=gather(img2AlphaData);
%     amap = linspace(0,1,64)/0.25;
%     amap(amap>1) = 1;
%     obj.go.axes(5).Alphamap = amap; %round(linspace(0,64,64)/obj.plotting.alpha.dopant)/64;
%     alphamap(amap)

%     obj.go.axes(5).Colorbar.Colormap = obj.plotting.colormap.droplet;
%     obj.go.image(2,1).CData = obj.go.image(2,1).CData./max(obj.go.image(2,1).CData(:))*100;
%     obj.go.axes(5).Colorbar.
%     obj.go.axes(5).Colorbar.Ruler.TickLabelFormat='%g%%';
%     for i=1:numel(obj.go.axes(5).Colorbar.TickLabels)
%         obj.go.axes(5).Colorbar.TickLabels{i} = sprintf('%d%%', obj.go.axes(5).Colorbar.Ticks(i));
%     end

    obj.setPlotRange();
    obj.go.axes(3).Title.String = sprintf('reconstructed - %i steps', obj.nTotal-1);
    obj.go.axes(5).Title.String = sprintf('before constraints - %i steps', obj.nTotal-1);
    obj.go.figure(1).Pointer = 'arrow';
    drawnow;

    changeColorbarAlpha(obj.go.axes(5),obj.plotting.alpha.dopant);
    changeColorbarAlpha(obj.go.axes(6),obj.plotting.alpha.dopant);

    obj.go.axes(5).Title.String = sprintf('alpha = %.2f', obj.alpha);
    obj.go.axes(5).Title.Visible = 1;

%     ax = obj.go.axes(5);
%     ax.Colorbar.Face.ColorBinding = 'discrete';
%     ax.Colorbar.Face.Texture.ColorType = 'truecoloralpha';
%     ax.Colorbar.Face.Texture.CData(end,:) = 255*obj.plotting.alpha.droplet;
%     ax.Colorbar.Face.ColorBinding = 'interpolated';

end
