function xylabel(varargin)

if isgraphics(varargin{1})
    hAx = varargin{1};
    xLabel = varargin{2};
    yLabel = varargin{3};
else
    hAx = gca;
    xLabel = varargin{1};
    yLabel = varargin{2};
end

for i=1:numel(hAx)
    xlabel(hAx(i), xLabel);
    ylabel(hAx(i), yLabel);
%     hAx(i).XLabel.String = xLabel;
%     hAx(i).YLabel.String = yLabel;
end
