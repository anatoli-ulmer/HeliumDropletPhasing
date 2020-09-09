function r = ellipse_fitfcn(phi, a, b, rot)

% e = a^2 - b^2;
% r = b^2./( a+e*cos(phi) );

r = sqrt(cos(phi + rot).^2/a^2 + sin(phi + rot).^2/b^2).^-1;