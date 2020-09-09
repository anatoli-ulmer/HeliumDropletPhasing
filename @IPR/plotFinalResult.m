function obj = plotFinalResult(obj, ~,~)
    %             obj.rhoThreshold = 1.1;
    ncols = 256;
    colth = ncols/2*obj.rhoThreshold;
    final.ws = real(obj.ws);
    final.ws = ( (final.ws / max(final.ws(:))*(ncols/2) + ncols/2) .* (obj.ws > (obj.rho*obj.rhoThreshold) ) ) + ...
        ( obj.rho / max(obj.rho(:)) * (ncols/2)  .* (obj.ws <= (obj.rho*obj.rhoThreshold) ) );
    r = real( (obj.ws-obj.rho) .* single(obj.ws > (obj.rho*obj.rhoThreshold) ) );
    g = zeros(size(obj.ws));
    b = real( obj.rho );
    r = uint8(r/max(r(:))*255);
    g = uint8(g);
    b = uint8(b/max(b(:))*255);
    r(~obj.support) = 255;
    g(~obj.support) = 255;
    b(~obj.support) = 255;
    final.rgb = cat(3,r,g,b);

    final.fig = figure(333001); clf
    final.ax(1) = mysubplot(1,2,1);
    final.ax(2) = mysubplot(1,2,2);
    final.img(1) = imagesc((final.ws), 'parent', final.ax(1), 'XData', obj.plt.rec(2).img.XData, 'YData', obj.plt.rec(2).img.YData);
    axis image;

    colormap([bluemap(colth); b2r(ncols-colth)]);
    grid off;
    final.img(2) = image(final.rgb, 'parent', final.ax(2), 'XData', obj.plt.rec(2).img.XData, 'YData', obj.plt.rec(2).img.YData);
    arrayfun(@(a) set(final.ax(a), 'XLim', obj.ax.rec(2).XLim, 'YLim', obj.ax.rec(2).YLim), 1:2);
    drawnow limitrate;
end