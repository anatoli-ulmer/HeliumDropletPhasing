function obj = reconApplyConstraints(obj, method)

    if mod(obj.nTotal, obj.constraints.normalizeRhoEachStep)
        normArea = abs(obj.w-obj.rho)<obj.delta & ~imdilate(~obj.support0, strel('disk',2));
        %         figure(338882); imgSize = size(normArea); imgCenter = imgSize/2+1; imagesc(normArea); xlim(obj.support_radius*[-1,1]*1.5+imgCenter); ylim(obj.support_radius*[-1,1]*1.5+imgCenter);
        newAlpha = norm(abs(obj.w(normArea)), 'fro')/norm(abs(obj.rho(normArea)), 'fro');
%         fprintf('\tnormalized with calculated alpha = %.2f', newAlpha);
        if ~isnan(newAlpha) && ~isempty(newAlpha)
            obj.rho = obj.rho * newAlpha;
        end

        %     renormalize normalize on droplet density
%             obj.rho = obj.alpha * obj.rho / norm(obj.rho, 'fro') * norm(abs(obj.ws).*obj.support, 'fro');

        %     obj.rho = obj.rho0 .* nanmedian(obj.w(~shrunkSupport(:))./obj.rho0(~shrunkSupport(:)));
%         obj.rho = obj.rho0 .* nanmedian(abs(obj.ws(obj.supportShrunk(:)))./abs(obj.rho0(obj.supportShrunk(:))));

%         obj.rho = obj.rho0 .* nanmean(abs(obj.w(obj.supportShrunk(:)))./abs(obj.rho0(obj.supportShrunk(:))));
%             obj.rho = obj.rho0 .* nanmedian(abs(obj.w(:))./abs(obj.rho0(:)));
    end

    obj.constraintsMet = obj.support>0;

    if obj.constraints.posReal 
        obj.constraintsMet = obj.constraintsMet & (real(obj.ws)>=0);
    end
    if obj.constraints.posImag
        obj.constraintsMet = obj.constraintsMet & (imag(obj.ws)>=0);
    end
    if obj.constraints.shape
        obj.constraintsMet = obj.constraintsMet & ...
            ( abs(obj.ws-obj.rho) > obj.delta );
    end
    if obj.constraints.minPhase
        obj.constraintsMet = obj.constraintsMet & ...
        ( angle(obj.ws-obj.rho) >= obj.phaseMin );
    end
    if obj.constraints.real
        obj.ws = real(obj.ws); 
    end
    obj.constraintsViolated = ~obj.constraintsMet;
    
    obj.updateBeta();
% 
    switch lower(method)
        case 'dcdi' % 4
            switch obj.constraints.deltaComparePart
                case 'real'
                    compareDensity = real(obj.ws-obj.rho);
                case 'imag'
                    compareDensity = imag(obj.ws-obj.rho);
                otherwise
                    compareDensity = abs(obj.ws-obj.rho);
            end
            obj.constraintsMet = obj.constraintsMet & ...
                ( ( compareDensity > obj.delta ) & ...
                ( angle(obj.ws-obj.rho) >= obj.phaseMin ) & ...
                ( angle(obj.ws-obj.rho) <= obj.phaseMax ));
            obj.w(obj.constraintsMet) = obj.ws(obj.constraintsMet);
            obj.w(~obj.constraintsMet) = obj.rho(~obj.constraintsMet);
%             obj.w(~obj.support) = 0;
%             obj.w = obj.ws .* obj.constraintsMet ...
%                 + obj.rho .* ~obj.constraintsMet;
%             obj.w = obj.w.*obj.support;
            
%             cond1 = ( real(obj.ws) > (obj.rho + obj.delta) );
%             cond2 = ( angle(obj.ws-obj.rho) >= obj.phaseMin );
%             cond3 = cond1 .* cond2;
%             obj.w = obj.ws .* cond3 + obj.rho .* ~cond3;
%             obj.w = obj.w.*obj.support;

