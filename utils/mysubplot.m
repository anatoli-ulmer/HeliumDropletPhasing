function hAx = mysubplot(varargin)

axesOptions = [];
idx = [];

if isobject(varargin{1})
    hFig = varargin{1};
    nrows = varargin{2};
    ncols = varargin{3};
    if nargin>3
        idx = varargin{4};
    end
    if nargin>4
        axesOptions = varargin(5:end);
    end
else
    hFig = gcf;
    nrows = varargin{1};
    ncols = varargin{2};
    if nargin>2
        idx = varargin{3};
    end
    if nargin>3
        axesOptions = varargin(4:end);
    end
end

if isempty(idx)
    idx = 1:nrows*ncols;
end

for i=1:numel(idx)
    outerPosition = [ ...
        (mod(idx(i)-1,ncols))/ncols, ...
        1-ceil(idx(i)/ncols)/nrows, ...
        1/ncols, ...
        1/nrows ...
        ];

    if isempty(axesOptions)
        hAx(i) = axes(hFig, 'OuterPosition', outerPosition);
    else
        hAx(i) = axes(hFig, 'OuterPosition', outerPosition, axesOptions{:});
    end
end

% fprintf('subplot(%i,%i,%i, position [%.02f,%02f,%02f,%02f]\n', nrows,ncols,idx, (mod(idx-1,ncols))/ncols, 1-ceil(idx/ncols)/nrows, 1/ncols, 1/nrows)
