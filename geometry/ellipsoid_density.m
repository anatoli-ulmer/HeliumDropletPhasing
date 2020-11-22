function [density, support] = ellipsoid_density(a, b, c, rot, center, N)

% ELLIPSOID_DENSITY
% 
% (x/a)^2 + (y/b)^2 + (z/c)^2 = 1
%
% el = ellipsoid_density(a, b, c)
%       Gives the projection of a ellipsoid with onto the x,y - plane in
%       the center of a 1024x1024 grid.
% el = ellipsoid_density(a, b, c, shift)
%       Gives the projection of a ellipsoid with onto the x,y - plane with
%       the center shifted by shift of a 1024x1024 grid.
% el = ellipsoid_density(a, b, c, shift, N)
%       Gives the projection of a ellipsoid with onto the x,y - plane with
%       the center shifted by shift of a NxN, or N(1)xN(2) grid.
%

    if ~exist('N', 'var')
        N=[1024,1024];
    end
    if numel(N)==1
        N = [N,N];
    end
    if ~exist('center', 'var')
        center = N/2+1;
    end
    if isempty(center)
        center = N/2+1;
    end
    if isempty(c)
        c = (a+b)/2;
    end

    [xx,yy] = meshgrid((1:N(2))-center(2), (1:N(1))-center(1));
    xrot = xx*cos(rot) - yy*sin(rot);
    yrot = xx*sin(rot) + yy*cos(rot);
    density = 2*c*sqrt( 1 - ((xrot)/a).^2 - ((yrot)/b).^2);
    density = real( density.* ( ((xrot/a).^2 + (yrot/b).^2) <= 1 ) );
    support = density>0;
end
