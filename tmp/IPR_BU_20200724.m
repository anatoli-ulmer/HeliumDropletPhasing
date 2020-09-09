classdef IPR < handle
    properties
        %%%%%% in Fourier space %%%%%%
        newint
        INT
        PHASE
        MASK
        RMASK
        wedgeMask
        smoothRMask
        W
        WS
        SCATT
        ONESHOT
        %%%%%% in real space %%%%%%
        int
        phase
        support
        constraintViolated
        w
        ws
        w_old
        int_old
        density
        start_density
        scalingfactor
        oneshot
        %%%%%% reconstruction parameter %%%%%%
        errReal = nan(1,1000);
        errFourier = nan(1,1000);
        %     startcond
        OSR
        beta0;
        beta = 0.87;
        support_radius = 70;
        ntotal = 0;
        random_phase = false;
        alpha = 1;
        delta = 0.9;
        phaseMin = -.5;
        mixScatt = 0;
        masking
        doERstep = 0;
        %%%%%% image properties %%%%%%
        center
        imgsize
        xx
        yy
        rmin = 0;
        rmax = 432;
        wedgeAngle = 0;
        binfactor = 1; % [0,1]
        binmethod = 'bilinear'; % 'nearest', 'bilinear' or 'bicubic'
        clims_scatt = log10([0.1, 60]);
        clims_recon
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
        RMASK_smoothPix = 10;
        reconpart = 3;
        reconrange = 1;
        rec_cm = 3;
        int_cm = 1;
        subscale = 1;
        densityThreshold = 1;
        %%%%%% plot objects %%%%%%
        parentfig
        fig
        ax
        plt
        popup
        edt
    end
    methods
        %%%%%%%%%% INIT %%%%%%%%%%
        %%%%%%%%%% INIT %%%%%%%%%%
        %%%%%%%%%% INIT %%%%%%%%%%
        function obj = IPR(pnCCDimg, varargin)
            if exist('varargin','var')
                L = length(varargin);
                if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
                for ni = 1:2:L
                    switch lower(varargin{ni})
                        case 'fig', obj.fig = varargin{ni+1};
                        case 'ax', obj.ax = varargin{ni+1};
                        case 'plt', obj.plt = varargin{ni+1};
                        case 'popup', obj.popup = varargin{ni+1};
                        case 'edt', obj.edt = varargin{ni+1};
                        case 'phase', obj.PHASE = varargin{ni+1};
                        case 'mask', obj.MASK = varargin{ni+1};
                        case 'support', obj.support = varargin{ni+1};
                        case 'support_radius', obj.support_radius = varargin{ni+1};
                        case 'start_density', obj.start_density = varargin{ni+1};
                        case 'center', obj.center = varargin{ni+1};
                        case 'parentfig', obj.parentfig = varargin{ni+1};
                        case 'rmin', obj.masking.rmin = varargin{ni+1};
                        case 'rmax', obj.masking.rmax = varargin{ni+1};
                        case 'beta', obj.beta = varargin{ni+1};
                        case 'clims_scatt', obj.clims_scatt = varargin{ni+1};
                        case 'clims_recon', obj.clims_recon = varargin{ni+1};
                        case 'binfactor', obj.binfactor = varargin{ni+1};
                        case 'substract_shape', obj.substract_shape = varargin{ni+1};
                        case 'normalize_shape', obj.normalize_shape = varargin{ni+1};
                        case 'random_phase', obj.random_phase = varargin{ni+1};
                        case 'constraint_real', obj.constraint_real = varargin{ni+1};
                        case 'constraint_pos', obj.constraint_pos = varargin{ni+1};
                        case 'constraint_shape', obj.constraint_shape = varargin{ni+1};
                        case 'reconpart', obj.reconpart = varargin{ni+1};
                        case 'reconrange', obj.reconrange = varargin{ni+1};
                        case 'rec_cm', obj.rec_cm = varargin{ni+1};
                        case 'int_cm', obj.int_cm = varargin{ni+1};
                    end
                end
            end
            obj.newint = pnCCDimg;
            
            % LOAD CONFIG FROM FILE
            obj = load_config_phasing(obj);
            
            obj.MASK = (~isnan(obj.newint));
            if obj.masking.dilate
                obj.MASK = imdilate(obj.newint .* ( isnan(obj.newint) ), ...
                    strel('disk', obj.masking.dilateFactor));
                %         obj.newint = obj.newint .* (~obj.MASK);
                %         obj.newint(obj.MASK==0) = nan;
                %       else
                %         obj.MASK = double(~isnan(obj.newint));
            end
            %       obj.newint(isnan(obj.newint)) = 0;
            obj.newint = fillmissing(obj.newint, 'constant', 0.0);
            obj.SCATT = single(obj.newint);
            obj.INT = obj.SCATT;
            obj.imgsize = size(obj.INT);
            
            if isempty(obj.center)
                obj.center = obj.imgsize/2;
            end
            obj.beta0 = obj.beta;
            [obj.xx, obj.yy] = meshgrid(...
                linspace(1,obj.imgsize(2),obj.imgsize(2)) - obj.center(2),...
                linspace(1,obj.imgsize(1),obj.imgsize(1)) - obj.center(1) );
            obj.updatemask;
            obj.INT(isnan(obj.INT)) = 0;
            obj.SCATT(isnan(obj.SCATT)) = 0;
            obj.INT = obj.INT.*obj.MASK;
            obj.startsupport;
            obj.startphase;
            obj.density = obj.start_density;
            obj.calcOSR;
            obj.gpufun;
            obj.plotfun;
        end
        function obj = updatemask(obj)
            if isempty(obj.MASK)
                obj.MASK = ones(obj.imgsize);
            end
            obj.MASK = double(obj.MASK & ~isnan(obj.INT));
            obj.MASK(obj.xx.^2+obj.yy.^2<obj.masking.rmin.^2) = 0;
            obj.RMASK = (obj.xx.^2+obj.yy.^2>obj.masking.rmax.^2);
            obj.wedgeMask = abs(atan(obj.yy./obj.xx))<=obj.masking.wedgeAngle;
            if obj.masking.constraint_RMask; obj.MASK = obj.MASK .* ~obj.RMASK; end
            if obj.masking.constraint_wedgeMask; obj.MASK(obj.wedgeMask) = 0; end
        end
        function obj = startsupport(obj)
            if isempty(obj.support)
                obj.support = double( (obj.xx).^2 + (obj.yy).^2 < obj.support_radius.^2);
                fprintf('generating support from radius\n');
            end
            obj.constraintViolated = double(obj.support == 0);
        end
        function obj = startphase(obj)
            if isempty(obj.start_density)
                if isempty(obj.support)
                    obj.start_density = 2*sqrt((obj.support_radius^2-(obj.xx).^2-(obj.yy).^2));
                    obj.start_density = obj.start_density.*obj.support;
                    obj.start_density = obj.start_density/sum(obj.start_density(:));
                else
                    obj.start_density = obj.support;
                end
            end
            obj.w = complex(obj.start_density);
            obj.W = ifftshift(fft2(fftshift(obj.w)));
            % normalize on integral in masked area
            obj.scalingfactor = obj.alpha/nansum(nansum(abs(obj.W) .* obj.MASK)) * ...
                nansum(nansum(obj.SCATT .* obj.MASK));
            %       obj.W = abs(obj.W) * obj.scalingfactor .* exp(1i*angle(obj.W));
            %       obj.w = abs(obj.w) * obj.scalingfactor .* exp(1i*angle(obj.w));
            obj.w = obj.w * obj.scalingfactor;
            obj.W = obj.W * obj.scalingfactor;
            %       obj.int = abs(obj.w).*obj.support;
            %       obj.phase = angle(obj.w).*obj.support;
            obj.INT = abs(obj.W);
            obj.PHASE = angle(obj.W);
            if obj.random_phase
                obj.randphase;
            end
            obj.WS = ( obj.INT.*(1-obj.MASK) + obj.SCATT.*obj.MASK ) .* exp(1i*obj.PHASE);
            obj.ws = fftshift(ifft2(fftshift(obj.WS)));
            obj.w = obj.ws .* obj.support;
            obj.int = abs(obj.w);
            obj.phase = angle(obj.w);
            %       obj.ws = obj.w .* obj.support;
            obj.start_density = obj.int;
            obj.ONESHOT = obj.WS;
            %       obj.oneshot = fftshift(ifft2(fftshift(obj.WS)));% .* obj.support;
            obj.oneshot = obj.w;
            %       figure(34866)
            %       imagesc(abs(obj.oneshot)-obj.start_density);
        end
        function obj = randphase(obj)
            obj.PHASE = (rand(obj.imgsize)-.5)*2*pi;
        end
        
        %%%%%%%%%% RECONSTRUCTION %%%%%%%%%%
        %%%%%%%%%% RECONSTRUCTION %%%%%%%%%%
        %%%%%%%%%% RECONSTRUCTION %%%%%%%%%%
        function obj = iterate(obj, nsteps, method)
            for i=1:nsteps
                obj.W = ifftshift(fft2(fftshift(obj.w)));
                if obj.masking.constraint_RMask
                    obj.smoothRMask = imgaussfilt((1-obj.RMASK), obj.masking.RMASK_smoothPix);
                    obj.W = obj.W .* obj.smoothRMask;
                end
                
                %%%%% code from before 15.07.2020 %%%%%
                %         obj.INT = abs(obj.W);
                %         obj.PHASE = angle(obj.W);
                % %         obj.WS = ( obj.INT .* (1-obj.MASK) ) + ( obj.SCATT.*exp(1i*obj.PHASE) .* obj.MASK );
                %         SCATT_REP = iif(obj.constraint_mixScatt, (obj.SCATT * obj.mixScatt + obj.INT * (1-obj.mixScatt)), obj.SCATT);
                %         obj.WS = ( obj.INT .* (1-obj.MASK) ) + (SCATT_REP.*exp(1i*obj.PHASE) .* obj.MASK );
                %
                %         obj.WS = abs(obj.WS) .* exp(1i * obj.PHASE);
                % %         obj.WS = obj.W; obj.WS(obj.MASK>0) = abs(obj.SCATT(obj.MASK>0)).*angle(obj.W(obj.MASK>0));
                % %         obj.WS = obj.W; obj.WS(obj.MASK>0) = obj.WS(obj.MASK>0)./abs(obj.WS(obj.MASK>0)).*obj.SCATT(obj.MASK>0);
                %         %         obj.WS = obj.W .* (1-obj.MASK) + obj.SCATT.*obj.W./abs(obj.W) .* obj.MASK;
                % %         obj.WS = obj.WS .* ~obj.RMASK;
                %         obj.w_old = obj.ws;
                %         obj.int_old = abs(obj.w_old);
                %         obj.w = fftshift(ifft2(ifftshift(obj.WS), iif(obj.constraint_symmetry,'symmetric','nonsymmetric')));
                %         obj.int = abs(obj.w);
                %         obj.phase = angle(obj.w);
                % %         obj.w = abs(obj.w);
                %%%%% /code from before 15.07.2020 %%%%%
                
                %%%%% new code from 15.07.2020 %%%%%
                obj.INT = abs(obj.W);
                obj.PHASE = angle(obj.W);
                obj.WS = ( (obj.INT .* (1-obj.MASK)) + (obj.SCATT.*obj.MASK) ) .* exp(1i*obj.PHASE);
                obj.ws = fftshift(ifft2(fftshift(obj.WS)));
                
                obj.constraints(method);
                %         obj.ws = obj.ws/sum(abs(obj.ws(:)).^2)*sum(abs(obj.w(:)).^2);
                %         obj.ws = obj.ws .* exp(1i*obj.phase);
                obj.calcerr;
                obj.ntotal = obj.ntotal+1;
                if mod(obj.ntotal,1000) == 0
                    obj.plotfun;
                end
            end
        end
        function obj = constraints(obj, method)
            if obj.constraint_real; obj.ws = real(obj.ws); end
            if obj.constraint_pos; obj.constraintViolated = double(obj.ws<0); end
            if obj.constraint_posImag; obj.ws = real(obj.ws) + 1i*imag(obj.ws) .* double(imag(obj.ws)>0); end
            obj.constraintViolated = double( ( obj.constraintViolated + (1-obj.support) ) > 0);
            
            switch method
                case 'dcdi'
                    obj.norm_density;
                    obj.ws = obj.ws .* obj.support;
                    obj.w = obj.ws .* double( real(obj.ws)>obj.density*obj.delta );
                    obj.w = obj.w + obj.density .* double( (real(obj.ws)<=obj.density*obj.delta) );
                    obj.w( angle( (obj.ws - obj.density) ) < obj.phaseMin ) = obj.density( angle( (obj.ws - obj.density) ) < obj.phaseMin );
                    
                    % % %           obj.norm_density;
                    % % %           obj.ws = obj.w;
                    % % %           obj.ws(obj.support==0) = 0;
                    % % %           obj.ws(real(obj.w) > obj.density*obj.delta) = ...
                    % % %             obj.w(real(obj.w) > obj.density*obj.delta);
                    % % %           obj.ws( real(obj.w) <= obj.density*obj.delta | angle(obj.w) < obj.phaseMin ) = ...
                    % % %             obj.w( real(obj.w) <= obj.density*obj.delta | angle(obj.w) < obj.phaseMin );
                    % % %
                    % % % %           obj.ws = obj.w .* (real(obj.w) > (obj.density + delta) ) + ...
                    % % % %             obj.density .* ( (real(obj.w) <= (obj.density + delta) ) || angle(obj.w)<phaseMin );
                    % % %           obj.ws(obj.support==0) = 0;
                case 'er'
                    obj.w = (1-obj.constraintViolated) .* obj.ws;
                    
                    % % %           obj.w = obj.ws .* obj.support;
                    % % % %           obj.ws(obj.support==0) = 0;
                    % % % %           obj.norm_density;
                case 'io'
                    % % % %           obj.ws = obj.w - ( obj.beta.*obj.w_old.*(1-obj.support) );
                    % % %           obj.ws = obj.int - ( obj.beta.*obj.int_old.*(1-obj.support) );
                    % % %           obj.phase = obj.phase .* obj.support;
                    % % %           obj.ws = obj.ws .* exp(1i*obj.phase);
                case 'hio'
                    obj.w = obj.constraintViolated .* (obj.w - obj.beta*obj.ws);
                    obj.w = (1-obj.constraintViolated) .* obj.ws;
                    %           figure(3434567);
                    %           imagesc((obj.constraintViolated));
                    %           drawnow;
                    % % % %           obj.ws = obj.w;
                    % % %           obj.ws = ( obj.w.*(obj.support)) + ( (obj.w_old - obj.beta.*obj.w).*((1-obj.support)) );
                    % % % %           obj.ws = ( obj.int .* (obj.support) ) + ( (obj.w_old - obj.beta.*obj.int).*((1-obj.support)) );
                    % % % %           obj.phase = obj.phase .* obj.support;
                    % % %           obj.ws = obj.ws .* exp(1i*obj.phase);
                    
                    
                case 'raar'
                    % % %           obj.ws = ( obj.int_old .* (obj.support) )...
                    % % %             + ( (obj.beta*obj.int - (1-2*obj.beta)*obj.int_old) .* ((1-obj.support)) );
                    % % %           obj.ws = obj.ws .* exp(1i*obj.phase);
                    % % %           % obj.ws = (1-obj.beta)*obj.w + obj.w .* obj.support + ( (1-2*obj.beta)*obj.w + obj.beta*obj.w_old ) .* (1-obj.support);
                    % % %           % obj.ws = obj.w .* (obj.support & obj.w>=0) + (obj.beta*obj.w_old - (1-2*obj.beta)*obj.w) .* ((1-obj.support) | obj.w<0);
            end
            %       if obj.constraint_real
            %         obj.ws = real(obj.ws);
            %       end
            %       if obj.constraint_posImag
            %         obj.ws = real(obj.ws) + 1i*imag(obj.ws) .* double(imag(obj.ws)>0);
            %       end
            %       obj.norm_density;
            %
            %       if obj.constraint_pos
            %         obj.w(abs(obj.w).*obj.support<0) = obj.density(abs(obj.w).*obj.support<0);
            %       end
            %       if obj.constraint_shape
            %         obj.ws((obj.ws * obj.delta) < obj.density) = obj.density( (obj.ws * obj.delta) < obj.density);
            %       end
        end
        function obj = realERstep(obj)
            obj.ws(obj.support==0) = 0;
        end
        function obj = halfSupport(obj)
            obj.ws(:,1:obj.imgsize(2)/2-1) = obj.ws(:,1:obj.imgsize(2)/2-1)*1.1;
            obj.ws(:,obj.imgsize(2)/2:end) = obj.ws(:,obj.imgsize(2)/2:end)*0.9;
        end
        function obj = norm_density(obj)
            %       obj.density = obj.density * nanmedian( real(obj.w(obj.support>0))./obj.density(obj.support>0) );
            rati = abs(obj.ws(obj.support>0))./obj.density(obj.support>0);
            obj.density = obj.density .* nanmedian( rati(~isnan(rati)) );
            %       obj.density = obj.density/nansum(obj.density(:))*nansum(abs(obj.w(:)))/2;
        end
        function obj = zeroborders(obj)
            obj.W = ifftshift(fft2(fftshift(obj.ws)));
            obj.INT = abs(obj.W);
            obj.PHASE = angle(obj.W);
            obj.WS = obj.W .* (1-obj.MASK) + obj.SCATT.*exp(1i*obj.PHASE) .* (obj.MASK);
            if obj.masking.constraint_RMask
                obj.smoothRMask = imgaussfilt((1-obj.RMASK), obj.masking.RMASK_smoothPix);
                obj.WS = obj.WS .* obj.smoothRMask;
            end
            obj.w_old = obj.ws;
            obj.w = fftshift(ifft2(ifftshift(obj.WS), iif(obj.constraint_symmetry,'symmetric','nonsymmetric')));
            obj.int = abs(obj.w);
            obj.phase = angle(obj.w);
            obj.ws = (obj.w .* obj.support).*exp(1i*obj.phase);
            %       obj.constraints('dcdi');
            obj.plotfun;
        end
        function obj = calcerr(obj)
            %       errmat = sum(abs(abs(obj.W(obj.MASK>0))-obj.SCATT(obj.MASK>0))) / ...
            %         sum(abs(obj.SCATT(obj.MASK>0)));
            %       errmat(isinf(errmat)) = nan;
            %       if numel(obj.errFourier)<=obj.ntotal+1
            %         obj.errReal = [obj.errReal,nan(1,1000)];
            %         obj.errFourier = [obj.errFourier,nan(1,1000)];
            %       end
            %       obj.errFourier(obj.ntotal+1) = nansum(errmat(:));
            
            
            obj.errFourier(obj.ntotal+1) = sqrt(nansum( ( abs(obj.W(obj.MASK>0)) - abs(obj.SCATT(obj.MASK>0)) ).^2 ) ) ...
                / sqrt( nansum( abs(obj.SCATT(obj.MASK>0)).^2 ) );
            
            if obj.errFourier(obj.ntotal+1)<1e-10
                obj.errFourier(obj.ntotal+1) = nan;
            end
            obj.errReal(obj.ntotal+1) = nansum(abs( obj.int(obj.support==0) ).^2 )./...
                nansum(abs( obj.int(obj.support>0) ).^2 );
        end
        function obj = updatesupport(obj)
            nsup = abs(obj.w);
            nsup = double(nsup>.15*max(nsup(:)));
            nsup = imgaussfilt(nsup, 3);
            nsup = nsup>.15;
            %       obj.support = nsup>.1*max(nsup(:));
            obj.support = nsup;
        end
        function obj = updatebeta(obj)
            obj.beta = obj.beta0 + (1-obj.beta0)*(1-exp(-(obj.ntotal/500)^3));
        end
        
        %%%%%%%%%% PLOTTING %%%%%%%%%%
        %%%%%%%%%% PLOTTING %%%%%%%%%%
        %%%%%%%%%% PLOTTING %%%%%%%%%%
        function obj = plotfun(obj,~,~)
            if isempty(obj.fig)
                %         obj.fig.int = figure(20000001); clf
                obj.fig.rec = figure(20000002); clf
                obj.fig.rec.KeyPressFcn = obj.parentfig.KeyPressFcn;
                %         obj.fig.err = figure(20000003); clf
            end
            if isempty(obj.popup)
                obj.popup(1).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'popup', 'String', ...
                    {'imorgen', 'morgenstemning', 'wjet','r2b','r2b2','parula','jet','hsv','hot','cool','gray','igray','redmap','redmap2','bluemap','bluemap2','b2r','b2r2'},...
                    'Units', 'normalized', 'Position', [.57,.94,.05,.05], 'Callback', @ obj.setmap, 'Value', obj.int_cm);
                obj.popup(2).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'popup', 'String', ...
                    {'imorgen', 'morgenstemning', 'wjet','r2b','r2b2','parula','jet','hsv','hot','cool','gray','igray','redmap','redmap2','bluemap','bluemap2','b2r','b2r2'},...%%       {'imorgen', 'morgenstemning', 'wjet','r2b','parula','jet','hsv','hot','cool','gray','igray'},...
                    'Units', 'normalized', 'Position', [.92,.94,.05,.05], 'Callback', @ obj.setmap, 'Value', obj.rec_cm);
                obj.popup(3).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'popup', 'String', ...
                    {'', 'linear', 'semilogx', 'semilogy','loglog'}, 'value', 3,...
                    'Units', 'normalized', 'Position', [.23,.94,.05,.05], 'Callback', @ obj.setplt);
                obj.popup(4).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'popup', 'String', ...
                    {'autoscale','0:max(abs)','-max(abs):max(abs)','20%:100%','-max:max', '-pi:pi', '-pi/2:pi/2','-pi/4:pi/4','-pi/8:pi/8','-0.1:0.1'},'Value',obj.reconrange,...
                    'Units', 'normalized', 'Position', [.92,.88,.05,.05], 'Callback', @ obj.setrange);
                obj.popup(5).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'popup', 'String', ...
                    {'log10(abs(IMG).^2)','abs(IMG)','real(IMG)','imag(IMG)','angle(IMG)','log10(abs(real(IMG)))','sign(real(IMG))'},...
                    'Units', 'normalized', 'Position', [.57,.01,.05,.05], 'Callback', @ obj.plotfun);
                obj.popup(6).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'popup', 'String', ...
                    {'real','imag','abs','angle'},'Value',obj.reconpart,...
                    'Units', 'normalized', 'Position', [.92,.01,.05,.05], 'Callback', @ obj.plotfun);
                obj.popup(7).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'checkbox', 'String', ...
                    'substract ellipsoid', 'Value', gather(obj.substract_shape), ...
                    'Units', 'normalized', 'Position', [.92,.07,.05,.05], 'Callback', @ obj.plotfun);
                obj.popup(8).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'checkbox', 'String', ...
                    'normalize ellipsoid', 'Value', gather(obj.normalize_shape), ...
                    'Units', 'normalized', 'Position', [.92,.12,.05,.05], 'Callback', @ obj.plotfun);
            end
            if isempty(obj.edt)
                obj.edt(1).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'edit', 'String', num2str(obj.clims_scatt(1)),...
                    'Units', 'normalized', 'Position', [.57,.07,.025,.025], 'Callback', @ obj.plotfun);
                obj.edt(2).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'edit', 'String', num2str(obj.clims_scatt(2)),...
                    'Units', 'normalized', 'Position', [.6,.07,.025,.025], 'Callback', @ obj.plotfun);
                obj.edt(3).ctrl = uicontrol('parent', obj.fig.rec, 'Style', 'edit', 'String', num2str(obj.subscale),...
                    'Units', 'normalized', 'Position', [.92,.82,.025,.025], 'Callback', @ obj.plotfun);
                %         figure(obj.parentfig);
            end
            if isempty(obj.ax)
                %         obj.ax.int(1) = axes('parent', obj.fig.int, 'Units', 'normalized', 'Position', [.025 .525 .95 .425]);
                %         obj.ax.int(2) = axes('parent', obj.fig.int, 'Units', 'normalized', 'Position', [.025 .025 .95 .425]);
                %         obj.ax.rec(1) = axes('parent', obj.fig.rec, 'Units', 'normalized', 'Position', [.025 .525 .95 .425]);
                %         obj.ax.rec(2) = axes('parent', obj.fig.rec, 'Units', 'normalized', 'Position', [.025 .025 .95 .425]);
                %         obj.ax.err(1) = mysubplot(2,1,1, 'parent', obj.fig.err);
                %         obj.ax.err(2) = mysubplot(2,1,2, 'parent', obj.fig.err);
                obj.ax.err(1) = axes('parent', obj.fig.rec, 'Units', 'normalized', 'Position', [.025 .025 .25 .425]);
                obj.ax.err(2) = axes('parent', obj.fig.rec, 'Units', 'normalized', 'Position', [.025 .525 .25 .425]);
                obj.ax.int(1) = axes('parent', obj.fig.rec, 'Units', 'normalized', 'Position', [.27 .525 .33 .425]);
                obj.ax.int(2) = axes('parent', obj.fig.rec, 'Units', 'normalized', 'Position', [.27 .025 .33 .425]);
                obj.ax.rec(1) = axes('parent', obj.fig.rec, 'Units', 'normalized', 'Position', [.62 .525 .33 .425]);
                obj.ax.rec(2) = axes('parent', obj.fig.rec, 'Units', 'normalized', 'Position', [.62 .025 .33 .425]);
            end
            if isempty(obj.plt)
                obj.plt.err(1) = semilogy(obj.ax.err(1), (obj.errReal)); grid(obj.ax.err(1), 'on');
                obj.plt.err(2) = semilogy(obj.ax.err(2), (obj.errFourier), 'r'); grid(obj.ax.err(2), 'on');
                title(obj.ax.err(1), 'real space error');
                title(obj.ax.err(2), 'fourier space error');
                
                anglebound = atan([obj.yy(1),obj.yy(end)]*75e-6/0.37/obj.binfactor)/2/pi*360;
                obj.plt.int(1).img = imagesc((log10(abs(obj.INT).^2)), 'XData', anglebound,'YData', anglebound,...
                    'parent', obj.ax.int(1));
                colormap(obj.ax.int(1), obj.popup(1).ctrl.String{obj.popup(1).ctrl.Value}); grid(obj.ax.int(1), 'off');
                obj.plt.int(2).img = imagesc((log10(abs(obj.W).^2)), 'XData', anglebound,'YData', anglebound,...
                    'parent', obj.ax.int(2));
                colormap(obj.ax.int(2), obj.popup(1).ctrl.String{obj.popup(1).ctrl.Value}); grid(obj.ax.int(2), 'off');
                obj.plt.rec(1).img = imagesc((real(obj.w)), 'XData', [obj.xx(1),obj.xx(end)]*6,'YData', [obj.yy(1),obj.yy(end)]*6,...
                    'parent', obj.ax.rec(1));
                colormap(obj.ax.rec(1), obj.popup(2).ctrl.String{obj.popup(2).ctrl.Value}); grid(obj.ax.rec(1), 'off');
                obj.plt.rec(2).img = imagesc((real(obj.w .* obj.support)), 'XData', [obj.xx(1),obj.xx(end)]*6,'YData', [obj.yy(1),obj.yy(end)]*6,...
                    'parent', obj.ax.rec(2));
                colormap(obj.ax.rec(2), obj.popup(2).ctrl.String{obj.popup(2).ctrl.Value}); grid(obj.ax.rec(2), 'off');
                
                obj.ax.err(1).Position = [.025 .025 .25 .425];
                obj.ax.err(2).Position = [.025 .525 .25 .425];
                obj.ax.int(1).Position = [.27 .525 .33 .425];
                obj.ax.int(2).Position = [.27 .025 .33 .425];
                obj.ax.rec(1).Position = [.62 .525 .33 .425];
                obj.ax.rec(2).Position = [.62 .025 .33 .425];
                
                obj.plt.int(1).title = title(obj.ax.int(1), sprintf('reconstructed - %i steps', obj.ntotal));
                obj.plt.int(2).title = title(obj.ax.int(2), 'measured');
                obj.plt.rec(1).title = title(obj.ax.rec(1), 'before constraints');
                obj.plt.rec(2).title = title(obj.ax.rec(2), 'after constraints');
                
                obj.ax.int(1).YLabel.String = 'scattering angle';
                obj.ax.int(2).YLabel.String = 'scattering angle';
                obj.ax.rec(1).YLabel.String = 'nanometers';
                obj.ax.rec(2).YLabel.String = 'nanometers';
                arrayfun(@(a) colorbar(a), [obj.ax.rec]);
                arrayfun(@(a) colorbar(a), [obj.ax.int]);
                arrayfun(@(a) axis(a, 'image'), [obj.ax.int, obj.ax.rec]);
                vf = gather([-1,1]*1.5*abs(obj.support_radius)*6);
                arrayfun(@(a) set(a, 'XLim', vf, 'YLim', vf), [obj.ax.rec]);
            end
            obj.plt.err(1).YData = gather(abs(obj.errReal));
            obj.plt.err(2).YData = gather(abs(obj.errFourier));
            axis(obj.ax.err(1), 'tight');
            axis(obj.ax.err(2), 'tight');
            
            measuredSCATT = ( (obj.INT .* (1-obj.MASK)) + (obj.SCATT .* obj.MASK) ) .* exp(1i*obj.PHASE);
            obj.plt.int(1).img.CData = gather(eval(strrep(obj.popup(5).ctrl.String{obj.popup(5).ctrl.Value},'IMG','obj.W')));
            obj.plt.int(2).img.CData = gather(eval(strrep(obj.popup(5).ctrl.String{obj.popup(5).ctrl.Value},'IMG','measuredSCATT')));
            
            %       rel = gather(obj.int./obj.density);
            %       scl = nanmedian(rel(~isnan(rel) & ~isinf(rel) & obj.support));
            %       obj.density = obj.density * gpuArray(scl);
            %       obj.density(isinf(obj.density)) = nan;
            
            %       obj.density = obj.density .* nanmedian( abs(obj.w(obj.support>0))./obj.density(obj.support>0) );
            obj.subscale = str2double(obj.edt(3).ctrl.String);
            
            if obj.popup(8).ctrl.Value
                obj.plt.rec(1).img.CData = gather(eval([obj.popup(6).ctrl.String{obj.popup(6).ctrl.Value}, '(obj.w./obj.density)']));
                obj.plt.rec(2).img.CData = gather(eval([obj.popup(6).ctrl.String{obj.popup(6).ctrl.Value}, '(obj.ws./obj.density)']));
            else
                if obj.popup(7).ctrl.Value
                    obj.plt.rec(1).img.CData = gather(eval([obj.popup(6).ctrl.String{obj.popup(6).ctrl.Value}, '( obj.w ) - (obj.density .* obj.subscale) ']));
                    obj.plt.rec(2).img.CData = gather(obj.support .* eval([obj.popup(6).ctrl.String{obj.popup(6).ctrl.Value}, '( obj.ws ) - (obj.density .* obj.subscale)']));
                else
                    obj.plt.rec(1).img.CData = gather(eval([obj.popup(6).ctrl.String{obj.popup(6).ctrl.Value}, '(obj.w)']));
                    obj.plt.rec(2).img.CData = gather(eval([obj.popup(6).ctrl.String{obj.popup(6).ctrl.Value}, '(obj.ws)']));
                end
            end
            obj.setrange;
            obj.plt.int(1).title.String = sprintf('reconstructed - %i steps', obj.ntotal);
            obj.plt.rec(1).title.String = sprintf('before constraints - %i steps', obj.ntotal);
            drawnow;
        end
        function obj = plotFinalResult(obj, ~,~)
            %       obj.densityThreshold = 1.1;
            ncols = 256;
            colth = ncols/2*obj.densityThreshold;
            final.ws = real(obj.ws);
            final.ws = ( (final.ws / max(final.ws(:))*(ncols/2) + ncols/2) .* (obj.ws > (obj.density*obj.densityThreshold) ) ) + ...
                ( obj.density / max(obj.density(:)) * (ncols/2) .* (obj.ws <= (obj.density*obj.densityThreshold) ) );
            r = real( (obj.ws-obj.density) .* double(obj.ws > (obj.density*obj.densityThreshold) ) );
            g = zeros(size(obj.ws));
            b = real( obj.density );
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
        end
        
        %%%%%%%%%% UTLIS %%%%%%%%%%
        %%%%%%%%%% UTLIS %%%%%%%%%%
        %%%%%%%%%% UTLIS %%%%%%%%%%
        function obj = gpufun(obj)
            fields = fieldnames(obj);
            for f=1:numel(fields)
                if ~strcmp('fig', (fields{f})) ...
                        && ~strcmp('popup', (fields{f}))...
                        && ~strcmp('plt', (fields{f}))...
                        && ~strcmp('ax', (fields{f})) ...
                        && ~strcmp('edt', (fields{f})) ...
                        && ~strcmp('clims_scatt', (fields{f})) ...
                        && ~strcmp('reconpart', (fields{f})) ...
                        && ~strcmp('reconrange', (fields{f})) ...
                        && ~strcmp('rec_cm', (fields{f})) ...
                        && ~strcmp('int_cm', (fields{f}))
                    %           if ismember((fields{f}), {'w','w_old','ws','W','WS'}) || islogical(obj.(fields{f}))
                    %             obj.(fields{f}) = gpuArray((obj.(fields{f})));
                    %             continue
                    %           end
                    if isfloat(obj.(fields{f})) || islogical(obj.(fields{f}))
                        %                         disp((fields{f}))
                        obj.(fields{f}) = gpuArray((obj.(fields{f})));
                    end
                    %           if islogical(obj.(fields{f}))
                    %             obj.(fields{f}) = gpuArray((obj.(fields{f})));
                    %           end
                end
            end
        end
        function obj = calcOSR(obj)
            Nknown = sum(obj.MASK(:)) + 2*sum(~obj.support(:));
            Nunknown = size(obj.INT,1)*size(obj.INT,2) + sum(~obj.MASK(:)) + 2*sum(obj.support(:));
            obj.OSR = Nknown/Nunknown;
            fprintf('over sampling ratio = %.1f\n', obj.OSR);
        end
        function obj = setmap(obj,~,~)
            newmap = obj.popup(1).ctrl.String{obj.popup(1).ctrl.Value};
            colormap(obj.ax.int(1), newmap);
            colormap(obj.ax.int(2), newmap);
            newmap = obj.popup(2).ctrl.String{obj.popup(2).ctrl.Value};
            colormap(obj.ax.rec(1), newmap);
            colormap(obj.ax.rec(2), newmap);
            drawnow;
        end
        function obj = setplt(obj,evt,~)
            switch evt.Value
                case 1
                case 2
                    set(obj.ax.err(1),'XScale','linear','YScale','linear');
                    set(obj.ax.err(2),'XScale','linear','YScale','linear');
                case 3
                    set(obj.ax.err(1),'XScale','log','YScale','linear');
                    set(obj.ax.err(2),'XScale','log','YScale','linear');
                case 4
                    set(obj.ax.err(1),'XScale','linear','YScale','log');
                    set(obj.ax.err(2),'XScale','linear','YScale','log');
                case 5
                    set(obj.ax.err(1),'XScale','log','YScale','log');
                    set(obj.ax.err(2),'XScale','log','YScale','log');
            end
        end
        function obj = setrange(obj,~,~)
            sc1 = str2double(obj.edt(1).ctrl.String);
            sc2 = str2double(obj.edt(2).ctrl.String);
            if isnan(sc1) || isnan(sc2) || sc1==sc2
                caxis(obj.ax.int(1), 'auto');
                caxis(obj.ax.int(2), 'auto');
            else
                obj.ax.int(1).CLim = [sc1,sc2];
                obj.ax.int(2).CLim = [sc1,sc2];
            end
            if obj.popup(8).ctrl.Value
                obj.ax.rec(1).CLim = 1+[-1,1]*0.05;
                obj.ax.rec(2).CLim = 1+[-1,1]*0.05;
            else
                if max(abs(obj.plt.rec(1).img.CData(:))) > 0
                    switch obj.popup(4).ctrl.Value
                        case 1
                            obj.ax.rec(1).CLim=[min(obj.plt.rec(1).img.CData(:)),max(obj.plt.rec(1).img.CData(:))];
                        case 2
                            obj.ax.rec(1).CLim=[0,max(obj.plt.rec(1).img.CData(:))];
                        case 3
                            obj.ax.rec(1).CLim = [-1,1]*max(abs(obj.plt.rec(1).img.CData(:)));
                        case 4
                            obj.ax.rec(1).CLim = [0.2,1]*max(abs(obj.plt.rec(1).img.CData(:)));
                        case 5
                            if max((obj.plt.rec(2).img.CData(:))) > 0
                                obj.ax.rec(1).CLim = [-1,1]*max((obj.plt.rec(1).img.CData(:)));
                            end
                        case 6
                            obj.ax.rec(1).CLim = [-1,1]*pi;
                        case 7
                            obj.ax.rec(1).CLim = [-1,1]*pi/2;
                        case 8
                            obj.ax.rec(1).CLim = [-1,1]*pi/4;
                        case 9
                            obj.ax.rec(1).CLim = [-1,1]*pi/8;
                        case 10
                            obj.ax.rec(1).CLim = [-1,1]*0.1;
                    end
                end
                if max(abs(obj.plt.rec(2).img.CData(:))) > 0
                    switch obj.popup(4).ctrl.Value
                        case 1
                            obj.ax.rec(2).CLim=[min(obj.plt.rec(2).img.CData(:)),max(obj.plt.rec(2).img.CData(:))];
                        case 2
                            obj.ax.rec(2).CLim=[0,max(obj.plt.rec(2).img.CData(:))];
                        case 3
                            obj.ax.rec(2).CLim = [-1,1]*max(abs(obj.plt.rec(2).img.CData(:)));
                        case 4
                            obj.ax.rec(2).CLim = [0.2,1]*max(abs(obj.plt.rec(2).img.CData(:)));
                        case 5
                            if max((obj.plt.rec(2).img.CData(:))) > 0
                                obj.ax.rec(2).CLim = [-1,1]*max((obj.plt.rec(2).img.CData(:)));
                            end
                        case 6
                            obj.ax.rec(2).CLim = [-1,1]*pi;
                        case 7
                            obj.ax.rec(2).CLim = [-1,1]*pi/2;
                        case 8
                            obj.ax.rec(2).CLim = [-1,1]*pi/4;
                        case 9
                            obj.ax.rec(2).CLim = [-1,1]*pi/8;
                        case 10
                            obj.ax.rec(2).CLim = [-1,1]*0.1;
                    end
                end
            end
        end
    end
end





