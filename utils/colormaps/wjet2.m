function cm = wjet2(m)

%% CALCULATION OF WJET ARRAY
% j = colormap(jet);
% startcol = [1,1,1];
% endcol = j(1,:);
% diffcol = endcol-startcol;
% nsteps = 64;
% cm = nan(nsteps,3);
% for i=1:nsteps
%     cm(i,:) = startcol + diffcol.*i/nsteps;
% end
% cm = [startcol; cm; j];
% nColors = size(cm,1);
% cInd = 1:nColors;
% qInd = linspace(1,m,m)/m*nColors;
% r = interp1(cInd, cm(:,1), qInd);
% g = interp1(cInd, cm(:,2), qInd);
% b = interp1(cInd, cm(:,3), qInd);
% cm = [r',g',b'];

%%
if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

% cm = [1,1,1;0.984375000000000,0.984375000000000,0.992431640625000;0.968750000000000,0.968750000000000,0.984863281250000;0.953125000000000,0.953125000000000,0.977294921875000;0.937500000000000,0.937500000000000,0.969726562500000;0.921875000000000,0.921875000000000,0.962158203125000;0.906250000000000,0.906250000000000,0.954589843750000;0.890625000000000,0.890625000000000,0.947021484375000;0.875000000000000,0.875000000000000,0.939453125000000;0.859375000000000,0.859375000000000,0.931884765625000;0.843750000000000,0.843750000000000,0.924316406250000;0.828125000000000,0.828125000000000,0.916748046875000;0.812500000000000,0.812500000000000,0.909179687500000;0.796875000000000,0.796875000000000,0.901611328125000;0.781250000000000,0.781250000000000,0.894042968750000;0.765625000000000,0.765625000000000,0.886474609375000;0.750000000000000,0.750000000000000,0.878906250000000;0.734375000000000,0.734375000000000,0.871337890625000;0.718750000000000,0.718750000000000,0.863769531250000;0.703125000000000,0.703125000000000,0.856201171875000;0.687500000000000,0.687500000000000,0.848632812500000;0.671875000000000,0.671875000000000,0.841064453125000;0.656250000000000,0.656250000000000,0.833496093750000;0.640625000000000,0.640625000000000,0.825927734375000;0.625000000000000,0.625000000000000,0.818359375000000;0.609375000000000,0.609375000000000,0.810791015625000;0.593750000000000,0.593750000000000,0.803222656250000;0.578125000000000,0.578125000000000,0.795654296875000;0.562500000000000,0.562500000000000,0.788085937500000;0.546875000000000,0.546875000000000,0.780517578125000;0.531250000000000,0.531250000000000,0.772949218750000;0.515625000000000,0.515625000000000,0.765380859375000;0.500000000000000,0.500000000000000,0.757812500000000;0.484375000000000,0.484375000000000,0.750244140625000;0.468750000000000,0.468750000000000,0.742675781250000;0.453125000000000,0.453125000000000,0.735107421875000;0.437500000000000,0.437500000000000,0.727539062500000;0.421875000000000,0.421875000000000,0.719970703125000;0.406250000000000,0.406250000000000,0.712402343750000;0.390625000000000,0.390625000000000,0.704833984375000;0.375000000000000,0.375000000000000,0.697265625000000;0.359375000000000,0.359375000000000,0.689697265625000;0.343750000000000,0.343750000000000,0.682128906250000;0.328125000000000,0.328125000000000,0.674560546875000;0.312500000000000,0.312500000000000,0.666992187500000;0.296875000000000,0.296875000000000,0.659423828125000;0.281250000000000,0.281250000000000,0.651855468750000;0.265625000000000,0.265625000000000,0.644287109375000;0.250000000000000,0.250000000000000,0.636718750000000;0.234375000000000,0.234375000000000,0.629150390625000;0.218750000000000,0.218750000000000,0.621582031250000;0.203125000000000,0.203125000000000,0.614013671875000;0.187500000000000,0.187500000000000,0.606445312500000;0.171875000000000,0.171875000000000,0.598876953125000;0.156250000000000,0.156250000000000,0.591308593750000;0.140625000000000,0.140625000000000,0.583740234375000;0.125000000000000,0.125000000000000,0.576171875000000;0.109375000000000,0.109375000000000,0.568603515625000;0.0937500000000000,0.0937500000000000,0.561035156250000;0.0781250000000000,0.0781250000000000,0.553466796875000;0.0625000000000000,0.0625000000000000,0.545898437500000;0.0468750000000000,0.0468750000000000,0.538330078125000;0.0312500000000000,0.0312500000000000,0.530761718750000;0.0156250000000000,0.0156250000000000,0.523193359375000;0,0,0.515625000000000;0,0,0.515625000000000;0,0,0.531250000000000;0,0,0.546875000000000;0,0,0.562500000000000;0,0,0.578125000000000;0,0,0.593750000000000;0,0,0.609375000000000;0,0,0.625000000000000;0,0,0.640625000000000;0,0,0.656250000000000;0,0,0.671875000000000;0,0,0.687500000000000;0,0,0.703125000000000;0,0,0.718750000000000;0,0,0.734375000000000;0,0,0.750000000000000;0,0,0.765625000000000;0,0,0.781250000000000;0,0,0.796875000000000;0,0,0.812500000000000;0,0,0.828125000000000;0,0,0.843750000000000;0,0,0.859375000000000;0,0,0.875000000000000;0,0,0.890625000000000;0,0,0.906250000000000;0,0,0.921875000000000;0,0,0.937500000000000;0,0,0.953125000000000;0,0,0.968750000000000;0,0,0.984375000000000;0,0,1;0,0.0156250000000000,1;0,0.0312500000000000,1;0,0.0468750000000000,1;0,0.0625000000000000,1;0,0.0781250000000000,1;0,0.0937500000000000,1;0,0.109375000000000,1;0,0.125000000000000,1;0,0.140625000000000,1;0,0.156250000000000,1;0,0.171875000000000,1;0,0.187500000000000,1;0,0.203125000000000,1;0,0.218750000000000,1;0,0.234375000000000,1;0,0.250000000000000,1;0,0.265625000000000,1;0,0.281250000000000,1;0,0.296875000000000,1;0,0.312500000000000,1;0,0.328125000000000,1;0,0.343750000000000,1;0,0.359375000000000,1;0,0.375000000000000,1;0,0.390625000000000,1;0,0.406250000000000,1;0,0.421875000000000,1;0,0.437500000000000,1;0,0.453125000000000,1;0,0.468750000000000,1;0,0.484375000000000,1;0,0.500000000000000,1;0,0.515625000000000,1;0,0.531250000000000,1;0,0.546875000000000,1;0,0.562500000000000,1;0,0.578125000000000,1;0,0.593750000000000,1;0,0.609375000000000,1;0,0.625000000000000,1;0,0.640625000000000,1;0,0.656250000000000,1;0,0.671875000000000,1;0,0.687500000000000,1;0,0.703125000000000,1;0,0.718750000000000,1;0,0.734375000000000,1;0,0.750000000000000,1;0,0.765625000000000,1;0,0.781250000000000,1;0,0.796875000000000,1;0,0.812500000000000,1;0,0.828125000000000,1;0,0.843750000000000,1;0,0.859375000000000,1;0,0.875000000000000,1;0,0.890625000000000,1;0,0.906250000000000,1;0,0.921875000000000,1;0,0.937500000000000,1;0,0.953125000000000,1;0,0.968750000000000,1;0,0.984375000000000,1;0,1,1;0.0156250000000000,1,0.984375000000000;0.0312500000000000,1,0.968750000000000;0.0468750000000000,1,0.953125000000000;0.0625000000000000,1,0.937500000000000;0.0781250000000000,1,0.921875000000000;0.0937500000000000,1,0.906250000000000;0.109375000000000,1,0.890625000000000;0.125000000000000,1,0.875000000000000;0.140625000000000,1,0.859375000000000;0.156250000000000,1,0.843750000000000;0.171875000000000,1,0.828125000000000;0.187500000000000,1,0.812500000000000;0.203125000000000,1,0.796875000000000;0.218750000000000,1,0.781250000000000;0.234375000000000,1,0.765625000000000;0.250000000000000,1,0.750000000000000;0.265625000000000,1,0.734375000000000;0.281250000000000,1,0.718750000000000;0.296875000000000,1,0.703125000000000;0.312500000000000,1,0.687500000000000;0.328125000000000,1,0.671875000000000;0.343750000000000,1,0.656250000000000;0.359375000000000,1,0.640625000000000;0.375000000000000,1,0.625000000000000;0.390625000000000,1,0.609375000000000;0.406250000000000,1,0.593750000000000;0.421875000000000,1,0.578125000000000;0.437500000000000,1,0.562500000000000;0.453125000000000,1,0.546875000000000;0.468750000000000,1,0.531250000000000;0.484375000000000,1,0.515625000000000;0.500000000000000,1,0.500000000000000;0.515625000000000,1,0.484375000000000;0.531250000000000,1,0.468750000000000;0.546875000000000,1,0.453125000000000;0.562500000000000,1,0.437500000000000;0.578125000000000,1,0.421875000000000;0.593750000000000,1,0.406250000000000;0.609375000000000,1,0.390625000000000;0.625000000000000,1,0.375000000000000;0.640625000000000,1,0.359375000000000;0.656250000000000,1,0.343750000000000;0.671875000000000,1,0.328125000000000;0.687500000000000,1,0.312500000000000;0.703125000000000,1,0.296875000000000;0.718750000000000,1,0.281250000000000;0.734375000000000,1,0.265625000000000;0.750000000000000,1,0.250000000000000;0.765625000000000,1,0.234375000000000;0.781250000000000,1,0.218750000000000;0.796875000000000,1,0.203125000000000;0.812500000000000,1,0.187500000000000;0.828125000000000,1,0.171875000000000;0.843750000000000,1,0.156250000000000;0.859375000000000,1,0.140625000000000;0.875000000000000,1,0.125000000000000;0.890625000000000,1,0.109375000000000;0.906250000000000,1,0.0937500000000000;0.921875000000000,1,0.0781250000000000;0.937500000000000,1,0.0625000000000000;0.953125000000000,1,0.0468750000000000;0.968750000000000,1,0.0312500000000000;0.984375000000000,1,0.0156250000000000;1,1,0;1,0.984375000000000,0;1,0.968750000000000,0;1,0.953125000000000,0;1,0.937500000000000,0;1,0.921875000000000,0;1,0.906250000000000,0;1,0.890625000000000,0;1,0.875000000000000,0;1,0.859375000000000,0;1,0.843750000000000,0;1,0.828125000000000,0;1,0.812500000000000,0;1,0.796875000000000,0;1,0.781250000000000,0;1,0.765625000000000,0;1,0.750000000000000,0;1,0.734375000000000,0;1,0.718750000000000,0;1,0.703125000000000,0;1,0.687500000000000,0;1,0.671875000000000,0;1,0.656250000000000,0;1,0.640625000000000,0;1,0.625000000000000,0;1,0.609375000000000,0;1,0.593750000000000,0;1,0.578125000000000,0;1,0.562500000000000,0;1,0.546875000000000,0;1,0.531250000000000,0;1,0.515625000000000,0;1,0.500000000000000,0;1,0.484375000000000,0;1,0.468750000000000,0;1,0.453125000000000,0;1,0.437500000000000,0;1,0.421875000000000,0;1,0.406250000000000,0;1,0.390625000000000,0;1,0.375000000000000,0;1,0.359375000000000,0;1,0.343750000000000,0;1,0.328125000000000,0;1,0.312500000000000,0;1,0.296875000000000,0;1,0.281250000000000,0;1,0.265625000000000,0;1,0.250000000000000,0;1,0.234375000000000,0;1,0.218750000000000,0;1,0.203125000000000,0;1,0.187500000000000,0;1,0.171875000000000,0;1,0.156250000000000,0;1,0.140625000000000,0;1,0.125000000000000,0;1,0.109375000000000,0;1,0.0937500000000000,0;1,0.0781250000000000,0;1,0.0625000000000000,0;1,0.0468750000000000,0;1,0.0312500000000000,0;1,0.0156250000000000,0;1,0,0;0.984375000000000,0,0;0.968750000000000,0,0;0.953125000000000,0,0;0.937500000000000,0,0;0.921875000000000,0,0;0.906250000000000,0,0;0.890625000000000,0,0;0.875000000000000,0,0;0.859375000000000,0,0;0.843750000000000,0,0;0.828125000000000,0,0;0.812500000000000,0,0;0.796875000000000,0,0;0.781250000000000,0,0;0.765625000000000,0,0;0.750000000000000,0,0;0.734375000000000,0,0;0.718750000000000,0,0;0.703125000000000,0,0;0.687500000000000,0,0;0.671875000000000,0,0;0.656250000000000,0,0;0.640625000000000,0,0;0.625000000000000,0,0;0.609375000000000,0,0;0.593750000000000,0,0;0.578125000000000,0,0;0.562500000000000,0,0;0.546875000000000,0,0;0.531250000000000,0,0;0.515625000000000,0,0;0.500000000000000,0,0];
% cm = [0.996032714843750,0.996032714843750,0.998078346252441;0.976440429687500,0.976440429687500,0.988588333129883;0.956848144531250,0.956848144531250,0.979098320007324;0.937255859375000,0.937255859375000,0.969608306884766;0.917663574218750,0.917663574218750,0.960118293762207;0.898071289062500,0.898071289062500,0.950628280639648;0.878479003906250,0.878479003906250,0.941138267517090;0.858886718750000,0.858886718750000,0.931648254394531;0.839294433593750,0.839294433593750,0.922158241271973;0.819702148437500,0.819702148437500,0.912668228149414;0.800109863281250,0.800109863281250,0.903178215026856;0.780517578125000,0.780517578125000,0.893688201904297;0.760925292968750,0.760925292968750,0.884198188781738;0.741333007812500,0.741333007812500,0.874708175659180;0.721740722656250,0.721740722656250,0.865218162536621;0.702148437500000,0.702148437500000,0.855728149414063;0.682556152343750,0.682556152343750,0.846238136291504;0.662963867187500,0.662963867187500,0.836748123168945;0.643371582031250,0.643371582031250,0.827258110046387;0.623779296875000,0.623779296875000,0.817768096923828;0.604187011718750,0.604187011718750,0.808278083801270;0.584594726562500,0.584594726562500,0.798788070678711;0.565002441406250,0.565002441406250,0.789298057556152;0.545410156250000,0.545410156250000,0.779808044433594;0.525817871093750,0.525817871093750,0.770318031311035;0.506225585937500,0.506225585937500,0.760828018188477;0.486633300781250,0.486633300781250,0.751338005065918;0.467041015625000,0.467041015625000,0.741847991943359;0.447448730468750,0.447448730468750,0.732357978820801;0.427856445312500,0.427856445312500,0.722867965698242;0.408264160156250,0.408264160156250,0.713377952575684;0.388671875000000,0.388671875000000,0.703887939453125;0.369079589843750,0.369079589843750,0.694397926330566;0.349487304687500,0.349487304687500,0.684907913208008;0.329895019531250,0.329895019531250,0.675417900085449;0.310302734375000,0.310302734375000,0.665927886962891;0.290710449218750,0.290710449218750,0.656437873840332;0.271118164062500,0.271118164062500,0.646947860717773;0.251525878906250,0.251525878906250,0.637457847595215;0.231933593750000,0.231933593750000,0.627967834472656;0.212341308593750,0.212341308593750,0.618477821350098;0.192749023437500,0.192749023437500,0.608987808227539;0.173156738281250,0.173156738281250,0.599497795104981;0.153564453125000,0.153564453125000,0.590007781982422;0.133972167968750,0.133972167968750,0.580517768859863;0.114379882812500,0.114379882812500,0.571027755737305;0.0947875976562500,0.0947875976562500,0.561537742614746;0.0751953125000000,0.0751953125000000,0.552047729492188;0.0556030273437500,0.0556030273437500,0.542557716369629;0.0360107421875000,0.0360107421875000,0.533067703247070;0.0164184570312500,0.0164184570312500,0.523577690124512;0,0,0.515625000000000;0,0,0.522766113281250;0,0,0.542358398437500;0,0,0.561950683593750;0,0,0.581542968750000;0,0,0.601135253906250;0,0,0.620727539062500;0,0,0.640319824218750;0,0,0.659912109375000;0,0,0.679504394531250;0,0,0.699096679687500;0,0,0.718688964843750;0,0,0.738281250000000;0,0,0.757873535156250;0,0,0.777465820312500;0,0,0.797058105468750;0,0,0.816650390625000;0,0,0.836242675781250;0,0,0.855834960937500;0,0,0.875427246093750;0,0,0.895019531250000;0,0,0.914611816406250;0,0,0.934204101562500;0,0,0.953796386718750;0,0,0.973388671875000;0,0,0.992980957031250;0,0.0125732421875000,1;0,0.0321655273437500,1;0,0.0517578125000000,1;0,0.0713500976562500,1;0,0.0909423828125000,1;0,0.110534667968750,1;0,0.130126953125000,1;0,0.149719238281250,1;0,0.169311523437500,1;0,0.188903808593750,1;0,0.208496093750000,1;0,0.228088378906250,1;0,0.247680664062500,1;0,0.267272949218750,1;0,0.286865234375000,1;0,0.306457519531250,1;0,0.326049804687500,1;0,0.345642089843750,1;0,0.365234375000000,1;0,0.384826660156250,1;0,0.404418945312500,1;0,0.424011230468750,1;0,0.443603515625000,1;0,0.463195800781250,1;0,0.482788085937500,1;0,0.502380371093750,1;0,0.521972656250000,1;0,0.541564941406250,1;0,0.561157226562500,1;0,0.580749511718750,1;0,0.600341796875000,1;0,0.619934082031250,1;0,0.639526367187500,1;0,0.659118652343750,1;0,0.678710937500000,1;0,0.698303222656250,1;0,0.717895507812500,1;0,0.737487792968750,1;0,0.757080078125000,1;0,0.776672363281250,1;0,0.796264648437500,1;0,0.815856933593750,1;0,0.835449218750000,1;0,0.855041503906250,1;0,0.874633789062500,1;0,0.894226074218750,1;0,0.913818359375000,1;0,0.933410644531250,1;0,0.953002929687500,1;0,0.972595214843750,1;0,0.992187500000000,1;0.0117797851562500,1,0.988220214843750;0.0313720703125000,1,0.968627929687500;0.0509643554687500,1,0.949035644531250;0.0705566406250000,1,0.929443359375000;0.0901489257812500,1,0.909851074218750;0.109741210937500,1,0.890258789062500;0.129333496093750,1,0.870666503906250;0.148925781250000,1,0.851074218750000;0.168518066406250,1,0.831481933593750;0.188110351562500,1,0.811889648437500;0.207702636718750,1,0.792297363281250;0.227294921875000,1,0.772705078125000;0.246887207031250,1,0.753112792968750;0.266479492187500,1,0.733520507812500;0.286071777343750,1,0.713928222656250;0.305664062500000,1,0.694335937500000;0.325256347656250,1,0.674743652343750;0.344848632812500,1,0.655151367187500;0.364440917968750,1,0.635559082031250;0.384033203125000,1,0.615966796875000;0.403625488281250,1,0.596374511718750;0.423217773437500,1,0.576782226562500;0.442810058593750,1,0.557189941406250;0.462402343750000,1,0.537597656250000;0.481994628906250,1,0.518005371093750;0.501586914062500,1,0.498413085937500;0.521179199218750,1,0.478820800781250;0.540771484375000,1,0.459228515625000;0.560363769531250,1,0.439636230468750;0.579956054687500,1,0.420043945312500;0.599548339843750,1,0.400451660156250;0.619140625000000,1,0.380859375000000;0.638732910156250,1,0.361267089843750;0.658325195312500,1,0.341674804687500;0.677917480468750,1,0.322082519531250;0.697509765625000,1,0.302490234375000;0.717102050781250,1,0.282897949218750;0.736694335937500,1,0.263305664062500;0.756286621093750,1,0.243713378906250;0.775878906250000,1,0.224121093750000;0.795471191406250,1,0.204528808593750;0.815063476562500,1,0.184936523437500;0.834655761718750,1,0.165344238281250;0.854248046875000,1,0.145751953125000;0.873840332031250,1,0.126159667968750;0.893432617187500,1,0.106567382812500;0.913024902343750,1,0.0869750976562500;0.932617187500000,1,0.0673828125000000;0.952209472656250,1,0.0477905273437500;0.971801757812500,1,0.0281982421875000;0.991394042968750,1,0.00860595703125000;1,0.989013671875000,0;1,0.969421386718750,0;1,0.949829101562500,0;1,0.930236816406250,0;1,0.910644531250000,0;1,0.891052246093750,0;1,0.871459960937500,0;1,0.851867675781250,0;1,0.832275390625000,0;1,0.812683105468750,0;1,0.793090820312500,0;1,0.773498535156250,0;1,0.753906250000000,0;1,0.734313964843750,0;1,0.714721679687500,0;1,0.695129394531250,0;1,0.675537109375000,0;1,0.655944824218750,0;1,0.636352539062500,0;1,0.616760253906250,0;1,0.597167968750000,0;1,0.577575683593750,0;1,0.557983398437500,0;1,0.538391113281250,0;1,0.518798828125000,0;1,0.499206542968750,0;1,0.479614257812500,0;1,0.460021972656250,0;1,0.440429687500000,0;1,0.420837402343750,0;1,0.401245117187500,0;1,0.381652832031250,0;1,0.362060546875000,0;1,0.342468261718750,0;1,0.322875976562500,0;1,0.303283691406250,0;1,0.283691406250000,0;1,0.264099121093750,0;1,0.244506835937500,0;1,0.224914550781250,0;1,0.205322265625000,0;1,0.185729980468750,0;1,0.166137695312500,0;1,0.146545410156250,0;1,0.126953125000000,0;1,0.107360839843750,0;1,0.0877685546875000,0;1,0.0681762695312500,0;1,0.0485839843750000,0;1,0.0289916992187500,0;1,0.00939941406250000,0;0.989807128906250,0,0;0.970214843750000,0,0;0.950622558593750,0,0;0.931030273437500,0,0;0.911437988281250,0,0;0.891845703125000,0,0;0.872253417968750,0,0;0.852661132812500,0,0;0.833068847656250,0,0;0.813476562500000,0,0;0.793884277343750,0,0;0.774291992187500,0,0;0.754699707031250,0,0;0.735107421875000,0,0;0.715515136718750,0,0;0.695922851562500,0,0;0.676330566406250,0,0;0.656738281250000,0,0;0.637145996093750,0,0;0.617553710937500,0,0;0.597961425781250,0,0;0.578369140625000,0,0;0.558776855468750,0,0;0.539184570312500,0,0;0.519592285156250,0,0;0.500000000000000,0,0];
cm = [         0    0.9922    1.0000
    0.0060    0.9962    0.9940
    0.0129    0.9991    0.9871
    0.0221    0.9997    0.9779
    0.0316    1.0000    0.9684
    0.0415    1.0000    0.9585
    0.0514    1.0000    0.9486
    0.0613    1.0000    0.9387
    0.0712    1.0000    0.9288
    0.0811    1.0000    0.9189
    0.0909    1.0000    0.9091
    0.1008    1.0000    0.8992
    0.1106    1.0000    0.8894
    0.1205    1.0000    0.8795
    0.1304    1.0000    0.8696
    0.1403    1.0000    0.8597
    0.1502    1.0000    0.8498
    0.1601    1.0000    0.8399
    0.1699    1.0000    0.8301
    0.1798    1.0000    0.8202
    0.1896    1.0000    0.8104
    0.1995    1.0000    0.8005
    0.2094    1.0000    0.7906
    0.2192    1.0000    0.7808
    0.2291    1.0000    0.7709
    0.2390    1.0000    0.7610
    0.2489    1.0000    0.7511
    0.2588    1.0000    0.7412
    0.2686    1.0000    0.7314
    0.2785    1.0000    0.7215
    0.2884    1.0000    0.7116
    0.2982    1.0000    0.7018
    0.3081    1.0000    0.6919
    0.3180    1.0000    0.6820
    0.3279    1.0000    0.6721
    0.3378    1.0000    0.6622
    0.3476    1.0000    0.6524
    0.3575    1.0000    0.6425
    0.3674    1.0000    0.6326
    0.3772    1.0000    0.6228
    0.3871    1.0000    0.6129
    0.3970    1.0000    0.6030
    0.4069    1.0000    0.5931
    0.4168    1.0000    0.5832
    0.4266    1.0000    0.5734
    0.4365    1.0000    0.5635
    0.4464    1.0000    0.5536
    0.4562    1.0000    0.5438
    0.4661    1.0000    0.5339
    0.4759    1.0000    0.5241
    0.4858    1.0000    0.5142
    0.4957    1.0000    0.5043
    0.5056    1.0000    0.4944
    0.5155    1.0000    0.4845
    0.5254    1.0000    0.4746
    0.5352    1.0000    0.4648
    0.5451    1.0000    0.4549
    0.5549    1.0000    0.4451
    0.5648    1.0000    0.4352
    0.5747    1.0000    0.4253
    0.5846    1.0000    0.4154
    0.5945    1.0000    0.4055
    0.6044    1.0000    0.3956
    0.6142    1.0000    0.3858
    0.6241    1.0000    0.3759
    0.6339    1.0000    0.3661
    0.6438    1.0000    0.3562
    0.6537    1.0000    0.3463
    0.6635    1.0000    0.3365
    0.6735    1.0000    0.3265
    0.6834    1.0000    0.3166
    0.6932    1.0000    0.3068
    0.7031    1.0000    0.2969
    0.7129    1.0000    0.2871
    0.7228    1.0000    0.2772
    0.7327    1.0000    0.2673
    0.7425    1.0000    0.2575
    0.7524    1.0000    0.2476
    0.7623    1.0000    0.2377
    0.7722    1.0000    0.2278
    0.7821    1.0000    0.2179
    0.7919    1.0000    0.2081
    0.8018    1.0000    0.1982
    0.8117    1.0000    0.1883
    0.8215    1.0000    0.1785
    0.8314    1.0000    0.1686
    0.8412    1.0000    0.1588
    0.8511    1.0000    0.1489
    0.8611    1.0000    0.1389
    0.8709    1.0000    0.1291
    0.8808    1.0000    0.1192
    0.8907    1.0000    0.1093
    0.9005    1.0000    0.0995
    0.9104    1.0000    0.0896
    0.9202    1.0000    0.0798
    0.9301    1.0000    0.0699
    0.9400    1.0000    0.0600
    0.9499    1.0000    0.0501
    0.9598    1.0000    0.0402
    0.9697    1.0000    0.0303
    0.9794    0.9999    0.0206
    0.9880    0.9986    0.0120
    0.9947    0.9955    0.0053
    0.9988    0.9897    0.0012
    1.0000    0.9810         0
    1.0000    0.9711         0
    1.0000    0.9612         0
    1.0000    0.9513         0
    1.0000    0.9415         0
    1.0000    0.9316         0
    1.0000    0.9218         0
    1.0000    0.9119         0
    1.0000    0.9020         0
    1.0000    0.8922         0
    1.0000    0.8823         0
    1.0000    0.8724         0
    1.0000    0.8625         0
    1.0000    0.8526         0
    1.0000    0.8428         0
    1.0000    0.8329         0
    1.0000    0.8230         0
    1.0000    0.8132         0
    1.0000    0.8033         0
    1.0000    0.7934         0
    1.0000    0.7835         0
    1.0000    0.7736         0
    1.0000    0.7638         0
    1.0000    0.7539         0
    1.0000    0.7440         0
    1.0000    0.7342         0
    1.0000    0.7243         0
    1.0000    0.7144         0
    1.0000    0.7045         0
    1.0000    0.6946         0
    1.0000    0.6848         0
    1.0000    0.6749         0
    1.0000    0.6650         0
    1.0000    0.6552         0
    1.0000    0.6453         0
    1.0000    0.6355         0
    1.0000    0.6256         0
    1.0000    0.6157         0
    1.0000    0.6058         0
    1.0000    0.5959         0
    1.0000    0.5860         0
    1.0000    0.5762         0
    1.0000    0.5663         0
    1.0000    0.5565         0
    1.0000    0.5466         0
    1.0000    0.5367         0
    1.0000    0.5268         0
    1.0000    0.5169         0
    1.0000    0.5070         0
    1.0000    0.4972         0
    1.0000    0.4873         0
    1.0000    0.4775         0
    1.0000    0.4676         0
    1.0000    0.4577         0
    1.0000    0.4478         0
    1.0000    0.4379         0
    1.0000    0.4280         0
    1.0000    0.4182         0
    1.0000    0.4083         0
    1.0000    0.3985         0
    1.0000    0.3886         0
    1.0000    0.3787         0
    1.0000    0.3689         0
    1.0000    0.3590         0
    1.0000    0.3491         0
    1.0000    0.3392         0
    1.0000    0.3293         0
    1.0000    0.3195         0
    1.0000    0.3096         0
    1.0000    0.2997         0
    1.0000    0.2899         0
    1.0000    0.2800         0
    1.0000    0.2702         0
    1.0000    0.2602         0
    1.0000    0.2503         0
    1.0000    0.2405         0
    1.0000    0.2306         0
    1.0000    0.2207         0
    1.0000    0.2109         0
    1.0000    0.2010         0
    1.0000    0.1912         0
    1.0000    0.1813         0
    1.0000    0.1713         0
    1.0000    0.1615         0
    1.0000    0.1516         0
    1.0000    0.1417         0
    1.0000    0.1319         0
    1.0000    0.1220         0
    1.0000    0.1122         0
    1.0000    0.1023         0
    1.0000    0.0924         0
    1.0000    0.0826         0
    1.0000    0.0726         0
    1.0000    0.0627         0
    1.0000    0.0529         0
    1.0000    0.0430         0
    1.0000    0.0332         0
    1.0000    0.0233         0
    0.9988    0.0146         0
    0.9964    0.0071         0
    0.9907    0.0030         0
    0.9837         0         0
    0.9739         0         0
    0.9640         0         0
    0.9542         0         0
    0.9443         0         0
    0.9344         0         0
    0.9246         0         0
    0.9147         0         0
    0.9048         0         0
    0.8949         0         0
    0.8850         0         0
    0.8752         0         0
    0.8653         0         0
    0.8554         0         0
    0.8456         0         0
    0.8357         0         0
    0.8259         0         0
    0.8160         0         0
    0.8061         0         0
    0.7962         0         0
    0.7863         0         0
    0.7764         0         0
    0.7666         0         0
    0.7567         0         0
    0.7469         0         0
    0.7370         0         0
    0.7271         0         0
    0.7172         0         0
    0.7073         0         0
    0.6974         0         0
    0.6876         0         0
    0.6777         0         0
    0.6679         0         0
    0.6580         0         0
    0.6481         0         0
    0.6382         0         0
    0.6283         0         0
    0.6184         0         0
    0.6086         0         0
    0.5987         0         0
    0.5889         0         0
    0.5790         0         0
    0.5691         0         0
    0.5593         0         0
    0.5494         0         0
    0.5395         0         0
    0.5296         0         0
    0.5197         0         0
    0.5099         0         0
    0.5000         0         0];

nColors = size(cm,1);

if (nColors ~= m)
    cInd = 1:(nColors);
    qInd = linspace(1,nColors,m);
    r = interp1(cInd, cm(:,1), qInd);
    g = interp1(cInd, cm(:,2), qInd);
    b = interp1(cInd, cm(:,3), qInd);
    cm = [r',g',b'];
%     cm = [1 1 1; cm];
end



