function [shape, goodnessOfFit, hAxesFig2] = findShapeFit(img, ...
    radiusPX, varargin)

nPix = 1024;
radiusPX = radiusPX * nPix/1024*2; %because autocorrelation
dilutePX = 20;
diluteThreshold = 0.9;
centerSigma=radiusPX;
radialRange = .5;
rMin = round((1-radialRange)*radiusPX);
rMax = round((1+radialRange)*radiusPX);
angularKernelPX = 100;
radialKernelPX = 3;
nProfiles = 100;
thresh = 1/12;
hAxesFig1 = [];
hAxesFig2 = [];
shape = [];

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'haxesfig1', hAxesFig1 = varargin{ni+1};
            case 'haxesfig2', hAxesFig2 = varargin{ni+1};
        end
    end
end


imgCenter = size(img)/2+1;
img = img( imgCenter(1)-nPix/2:imgCenter(1)+nPix/2-1, ...
    imgCenter(2)-nPix/2:imgCenter(2)+nPix/2-1 );
imgSize = size(img);

[xx,yy] = meshgrid(-imgSize(2)/2:imgSize(2)/2-1,-imgSize(1)/2:imgSize(1)/2-1);

img( xx.^2+yy.^2 > 480.^2) = nan;
% img( xx.^2+yy.^2 <= 60.^2) = nan;

centerFilter = 1 - exp( -(xx.^2+yy.^2)/2/centerSigma^2 );
nanMask = isnan(img);
floatMask = single(~nanMask);
% floatMask = single(repmat(~nanMask(:,513), 1, size(nanMask,2)));
imgshow = img;
imgshow(isnan(imgshow)) = 0;
imgshow(imgshow<.5) = 0;

I = sqrt(imgshow);
diluteMask = single( imgaussfilt( floatMask, dilutePX) > diluteThreshold );
filterMask = imgaussfilt( (diluteMask), dilutePX ) .* diluteMask .* floatMask;
I = I.*filterMask;
R = ift2(I);
R=(R).*centerFilter;

% figure(3446); clf
% mysubplot(2,2,1); imagesc(floatMask);
% mysubplot(2,2,2); imagesc(log10(abs(imgshow)));
% mysubplot(2,2,3); imagesc(diluteMask);
% mysubplot(2,2,4); imagesc(filterMask);

