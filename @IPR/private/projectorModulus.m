function WS = projectorModulus(AMP, AMP0, PHASE, MASK)
	
	WS = (AMP.*(~MASK) + AMP0.*MASK).*exp(1i.*PHASE);
end
