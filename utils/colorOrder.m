function out = colorOrder(varargin)

co = get(gca, 'ColorOrder');

if nargin<1
    n = mod(length(get(gca, 'Children')), size(co, 1) + 1);
else
    n = varargin{:};
end

out = co(n,:);
