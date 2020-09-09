
        function obj = zeroBorders(obj)
%            obj.W = ft2(obj.ws);
%            obj.INT = abs(obj.W);
%            obj.PHASE = angle(obj.W);
%            obj.WS = obj.W .* (1-obj.MASK) + obj.SCATT.*exp(1i*obj.PHASE) .* (obj.MASK);
%            if obj.masking.constraint_RMask
%                obj.RMASK_smooth = imgaussfilt(single(obj.RMASK), obj.masking.RMASK_smoothPix);
%               obj.WS = obj.WS .* obj.RMASK_smooth;
%            end
%            obj.w_old = obj.ws;
%            obj.w = ift2(obj.WS), iif(obj.constraint_symmetry,'symmetric','nonsymmetric');
%            obj.int = abs(obj.w);
%            obj.phase = angle(obj.w);
%            obj.ws = (obj.w .* obj.support).*exp(1i*obj.phase);
%            %             obj.constraints('dcdi');
%            obj.plotAll;
        end  