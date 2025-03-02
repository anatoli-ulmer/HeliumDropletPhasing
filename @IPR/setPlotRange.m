function obj = setPlotRange(obj,~,~)
    sc1 = str2double(obj.go.edit(1).String);
    sc2 = str2double(obj.go.edit(2).String);
    if sc1==sc2
        caxis(obj.go.axes(3), 'auto');
        caxis(obj.go.axes(4), 'auto');
    else
        if isnan(sc1), sc1 = min(obj.go.image(1,2).CData(:), 'omitnan'); end
        if isnan(sc2), sc2 = max(obj.go.image(1,2).CData(:), 'omitnan'); end
        obj.go.axes(3).CLim = [sc1,sc2];
        obj.go.axes(4).CLim = [sc1,sc2];
    end
    if max(abs(obj.go.image(2,1).CData(:))) > 0
        switch obj.go.popup(4).Value
            case 1
                obj.go.axes(5).CLim=[min(obj.go.image(2,1).CData(:)),max(obj.go.image(2,1).CData(:))];
            case 2
                obj.go.axes(5).CLim=[0,max(obj.go.image(2,1).CData(:))];
            case 3
                obj.go.axes(5).CLim = [-1,1]*max(abs(obj.go.image(2,1).CData(:)));
            case 4
                obj.go.axes(5).CLim = [0.2,1]*max(abs(obj.go.image(2,1).CData(:)));
            case 5
                if max((obj.go.image(2,2).CData(:))) > 0
                    obj.go.axes(5).CLim = [-1,1]*max((obj.go.image(2,1).CData(:)));
                end
            case 6
                obj.go.axes(5).CLim = [-1,1]*pi;
            case 7
                obj.go.axes(5).CLim = [-1,1]*pi/2;
            case 8
                obj.go.axes(5).CLim = [-1,1]*pi/4;
            case 9
                obj.go.axes(5).CLim = [-1,1]*pi/8;
            case 10
                obj.go.axes(5).CLim = [-1,1]*0.1;
            case 11
%                 if max((obj.go.image(2,1).CData(:))) > 0
                    obj.go.axes(5).CLim = [0,1]*max((obj.go.image(2,1).CData(:)))/2;
%                 end
        end
    end
    if max(abs(obj.go.image(2,2).CData(:))) > 0
        switch obj.go.popup(4).Value
            case 1
                obj.go.axes(6).CLim=[min(obj.go.image(2,2).CData(:)),max(obj.go.image(2,2).CData(:))];
            case 2
                obj.go.axes(6).CLim=[0,max(obj.go.image(2,2).CData(:))];
            case 3
                obj.go.axes(6).CLim = [-1,1]*max(abs(obj.go.image(2,2).CData(:)));
            case 4
                obj.go.axes(6).CLim = [0.2,1]*max(abs(obj.go.image(2,2).CData(:)));
            case 5
                if max((obj.go.image(2,2).CData(:))) > 0
                    obj.go.axes(6).CLim = [-1,1]*max((obj.go.image(2,2).CData(:)));
                end
            case 6
                obj.go.axes(6).CLim = [-1,1]*pi;
            case 7
                obj.go.axes(6).CLim = [-1,1]*pi/2;
            case 8
                obj.go.axes(6).CLim = [-1,1]*pi/4;
            case 9
                obj.go.axes(6).CLim = [-1,1]*pi/8;
            case 10
                obj.go.axes(6).CLim = [-1,1]*0.1;
            case 11
%                 if max((obj.go.image(2,2).CData(:))) > 0
                    obj.go.axes(6).CLim = [0,1]*max((obj.go.image(2,2).CData(:)))/2;
%                 end
        end
    end
end
