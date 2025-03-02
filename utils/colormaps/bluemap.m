function cm = bluemap(ncols)

if ~exist('ncols','var')
    ncols = 256;
end

HSVstartB = [210, 80, 60]./[360,100,100];
HSVendB = [0, 0, 100]./[360,100,100];
RGBstartB = hsv2rgb(HSVstartB);
RGBendB = hsv2rgb(HSVendB);

RGBdiffB = RGBendB-RGBstartB;

cm = [1 1 1];
for idc = linspace(0,1,ncols)
    cm = [cm; RGBendB-RGBdiffB*idc];
end

