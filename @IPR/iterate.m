function obj = iterate(obj, nSteps, method)
    % preallocating space for error metrics
    obj.errors=[obj.errors,nan(size(obj.errors,1),nSteps,'single','gpuArray')];
    
    for i=1:nSteps
        obj.W = ft2(obj.w);

        if obj.masking.constraint_RMask
            obj.W = obj.W .* obj.RMASK_smooth;
        end

        obj.AMP = abs(obj.W);
        obj.PHASE = angle(obj.W);

        obj.WS = projectorModulus(obj.AMP, obj.AMP0, obj.PHASE, obj.MASK);
        obj.ws = ift2(obj.WS);
        
        obj = applyConstraints(obj, method);

        obj.errors(:,obj.nTotal) = ...
            calcError(obj.ws, obj.rho, obj.support, obj.AMP, obj.AMP0, obj.MASK);

        if mod(obj.nTotal, obj.nStepsUpdatePlot) == 0
            obj.plotAll;
        end
        obj.nTotal = obj.nTotal+1;
    end
end