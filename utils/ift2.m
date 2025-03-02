function data = ift2(data, symmetricNorm)

	data = fftshift(ifft2(fftshift(data)));

    % symmetrisize norm
    if exist('symmetricNorm','var')
        if symmetricNorm
            data = data * sqrt(numel(data));
        end
    else
        data = data * sqrt(numel(data));
    end
end
