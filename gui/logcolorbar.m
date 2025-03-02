function h = logcolorbar(varargin)
drawnow;
if nargin < 1
    args = gca;
else
    args = varargin{:};
end
set(gca, 'colorscale', 'log');
h = colorbar(args);
% h.TickLabels = sprintf('10^{%.0g}\n', (h.Ticks));
