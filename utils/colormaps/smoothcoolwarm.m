function p = smoothcoolwarm(m)
%BENTCOOLWARM    colormap

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cmap_mat = [
        0.3348    0.2831    0.7565
    0.3390    0.2902    0.7627
    0.3432    0.2973    0.7689
    0.3474    0.3043    0.7750
    0.3516    0.3113    0.7810
    0.3558    0.3184    0.7870
    0.3601    0.3254    0.7929
    0.3643    0.3323    0.7987
    0.3685    0.3393    0.8045
    0.3727    0.3462    0.8102
    0.3769    0.3532    0.8158
    0.3812    0.3601    0.8213
    0.3854    0.3670    0.8268
    0.3896    0.3738    0.8323
    0.3939    0.3807    0.8376
    0.3981    0.3875    0.8429
    0.4023    0.3943    0.8481
    0.4066    0.4011    0.8532
    0.4108    0.4078    0.8582
    0.4151    0.4146    0.8632
    0.4194    0.4213    0.8681
    0.4236    0.4280    0.8729
    0.4279    0.4346    0.8776
    0.4322    0.4413    0.8823
    0.4365    0.4479    0.8869
    0.4408    0.4545    0.8914
    0.4451    0.4611    0.8958
    0.4494    0.4676    0.9001
    0.4537    0.4741    0.9044
    0.4580    0.4806    0.9085
    0.4623    0.4870    0.9126
    0.4666    0.4935    0.9166
    0.4709    0.4998    0.9205
    0.4753    0.5062    0.9243
    0.4796    0.5125    0.9281
    0.4840    0.5188    0.9317
    0.4883    0.5251    0.9353
    0.4927    0.5313    0.9388
    0.4970    0.5375    0.9421
    0.5014    0.5436    0.9454
    0.5058    0.5498    0.9486
    0.5101    0.5558    0.9518
    0.5145    0.5619    0.9548
    0.5189    0.5679    0.9577
    0.5233    0.5739    0.9606
    0.5277    0.5798    0.9633
    0.5321    0.5857    0.9660
    0.5365    0.5915    0.9685
    0.5409    0.5973    0.9710
    0.5453    0.6031    0.9734
    0.5497    0.6088    0.9757
    0.5541    0.6144    0.9779
    0.5585    0.6201    0.9800
    0.5630    0.6256    0.9820
    0.5674    0.6312    0.9839
    0.5718    0.6367    0.9857
    0.5762    0.6421    0.9874
    0.5807    0.6475    0.9890
    0.5851    0.6528    0.9905
    0.5895    0.6581    0.9920
    0.5940    0.6633    0.9933
    0.5984    0.6685    0.9945
    0.6028    0.6736    0.9957
    0.6072    0.6787    0.9967
    0.6117    0.6837    0.9977
    0.6161    0.6887    0.9985
    0.6205    0.6936    0.9993
    0.6249    0.6985    0.9999
    0.6294    0.7033    1.0000
    0.6338    0.7080    1.0000
    0.6382    0.7127    1.0000
    0.6426    0.7173    1.0000
    0.6470    0.7219    1.0000
    0.6514    0.7264    1.0000
    0.6558    0.7309    1.0000
    0.6601    0.7352    1.0000
    0.6645    0.7396    1.0000
    0.6689    0.7438    1.0000
    0.6732    0.7480    1.0000
    0.6776    0.7522    1.0000
    0.6819    0.7562    0.9996
    0.6863    0.7602    0.9989
    0.6906    0.7642    0.9981
    0.6949    0.7681    0.9972
    0.6992    0.7719    0.9962
    0.7035    0.7756    0.9951
    0.7077    0.7793    0.9939
    0.7120    0.7829    0.9926
    0.7162    0.7864    0.9912
    0.7205    0.7899    0.9898
    0.7247    0.7933    0.9882
    0.7289    0.7966    0.9866
    0.7331    0.7998    0.9848
    0.7372    0.8030    0.9830
    0.7414    0.8061    0.9810
    0.7455    0.8092    0.9790
    0.7496    0.8121    0.9769
    0.7537    0.8150    0.9747
    0.7578    0.8178    0.9724
    0.7618    0.8206    0.9700
    0.7658    0.8232    0.9675
    0.7698    0.8258    0.9649
    0.7738    0.8283    0.9622
    0.7778    0.8308    0.9595
    0.7817    0.8331    0.9566
    0.7856    0.8354    0.9537
    0.7895    0.8376    0.9506
    0.7934    0.8397    0.9475
    0.7972    0.8418    0.9443
    0.8010    0.8437    0.9410
    0.8048    0.8456    0.9377
    0.8085    0.8474    0.9342
    0.8122    0.8491    0.9307
    0.8159    0.8508    0.9270
    0.8196    0.8524    0.9233
    0.8232    0.8538    0.9195
    0.8268    0.8552    0.9157
    0.8303    0.8566    0.9117
    0.8338    0.8578    0.9077
    0.8373    0.8590    0.9035
    0.8408    0.8600    0.8993
    0.8442    0.8610    0.8951
    0.8476    0.8619    0.8907
    0.8509    0.8627    0.8863
    0.8542    0.8635    0.8817
    0.8575    0.8641    0.8772
    0.8607    0.8647    0.8725
    0.8639    0.8652    0.8677
    0.8673    0.8645    0.8626
    0.8711    0.8628    0.8571
    0.8747    0.8609    0.8516
    0.8783    0.8590    0.8460
    0.8818    0.8570    0.8404
    0.8852    0.8549    0.8348
    0.8886    0.8527    0.8291
    0.8918    0.8504    0.8234
    0.8950    0.8481    0.8177
    0.8981    0.8456    0.8119
    0.9011    0.8431    0.8061
    0.9040    0.8405    0.8003
    0.9069    0.8379    0.7945
    0.9096    0.8351    0.7886
    0.9123    0.8323    0.7828
    0.9149    0.8294    0.7769
    0.9174    0.8264    0.7709
    0.9199    0.8233    0.7650
    0.9222    0.8202    0.7590
    0.9245    0.8170    0.7530
    0.9267    0.8137    0.7470
    0.9288    0.8103    0.7410
    0.9308    0.8069    0.7350
    0.9328    0.8033    0.7289
    0.9346    0.7997    0.7228
    0.9364    0.7961    0.7168
    0.9381    0.7923    0.7107
    0.9397    0.7885    0.7046
    0.9412    0.7846    0.6984
    0.9426    0.7806    0.6923
    0.9440    0.7766    0.6862
    0.9453    0.7725    0.6800
    0.9464    0.7683    0.6739
    0.9475    0.7640    0.6677
    0.9486    0.7597    0.6615
    0.9495    0.7553    0.6554
    0.9503    0.7508    0.6492
    0.9511    0.7463    0.6430
    0.9518    0.7417    0.6368
    0.9524    0.7370    0.6306
    0.9529    0.7323    0.6244
    0.9533    0.7274    0.6182
    0.9537    0.7226    0.6121
    0.9539    0.7176    0.6059
    0.9541    0.7126    0.5997
    0.9542    0.7075    0.5935
    0.9542    0.7024    0.5873
    0.9541    0.6972    0.5811
    0.9540    0.6919    0.5750
    0.9537    0.6866    0.5688
    0.9534    0.6812    0.5626
    0.9530    0.6757    0.5565
    0.9525    0.6702    0.5503
    0.9519    0.6646    0.5442
    0.9512    0.6590    0.5381
    0.9505    0.6533    0.5319
    0.9497    0.6475    0.5258
    0.9488    0.6417    0.5197
    0.9478    0.6358    0.5137
    0.9467    0.6299    0.5076
    0.9455    0.6239    0.5015
    0.9443    0.6178    0.4955
    0.9430    0.6117    0.4895
    0.9415    0.6055    0.4834
    0.9401    0.5993    0.4774
    0.9385    0.5930    0.4715
    0.9368    0.5867    0.4655
    0.9351    0.5803    0.4595
    0.9333    0.5738    0.4536
    0.9314    0.5673    0.4477
    0.9294    0.5608    0.4418
    0.9273    0.5542    0.4359
    0.9252    0.5475    0.4301
    0.9230    0.5408    0.4243
    0.9207    0.5340    0.4185
    0.9183    0.5272    0.4127
    0.9158    0.5203    0.4069
    0.9133    0.5134    0.4012
    0.9107    0.5064    0.3955
    0.9080    0.4993    0.3898
    0.9052    0.4923    0.3841
    0.9024    0.4851    0.3785
    0.8994    0.4779    0.3729
    0.8964    0.4707    0.3673
    0.8933    0.4633    0.3617
    0.8902    0.4560    0.3562
    0.8869    0.4486    0.3507
    0.8836    0.4411    0.3452
    0.8802    0.4336    0.3398
    0.8768    0.4260    0.3344
    0.8733    0.4183    0.3290
    0.8696    0.4106    0.3236
    0.8660    0.4029    0.3183
    0.8622    0.3951    0.3130
    0.8584    0.3872    0.3078
    0.8545    0.3792    0.3025
    0.8505    0.3712    0.2973
    0.8465    0.3631    0.2922
    0.8423    0.3550    0.2871
    0.8382    0.3467    0.2820
    0.8339    0.3384    0.2769
    0.8296    0.3300    0.2719
    0.8252    0.3215    0.2669
    0.8207    0.3130    0.2619
    0.8162    0.3043    0.2570
    0.8116    0.2955    0.2521
    0.8069    0.2866    0.2473
    0.8022    0.2776    0.2425
    0.7974    0.2685    0.2377
    0.7926    0.2592    0.2330
    0.7876    0.2498    0.2283
    0.7826    0.2402    0.2236
    0.7776    0.2305    0.2190
    0.7725    0.2205    0.2144
    0.7673    0.2102    0.2099
    0.7621    0.1998    0.2054
    0.7568    0.1890    0.2009
    0.7514    0.1778    0.1965
    0.7460    0.1662    0.1921
    0.7405    0.1541    0.1878
    0.7350    0.1414    0.1835
    0.7294    0.1279    0.1792
    0.7237    0.1134    0.1750
    0.7180    0.0975    0.1708
    0.7122    0.0797    0.1667
    0.7064    0.0586    0.1626
    0.7006    0.0316    0.1586
    0.6946    0.0030    0.1546
    ];

%interpolate values
xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');
