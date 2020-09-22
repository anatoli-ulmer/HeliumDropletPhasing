function obj = initIPR(obj, pnCCDimg)

	fprintf('\n\nInitializing phasing ...\n')
    
    if isempty(obj.dropletOutline)
        obj.dropletOutline.x=nan(1,100);
        obj.dropletOutline.y=nan(1,100);
    end
    obj.SCATT = (single(pnCCDimg));
    obj.resizeData();
%     obj.initGPU()
    obj.initMask();
    
    obj.initGUI();
    obj.resetIPR();

    fprintf('\t... done.\n')
end
