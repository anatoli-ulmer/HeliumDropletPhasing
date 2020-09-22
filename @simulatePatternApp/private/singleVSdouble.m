function [scene1, scene2, scatt1, scatt2] = singleVSdouble(dropletRadius, dopantRadius, dopantPosition, scatteringPowerRatio, density)
    if exist('density', 'var')
        scene = density;
    else
        scene = zeros(1024);
        scene = scene + sphereProjection(dropletRadius);
    end
    scene1 = scene ...
        + (scatteringPowerRatio-1)*sphereProjection(dopantRadius, dopantPosition);
    scene2 = scene ...
        + (scatteringPowerRatio-1)*sphereProjection(dopantRadius, dopantPosition) ...
        + (scatteringPowerRatio-1)*sphereProjection(dopantRadius, -dopantPosition);
    scatt1 = abs(ft2(scene1)).^2;
    scatt2 = abs(ft2(scene2)).^2;
end
