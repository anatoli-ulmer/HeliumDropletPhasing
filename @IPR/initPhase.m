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
    
    obj.rho0 = obj.rho0 / norm(obj.rho0, 'fro');
    obj.W = ft2(gpuArray(complex(single(obj.rho0))));
    obj.PHASE = angle(obj.W).*(~obj.random_phase)  ...
        + (2*pi*rand(obj.imgsize)-pi)*obj.random_phase;
    % normalize on integral in masked area
    obj.W = obj.W * norm(obj.AMP0.*obj.MASK, 'fro') ...
        / norm(abs(obj.W).*obj.MASK, 'fro');
    obj.AMP = abs(obj.W);
    obj.WS = ( obj.AMP0.*obj.MASK + obj.AMP.*(~obj.MASK) ) .* exp(1i*obj.PHASE);

    obj.ws = ift2(obj.WS);
    obj.w = obj.ws .* obj.support0;
    obj.amp = abs(obj.w);
    obj.phase = angle(obj.w);
    
    obj.rho0 = obj.rho0 / norm(obj.rho0, 'fro') * norm(obj.amp, 'fro');
    obj.rho = obj.rho0 * obj.alpha;
    obj.delta = obj.deltaFactor * obj.noise;
    
    fprintf('\tbin factor = %.3g\n', obj.binFactor)
    fprintf('\talpha = %.3g\n', obj.alpha)
    fprintf('\tnoise = %.3g\n', obj.noise)
    fprintf('\tdelta = %.3g\n', obj.delta)
    
    obj.oneshot = obj.w;
    obj.ONESHOT = obj.WS;
end