function refineDetectorGeometry(data, simu, shiftUH, ...
    shiftLH, shiftSimu)
	
    if ~exist('shiftUH', 'var'), shiftUH = [0,0]; % [X,Y] !!!
	elseif isempty('shiftUH'), shiftUH = [0,0]; % [X,Y] !!!
    end    
    if ~exist('shiftLH', 'var'), shiftLH = [0,0]; % [X,Y] !!!
	elseif isempty('shiftLH'), shiftLH = [0,0]; % [X,Y] !!!
    end
    if ~exist('shiftSimu', 'var'), shiftSimu = [0,0]; % [X,Y] !!!
    elseif isempty('shiftSimu'), shiftSimu = [0,0]; % [X,Y] !!!
    end
    addImages=false;

	data = sqrt(data.*(data>=0));
	simu = sqrt(simu);
   
    dataUH = data;
	dataUH(1:512,:) = 0;
    dataLH = data;
    dataLH(513:1024,:) = 0;

    hFigure = figure(4359);
    hAxesArray(1) = subplot(3,3,1,'Parent',hFigure);
    hImg(1) = imagesc(nan(size(data)),'Parent',hAxesArray(1));
    hAxesArray(2) = subplot(3,3,4,'Parent',hFigure);
    hImg(2) = imagesc(nan(size(data)),'Parent',hAxesArray(2));
    hAxesArray(3) = subplot(3,3,7,'Parent',hFigure);
    hImg(3) = imagesc(nan(size(data)),'Parent',hAxesArray(3));
    hAxesArray(4) = subplot(3,3,[2,3,5,6,8,9],'Parent',hFigure);
    hImg(4) = imagesc(nan(size(data)),'Parent',hAxesArray(4));
    
    hAxesArray(1).Tag = 'axesUH';
    hAxesArray(2).Tag = 'axesLH';
    hAxesArray(3).Tag = 'axesSimu';
    hAxesArray(4).Tag = 'axesOverlap';

    translateImages(dataUH,dataLH,simu,...
        shiftUH,shiftLH,shiftSimu);

    function translateImages(dataUH,dataLH,simu,...
            shiftUH,shiftLH,shiftSimu)
        upperMask=~isnan(dataUH);
        lowerMask=~isnan(dataLH);
        dataUH(~upperMask)=0;
        dataLH(~lowerMask)=0;
        upperMask = imtranslate(upperMask,shiftUH,...
            "bilinear","FillValues",0);
	    lowerMask = imtranslate(lowerMask,shiftLH,...
            "bilinear","FillValues",0);
	    shiftedDataUH = imtranslate(dataUH,shiftUH,...
            "bilinear","FillValues",0);
	    shiftedDataLH = imtranslate(dataLH,shiftLH,...
            "bilinear","FillValues",0);
	    shiftedSimu = imtranslate(simu,shiftSimu,...
            "bilinear","FillValues",0);

	    dataMask = upperMask>0 & lowerMask>0;
%         figure(34545); imagesc(dataMask);
% 	    shiftedDataUH(~dataMask) = 0;
% 	    shiftedDataLH(~dataMask) = 0;
	    shiftedData = shiftedDataUH + shiftedDataLH;
		shiftedSimu = shiftedSimu/norm(shiftedSimu(dataMask),'fro')...
            *norm(shiftedData(dataMask),'fro');
        if addImages
            overlapImg = shiftedData + shiftedSimu;%.*~dataMask;
        else
            overlapImg = shiftedData + shiftedSimu.*~dataMask;
        end
        
	    [hImg.CData] = deal(...
            log10(shiftedDataUH),...
            log10(shiftedDataLH),...
            log10(shiftedSimu),...
            log10(overlapImg)...
            );
        arrayfun(@(i) set(hAxesArray(i),'CLim',[-1,2]), 1:4);
	    fprintf(['\nupper half shifted by: [%.1f, %.1f]\n'...
            'lower half shifted by: [%.1f, %.1f]\n'...
            'simulated shifted by: [%.1f, %.1f]\n'],...
	    	shiftUH(1),shiftUH(2),shiftLH(1),...
            shiftLH(2),shiftSimu(1),shiftSimu(2))
	end % translateImages

	hFigure.KeyReleaseFcn = @translateAndUpdate;

    function translateAndUpdate(~,evt)
		switch evt.Key
			case 'uparrow', newShift = [0,1];
			case 'downarrow', newShift = [0,-1];
			case 'leftarrow', newShift = [-1,0];
			case 'rightarrow', newShift = [1,0];
            case 'a'
                newShift = [0,0];
                addImages=~addImages;
			otherwise, return;
        end
		switch hFigure.CurrentAxes.Tag
			case 'axesUH'
				shiftUH = shiftUH+newShift;
			case 'axesLH'
				shiftLH = shiftLH+newShift;
			case 'axesSimu'
				shiftSimu = shiftSimu+newShift;
            case 'axesOverlap'
                if hAxesArray(4).CurrentPoint(1,2)>512
                    shiftUH = shiftUH+newShift;
                else
                    shiftLH = shiftLH+newShift;
                end
			otherwise, return;
		end
		translateImages(dataUH,dataLH,simu,shiftUH,shiftLH,shiftSimu);
	end % translateAndUpdate
end % refineDetectorGeometry