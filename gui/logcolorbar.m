function h = logcolorbar(varargin)
drawnow;
h = colorbar(varargin);
h.TickLabels = sprintf('10^{%.0g}\n', (h.Ticks));
