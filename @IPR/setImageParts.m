function obj = setImageParts(obj,~,~,noUpdate)
    obj.intpart = uint8(obj.go.popup(5).Value);
    obj.reconpart = obj.go.popup(6).String{obj.go.popup(6).Value};
    if ~exist('noUpdate', 'var')
        obj.updateGUI();
    elseif ~noUpdate
        obj.updateGUI();
    end
end
