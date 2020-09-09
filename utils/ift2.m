function data=ift2(data)
    % Source: Felix Zimmermann, Bachelor Thesis, TU Berlin, 2016-2017
    % https://github.com/fzimmermann89/bsc
    
    % perform 2d iFT for even N with correct (and fast) shifting
    % Necessary because fftshift is extremly slow on gpuArrays
    
    N=size(data,1);
    %works for even and uneven
    %     index= mod((0:N-1)-double(rem(ceil(N/2),N)), N)+1;
    %works for even only
    index = mod((0:N-1)-N/2,N)+1;
    data = data(index,index);
    data = ifft2(data);
    data = data(index,index);

%     % the simple and slower version. 
%     % USE THIS IF THE METHOD ABOVE DOES NOT WORK!
%     data = fftshift(ifft2(fftshift(data)));

    % symmetrisize norm
    data = data * sqrt(numel(data));
end