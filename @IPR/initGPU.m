function obj = initGPU(obj)
    % switch to GPU if available
    obj.gpuAvailable = gpuDeviceCount;
    if obj.gpuAvailable
        fprintf('%i GPU devices found. Initiating data on GPU...', obj.gpuAvailable)
        
        %% uncategorized variables
        gpuVarArray={'support0','rho0','errors','subscale',...
            'support_dilateFactor','overSamplingRatio','beta0','beta',...
            'support_radius','alpha','delta','deltaFactor','phaseMin',...
            'center','imgsize',...
            'nStepsUpdatePlot','simScene'};
        for i=1:numel(gpuVarArray)
            obj.(gpuVarArray{i}) = ...
                gpuArray(obj.(gpuVarArray{i}));
        end
        
        %% masking variables
        gpuMaskingVarArray={'RMASK_smoothPix'};
        for i=1:numel(gpuMaskingVarArray)
            obj.masking.(gpuMaskingVarArray{i}) = ...
                gpuArray(obj.masking.(gpuMaskingVarArray{i}));
        end
        
        %% initialize variables 
%         gpuMaskingVarArray={'RMASK_smoothPix'};
%         for i=1:numel(gpuMaskingVarArray)
%             obj.masking.(gpuMaskingVarArray{i}) = ...
%                 gpuArray(obj.masking.(gpuMaskingVarArray{i}));
%         end
        
        %% image
        obj.pnCCDimg = gpuArray(single(obj.pnCCDimg));
        fprintf(' done!\n')
    else
        fprintf('No available GPU device found.\n')
    end
end
