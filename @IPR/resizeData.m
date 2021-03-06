function obj = resizeData(obj)

    obj.masking.rmin = obj.masking.rmin*obj.binFactor;
    obj.masking.rmax = obj.masking.rmax*obj.binFactor;
    
    sizeOld = single(size(obj.SCATT));
    obj.SCATT = imresize(obj.SCATT, obj.binFactor, obj.binMethod)/obj.binFactor^2;
%     % self written method so be sure that binning works correct
%     obj.SCATT = imgBinning(obj.SCATT, obj.binFactor);

    obj.SCATT = (single(obj.SCATT));
    obj.support0 = (single(obj.support0));
    obj.rho0 = (single(obj.rho0));
    
    if obj.filter.gauss.isApplied
        obj.SCATT = imgaussfilt(obj.SCATT, obj.filter.gauss.sigma);
    end

    obj.SCATT(obj.SCATT<obj.masking.minPhotons) = 0;
    obj.SCATT(obj.SCATT>obj.masking.maxPhotons) = nan;

    obj.imgsize = size(obj.SCATT);
    obj.center = obj.imgsize/2+1;

    obj.support0 = cropThis(obj.support0, sizeOld, obj.imgsize);
    obj.rho0 = cropThis(obj.rho0, sizeOld, obj.imgsize);
    
    if ~isempty(obj.simScene)
        obj.simScene = single(obj.simScene);
        obj.simSceneFlipped = circshift(rot90(obj.simScene,2), [1,1]);
        obj.simScene = cropThis(obj.simScene, sizeOld, obj.imgsize);
        obj.simSceneFlipped = cropThis(obj.simSceneFlipped, sizeOld, obj.imgsize);
    end

    if obj.support_dilate
        obj.support0 = ( 0 < imdilate(...
            obj.support0>0, strel(obj.support_dilateMethod, double(obj.support_dilateFactor))...
            ) );
    end
    obj.support = obj.support0;
    
    function img = cropThis(img,sizeOld,sizeNew)
        img = img(...
                colon( ...
                1+sizeOld(1)/2 - sizeNew(1)/2 , ...
                sizeOld(1)/2 + sizeNew(1)/2 ...
                ), ...
                colon( ...
                1+sizeOld(2)/2 - sizeNew(2)/2 , ...
                sizeOld(2)/2 + sizeNew(2)/2 ...
                ) ...
            );
    end
end
