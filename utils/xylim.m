function xylim(varargin)

if isgraphics(varargin{1})
    hAx = varargin{1};
    xLim = varargin{2};
    if nargin>2
        yLim = varargin{3};
    else
        yLim = xLim;
    end
else
    hAx = gca;
    xLim = varargin{1};
    if nargin>1
        yLim = varargin{2};
    else
        yLim = xLim;
    end
end

for i=1:numel(hAx)
    hAx(i).XLim = xLim;
    hAx(i).YLim = yLim;
end
