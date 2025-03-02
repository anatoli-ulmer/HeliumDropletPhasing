function varargout = ellipse_outline(a, b, rot, center, Npts)

% ELLIPSE_OUTLINE
% 
% returns data of an ellipse outline in 'el' with half axes 'a' and 'b',
% rotated by 'rot', centered around 'center' with 'Npts' points.

    if ~exist('rot', 'var'); rot = 0; end
    if ~exist('center', 'var'); center = [0,0]; end
    if ~exist('Npts', 'var'); Npts = 100; end

    t=linspace(-pi,pi,Npts);
    x=center(2)+a*cos(t);
    y=center(1)+b*sin(t);

    el.x = x*cos(rot) - y*sin(rot);
    el.y = x*sin(rot) + y*cos(rot);
    
    if nargout==1
        varargout{1} = el;
    else
        varargout{1} = el.x;
        varargout{2} = el.y;
    end
end
