function [center, hCentering] = findCenterXcorr(hCentering, ...
    img, center, windowSize, ringRadii, shiftStrength)

%% calculation
nanMask = isnan(img);
nanMask = imdilate(nanMask, strel('disk',10));
img(nanMask) = 0;

centerInt = round(center);
lowerHalf = img( centerInt(1)-windowSize/2 : centerInt(1)-1, ...
    centerInt(2)-windowSize/2 : centerInt(2)+windowSize/2-1 );

upperHalf = img(centerInt(1) : centerInt(1)+windowSize/2-1, ...
    centerInt(2)-windowSize/2 : centerInt(2)+windowSize/2-1 );

% % % lowerXcorr = xcorr2(lowerHalf, lowerHalf);
% % % upperXcorr = xcorr2(upperHalf, upperHalf);
% % % lowerMaxVal = max(lowerXcorr(:));
% % % upperMaxVal = max(upperXcorr(:));
% % % [lowerY, lowerX] = find(lowerMaxVal == lowerXcorr);
% % % [upperY, upperX] = find(upperMaxVal == upperXcorr);
% % % lowerShift = [lowerY - windowSize/2, lowerX - windowSize];
% % % upperShift = [upperY - windowSize/2, upperX - windowSize];
% % % 
% % % if any(lowerShift ~= 0) || any(upperShift ~= 0)
% % %     warning('lowerShift = [%i, %i]\nupperShift = [%i, %i]\n', ...
% % %         lowerShift(1), lowerShift(2), upperShift(1), upperShift(2) )
% % % end

imgXcorr = xcorr2(lowerHalf, rot90(upperHalf,2));
maxVal = max(imgXcorr(:));
[yMax, xMax] = find(maxVal == imgXcorr);
centerShift(2) = xMax - windowSize - 1;
centerShift(1) = yMax - windowSize/2 - 1;
center = center + centerShift/2 * shiftStrength;

%% plotting
img(nanMask) = nan;

hCentering.image(1).CData = log10(abs(img));
hCentering.image(4).CData = log10(abs(lowerHalf));
hCentering.image(2).CData = log10(abs(upperHalf));
hCentering.image(3).CData = imgXcorr;

hCentering.image(3).XData = [-windowSize/2, windowSize/2 - 1];
hCentering.image(3).YData = [-windowSize/4, windowSize/4 - 1];

hCentering.plot(1).XData = center(2);
hCentering.plot(1).YData = center(1);
hCentering.plot(2).XData = xMax - windowSize;
hCentering.plot(2).YData = yMax - windowSize/2;

hCentering.plot(3) = draw_rings(hCentering.axes(1), center, [], ...
    ringRadii, 1, [.3,.3,.3], [], hCentering.plot(3));

hCentering.axes(1).CLim = [-1,2];
hCentering.axes(2).CLim = [-1,2];
hCentering.axes(4).CLim = [-1,2];
hCentering.axes(1).XLim = [-1,1]*windowSize/2 + center(2);
hCentering.axes(1).YLim = [-1,1]*windowSize/2 + center(1);
hCentering.axes(3).XLim = hCentering.image(3).XData;
hCentering.axes(3).YLim = hCentering.image(3).YData;

hCentering.axes(1).Title.String = sprintf('center = [%.1f, %.1f]', center);
% ax(2).Title.String = 'upper detector';
% ax(4).Title.String = 'lower detector';
hCentering.axes(3).Title.String = 'cross correlation';
hCentering.axes(3).XLabel.String = sprintf('x shift = %.0fpx', centerShift(2));
hCentering.axes(3).YLabel.String = sprintf('y shift = %.0fpx', centerShift(1));

arrayfun(@(a) set(hCentering.axes(a), 'XTickLabel', [], 'YTickLabel', []), [1,2,4]);

fprintf('\t\tshift = [%.2f, %.2f]\n', centerShift)
fprintf('\t\tcenter = [%.2f, %.2f]\n', center)


