function imgOut = imgBinning(img, binFactor)

binStep = 1/binFactor;
[ny,nx] = size(img);
% imgOut = zeros(binFactor*[ny,nx]);
imgTmp = zeros([binFactor*[ny,nx], binStep, binStep]);

for i=1:binStep
    for j=1:binStep
        imgTmp(:,:,i,j) = img(i:binStep:ny,j:binStep:nx);
%         imgOut = imgOut + img(i:binStep:ny,j:binStep:nx);
    end
end

% imgOut = nanmedian(nanmedian(imgTmp, 4), 3);
imgOut = nanmean(nanmean(imgTmp, 4), 3);
% imgOut = nansum(nansum(imgTmp, 4), 3);