function obj = resetIPR(obj)

    obj.configIPR();
    obj.AMP = obj.AMP0;
    obj.beta = obj.beta0;
    
    obj.initPhase();
    obj.nTotal = 1;
    obj.errors = nan(size(obj.errors,1),1,'like', obj.errors);
%     obj.errors(:,1) = calcError(obj.ws, obj.rho, obj.support0, obj.AMP, obj.AMP0, obj.MASK);
    obj.reconPlan = {};
end