% % function cm = r2b2(ncols)
% % 
% % if ~exist('ncols','var')
% %     ncols = 256;
% % end
% % 
% % % HSVstartR = [0, 100, 62]./[360,100,100];
% % % HSVendR = [0, 6, 100]./[360,100,100];
% % % HSVzero = [0, 0, 100]./[360,100,100];
% % % HSVstartB = [220, 100, 62]./[360,100,100];
% % % HSVendB = [220, 6, 100]./[360,100,100];
% % 
% % HSVstartR = [0, 100, 60]./[360,100,100];
% % HSVendR = [0, 0, 100]./[360,100,100];
% % HSVzero = [0, 0, 100]./[360,100,100];
% % HSVstartB = [210, 100, 60]./[360,100,100];
% % HSVendB = [0, 0, 100]./[360,100,100];
% % 
% % RGBstartR = hsv2rgb(HSVstartR);
% % RGBendR = hsv2rgb(HSVendR);
% % RGBzero = hsv2rgb(HSVzero);
% % RGBstartB = hsv2rgb(HSVstartB);
% % RGBendB = hsv2rgb(HSVendB);
% % 
% % RGBdiffR = RGBendR-RGBstartR;
% % RGBdiffB = RGBendB-RGBstartB;
% % 
% % cm = [];
% % for idc = linspace(1,0,ncols)
% %     cm = [cm; RGBendR-RGBdiffR*idc^2]; %#ok<*AGROW>
% % end
% % % cm = [cm; RGBzero];
% % for idc = linspace(0,1,ncols)
% %     cm = [cm; RGBendB-RGBdiffB*idc^2];
% % end

