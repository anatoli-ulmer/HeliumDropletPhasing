function [noise, noiseMatrix, NOISEMatrix] = calcNoise(AMP0, MASK, ...
    binFactor, noiseConstraints)

plotNoise = 0;
% AMP0 = AMP0.*binFactor;

if noiseConstraints.manualNoise
    noise = noiseConstraints.manualNoise;
    NOISEMatrix = noise*ones(size(AMP0));
%     noise = rms(NOISEMatrix(:));
    noiseMatrix = nan;
    return
end
if ~noiseConstraints.radAvg
    NOISEMatrix = AMP0;
    if noiseConstraints.zeroPointFive, NOISEMatrix(NOISEMatrix>sqrt(0.2)) = 0.5; end
    noise = rms(NOISEMatrix(MASK>0));
    noiseMatrix = nan;
%     NOISEMatrix = nan;
    return
end
    
    AMP0(~MASK) = nan;    
    imgSize = size(AMP0);
    imgCenter = imgSize/2+1;
    [radialAMP, ~] = rmean(AMP0, ceil(sqrt(2)*max(imgSize)/2+1));


    [xx, yy] = meshgrid( (1:imgSize(2))-imgCenter(2), (1:imgSize(1))-imgCenter(1));
    radialM = round(sqrt(xx.^2+yy.^2)+.5);
    radialM(radialM==0) = 1;
    avgAMP = radialAMP(radialM);

%     INT0 = AMP0.^2;
%     NOISEMatrix = 0.5*ones(imgSize);
%     NOISEMatrix(INT0<0.2) = avgAMP(INT0<0.2);
% % 
    NOISEMatrix = avgAMP;
    if noiseConstraints.zeroPointFive, NOISEMatrix(NOISEMatrix>sqrt(0.2)) = 0.5; end
    if noiseConstraints.maskedOnly, NOISEMatrix(~MASK) = nan; end

    noise = rms(NOISEMatrix(~isnan(NOISEMatrix)));
%     noise = .5;

    if plotNoise
        figure(88334); imagesc(NOISEMatrix);
        fprintf('\tnoise level = %.3g\n', noise)
    end
end

