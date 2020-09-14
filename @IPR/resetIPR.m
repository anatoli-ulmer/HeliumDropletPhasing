function obj = resetIPR(obj,varargin)
    if mod(numel(varargin),2)~=0
        error('Optional arguments must come in name-value-pairs.')
    end    
    for i=1:2:numel(varargin)
        obj.(varargin{i})=varargin{i+1};
    end
    
    TMP0 = obj.SCATT;
    TMP0(~obj.MASK) = 0;
    
    TMP0 = (single(sqrt(complex(TMP0))));
    obj.AMP0 = abs(TMP0);
    obj.PHASE = angle(TMP0);
    
    obj.overSamplingRatio = calcOverSamplingRatio(obj.MASK, obj.support0);
    [obj.noise, obj.noiseMatrix, obj.NOISEMatrix] = calcNoise(obj.AMP0);

    obj.beta = obj.beta0;
    obj.support = obj.support0;
    obj.nTotal = 1;
    obj.errors = nan(size(obj.errors,1),1,'like', obj.errors);
    obj.reconPlan = {};
    
    obj.initPhase();
    obj.plotAll();
end