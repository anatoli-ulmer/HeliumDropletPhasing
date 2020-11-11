function p = ibentcoolwarm(m)
%iBENTCOOLWARM    colormap

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cmap_mat = [
        0.6946    0.0030    0.1546
    0.6973    0.0327    0.1579
    0.7000    0.0599    0.1613
    0.7026    0.0809    0.1647
    0.7052    0.0984    0.1682
    0.7079    0.1139    0.1717
    0.7105    0.1279    0.1753
    0.7131    0.1408    0.1790
    0.7156    0.1529    0.1827
    0.7182    0.1643    0.1864
    0.7207    0.1752    0.1902
    0.7233    0.1856    0.1941
    0.7258    0.1956    0.1980
    0.7283    0.2053    0.2020
    0.7308    0.2146    0.2060
    0.7333    0.2238    0.2101
    0.7358    0.2327    0.2142
    0.7382    0.2414    0.2183
    0.7407    0.2499    0.2226
    0.7431    0.2582    0.2268
    0.7455    0.2664    0.2312
    0.7479    0.2745    0.2355
    0.7503    0.2825    0.2400
    0.7527    0.2903    0.2444
    0.7551    0.2980    0.2490
    0.7574    0.3057    0.2535
    0.7598    0.3132    0.2581
    0.7621    0.3207    0.2628
    0.7644    0.3281    0.2675
    0.7667    0.3354    0.2723
    0.7690    0.3426    0.2771
    0.7713    0.3498    0.2820
    0.7736    0.3570    0.2869
    0.7758    0.3640    0.2918
    0.7781    0.3710    0.2968
    0.7803    0.3780    0.3019
    0.7825    0.3850    0.3070
    0.7848    0.3918    0.3121
    0.7870    0.3987    0.3173
    0.7891    0.4055    0.3225
    0.7913    0.4123    0.3278
    0.7935    0.4190    0.3332
    0.7956    0.4257    0.3385
    0.7978    0.4324    0.3439
    0.7999    0.4390    0.3494
    0.8020    0.4456    0.3549
    0.8041    0.4522    0.3605
    0.8062    0.4588    0.3661
    0.8083    0.4653    0.3717
    0.8104    0.4719    0.3774
    0.8124    0.4783    0.3831
    0.8145    0.4848    0.3889
    0.8165    0.4913    0.3947
    0.8186    0.4977    0.4006
    0.8206    0.5041    0.4065
    0.8226    0.5105    0.4125
    0.8246    0.5169    0.4184
    0.8266    0.5233    0.4245
    0.8286    0.5296    0.4306
    0.8305    0.5359    0.4367
    0.8325    0.5423    0.4429
    0.8344    0.5486    0.4491
    0.8364    0.5549    0.4553
    0.8383    0.5611    0.4616
    0.8402    0.5674    0.4679
    0.8421    0.5736    0.4743
    0.8440    0.5799    0.4807
    0.8459    0.5861    0.4872
    0.8478    0.5923    0.4937
    0.8497    0.5985    0.5003
    0.8516    0.6047    0.5068
    0.8534    0.6109    0.5135
    0.8553    0.6171    0.5201
    0.8571    0.6233    0.5268
    0.8589    0.6294    0.5336
    0.8608    0.6356    0.5404
    0.8626    0.6417    0.5472
    0.8644    0.6479    0.5541
    0.8662    0.6540    0.5610
    0.8680    0.6601    0.5680
    0.8698    0.6662    0.5749
    0.8715    0.6723    0.5820
    0.8733    0.6784    0.5890
    0.8751    0.6845    0.5962
    0.8768    0.6906    0.6033
    0.8786    0.6967    0.6105
    0.8803    0.7027    0.6177
    0.8821    0.7088    0.6250
    0.8838    0.7149    0.6323
    0.8855    0.7209    0.6396
    0.8873    0.7270    0.6470
    0.8890    0.7330    0.6544
    0.8907    0.7390    0.6619
    0.8924    0.7451    0.6694
    0.8941    0.7511    0.6769
    0.8958    0.7571    0.6845
    0.8975    0.7631    0.6921
    0.8992    0.7691    0.6997
    0.9009    0.7751    0.7074
    0.9025    0.7811    0.7151
    0.9042    0.7871    0.7229
    0.9059    0.7931    0.7307
    0.9076    0.7991    0.7385
    0.9092    0.8050    0.7464
    0.9109    0.8110    0.7543
    0.9126    0.8170    0.7622
    0.9142    0.8229    0.7702
    0.9159    0.8289    0.7782
    0.9176    0.8348    0.7863
    0.9192    0.8408    0.7943
    0.9209    0.8467    0.8025
    0.9225    0.8527    0.8106
    0.9242    0.8586    0.8188
    0.9258    0.8645    0.8270
    0.9275    0.8704    0.8353
    0.9291    0.8764    0.8435
    0.9308    0.8823    0.8519
    0.9325    0.8882    0.8602
    0.9341    0.8941    0.8686
    0.9358    0.9000    0.8770
    0.9375    0.9059    0.8855
    0.9391    0.9118    0.8940
    0.9408    0.9177    0.9025
    0.9425    0.9236    0.9110
    0.9441    0.9294    0.9196
    0.9458    0.9353    0.9283
    0.9475    0.9412    0.9369
    0.9492    0.9471    0.9456
    0.9466    0.9475    0.9495
    0.9396    0.9427    0.9485
    0.9328    0.9378    0.9476
    0.9259    0.9328    0.9466
    0.9191    0.9279    0.9457
    0.9123    0.9230    0.9448
    0.9056    0.9181    0.9438
    0.8988    0.9131    0.9429
    0.8922    0.9082    0.9419
    0.8855    0.9033    0.9410
    0.8789    0.8983    0.9400
    0.8723    0.8933    0.9391
    0.8657    0.8884    0.9381
    0.8592    0.8834    0.9372
    0.8527    0.8784    0.9362
    0.8463    0.8735    0.9352
    0.8399    0.8685    0.9343
    0.8335    0.8635    0.9333
    0.8271    0.8585    0.9323
    0.8208    0.8535    0.9314
    0.8145    0.8485    0.9304
    0.8083    0.8435    0.9294
    0.8021    0.8384    0.9284
    0.7959    0.8334    0.9274
    0.7897    0.8284    0.9264
    0.7836    0.8233    0.9254
    0.7775    0.8183    0.9244
    0.7715    0.8133    0.9234
    0.7654    0.8082    0.9223
    0.7595    0.8032    0.9213
    0.7535    0.7981    0.9203
    0.7476    0.7930    0.9192
    0.7417    0.7880    0.9182
    0.7359    0.7829    0.9171
    0.7300    0.7778    0.9160
    0.7243    0.7727    0.9150
    0.7185    0.7676    0.9139
    0.7128    0.7625    0.9128
    0.7071    0.7574    0.9117
    0.7015    0.7523    0.9106
    0.6958    0.7472    0.9095
    0.6903    0.7421    0.9083
    0.6847    0.7370    0.9072
    0.6792    0.7319    0.9061
    0.6737    0.7268    0.9049
    0.6683    0.7216    0.9037
    0.6629    0.7165    0.9026
    0.6575    0.7113    0.9014
    0.6521    0.7062    0.9002
    0.6468    0.7011    0.8990
    0.6415    0.6959    0.8978
    0.6363    0.6908    0.8965
    0.6311    0.6856    0.8953
    0.6259    0.6804    0.8941
    0.6208    0.6753    0.8928
    0.6156    0.6701    0.8915
    0.6106    0.6649    0.8902
    0.6055    0.6597    0.8889
    0.6005    0.6546    0.8876
    0.5955    0.6494    0.8863
    0.5906    0.6442    0.8850
    0.5857    0.6390    0.8836
    0.5808    0.6338    0.8822
    0.5760    0.6286    0.8809
    0.5712    0.6234    0.8795
    0.5664    0.6182    0.8781
    0.5616    0.6130    0.8766
    0.5569    0.6077    0.8752
    0.5523    0.6025    0.8738
    0.5476    0.5973    0.8723
    0.5430    0.5921    0.8708
    0.5384    0.5868    0.8693
    0.5339    0.5816    0.8678
    0.5294    0.5763    0.8663
    0.5249    0.5711    0.8647
    0.5205    0.5658    0.8632
    0.5161    0.5606    0.8616
    0.5117    0.5553    0.8600
    0.5074    0.5501    0.8584
    0.5031    0.5448    0.8568
    0.4988    0.5395    0.8552
    0.4946    0.5342    0.8535
    0.4904    0.5290    0.8518
    0.4862    0.5237    0.8501
    0.4820    0.5184    0.8484
    0.4779    0.5131    0.8467
    0.4739    0.5078    0.8450
    0.4698    0.5025    0.8432
    0.4658    0.4972    0.8414
    0.4619    0.4918    0.8396
    0.4579    0.4865    0.8378
    0.4540    0.4812    0.8360
    0.4501    0.4759    0.8342
    0.4463    0.4705    0.8323
    0.4425    0.4652    0.8304
    0.4387    0.4598    0.8285
    0.4350    0.4545    0.8266
    0.4313    0.4491    0.8246
    0.4276    0.4437    0.8226
    0.4239    0.4383    0.8207
    0.4203    0.4330    0.8187
    0.4167    0.4276    0.8166
    0.4132    0.4222    0.8146
    0.4097    0.4167    0.8125
    0.4062    0.4113    0.8104
    0.4028    0.4059    0.8083
    0.3993    0.4005    0.8062
    0.3960    0.3950    0.8040
    0.3926    0.3896    0.8019
    0.3893    0.3841    0.7997
    0.3860    0.3786    0.7975
    0.3827    0.3731    0.7952
    0.3795    0.3676    0.7930
    0.3763    0.3621    0.7907
    0.3731    0.3566    0.7884
    0.3700    0.3510    0.7861
    0.3669    0.3455    0.7837
    0.3638    0.3399    0.7814
    0.3608    0.3343    0.7790
    0.3578    0.3287    0.7766
    0.3548    0.3231    0.7742
    0.3519    0.3174    0.7717
    0.3489    0.3118    0.7692
    0.3460    0.3061    0.7667
    0.3432    0.3004    0.7642
    0.3404    0.2946    0.7617
    0.3376    0.2889    0.7591
    0.3348    0.2831    0.7565
    ];

%interpolate values
xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');
