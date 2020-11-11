classdef const
    properties (Constant)
        SPEEDOFLIGHT = 299792458; % c [m/s]
        ELECTRONMASS = 9.10938356e-31; % m_e [kg]
        ELECTRONCHARGE = 1.602176634e-19; % e [C]
        AMU = 1.660539e-27; % u [kg]
        PLANCKCONSTANT = 6.62607015e-34; % h [J*s]
        HBAR = 1.054571817e-34; % hbar [J*s]
        BOLTZMANN = 1.38064852e-23; % k_B J/K
        AVOGADRO = 6.02214076e23; % N_A [1/mol]
        GASCONSTANT = 6.02214076e23 * 1.38064852e-23; % R = N_A*k_B [J/K/mol]
        
        c = 299792458; % c [m/s]
        e = 1.602176634e-19; % e [C]
        u = 1.660539e-27; % u [kg]
        h = 6.62607015e-34; % h [J*s]
        hbar = 1.054571817e-34; % hbar [J*s]
        k = 1.38064852e-23; % k_B J/K
        NAvo = 6.02214076e23; % N_A [1/mol]
        mol = 6.02214076e23; % N_A [1/mol]
        R = 6.02214076e23 * 1.38064852e-23; % R = N_A*k_B [J/K/mol]
        
        mEl = 9.10938356e-31; % m_e [kg]
        mHe = 4.002602 * 1.660539e-27;
        mAr = 39.948 * 1.660539e-27; 
        mAg = 107.8682 * 1.660539e-27; 
        mXe = 131.293 * 1.660539e-27; 
        mCH3I = 141.94 * 1.660539e-27;  % 1 AMU = 1 g/mol !!!
        mCH3CN = 41.05 * 1.660539e-27; 
        n_LHe = 2.18e28; % 1/m^3 liquid He density (superfluid !?)
        rho0 = 145; % kg/m^3
        r0 = ( 4/3*pi*2.18e28 )^(-1/3); % Wigner Seitz radius = 0.222 Angstrom
        titrationChi = pi/( 3*1.38064852e-23 ) * ( 3/( 4*pi*2.18e28 ) )^(2/3);
        
        KtoJ = 1.38066*10^-23;
        JtoK = 7.24290*10^22;
        
        colormaps = {'wjet',...
            'ihesperia','hesperia',...
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
