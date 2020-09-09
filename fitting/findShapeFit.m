function [f, ax2] = findShapeFit(img,rpix,varargin)

rpix = rpix*2; %because autocorrelation
dpix = 15;
dth = 0.99;
sigma=rpix;
rrange = .5;
rmin = round((1-rrange)*rpix);
rmax = round((1+rrange)*rpix);
kang = 100;
krad = 3;
nprofs = 100;
thresh = 1/12;
fig1 = [];
fig2 = [];
ax2 = [];

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'fig1', fig1 = varargin{ni+1};
            case 'fig2', fig2 = varargin{ni+1};
            case 'ax', ax2 = varargin{ni+1};
        end
    end
end

[xx,yy] = meshgrid((1:size(img,2))-size(img,2)/2,(1:size(img,1))-size(img,1)/2);

GAUSSMASK = 1-exp(-(xx.^2+yy.^2)/2/sigma^2);
MASK = single(~isnan(img));
imgshow = img;
imgshow(isnan(imgshow)) = 0;
imgshow(imgshow<.5) = 0;

I = sqrt(imgshow);
DILUTEMASK = single(imgaussfilt((MASK),dpix)>dth);
MASK = imgaussfilt((DILUTEMASK),dpix) .* MASK;
I = I.*MASK;
R = fftshift(ifft2(ifftshift(I)));
R=(R).*GAUSSMASK;


pol = polar_matrix(R,'xcenter', size(img,2)/2+1,'ycenter',size(img,1)/2+1);
pol = pol(:,rmin:rmax);
kernel = repmat(gausswin(size(pol,2))',size(pol,1),1);
pol = pol.*kernel;

kernel = ones(kang, krad);
kernel = kernel.*repmat(gausswin(krad)', kang, 1);
kernel = kernel.*repmat(gausswin(kang), 1, krad);
fpol = conv2(pol, kernel, 'same');
pol = real(pol);
fpol = real(fpol);
% [~,minpol] = min(pol,[],2);
[~,maxpol] = max(pol,[],2);
% [~,minfpol] = min(fpol,[],2);
[~,maxfpol] = max(fpol,[],2);
maxpol= maxpol+rmin-1;
maxfpol= maxfpol+rmin-1;
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

pol = pol/nanmax(abs(pol(:)));
fpol = fpol/nanmax(abs(fpol(:)));


dstep = size(fpol,1)/nprofs;
lprofx = cell2mat(arrayfun(@(i) (rmin:rmax)', 1:nprofs, 'UniformOutput', false));
lprofy = cell2mat(arrayfun(@(i) dstep*i/size(fpol,1)*360+fpol(round(dstep*i),:)'*10, 1:nprofs, 'UniformOutput', false));
x = rmin:rmax;

if isempty(fig1)
    fig1 = figure(6868686); clf
end
clf(fig1)
sub(1) = subplot(1,4,1,'parent',fig1); 
plt(1)=imagesc(pol,'YData',[0,360],'XData',[rmin,rmax],'parent',sub(1), [-1,1]);

sub(2) = subplot(1,4,2,'parent',fig1); 
plt(2)=imagesc(fpol,'YData',[0,360],'XData',[rmin,rmax],'parent',sub(2), [-1,1]);

sub(3) = subplot(1,4,3,'parent',fig1); 
plot(sub(3),lprofx,lprofy); 

sub(4) = subplot(1,4,4,'parent',fig1); 
plot(sub(4),maxpol, (1:numel(maxpol))/size(pol,1)*360, maxfpol,(1:numel(maxfpol))/size(fpol,1)*360,...
    x, ones(1,numel(x))*360*thresh, 'g--',...
    x, ones(1,numel(x))*360*(.5-thresh), 'g--',...
    x, ones(1,numel(x))*360*(.5+thresh), 'g--',...
    x, ones(1,numel(x))*360*(1-thresh), 'g--');

title(sub(1), 'weighted real part');
title(sub(2), 'filtered real part');
title(sub(3), 'traces of real part');
title(sub(4), 'position of maximum');

arrayfun(@(i) colorbar(sub(i), 'off'), 1:4);
arrayfun(@(i) xlabel(sub(i), 'radius in px'), 1:4);
arrayfun(@(i) ylabel(sub(i), 'angle in degree'), 1:4);
arrayfun(@(i) colormap(sub(i), r2b), 1:2);
arrayfun(@(i) set(sub(i),'YDir','normal','YTick',0:30:360,...
    'XLim',[rmin,rmax],'YLim',[0,360],'PlotBoxAspectRatioMode','auto',...
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

ft = fittype('ellipse_fitfcn(x, a, b, rot)');
f = fit( phi_array(~isnan(r_array))',r_array(~isnan(r_array))', ft, 'StartPoint', [rpix, rpix, 0] );

warning('off','curvefit:cfit:subsasgn:coeffsClearingConfBounds');
f.rot = mod(f.rot, 2*pi);
warning('on','curvefit:cfit:subsasgn:coeffsClearingConfBounds');

phi_array = linspace(0,2*pi,size(fpol,1));

if isempty(fig2)
    fig2 = figure(8686868);
end
clf(fig2)
ax1=mysubplot(1,2,1,'parent',fig2);
if isempty(ax2); ax2=mysubplot(1,2,2,'parent',fig2); end
if ~isvalid(ax2); ax2=mysubplot(1,2,2,'parent',fig2); end

xell = size(img,2)/2+1+ellipse_fitfcn(phi_array, f.a, f.b, f.rot).*cos(phi_array);
yell = size(img,1)/2+1+ellipse_fitfcn(phi_array, f.a, f.b, f.rot).*sin(phi_array);
xell2 = size(img,2)/2+1+ellipse_fitfcn(phi_array, f.a/2, f.a/2, f.rot).*cos(phi_array);
yell2 = size(img,1)/2+1+ellipse_fitfcn(phi_array, f.a/2, f.a/2, f.rot).*sin(phi_array);

imagesc(real(R),'parent',ax1); colormap(ax1,r2b); hold(ax1, 'on'); zoom(ax1, 5);
imagesc(real(R),'parent',ax2); colormap(ax2,r2b); hold(ax2, 'on'); zoom(ax2, 5);
set(ax1, 'XLim', size(R,2)/2+rpix*2*[-1,1], 'YLim', size(R,1)/2+rpix*2*[-1,1])
set(ax2, 'XLim', size(R,2)/2+rpix*2*[-1,1], 'YLim', size(R,1)/2+rpix*2*[-1,1])
plot(ax2,xmax, ymax, 'kx', 'MarkerSize',3,'LineWidth',.1);
plot(ax2,xmax_copy, ymax_copy, 'rx', 'MarkerSize',2);
plot(ax2,xell, yell, 'g--')
plot(ax2,xell2, yell2, 'g--')
