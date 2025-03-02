function obj = reconIterate(obj, nSteps, method)
    % preallocating space for error metrics
    obj.errors=[obj.errors,nan(size(obj.errors,1),nSteps,'like',obj.errors)];
    
    for i=1:nSteps
        obj.W = ft2(obj.w);

        if obj.masking.constraint_RMask
            if obj.masking.constraint_RMaskSmoothing
                obj.W = obj.W .* obj.RMASK_smooth;
            else
                obj.W = obj.W .* obj.RMASK;
            end
        end
        
        if obj.masking.constraint_taper
            obj.W = obj.W .* obj.masking.taper.mask;
        end

        obj.AMP = abs(obj.W);
        obj.PHASE = angle(obj.W);
    
%         % normalize
%         if obj.constraints.normalizeRhoEachStep
%             norm0 = norm(obj.AMP0.*obj.MASK, 'fro');
%             norm1 = norm(obj.AMP.*obj.MASK, 'fro');
%             alpha = norm0/norm1;
%             obj.rho = obj.rho*alpha;
%             obj.AMP = obj.AMP*alpha;
%             %         disp(obj.alpha)
% %         obj.rho = obj.rho/norm(obj.AMP.*obj.MASK, 'fro');
% %         obj.rho = obj.rho*norm(obj.AMP0.*obj.MASK, 'fro');
% %         obj.AMP = obj.AMP/norm(obj.AMP.*obj.MASK, 'fro');
% %         obj.AMP = obj.AMP*norm(obj.AMP0.*obj.MASK, 'fro');
%         end

        obj.WS = projectorModulus(obj.AMP, obj.AMP0, obj.PHASE, obj.MASK);
        obj.ws = ift2(obj.WS);
        
        obj = reconApplyConstraints(obj, method);

        obj.calcError();
        
        if mod(obj.nTotal, obj.nStepsUpdatePlot) == 0
            obj.updateGUI;
        end
        obj.nTotal = obj.nTotal+1;
    end
end
