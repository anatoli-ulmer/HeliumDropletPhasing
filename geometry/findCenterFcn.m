function [center, centerax, ringplot] = findCenterFcn(img, varargin)

nwedges = 8;
shiftstrength = 1;
nIter = 5;
rmin = 70;
rmax = 200;
center = size(img)/2;
movmeanpix = 1;
dispflag = 0;
fig = [];

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'center', center = varargin{ni+1};
            case 'nwedges', nwedges = varargin{ni+1};
            case 'shiftstrength', shiftstrength = varargin{ni+1};
            case 'niter', nIter = varargin{ni+1};
            case 'rmin', rmin = varargin{ni+1};
            case 'rmax', rmax = varargin{ni+1};
            case 'movmeanpix', movmeanpix = varargin{ni+1};
            case 'dispflag', dispflag = varargin{ni+1};
            case 'figure', fig = varargin{ni+1};
        end
    end
end

if isempty(fig)
    fig = figure(3001);
end
clf(fig)
nrows = ceil(nwedges/4)+1;
ncols = 4;
centerax = subplot(nrows,ncols,cell2mat(arrayfun(@(i) [i:ncols:nrows*ncols], 1:(ncols-2), 'UniformOutput',false)), 'parent', fig);
ax(3) = subplot(nrows,ncols,ncols-1, 'parent', fig);
ax(4) = subplot(nrows,ncols,ncols, 'parent', fig);
for w=1:nwedges/2
    wedge(w).cmp_ax = subplot(nrows,ncols,ncols+ceil(w/2)*(ncols)+mod(w+1,2)-1, 'parent', fig); %#ok<AGROW>
end

% popup = 
uicontrol('parent', fig, 'Style', 'popup', 'String', ...
                    {'imorgen', 'morgenstemning', 'wjet', 'parula','jet','hsv','hot','cool','gray','igray'},...
                    'Units', 'normalized', 'Position', [.1,.8,.18,.18], 'Callback', @setColormap);

% img_plot = 
imagesc(log10(abs(img)), 'parent', centerax); axis(centerax, 'equal');
zoom(centerax, 4); colorbar(centerax, 'off'); centerax.CLim(1) = -1; hold(centerax, 'on');
colormap(centerax, imorgen);

center_iter = nan(nIter,2);
center_iterplot(1) = plot(ax(3), center_iter(:,1)); hold(ax(3), 'on');
center_iterplot(2) = plot(ax(3), center_iter(:,2));

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
% ringplot = draw_rings(centerax, [center(2),center(1)], 10, [50:10:150], 1, 'k');
% center
% % % % % % % % % % 

for i=1:nIter
    [xx, yy] = meshgrid((1:size(img,2))-center(2), (1:(size(img,1)))-center(1));
    [theta,~] = cart2pol(xx,yy);
    r = (1:min(size(img)))/2;
    
    for w=1:nwedges
        try delete(wedge(w).line); end
        wedge(w).lims = ([w-1, w]*2 / nwedges - 1) * pi;
        wedge(w).mask = (theta>=wedge(w).lims(1) & theta<wedge(w).lims(2))*w;
%         figure(7834); clf
%         imagesc(wedge(w).mask);
%         title(w)
%         drawnow
        wedge(w).rprof = nan_rscan(img.*wedge(w).mask, 'rmin', rmin, 'rmax', rmax, 'xavg', center(2), 'yavg', center(1));
%         wedge(w).rprof = movmean(wedge(w).rprof, movmeanpix);
        wedge(w).rprof = conv(wedge(w).rprof(rmin:rmax), ones(movmeanpix,1), 'valid');
%         wedge(w).rprof(1:end-1) = wedge(w).rprof(2:end) - wedge(w).rprof(1:end-1); 
%         wedge(w).rprof = wedge(w).rprof(1:end-1);
    end
    
    hold(ax(4), 'off');
    center_array = nan(w/2,2);
    for w=1:nwedges/2
