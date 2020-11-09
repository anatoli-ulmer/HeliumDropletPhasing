function obj = configIPR(obj)
    %% constraint flags
    obj.support_dilate                  = false;                % generate more loose support by dilation
    obj.random_phase                    = false;                % use random starting phase
    
    obj.masking.constraint_RMask        = false;                % cut large angle scattering signal above rmax
    obj.masking.constraint_wedgeMask    = true;                 % cut wedges in detector slit direction (for straylight)
    obj.masking.constraint_gapMask      = false;                % cut gap slit (for straylight)
    obj.masking.dilate                  = false;                % dilate masked area (useful for straylight at detector edges)
    
    obj.constraint_real                 = false;                % rho is real
    obj.constraint_pos                  = false;                % rho is positive
    obj.constraint_posImag              = false;                % imag(rho) is real
    obj.constraint_shape                = false;                % DCDI: max deviation from calculated He drop rho (applies delta)
    obj.constraint_symmetry             = false;                % use symmetric FFT2 (only for small angle scattering)
    obj.constraint_mixScatt             = false;                % mix output image with scattering (weaker F. domain constr.)
    obj.doERstep                        = false;                % do ER step after each loop

    %% init parameter
    obj.binFactor                       = single(0.5);         	% bin image before phasing (e.g. 1024px * 0.5 = 512px)
    obj.binMethod                       = 'bicubic';          	% method for imresize (see documentation)
    obj.masking.dilateFactor            = double(1);        	% IF dilateMask: dilate by px
    obj.support_dilateFactor            = double(1);
    obj.support_dilateMethod            = 'disk';

    %% masking parameter
    obj.masking.minPhotons              = single(0);        	% low signal cutoff in photons 
    obj.masking.maxPhotons              = single(Inf);        	% high signal cutoff in photons 
    obj.masking.rmin                    = single(0);        	% radial mask min px cutoff
    obj.masking.rmax                    = single(512*3/4);      % IF constraint_RMask: radial mask max px cu toff
    obj.masking.RMASK_smoothPix         = single(20);       	% smoothing radial mask to avoid ringing
    obj.masking.wedgeAngle              = single(15/180*pi);    % cut wedge
    obj.masking.gapSize                 = single(80);           % gap

    %% phasing parameter
    obj.beta0                           = single(0.9);          % phasing parameter; should be between 0.5 and 1.0
    obj.alpha                           = single(1);            % 0.84 in Tanyag2015
    obj.delta                           = 1-obj.alpha;          % IF constraint_shape; DCDI parameter: max deviation from calculated rho
    obj.deltaFactor                     = 10;                   % Threshold multiplier for noise threshold
    obj.phaseMin                        = single(-Inf);         % DCDI parameter: min phase value; helps convergence behaviour
    obj.mixScatt                        = single(0.1);          % IF constraint_mixscatt: share of scattering in Fourier domain

    %% plot parameter
    obj.nStepsUpdatePlot                = Inf;
    obj.int_cm                          = 'imorgen';            % colormap index for Fourier domain (dropdown menu)
    obj.rec_cm                          = 'wjet';               % colormap for Real domain (dropdown menu)
    obj.clims_scatt                     = [-1,3];               % colormap limits for Fourier domain (log10 scale!)
    obj.reconrange                      = 2;                    % range index for color map scaling (dropdown menu)
    obj.intpart                         = 1;
    obj.reconpart                       = 'abs';                % 'real' | 'imag' | 'abs' | 'angle' -  filter for Real space image
    obj.normalize_shape                 = false;
    obj.substract_shape                 = true;                 % subtract calculated shape before plotting
    obj.subscale                        = 1;                    % scale calculated shape before subtraction
end
