function data = getReconstructionPart(data, part)
    switch part
        case 'real', data=real(data);
        case 'imag', data=imag(data);
        case 'abs', data=abs(data);
        case 'angle', data=angle(data);
    end
end
