function obj = addReconPlan(obj, method, nSteps, nLoops)
    obj.reconPlan = [obj.reconPlan; {method,nSteps,nLoops}];
    fprintf(['added %d loop(s) with %d step(s) using method ''%s'' ',...
        'to reconstruction plan\n'],nLoops,nSteps,method);
end