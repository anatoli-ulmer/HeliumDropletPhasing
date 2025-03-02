function myImwrite(img, cmap, clim, filename, varargin)
if nargin<3
    filename=cmap;
    cmap=imorgen;
end
bitDepth = 8;
if nargin>3
    for i=1:numel(varargin)
        if strcmpi(varargin{i}, 'bitdepth')
            bitDepth = varargin{i+1};
        end
    end
end
%% Scale image values before saving

img = gather(img);
img = double(img);
img(isinf(img))=nan;
if isempty(clim)
    clim = [0, nanmax(img(:))] + [1,-1]*nanmin(img(:));
end
img = (img-clim(1));
img = img/clim(2);
img = uint8(img*255);
% img = 1+img*size(cmap,1);
% img = img*(2^bitDepth-1);
% if bitDepth<=8
%     img = img;
% else
%     img = uint16(img);
%     varargin = [varargin, 'mode', 'lossless'];
% end
% rgb = ind2rgb(img, cmap);

% img2 = im2double(gather(img));
%% Save image
imwrite(img, cmap, filename, varargin{:});
% imwrite(rgb, cmap, filename, varargin{:});