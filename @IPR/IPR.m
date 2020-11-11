classdef IPR < handle
    properties
        %% General
        gpuAvailable                                                            % number of available gpu devices
        
        %% Fourier space variables
        pnCCDimg
        SCATT                                                                   % Scattering pattern
        AMP0                                                                    % Start Fourier space amplitude
        AMP                                                                     % current Fourier space amplitude
        PHASE                                                                   % current Fourier space Phase
        MASK                                                                    % binary mask for data in Fourier Space
        RMASK                                                                   % binary radial mask, applied if (constraint_RMask == true)
        wedgeMask                                                               % binary wedge like mask for stray light, applied if (constraint_wedgeMask == true)
        gapMask                                                                 % binary gap mask for stray light, applied if (constraint_gapMask == true)
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
        simScene
        simSceneFlipped
        oneshot                                                                 % complex valued Real space reconstruction after one step
        support_dilate = false                                                  % boolian switch - dilate start Support // see support_dilateFactor, support_dilateMethod
        support_dilateFactor = 2 * ones(1, 'single')                            % factor for kernel for dlating the start Support, applied if (support_dilate == true) // see support_dilate, support_dilateMethod
        support_dilateMethod = 'disk';                                          % kernel method for dilating the start Support, applied if (support_dilate == true) // see support_dilate, support_dilateFactor
        dropletOutline
        
        %% Reconstruction parameter
        reconPlan
        constraints
        errors = nan(3,1, 'single')
        noise = (single(1.0))                                                   % noise amplitude estimation value, noise = rms(noiseMatrix) = rms(NOISEMatrix)
        noiseMatrix                                                             % noise amplitude estimation matrix in Real space
        NOISEMatrix                                                             % noise amplitude estimation matrix in Fourier space
        overSamplingRatio = ones(1, 'single')
        beta0 = 0.9*ones(1, 'single')
        beta = 0.9*ones(1, 'single')
        support_radius = 70*ones(1, 'single')
        nTotal = ones(1, 'uint32')
        random_phase = false;
        alpha = 1.0 * ones(1, 'single')
        delta = 0.1 * ones(1, 'single')
        deltaFactor = 5*ones(1, 'single')
        phaseMin = -Inf * ones(1, 'single')
        mixScatt = false
        masking
        
        %% image properties
        center = nan(1,2, 'single');
        imgsize = ones(1,2, 'single');
        xx
        yy
        binFactor = (single(0.5));                                              % 1 | 0.5 | 0.25 - factor for image binning before reconstruction
        binMethod = 'bilinear';                                                 % 'nearest' | 'bilinear' | 'bicubic' - method for image binning before reconstruction
        clims_scatt = log10([0.1, 60]);
        clims_recon = nan(1,2);
        substract_shape = false;
        normalize_shape = false;
        reconpart char = 'real';
        intpart = uint8(1);
        reconrange = uint8(1);
        rec_cm char = 'wjet';                                                   % colormap for Real space axes
        int_cm char = 'imorgen';                                                % colormap for Fourier space axes
        subscale = 1.0;                                                         % factor for droplet density subtraction before plotting (applied for plotting only!)
        nStepsUpdatePlot = uint32(100);                                         % update plots after how many steps
        
        %% plot object
        parentfig = gobjects(1,1)                                               % handle for parent figure
        figureArray = gobjects(1,1)                                             % handle for IPR main figure
%         tiledLayout = gobjects(1,1)                                             % handle fpr IPR main figure tiledlayout
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
            obj.pnCCDimg = pnCCDimg;
            % Main figure for iterative phase retrieval. Copies the
            % KeyPressFcn Callback from Calling figure.
            if mod(numel(varargin),2)~=0
                error('Optional arguments must come in name-value-pairs.')
            end
            % load standard values from config file
            obj.configIPR();
            % overwrite data by variable input arguments
            for i=1:2:numel(varargin)
                obj.(varargin{i})=varargin{i+1};
            end
            obj.initGPU();
            % init
            obj.initIPR(pnCCDimg);
        end
        
        %% DECLARATION
        obj = configIPR(obj)                                                    % load standard values from config file
        obj = initGPU(obj)
        obj = initIPR(obj, pnCCDimg)                                            % initialization function                                                    % initialization funciton for GPU arrays
        obj = initMask(obj)                                                     % initialize masks
        obj = initGUI(obj)                                                      % generate figure and plot objects
        obj = resizeData(obj)                                                   % rebin and resize data
        obj = resetIPR(obj,varargin)                                            % reset variables to starting values
        [noise, noiseMatrix, NOISEMatrix] = calcNoise(AMP0)                     % calculate noise amplitude
        
        obj = reconAddToPLan(obj, method, nSteps, nLoops)
        obj = reconRunPlan(obj, method, nSteps, nLoops)
        obj = reconIterate(obj, nSteps, method)
        obj = reconApplyConstraints(obj, method)         
        obj = calcError(obj)

        WS = projectorModulus(AMP, AMP0, PHASE, MASK)
        
        beta = updateBeta(beta0, beta, nTotal)
        support = updateSupport(w)
        
        data = getReconstructionPart(data, part)                                % Get part of Real space reconstruction, chosen by dropdown menu.
        
        obj = setIPRColormaps(obj,~,~)                                             % Setter for colormaps
        obj = setScaleErrorPlot(obj,src,~)                                      % Setter for colorbar limits of Real space plots, chosen by dropdown menu.
        obj = setImageParts(obj,~,~)                                             % Setter for real/imag/abs/angle part of Real space plots, chosen by dropdown menu.
        obj = setSubtractionScale(obj,~,~)
        obj = setPlotRange(obj,~,~)
        
        obj = updateGUI(obj,~,~)
    end
end
