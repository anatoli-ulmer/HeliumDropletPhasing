function OSR = calcOverSamplingRatio(MASK, support)

    Nknown = sum(MASK(:)) + 2*sum(~support(:));
    Nunknown = numel(MASK(:)) + sum(~MASK(:)) + 2*sum(support(:));
    OSR = Nknown/Nunknown;
    fprintf('\tover sampling ratio = %.1f\n', OSR);

end