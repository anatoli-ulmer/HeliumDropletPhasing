function setColormap(src,evt,h)
    newmap = evt.Source.String{evt.Source.Value};
    ax = findall(evt.Source.Parent.Children, 'type', 'axes');
    for i=1:numel(ax)
        colormap(ax(i), newmap);
    end
end