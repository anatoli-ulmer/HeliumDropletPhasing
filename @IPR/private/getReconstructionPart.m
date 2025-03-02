function [CData, AlphaData] = getReconstructionPart(data, part, alpha)
    switch part
        case 'real'    
            CData=real(data);
        case 'imag'
            CData=imag(data);
        case 'abs'
            CData=abs(data);
        case 'angle'
            CData=angle(data);
        case 'complex'
            CData=compleximagedata(data);
    end
    
    if nargout>1
        switch part
%             case 'real'
%                 AlphaData = ones(size(data),'like',abs(data));
%             case 'imag'
%                 AlphaData = ones(size(data),'like',abs(data));
%             case 'abs'
%                 AlphaData = ones(size(data),'like',abs(data));
%             case 'angle'
%                 AlphaData = ones(size(data),'like',abs(data));
            case 'complex'
                AlphaData = abs(data);
            otherwise
                AlphaData = ones(size(data),'like',abs(data));
        end
        %             AlphaData = alpha*AlphaData;
        CDataMax = max(CData(:));
        AlphaData = (CData/CDataMax)/alpha;% (CData-CDataMax*alpha);
%         nAlpha=numel(ax.Colorbar.Face.Texture.CData(end,:));
%         thresh=round(nAlpha*obj.plotting.alpha.dopant);
%         alphaMap=zeros(1,nAlpha,'uint8');
%         alphaMap(thresh+1:end)=255;
%         alphaMap(1:thresh)=uint8(linspace(0,255,thresh));

%         AlphaData(CData < (1-alpha) * CDataMax) = 0;
    end
    
end
