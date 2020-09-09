function beta = updateBeta(beta0, beta, nTotal)
    beta = beta0 + (1-beta0)*(1-exp(-(nTotal/500)^3));
end