function cm = redmap(ncols)

if ~exist('ncols','var')
    ncols = 256;
end

HSVstartR = [0, 0, 100]./[360,100,100];
HSVendR = [0, 100, 80]./[360,100,100];

RGBstartR = hsv2rgb(HSVstartR);
RGBendR = hsv2rgb(HSVendR);

RGBdiffR = RGBendR-RGBstartR;

cm = [];
for idc = linspace(1,0,ncols)
    cm = [cm; RGBendR-RGBdiffR*idc]; %#ok<*AGROW>
end
cm = [[1 1 1]; cm];