%             obj.w = obj.ws .* ( ( abs(obj.ws-obj.rho) > obj.delta ) .* ...
%                 ( angle(obj.ws-obj.rho) >= obj.phaseMin ) )...
%                 + obj.rho .* ~( ( abs(obj.ws-obj.rho) > obj.delta ) .* ...
%                 ( angle(obj.ws-obj.rho) >= obj.phaseMin ) );
%             obj.w = obj.w.*obj.support;
        case 'er' % 5
            obj.w = obj.ws .* obj.support;
        case 'hpr' %
            obj.w = obj.ws .* ...
                ( obj.constraintsMet & (obj.w <= obj.ws.*(1+obj.beta) ) ) ...
                + (obj.w - obj.beta*obj.ws) .* ...
                ~( obj.constraintsMet & ( obj.w <= obj.ws.*(1+obj.beta) ) );
        case 'hio' % 8
            obj.w(obj.constraintsMet) = obj.ws(obj.constraintsMet);
            obj.w(~obj.constraintsMet) = obj.w(~obj.constraintsMet) - obj.beta*obj.ws(~obj.constraintsMet);
%             obj.w = obj.constraintsMet.* obj.ws + ...
%                 (~obj.constraintsMet).*(obj.w - obj.beta*obj.ws);
        case 'mdcdi'
            obj.w = (obj.ws + obj.rho)/2;
            obj.w = obj.w.*obj.support;
        case 'ntdcdi'
%             fieldScatt = abs(ft2(obj.ws));
%             fieldRef = ft2(obj.rho);
%             scattImg = abs(fieldScatt).^2;
%             scattImg = obj.AMP0;
%             snr = double(scattImg.*(scattImg<=0.2) + 0.5*(scattImg>0.2));
%             fieldDeconvolved = fieldScatt .* fieldRef' .* snr ./ (1 + abs(fieldRef).^2 .* snr);
%             obj.w = obj.rho + ift2(fieldDeconvolved);
            
% %             obj.w = (obj.w - obj.beta*obj.ws).*(~obj.support);
% %             obj.w = obj.w .* (abs(obj.ws)>obj.delta);
% %             obj.w = obj.w + obj.ws .* obj.support;
%             
%             wI = obj.ws .* ( ( real(obj.ws) > (real(obj.rho) + obj.delta) ) .* ...
%                 ( angle(obj.ws-obj.rho) >= obj.phaseMin ) )...
%                 + obj.rho .* ~( ( real(obj.ws) > (real(obj.rho) + obj.delta) ) .* ...
%                 ( angle(obj.ws-obj.rho) >= obj.phaseMin ) );
%             wI = wI.*obj.constraintsMet;
%             wO = (obj.w - obj.beta*obj.ws).*(~obj.constraintsMet);
%             wO = wO .* (abs(obj.ws)>obj.delta);
%             obj.w = wO + wI;
            
        case 'nthio' % 7
            obj.w = (obj.w - obj.beta*obj.ws).*(~obj.constraintsMet);
            obj.w = obj.w .* (abs(obj.ws)>obj.delta);
            obj.w = obj.w + obj.ws .* obj.constraintsMet;
        case 'raar' % 8
%             tmp = obj.beta * (obj.w.*obj.support - obj.w);
%             obj.w = 2*obj.beta.*obj.support.*obj.ws;
%             obj.w = obj.w + (1-2*obj.beta)*obj.ws;
%             obj.w = obj.w + tmp;
% %             ( -obj.w .*  + obj.ws .* (1-2*obj.beta) ).*(~obj.support);
% %             obj.w = ~obj.support.*(obj.beta*obj.w - (1-2*obj.beta)*obj.ws);
%             obj.w = obj.w + obj.support.*obj.ws;

            Rm = 2*obj.ws - obj.w;
            obj.constraintsMet = obj.constraintsMet .* (real(Rm) > 0);
%             obj.constraintsViolated = obj.support & (real(Rm) < 0);
            obj.w = obj.constraintsMet .* obj.ws + ...
                (~obj.constraintsMet) .* (obj.beta*obj.w - (1-2*obj.beta)*obj.ws);

%             tmp = obj.beta * (obj.w.*obj.support - obj.w);
%             obj.w = 2*obj.beta.*obj.support.*obj.ws;
%             obj.w = obj.w + (1-2*obj.beta)*obj.ws;
%             obj.w = obj.w + tmp;
%             ( -obj.w .*  + obj.ws .* (1-2*obj.beta) ).*(~obj.support);
%             obj.w = ~obj.support.*(obj.beta*obj.w - (1-2*obj.beta)*obj.ws);
%             obj.w = obj.w + obj.support.*obj.ws;

    end
end
