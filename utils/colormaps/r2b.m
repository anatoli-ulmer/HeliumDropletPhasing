function cm = r2b(ncols)

if ~exist('ncols','var')
    ncols = 256;
end

% HSVstartR = [0, 100, 62]./[360,100,100];
% HSVendR = [0, 6, 100]./[360,100,100];
% HSVzero = [0, 0, 100]./[360,100,100];
% HSVstartB = [220, 100, 62]./[360,100,100];
% HSVendB = [220, 6, 100]./[360,100,100];

HSVstartR = [0, 80, 60]./[360,100,100];
HSVendR = [0, 0, 100]./[360,100,100];
HSVzero = [0, 0, 100]./[360,100,100];
HSVstartB = [210, 80, 60]./[360,100,100];
HSVendB = [0, 0, 100]./[360,100,100];

RGBstartR = hsv2rgb(HSVstartR);
RGBendR = hsv2rgb(HSVendR);
RGBzero = hsv2rgb(HSVzero);
RGBstartB = hsv2rgb(HSVstartB);
RGBendB = hsv2rgb(HSVendB);

RGBdiffR = RGBendR-RGBstartR;
RGBdiffB = RGBendB-RGBstartB;

cm = [];
for idc = linspace(1,0,ncols)
    cm = [cm; RGBendR-RGBdiffR*idc]; %#ok<*AGROW>
end
% cm = [cm; RGBzero];
for idc = linspace(0,1,ncols)
    cm = [cm; RGBendB-RGBdiffB*idc];
end
