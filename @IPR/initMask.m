function obj = initMask(obj)
    
    obj.MASK = (~isnan(obj.SCATT));
    [obj.xx, obj.yy] = meshgrid(...
        linspace(1,obj.imgsize(2),obj.imgsize(2)) - obj.center(2),...
        linspace(1,obj.imgsize(1),obj.imgsize(1)) - obj.center(1) );

    obj.MASK = ( obj.MASK & ~isnan(obj.SCATT) );
    if obj.masking.constraint_rmin
        obj.MASK = ( obj.MASK & (obj.xx.^2+obj.yy.^2 >= obj.masking.rmin.^2) );
    end
    obj.RMASK = ( obj.xx.^2+obj.yy.^2 <= obj.masking.rmax.^2 );
    if obj.masking.constraint_gapMask            
        obj.gapMask = true(size(obj.MASK), 'like', obj.MASK);
        obj.gapMask( obj.center(1) - round(obj.masking.gapSize/2:obj.masking.gapSize/2-1), :) = 0;
        obj.MASK = obj.MASK .* obj.gapMask;
    end
    if obj.masking.constraint_wedgeMask
        %     wedgeAngles = [-15 15; 165 -165;-15 15; 165 -165; -105 -75 ; 75 105]/180*pi;
        %
        %     wedgeAngles = [0 0; 180 -180; 0 0; 180 -180; -90 -90; 90 90]/180*pi ...
        %         + [-1 1; -1 1; -1 1; -1 1; -1 1 ; -1 1]*obj.masking.wedgeAngle;
        %     wedgeCenters = [hGapPx 0; hGapPx 0; -hGapPx 0; -hGapPx 0; 0 0; 0 0];
        
        obj.wedgeMask = ( abs(atan(obj.yy./obj.xx)) > obj.masking.wedgeAngle );
        
        hGapPx = obj.masking.gapSize/2;
        
        
        wedgeAngles = [0 0; 180 -180; 0 0; 180 -180]/180*pi ...
            + [-1 1; -1 1; -1 1; -1 1]*obj.masking.wedgeAngle;
        wedgeCenters = [hGapPx-1 0; hGapPx-1 0; -hGapPx, 0; -hGapPx, 0];
        
        if obj.masking.constraint_verticalWedgeMask
            verticalWedgeAngles =  [-90 -90; 90 90]/180*pi ...
                + [-1 1; -1 1]*obj.masking.verticalWedgeAngle;
            verticalWedgeCenters = [0 0; 0 0]*obj.masking.wedgeAngle;
            wedgeAngles = [wedgeAngles;verticalWedgeAngles];
            wedgeCenters = [wedgeCenters; verticalWedgeCenters];
        end
        wedgeCenters(:,1) = obj.center(1)+wedgeCenters(:,1);
        wedgeCenters(:,2) = obj.center(2)+wedgeCenters(:,2);
        obj.wedgeMask = computeRadialMask(obj.imgsize, wedgeAngles, wedgeCenters);
        obj.MASK = (obj.MASK .* obj.wedgeMask); 
    end
    if obj.masking.constraint_RMask
        obj.MASK = (obj.MASK .* obj.RMASK);
        if obj.masking.constraint_RMaskSmoothing
            obj.RMASK_smooth = imgaussfilt(single(obj.RMASK), obj.masking.RMASK_smoothPix); 
        end
    end
    if obj.masking.dilate
        obj.MASK = (~imdilate(~obj.MASK, ...
            strel(obj.masking.dilateMethod, double(obj.masking.dilateFactor))));
        % HAS TO BE DOUBLE FOR STREL !
    end
end
