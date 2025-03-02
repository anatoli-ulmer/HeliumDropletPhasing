function obj = setScaleErrorPlot(obj,src,~)
    switch src.Value
        case 1
        case 2
%             set(obj.go.axes(1),'XScale','linear','YScale','linear');
            set(obj.go.axes(2),'XScale','linear','YScale','linear');
        case 3
%             set(obj.go.axes(1),'XScale','log','YScale','linear');
            set(obj.go.axes(2),'XScale','log','YScale','linear');
        case 4
%             set(obj.go.axes(1),'XScale','linear','YScale','log');
            set(obj.go.axes(2),'XScale','linear','YScale','log');
        case 5
%             set(obj.go.axes(1),'XScale','log','YScale','log');
            set(obj.go.axes(2),'XScale','log','YScale','log');
    end
end
