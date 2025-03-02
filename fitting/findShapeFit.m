function [shape, fitting, goh] = findShapeFit(intensity, ...
    radiusPX, fittingPart, goh)

% flags
do_filter_ac_polar = 1;
do_max_weighting = 0;
do_min_max = 1;
do_sqrt_int = 1;
do_shrink = 1;
do_max_bigger_min = 1;
do_median_instead_of_mean = 0;
do_min_one_pix_thresholding = 1;

shrinkSizePX = iif(do_min_max, -1, 1);
if ~do_min_max
    fittingPart = 'abs';
end

% variables
nPix = min(size(intensity));
radiusPX = radiusPX * nPix/1024*2; %because autocorrelation
dilutePX = 10;
diluteThreshold = 0.99;
centerSigma=radiusPX;
radialRange = .25;
minRangePixel = 7;
rMin = max([1, round(radiusPX - max([minRangePixel, radialRange*radiusPX]))]);
rMax = max([1, round(radiusPX + max([minRangePixel, radialRange*radiusPX]))]);
angularKernelPX = 10;
radialKernelPX = 1;
nProfiles = 100;
thresh = 1/12;
shape = [];
minPhotons=0.5;
exclude_thresh = 1;


% crop image to get quadratic matrix if necessary
center = size(intensity)/2+1;
intensity = intensity( center(1)-nPix/2:center(1)+nPix/2-1, ...
    center(2)-nPix/2:center(2)+nPix/2-1 );

[xx,yy] = meshgrid(-nPix/2:nPix/2-1,-nPix/2:nPix/2-1);

% intensity( xx.^2+yy.^2 > 420.^2) = nan;
% intensity( xx.^2+yy.^2 <= 65.^2) = nan; % 2021-12-28

nanMask = isnan(intensity);
floatMask = single(~nanMask);
diluteMask = single( imgaussfilt(floatMask, dilutePX) > diluteThreshold );
filterMask = imgaussfilt( (diluteMask), dilutePX*2);

intensity(isnan(intensity)) = 0;
intensity(intensity<minPhotons) = 0;
if do_sqrt_int
    amplitude = sqrt(intensity);
else
    amplitude = (intensity);
end


amplitudeFiltered = amplitude.*filterMask;
autocorr = ift2(amplitudeFiltered);

% I = real(autocorr);
% I = I.*(1 - exp( -(xx.^2+yy.^2)/2/centerSigma^2 ));
% I = I(nPix/2-rMax:nPix/2+1+rMax, nPix/2-rMax:nPix/2+1+rMax);
% BW1 = edge(I,'sobel');
% BW2 = edge(I,'canny');
% figure(343433);
% tiledlayout(1,2)
% nexttile
% imshow(BW1)
% title('Sobel Filter')
% nexttile
% imshow(BW2)
% title('Canny Filter')
% fittingPart = 'abs';

switch fittingPart
    case 'real', autocorr = real(autocorr);
    case 'imag', autocorr = imag(autocorr);
    case 'angle', autocorr = angle(autocorr);
    case 'abs', autocorr = abs(autocorr);
end

centerFilter = 1 - exp( -(xx.^2+yy.^2)/2/centerSigma^2 );
% fprintf('\t\t\tvariance(autocorrFiltered) = %.3g\n', var(real(autocorrFiltered(:))));

autocorrFiltered=(autocorr).*centerFilter;




% figure(3446); clf
% mysubplot(2,2,1); imagesc(floatMask);
% mysubplot(2,2,2); imagesc(log10(abs(intensity)));
% mysubplot(2,2,3); imagesc(diluteMask);
% mysubplot(2,2,4); imagesc(filterMask); colormap gray;

ac_polar = polar_matrix(autocorrFiltered,'xcenter',center(2),'ycenter',center(1));
ac_polar = ac_polar(:,rMin:rMax);
% ac_polar = diff(ac_polar);
polarSize = size(ac_polar);

