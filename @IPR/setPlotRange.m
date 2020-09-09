function obj = setPlotRange(obj,~,~)
    sc1 = str2num_fast(obj.editArray(1).String);
    sc2 = str2num_fast(obj.editArray(2).String);
    if isnan(sc1) || isnan(sc2) || sc1==sc2
        caxis(obj.axesArray(3), 'auto');
        caxis(obj.axesArray(4), 'auto');
    else
        obj.axesArray(3).CLim = [sc1,sc2];
        obj.axesArray(4).CLim = [sc1,sc2];
    end
    if obj.normalize_shape
        obj.axesArray(5).CLim = 1+[-1,1]*0.05;
        obj.axesArray(6).CLim = 1+[-1,1]*0.05;
    else
        if max(abs(obj.plt.rec(1).img.CData(:))) > 0
            switch obj.popupArray(4).Value
                case 1
                    obj.axesArray(5).CLim=[min(obj.plt.rec(1).img.CData(:)),max(obj.plt.rec(1).img.CData(:))];
                case 2
                    obj.axesArray(5).CLim=[0,max(obj.plt.rec(1).img.CData(:))];
                case 3
                    obj.axesArray(5).CLim = [-1,1]*max(abs(obj.plt.rec(1).img.CData(:)));
                case 4
                    obj.axesArray(5).CLim = [0.2,1]*max(abs(obj.plt.rec(1).img.CData(:)));
                case 5
                    if max((obj.plt.rec(2).img.CData(:))) > 0
                        obj.axesArray(5).CLim = [-1,1]*max((obj.plt.rec(1).img.CData(:)));
                    end
                case 6
                    obj.axesArray(5).CLim = [-1,1]*pi;
                case 7
                    obj.axesArray(5).CLim = [-1,1]*pi/2;
                case 8
                    obj.axesArray(5).CLim = [-1,1]*pi/4;
                case 9
                    obj.axesArray(5).CLim = [-1,1]*pi/8;
                case 10
                    obj.axesArray(5).CLim = [-1,1]*0.1;
            end
        end
        if max(abs(obj.plt.rec(2).img.CData(:))) > 0
            switch obj.popupArray(4).Value
                case 1
                    obj.axesArray(6).CLim=[min(obj.plt.rec(2).img.CData(:)),max(obj.plt.rec(2).img.CData(:))];
                case 2
                    obj.axesArray(6).CLim=[0,max(obj.plt.rec(2).img.CData(:))];
                case 3
                    obj.axesArray(6).CLim = [-1,1]*max(abs(obj.plt.rec(2).img.CData(:)));
                case 4
                    obj.axesArray(6).CLim = [0.2,1]*max(abs(obj.plt.rec(2).img.CData(:)));
                case 5
                    if max((obj.plt.rec(2).img.CData(:))) > 0
                        obj.axesArray(6).CLim = [-1,1]*max((obj.plt.rec(2).img.CData(:)));
                    end
                case 6
                    obj.axesArray(6).CLim = [-1,1]*pi;
                case 7
                    obj.axesArray(6).CLim = [-1,1]*pi/2;
                case 8
                    obj.axesArray(6).CLim = [-1,1]*pi/4;
                case 9
                    obj.axesArray(6).CLim = [-1,1]*pi/8;
                case 10
                    obj.axesArray(6).CLim = [-1,1]*0.1;
            end
        end
    end
end