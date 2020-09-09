function saveImgRealResolution(img, savename, cmap, makeAxes)

save_fig = figure('Units', 'inches',...
    'Position', [1,1,size(img,2)/size(img,1)*3,3],...
    'PaperUnits', 'inches', 'PaperSize', [size(img,2)/size(img,1)*3,3],...
    'PaperPosition', [0,0,size(img,2)/size(img,1)*3,3]);
save_ax = axes('Units', 'normalized', 'Position', [0,0,1,1]);
save_plt = imagesc(img); %#ok<NASGU>
colormap(save_ax, cmap); 

if makeAxes
    colorbar(save_ax);
else
    colorbar(save_ax, 'off');
    set(save_ax,'visible', 'off')
end
drawnow;
print(save_fig, savename, sprintf('-r%i', size(img,1)), '-dpng')
close(save_fig)