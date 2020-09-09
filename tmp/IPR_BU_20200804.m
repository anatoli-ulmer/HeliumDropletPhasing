classdef IPR < handle
    properties
        %%%%%% in Fourier space %%%%%%
        SCATT
        INT
        INT0
        PHASE
        MASK
        RMASK
        wedgeMask
        RMASK_smooth
        W
        WS
        ONESHOT
        %%%%%% in real space %%%%%%
        int
        phase
        support
        support0
        S
        w
        ws
        rho
        rho0
        rati
        scalingfactor = nan(1.0, 'single', 'gpuArray');
        oneshot
        support_dilate = false;
        support_dilateFactor = 2 * ones(1, 'single', 'gpuArray')
        support_dilateMethod = 'disk';
        %%%%%% reconstruction parameter %%%%%%
        errors = nan(3,1000, 'single', 'gpuArray');
        %         errors.real = nan(1,1000, 'single', 'gpuArray');
        %         errors(2,:) = nan(1,1000, 'single', 'gpuArray');
        %         errors(3,:) = nan(1,1000, 'single', 'gpuArray');
        noise = gpuArray(single(1.0))
        noiseMatrix
        overSamplingRatio = ones(1, 'single', 'gpuArray')
        beta0 = 0.9*ones(1, 'single', 'gpuArray')
        beta = 0.9*ones(1, 'single', 'gpuArray');
        support_radius = 70*ones(1, 'single', 'gpuArray')
        nTotal = zeros(1, 'uint32');
        random_phase = false;
        alpha = 1.0 * ones(1, 'single', 'gpuArray')
        delta = 0.1 * ones(1, 'single', 'gpuArray')
        phaseMin = -0.5 * ones(1, 'single', 'gpuArray')
        mixScatt = false;
        masking
        doERstep = false;
        %%%%%% image properties %%%%%%
        center% = nan(1,2, 'single', 'gpuAqrray');
        imgsize% = ones(1,2, 'single', 'gpuAqrray');
        xx
        yy
        wedgeAngle = gpuArray(single(10));
        binFactor = gpuArray(single(0.5)); % [0,1]
        binMethod = 'bilinear'; % 'nearest', 'bilinear' or 'bicubic'
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
        RMASK_smoothPix = gpuArray(single(10));
        reconpart double = 3;
        intpart double = 1;
        reconrange uint8 = 1;
        rec_cm uint8 = 3;
        int_cm uint8 = 1;
        subscale = gpuArray(single(1));
        rhoThreshold = gpuArray(single(1));
        nStepsUpdatePlot = gpuArray(uint32(100));
        %%%%%% plot objects %%%%%%
        parentfig = gobjects(1)
        fig
        figS = gobjects(1)
        tS = gobjects(1)
        axS = gobjects(1)
        pltS = gobjects(1)
        ax
        plt
        popup
        edt
    end
    methods
        %%%%%%%%%% DECLARATION %%%%%%%%%%
        obj = configIPR(obj)
        obj = initGPU(obj)
        obj = initIPR(obj, pnCCDimg)
        obj = initMask(obj)
        obj = initPlots(obj)
        obj = resizeImg(obj)
        
        obj = applyConstraints(obj, method)
        obj = calcError(obj)
        WS = projectorModulus(AMP, AMP0, PHASE, MASK)
        rho = normalizeDensity(ws, support, rho, rho0, alpha)
        obj = updatBeta(obj)
        obj = updateSupport(obj)
        obj = zeroBorders(obj)
        
        obj = setColormaps(obj,~,~)
        obj = setScaleErrorPlot(obj,evt,~)
        obj = setPlotParts(obj,~,~)
        obj = setSubtractionScale(obj,~,~)
        obj = setPlotRange(obj,~,~)
        
        %%%%%%%%%% INIT %%%%%%%%%%
        %%%%%%%%%% INIT %%%%%%%%%%
        %%%%%%%%%% INIT %%%%%%%%%%
        function obj = IPR(pnCCDimg, varargin)
            if exist('varargin','var')
                L = length(varargin);
                if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
                for ni = 1:2:L
                    switch lower(varargin{ni})
                        case 'objecthandle', obj = varargin{ni+1};
                        case 'fig', obj.fig = varargin{ni+1};
                        case 'ax', obj.ax = varargin{ni+1};
                        case 'plt', obj.plt = varargin{ni+1};
                        case 'popup', obj.popup = varargin{ni+1};
                        case 'edt', obj.edt = varargin{ni+1};
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
            %             obj.figS = figure(456784); clf
            %             obj.tS = tiledlayout('flow', 'Parent', obj.figS, 'TileSpacing', 'compact', 'Padding', 'compact');
            %             obj.axS(1) = nexttile(obj.tS);
            %             obj.axS(2) = nexttile(obj.tS);
            %             obj.pltS(1) = imagesc(obj.axS(1), abs(obj.INT)); zoom(obj.axS(1), 5);
            %             obj.pltS(2) = imagesc(obj.axS(2), abs(obj.INT)); zoom(obj.axS(2), 5);
        end
        function obj = plotAll(obj,~,~)
            obj.plt.err(1).YData = gather((obj.errors(1,:)));
            obj.plt.err(2).YData = gather((obj.errors(2,:)));
            obj.plt.err(3).YData = gather((obj.errors(3,:)));
            %             obj.ax.err(1).XLim=[0,max(1, obj.nTotal)];
            %             obj.ax.err(2).XLim=[0,max(1, obj.nTotal)];
            %             obj.ax.err(1).YLim=[0,gather(nanmax([1, obj.errors(1,:)]))];
            %             obj.ax.err(2).YLim=[0,gather(nanmax([1, obj.errors(2,:), obj.errors(3,:)]))];
            
            obj.plt.int(1).img.CData = gather(intpartfunc(obj.W, obj.intpart));
            obj.plt.int(2).img.CData = gather(intpartfunc(obj.WS, obj.intpart));
            
            if obj.normalize_shape
                obj.plt.rec(1).img.CData = gather(recpartfunc(obj.ws./obj.rho, obj.reconpart));
                obj.plt.rec(2).img.CData = gather(recpartfunc(obj.w./obj.rho, obj.reconpart));
            elseif obj.substract_shape
                obj.plt.rec(1).img.CData = gather(recpartfunc( obj.ws, obj.reconpart) - (obj.rho .* obj.subscale) );
                obj.plt.rec(2).img.CData = gather(recpartfunc( obj.w, obj.reconpart) - (obj.rho .* obj.subscale) );
            else
                obj.plt.rec(1).img.CData = gather(recpartfunc(obj.ws, obj.reconpart));
                obj.plt.rec(2).img.CData = gather(recpartfunc(obj.w, obj.reconpart));
            end
            obj.setPlotRange;
            %             obj.plt.int(1).title.String = sprintf('reconstructed - %i steps', obj.nTotal);
            obj.plt.rec(1).title.String = sprintf('before constraints - %i steps', obj.nTotal);
            drawnow limitrate;
        end
        function obj = plotFinalResult(obj, ~,~)
            %             obj.rhoThreshold = 1.1;
            ncols = 256;
            colth = ncols/2*obj.rhoThreshold;
            final.ws = real(obj.ws);
            final.ws = ( (final.ws / max(final.ws(:))*(ncols/2) + ncols/2) .* (obj.ws > (obj.rho*obj.rhoThreshold) ) ) + ...
                ( obj.rho / max(obj.rho(:)) * (ncols/2)  .* (obj.ws <= (obj.rho*obj.rhoThreshold) ) );
            r = real( (obj.ws-obj.rho) .* single(obj.ws > (obj.rho*obj.rhoThreshold) ) );
            g = zeros(size(obj.ws));
            b = real( obj.rho );
            r = uint8(r/max(r(:))*255);
            g = uint8(g);
            b = uint8(b/max(b(:))*255);
            r(~obj.support) = 255;
            g(~obj.support) = 255;
            b(~obj.support) = 255;
            final.rgb = cat(3,r,g,b);
            
            final.fig = figure(333001); clf
            final.ax(1) = mysubplot(1,2,1);
            final.ax(2) = mysubplot(1,2,2);
            final.img(1) = imagesc((final.ws), 'parent', final.ax(1), 'XData', obj.plt.rec(2).img.XData, 'YData', obj.plt.rec(2).img.YData);
            axis image;
            
            colormap([bluemap(colth); b2r(ncols-colth)]);
            grid off;
            final.img(2) = image(final.rgb, 'parent', final.ax(2), 'XData', obj.plt.rec(2).img.XData, 'YData', obj.plt.rec(2).img.YData);
            arrayfun(@(a) set(final.ax(a), 'XLim', obj.ax.rec(2).XLim, 'YLim', obj.ax.rec(2).YLim), 1:2);
            drawnow limitrate;
        end
        
        %%%%%%%%%% UTLIS %%%%%%%%%%
        %%%%%%%%%% UTLIS %%%%%%%%%%
        %%%%%%%%%% UTLIS %%%%%%%%%%
        
