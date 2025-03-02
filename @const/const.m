classdef const
    properties (Constant)
        SPEEDOFLIGHT = 299792458; % c [m/s]
        ELECTRONMASS = 9.10938356e-31; % m_e [kg]
        ELECTRONCHARGE = 1.602176634e-19; % e [C]
        ELECTRONRADIUS = 2.81794e-15; % r_e [m]
        AMU = 1.660539e-27; % u [kg]
        PLANCKCONSTANT = 6.62607015e-34; % h [J*s]
        HBAR = 1.054571817e-34; % hbar [J*s]
        BOLTZMANN = 1.38064852e-23; % k_B J/K
        AVOGADRO = 6.02214076e23; % N_A [1/mol]
        GASCONSTANT = 6.02214076e23 * 1.38064852e-23; % R = N_A*k_B [J/K/mol]
        BOHR_RADIUS = 5.291772191260243e-11; % m
        
        c = 299792458; % c [m/s]
        e = 1.602176634e-19; % e [C]
        r_e = 2.81794e-15; % r_e [m]
        u = 1.660539e-27; % u [kg]
        h = 6.62607015e-34; % h [J*s]
        hbar = 1.054571817e-34; % hbar [J*s]
        k = 1.38064852e-23; % k_B J/K
        NAvo = 6.02214076e23; % N_A [1/mol]
        mol = 6.02214076e23; % N_A [1/mol]
        R = 6.02214076e23 * 1.38064852e-23; % R = N_A*k_B [J/K/mol]
        rad = 180/pi;
        vacuum_permittivity = 8.8541878128e-12; % F/m
        vacuum_permeability = 1.25663706212e-6; % N/m^2
        eplsilon_0 = 8.8541878128e-12; % F/m
        mu_0 = 1.25663706212e-6; % N/m^2
        free_space_impedance = 376.730313668; % Ohm
        Z_0 = 376.730313668; % Ohm
        a_0 = 5.291772191260243e-11; % m
        
        mEl = 9.10938356e-31; % m_e [kg]
        mHe = 4.002602 * 1.660539e-27;
        mAr = 39.948 * 1.660539e-27; 
        mAg = 107.8682 * 1.660539e-27; 
        mXe = 131.293 * 1.660539e-27; 
        mCH3I = 141.94 * 1.660539e-27;  % 1 AMU = 1 g/mol !!!
        mCH3CN = 41.05 * 1.660539e-27; 
        mHe_cgs = 0.082512984937649; % = const.mHe/const.hbar^2*const.k*1e-20
        
        % Atomic Scattering Factors at 1keV
        f1He = 2.013;
        f2He = 5.6e-3;
        f0He = 2.013 - 1i*5.6e-3;
        f1Ag = 38.90;
        f2Ag = 18.21;
        f0Ag = 38.90 - 1i*18.21;
        f1Xe = 34.52;
        f2Xe = 29.56;
        f0Xe = 34.52 - 1i*29.56;
        zHe = 2;
        zAg = 47;
        zXe = 54;
        electronScatteringCrossSection = 6.652e-29; % m^2
        atomicScatteringCrossSectionHe = 6.652e-29 * (2.013^2 + 5.6e-3^2); % THIS NEEDS TO BE CHECKED
        atomicScatteringCrossSectionAg = 6.652e-29 * (38.90^2 + 18.21^2); % THIS NEEDS TO BE CHECKED
        atomicScatteringCrossSectionXe = 6.652e-29 * (34.52^2 + 29.56^2); % THIS NEEDS TO BE CHECKED
        thomson_cross_section = 6.652458e-29; % m^2
        sigma_thomson = 6.652458e-29; % m^2

        % liquid He constants
        HeSpeedOfSound = 238.23; % m/s at T = 0.4K     [Donnelly et al., J. Phys. Chem. Ref. Data, Vol. 27, No. 6, 1998]
        rho0 = 145.1; % kg/m^3 mass density at T = 0.4K     [Donnelly et al., J. Phys. Chem. Ref. Data, Vol. 27, No. 6, 1998]
        n_LHe = 2.1831e28; % 1/m^3 particle density at low T    from rho0
        r0 = ( 4/3*pi*2.1831e28 )^(-1/3); % Wigner Seitz radius = 2.22 Angstrom
        r0_angstrom = ( 4/3*pi*2.1831e28 )^(-1/3) * 1e10; % Wigner Seitz radius = 2.22 Angstrom
        surfaceTension_alt = 3.536e-4; % N/m at low T
        surfaceTension = 3.7830e-04; % N/m at low T
        surfaceTension_cgs = 0.274; % Brink, D. M., &#38; Stringari, S. (1990). Density of states and evaporation rate of helium clusters. <i>Zeitschrift Für Physik D Atoms, Molecules and Clusters</i>, <i>15</i>(3), 257–263. https://doi.org/10.1007/BF01437187
        HeSurfaceTension = 3.54e-4; % N/m at low T
        titrationChi = pi/( 3*1.38064852e-23 ) * ( 3/( 4*pi*2.18e28 ) )^(2/3);
        HeCirculation = 6.62607015e-34 / (4.002602 * 1.660539e-27); % m^2/s
        vortexCoreRadius = 1e-10; % m
        vortexCoreRadiusLehmann = 1e-10/sqrt(exp(1)); % m
        
        KtoJ = 1.38066*10^-23;
        K2J = 1.38066*10^-23;
        JtoK = 7.24290*10^22;
        J2K = 7.24290*10^22;
        eV2J = 1.602176634e-19;
        J2eV = 6.2415e+18;
        K2eV = 8.6174e-05;
        eV2K = 1.1604e+04;
        joulePerMol2eV = 1.0364e-05;
        eV2joulePerMol = 9.6485e+04;
        joulePerMol2K = 0.120264;
        K2joulePerMol = 8.314498;

        phi = (1 + sqrt(5))/2;
        goldenRatio = (1 + sqrt(5))/2;

        planckSymbol = "ℏ";
        
        colormaps = {'wjet',...
            'ihesperia','hesperia',...
            'gray','igray',...
            'b2r','r2b',...
            'ibentcoolwarm','bentcoolwarm',...
            'imorgen', 'morgenstemning',...
            'ismoothcoolwarm','smoothcoolwarm',...
            'icoolwarm','coolwarm',...
            'redmap','bluemap',...
            'parula','jet','hsv','hot','cool',...
            'b2r2','r2b2',...
            'redmap2','bluemap2',...
            'hslcolormap'}
        printRes = 300 % dpi
        figureWidth = 13 % cm
    end
