function ytight(ax)
  % Set axis tight only on y-axes
  yl=ax.YLim; % retrieve auto y-limits
  axis tight   % set tight range
  ylim(ax,yl)  % restore y limits 
end
