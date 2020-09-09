function obj = setPlotParts(obj,~,~)
    obj.intpart = obj.popupArray(5).Value;
    obj.reconpart = obj.popupArray(6).String{obj.popupArray(6).Value};
    obj.plotAll;
end