function cm = b2r(ncols)

if ~exist('ncols','var')
    ncols = 256;
end

cm = r2b(ncols);
cm = cm([end:-1:1],:);