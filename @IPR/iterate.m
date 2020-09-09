function obj = iterate(obj, nSteps, method)
    obj.errors(:,1) = calcError(obj.ws, obj.rho, obj.support0, obj.AMP, obj.AMP0, obj.MASK);
    obj.errors = [obj.errors, nan(size(obj.errors,1), nSteps, 'single', 'gpuArray')];
    
    for i=1:nSteps
        obj.W = ft2(obj.w);

        if obj.masking.constraint_RMask
            obj.W = obj.W .* obj.RMASK_smooth;
        end

        obj.AMP = abs(obj.W);
        obj.PHASE = angle(obj.W);

        obj.WS = projectorModulus(obj.AMP, obj.AMP0, obj.PHASE, obj.MASK);
        obj.ws = ift2(obj.WS);
        
%         fprintf('real space integral: %.3g, Reciprocal space integral: %.3g\nmask sum %.3g\n',...
%             sum(abs(obj.ws(:)).^2), sum(abs(obj.WS(:)).^2),sum(obj.MASK(:)));
        obj = applyConstraints(obj, method);

        obj.errors(:,obj.nTotal+1) = ...
            calcError(obj.ws, obj.rho, obj.support0, obj.AMP, obj.AMP0, obj.MASK);

        if mod(obj.nTotal, obj.nStepsUpdatePlot) == 0
            obj.plotAll;
        end
        obj.nTotal = obj.nTotal+1;
    end
end