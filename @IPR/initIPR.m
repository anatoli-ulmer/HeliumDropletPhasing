function obj = initIPR(obj, pnCCDimg)

	fprintf('\n\nInitializing phasing ...\n')
    
    obj.SCATT = (single(pnCCDimg));
    obj.resizeData();
%     obj.initGPU()
    obj.initMask();
    
    obj.initPlots();
    obj.resetIPR();

    fprintf('\t... done.\n')
end