function errors = calcError(ws,rho,support,W,AMP0,MASK)
    %% Real Space
    errors(1,1) = norm( ws.*(support==false), 'fro') / norm(ws, 'fro');
    errors(2,1) = norm( ws.*(support==false), 'fro') / norm(ws.*(support==true), 'fro');
    %% Fourier Space
    errors(3,1) = norm( (abs(W).^2-AMP0.^2) .*MASK, 'fro') / norm(AMP0.^2.*MASK, 'fro');
    errors(4,1) = norm( ( abs(W)-abs(AMP0) ) .*MASK, 'fro') / norm(AMP0.*MASK, 'fro');
    errors(5,1) = norm( abs(W-AMP0) .*MASK, 'fro') / norm(AMP0.*MASK, 'fro');
end
