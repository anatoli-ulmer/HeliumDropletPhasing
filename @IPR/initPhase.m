function obj = initPhase(obj)
    if isempty(obj.rho0)
        if isempty(obj.support0)
            obj.support0 = single( (obj.xx).^2 + (obj.yy).^2 < obj.support_radius.^2);
            fprintf('generating support from radius\n');
        end
        obj.rho0 = 2*sqrt((obj.support_radius^2-(obj.xx).^2-(obj.yy).^2));
        obj.rho0 = obj.rho0.*obj.support0;
        obj.rho0 = obj.rho0/norm(obj.rho0, 'fro');
    end

    %% print parameters
    fprintf('\tbinning factor = %.3g\n', obj.binFactor)
    %     fprintf('\tpadding factor = %.3g\n', obj.padFactor)
    fprintf('\talpha = '); cprintf([.0,.5,.0], '%.3g\n', obj.alpha);
    fprintf('\tnoise = %.3g\n', obj.noise)
    fprintf('\tdelta = '); cprintf('blue', '%.2g', obj.deltaFactor); cprintf([0 0 0], ' * noise = '); cprintf([.8,.3,.14], '%.3g\n', obj.noise*obj.deltaFactor)

    %% set delta
    if obj.constraints.manualDelta
        fprintf('\tmanual delta set to '); cprintf([1,.5,0], '%.3g!\n', obj.delta0)
        obj.delta = obj.delta0;
    else
        obj.delta = obj.deltaFactor * obj.noise;
        if obj.constraints.maxDelta>0 && obj.delta>obj.constraints.maxDelta
            obj.delta = obj.constraints.maxDelta;
            fprintf('\tdelta cut off at maximum to '); cprintf([1,.5,0], '%.3g!\n', obj.delta)
        end
        if obj.constraints.minDelta>0 && obj.delta<obj.constraints.minDelta
            obj.delta = obj.constraints.minDelta;
            fprintf('\tdelta cut off at minimum to '); cprintf([1,.5,0], '%.3g!\n', obj.delta)
        end
    end

    
%     mu = 2*pi/1.2398e-9 * 6e-9 * obj.rho0 * 8.424e-8;
%     phi = 2*pi/1.2398e-9 * 6e-9 * obj.rho0 * 3.028e-5;
%     T = exp(-mu-1i*phi);
%     obj.rho0 = 1-T;

%     figure(34355);tiledlayout('flow');
%     nexttile; imagesc(mu); colorbar;
%     nexttile; imagesc(phi); colorbar;
%     nexttile; imagesc(abs(A)); colorbar;
%     nexttile; imagesc(-angle(T)); colorbar;

    obj.rho0 = abs(obj.rho0);
%     obj.rho0 = 1i*abs(obj.rho0);
%     obj.rho0 = obj.rho0*8.424e-8 + 1i*obj.rho0*3.028e-5;
%     obj.rho0 =  - obj.support_radius*6/1.24*2*pi*(obj.rho0*8.424e-8 + 1i*obj.rho0*3.028e-5);


    obj.rho0 = obj.rho0 / norm(abs(obj.rho0), 'fro');
    
    obj.W = ft2((complex(single(obj.rho0))));
    obj.PHASE = angle(obj.W).*(~obj.random_phase)  ...
        + (2*pi*rand(obj.imgsize)-pi)*obj.random_phase;

    %%% HEIKEL
    normDroplet = norm(abs(obj.W).*obj.MASK, 'fro');
    normData = norm(obj.AMP0.*obj.MASK, 'fro');
    obj.rho0 = obj.rho0 / normDroplet * normData;
    obj.rho = obj.rho0 * obj.alpha;
%     obj.rho = obj.rho0;
    obj.W = ft2((complex(single(obj.rho))));
    obj.PHASE = angle(obj.W).*(~obj.random_phase)  ...
        + (2*pi*rand(obj.imgsize)-pi)*obj.random_phase;
    %%%%

%     % normalize on integral in masked area
%     obj.W = obj.W * norm(obj.AMP0.*obj.MASK, 'fro') ...
%         / norm(abs(obj.W).*obj.MASK, 'fro');
    
    obj.AMP = abs(obj.W);
    obj.WS = ( obj.AMP0.*obj.MASK + obj.AMP.*(~obj.MASK) ) .* exp(1i*obj.PHASE);

    obj.ws = ift2(obj.WS);
    obj.w = obj.ws .* obj.support0;
    if obj.constraints.initWithPosReal
        obj.w(real(obj.w)<0) = obj.rho(real(obj.w)<0);
    end
    if obj.constraints.initWithPosImag
        obj.w(imag(obj.w)<0) = obj.rho(imag(obj.w)<0);
    end

    if obj.constraints.normalizeToSubNoise
        normArea = abs(obj.w-obj.rho)<obj.delta & ~imdilate(~obj.support0, strel('disk',2));
%         figure(338882); imgSize = size(normArea); imgCenter = imgSize/2+1; imagesc(normArea); xlim(obj.support_radius*[-1,1]*1.5+imgCenter); ylim(obj.support_radius*[-1,1]*1.5+imgCenter);
        newAlpha = norm(abs(obj.w(normArea)), 'fro')/norm(abs(obj.rho0(normArea)), 'fro');
        fprintf('\tnormalized with calculated alpha = %.2f', newAlpha)
        obj.rho0 = obj.rho0 * newAlpha;
        obj.rho = obj.rho0;
    end
    
%     obj.w = -1i*(1i*obj.w + circshift(1i*obj.w.', [0 0]))/2;
%     nPixel = size(obj.w);
%     obj.w = obj.w - circshift(obj.w(end:-1:1,end:-1:1), [1 1]);
    
    obj.amp = abs(obj.w);
    obj.phase = angle(obj.w);
    
%     obj.rho0 = obj.rho0 / norm(abs(obj.rho0), 'fro') * norm(obj.amp, 'fro');
%     obj.rho = obj.rho0 * obj.alpha;
    
    
    if ~isempty(obj.simScene)
        obj.simScene = obj.simScene / norm(obj.simScene, 'fro') * norm(obj.amp, 'fro');
        obj.simSceneFlipped = obj.simSceneFlipped / norm(obj.simSceneFlipped, 'fro') * norm(obj.amp, 'fro');
    end
   
    
    obj.oneshot = obj.w;
    obj.ONESHOT = obj.WS;
end
