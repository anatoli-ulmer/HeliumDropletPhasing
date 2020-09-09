function obj = resetIPR(obj)

    obj.AMP = obj.AMP0;
    obj.beta = obj.beta0;

    obj = initPhase(obj);
    obj.nTotal = 1;
    obj.errors = nan(size(obj.errors,1),1,'like', obj.errors);
    obj.reconPlan = {};
end