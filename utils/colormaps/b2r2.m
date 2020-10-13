function cm = b2r2(m)

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cm = r2b2(m);
cm = cm([end:-1:1],:);
