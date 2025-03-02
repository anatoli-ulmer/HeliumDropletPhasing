function obj = configIPR(obj)
    %% init parameter
    obj.binFactor                       = single(1/2);           % bin factor 0.25 (default) | 0.5 | 1 - bin image before phasing (e.g. 1024px * 0.5 = 512px)
    obj.binMethod                       = 'lanczos2';          	% default: 'lanczos2' - method for imresize (see documentation)
    obj.padFactor                       = single(1);
    obj.random_phase                    = 1;                % default: false - use random starting phase
    
    obj.filter.roundOnPhotons           = 0;
    obj.filter.gauss.isApplied          = false;
    obj.filter.gauss.sigma              = 1;
    
    %% masking
    obj.masking.constraint_rmin         = 0;        	% default: 0 - radial mask min px cutoff
    obj.masking.dilate                  = 1;                % default: false - dilate masked area (useful for straylight at detector edges)
    obj.masking.constraint_wedgeMask    = 1;                 % default: true - cut wedges in detector slit direction (for straylight)
    obj.masking.constraint_taper        = 1;
    obj.masking.constraint_gapMask      = 1;                 % default: true - mask gap slit (for straylight)
    obj.masking.constraint_RMask        = 0;                % default: false - cut large angle scattering signal above rmax
    obj.masking.constraint_verticalWedgeMask = 0;                 % default: true - cut wedges in detector slit direction (for straylight)

        
    obj.masking.minPhotons              = single(0);        	% default: 0.25 - low signal cutoff in photons
    obj.masking.maxPhotons              = single(100);        	% default: Inf - high signal cutoff in photons 
    obj.masking.wedgeAngle              = single(15/180*pi);    % default: 15*pi/180 - wedge mask half opening angle in rad
    obj.masking.verticalWedgeAngle      = single(10/180*pi);    % default: 15*pi/180 - wedge mask half opening angle in rad
    obj.masking.gapSize                 = single(40);           % default: 40 - gap mask size in px
    obj.masking.fillMask                = 1;                % default: true - fills missing data with current reconstructed intensity
    obj.masking.rmin                    = single(60);        	% default: 0 - radial mask min px cutoff
    obj.masking.rmax                    = single(432);      % default: 384 - IF constraint_RMask: radial mask max px cutoff
    obj.masking.constraint_RMaskSmoothing = 0;
    obj.masking.RMASK_smoothPix         = single(0);       	% default: 20 - smoothing radial mask to avoid ringing
    obj.masking.dilateMethod            = 'disk';
    obj.masking.dilateFactor            = double(1);        	% default: 1 - IF dilateMask: dilate by px
    obj.masking.taper.method            = 'gaussian';
    obj.masking.taper.size              = 80;
    obj.masking.taper.sigma             = 80;
    
    obj.support_dilate                  = 0;                % default: false - generate more loose support by dilation
    obj.support_dilateFactor            = double(1);            % default: 1 - dilate kernel size
    obj.support_dilateMethod            = 'disk';               % default: 'disk' - dilate kernel shape

    %% constraint flags
    obj.constraints.real                = 0;                % default: false - rho is real
    obj.constraints.posReal             = 0;                 % default: true - real(rho) is positive
    obj.constraints.posImag             = 0;                % default: false - imag(rho) is positive
    obj.constraints.shape               = false;                % default: false - DCDI: max deviation from calculated He drop rho (applies delta)
    obj.constraints.minPhase            = 0;                % default: false - DCDI
    obj.constraints.symmetry            = false;                % default: false - use symmetric FFT2 (only for small angle scattering)
    obj.constraints.mixScatt            = false;                % default: false - mix output image with scattering (weaker F. domain constr.)
    obj.constraints.doERstep            = false;                % default: false - do ER step after each loop
    obj.constraints.changeBeta          = false;
    obj.constraints.noise.radAvg        = 1;                               % use radial average for calculation of sigma(n,m)
    obj.constraints.noise.zeroPointFive = 1;                               % sigma(n,m) = 0.5 for I>0.2
    obj.constraints.noise.maskedOnly    = 0;                               % true => smaller noise (rms only over masked area)
    obj.constraints.noise.manualNoise   = 0;                               % set manual noise value. not used when is zero    
    
    obj.constraints.manualDelta         = 0;                    % default: false - sets constant delta
    obj.constraints.minDelta            = 0;%2.25;                    % default: 4 - cuts off delta to this value
    obj.constraints.maxDelta            = 8;%3;                    % default: 4 - cuts off delta to this value
    obj.constraints.normalizeRhoEachStep = 1;
    obj.constraints.normalizeToSubNoise = 1;
    obj.constraints.initWithPosReal     = 1;
    obj.constraints.initWithPosImag     = 1;
    obj.constraints.deltaComparePart    = 'real';

    
    %% phasing parameter
    obj.beta0                           = single(0.87);          % default: 0.9 - phasing parameter; should be between 0.5 and 1.0
    obj.alpha                           = single(nan);            % default: 1 - in Tanyag2015 [0.8, 0.9]
    obj.deltaFactor                     = 5;                   % default: 10 - Threshold multiplier for noise threshold
    obj.delta0                          = 5;                    % only IF constraints.manualDelta
    obj.phaseMin                        = single(0);            % default: -Inf - DCDI parameter: min phase value; helps convergence behaviour
    obj.phaseMax                        = single(pi/2);            % default: -Inf - DCDI parameter: min phase value; helps convergence behaviour
%     obj.phaseMin                        = single(-pi/2);            % default: -Inf - DCDI parameter: min phase value; helps convergence behaviour
%     obj.phaseMin                        = single(-0.5);            % default: -Inf - DCDI parameter: min phase value; helps convergence behaviour
%     obj.phaseMax                        = single(pi);            % default: -Inf - DCDI parameter: min phase value; helps convergence behaviour
%     obj.phaseMin                        = single(-pi);            % default: -Inf - DCDI parameter: min phase value; helps convergence behaviour
    %% plot parameter
    obj.nStepsUpdatePlot                = Inf;                  % default: Inf - Update plots every n steps
    obj.int_cm                          = 'ihesperia';          % default: 'ihesperia' - colormap for Fourier domain (dropdown menu)
    obj.rec_cm                          = 'wjet2';                % default: 'b2r' - colormap for Real domain (dropdown menu)
    obj.clims_scatt                     = [0.1, 100];   % default: log10([0.5, 1000]) - colormap limits for Fourier domain (log10 scale!)
    obj.cscale_scatt                    = 'log';
    obj.reconrange                      = 1;                    % default: 3 - dropdown menu index for plot range of real space images
    obj.intpart                         = 1;                    % default: 1 - dropdown menu index for plot range of fourier space images
    obj.reconpart                       = 'abs';               % 'real' | 'imag' (default) | 'abs' | 'angle' -  filter for Real space image
    obj.substract_shape                 = true;                % subtract calculated shape before plotting
    obj.subscale                        = 1;                    % scale calculated shape before subtraction
    obj.plotting.drawDroplet            = true;
    obj.plotting.alpha.droplet          = .75;
    obj.plotting.alpha.dopant           = .25;
    obj.plotting.colormap.droplet       = dropletWjet(256, 0.5);
    obj.plotting.colormap.dopant        = dopantWjet(256, 0.5);
    obj.plotting.poissonNoise           = 1;
    obj.plotting.NRSMD                  = false;
    obj.plotting.LineWidth              = 1.5;
    
end
