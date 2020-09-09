function saveImg(cdata, filename, cmap)

if ~exist('cmap', 'var')
    cmap = wjet;
end

rgbData = ind2rgb(cdata, cmap);
imwrite(cdata,cmap,filename);