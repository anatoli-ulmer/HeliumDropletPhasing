function errors = calcError(ws,rho,support,W,AMP0,MASK)
    %% Real Space
    errors(1,1) = norm( ws.*(support==false), 'fro') / norm(ws, 'fro');
    errors(2,1) = norm( ws.*(support==false), 'fro') / norm(ws.*(support==true), 'fro');
    %% Fourier Space
    errors(3,1) = norm( (abs(W).^2-AMP0.^2) .*MASK, 'fro') / norm(AMP0.^2.*MASK, 'fro');
    errors(4,1) = norm( ( abs(W)-abs(AMP0) ) .*MASK, 'fro') / norm(AMP0.*MASK, 'fro');
    errors(5,1) = norm( abs(W-AMP0) .*MASK, 'fro') / norm(AMP0.*MASK, 'fro');

%         %% Real Space
%     errors(1,1) = sqrt(sum(sum(abs(  ws.*(support==false)  ).^2))) / sqrt(sum(sum(abs(  ws  ).^2)));
%     errors(2,1) = sqrt(sum(sum(abs(  ws.*(support==false)  ).^2))) / sqrt(sum(sum(abs(  ws.*(support==true)  ).^2)));
%     %% Fourier Space
%     errors(3,1) = sqrt(sum(sum(abs(  ( abs(W(:)).^2-AMP0(:).^2 ) .*MASK(:)  ).^2))) / sqrt(sum(sum(abs(  AMP0(:).^2.*MASK(:)  ).^2)));
%     errors(4,1) = sqrt(sum(sum(abs(  ( abs(W(:))-abs(AMP0(:)) ) .*MASK(:)  ).^2))) / sqrt(sum(sum(abs(  AMP0(:).*MASK(:)  ).^2)));
%     errors(5,1) = sqrt(sum(sum(abs(  abs(W-AMP0) .*MASK  ).^2))) / sqrt(sum(sum(abs(  AMP0.*MASK  ).^2)));
    
    
    %% Metrics from Huang et al., 6 December 2010 / Vol. 18, No. 25 / OPTICS EXPRESS 26441
%     errors(5,1) = norm((ws-rho), 'fro') / norm((ws+rho), 'fro');
%     AMPMean = nanmean(AMP.*MASK);
%     AMP0Mean = nanmean(AMP0.*MASK);
%     errors(5,1) = nanmean2( (AMP.*MASK - AMPMean) .* (AMP0.*MASK - AMP0Mean) )...
%         /sqrt( nanmean2(AMP.*MASK - AMPMean).^2 * nanmean2(AMP0.*MASK - AMPMean).^2 );
end
