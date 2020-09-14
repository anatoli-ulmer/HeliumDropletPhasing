function img = centerAndCropFcn(img,center)
    hsz = size(img)/2;
    img2 = nan(2048, 'like', img);
    img2( round( 1024+( -hsz(1):(hsz(1)-1) ) ), ...
        round( 1024+( -hsz(2):(hsz(2)-1) ) ) ) = img;
    center = round(center-hsz)-1;
    img = img2(...
        1024+(-512:511)+center(1), ...
        1024+(-512:511)+center(2) );
%     img = imcrop(img, [ round(fliplr(center)) - 512  , 1023, 1023 ] );
end