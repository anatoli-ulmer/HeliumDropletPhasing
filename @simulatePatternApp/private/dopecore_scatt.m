function [simData, simParameter] = dopecore_scatt(simData, simParameter)

    simParameter.aspectRatioCore = simParameter.aCore/simParameter.bCore;
    simParameter.aspectRatioDrop = simParameter.aCore/simParameter.bDrop;
    simParameter.posCore1 = [simParameter.y1, simParameter.x1]/6 + simParameter.center;
    simParameter.posCore2 = [simParameter.y2, simParameter.x2]/6 + simParameter.center;

    % 1 pixel = 6nm
    % subfunctions work with pixels, so the calculation is done beforehand
    
    aDrop = simParameter.aDrop / 6;
    bDrop = simParameter.bDrop / 6;
    aCore = simParameter.aCore / 6;
    bCore = simParameter.bCore / 6;
    rotationDrop = simParameter.rotationDrop;
    rotationCore = simParameter.rotationCore;
    posCore1 = simParameter.posCore1;
    posCore2 = simParameter.posCore2;
    ratio = simParameter.ratio;
    center = simParameter.center;
    nPixel = simParameter.nPixel;


    % Calculate real space densities
    simData.droplet = ellipsoid_density(aDrop, bDrop, [], rotationDrop, center, nPixel);
    simData.core1 = ellipsoid_density(aCore, bCore, [], rotationCore, posCore1, nPixel);
    simData.core2 = ellipsoid_density(aCore, bCore, [], rotationCore, posCore2, nPixel);

    simData.scene1 = simData.droplet + (ratio-1)*simData.core1;
    simData.scene2 = simData.scene1 + (ratio-1)*simData.core2;

    simData.scatt1 = abs(ft2(simData.scene1)).^2;
    simData.scatt2 = abs(ft2(simData.scene2)).^2;

    
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    THIS NEEDS TO BE PROPERLY CONVERTED! SWITCHED FROM PIXEL TO NM AND
%%    DID NOT CORRECT THIS PART YET. 

    % dropletVol = sum(simData.droplet(:));
    % coreVol = (ratio-1)*sum(simData.core1(:));
    % cCore = (aCore+bCore)/2;
    % coreVolCalc = 4/3*pi*aCore*bCore*cCore*6^3; % nm^3
    % densRatioXe = 131.3*1.66e-27 * simParameter.nDopants / coreVolCalc * (1e9)^3 / 3640;
    % densRatioAg = 107.9*1.66e-27 * simParameter.nDopants / coreVolCalc * (1e9)^3 / 10500;
    %
    % fprintf('Calculated particle density ratio: %.1f%% (Xe) // %.1f%% (Ag)\n', densRatioXe*100, densRatioAg*100)
    %
    % particleDensityHe = 2.1837e+28;
    % particleDensityXe = 1.6700e+28;
    % particleDensityAg = 5.8622e+28;
    % fHe = 2.01;
    % fXe = 45.45;
    % fAg = 42.95;
    %
    % switch simParameter.dopant
    %     case 'Xe'
    %         f = 45.45;
    %     case 'Ag'
    %         f = 42.95;
    % end
    %
    % CalcPartDensXe = particleDensityHe * fHe/fXe * dropletVol/coreVol * simParameter.nDopants/simParameter.nDroplet;
    % CalcPartDensAg = particleDensityHe * fHe/fAg * dropletVol/coreVol * simParameter.nDopants/simParameter.nDroplet;
    %
    % % fprintf('Calculated particle density ratio: %.1e (Xe) // %.1e (Ag)\n', CalcPartDensXe/particleDensityXe, CalcPartDensAg/particleDensityAg)
    %
    % simData.droplet = simParameter.nDroplet * simData.droplet / norm(simData.droplet, 'fro');
    % simData.core1 = simParameter.nDopants*(simParameter.ratio-1) * simData.core1 / norm(simData.core1, 'fro');
    % simData.core2 = simParameter.nDopants*(simParameter.ratio-1) * simData.core2 / norm(simData.core2, 'fro');
    %
    % simData.droplet = simParameter.nDroplet * simData.droplet / norm(simData.droplet, 'fro');
    % simData.core1 = simParameter.nDopants*(simParameter.ratio-1) * simData.core1 / norm(simData.core1, 'fro');
    % simData.core2 = simParameter.nDopants*(simParameter.ratio-1) * simData.core2 / norm(simData.core2, 'fro');
    %
    % simData.scene1 = simData.droplet + simData.core1;
    % simData.scene2 = simData.scene1 + simData.core2;
    %
    % simData.scatt1 = abs(fftshift(fft2(fftshift(simData.scene1)))).^2;
    % simData.scatt2 = abs(fftshift(fft2(fftshift(simData.scene2)))).^2;

end