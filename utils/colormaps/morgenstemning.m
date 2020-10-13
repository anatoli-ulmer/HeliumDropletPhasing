% % % function cmap=morgenstemning(n,varargin)
% % % %MORGENSTEMNING Colormap that increases linearly in lightness (with colors)
% % % %
% % % %	Written by Matthias Geissbuehler - matthias.geissbuehler@a3.epfl.ch
% % % %	January 2013
% % % %
% % % %   Colormap that increases linearly in lightness (such as a pure black to white
% % % %   map) but incorporates additional colors that help to emphasize the
% % % %   transitions and hence enhance the perception of the data.
% % % %   This colormap is designed to be printer-friendly both for color printers as
% % % %   as well as B&W printers.
% % % %
% % % %   Credit: The idea of the passages over blue&red stems from ImageJ's LUT 'Fire'
% % % %   Our colormap corrects the color-printout-problems as well as the
% % % %   non-linearity in the fire-colormap which would make it incompatible
% % % %   with a B&W printing.
% % % %
% % % %
% % % %   See also: isolum, ametrine
% % % %
% % % %
% % % %   Please feel free to use this colormap at your own convenience.
% % % %   A citation to the original article is of course appreciated, however not "mandatory" :-)
% % % %   
% % % %   M. Geissbuehler and T. Lasser "How to display data by color schemes compatible
% % % %   with red-green color perception deficiencies" Opt. Express 21, 9862-9874 (2013)
% % % %   http://www.opticsinfobase.org/oe/abstract.cfm?URI=oe-21-8-9862
% % % %
% % % %
% % % %   For more detailed information, please see:
% % % %   http://lob.epfl.ch -> Research -> Color maps
% % % %
% % % %
% % % %   Usage:
% % % %   cmap = morgenstemning(n)
% % % %
% % % %   All arguments are optional:
% % % %
% % % %   n           The number of elements (256)
% % % %
% % % %   Further on, the following options can be applied
% % % %     'minColor' The absolute minimum value can have a different color
% % % %                ('none'), 'white','black','lightgray', 'darkgray'
% % % %                or any RGB value ex: [0 1 0]
% % % %     'maxColor' The absolute maximum value can have a different color
% % % %     'invert'   (0), 1=invert the whole colormap
% % % %     'gamma'    The gamma of the monitor to be used (1.8)
% % % %
% % % %
% % % %   Examples:
% % % %     figure; imagesc(peaks(200));
% % % %     colormap(morgenstemning)
% % % %     colorbar
% % % %
% % % %     figure; imagesc(peaks(200));
% % % %     colormap(morgenstemning(256,'minColor','black','maxColor',[0 1 0]))
% % % %     colorbar
% % % %
% % % %     figure; imagesc(peaks(200));
% % % %     colormap(morgenstemning(256,'invert',1,'minColor','darkgray'))
% % % %     colorbar
% % % %
% % % %
% % % %
% % % %
% % % % 
% % % %     Copyright (c) 2013, Matthias Geissbuehler
% % % %     All rights reserved.
% % % % 
% % % %     Redistribution and use in source and binary forms, with or without
% % % %     modification, are permitted provided that the following conditions are
% % % %     met:
% % % % 
% % % %         * Redistributions of source code must retain the above copyright
% % % %           notice, this list of conditions and the following disclaimer.
% % % %         * Redistributions in binary form must reproduce the above copyright
% % % %           notice, this list of conditions and the following disclaimer in
% % % %           the documentation and/or other materials provided with the distribution
% % % % 
% % % %     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% % % %     AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% % % %     IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% % % %     ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% % % %     LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% % % %     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% % % %     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% % % %     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% % % %     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% % % %     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% % % %     POSSIBILITY OF SUCH DAMAGE.
% % % 
% % % %   Copyright 2013 Matthias Geissbuehler - matthias.geissbuehler@a3.epfl.ch
% % % %   $Revision: 3.0 $  $Date: 2013/01/29 12:00:00 $
% % % p=inputParser;
% % % p.addParamValue('minColor','none');
% % % p.addParamValue('maxColor','none');
% % % p.addParamValue('invert',0, @(x)x==0 || x==1);
% % % p.addParamValue('gamma',1.8, @(x)x>0);
% % % 
% % % if nargin==1
% % %     p.addRequired('n', @(x)x>0 && mod(x,1)==0);
% % %     p.parse(n);
% % % elseif nargin>1
% % %     p.addRequired('n', @(x)x>0 && mod(x,1)==0);
% % %     p.parse(n, varargin{:});
% % % else
% % %     p.addParamValue('n',256, @(x)x>0 && mod(x,1)==0);
% % %     p.parse();
% % % end
% % % config = p.Results;
% % % n=config.n;
% % % 
% % % %the ControlPoints
% % % cP(:,1) = [0 0 0]./255;
% % % cP(:,2) = [25 53 95]./255;         %cyan
% % % cP(:,3) = [192 27 111]./255;       %redish-magenta
% % % cP(:,4) = [252 229 0]./255;        %yellow
% % % cP(:,5) = [255 255 255]./255;
% % % 
% % % number_of_elements_reached = false;
% % % last_n = size(cP,2);
% % % curr_n = last_n .* 2 - 1;
% % % last_cmap = double(cP');
% % % 
% % % % Normalization and smooth interpolation while keeping
% % % % strictly monotonically increasing gray-values:
% % % %
% % % % 1. interpolate 2x the number of points of the previous cmap (controlpoints)
% % % % 2. normalize all of them
% % % % 3. Loop from 1. until number of points is >n
% % % % 4. Interpolate to the correct number of points (n)
% % % 
% % % while ~number_of_elements_reached;
% % %     cmap = abs(interp1((1:last_n),last_cmap,linspace(1,last_n,curr_n),'pchip'));  % Interpolation between the control-Points
% % %     
% % %     checkIfAnyAbove1 = 1;
% % %     while checkIfAnyAbove1
% % %         % Normalization by calculation of the gray-value
% % %         % using the average RGB-value (gamma-corrected)
% % %         tempgraymap = mean(cmap.^config.gamma,2);
% % %         tempgraymap = tempgraymap .^(1/config.gamma);
% % %         cmap(:,1)=cmap(:,1)./tempgraymap.*linspace(0,1,curr_n)';
% % %         cmap(:,2)=cmap(:,2)./tempgraymap.*linspace(0,1,curr_n)';
% % %         cmap(:,3)=cmap(:,3)./tempgraymap.*linspace(0,1,curr_n)';
% % %         cmap(isnan(cmap))=0;
% % %         cmap = round(10000*cmap)./10000; % staying within reasonable required precision
% % %         
% % %         % check if during normalization any value is now bigger than 1
% % %         above1 = cmap>1;
% % %         if sum(above1(:))
% % %             mydiff = 0.025;
% % %             if sum(above1(:,1))  % any R>1 ?
% % %                 myIndexes = find(above1(:,1));
% % %                 cmap(myIndexes,1) = (1-mydiff) .* cmap(myIndexes,1);                          % remove a little bit
% % %                 cmap(myIndexes,2) = (mydiff/2) .* (1-cmap(myIndexes,2)) + cmap(myIndexes,2);  % add a little bit to other values
% % %                 cmap(myIndexes,3) = (mydiff/2) .* (1-cmap(myIndexes,3)) + cmap(myIndexes,3);  % add a little bit to other values
% % %             end
% % %             if sum(above1(:,2))  % any G>1 ?
% % %                 myIndexes = find(above1(:,2));
% % %                 cmap(myIndexes,2) = (1-mydiff) .* cmap(myIndexes,2);                          % remove a little bit
% % %                 cmap(myIndexes,1) = (mydiff/2) .* (1-cmap(myIndexes,1)) + cmap(myIndexes,1);  % add a little bit to other values
% % %                 cmap(myIndexes,3) = (mydiff/2) .* (1-cmap(myIndexes,3)) + cmap(myIndexes,3);  % add a little bit to other values
% % %             end
% % %             if sum(above1(:,3))  % any B>1 ?
% % %                 myIndexes = find(above1(:,3));
% % %                 cmap(myIndexes,3) = (1-mydiff) .* cmap(myIndexes,3);                          % remove a little bit
% % %                 cmap(myIndexes,1) = (mydiff/2) .* (1-cmap(myIndexes,1)) + cmap(myIndexes,1);  % add a little bit to other values
% % %                 cmap(myIndexes,2) = (mydiff/2) .* (1-cmap(myIndexes,2)) + cmap(myIndexes,2);  % add a little bit to other values
% % %             end
% % %             checkIfAnyAbove1 = 1;
% % %         else
% % %             checkIfAnyAbove1 = 0;
% % %         end
% % %     end
% % %     last_n = curr_n;
% % %     curr_n = last_n .* 2 - 1;
% % %     last_cmap = cmap;
% % %     if last_n > n
% % %         number_of_elements_reached = true;
% % %     end
% % % end
% % % cmap = abs(interp1((1:last_n),last_cmap,linspace(1,last_n,n)));
% % % 
% % % 
% % % % Additional modifications of the colormap
% % % if config.invert
% % %     cmap = flipud(cmap);
% % % end
% % % 
% % % if ischar(config.minColor)
% % %     if ~strcmp(config.minColor,'none')
% % %         switch config.minColor
% % %             case 'white'
% % %                 cmap(1,:) = [1 1 1];
% % %             case 'black'
% % %                 cmap(1,:) = [0 0 0];
% % %             case 'lightgray'
% % %                 cmap(1,:) = [0.8 0.8 0.8];
% % %             case 'darkgray'
% % %                 cmap(1,:) = [0.2 0.2 0.2];
% % %         end
% % %     end
% % % else
% % %     cmap(1,:) = config.minColor;
% % % end
% % % if ischar(config.maxColor)
% % %     if ~strcmp(config.maxColor,'none')
% % %         switch config.maxColor
% % %             case 'white'
% % %                 cmap(end,:) = [1 1 1];
% % %             case 'black'
% % %                 cmap(end,:) = [0 0 0];
% % %             case 'lightgray'
% % %                 cmap(end,:) = [0.8 0.8 0.8];
% % %             case 'darkgray'
% % %                 cmap(end,:) = [0.2 0.2 0.2];
% % %         end
% % %     end
% % % else
% % %     cmap(end,:) = config.maxColor;
% % % end

function p = morgenstemning(m)
% % % %MORGENSTEMNING Colormap that increases linearly in lightness (with colors)
% % % %
% % % %	Written by Matthias Geissbuehler - matthias.geissbuehler@a3.epfl.ch
% % % %	January 2013
% % % %
% % % %   Colormap that increases linearly in lightness (such as a pure black to white
% % % %   map) but incorporates additional colors that help to emphasize the
% % % %   transitions and hence enhance the perception of the data.
% % % %   This colormap is designed to be printer-friendly both for color printers as
% % % %   as well as B&W printers.
% % % %
% % % %   Credit: The idea of the passages over blue&red stems from ImageJ's LUT 'Fire'
% % % %   Our colormap corrects the color-printout-problems as well as the
% % % %   non-linearity in the fire-colormap which would make it incompatible
% % % %   with a B&W printing.
% % % %
% % % %
% % % %   See also: isolum, ametrine
% % % %
% % % %
% % % %   Please feel free to use this colormap at your own convenience.
% % % %   A citation to the original article is of course appreciated, however not "mandatory" :-)
% % % %   
% % % %   M. Geissbuehler and T. Lasser "How to display data by color schemes compatible
% % % %   with red-green color perception deficiencies" Opt. Express 21, 9862-9874 (2013)
% % % %   http://www.opticsinfobase.org/oe/abstract.cfm?URI=oe-21-8-9862
% % % %
% % % %
% % % %   For more detailed information, please see:
% % % %   http://lob.epfl.ch -> Research -> Color maps
% % % %
% % % %
% % % %   Usage:
% % % %   cmap = morgenstemning(n)
% % % %
% % % %   All arguments are optional:
% % % %
% % % %   n           The number of elements (256)
% % % %
% % % %   Further on, the following options can be applied
% % % %     'minColor' The absolute minimum value can have a different color
% % % %                ('none'), 'white','black','lightgray', 'darkgray'
% % % %                or any RGB value ex: [0 1 0]
% % % %     'maxColor' The absolute maximum value can have a different color
% % % %     'invert'   (0), 1=invert the whole colormap
% % % %     'gamma'    The gamma of the monitor to be used (1.8)
% % % %
% % % %
% % % %   Examples:
% % % %     figure; imagesc(peaks(200));
% % % %     colormap(morgenstemning)
% % % %     colorbar
% % % %
% % % %     figure; imagesc(peaks(200));
% % % %     colormap(morgenstemning(256,'minColor','black','maxColor',[0 1 0]))
% % % %     colorbar
% % % %
% % % %     figure; imagesc(peaks(200));
% % % %     colormap(morgenstemning(256,'invert',1,'minColor','darkgray'))
% % % %     colorbar
% % % %
% % % %
% % % %
% % % %
% % % % 
% % % %     Copyright (c) 2013, Matthias Geissbuehler
% % % %     All rights reserved.
% % % % 
% % % %     Redistribution and use in source and binary forms, with or without
% % % %     modification, are permitted provided that the following conditions are
% % % %     met:
% % % % 
% % % %         * Redistributions of source code must retain the above copyright
% % % %           notice, this list of conditions and the following disclaimer.
% % % %         * Redistributions in binary form must reproduce the above copyright
% % % %           notice, this list of conditions and the following disclaimer in
% % % %           the documentation and/or other materials provided with the distribution
% % % % 
% % % %     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% % % %     AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% % % %     IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% % % %     ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% % % %     LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% % % %     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% % % %     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% % % %     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% % % %     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% % % %     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% % % %     POSSIBILITY OF SUCH DAMAGE.
% % % 
% % % %   Copyright 2013 Matthias Geissbuehler - matthias.geissbuehler@a3.epfl.ch
% % % %   $Revision: 3.0 $  $Date: 2013/01/29 12:00:00 $

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cmap_mat = [
        0         0         0
    0.0003    0.0040    0.0057
    0.0005    0.0079    0.0114
    0.0007    0.0118    0.0172
    0.0010    0.0158    0.0230
    0.0013    0.0196    0.0287
    0.0016    0.0235    0.0345
    0.0020    0.0274    0.0403
    0.0024    0.0312    0.0461
    0.0028    0.0350    0.0519
    0.0032    0.0388    0.0577
    0.0037    0.0427    0.0636
    0.0042    0.0465    0.0694
    0.0047    0.0502    0.0752
    0.0053    0.0539    0.0810
    0.0059    0.0576    0.0869
    0.0065    0.0613    0.0929
    0.0072    0.0649    0.0988
    0.0079    0.0685    0.1047
    0.0087    0.0721    0.1106
    0.0095    0.0757    0.1166
    0.0103    0.0793    0.1225
    0.0112    0.0828    0.1284
    0.0121    0.0863    0.1343
    0.0130    0.0898    0.1404
    0.0140    0.0933    0.1463
    0.0150    0.0968    0.1522
    0.0160    0.1003    0.1582
    0.0171    0.1037    0.1642
    0.0182    0.1072    0.1702
    0.0194    0.1106    0.1761
    0.0206    0.1140    0.1820
    0.0219    0.1174    0.1879
    0.0231    0.1210    0.1939
    0.0244    0.1245    0.1997
    0.0257    0.1280    0.2056
    0.0270    0.1315    0.2114
    0.0284    0.1350    0.2173
    0.0298    0.1384    0.2232
    0.0312    0.1418    0.2291
    0.0328    0.1452    0.2349
    0.0344    0.1485    0.2408
    0.0361    0.1518    0.2468
    0.0378    0.1551    0.2527
    0.0396    0.1583    0.2587
    0.0415    0.1615    0.2646
    0.0435    0.1647    0.2706
    0.0455    0.1678    0.2765
    0.0476    0.1710    0.2824
    0.0497    0.1742    0.2882
    0.0520    0.1774    0.2940
    0.0543    0.1805    0.2999
    0.0567    0.1836    0.3057
    0.0593    0.1865    0.3115
    0.0620    0.1894    0.3174
    0.0648    0.1921    0.3234
    0.0678    0.1948    0.3293
    0.0709    0.1975    0.3352
    0.0742    0.1999    0.3411
    0.0778    0.2023    0.3471
    0.0815    0.2044    0.3530
    0.0856    0.2063    0.3590
    0.0900    0.2079    0.3651
    0.0949    0.2091    0.3711
    0.1005    0.2097    0.3774
    0.1069    0.2098    0.3835
    0.1140    0.2098    0.3894
    0.1217    0.2097    0.3950
    0.1300    0.2095    0.4004
    0.1386    0.2093    0.4054
    0.1477    0.2090    0.4101
    0.1572    0.2086    0.4146
    0.1670    0.2082    0.4188
    0.1771    0.2077    0.4228
    0.1874    0.2071    0.4265
    0.1981    0.2065    0.4298
    0.2090    0.2058    0.4330
    0.2202    0.2049    0.4358
    0.2316    0.2040    0.4384
    0.2431    0.2030    0.4408
    0.2547    0.2018    0.4429
    0.2664    0.2006    0.4449
    0.2781    0.1993    0.4467
    0.2899    0.1979    0.4483
    0.3018    0.1965    0.4497
    0.3138    0.1949    0.4509
    0.3257    0.1932    0.4519
    0.3378    0.1914    0.4528
    0.3499    0.1894    0.4535
    0.3620    0.1873    0.4541
    0.3740    0.1851    0.4545
    0.3860    0.1828    0.4549
    0.3980    0.1804    0.4552
    0.4098    0.1779    0.4554
    0.4216    0.1754    0.4555
    0.4333    0.1728    0.4556
    0.4448    0.1703    0.4556
    0.4562    0.1678    0.4556
    0.4675    0.1654    0.4555
    0.4787    0.1630    0.4553
    0.4898    0.1606    0.4551
    0.5008    0.1581    0.4549
    0.5116    0.1556    0.4547
    0.5224    0.1532    0.4545
    0.5331    0.1508    0.4542
    0.5437    0.1484    0.4538
    0.5543    0.1460    0.4534
    0.5648    0.1436    0.4530
    0.5752    0.1412    0.4526
    0.5855    0.1389    0.4521
    0.5957    0.1366    0.4516
    0.6059    0.1343    0.4511
    0.6159    0.1320    0.4506
    0.6259    0.1297    0.4502
    0.6358    0.1274    0.4497
    0.6456    0.1251    0.4493
    0.6553    0.1229    0.4488
    0.6650    0.1209    0.4483
    0.6746    0.1190    0.4478
    0.6841    0.1172    0.4472
    0.6935    0.1154    0.4467
    0.7029    0.1137    0.4461
    0.7122    0.1122    0.4455
    0.7215    0.1109    0.4449
    0.7307    0.1098    0.4443
    0.7399    0.1088    0.4435
    0.7491    0.1080    0.4427
    0.7583    0.1075    0.4417
    0.7675    0.1083    0.4401
    0.7767    0.1113    0.4378
    0.7859    0.1159    0.4349
    0.7950    0.1217    0.4315
    0.8040    0.1286    0.4277
    0.8129    0.1364    0.4236
    0.8217    0.1452    0.4190
    0.8303    0.1549    0.4141
    0.8387    0.1651    0.4089
    0.8469    0.1757    0.4036
    0.8548    0.1869    0.3980
    0.8625    0.1989    0.3921
    0.8700    0.2115    0.3859
    0.8771    0.2249    0.3794
    0.8839    0.2386    0.3726
    0.8905    0.2527    0.3655
    0.8968    0.2668    0.3584
    0.9029    0.2809    0.3512
    0.9088    0.2952    0.3439
    0.9143    0.3097    0.3364
    0.9196    0.3244    0.3287
    0.9245    0.3394    0.3208
    0.9291    0.3547    0.3127
    0.9334    0.3702    0.3045
    0.9374    0.3859    0.2960
    0.9410    0.4019    0.2873
    0.9443    0.4180    0.2784
    0.9474    0.4341    0.2694
    0.9503    0.4502    0.2603
    0.9528    0.4664    0.2510
    0.9551    0.4824    0.2417
    0.9572    0.4982    0.2324
    0.9592    0.5138    0.2230
    0.9610    0.5291    0.2136
    0.9627    0.5442    0.2041
    0.9643    0.5592    0.1948
    0.9656    0.5740    0.1854
    0.9669    0.5886    0.1761
    0.9680    0.6030    0.1668
    0.9689    0.6172    0.1576
    0.9697    0.6313    0.1486
    0.9705    0.6451    0.1398
    0.9710    0.6587    0.1310
    0.9715    0.6721    0.1224
    0.9720    0.6852    0.1139
    0.9725    0.6981    0.1056
    0.9729    0.7107    0.0975
    0.9733    0.7231    0.0894
    0.9737    0.7354    0.0813
    0.9741    0.7473    0.0732
    0.9746    0.7589    0.0654
    0.9750    0.7704    0.0578
    0.9754    0.7816    0.0507
    0.9758    0.7926    0.0439
    0.9763    0.8034    0.0376
    0.9768    0.8140    0.0316
    0.9773    0.8244    0.0257
    0.9780    0.8345    0.0203
    0.9787    0.8443    0.0154
    0.9795    0.8541    0.0111
    0.9804    0.8636    0.0073
    0.9813    0.8730    0.0041
    0.9822    0.8823    0.0017
    0.9832    0.8914    0.0003
    0.9842    0.9006    0.0024
    0.9851    0.9098    0.0081
    0.9860    0.9187    0.0162
    0.9870    0.9273    0.0266
    0.9880    0.9354    0.0382
    0.9890    0.9432    0.0514
    0.9900    0.9507    0.0663
    0.9909    0.9576    0.0824
    0.9917    0.9643    0.0988
    0.9925    0.9705    0.1157
    0.9934    0.9762    0.1336
    0.9942    0.9812    0.1524
    0.9950    0.9857    0.1724
    0.9957    0.9895    0.1933
    0.9964    0.9925    0.2151
    0.9971    0.9948    0.2378
    0.9980    0.9962    0.2616
    0.9986    0.9969    0.2861
    0.9989    0.9972    0.3108
    0.9989    0.9973    0.3356
    0.9987    0.9971    0.3604
    0.9982    0.9967    0.3845
    0.9976    0.9963    0.4081
    0.9972    0.9959    0.4303
    0.9970    0.9958    0.4506
    0.9971    0.9960    0.4694
    0.9972    0.9962    0.4875
    0.9973    0.9965    0.5050
    0.9975    0.9968    0.5221
    0.9976    0.9970    0.5388
    0.9978    0.9973    0.5551
    0.9979    0.9975    0.5713
    0.9979    0.9976    0.5874
    0.9979    0.9976    0.6034
    0.9979    0.9977    0.6192
    0.9979    0.9977    0.6347
    0.9979    0.9978    0.6499
    0.9979    0.9978    0.6649
    0.9980    0.9979    0.6797
    0.9980    0.9979    0.6941
    0.9981    0.9980    0.7083
    0.9982    0.9982    0.7223
    0.9983    0.9983    0.7361
    0.9985    0.9985    0.7496
    0.9987    0.9987    0.7630
    0.9988    0.9988    0.7763
    0.9990    0.9989    0.7894
    0.9991    0.9990    0.8026
    0.9992    0.9991    0.8157
    0.9992    0.9991    0.8288
    0.9992    0.9991    0.8417
    0.9992    0.9991    0.8547
    0.9992    0.9991    0.8675
    0.9992    0.9991    0.8801
    0.9992    0.9991    0.8927
    0.9992    0.9992    0.9050
    0.9993    0.9993    0.9173
    0.9993    0.9993    0.9294
    0.9994    0.9994    0.9415
    0.9995    0.9995    0.9534
    0.9996    0.9996    0.9652
    0.9997    0.9997    0.9769
    0.9998    0.9998    0.9886
    1.0000    1.0000    1.0000
    ];

%interpolate values
xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');
