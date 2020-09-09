classdef IPR < handle
    properties
        %% Fourier space variables
        SCATT                                                                   % Scattering pattern
        AMP0                                                                    % Start Fourier space amplitude
        AMP                                                                     % current Fourier space amplitude
        PHASE                                                                   % current Fourier space Phase
        MASK                                                                    % binary mask for data in Fourier Space
        RMASK                                                                   % binary radial mask, applied if (constraint_RMask == true)
        wedgeMask                                                               % binary wedge like mask for stray light, applied if (constraint_wedgeMask == true)
        gapMask
        RMASK_smooth                                                            % single valued radial mask with smooth transisiton to zero values, applied if (constraint_RMask == true), using convolution kernel width 'RMASK_smoothPix'
        W                                                                       % current complex valued reconstruction after applying Fourier space constraints
        WS                                                                      % current complex valued reconstruction before applying Fourier space constraints
        ONESHOT                                                                 % complex valued Fourier space reconstruction after one step
        %% Real space variables
        amp                                                                     % current Real space amplitude
        phase                                                                   % current Real space phase
        support                                                                 % current binary Support constraint, may include reality and positivity constraints
        support0                                                                % start binary Support constraint
        w                                                                       % current complex valued reconstruction after applying Real space constraints
        ws                                                                      % current complex valued reconstruction before applying Real space constraints
        rho                                                                     % current droplet density
        rho0                                                                    % start droplet density
        rati
        scalingfactor = nan(1.0, 'single', 'gpuArray');
        oneshot                                                                 % complex valued Real space reconstruction after one step
        support_dilate = false;                                                 % boolian switch - dilate start Support
        support_dilateFactor = 2 * ones(1, 'single', 'gpuArray')                % factor for kernel for dlating the start Support, applied if (support_dilate == true)
        support_dilateMethod = 'disk';                                          % kernel method for dilating the start Support, applied if (support_dilate == true)
        %% Reconstruction parameter
        reconPlan
        errors = nan(5,1, 'single', 'gpuArray');
        noise = gpuArray(single(1.0))                                           % noise amplitude estimation value, noise = rms(noiseMatrix) = rms(NOISEMatrix)
        noiseMatrix                                                             % noise amplitude estimation matrix in Real space
        NOISEMatrix                                                             % noise amplitude estimation matrix in Fourier space
        overSamplingRatio = ones(1, 'single', 'gpuArray')
        beta0 = 0.9*ones(1, 'single', 'gpuArray')
        beta = 0.9*ones(1, 'single', 'gpuArray')
        support_radius = 70*ones(1, 'single', 'gpuArray')
        nTotal = ones(1, 'uint32');
        random_phase = false;
        alpha = 1.0 * ones(1, 'single', 'gpuArray')
        delta = 0.1 * ones(1, 'single', 'gpuArray')
        deltaFactor = 5*ones(1, 'single', 'gpuArray')
        deltaArray
        phaseMin = -Inf * ones(1, 'single', 'gpuArray')
        mixScatt = false;
        masking
        doERstep = false;
        %% image properties
        center% = nan(1,2, 'single', 'gpuAqrray');
        imgsize% = ones(1,2, 'single', 'gpuAqrray');
        xx
        yy
        binFactor = gpuArray(single(0.5));                                      % 1 | 0.5 | 0.25 - factor for image binning before reconstruction
        binMethod = 'bilinear';                                                 % 'nearest' | 'bilinear' | 'bicubic' - method for image binning before reconstruction
        clims_scatt = log10([0.1, 60]);
        clims_recon = nan(1,2);
        substract_shape = false;
        normalize_shape = false;
        constraint_real = false;
        constraint_posImag = false;
        constraint_pos = false;
        constraint_shape = false;
        constraint_symmetry = false;
        constraint_mixScatt = false;
        constraint_RMask = false;
        constraint_wedgeMask = false;
        constraint_gapMask = false;
        RMASK_smoothPix = gpuArray(single(10));
        reconpart string = 'real';
        intpart double = 1;
        reconrange uint8 = 1;
        rec_cm char = 'wjet';                                                   % colormap for Real space axes
        int_cm char = 'imorgen';                                                % colormap for Fourier space axes
        subscale = gpuArray(single(1));                                         % factor for droplet density subtraction before plotting (applied for plotting only!)
        rhoThreshold = gpuArray(single(1));                                     % Dunno what this did ...
        nStepsUpdatePlot = gpuArray(uint32(100));                               % update plots after how many steps
        %% plot object
        parentfig = gobjects(1,1)                                               % handle for parent figure
        figureArray = gobjects(1,1)                                             % handle for IPR main figure
        tiledLayout = gobjects(1,1)                                             % handle fpr IPR main figure tiledlayout
        axesArray = gobjects(6,1)                                               % handle for IPR main figure axes
        plt                                                                     % handle for IPR main figure plots
        popupArray = gobjects(6,1)                                              % handle for IPR main figure popup uicontrols
        cBoxArray = gobjects(2,1)
        editArray = gobjects(3,1)                                               % handle for IPR main figure edit uicontrols
        scanObj
    end
    methods

        %% INIT
        function obj = IPR(pnCCDimg, varargin)                                  
            % Main figure for iterative phase retrieval. Copies the
            % KeyPressFcn Callback from Calling figure.
            
            obj.configIPR();    % load standard values from config file
            
            if exist('varargin','var')
                L = length(varargin);
                if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
                for ni = 1:2:L
                    switch lower(varargin{ni})
                        case 'objecthandle', obj = varargin{ni+1};
                        case 'parentfig', obj.parentfig = varargin{ni+1};
                            
                        case 'clims_scatt', obj.clims_scatt = single(varargin{ni+1});
                        case 'clims_recon', obj.clims_recon = single(varargin{ni+1});
                        case 'substract_shape', obj.substract_shape = single(varargin{ni+1});
                        case 'normalize_shape', obj.normalize_shape = single(varargin{ni+1});
                        case 'reconpart', obj.reconpart = varargin{ni+1};
                        case 'reconrange', obj.reconrange = varargin{ni+1};
                        case 'rec_cm', obj.rec_cm = varargin{ni+1};
                        case 'int_cm', obj.int_cm = varargin{ni+1};
                            
                        case 'binfactor', obj.binFactor = single(varargin{ni+1});
                        case 'phase', obj.PHASE = single(varargin{ni+1});
                        case 'mask', obj.MASK = logical(varargin{ni+1});
                        case 'support', obj.support0 = single(varargin{ni+1});
                        case 'support_radius', obj.support_radius = single(varargin{ni+1});
                        case 'rho0', obj.rho0 = single(varargin{ni+1});
                        case 'center', obj.center = single(varargin{ni+1});
                        case 'rmin', obj.masking.rmin = single(varargin{ni+1});
                        case 'rmax', obj.masking.rmax = single(varargin{ni+1});
                        case 'beta', obj.beta0 = single(varargin{ni+1});
                        case 'random_phase', obj.random_phase = varargin{ni+1};
                        case 'constraint_real', obj.constraint_real = varargin{ni+1};
                        case 'constraint_pos', obj.constraint_pos = varargin{ni+1};
                        case 'constraint_shape', obj.constraint_shape = varargin{ni+1};
                    end
                end
            end
            obj = initIPR(obj, pnCCDimg);
            obj.plotAll;
        end
        
        %% DECLARATION
        obj = configIPR(obj)                                                    % load standard values from config file
        obj = initIPR(obj, pnCCDimg)                                            % initialization function
        obj = initGPU(obj)                                                      % initialization funciton for GPU arrays
        obj = initMask(obj)                                                     % initialize masks
        obj = initPlots(obj)                                                    % generate figure and plot objects
        obj = resizeData(obj)                                                   % rebin and resize data
        obj = resetIPR(obj)                                                     % reset variables to starting values
        [noise, noiseMatrix, NOISEMatrix] = calcNoise(AMP0)                     % calculate noise amplitude
        
        obj = addReconPlan(obj, method, nSteps, nLoops)
        obj = startRecon(obj)
        obj = iterate(obj, nSteps, method)
        obj = applyConstraints(obj, method)                                             
        rho = normalizeDensity(ws, support, rho0, alpha)
        WS = projectorModulus(AMP, AMP0, PHASE, MASK)
        obj = scanParameter(obj, sVar, sArray, nSteps, savePath)        % scan parameter and save images
        
        alpha = updateAlpha(alphaArray, idx)
        beta = updateBeta(beta0, beta, nTotal)
        support = updateSupport(w)
        
        data = getReconstructionPart(data, part)                                % Get part of Real space reconstruction, chosen by dropdown menu.
        obj = zeroBorders(obj)                                                  % Set outer region in Fourier space to zero
        
        obj = plotAll(obj,~,~)
        obj = setColormaps(obj,~,~)                                             % Setter for colormaps
        obj = setScaleErrorPlot(obj,src,~)                                      % Setter for colorbar limits of Real space plots, chosen by dropdown menu.
        obj = setPlotParts(obj,~,~)                                             % Setter for real/imag/abs/angle part of Real space plots, chosen by dropdown menu.
        obj = setSubtractionScale(obj,~,~)
        obj = setPlotRange(obj,~,~)
    end
end





