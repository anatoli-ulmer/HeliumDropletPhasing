function [center, returnAx, ringplot] = findCenterFcn(img, varargin)
warning('off','all')
% profile on
%% default parameter
nWedges = 8;
nPixShift = 1;
nIterations = 5;
rMin = 70;
rMax = 200;
center = size(img)/2;
movMeanPixel = 1;
displayFlag = 0;
hFig=[];
hAx=[];
%% input parser
if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'figure', hFig = varargin{ni+1};
            case 'center', center = varargin{ni+1};
            case 'nwedges', nWedges = varargin{ni+1};
            case 'npixshift', nPixShift = varargin{ni+1};
            case 'niterations', nIterations = varargin{ni+1};
            case 'rmin', rMin = varargin{ni+1};
            case 'rmax', rMax = varargin{ni+1};
            case 'movmeanpixel', movMeanPixel = varargin{ni+1};
            case 'displayflag', displayFlag = varargin{ni+1};
        end
    end
end
%% create gui objects
if isempty(hFig)
    hFig = figure(1010102);
end
clf(hFig)
nRows = ceil(nWedges/4)+1;
nCols = 4;
hTL=tiledlayout(hFig,nRows,nCols);
hAx.center = nexttile(hTL,1,[nRows,nCols-2]);
hAx.centerPlt = nexttile(hTL,nCols-1);
hAx.xcorrPlt = nexttile(hTL,nCols);
for w=1:nWedges/2
    hAx.wedge(w) = nexttile(hTL,nCols+ceil(w/2)*(nCols)+mod(w+1,2)-1);
end
hPopup = uicontrol('parent', hFig, 'Style','popup','String',...
    {'imorgen','morgenstemning','wjet','parula','jet','hsv','hot',...
    'cool','gray','igray'},'Units','normalized','Position',...
    [.1,.8,.18,.18],'Callback',@setColormap); %#ok<NASGU>
%% draw centering image
hImg=imagesc(log10(abs(img)),'parent',hAx.center); %#ok<NASGU>
hAx.center.XLim=[513-128,513+127];
hAx.center.YLim=hAx.center.XLim;
colorbar(hAx.center, 'off');
hAx.center.CLim(1) = -1;
hold(hAx.center, 'on');
%% wedges
wedgeAngles=linspace(-pi,pi,nWedges+1);
wedge(nWedges).lims = nan(2,1);
wedge(nWedges).line=[];
wedge(nWedges).xcorrPlt=[];
wedge(nWedges).cmpRProfPlt=[];
wedge(nWedges).centerPlt=[];

r = (1:min(size(img)))/2;
centerArray=nan(nIterations,2);
centerCrossPlt=[];
centerPosPltX=[];
centerPosPltY=[];

ringplot.black=gobjects(1);
ringplot.red=gobjects(1);

for i=1:nIterations
    %% calculate radial profile for each wedge
    [xx,yy]=meshgrid((1:size(img,2))-center(2),(1:(size(img,1)))-center(1));
    for w=1:nWedges
