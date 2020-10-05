function g = igray(m)

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

g = (0:m-1)'/max(m-1,1);
g = g(end:-1:1);
g = [g g g];