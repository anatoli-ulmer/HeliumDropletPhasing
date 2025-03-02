function OSR = calcOverSamplingRatio(MASK, support, constraint_RMask, RMASK)

    if constraint_RMask
        MASK(~RMASK) = 1;
    end
%     Nknown = sum(MASK(:)) + 2*sum(~support(:));
%     Nunknown = numel(MASK(:)) + sum(~MASK(:)) + 2*sum(support(:));
%     OSR = Nknown/Nunknown;

    % Miao, J., Sayre, D., &#38; Chapman, H. N. (1998). Phase retrieval 
    % from the magnitude of the Fourier transforms of nonperiodic objects. 
    % Journal of the Optical Society of America A 15 (6), 1662. 
    % https://doi.org/10.1364/JOSAA.15.001662</div>

    Ntotal = (numel(MASK));
    NunknownSpatial = sum(support(:)>0);
    OSR = Ntotal/NunknownSpatial;
    
    fprintf('\tover sampling ratio = %.1f\n', OSR);

end
