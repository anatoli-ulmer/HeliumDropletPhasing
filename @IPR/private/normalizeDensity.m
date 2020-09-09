function rho = normalizeDensity(ws, support, rho, alpha)
    if ~exist('alpha', 'var')
        alpha = 1;
    end
    rho = alpha * rho / norm(rho, 'fro') * norm(abs(ws).*support, 'fro');
end