function IMG = getScatteringPart(IMG, part)
    switch part
        case 1, IMG=abs(IMG).^2;
        case 2, IMG=abs(IMG);
        case 3, IMG=real(IMG);
        case 4, IMG=imag(IMG);
        case 5, IMG=angle(IMG);
        case 6, IMG=abs(real(IMG));
        case 7, IMG=sign(real(IMG));
    end
end
