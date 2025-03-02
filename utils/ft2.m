function data = ft2(data, symmetricNorm)

	data = fftshift(fft2(fftshift(data)));

    % symmetrisize norm
    if exist('symmetricNorm','var')
        if symmetricNorm
            data = data / sqrt(numel(data));
        end
    else
        data = data / sqrt(numel(data));
    end
end
