function [newcenter, hCentering, centerShift] = findCenterXcorr(hCentering, ...
    origimg, center, windowSize, ringRadii, shiftStrength, maskDilation, ...
    centerofmass, interpolate)

%% calculation
img=origimg;
nanMask = isnan(img);
nanMask = imdilate(nanMask, strel('disk', maskDilation));
img(nanMask) = 0;

if interpolate
    img=centerAndCropFcn(img,center,interpolate);
    centerInt=round(size(img)/2+1);
else
    centerInt = round(center);
end

lowerHalf = img( centerInt(1)-windowSize/2 : centerInt(1)-1, ...
    centerInt(2)-windowSize/2 : centerInt(2)+windowSize/2-1 );

upperHalf = img(centerInt(1) : centerInt(1)+windowSize/2-1, ...
    centerInt(2)-windowSize/2 : centerInt(2)+windowSize/2-1 );



%%
imgXcorr = xcorr2(lowerHalf, rot90(upperHalf,2));

if centerofmass
    averaginWindowSize=10;
    x=windowSize + (-averaginWindowSize/2:averaginWindowSize/2);
    y=windowSize/2 + (-averaginWindowSize/2:averaginWindowSize/2);
    imgXcorrAve=imgXcorr(y,x);
    [X, Y] = meshgrid(x, y);
%     meanA = mean(imgXcorrAve(:));
    sumA = sum(imgXcorrAve(:));
    centerOfMassX = sum(imgXcorrAve(:) .* X(:)) / sumA;
    centerOfMassY = sum(imgXcorrAve(:) .* Y(:)) / sumA;

    yMax=centerOfMassY;
    xMax=centerOfMassX;
    shiftStrength=shiftStrength*10;
else
    [~, maxIdx] = max(imgXcorr(:));
    [yMax, xMax] = ind2sub(size(imgXcorr),maxIdx);
end

centerShift = [yMax - windowSize/2, xMax - windowSize];
centerShift = centerShift - 1;
% centerShift = minimizePhaseRamps(img(centerInt(1)-512/2 : centerInt(1)+512/2-1, ...
%     centerInt(2)-512/2 : centerInt(2)+512/2-1), 5);

newcenter = center + centerShift * shiftStrength;
% newcenter = newcenter - [.5,0];
%%
% img2 = [lowerHalf; upperHalf];
% imgXcorr = xcorr2(img2, rot90(img2));
% 
% if centerofmass
%     filtimg = imgaussfilt(imgXcorr, 5);
%     maxVal = max(filtimg(:));
%     [yMax, xMax] = find(maxVal == filtimg);
%     imgXcorr = filtimg;
% %     averaginWindowSize=8;
% %     x=(-averaginWindowSize/2:averaginWindowSize/2);
% %     y=(-averaginWindowSize/2:averaginWindowSize/2);
% % 
% % %     maxVal = max(imgXcorr(:));
% % %     [yMax, xMax] = find(maxVal == imgXcorr);
% %     yMax = windowSize;
% %     xMax = windowSize;
% % 
% %     imgXcorrAve=imgXcorr(yMax + y, xMax + x);
% %     [X, Y] = meshgrid(x + (center(2)-round(center(2))), y + (center(1)-round(center(1))));
% % %     meanA = mean(imgXcorrAve(:));
% %     sumA = sum(imgXcorrAve(:));
% %     centerOfMassX = sum(imgXcorrAve(:) .* X(:))/sumA;
% %     centerOfMassY = sum(imgXcorrAve(:) .* Y(:))/sumA;
% % 
% %     yMax=5*centerOfMassY+windowSize;
% %     xMax=5*centerOfMassX+windowSize;
% % %     shiftStrength=shiftStrength*10;
% else
%     maxVal = max(imgXcorr(:));
%     [yMax, xMax] = find(maxVal == imgXcorr);
% end
% 
% centerShift = [yMax - windowSize, xMax - windowSize];
% newcenter = center + centerShift * shiftStrength;

%% plotting
origimg(nanMask) = nan;

hCentering.image(1).CData = log10(abs(origimg));
% hCentering.image(4).CData = log10(abs(lowerHalf));
% hCentering.image(2).CData = log10(abs(upperHalf));
hCentering.image(3).CData = imgXcorr;
% size(imgXcorr)

hCentering.image(3).XData = [-1,1]*windowSize-1;% + [0, 1]; % size of imgXcorr is (windowSize-1)!!!
hCentering.image(3).YData = [-1,1]*windowSize/2-1;% + [0, 1]; % size of imgXcorr is (windowSize-1)!!!

hCentering.plot(1).XData = newcenter(2);
hCentering.plot(1).YData = newcenter(1);
hCentering.line(1).Value = 0;%centerShift(1);
hCentering.line(2).Value = 0;%centerShift(2);
% hCentering.plot(2).XData = centerShift(2);
% hCentering.plot(2).YData = centerShift(1);


% try delete(hCentering.plot(2)); end
% hCentering.plot(2) = 
draw_rings(hCentering.axes(1), newcenter, [], ...
    ringRadii, 1, hCentering.plot(2).Color, [], hCentering.plot(2));

hCentering.axes(1).CLim = [-1.5,2];
% hCentering.axes(2).CLim = [-1.5,2];
% hCentering.axes(4).CLim = [-1.5,2];
hCentering.axes(1).XLim = [-1 1]*windowSize/2 + newcenter(2);
hCentering.axes(1).YLim = [-1,1]*windowSize/2 + newcenter(1);
hCentering.axes(3).XLim = hCentering.image(3).XData/2;
hCentering.axes(3).YLim = hCentering.image(3).YData/2;

hCentering.axes(1).Title.String = sprintf('center = [%.1f, %.1f]', newcenter);
% ax(2).Title.String = 'upper detector';
% ax(4).Title.String = 'lower detector';
hCentering.axes(3).Title.String = 'cross correlation';
hCentering.axes(3).XLabel.String = sprintf('x offset = %.0fpx', centerShift(2));
hCentering.axes(3).YLabel.String = sprintf('y offset = %.0fpx', centerShift(1));

% arrayfun(@(a) set(hCentering.axes(a), 'XTickLabel', [], 'YTickLabel', []), [1,2,4]);

fprintf('\t\tcenter = [%.1f, %.1f] // shift = [%.1f, %.1f] // shiftStrength = %.3f\n', newcenter, centerShift, shiftStrength)

%%

% 
% figure(86434); clf
% ax = axes;
% acImgData = origimg(newcenter(1)-windowSize/2:newcenter(1)+windowSize/2-1, newcenter(2)-windowSize/2:newcenter(2)+windowSize/2-1);
% acImgData(isnan(acImgData)) = 0;
% acImgData = ift2(abs(ft2(acImgData)).^2);
% acImg = imagesc(abs(acImgData)); axis image; colormap(wjet); ax.ColorScale = 'linear';
% xline(0, '--')
% yline(0, '--')
% % xline(newcenter(2))
% % yline(newcenter(1))
% acImg.XData = [-1,1]*windowSize - 1;
% acImg.YData = [-1,1]*windowSize - 1;