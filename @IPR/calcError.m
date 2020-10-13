function obj = calcError(obj)
    %% Real Space
    obj.errors(1,obj.nTotal) = norm( obj.ws.*(obj.support==false), 'fro') / norm(obj.ws, 'fro');
    obj.errors(2,obj.nTotal) = norm( obj.ws.*(obj.support==false), 'fro') / norm(obj.ws.*(obj.support==true), 'fro');
    %% Fourier Space
    obj.errors(3,obj.nTotal) = norm( (abs(obj.W).^2-obj.AMP0.^2) .*obj.MASK, 'fro') / norm(obj.AMP0.^2.*obj.MASK, 'fro');
    obj.errors(4,obj.nTotal) = norm( ( abs(obj.W)-abs(obj.AMP0) ) .*obj.MASK, 'fro') / norm(obj.AMP0.*obj.MASK, 'fro');
    obj.errors(5,obj.nTotal) = norm( abs(obj.W-obj.AMP0) .*obj.MASK, 'fro') / norm(obj.AMP0.*obj.MASK, 'fro');
end
