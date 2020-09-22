function output = sphereProjection(radius, shift, N)

    if nargin<3
        N=[1024,1024];
        if nargin<2
            shift=[0,0];
        end
    end
    if numel(N)==1
        N = [N,N];
    end
    
    [X,Y]=meshgrid(-N(2)/2:N(2)/2-1,-N(1)/2:N(1)/2-1);
    output=2*sqrt((radius^2-(X-shift(2)).^2-(Y-shift(1)).^2));
    output=output.*((X-shift(2)).^2+(Y-shift(1)).^2<radius^2);
end