pol = polar_matrix(R,'xcenter', size(img,2)/2+1,'ycenter',size(img,1)/2+1);
pol = pol(:,rMin:rMax);
kernel = repmat(gausswin(size(pol,2))',size(pol,1),1);
% pol = pol.*kernel;

kernel = ones(angularKernelPX, radialKernelPX);
kernel = kernel.*repmat(gausswin(radialKernelPX)', angularKernelPX, 1);
kernel = kernel.*repmat(gausswin(angularKernelPX), 1, radialKernelPX);
fpol = conv2(pol, kernel, 'same');
pol = real(pol);
fpol = real(fpol);
% [~,minpol] = min(pol,[],2);
[~,maxpol] = max(pol,[],2);
% [~,minfpol] = min(fpol,[],2);
[~,maxfpol] = max(fpol,[],2);
maxpol= maxpol+rMin-1;
maxfpol= maxfpol+rMin-1;
% maxpol= (minpol+maxpol)/2+rmin;
% maxfpol= (minfpol+maxfpol)/2+rmin;

% maxpol = nansum(pol./repmat(nansum(pol,2), 1, size(pol,2)).*repmat(rmin:rmax, size(pol,1), 1) ,2);
% maxfpol = nansum(fpol./repmat(nansum(fpol,2), 1, size(fpol,2)).*repmat(rmin:rmax, size(fpol,1), 1) ,2);
% maxpol=maxpol+rmin-1;
% maxfpol=maxfpol+rmin-1;

maxpol_copy = maxpol;
maxfpol_copy = maxfpol;
maxpol(std(maxpol)<abs(maxpol-mean(maxpol))) = nan;
maxfpol(std(maxfpol)<abs(maxfpol-mean(maxfpol))) = nan;
maxpol_copy(std(maxpol_copy)>=abs(maxpol_copy-mean(maxpol_copy))) = nan;
maxfpol_copy(std(maxfpol_copy)>=abs(maxfpol_copy-mean(maxfpol_copy))) = nan;
% figure(23343)
% plot(maxpol)

pol = pol/nanmax(real(pol(:)));
fpol = fpol/nanmax(real(fpol(:)));


dstep = size(fpol,1)/nProfiles;
lprofx = cell2mat(arrayfun(@(i) (rMin:rMax)', 1:nProfiles, 'UniformOutput', false));
lprofy = cell2mat(arrayfun(@(i) dstep*i/size(fpol,1)*360+fpol(round(dstep*i),:)'*10, 1:nProfiles, 'UniformOutput', false));
x = rMin:rMax;

imagesc(hAxesFig1(1),[rMin,rMax],[0,360],pol, [-1,1]);
imagesc(hAxesFig1(2),[rMin,rMax],[0,360],fpol, [-1,1]);
plot(hAxesFig1(3),lprofx,lprofy); 
plot(hAxesFig1(4),maxpol, (1:numel(maxpol))/size(pol,1)*360, maxfpol,(1:numel(maxfpol))/size(fpol,1)*360,...
    x, ones(1,numel(x))*360*thresh, 'g--',...
    x, ones(1,numel(x))*360*(.5-thresh), 'g--',...
    x, ones(1,numel(x))*360*(.5+thresh), 'g--',...
    x, ones(1,numel(x))*360*(1-thresh), 'g--');

title(hAxesFig1(1), 'weighted real part');
title(hAxesFig1(2), 'filtered real part');
title(hAxesFig1(3), 'traces of real part');
title(hAxesFig1(4), 'position of maximum');

% arrayfun(@(i) colorbar(fig1axes(i), 'off'), 1:4);
arrayfun(@(i) xlabel(hAxesFig1(i), 'radius in px'), 1:4);
arrayfun(@(i) ylabel(hAxesFig1(i), 'angle in degree'), 1:4);
% arrayfun(@(i) colormap(fig1axes(i), r2b), 1:2);
arrayfun(@(i) set(hAxesFig1(i),'YDir','normal','YTick',0:30:360,...
    'XLim',[rMin,rMax],'YLim',[0,360],'PlotBoxAspectRatioMode','auto',...
    'DataAspectRatioMode','auto'), 1:4);

th=thresh*size(fpol,1);
todel = round([1:th, size(fpol,1)/2-th:size(fpol,1)/2+th, size(fpol,1)-th:size(fpol,1)]);
phi_array = linspace(0,2*pi,size(fpol,1));
r_array = maxfpol';
r_array_copy = maxfpol_copy';

phi_array(todel) = [];
r_array(todel) = [];
r_array_copy(todel) = [];

xmax = size(img,2)/2+1+r_array.*cos(phi_array);
ymax = size(img,1)/2+1+r_array.*sin(phi_array);
xmax_copy = size(img,2)/2+1+r_array_copy.*cos(phi_array);
ymax_copy = size(img,1)/2+1+r_array_copy.*sin(phi_array);

%% Fitting
ft = fittype('ellipse_fitfcn(x, a, b, rot)');
[fitResults, goodnessOfFit] = fit( phi_array(~isnan(r_array))', ...
    r_array(~isnan(r_array))', ft, 'StartPoint', [radiusPX, radiusPX, 0] );

shape.fitResults = fitResults;
shape.goodnessOfFit = goodnessOfFit;
shape.a = fitResults.a * 1024/nPix;
shape.b = fitResults.b * 1024/nPix;
shape.rot = mod(fitResults.rot+pi, 2*pi) - pi;
shape.R = (fitResults.a+fitResults.b)/2/2;
shape.aspectRatio = iif(fitResults.a>fitResults.b, fitResults.a/fitResults.b, ...
    fitResults.b/fitResults.a);

%% Plotting
phi_array = linspace(0,2*pi,size(fpol,1));

ellipseX = size(img,2)/2+1+ellipse_fitfcn(phi_array, fitResults.a, fitResults.b, fitResults.rot).*cos(phi_array);
ellipseY = size(img,1)/2+1+ellipse_fitfcn(phi_array, fitResults.a, fitResults.b, fitResults.rot).*sin(phi_array);
% ellipse2X = size(img,2)/2+1+ellipse_fitfcn(phi_array, fitResults.a/2, fitResults.a/2, fitResults.rot).*cos(phi_array);
% ellipse2Y = size(img,1)/2+1+ellipse_fitfcn(phi_array, fitResults.a/2, fitResults.a/2, fitResults.rot).*sin(phi_array);

xyLims=radiusPX*1.5*[-1,1] + size(R,2)/2 + [0,1];

imagesc(real(R),'parent',hAxesFig2(1)); 
set(hAxesFig2(1),'XLim',xyLims,'YLim',xyLims);

hold(hAxesFig2(2), 'off'); 
imagesc(real(R),'parent',hAxesFig2(2)); 

colorbar(hAxesFig2(1),'Location','southoutside');
colorbar(hAxesFig2(2),'Location','southoutside');

hold(hAxesFig2(2), 'on');
plot(hAxesFig2(2),xmax, ymax, 'gx', 'MarkerSize',3,'LineWidth',.1);
plot(hAxesFig2(2),xmax_copy, ymax_copy, 'rx', 'MarkerSize',3);
plot(hAxesFig2(2),ellipseX, ellipseY, 'k--')
% plot(hAxesFig2(2),ellipse2X, ellipse2Y, 'g--')
set(hAxesFig2(2),'XLim',xyLims,'YLim',xyLims);

title(hAxesFig2(1), sprintf('[R, ar] = [%.2fpx, %.4f]', shape.R, shape.aspectRatio));
title(hAxesFig2(2), sprintf('[a, b, rot] = [%.2fpx, %.2fpx, %.2frad]', ...
    shape.a, shape.b, shape.rot));
