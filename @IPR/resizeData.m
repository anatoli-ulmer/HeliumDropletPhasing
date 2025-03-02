function obj = resizeData(obj)
    
    if obj.filter.roundOnPhotons
        obj.SCATT = single(round(obj.SCATT));
    end
    obj.SCATT(obj.SCATT>obj.masking.maxPhotons) = nan;

    sizeOld = single(size(obj.SCATT));
%     nPix = min(sizeOld);
%     osr=2;
%     binFactor = 1;
%     while nPix*binFactor>4*osr*obj.support_radius && binFactor>obj.binFactor
%         binFactor = binFactor/2;
%     end
%     obj.binFactor = binFactor;
    
    obj.masking.rmin = obj.masking.rmin*obj.binFactor;
    obj.masking.rmax = obj.masking.rmax*obj.binFactor;
    obj.masking.gapSize = obj.masking.gapSize*obj.binFactor/obj.padFactor;

    obj.SCATT = circshift(obj.SCATT, [1,1]*round(1/obj.binFactor/2-1)); % shift prior to resize so center is at N/2+1
    if strcmp(obj.binMethod, 'nanmean')
        obj.SCATT = imgBinning(obj.SCATT, obj.binFactor);
    else
%         obj.SCATT = single(nanimresize(double(obj.SCATT),  obj.binFactor, obj.binMethod));
        obj.SCATT = imresize(obj.SCATT,  obj.binFactor, obj.binMethod);
    end
    obj.SCATT = obj.SCATT/obj.binFactor^2;
    obj.SCATT = (single(obj.SCATT));
    obj.support0 = (single(obj.support0));
    obj.rho0 = (single(obj.rho0));
    
    
    if obj.filter.gauss.isApplied
        obj.SCATT = imgaussfilt(obj.SCATT, obj.filter.gauss.sigma);
    end
    
    obj.SCATT(obj.SCATT<obj.masking.minPhotons) = 0;
    obj.SCATT = abs(obj.SCATT);


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
    
    %% PADDING
    if obj.padFactor>1
%         obj.SCATT = zeropad(obj.SCATT, obj.imgsize*obj.padFactor, 'single')*obj.padFactor^2;
        obj.SCATT = nanpad(obj.SCATT, obj.imgsize*obj.padFactor, 'single')*obj.padFactor^2;
        obj.imgsize = size(obj.SCATT);
        obj.center = obj.center*obj.padFactor;
        obj.support0 = imresize(obj.support0, obj.padFactor);
        obj.rho0 = imresize(obj.rho0, obj.padFactor);
        obj.dropletOutline.x=2*obj.dropletOutline.x;
        obj.dropletOutline.y=2*obj.dropletOutline.y;
%         obj.masking.rmin = obj.masking.rmin * obj.padFactor;
%         obj.masking.rmax = obj.masking.rmax * obj.padFactor;
    end

    obj.supportShrunk = ~imdilate(~obj.support0, strel('disk',4));
    obj.support = obj.support0;
    obj.constraintsViolated = obj.support0;
    
    
    %% SUBFUNCTIONS
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

    function outp = nanpad(inp, dims, typename)
        
        if nargin < 3
            typename = class(inp);
        end
        if nargin < 2
            dims = 2*size(inp);
        elseif size(dims,2) == 1
            dims = [dims, dims];
        end

        if dims(1)==size(inp,1) && dims(2)==size(inp,2)
            return
        end

        outp = nan(dims(1), dims(2), typename);
        xx = round(dims(1)/2 - size(inp,1)/2);
        yy = round(dims(2)/2 - size(inp,2)/2);

        outp(xx: xx+size(inp,1)-1, yy: yy+size(inp,2)-1) = inp;
    end

    function outp = zeropad(inp, dims, typename)
        
        if nargin < 3
            typename = class(inp);
        end
        if nargin < 2
            dims = 2*size(inp);
        elseif size(dims,2) == 1
            dims = [dims, dims];
        end

        if dims(1)==size(inp,1) && dims(2)==size(inp,2)
            return
        end

        outp = zeros(dims(1), dims(2), typename);
        xx = round(dims(1)/2 - size(inp,1)/2);
        yy = round(dims(2)/2 - size(inp,2)/2);

        outp(xx: xx+size(inp,1)-1, yy: yy+size(inp,2)-1) = inp;
    end

    function A = simpleshift(A, shifts)
        
        % use imtranslate instead!
        
        rts = shifts(1);
        cts = shifts(2);
        
        A = circshift(A, [rts,cts]);
        if rts>0
            A(1:rts,:) = 0;
        elseif rts<0
            A(end+rts:end,:) = 0;
        end
        if cts>0
            A(:,1:cts) = 0;
        elseif cts <0
            A(:,end+cts:end) = 0;
        end
    end
end
