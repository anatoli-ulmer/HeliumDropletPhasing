function hRingPlots = draw_rings(hAx, center, nRings, ringRadii, ...
    ringWidth, ringColor, ringStyle, hRingPlots)

%DRAW_RINGS
%
% hRingPlots = draw_rings(hAx, center, nRings, ringRadii, ...
%     ringWidth, ringColor, ringStyle)

lims = [hAx.XLim, hAx.YLim];

if ~exist('ringRadii', 'var')
    ringRadii = [];
end
if isempty(nRings)
    nRings = numel(ringRadii);
end
if nRings == 0
    nRings = numel(ringRadii);
end
if isempty(ringRadii)
    sizex = hAx.XLim(2) - hAx.XLim(1);
    sizey = hAx.YLim(2) - hAx.YLim(1);
    ringRadii = linspace(1, min(sizex, sizey), nRings);
end
if ~exist('ringWidth', 'var')
    ringWidth = .5;
end
if isempty(ringWidth)
    ringWidth = .5;
end
if ~exist('ringColor', 'var')
    ringColor = 'r';
end
if isempty(ringColor)
    ringColor = 'r';
end
if ~exist('ringStyle', 'var')
    ringStyle= '--';
end
if isempty(ringStyle)
    ringStyle = '--';
end
if ~exist('hRingPlots', 'var')
    hRingPlots=gobjects(1);
end

th = [linspace(0,2*pi,50), nan];
xunit = cos(th)' * ringRadii + center(2);
yunit = sin(th)' * ringRadii + center(1);

if isgraphics(hRingPlots)
    hRingPlots.XData = xunit(:);
    hRingPlots.YData = yunit(:);
    hRingPlots.Color = ringColor;
    hRingPlots.LineWidth = ringWidth;
    hRingPlots.LineStyle = ringStyle;
else
    hold(hAx, 'on');
    hRingPlots = plot(hAx, xunit(:), yunit(:), 'Color', ringColor, ...
        'LineWidth', ringWidth, 'LineStyle', ringStyle);
    hold(hAx, 'off');
end
    
hAx.XLim = lims(1:2);
hAx.YLim = lims(3:4);
