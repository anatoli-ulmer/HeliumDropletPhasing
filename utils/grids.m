function grids(hAxes, varargin)

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
        grid(hAxes(i), 'on');
    else
        grid(hAxes(i), 'off');
    end
end
