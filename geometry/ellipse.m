function output = ellipse(a, b, rot, center, N)
    % returns BW image of an ellipse with half axes 'a' and 'b' rotated by
    % 'rot', centered around 'center' with N=[Ny,Nx] pixels.
    if ~exist('N', 'var'), N=[1024,1024]; end
    if ~exist('center', 'var'), center=[0,0]; end
    if isempty(center), center = [0,0]; end
    if numel(N)==1, N = [N,N]; end

    [xx,yy] = meshgrid((1:N(2))-center(2), (1:N(1))-center(1));
    xrot = xx*cos(rot) - yy*sin(rot);
    yrot = xx*sin(rot) + yy*cos(rot);
    output = (((xrot/a).^2 - (yrot/b).^2) < 1);
end