function obj = initGPU(obj)
    %% switch to GPU if available
    obj.gpuAvailable = gpuDeviceCount;
    if obj.gpuAvailable
        fprintf('%i GPU devices found. Initiating data on GPU...', obj.gpuAvailable)

        %% uncategorized variables
        gpuVariables = {'support0','rho0','errors','subscale',...
            'support_dilateFactor','overSamplingRatio','beta0','beta',...
            'support_radius','alpha','delta','deltaFactor','phaseMin',...
            'center','imgsize',...
            'nStepsUpdatePlot','simScene'};
        for i=1:numel(gpuVariables)
            obj.(gpuVariables{i}) = ...
                gpuArray(obj.(gpuVariables{i}));
        end
        
        %% masking variables
        gpuMaskingVariables={'RMASK_smoothPix'};
        for i=1:numel(gpuMaskingVariables)
            obj.masking.(gpuMaskingVariables{i}) = ...
                gpuArray(obj.masking.(gpuMaskingVariables{i}));
        end
        
        %% initialize variables 
%         gpuMaskingVariables={'RMASK_smoothPix'};
%         for i=1:numel(gpuMaskingVariables)
%             obj.masking.(gpuMaskingVariables{i}) = ...
%                 gpuArray(obj.masking.(gpuMaskingVariables{i}));
%         end
        
        %% image
        obj.pnCCDimg = gpuArray(single(obj.pnCCDimg));
        fprintf(' done!\n')
    else
        fprintf('No available GPU device found.\n')
    end
end
