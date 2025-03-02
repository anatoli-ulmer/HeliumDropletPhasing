function imgOut = imgBinning(img, binFactor, movMeanRange)

    oldSize = size(img);
    newSize = round(oldSize*binFactor);
    dx = round(1/binFactor);
    
    ix = 1:dx:oldSize(2);
    iy = 1:dx:oldSize(1);
    
    if exist('movMeanRange', 'var')
%         conv2()
        img = movmean(movmean(img, movMeanRange, 1), movMeanRange, 2);
        imgOut = img(iy, ix);
%         for i=1:dx
%             for j=1:dx
%                 imgOut(i) = img(iy+(i-1), ix+(j-1));
%                 k=k+1;
%             end
%         end
    else
        img3d = zeros([newSize, dx]);
        k=1;
        for i=1:dx
            for j=1:dx
                img3d(:,:,k) = img(iy+(i-1), ix+(j-1));
                k=k+1;
            end
        end

        imgOut = mean(img3d,3, 'omitnan');
    end

end