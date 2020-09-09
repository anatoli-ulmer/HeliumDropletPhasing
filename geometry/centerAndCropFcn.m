function img = centerAndCropFcn(img,center)
    hsz = size(img)/2;
    img2 = zeros(1536, 'like', img);
    img2(round(1025-hsz(1):1024+hsz(1)), ...
        round(1025-hsz(2):1024+hsz(2))) = img;
    center = round(center-hsz)-1;
    img = img2(...
        1025-512+center(1):1024+512+center(1), ...
        1025-512+center(2):1024+512+center(2));
%     img = imcrop(img, [ round(fliplr(center)) - 512  , 1023, 1023 ] );
end