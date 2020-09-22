material(1).name = 'He';
material(1).f1 = 2.013;
material(1).f2 = 0.56e-2;
material(1).massDensity = 145; %kg/m^3
material(1).particleDensity = 2.1837e+28; % 1/m^3 145/(1.66e-27)/4
material(1).inelasticCrossSection = 1.017e-3; %m^2/kg
material(1).cs = 2.2208e+25; %2.1837e+28 * 1.017e-3
material(1).delta = 3.03E-05;
material(1).beta = 8.42E-08;

material(1).scatteringDensity = ...
    sqrt(material(1).f1.^2+material(1).f2.^2)*material(1).particleDensity;


material(2).name = 'Xe';
material(2).f1 = 34.52;
material(2).f2 = 29.56;
material(2).massDensity = 3640; %kg/m^3 solid
material(2).particleDensity = 1.6700e+28; % 1/m^3 3640/(1.66e-27)/131.3
material(2).inelasticCrossSection = 4.417e-4; %m^2/kg
material(2).cs = 7.3764e+24; %1.6700e+28 * 4.417e-4
material(2).delta = 3.97e-4;
material(2).beta = 3.40e-4;

material(2).scatteringDensity = ...
    sqrt(material(2).f1.^2+material(2).f2.^2)*material(2).particleDensity;


material(3).name = 'Ag';
material(3).f1 = 38.9;
material(3).f2 = 18.21;
material(3).massDensity = 10500; %kg/m^3 solid
material(3).particleDensity = 5.8622e+28; % 1/m^3 10500/(1.66e-27)/107.9
material(3).inelasticCrossSection = 4.981e-4; %m^2/kg
material(3).cs = 2.9200e+25; %5.8622e+28 * 4.981e-4
material(3).delta = 1.57e-3;
material(3).beta = 7.36e-4;

material(3).scatteringDensity = ...
    sqrt(material(3).f1.^2+material(3).f2.^2)*material(3).particleDensity;

fprintf('scattering densities:\n He: %.3g\n Xe: %.3g\n Ag: %.3g\n', ...
    material(1).scatteringDensity, material(2).scatteringDensity, ...
    material(3).scatteringDensity)
fprintf('scattering ratios:\n He: %.3g\n Xe: %.3g\n Ag: %.3g\n', 1, ...
    material(2).scatteringDensity/material(1).scatteringDensity, ...
    material(3).scatteringDensity/material(1).scatteringDensity)

