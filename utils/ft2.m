function data=ft2(data)

    data = fftshift(fft2(fftshift(data)));
    % symmetrisize norm
    data = data / sqrt(numel(data));
    
end