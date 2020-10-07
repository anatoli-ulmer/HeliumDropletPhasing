function hFig = getFigure(hFig, varargin)
    if mod(numel(varargin),2)~=0
        error('Optional arguments must come in name-value-pairs.')
    end
    if ~isgraphics(hFig)
        hFig = findobj('Type','Figure',varargin{:});
        if isempty(hFig)
            hFig = figure;
            hFig.NumberTitle='off';
            % overwrite data by variable input arguments
            for i=1:2:numel(varargin)
                hFig.(varargin{i})=varargin{i+1};
            end
        end
    end
end
