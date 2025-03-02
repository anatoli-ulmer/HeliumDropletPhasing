function obj = resetIPR(obj,varargin)
    if mod(numel(varargin),2)~=0
        error('Optional arguments must come in name-value-pairs.')
    end    
    for i=1:2:numel(varargin)
        obj.(varargin{i}) = varargin{i+1};
    end
    
    SCATT = obj.SCATT;
    SCATT(~obj.MASK) = 0;
    
%     negVals = SCATT<0;
    AMP0 = (single(sqrt(complex(abs(SCATT)))));
%     AMP0(negVals) = -AMP0(negVals);
    obj.masking.taper.mask = zeros(size(AMP0), 'like', AMP0);
    
    if obj.masking.constraint_taper
        obj.masking.taper.size = double(ceil(obj.masking.taper.size * obj.binFactor * obj.padFactor));
        obj.masking.taper.sigma = double(ceil(obj.masking.taper.sigma * obj.binFactor * obj.padFactor));
%         obj.masking.taper.PSF = fspecial(obj.masking.taper.method, obj.masking.taper.size, obj.masking.taper.sigma);
        obj.masking.taper.mask([1:obj.masking.taper.size, end-obj.masking.taper.size+1:end],:) = 1;
        obj.masking.taper.mask(:,[1:obj.masking.taper.size, end-obj.masking.taper.size+1:end]) = 1;
        obj.masking.taper.mask = imgaussfilt(obj.masking.taper.mask, obj.masking.taper.sigma);
        obj.masking.taper.mask = 1- obj.masking.taper.mask;
        
        AMP0 = AMP0.*obj.masking.taper.mask;
        AMP0 = single(AMP0);
        
        if obj.gpuAvailable
            obj.masking.taper.mask = gpuArray(obj.masking.taper.mask);
        end
    end
%     m = (obj.masking.taper.mask<0.5) | ~obj.MASK;
%     disp(sum(m(:))/numel(obj.MASK))
%     disp(sum(~obj.MASK(:))/numel(obj.MASK))
    
    obj.AMP0 = abs(AMP0);
    obj.PHASE = angle(AMP0);
    
    obj.overSamplingRatio = calcOverSamplingRatio(obj.MASK, obj.support0, obj.masking.constraint_RMask, obj.RMASK);
    obj.noise = calcNoise(obj.AMP0, obj.MASK, ...
        obj.binFactor, obj.constraints.noise);
% % %     obj.noise = sqrt(mean(abs(obj.SCATT(robj.MASK>0))));
%     obj.noise = rms(obj.AMP0(obj.MASK>0));
% % %     [obj.noise, obj.noiseMatrix, obj.NOISEMatrix] = calcNoise(obj.SCATT.*obj.MASK);

    obj.beta = obj.beta0;
    obj.support = obj.support0;
    obj.nTotal = 1;
    obj.errors = nan(size(obj.errors,1),1,'like', obj.errors);
    obj.reconPlan = {};
    
    obj.initPhase();
    obj.updateGUI();
end