function p = r2b2(m)
%R2B    colormap

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cmap_mat = [
        0.6000         0         0
    0.6063    0.0157    0.0157
    0.6125    0.0312    0.0312
    0.6187    0.0467    0.0467
    0.6248    0.0620    0.0620
    0.6309    0.0772    0.0772
    0.6369    0.0923    0.0923
    0.6429    0.1072    0.1072
    0.6488    0.1220    0.1220
    0.6547    0.1367    0.1367
    0.6605    0.1513    0.1513
    0.6663    0.1657    0.1657
    0.6720    0.1800    0.1800
    0.6777    0.1942    0.1942
    0.6833    0.2083    0.2083
    0.6889    0.2223    0.2223
    0.6944    0.2361    0.2361
    0.6999    0.2498    0.2498
    0.7054    0.2634    0.2634
    0.7107    0.2768    0.2768
    0.7161    0.2902    0.2902
    0.7213    0.3034    0.3034
    0.7266    0.3164    0.3164
    0.7318    0.3294    0.3294
    0.7369    0.3422    0.3422
    0.7420    0.3550    0.3550
    0.7470    0.3675    0.3675
    0.7520    0.3800    0.3800
    0.7569    0.3923    0.3923
    0.7618    0.4046    0.4046
    0.7667    0.4166    0.4166
    0.7714    0.4286    0.4286
    0.7762    0.4404    0.4404
    0.7809    0.4522    0.4522
    0.7855    0.4638    0.4638
    0.7901    0.4752    0.4752
    0.7946    0.4866    0.4866
    0.7991    0.4978    0.4978
    0.8036    0.5089    0.5089
    0.8079    0.5199    0.5199
    0.8123    0.5307    0.5307
    0.8166    0.5414    0.5414
    0.8208    0.5520    0.5520
    0.8250    0.5625    0.5625
    0.8292    0.5729    0.5729
    0.8332    0.5831    0.5831
    0.8373    0.5932    0.5932
    0.8413    0.6032    0.6032
    0.8452    0.6131    0.6131
    0.8491    0.6228    0.6228
    0.8530    0.6324    0.6324
    0.8568    0.6419    0.6419
    0.8605    0.6512    0.6512
    0.8642    0.6605    0.6605
    0.8678    0.6696    0.6696
    0.8714    0.6786    0.6786
    0.8750    0.6875    0.6875
    0.8785    0.6962    0.6962
    0.8819    0.7048    0.7048
    0.8853    0.7133    0.7133
    0.8887    0.7217    0.7217
    0.8920    0.7299    0.7299
    0.8952    0.7380    0.7380
    0.8984    0.7460    0.7460
    0.9016    0.7539    0.7539
    0.9047    0.7617    0.7617
    0.9077    0.7693    0.7693
    0.9107    0.7768    0.7768
    0.9137    0.7842    0.7842
    0.9166    0.7914    0.7914
    0.9194    0.7986    0.7986
    0.9222    0.8056    0.8056
    0.9250    0.8124    0.8124
    0.9277    0.8192    0.8192
    0.9303    0.8258    0.8258
    0.9329    0.8324    0.8324
    0.9355    0.8387    0.8387
    0.9380    0.8450    0.8450
    0.9405    0.8511    0.8511
    0.9429    0.8572    0.8572
    0.9452    0.8630    0.8630
    0.9475    0.8688    0.8688
    0.9498    0.8744    0.8744
    0.9520    0.8800    0.8800
    0.9541    0.8854    0.8854
    0.9563    0.8906    0.8906
    0.9583    0.8958    0.8958
    0.9603    0.9008    0.9008
    0.9623    0.9057    0.9057
    0.9642    0.9105    0.9105
    0.9660    0.9151    0.9151
    0.9679    0.9196    0.9196
    0.9696    0.9240    0.9240
    0.9713    0.9283    0.9283
    0.9730    0.9325    0.9325
    0.9746    0.9365    0.9365
    0.9762    0.9404    0.9404
    0.9777    0.9442    0.9442
    0.9791    0.9479    0.9479
    0.9806    0.9514    0.9514
    0.9819    0.9548    0.9548
    0.9832    0.9581    0.9581
    0.9845    0.9612    0.9612
    0.9857    0.9643    0.9643
    0.9869    0.9672    0.9672
    0.9880    0.9700    0.9700
    0.9891    0.9727    0.9727
    0.9901    0.9752    0.9752
    0.9910    0.9776    0.9776
    0.9920    0.9799    0.9799
    0.9928    0.9821    0.9821
    0.9937    0.9841    0.9841
    0.9944    0.9860    0.9860
    0.9951    0.9878    0.9878
    0.9958    0.9895    0.9895
    0.9964    0.9911    0.9911
    0.9970    0.9925    0.9925
    0.9975    0.9938    0.9938
    0.9980    0.9950    0.9950
    0.9984    0.9960    0.9960
    0.9988    0.9970    0.9970
    0.9991    0.9978    0.9978
    0.9994    0.9984    0.9984
    0.9996    0.9990    0.9990
    0.9998    0.9994    0.9994
    0.9999    0.9998    0.9998
    1.0000    0.9999    0.9999
    1.0000    1.0000    1.0000
    1.0000    1.0000    1.0000
    0.9999    1.0000    1.0000
    0.9998    0.9998    0.9999
    0.9994    0.9996    0.9998
    0.9990    0.9993    0.9996
    0.9984    0.9989    0.9994
    0.9978    0.9984    0.9991
    0.9970    0.9979    0.9988
    0.9960    0.9972    0.9984
    0.9950    0.9965    0.9980
    0.9938    0.9957    0.9975
    0.9925    0.9947    0.9970
    0.9911    0.9938    0.9964
    0.9895    0.9927    0.9958
    0.9878    0.9915    0.9951
    0.9860    0.9902    0.9944
    0.9841    0.9889    0.9937
    0.9821    0.9875    0.9928
    0.9799    0.9859    0.9920
    0.9776    0.9843    0.9910
    0.9752    0.9826    0.9901
    0.9727    0.9809    0.9891
    0.9700    0.9790    0.9880
    0.9672    0.9770    0.9869
    0.9643    0.9750    0.9857
    0.9612    0.9729    0.9845
    0.9581    0.9707    0.9832
    0.9548    0.9684    0.9819
    0.9514    0.9660    0.9806
    0.9479    0.9635    0.9791
    0.9442    0.9609    0.9777
    0.9404    0.9583    0.9762
    0.9365    0.9556    0.9746
    0.9325    0.9527    0.9730
    0.9283    0.9498    0.9713
    0.9240    0.9468    0.9696
    0.9196    0.9438    0.9679
    0.9151    0.9406    0.9660
    0.9105    0.9373    0.9642
    0.9057    0.9340    0.9623
    0.9008    0.9306    0.9603
    0.8958    0.9270    0.9583
    0.8906    0.9234    0.9563
    0.8854    0.9198    0.9541
    0.8800    0.9160    0.9520
    0.8744    0.9121    0.9498
    0.8688    0.9082    0.9475
    0.8630    0.9041    0.9452
    0.8572    0.9000    0.9429
    0.8511    0.8958    0.9405
    0.8450    0.8915    0.9380
    0.8387    0.8871    0.9355
    0.8324    0.8826    0.9329
    0.8258    0.8781    0.9303
    0.8192    0.8734    0.9277
    0.8124    0.8687    0.9250
    0.8056    0.8639    0.9222
    0.7986    0.8590    0.9194
    0.7914    0.8540    0.9166
    0.7842    0.8489    0.9137
    0.7768    0.8438    0.9107
    0.7693    0.8385    0.9077
    0.7617    0.8332    0.9047
    0.7539    0.8277    0.9016
    0.7460    0.8222    0.8984
    0.7380    0.8166    0.8952
    0.7299    0.8109    0.8920
    0.7217    0.8052    0.8887
    0.7133    0.7993    0.8853
    0.7048    0.7934    0.8819
    0.6962    0.7873    0.8785
    0.6875    0.7812    0.8750
    0.6786    0.7750    0.8714
    0.6696    0.7687    0.8678
    0.6605    0.7623    0.8642
    0.6512    0.7559    0.8605
    0.6419    0.7493    0.8568
    0.6324    0.7427    0.8530
    0.6228    0.7360    0.8491
    0.6131    0.7291    0.8452
    0.6032    0.7222    0.8413
    0.5932    0.7153    0.8373
    0.5831    0.7082    0.8332
    0.5729    0.7010    0.8292
    0.5625    0.6938    0.8250
    0.5520    0.6864    0.8208
    0.5414    0.6790    0.8166
    0.5307    0.6715    0.8123
    0.5199    0.6639    0.8079
    0.5089    0.6562    0.8036
    0.4978    0.6485    0.7991
    0.4866    0.6406    0.7946
    0.4752    0.6327    0.7901
    0.4638    0.6246    0.7855
    0.4522    0.6165    0.7809
    0.4404    0.6083    0.7762
    0.4286    0.6000    0.7714
    0.4166    0.5916    0.7667
    0.4046    0.5832    0.7618
    0.3923    0.5746    0.7569
    0.3800    0.5660    0.7520
    0.3675    0.5573    0.7470
    0.3550    0.5485    0.7420
    0.3422    0.5396    0.7369
    0.3294    0.5306    0.7318
    0.3164    0.5215    0.7266
    0.3034    0.5124    0.7213
    0.2902    0.5031    0.7161
    0.2768    0.4938    0.7107
    0.2634    0.4844    0.7054
    0.2498    0.4749    0.6999
    0.2361    0.4653    0.6944
    0.2223    0.4556    0.6889
    0.2083    0.4458    0.6833
    0.1942    0.4360    0.6777
    0.1800    0.4260    0.6720
    0.1657    0.4160    0.6663
    0.1513    0.4059    0.6605
    0.1367    0.3957    0.6547
    0.1220    0.3854    0.6488
    0.1072    0.3750    0.6429
    0.0923    0.3646    0.6369
    0.0772    0.3540    0.6309
    0.0620    0.3434    0.6248
    0.0467    0.3327    0.6187
    0.0312    0.3219    0.6125
    0.0157    0.3110    0.6063
         0    0.3000    0.6000
    ];

%interpolate values
xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');
