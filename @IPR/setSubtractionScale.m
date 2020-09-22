function obj = setSubtractionScale(obj,~,~)
    obj.subscale = str2num_fast(obj.editArray(3).String);
    obj.substract_shape = obj.cBoxArray(1).Value;
    obj.normalize_shape = obj.cBoxArray(2).Value;
    obj.updateGUI;
end
