function ax = mysubplot(nrows, ncols, idx, varargin)

ax = axes(varargin{:}, 'OuterPosition', [(mod(idx-1,ncols))/ncols, 1-ceil(idx/ncols)/nrows, 1/ncols, 1/nrows]);
% fprintf('subplot(%i,%i,%i, position [%.02f,%02f,%02f,%02f]\n', nrows,ncols,idx, (mod(idx-1,ncols))/ncols, 1-ceil(idx/ncols)/nrows, 1/ncols, 1/nrows)
