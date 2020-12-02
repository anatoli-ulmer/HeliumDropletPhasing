function hColorbars = colorbars(hAxes, varargin)

hColorbars = gobjects(1,numel(hAxes));

if nargin<2
    vals = {true};
else
    vals = varargin;
end

for i=1:numel(hAxes)
    if numel(vals)==1
        thisVal = vals{1};
    else
        thisVal = vals{i};
    end
    if ischar(thisVal)
        if strcmp(thisVal, 'on')
            thisVal = true;
        elseif strcmp(thisVal, 'off')
            thisVal = false;
        end
    end
    if thisVal
        hColorbars(i) = colorbar(hAxes(i));
    else
        hColorbars(i) = colorbar(hAxes(i), 'off');
    end
end