%         wedge(w).xcorr = xcorr((wedge(w).rprof/nanmean(wedge(w).rprof)),(wedge(w+nwedges/2).rprof/nanmean(wedge(w+nwedges/2).rprof)));
wedge(w).xcorr = xcorr(log10(wedge(w).rprof/nanmean(wedge(w).rprof)),log10(wedge(w+nwedges/2).rprof/nanmean(wedge(w+nwedges/2).rprof)));
        ax(4).XLim(2) = numel(wedge(w).xcorr);
        
        [~,mind] = max(wedge(w).xcorr);
        wedge(w).center_diff = -(mind - (numel(wedge(w).xcorr)/2));
        shift = [wedge(w).center_diff*sin(mean(wedge(w).lims)), wedge(w).center_diff*cos(mean(wedge(w).lims))];
        %         shift = sign(shift).*min(abs(shift),3);
        wedge(w).center = center - shiftstrength*shift;
        center_array(w,:) = wedge(w).center;
    end
    center_array_tmp = center_array;
    try
        stdarray = [std(center_array(:,1),'omitnan'), std(center_array(:,2),'omitnan')];
        center_array( ((stdarray(:,1)>3) & ( stdarray(:,1) < abs( center_array(:,1)-nanmean(center_array(:,1)) )) ) ,:) = nan;
        center_array( ((stdarray(:,2)>3) & ( stdarray(:,2) < abs( center_array(:,2)-nanmean(center_array(:,2)) )) ) ,:) = nan;
    end
    if isnan(center_array)
        center_array = center_array_tmp;
    end
    center = nanmean(center_array,1);
    center_iter(i,:) = center;
    
    if i==nIter || dispflag
        try delete(center_plot); end
        try delete(ringplot.black); end
        try delete(ringplot.red); end
        ringplot.black = draw_rings(centerax, [center(2),center(1)], [], 50:20:150, 1, [0,1,1]);
        ringplot.red = draw_rings(centerax, [center(2),center(1)], [], 60:20:150, 1, 'g', '--');
        
        for w=1:nwedges/2
            wedge(w).line = plot(centerax, r*sin(wedge(w).lims(1))+center(2), r*cos(wedge(w).lims(1))+center(1), 'b');
            wedge(w+nwedges/2).line = plot(centerax, r*sin(wedge(w+nwedges/2).lims(1))+center(2), r*cos(wedge(w+nwedges/2).lims(1))+center(1), 'b');
            try delete(wedge(w).center_plot);end
            hold(wedge(w).cmp_ax, 'off');
            wedge(w).xcorr_plot = plot(ax(4), wedge(w).xcorr); hold(ax(4), 'on');
            wedge(w).cmp_rprof_plot = semilogy(wedge(w).cmp_ax, wedge(w).rprof); hold(wedge(w).cmp_ax, 'on'); grid(wedge(w).cmp_ax, 'on')
            wedge(w+nwedges/2).cmp_rprof_plot = semilogy(wedge(w).cmp_ax, wedge(w+nwedges/2).rprof);
            wedge(w).center_plot = plot(centerax, wedge(w).center(2), wedge(w).center(1),  'o', 'LineWidth', 4);
            axis(wedge(w).cmp_ax, 'tight'); pbaspect(wedge(w).cmp_ax, 'auto');
        end
        
        center_plot = plot(centerax, center(2), center(1), 'r+', 'LineWidth', .5, 'MarkerSize', 50);
        center_iterplot(1).YData = center_iter(:,1);
        center_iterplot(2).YData = center_iter(:,2);
        
        title(ax(3), 'center position'); legend(ax(3),'center x', 'center y')
        title(ax(4), 'cross correlation analysis')
        pbaspect(ax(3), 'auto');
        pbaspect(ax(4), 'auto');
        legend(ax(4),arrayfun(@(i) {sprintf('wedge #%i',i)}, 1:w));
%         arrayfun(@(w) legend(wedge(w).cmp_ax,{sprintf('wedge %i',w),sprintf('wedge %i',w+nwedges/2)}),1:nwedges/2);
        drawnow
    end
end
end
