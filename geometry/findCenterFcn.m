function [center, returnAx, ringplot] = findCenterFcn(img, varargin)
    profile on
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
    %% create graphics objects
    if isempty(hFig)
        hFig = figure(1010102);
    end
    clf(hFig)
    nRows = ceil(nWedges/4)+1;
    nCols = 4;    
    hTL=tiledlayout(hFig,nRows,nCols);
    hAx.center = nexttile(hTL,1,[nRows,nCols-2]);
%         cell2mat(arrayfun(@(i) (i:nCols:nRows*nCols),1:(nCols-2),...
%         'UniformOutput',false)));
    hAx.centerPlot(1) = nexttile(hTL,nCols-1);
    hAx.centerPlot(2) = nexttile(hTL,nCols);
    for w=1:nWedges/2
        hAx.wedge(w) = nexttile(hTL,nCols+ceil(w/2)*(nCols)+mod(w+1,2)-1);
    end
    hPopup = uicontrol('parent', hFig, 'Style','popup','String',...
        {'imorgen','morgenstemning','wjet','parula','jet','hsv','hot',...
        'cool','gray','igray'},'Units','normalized','Position',...
        [.1,.8,.18,.18],'Callback',@setColormap);
    %% centering image    
    hImg=imagesc(log10(abs(img)),'parent',hAx.center);
    hAx.center.XLim=[513-128,513+127];
    hAx.center.XLim=hAx.center.YLim;
    colorbar(hAx.center, 'off');
    hAx.center.CLim(1) = -1; 
    hold(hAx.center, 'on');
    drawnow;
    %% center data plot
    centerArray = nan(nIterations,2);
    hPlt(1) = plot(hAx.centerPlot(1), centerArray(:,1)); 
    hold(hAx.centerPlot(1), 'on');
    hPlt(2) = plot(hAx.centerPlot(1), centerArray(:,2));
    %% old stuff I don't remember what it was doing
    % % % % % % % % % % 
    % 
    % 
    % img(isnan(img)) = 0;
    % ni = 5;
    % smat = zeros(2*ni+1);
    % for xi=-ni:ni
    %     for yi=-ni:ni
    % %         fprintf('[%i,%i]\n',yi,xi)
    %         img_shift = circshift(img, [yi,xi]);
    %         FIMG = fftshift(fft2(fftshift(img_shift)));
    %         smat(yi+ni+1,xi+ni+1) = sum(abs(real(FIMG(:))));
    % %         figure(3535)
    % %         imagesc(log10(abs(FIMG)))
    %         drawnow
    %     end
    % end
    % figure(343566)
    % imagesc(smat)
    % 
    % [~,I] = max(smat(:));
    % [I_row, I_col] = ind2sub(size(smat),I);
    % center = center + [I_col, I_row];
    % ringplot = draw_rings(hAx.center, [center(2),center(1)], 10, ...
    % [50:10:150], 1, 'k');
    % center
    % % % % % % % % % % 
    %% wedges
    wedgeAngles=linspace(-pi,pi,nWedges+1);
    wedge(nWedges).lims = nan(2,1);
    r = (1:min(size(img)))/2;
    for i=1:nIterations
        %% calculate radial profile for each wedge
        [xx,yy]=meshgrid((1:size(img,2))-center(2),(1:(size(img,1)))-center(1));
%         [theta,~] = cart2pol(xx,yy);
        for w=1:nWedges
            try delete(wedge(w).line); end
            wedge(w).lims = ([w-1, w]*2 / nWedges - 1) * pi;
%             wedge(w).mask = (theta>=wedge(w).lims(1) & theta<wedge(w).lims(2))*w;
            wedge(w).mask = atan2(yy,xx) > wedgeAngles(w) & ...
                atan2(yy,xx) <= wedgeAngles(w+1);
%             figure(7834); clf; imagesc(wedge(w).mask); title(w); drawnow
            wedge(w).rprof = nan_rscan(img.*wedge(w).mask, 'rmin', rMin,...
                'rmax', rMax, 'xavg', center(2), 'yavg', center(1));
            wedge(w).rprof = movmean(wedge(w).rprof, movMeanPixel);
