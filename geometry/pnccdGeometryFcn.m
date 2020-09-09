function [img_out, gap_size, shift_size, center, center_corrected] = pnccdGeometryFcn(img, db_run_info, run, nPix, addgap, addshift)
% Automatic correction of relative geometry (gap size and left/right
% shift) from calculated values based on the motor encoder values of
% the pnCCDs, and manual calibration for some images.
        
if ~exist('addgap','var')
    addgap = 0;
end
if ~exist('addshift','var')
    addshift = 0;
end

manualGap = 0;
manualShift = 0;

gap_physical = (((db_run_info(run).pnCCD.pos.vert_top - 18) + (db_run_info(run).pnCCD.pos.vert_bot - 18)) / 0.075);
gap_inactivePixels = 40;
gap_calc = gap_physical + gap_inactivePixels;
gap_size = gap_calc - 1 + addgap + manualGap;
shift_size = manualShift + addshift + 1 + ( ( db_run_info(run).pnCCD.pos.horz_top - 19.37 + db_run_info(run).pnCCD.pos.horz_bot - 17.2046 ) /0.075 );
% gap and shift verified with 'run_0437_hit_0013_trainid_137000527.mat'

center = [511, 535] ...
    + 0.5*[manualGap, manualShift] ...
    + [ -(db_run_info(run).pnCCD.pos.horz_top - 19.37),...
    + (db_run_info(run).pnCCD.pos.vert_top - 18)] / 75e-3 ...
    + 0.5*[addgap, addshift];
     

% if run_nr>=437
%     center = center + [2.5,1.5];
% end    

if gap_size > 600 || shift_size > 40
    warning('Warning: pnccd_geometry correction was aborted because gap_size > 600 or shift_size > 40 was detected. This does not make sense. Continue with uncorrected image.')
    img_out = img;
    return
end

% img_out = nan(size(img, 1) + round(gap_size), size(img, 2) + round(shift_size), 'single');
img_out = nan(nPix, 'like', img);

if shift_size >= 0
    img_out(1:512, 1:1024) = img(1:512, 1:1024);
    img_out(round(gap_size) + (513:1024), round(shift_size) + (1:1024)) = img(513:end, 1:1024);
else
    img_out((1:512),  -round(shift_size) + (1:1024)) = img(1:512, 1:1024);
    img_out(round(gap_size) + (513:1024), (1:1024)) = img(513:1024, 1:1024);
end

center_corrected = [center(2), center(1)];
%% There was a switch in x-y ...