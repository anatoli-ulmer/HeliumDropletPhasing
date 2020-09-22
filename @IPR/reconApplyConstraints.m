function obj = reconApplyConstraints(obj, method)

    if obj.constraint_real
        obj.ws = real(obj.ws); 
    end
    if obj.constraint_pos 
        obj.support = obj.support .* (real(obj.ws)>=0); 
    end
    if obj.constraint_shape
        obj.support = obj.support .* ( real(obj.ws) > obj.rho + obj.delta ); 
    end
%     renormalize normalize on droplet density
%     rho = obj.alpha * obj.rho / norm(obj.rho, 'fro') * norm(abs(obj.ws).*support, 'fro');

    switch lower(method)
        case 'dcdi' % 4
            obj.w = obj.ws .* ( ( real(obj.ws) > (obj.rho + obj.delta) ) .* ( angle(obj.ws-obj.rho) >= obj.phaseMin ) )...
                + obj.rho .* ~( ( real(obj.ws) > (obj.rho + obj.delta) ) .* ( angle(obj.ws-obj.rho) >= obj.phaseMin ) );
            obj.w = obj.w.*obj.support;
        case 'er' % 5
            obj.w = obj.ws .* obj.support;
        case 'hpr' % 
            obj.w = (  obj.ws .* ( obj.support & ( obj.w <= obj.ws.*(1+obj.beta) ) )  )...
                + (  (obj.w - obj.beta*obj.ws) .* ~( obj.support & ( obj.w <= obj.ws.*(1+obj.beta) ) )  );
        case 'hio' % 6
            obj.w = ~obj.support.*(obj.w - obj.beta*obj.ws) + obj.support.* obj.ws;
        case 'mdcdi'
            obj.w = (obj.ws + obj.rho)/2;
            obj.w = obj.w.*obj.support;
        case 'ntdcdi'
%             obj.w = (obj.w - obj.beta*obj.ws).*(~obj.support);
%             obj.w = obj.w .* (abs(obj.ws)>obj.delta);
%             obj.w = obj.w + obj.ws .* obj.support;
            
            wI = obj.ws .* ( ( real(obj.ws) > (obj.rho + obj.delta) ) .* ( angle(obj.ws-obj.rho) >= obj.phaseMin ) )...
                + obj.rho .* ~( ( real(obj.ws) > (obj.rho + obj.delta) ) .* ( angle(obj.ws-obj.rho) >= obj.phaseMin ) );
            wI = wI.*obj.support;
            wO = (obj.w - obj.beta*obj.ws).*(~obj.support);
            wO = wO .* (abs(obj.ws)>obj.delta);
            obj.w = wO + wI;
            
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