%         wedge(w).lims = ([w-1, w]*2 / nWedges - 1) * pi;
        wedge(w).lims = wedgeAngles([w,w+1]);
        wedgeMask = atan2(yy,xx) > wedgeAngles(w) & ...
            atan2(yy,xx) <= wedgeAngles(w+1);
        wedge(w).rprof = nan_rscan(img.*wedgeMask, 'rmin', rMin,...
            'rmax', rMax, 'xavg', center(2), 'yavg', center(1));
        %         wedge(w).rprof = rmean(img.*wedgeMask,rMax,center);
        %         wedge(w).rprof = movmean(wedge(w).rprof, movMeanPixel);
        wedge(w).rprof = conv(wedge(w).rprof(rMin:rMax),...
            ones(movMeanPixel,1), 'valid');
        %             wedge(w).rprof(1:end-1) = wedge(w).rprof(2:end) - ...
        %             wedge(w).rprof(1:end-1);
        %             wedge(w).rprof = wedge(w).rprof(1:end-1);
    end % for w
    %% calculate correlations of opposite wedges
    wedgeCenterArray = nan(w/2,2);
    for w=1:nWedges/2
        w2=w+nWedges/2;
        wedge(w).xcorr = xcorr(...
            (abs(wedge(w).rprof)),.../nanmean(wedge(w).rprof))),...
            (abs(wedge(w2).rprof)));%/nanmean(wedge(w2).rprof))));        
        [~,maxInd] = max(wedge(w).xcorr);
        wedge(w).center_diff = -(maxInd - (numel(wedge(w).xcorr)/2));
        shift = [wedge(w).center_diff*sin(mean(wedge(w).lims)), ...
            wedge(w).center_diff*cos(mean(wedge(w).lims))];
        wedge(w).center = center - nPixShift*shift;
        wedgeCenterArray(w,:) = wedge(w).center;
    end
    TmpWedgeCenterArray = wedgeCenterArray;
    try %#ok<TRYNC>
        stdArray = [std(wedgeCenterArray(:,1),'omitnan'), ...
            std(wedgeCenterArray(:,2),'omitnan')];
        wedgeCenterArray( ((stdArray(:,1)>3) & ( stdArray(:,1) < abs( ...
            wedgeCenterArray(:,1)-nanmean(wedgeCenterArray(:,1)) )) ...
            ) ,:) = nan;
        wedgeCenterArray( ((stdArray(:,2)>3) & ( stdArray(:,2) < abs( ...
            wedgeCenterArray(:,2)-nanmean(wedgeCenterArray(:,2)) )) ...
            ) ,:) = nan;
    end
    if isnan(wedgeCenterArray)
        wedgeCenterArray = TmpWedgeCenterArray;
    end
    center = nanmean(wedgeCenterArray,1);
    centerArray(i,:) = center;
    %% plotting
    if i==nIterations || displayFlag
        delete(ringplot.black);
        delete(ringplot.red);
        ringplot.black = draw_rings(hAx.center, center, ...
            [], 50:20:150, 1, [0,1,1]);
        ringplot.red = draw_rings(hAx.center, center, ...
            [], 60:20:150, 1, 'g', '--');
        for w=1:nWedges/2
            w2=w+nWedges/2;
            if ~isempty(wedge(w).line)
                wedge(w).line.XData=r*sin(wedge(w).lims(1))+center(2);
                wedge(w).line.YData=r*cos(wedge(w).lims(1))+center(1);
                wedge(w2).line.XData=r*sin(wedge(w2).lims(1))+center(2);
                wedge(w2).line.YData=r*cos(wedge(w2).lims(1))+center(1);
            else
                wedge(w).line = plot(hAx.center, ...
                    r*sin(wedge(w).lims(1))+center(2), ...
                    r*cos(wedge(w).lims(1))+center(1), 'k');
                wedge(w2).line = plot(hAx.center, ...
                    r*sin(wedge(w2).lims(1))+center(2), ...
                    r*cos(wedge(w2).lims(1))+center(1), 'k');
            end
            if ~isempty(wedge(w).xcorrPlt)
                wedge(w).xcorrPlt.YData=wedge(w).xcorr;
            else
                wedge(w).xcorrPlt = plot(hAx.xcorrPlt,wedge(w).xcorr);
                title(hAx.xcorrPlt, 'cross correlation analysis')
                hold(hAx.xcorrPlt, 'on');
                pbaspect(hAx.xcorrPlt,'auto');
                hAx.xcorrPlt.XLim(2) = numel(wedge(w).xcorr);
%                 legend(hAx.xcorrPlt,arrayfun(@(i) ...
%                     {sprintf('wedge #%i',i)},1:nWedges));
            end
            if ~isempty(wedge(w).cmpRProfPlt)
                wedge(w).cmpRProfPlt.YData=wedge(w).rprof;
                wedge(w2).cmpRProfPlt.YData=wedge(w2).rprof;
            else
                wedge(w).cmpRProfPlt=semilogy(hAx.wedge(w),wedge(w).rprof);
                hold(hAx.wedge(w), 'on');
                grid(hAx.wedge(w), 'on');
                wedge(w2).cmpRProfPlt=semilogy(hAx.wedge(w),wedge(w2).rprof);
            end
            if ~isempty(wedge(w).centerPlt)
                wedge(w).centerPlt.XData=wedge(w).center(2);
                wedge(w).centerPlt.YData=wedge(w).center(1);
            else
                wedge(w).centerPlt = plot(hAx.center,wedge(w).center(2),...
                    wedge(w).center(1),  'o', 'LineWidth', 4);
                axis(hAx.wedge(w), 'tight'); pbaspect(hAx.wedge(w),'auto');
            end %
        end % for w=1:nWedges/2
        if ~isempty(centerCrossPlt)
            centerCrossPlt.XData=center(2);
            centerCrossPlt.YData=center(1);
        else
            centerCrossPlt = plot(hAx.center, center(2), center(1), 'r+', ...
                'LineWidth', .5, 'MarkerSize', 50);
        end
        if ~isempty(centerPosPltX)
            centerPosPltY.YData = centerArray(:,1);
            centerPosPltX.YData = centerArray(:,2);
        else
            centerPosPltY = plot(hAx.centerPlt, centerArray(:,1));
            hold(hAx.centerPlt, 'on');
            centerPosPltX = plot(hAx.centerPlt, centerArray(:,2));
            hold(hAx.centerPlt, 'off');
            pbaspect(hAx.centerPlt,'auto');
            title(hAx.centerPlt, 'center position');
            legend(hAx.centerPlt,'center x', 'center y')
        end
        drawnow;
    end % if i==nIterations || displayFlag
end % for i=1:nIterations
returnAx=hAx.center;
% profile viewer
warning('on','all')
end
