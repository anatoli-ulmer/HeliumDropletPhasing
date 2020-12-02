function obj = setIPRColormaps(obj,~,~)
    obj.int_cm = obj.go.popup(1).String{obj.go.popup(1).Value};
    obj.rec_cm = obj.go.popup(2).String{obj.go.popup(2).Value};

    colormap(obj.go.axes(3), obj.int_cm);
    colormap(obj.go.axes(4), obj.int_cm);
    colormap(obj.go.axes(5), obj.rec_cm);
    colormap(obj.go.axes(6), obj.rec_cm);
end
