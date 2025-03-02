function hImg = imagescs(varargin)

if isgraphics(varargin{1})
    hAx = varargin{1};
    imageOptions = varargin(2:end);
else
    hAx = gca;
    imageOptions = varargin;
end

hImg = gobjects(1,numel(hAx));

for i=1:numel(hAx)
    hImg(i) = imagesc(hAx(i), imageOptions{:});
end