%         function obj = setColormaps(obj,~,~)
%             newintmap = obj.popup(1).ctrl.String{obj.popup(1).ctrl.Value};
%             colormap(obj.ax.int(1), newintmap);% drawnow; pause(.05);
%             colormap(obj.ax.int(2), newintmap);% drawnow; pause(.05);
%             newrecmap = obj.popup(2).ctrl.String{obj.popup(2).ctrl.Value};
%             colormap(obj.ax.rec(1), newrecmap);% drawnow; pause(.05);
%             colormap(obj.ax.rec(2), newrecmap);% drawnow; pause(.05);
%         end
%         function obj = setScaleErrorPlot(obj,evt,~)
%             switch evt.Value
%                 case 1
%                 case 2
%                     set(obj.ax.err(1),'XScale','linear','YScale','linear');
%                     set(obj.ax.err(2),'XScale','linear','YScale','linear');
%                 case 3
%                     set(obj.ax.err(1),'XScale','log','YScale','linear');
%                     set(obj.ax.err(2),'XScale','log','YScale','linear');
%                 case 4
%                     set(obj.ax.err(1),'XScale','linear','YScale','log');
%                     set(obj.ax.err(2),'XScale','linear','YScale','log');
%                 case 5
%                     set(obj.ax.err(1),'XScale','log','YScale','log');
%                     set(obj.ax.err(2),'XScale','log','YScale','log');
%             end
%         end
%         function obj = setPlotParts(obj,~,~)
%             obj.intpart = obj.popup(5).ctrl.Value;
%             obj.reconpart = obj.popup(6).ctrl.Value;
%             obj.plotAll;
%         end
       

    end
end





