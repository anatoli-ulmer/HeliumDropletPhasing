function cm = wjet2

j = colormap(jet);
startcol = [1,1,1];
endcol = j(1,:);
diffcol = endcol-startcol;
nsteps = 64;
cm = nan(nsteps,3);
for i=1:nsteps;
    cm(i,:) = startcol + diffcol.*i/nsteps;
end
cm = [cm; j];