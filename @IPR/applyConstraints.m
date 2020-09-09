function obj = applyConstraints(obj, method)
    
    obj.support = (obj.support0>0);

    if obj.constraint_real
        obj.ws = real(obj.ws); 
    end
    if obj.constraint_pos 
        obj.support = obj.support .* (real(obj.ws)>=0); 
    end
    if obj.constraint_shape
        obj.support = obj.support .* ( real(obj.ws) > obj.rho + obj.delta ); 
    end

%     obj.rho = normalizeDensity(obj.ws, obj.support, obj.rho, obj.alpha);

    switch lower(method)
        case 'dcdi' % 4
            obj.w = obj.ws .* ( ( real(obj.ws) > (obj.rho + obj.delta) ) .* ( angle(obj.ws-obj.rho) >= obj.phaseMin ) )...
                + obj.rho .* ~( ( real(obj.ws) > (obj.rho + obj.delta) ) .* ( angle(obj.ws-obj.rho) >= obj.phaseMin ) );
            obj.w = obj.w.*obj.support0;
        case 'er' % 5
            obj.w = obj.ws .* obj.support;
        case 'hpr' % 
            obj.w = (  obj.ws .* ( obj.support & ( obj.w <= obj.ws.*(1+obj.beta) ) )  )...
                + (  (obj.w - obj.beta*obj.ws) .* ~( obj.support & ( obj.w <= obj.ws.*(1+obj.beta) ) )  );
        case 'hio' % 6
            obj.w = ~obj.support.*(obj.w - obj.beta*obj.ws) + obj.support.* obj.ws;
        case 'nthio' % 7
            obj.w = (obj.w - obj.beta*obj.ws).*(~obj.support);
            obj.w = obj.w .* (abs(obj.ws)>obj.delta);
            obj.w = obj.w + obj.ws .* obj.support;
        case 'raar' % 8
%             obj.w = 
            tmp = obj.beta * (obj.w.*obj.support - obj.w);
            obj.w = 2*obj.beta.*obj.support.*obj.ws;
            obj.w = obj.w + (1-2*obj.beta)*obj.ws;
            obj.w = obj.w + tmp;
%             ( -obj.w .*  + obj.ws .* (1-2*obj.beta) ).*(~obj.support);
%             obj.w = ~obj.support.*(obj.beta*obj.w - (1-2*obj.beta)*obj.ws);
            obj.w = obj.w + obj.support.*obj.ws;
    end
end