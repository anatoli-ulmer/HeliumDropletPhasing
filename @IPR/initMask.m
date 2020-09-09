function obj = initMask(obj)
    
    obj.MASK = (~isnan(obj.SCATT));

    [obj.xx, obj.yy] = meshgrid(...
        gpuArray.linspace(1,obj.imgsize(2),obj.imgsize(2)) - obj.center(2),...
        gpuArray.linspace(1,obj.imgsize(1),obj.imgsize(1)) - obj.center(1) );

    obj.MASK = ( obj.MASK & ~isnan(obj.SCATT) );
    obj.MASK = ( obj.MASK & (obj.xx.^2+obj.yy.^2 >= obj.masking.rmin.^2) );

    obj.RMASK = ( obj.xx.^2+obj.yy.^2 <= obj.masking.rmax.^2 );
    
    obj.wedgeMask = ( abs(atan(obj.yy./obj.xx)) > obj.masking.wedgeAngle );
    obj.gapMask = true(size(obj.MASK), 'like', obj.MASK);
    obj.gapMask( ( obj.center(1)-round(obj.masking.gapSize*obj.binFactor/2) ) : ...
        ( obj.center(1)+round(obj.masking.gapSize*obj.binFactor/2)-1 ) , :) = 0;

    if obj.masking.constraint_gapMask
         obj.MASK = obj.MASK .* obj.gapMask;
%          obj.wedgeMask = ...
%              ( abs(atan( (obj.yy-obj.masking.gapSize/obj.binFactor)./obj.xx )) > obj.masking.wedgeAngle );% & ...
%              ( abs(atan( (obj.yy+obj.masking.gapSize/obj.binFactor-1)./obj.xx )) > obj.masking.wedgeAngle );
    end
    if obj.masking.constraint_wedgeMask
        obj.MASK = (obj.MASK .* obj.wedgeMask); 
    end
    if obj.masking.constraint_RMask
        obj.MASK = (obj.MASK .* obj.RMASK);
        obj.RMASK_smooth = imgaussfilt(single(obj.RMASK), obj.masking.RMASK_smoothPix); 
    end
    if obj.masking.dilate
        obj.MASK = (~imdilate(~obj.MASK, ...
            strel('disk', double(obj.masking.dilateFactor))));
        % HAS TO BE DOUBLE FOR STREL !
    end
end