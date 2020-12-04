function [noise, noiseMatrix, NOISEMatrix] = calcNoise(AMP0)

    NOISEMatrix = nan;
    noiseMatrix = nan;
    
    noise = nanmean(sqrt(AMP0(:)));


% %     NOISEMatrix = AMP0.*(AMP0<=0.2) + 0.5*single(AMP0>0.2);
% %     noiseMatrix = ift2(NOISEMatrix);
% %     
% %     % works only for symmetrized ft2/ift2 functions
% %     noise = rms(noiseMatrix(:));
    


% %     % calculate rms noise in Fourier space and translate it to real space
% %     % by deviding through number of elements (see MATLAB fft definition)
% %     noise = rms(NOISEMatrix(:))/numel(NOISEMatrix);
    
    fprintf('\tnoise level = %.3g\n', noise)
end