end

% classdef const
%     properties (Constant)
%         SPEEDOFLIGHT = 299792458; % c [m/s]
%         ELECTRONMASS = 9.10938356e-31; % m_e [kg]
%         ELECTRONCHARGE = 1.602176634e-19; % e [C]
%         AMU = 1.660539e-27; % u [kg]
%         PLANCKCONSTANT = 6.62607015e-34; % h [J*s]
%         HBAR = 1.054571817e-34; % hbar [J*s]
%         BOLTZMANN = 1.38064852e-23; % k_B J/K
%         AVOGADRO = 6.02214076e23; % N_A [1/mol]
%         GASCONSTANT = 6.02214076e23 * 1.38064852e-23; % R = N_A*k_B [J/K/mol]
%         
%         c = 299792458; % c [m/s]
%         e = 1.602176634e-19; % e [C]
%         u = 1.660539e-27; % u [kg]
%         h = 6.62607015e-34; % h [J*s]
%         hbar = 1.054571817e-34; % hbar [J*s]
%         k = 1.38064852e-23; % k_B J/K
%         NAvo = 6.02214076e23; % N_A [1/mol]
%         mol = 6.02214076e23; % N_A [1/mol]
%         R = 6.02214076e23 * 1.38064852e-23; % R = N_A*k_B [J/K/mol]
%         rad = 180/pi;
%         
%         mEl = 9.10938356e-31; % m_e [kg]
%         mHe = 4.002602 * 1.660539e-27;
%         mAr = 39.948 * 1.660539e-27; 
%         mAg = 107.8682 * 1.660539e-27; 
%         mXe = 131.293 * 1.660539e-27; 
%         mCH3I = 141.94 * 1.660539e-27;  % 1 AMU = 1 g/mol !!!
%         mCH3CN = 41.05 * 1.660539e-27; 
%         
%         % Atomic Scattering Factors at 1keV
%         f1He = 2.013;
%         f2He = 5.6e-3;
%         f0He = 2.013 - 1i*5.6e-3;
%         f1Ag = 38.90;
%         f2Ag = 18.21;
%         f0Ag = 38.90 - 1i*18.21;
%         f1Xe = 34.52;
%         f2Xe = 29.56;
%         f0Xe = 34.52 - 1i*29.56;
%         zHe = 2;
%         zAg = 47;
%         zXe = 54;
%         electronScatteringCrossSection = 6.652e-29; % m^2
%         atomicScatteringCrossSectionHe = 6.652e-29 * (2.013^2 + 5.6e-3^2);
%         atomicScatteringCrossSectionAg = 6.652e-29 * (38.90^2 + 18.21);
%         atomicScatteringCrossSectionXe = 6.652e-29 * (34.52^2 + 29.56);
%         
%         % liquid He constants
%         HeSpeedOfSound = 238; % m/s at low T
%         n_LHe = 2.18e28; % 1/m^3 particle density at low T
%         rho0 = 145; % kg/m^3 mass density at low T
%         r0 = ( 4/3*pi*2.18e28 )^(-1/3); % Wigner Seitz radius = 0.222 Angstrom
%         surfaceTension = 3.54e-4; % N/m at low T
%         HeSurfaceTension = 3.54e-4; % N/m at low T
%         titrationChi = pi/( 3*1.38064852e-23 ) * ( 3/( 4*pi*2.18e28 ) )^(2/3);
%         HeCirculation = 6.62607015e-34 / (4.002602 * 1.660539e-27); % m^2/s
%         vortexCoreRadius = 1e-10; % m
%         
%         KtoJ = 1.38066*10^-23;
%         JtoK = 7.24290*10^22;
%         phi = (1 + sqrt(5))/2;
%         goldenRatio = (1 + sqrt(5))/2;
%         
%         colormaps = {'wjet',...
%             'ihesperia','hesperia',...
%             'gray','igray',...
%             'b2r','r2b',...
%             'ibentcoolwarm','bentcoolwarm',...
%             'imorgen', 'morgenstemning',...
%             'ismoothcoolwarm','smoothcoolwarm',...
%             'icoolwarm','coolwarm',...
%             'redmap','bluemap',...
%             'parula','jet','hsv','hot','cool',...
%             'b2r2','r2b2',...
%             'redmap2','bluemap2',...
%             'hslcolormap'}
%         printRes = 300 % dpi
%         figureWidth = 13 % cm
%     end
% end
