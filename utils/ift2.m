function data=ift2(data)

    data = ifftshift(ifft2(ifftshift(data)));
    % symmetrisize norm
    data = data * sqrt(numel(data));
    
end