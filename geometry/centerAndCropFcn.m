function img = centerAndCropFcn(img,center,interpolate)
    
    if nargin<3
        interpolate=false;
    end
    hsz = size(img)/2;

    if interpolate
        nimg=img;
        nanmask=isnan(img);
        nimg(nanmask)=0;
        newcenter=(hsz+1);
        shift = -center + newcenter;
        if any(isnan(shift))
            shift = [0,0];
        end
        nimg = imtranslate(nimg,shift([2,1]),'bilinear');
        nanmask = imtranslate(nanmask,shift([2,1]));
        nimg(nanmask)=nan;
        padsize=50;
        nimg=padarray(nimg,[padsize,padsize],'both');
        newcenter=newcenter+padsize;
        img=nimg(newcenter(1)+(-512:511),newcenter(2)+(-512:511));
    else
        img2 = nan(2048, 'like', img);
        img2( round( 1024+( -hsz(1):(hsz(1)-1) ) ), ...
            round( 1024+( -hsz(2):(hsz(2)-1) ) ) ) = img;
        center = round(center-hsz)-1;
        %     center = center+[1,1];
        img = img2(...
            1024+(-512:511)+center(1), ...
            1024+(-512:511)+center(2) );
    end
end
