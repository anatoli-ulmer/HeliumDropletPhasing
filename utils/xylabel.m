function xylabel(varargin)

if isgraphics(varargin{1})
    switch class(varargin{1})
        case 'matlab.graphics.axis.Axes'
            ax = varargin{1};
        case {'matlab.ui.Figure', 'matlab.graphics.layout.TiledChartLayout'}
            fig = varargin{1};
            ax = [];
            for i = 1:numel(fig.Children)
                switch class(fig.Children(i))
                    case 'matlab.graphics.layout.TiledChartLayout'
                        for j = 1:numel(fig.Children(i).Children)
                            if isa(fig.Children(i).Children(j), 'matlab.graphics.axis.Axes')
                                ax = [ax, fig.Children(i).Children(j)];
                            end
                        end
                    case 'matlab.graphics.axis.Axes'
                        ax = [ax, fig.Children(i)];
                end
            end
    end
    xLabel = varargin{2};
    yLabel = varargin{3};
else
    ax = gca;
    xLabel = varargin{1};
    yLabel = varargin{2};
end

for i=1:numel(ax)
    xlabel(ax(i), xLabel);
    ylabel(ax(i), yLabel);
%     hAx(i).XLabel.String = xLabel;
%     hAx(i).YLabel.String = yLabel;
end
