function h = logcolorbar(varargin)

h = colorbar(varargin);
h.TickLabels = sprintf('10^{%.0g}\n', (h.Ticks));