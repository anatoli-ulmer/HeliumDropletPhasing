function obj = setSubtractionScale(obj,~,~,noUpdate)
    obj.subscale = str2double(obj.go.edit(3).String);
    obj.substract_shape = obj.go.checkbox(1).Value;
    if ~exist('noUpdate', 'var')
        obj.updateGUI();
    elseif ~noUpdate
        obj.updateGUI();
    end
end
