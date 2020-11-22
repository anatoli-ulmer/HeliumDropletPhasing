function hRingPlots = draw_rings(hAx, center, nRings, ringRadii, ...
    ringWidth, ringColor, ringStyle)

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
if ~exist('ringColor', 'var')
    ringColor = 'r';
end
if ~exist('ringStyle', 'var')
    ringStyle= '--';
end
% hRingPlots=gobjects(nRings,1);
% xunit=[];
% yunit=[];

th = [linspace(0,2*pi,100), nan];
xunit = cos(th)' * ringRadii + center(2);
yunit = sin(th)' * ringRadii + center(1);
% for ind = 1:nRings
%     r = ringRadii(ind);
%     xunit = [xunit, r * cos(th) + center(2), nan];
%     yunit = [yunit, r * sin(th) + center(1), nan];
% end
hRingPlots = plot(hAx, xunit(:), yunit(:), 'Color', ringColor, ...
    'LineWidth', ringWidth, 'LineStyle', ringStyle);
hAx.XLim = lims(1:2);
hAx.YLim = lims(3:4);
