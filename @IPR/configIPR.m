function obj = configIPR(obj)
    %% init parameter
    obj.binFactor                       = single(0.25);         % 0.25 (default) | 0.5 | 1 - bin image before phasing (e.g. 1024px * 0.5 = 512px)
    obj.binMethod                       = 'bicubic';          	% default: 'bicubic' - method for imresize (see documentation)
    obj.random_phase                    = false;                % default: false - use random starting phase
    
    %% masking
    obj.masking.minPhotons              = single(0.0);        	% default: 0.25 - low signal cutoff in photons
    obj.masking.maxPhotons              = single(Inf);        	% default: Inf - high signal cutoff in photons 
    obj.masking.constraint_wedgeMask    = true;                 % default: true - cut wedges in detector slit direction (for straylight)
    obj.masking.wedgeAngle              = single(15/180*pi);    % default: 15*pi/180 - wedge mask half opening angle in rad
    obj.masking.constraint_gapMask      = true;                 % default: true - mask gap slit (for straylight)
    obj.masking.gapSize                 = single(80);           % default: 80 - gap mask size in px
    obj.masking.fillMask                = false;                % default: true - fills missing data with current reconstructed intensity
    
    obj.masking.rmin                    = single(0);        	% default: 0 - radial mask min px cutoff
    obj.masking.constraint_RMask        = false;                % default: false - cut large angle scattering signal above rmax
    obj.masking.rmax                    = single(512*3/4);      % default: 384 - IF constraint_RMask: radial mask max px cutoff
    obj.masking.RMASK_smoothPix         = single(20);       	% default: 20 - smoothing radial mask to avoid ringing
    obj.masking.dilate                  = false;                % default: false - dilate masked area (useful for straylight at detector edges)
    obj.masking.dilateFactor            = double(1);        	% default: 1 - IF dilateMask: dilate by px

    obj.support_dilate                  = false;                % default: false - generate more loose support by dilation
    obj.support_dilateFactor            = double(1);            % default: 1 - dilate kernel size
    obj.support_dilateMethod            = 'disk';               % default: 'disk' - dilate kernel shape

    %% constraint flags    
    obj.constraints.real                = false;                % default: false - rho is real
    obj.constraints.posReal             = false;                % default: false - real(rho) is positive
    obj.constraints.posImag             = false;                % default: false - imag(rho) is positive
    obj.constraints.shape               = false;                % default: false - DCDI: max deviation from calculated He drop rho (applies delta)
    obj.constraints.symmetry            = false;                % default: false - use symmetric FFT2 (only for small angle scattering)
    obj.constraints.mixScatt            = false;                % default: false - mix output image with scattering (weaker F. domain constr.)
    obj.constraints.doERstep            = false;                % default: false - do ER step after each loop
    
    %% phasing parameter
    obj.beta0                           = single(0.9);          % default: 0.9 - phasing parameter; should be between 0.5 and 1.0
    obj.alpha                           = single(1);            % default: 1 - in Tanyag2015 [0.8, 0.9]
    obj.deltaFactor                     = 10;                   % default: 10 - Threshold multiplier for noise threshold
    obj.phaseMin                        = single(-Inf);         % default: -Inf - DCDI parameter: min phase value; helps convergence behaviour
    obj.mixScatt                        = single(0.1);          % default: 0.1 - IF constraint_mixscatt: share of scattering in Fourier domain
    
    %% plot parameter
    obj.nStepsUpdatePlot                = Inf;                  % default: Inf - Update plots every n steps
    obj.int_cm                          = 'ihesperia';          % default: 'ihesperia' - colormap for Fourier domain (dropdown menu)
    obj.rec_cm                          = 'b2r';                % default: 'b2r' - colormap for Real domain (dropdown menu)
    obj.clims_scatt                     = log10([0.5, 1000]);   % default: log10([0.5, 1000]) - colormap limits for Fourier domain (log10 scale!)
    obj.reconrange                      = 3;                    % default: 3 - dropdown menu index for plot range of real space images
    obj.intpart                         = 1;                    % default: 1 - dropdown menu index for plot range of fourier space images
    obj.reconpart                       = 'imag';               % 'real' | 'imag' (default) | 'abs' | 'angle' -  filter for Real space image
    obj.normalize_shape                 = false;                
    obj.substract_shape                 = false;                % subtract calculated shape before plotting
    obj.subscale                        = 1;                    % scale calculated shape before subtraction
end
