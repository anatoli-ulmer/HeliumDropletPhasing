function p_matrix = polar_matrix(c_matrix,varargin)

% Wrote this on my own. Had no time to test it. Be careful with the
% quantitative data output. The effective pixel size is not taken into
% account. Also in the code the X and Y directions are switched.
% 
% You can choose the center of the picture with the optional parameters
% 'xcenter' and 'ycenter'.
% 
% (c) Anatoli Ulmer, 05.02.2016
% anatoli.ulmer@gmail.com

p_matrix=zeros(size(c_matrix));
[Ny,Nx]=size(c_matrix);
center=[Ny,Nx]/2+1;

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'xcenter', center(2) = varargin{ni+1};
            case 'ycenter', center(1) = varargin{ni+1};
        end
    end
end
tt = linspace(0,2*pi,Nx+1);
tt = tt(1:end-1);
[theta, rho]=meshgrid(tt,1:Ny);
% theta = theta(1:end-1);
[xx,yy]=pol2cart(theta(:),rho(:));

theta=round(theta/2/pi*Nx);
theta(theta<1)=1;

xx=round(xx+center(2));
yy=round(yy+center(1));

for i=1:numel(xx)
    if (1<=xx(i)) && (xx(i)<=Nx) && (1<=yy(i)) && (yy(i)<=Ny)
        p_matrix(theta(i),rho(i))=c_matrix(yy(i),xx(i));
    end
end