%             wedge(w).rprof = conv(wedge(w).rprof(rMin:rMax),...
%                 ones(movMeanPixel,1), 'valid');
    %         wedge(w).rprof(1:end-1) = wedge(w).rprof(2:end) - wedge(w).rprof(1:end-1); 
    %         wedge(w).rprof = wedge(w).rprof(1:end-1);
        end % for w
        %% calculate correlations of opposite wedges
        hold(hAx.centerPlot(2), 'off');
        wedgeCenterArray = nan(w/2,2);
        for w=1:nWedges/2
            w2=w+nWedges/2;           
            wedge(w).xcorr = xcorr(...
                log10(wedge(w).rprof/nanmean(wedge(w).rprof)),...
                log10(wedge(w2).rprof/nanmean(wedge(w2).rprof)));
            hAx.centerPlot(2).XLim(2) = numel(wedge(w).xcorr);

            [~,maxInd] = max(wedge(w).xcorr);
            wedge(w).center_diff = -(maxInd - (numel(wedge(w).xcorr)/2));
            shift = [wedge(w).center_diff*sin(mean(wedge(w).lims)), ...
                wedge(w).center_diff*cos(mean(wedge(w).lims))];
            wedge(w).center = center - nPixShift*shift;
            wedgeCenterArray(w,:) = wedge(w).center;
        end
        TmpWedgeCenterArray = wedgeCenterArray;
        try
            stdarray = [std(wedgeCenterArray(:,1),'omitnan'), std(wedgeCenterArray(:,2),'omitnan')];
            wedgeCenterArray( ((stdarray(:,1)>3) & ( stdarray(:,1) < abs( wedgeCenterArray(:,1)-nanmean(wedgeCenterArray(:,1)) )) ) ,:) = nan;
            wedgeCenterArray( ((stdarray(:,2)>3) & ( stdarray(:,2) < abs( wedgeCenterArray(:,2)-nanmean(wedgeCenterArray(:,2)) )) ) ,:) = nan;
        end
        if isnan(wedgeCenterArray)
            wedgeCenterArray = TmpWedgeCenterArray;
        end
        center = nanmean(wedgeCenterArray,1);
        centerArray(i,:) = center;

        if i==nIterations || displayFlag
            try delete(center_plot); end
            try delete(ringplot.black); end
            try delete(ringplot.red); end
            ringplot.black = draw_rings(hAx.center, [center(2),center(1)], [], 50:20:150, 1, [0,1,1]);
            ringplot.red = draw_rings(hAx.center, [center(2),center(1)], [], 60:20:150, 1, 'g', '--');

            for w=1:nWedges/2
                wedge(w).line = plot(hAx.center, r*sin(wedge(w).lims(1))+center(2), r*cos(wedge(w).lims(1))+center(1), 'b');
                wedge(w2).line = plot(hAx.center, r*sin(wedge(w2).lims(1))+center(2), r*cos(wedge(w2).lims(1))+center(1), 'b');
                try delete(wedge(w).center_plot);end
                hold(hAx.wedge(w), 'off');
                
                wedge(w).xcorr_plot = plot(hAx.centerPlot(2), wedge(w).xcorr); 
                hold(hAx.centerPlot(2), 'on');
                
                wedge(w).cmp_rprof_plot=semilogy(hAx.wedge(w), wedge(w).rprof);
                hold(hAx.wedge(w), 'on'); 
                grid(hAx.wedge(w), 'on');
                wedge(w2).cmp_rprof_plot=semilogy(hAx.wedge(w),wedge(w2).rprof);
                
                wedge(w).center_plot= plot(hAx.center, wedge(w).center(2), wedge(w).center(1),  'o', 'LineWidth', 4);
                axis(hAx.wedge(w), 'tight'); pbaspect(hAx.wedge(w), 'auto');
            end % w=1:nWedges/2

            center_plot = plot(hAx.center, center(2), center(1), 'r+', 'LineWidth', .5, 'MarkerSize', 50);
            hPlt(1).YData = centerArray(:,1);
            hPlt(2).YData = centerArray(:,2);

            title(hAx.centerPlot(1), 'center position'); legend(hAx.centerPlot(1),'center x', 'center y')
            title(hAx.centerPlot(2), 'cross correlation analysis')
            pbaspect(hAx.centerPlot(1), 'auto');
            pbaspect(hAx.centerPlot(2), 'auto');
            legend(hAx.centerPlot(2),arrayfun(@(i) {sprintf('wedge #%i',i)}, 1:w));
    %         arrayfun(@(w) legend(hAx.wedge(w),{sprintf('wedge %i',w),sprintf('wedge %i',w+nwedges/2)}),1:nwedges/2);
            drawnow
        end % if i==nIterations || displayFlag
    end % for i=1:nIterations
    returnAx=hAx.center;
    profile viewer
end
