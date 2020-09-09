function obj = setColormaps(obj,~,~)
    obj.int_cm = obj.popupArray(1).String{obj.popupArray(1).Value};
    obj.rec_cm = obj.popupArray(2).String{obj.popupArray(2).Value};

    colormap(obj.axesArray(3), obj.int_cm);
    colormap(obj.axesArray(4), obj.int_cm);
    colormap(obj.axesArray(5), obj.rec_cm);
    colormap(obj.axesArray(6), obj.rec_cm);
end