%%%%%% removed 2022-02-01
% kernel = repmat(gausswin(size(ac_polar,2))', size(ac_polar,1), 1);
% ac_polar = ac_polar.*kernel;
%%%%%%

if do_filter_ac_polar
    kernel = ones(angularKernelPX, radialKernelPX);
    kernel = kernel.*repmat(gausswin(radialKernelPX)', angularKernelPX, 1);
    kernel = kernel.*repmat(gausswin(angularKernelPX), 1, radialKernelPX);
    ac_polar_filt = conv2(ac_polar, kernel, 'same');
else
    ac_polar_filt = ac_polar;
end


%%%%% MAX %%%%%
switch fittingPart
    case {'real', 'abs'}
        [~,maxIdx_window] = max(ac_polar,[],2);
        [~,maxFilteredIdx_window] = max(ac_polar_filt,[],2);
        % [~,minpol] = min(ac_polar,[],2);
        % [~,minfpol] = min(ac_polar_filt,[],2);
    case {'imag', 'angle'}
        [~,maxIdx_window] = max(abs(ac_polar),[],2);
        [~,maxFilteredIdx_window] = max(abs(ac_polar_filt),[],2);
end

if do_max_weighting
    maxIdxWeighted = maxIdx_window;
    maxFilteredIdxWeighted = maxFilteredIdx_window;
    
    xRangeLim = 2;
    for iY = 1:polarSize(1)
        xRange = maxIdx_window(iY)+(-xRangeLim:xRangeLim);
        xRange(xRange<1) = 1;
        xRange(xRange>polarSize(2)) = polarSize(2);
        maxIdxWeighted(iY) = sum(ac_polar(iY, xRange) .* xRange)/sum(ac_polar(iY, xRange));
        
        xRange = maxFilteredIdx_window(iY)+(-xRangeLim:xRangeLim);
        xRange(xRange<1) = 1;
        xRange(xRange>polarSize(2)) = polarSize(2);
        maxFilteredIdxWeighted(iY) = sum(ac_polar_filt(iY, xRange) .* xRange)/sum(ac_polar_filt(iY, xRange));
    end
    
    maxIdx_window = maxIdxWeighted;
    maxFilteredIdx_window = maxFilteredIdxWeighted;
end

maxIdx = maxIdx_window+rMin-1;
maxFilteredIdx = maxFilteredIdx_window+rMin-1;



%%%%% MIN %%%%%
if do_min_max
    ac_polar_min = ac_polar;
    ac_polar_min_filt = ac_polar_filt;
    if do_max_bigger_min
        for i=1:size(ac_polar,1)
            ac_polar_min(i,1:maxIdx_window(i)-6) = nan;
            ac_polar_min_filt(i,1:maxFilteredIdx_window(i)-6) = nan;
            ac_polar_min(i,maxIdx_window(i):end) = nan;
            ac_polar_min_filt(i,maxFilteredIdx_window(i):end) = nan;
        end
    end
    switch fittingPart
        case {'real', 'abs'}
            [~,minIdx_window] = min(ac_polar_min,[],2);
            [~,minFilteredIdx_window] = min(ac_polar_min_filt,[],2);

        case {'imag', 'angle'}
            [~,minIdx_window] = min(abs(ac_polar_min),[],2);
            [~,minFilteredIdx_window] = min(abs(ac_polar_min_filt),[],2);
    end    

    minIdx = minIdx_window+rMin-1;
    minFilteredIdx = minFilteredIdx_window+rMin-1;

    if do_max_bigger_min
        minIdx(minIdx>maxIdx) = nan;
    end
else
    minIdx = maxIdx;
    minFilteredIdx = maxFilteredIdx;
end

if do_shrink
    maxIdx = maxIdx-shrinkSizePX;
    maxFilteredIdx = maxFilteredIdx-shrinkSizePX;
    minIdx = minIdx-shrinkSizePX;
    minFilteredIdx = minFilteredIdx-shrinkSizePX;
end


th=thresh*polarSize(1);
ang_exclude = round([1:th, polarSize(1)/2-th:polarSize(1)/2+th, polarSize(1)-th:polarSize(1)]);

maxIdx(ang_exclude) = nan;
maxFilteredIdx(ang_exclude) = nan;

minIdx(ang_exclude) = nan;
minFilteredIdx(ang_exclude) = nan;



% % % % maxIdxRange = maxIdx+(-2:2);
% % % % maxIdxRange(maxIdxRange<1) = 1;
% % % % maxIdxRange(maxIdxRange>size(ac_polar,2)) = size(ac_polar,2);
% % % % maxIdx = sum( maxIdxRange .* ac_polar(maxIdxRange), 2 );
% % % % maxIdx = sum( (maxIdx-2:maxIdx+2) .* ac_polar, 2 );
% % % 
% % % % maxIdx= (minpol+maxIdx)/2+rmin;
% % % % maxFilteredIdx= (minfpol+maxFilteredIdx)/2+rmin;
% % % 
% % % % maxIdx = nansum(ac_polar./repmat(nansum(ac_polar,2), 1, size(ac_polar,2)).*repmat(rmin:rmax, size(ac_polar,1), 1) ,2);
% % % % maxFilteredIdx = nansum(ac_polar_filt./repmat(nansum(ac_polar_filt,2), 1, size(ac_polar_filt,2)).*repmat(rmin:rmax, polarSize(1), 1) ,2);
% % % % maxIdx=maxIdx+rmin-1;
% % % % maxFilteredIdx=maxFilteredIdx+rmin-1;

maxIdx_copy = maxIdx;
maxFilteredIdx_excluded = maxFilteredIdx;

minIdx_copy = minIdx;
minFilteredIdx_excluded = minFilteredIdx;

% % % % maxIdx(std(maxIdx, 'omitnan')<abs(maxIdx-nanmean(maxIdx))) = nan;
% % % % maxFilteredIdx(std(maxFilteredIdx, 'omitnan')<abs(maxFilteredIdx-nanmean(maxFilteredIdx))) = nan;
% % % % maxIdx_copy(std(maxIdx_copy, 'omitnan')>=abs(maxIdx_copy-nanmean(maxIdx_copy))) = nan;
% % % % maxFilteredIdx_excluded(std(maxFilteredIdx_excluded, 'omitnan')>=abs(maxFilteredIdx_excluded-nanmean(maxFilteredIdx_excluded))) = nan;

[maxIdx, maxIdx_exclude] = exclude_outliers(maxIdx, exclude_thresh, do_median_instead_of_mean);
[maxFilteredIdx, maxFilteredIdx_excluded] = exclude_outliers(maxFilteredIdx, exclude_thresh, do_median_instead_of_mean);
[minIdx, minIdx_exclude] = exclude_outliers(minIdx, exclude_thresh, do_median_instead_of_mean);
[minFilteredIdx, minFilteredIdx_excluded] = exclude_outliers(minFilteredIdx, exclude_thresh, do_median_instead_of_mean);

% maxIdx(exclude_thresh*std(maxIdx, 'omitnan')<abs(maxIdx-median(maxIdx, 'omitnan'))) = nan;
% maxFilteredIdx(exclude_thresh*std(maxFilteredIdx, 'omitnan')<abs(maxFilteredIdx-median(maxFilteredIdx, 'omitnan'))) = nan;
% % maxIdx_copy(exclude_thresh*std(maxIdx_copy, 'omitnan')>=abs(maxIdx_copy-nanmedian(maxIdx_copy))) = nan;
% maxFilteredIdx_excluded(exclude_thresh*std(maxFilteredIdx_excluded, 'omitnan')>=abs(maxFilteredIdx_excluded-median(maxFilteredIdx_excluded, 'omitnan'))) = nan;

% minIdx(exclude_thresh*std(minIdx, 'omitnan')<abs(minIdx-median(minIdx, 'omitnan'))) = nan;
% minFilteredIdx(exclude_thresh*std(minFilteredIdx, 'omitnan')<abs(minFilteredIdx-median(minFilteredIdx, 'omitnan'))) = nan;
% % minIdx_copy(exclude_thresh*std(minIdx_copy, 'omitnan')>=abs(minIdx_copy-nanmedian(minIdx_copy))) = nan;
% minFilteredIdx_excluded(exclude_thresh*std(minFilteredIdx_excluded, 'omitnan')>=abs(minFilteredIdx_excluded-median(minFilteredIdx_excluded, 'omitnan'))) = nan;


% figure(23343)
% plot(maxIdx)

ac_polar = ac_polar/max((ac_polar(:)));
ac_polar_filt = ac_polar_filt/max((ac_polar_filt(:)));


dstep = polarSize(1)/nProfiles;
lprofx = cell2mat(arrayfun(@(i) (rMin:rMax)', 1:nProfiles, 'UniformOutput', false));
lprofy = cell2mat(arrayfun(@(i) dstep*i/polarSize(1)*360+ac_polar_filt(round(dstep*i),:)'*10, 1:nProfiles, 'UniformOutput', false));
x = rMin:rMax;

goh(1).img(1) = imagesc(goh(1).axes(1),[rMin,rMax],[0,360],ac_polar, [-1,1]);

hold(goh(1).axes(3), 'off');
goh(1).img(3) = imagesc(goh(1).axes(3),[rMin,rMax],[0,360],ac_polar, [-1,1]);
goh(1).img(3).AlphaData = 0.5;
hold(goh(1).axes(3), 'on');
% imagesc(goh(1).axes(2),[rMin,rMax],[0,360],ac_polar_filt, [-1,1]);

plot(goh(1).axes(2),lprofx,lprofy);
angleArray = (1:numel(minFilteredIdx))/polarSize(1)*360;
goh(1).plt(4,1) = plot(goh(1).axes(3), minIdx, angleArray, 'b.', "DisplayName", 'min', 'MarkerSize',10);
goh(1).plt(4,3) = plot(goh(1).axes(3), maxIdx, angleArray, 'r.', 'DisplayName','max', 'MarkerSize',10);
goh(1).plt(4,2) = plot(goh(1).axes(3), minFilteredIdx_excluded, angleArray, 'x', 'DisplayName', 'excluded', 'Color', [.1 .1 .6], 'MarkerSize',10);
goh(1).plt(4,4) = plot(goh(1).axes(3), maxFilteredIdx_excluded, angleArray, 'x', 'DisplayName', 'excluded', 'Color', [.6 .1 .1], 'MarkerSize',10);
goh(1).plt(4,5) = plot(goh(1).axes(3), (minIdx+maxIdx)/2, angleArray, '.', 'DisplayName', 'edge', 'Color', [.2 .9 .2], 'MarkerSize',5);
yline(goh(1).axes(3), 360*[thresh, .5-thresh, .5+thresh, 1-thresh], 'k--')

legend([goh(1).plt(4,1:4)], 'Location', 'east', 'NumColumns', 2)


title(goh(1).axes(1), sprintf('%s(autocorrelation)', fittingPart));
title(goh(1).axes(2), sprintf('filtered %s part', fittingPart));
title(goh(1).axes(2), sprintf('traces of %s part', fittingPart));
title(goh(1).axes(3), 'min and max');

% arrayfun(@(i) colorbar(fig1axes(i), 'off'), 1:3);
arrayfun(@(i) xlabel(goh(1).axes(i), 'radius in px'), 1:3);
arrayfun(@(i) ylabel(goh(1).axes(i), 'angle in degree'), 1:3);
% arrayfun(@(i) colormap(fig1axes(i), r2b), 1:2);
arrayfun(@(i) set(goh(1).axes(i),'YDir','normal','YTick',0:30:360,...
    'XLim',[rMin,rMax],'YLim',[0,360],'PlotBoxAspectRatioMode','auto',...
    'DataAspectRatioMode','auto'), 1:3);

phi_array = linspace(-pi,pi,polarSize(1)+1);
phi_array = (phi_array(2:end) + phi_array(1:end-1))/2;

rmaxArray = maxFilteredIdx';
rminArray = minFilteredIdx';
rmaxArray_excluded = maxFilteredIdx_excluded';
rminArray_excluded = minFilteredIdx_excluded';
% r_array_copy = maxFilteredIdx_excluded';

rmaxArray(ang_exclude) = [];
rminArray(ang_exclude) = [];
rmaxArray_excluded(ang_exclude) = [];
rminArray_excluded(ang_exclude) = []; 


r_array = (rmaxArray + rminArray)/2;

[r_array, r_array_excluded] = exclude_outliers(r_array, exclude_thresh, do_median_instead_of_mean);

% ang_exclude = find(isnan(r_array));
phi_array(ang_exclude) = [];
% r_nm(ang_exclude) = [];
% r_nm_excluded(ang_exclude) = [];

%% Fitting
ft = fittype('ellipse_fitfcn(x, a, b, rot)');
[fitResults, goodnessOfFit] = fit( phi_array(~isnan(r_array))', ...
    r_array(~isnan(r_array))', ft, 'StartPoint', [radiusPX, radiusPX, 0] , ...
    'Upper', [rMax*3, rMax*3, pi], 'Lower', [rMin/3, rMin/3, -pi]);

fitting.fitResults = fitResults;
fitting.goodnessOfFit = goodnessOfFit;
shape.a = fitResults.a * 1024/nPix;
shape.b = fitResults.b * 1024/nPix;
% shape.rot = (mod(fitResults.rot+pi, 2*pi) - pi);
shape.rot = mod(fitResults.rot, 2*pi);
shape.R = (fitResults.a+fitResults.b)/2/2;
shape.aspectRatio = iif(fitResults.a>fitResults.b, fitResults.a/fitResults.b, ...
    fitResults.b/fitResults.a);
shape.manual = false;

%% Plotting

rmax_nm = 6*rmaxArray;
rmin_nm = 6*rminArray;
rmax_nm_excluded = 6*rmaxArray_excluded;
rmin_nm_excluded = 6*rminArray_excluded;
r_nm = 6*r_array;
r_nm_excluded = 6*r_array_excluded;

xoutline = r_nm.*cos(phi_array);
youtline = r_nm.*sin(phi_array);
xoutline_excluded = r_nm_excluded.*cos(phi_array);
youtline_excluded = r_nm_excluded.*sin(phi_array);

% xmaxOutline = rmax_nm.*cos(phi_array);
% ymaxOutline = rmax_nm.*sin(phi_array);
% xminOutline = rmin_nm.*cos(phi_array);
% yminOutline = rmin_nm.*sin(phi_array);

% phi_array = linspace(0,2*pi,polarSize(1));

% ellipseX = ellipse_fitfcn(phi_array, fitResults.a, fitResults.b, fitResults.rot).*cos(phi_array);
% ellipseY = ellipse_fitfcn(phi_array, fitResults.a, fitResults.b, fitResults.rot).*sin(phi_array);

% ellipse2X = ellipse_fitfcn(phi_array, fitResults.a/2, fitResults.a/2, fitResults.rot).*cos(phi_array);
% ellipse2Y = ellipse_fitfcn(phi_array, fitResults.a/2, fitResults.a/2, fitResults.rot).*sin(phi_array);

xyLims=6*radiusPX*1.5*[-1,1];% + size(autocorrFiltered,2)/2 + [0,1];

% imagesc((R),'parent',goh(2).axes(1));
goh(2).image(1).CData = autocorrFiltered;
goh(2).image(2).CData = autocorrFiltered;
set(goh(2).axes(1),'XLim',xyLims,'YLim',xyLims);
set(goh(2).axes(2),'XLim',xyLims,'YLim',xyLims);

% hold(goh(2).axes(2), 'off');
% imagesc((R),'parent',goh(2).axes(2));

% colorbar(goh(2).axes(1),'Location','southoutside');
% colorbar(goh(2).axes(2),'Location','southoutside');

% hold(goh(2).axes(2), 'on');

set(goh(2).plot(2,2), 'XData', xoutline, 'YData', youtline);
set(goh(2).plot(2,3), 'XData', xoutline_excluded, 'YData', youtline_excluded);
% goh(2).plot(2,2).XData = xoutline;
% goh(2).plot(2,2).YData = youtline;
% goh(2).plot(2,3).XData = xoutline_excluded;
% goh(2).plot(2,3).YData = youtline_excluded;

goh(2).plot(2,2).Marker = '.';
goh(2).plot(2,3).Marker = '.'; 
goh(2).plot(1,1).Marker = '.';

% goh(2).plot(2,2).XData = xmaxOutline;
% goh(2).plot(2,2).YData = ymaxOutline;
% goh(2).plot(2,3).XData = xminOutline;
% goh(2).plot(2,3).YData = yminOutline;

% goh(2).plot(1,2).XData = xoutline;
% goh(2).plot(1,2).YData = youtline;
% goh(2).plot(1,3).XData = xoutline_excluded;
% goh(2).plot(1,3).YData = youtline_excluded;



% goh(2).plot(2,2) = plot(goh(2).axes(2),xoutline, youtline, 'gx', 'MarkerSize',3,'LineWidth',.1);
% goh(2).plot(2,3) = plot(goh(2).axes(2),xoutline_copy, youtline_copy, 'rx', 'MarkerSize',3);
% plot(goh(2).axes(2),ellipseX, ellipseY, 'k--')
% plot(goh(2).axes(2),ellipse2X, ellipse2Y, 'g--')
set(goh(2).axes(2),'XLim',xyLims,'YLim',xyLims);

title(goh(2).axes(3), sprintf('R = %.0f nm,  aspect ratio = %.4f', shape.R*6, shape.aspectRatio));
title(goh(2).axes(2), sprintf('[a, b, rot] = [%.2fpx, %.2fpx, %.2frad]', ...
    shape.a, shape.b, shape.rot));

%%
% 
% sfig = figure(883388); clf
% stl = tiledlayout(sfig, 'flow');
% i=1;   sax(i) = nexttile(stl); simg(i) = imagesc(sax(i), intensity); colorbar(sax(i)); axis(sax(i), 'image'); sax(i).ColorScale = 'log'; sax(i).CLim = [.1, 100];
% i=i+1; sax(i) = nexttile(stl); simg(i) = imagesc(sax(i), autocorr); colorbar(sax(i)); axis(sax(i), 'image'); set(sax(i),'XLim',xyLims,'YLim',xyLims);
% i=i+1; sax(i) = nexttile(stl); simg(i) = imagesc(sax(i), autocorrFiltered); colorbar(sax(i)); axis(sax(i), 'image'); set(sax(i),'XLim',xyLims,'YLim',xyLims);
% figure(goh(2).figure)

%% helper functios

function [array, array_exclude] = exclude_outliers(array, thresh, do_median)
    array_exclude = array;
    if do_median
        diffarray = abs(array - median(array, 'omitnan'));
    else
        diffarray = abs(array - mean(array, 'omitnan'));
    end
    
    if do_min_one_pix_thresholding
        outliers = (thresh*std(array, 'omitnan') < diffarray) & (diffarray > 1);
    else
        outliers = (thresh*std(array, 'omitnan') < diffarray);
    end
    array(outliers) = nan;
    array_exclude(~outliers) = nan;
end

end