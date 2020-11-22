function center = findCenterXcorr(img, center, windowSize, ringRadii)

figure(23436); clf;
ax(1) = subplot(3,3,[1:2,4:5,7:8]);
ax(2) = mysubplot(3,3,3);
ax(3) = mysubplot(3,3,9);
ax(4) = mysubplot(3,3,6);
imgPlt(1) = imagesc(ax(1), nan);
imgPlt(2) = imagesc(ax(2), nan);
imgPlt(3) = imagesc(ax(3), nan);
imgPlt(4) = imagesc(ax(4), nan);

hold(ax(1), 'on');
hold(ax(2), 'on');
hold(ax(3), 'on');
hold(ax(4), 'on');

linePlt(1,1) = plot(ax(1), nan, nan, 'g+', 'LineWidth', .5, 'MarkerSize', 50);
linePlt(3,1) = plot(ax(3), nan, nan, 'g+', 'LineWidth', .5, 'MarkerSize', 50);

%% calculation
nanMask = isnan(img);
nanMask = imdilate(nanMask, strel('disk',10));
img(nanMask) = 0;

centerInt = round(center);
lowerHalf = img( centerInt(1)-windowSize/2 : centerInt(1)-1, ...
    centerInt(2)-windowSize/2 : centerInt(2)+windowSize/2-1 );

upperHalf = img(centerInt(1) : centerInt(1)+windowSize/2-1, ...
    centerInt(2)-windowSize/2 : centerInt(2)+windowSize/2-1 );

% upperHalf(1:70,:) = 0;
% lowerHalf(end-69:end,:) = 0;
% vertGap = 60;
% upperHalf(:,size(upperHalf,2)/2-vertGap/2:size(upperHalf,2)/2+vertGap/2-1) = 0;
% lowerHalf(:,size(lowerHalf,2)/2-vertGap/2:size(lowerHalf,2)/2+vertGap/2-1) = 0;

imgXcorr = xcorr2(lowerHalf, rot90(upperHalf,2));

maxVal = max(imgXcorr(:));

[yMax, xMax] = find(maxVal == imgXcorr);
centerShift(2) = xMax - windowSize;
centerShift(1) = yMax - windowSize/2;
center = centerInt + centerShift/2;

%% plotting
img(nanMask) = nan;

imgPlt(1).CData = log10(abs(img));
imgPlt(4).CData = log10(abs(lowerHalf));
imgPlt(2).CData = log10(abs(upperHalf));
imgPlt(3).CData = imgXcorr;

imgPlt(3).XData = imgPlt(3).XData - windowSize;
imgPlt(3).YData = imgPlt(3).YData - windowSize/2;

linePlt(1,1).XData = center(2);
linePlt(1,1).YData = center(1);
linePlt(3,1).XData = xMax - windowSize;
linePlt(3,1).YData = yMax - windowSize/2;

draw_rings(ax(1), center, [], ringRadii, 1, [.3,.3,.3]);

ax(1).CLim = [-1,2];
ax(2).CLim = [-1,2];
ax(4).CLim = [-1,2];
ax(1).XLim = [-1,1]*windowSize/2 + center(2);
ax(1).YLim = [-1,1]*windowSize/2 + center(1);

ax(1).Title.String = sprintf('center = [%.1f, %.1f]', center(1), center(2));
% ax(2).Title.String = 'upper detector';
% ax(4).Title.String = 'lower detector';
ax(3).Title.String = 'cross correlation';
ax(3).XLabel.String = sprintf('x shift = %.0fpx', centerShift(2));
ax(3).YLabel.String = sprintf('y shift = %.0fpx', centerShift(1));

arrayfun(@(a) set(ax(a), 'XTickLabel', [], 'YTickLabel', []), [1,2,4]);

fprintf('shift = [%.2f, %.2f]\n', centerShift(1), centerShift(2))
fprintf('center = [%.2f, %.2f]\n', center(1), center(2))


