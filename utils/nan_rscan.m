function [rdat, rpos] = nan_rscan(img,varargin)

% RDAT = RSCAN(M0,VARARGIN)
% Get radial scan of a matrix using the following procedure:
% [1] Get coordinates of a circle around an origin.
% [2] Average values of points where the circle passes through.
% [3] Change radius of the circle and repeat [1] until rprofile is obtained.
%
% For DEMO, run
% >> rscan_qavg();
% or
% >> rscan_qavg('demo','dispflag',0);
% >> plot(ans);
% or
% >> rdat = rscan_qavg();
% >> plot(rdat);
% or
% >> a = peaks(300);
% >> rscan_qavg(a);
% >> rscan_qavg(a,'rlim',50,'xavg',100);
% >> rscan_qavg(a,'rlim',25,'xavg',100,'dispflag',1,'dispflagc',1);
% >> rscan_qavg(a,'rlim',25,'xavg',100,'dispflag',1,'dispflagc',1, ...
%    'squeezx',0.7,'rot',pi/4);
%
% Draw Circle:
% [ref] http://www.mathworks.com/matlabcentral/fileexchange/
%       loadFile.do?objectId=2876&objectType=file

centerx = size(img,2)/2;
centery = size(img,1)/2;
rmax = floor(min(size(img))/2)-1;
rmin = 1;
dispFlag = 0;
dispFlagC = 0;
rot = 0; %% radian
squeezx = 1; %% 0.80;
squeezy = 1;
rstep = 1;

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'xavg', centerx = varargin{ni+1};
            case 'yavg', centery = varargin{ni+1};
            case 'squeezx', squeezx = varargin{ni+1};
            case 'squeezy', squeezy = varargin{ni+1};
            case 'rot', rot = varargin{ni+1};
            case 'rlim', rmax = varargin{ni+1};
            case 'rmax', rmax = varargin{ni+1};
            case 'rmin', rmin = varargin{ni+1};
            case 'dispflag', dispFlag = varargin{ni+1};
            case 'dispflagc', dispFlagC = varargin{ni+1};
            case 'rstep', rstep = varargin{ni+1};
        end
    end
end


img_size = size(img);
rdmax = floor(min( abs(img_size - [centerx, centery]) ))-1;
if rmax > rdmax, rmax = rdmax; end
rarray = rmin:rstep:floor(rmax);
rpos = rarray - rstep/2;

for r_idx = rarray
    NOP = round(2*pi*r_idx);
    THETA=linspace(0,2*pi,NOP);
    RHO=ones(1,NOP)*round(r_idx);
    [X,Y] = pol2cart(THETA,RHO);
    X = squeezx*X;
    Y = squeezy*Y;
    [THETA,RHO] = cart2pol(X,Y);
    [X,Y] = pol2cart(THETA+rot,RHO);
    X = X + centerx;
    Y = Y + centery;
    
    if dispFlag
        h1 = figure(100);clf;box on;
        imagesc(img);axis image;hold on; colormap fire;
        % H = plot(X,Y,'c-');
        line([centerx centerx],[1 img_size(1)],'color',[1 1 0],'linewidth',1);
        line([1 img_size(2)],[centery centery],'color',[1 1 0],'linewidth',1);
    end
    
    %%%
    X = round(X);
    Y = round(Y);
    %%%
    
%     clear dat uxy pxy mxy mx nx my ny;
    dat = [X;Y];
    uxy = diff(dat,1,2);
    uxy = [[1;1],uxy];
    pxy = union(find(uxy(1,:)~=0),find(uxy(2,:)~=0));
    dat = dat(:,pxy);
    
    img_cut=img(img_size(1)*(dat(1,:)-1) + dat(2,:));
%     figure(234234)
%     imagesc(img_cut)
    rdat(r_idx) = nanmean(img_cut);
    
    if dispFlag
        H = plot(dat(1,:),dat(2,:),'y-');
        if dispFlagC
            for nrn = 1:length(dat)
                H = plot(dat(1,nrn),dat(2,nrn),'m.','MarkerSize',12);
                drawnow;
                delete(H);
            end
        end
        drawnow;
    end
end

% rdat = rdat/max(rdat);
% xcoord = dat(1,:);
% ycoord = dat(2,:);

if dispFlag
    h2 = figure(101); clf; hold on;
    subplot(121); plot(rdat);axis tight; title('linear');
    subplot(122); plot(log(rdat));axis tight; title('logarithmic');
end



