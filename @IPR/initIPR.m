function obj = initIPR(obj, pnCCDimg)

	fprintf('\n\nInitializing phasing ...\n')

    obj.SCATT = (single(pnCCDimg));
    obj.resizeData();
%     obj.initGPU()
    obj.initMask();
    obj.SCATT(~obj.MASK) = 0;
    
    TMP0 = (single(sqrt(complex(obj.SCATT))));
    obj.AMP0 = abs(TMP0);
    obj.PHASE = angle(TMP0);
    
    obj.overSamplingRatio = calcOverSamplingRatio(obj.MASK, obj.support);
    [obj.noise, obj.noiseMatrix, obj.NOISEMatrix] = calcNoise(obj.AMP0);
    
    obj.resetIPR();
    obj.initPlots();
    obj.plotAll();

    fprintf('\t... done.\n')
end