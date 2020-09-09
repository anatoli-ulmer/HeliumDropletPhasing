%% functions from pnccd_gui version before Juli 2020
function keypressfun(~, eventdata)
hFig.main.Pointer = 'watch'; drawnow;
switch eventdata.Key
    case 'slash'; reconANDsave
    case 'z'; find_all_centers
    case 'p'; getGapAndShift
    case 'o'; getShapes
    case 'm'
        hData.img.data = center_crop(hData.img.data, hData.img.center);
        hData.img.mask = single(~isnan(hData.img.data));
        save(fullfile(paths.sim , 'simdata.mat'), 'hData.img.data','hData.img.mask')
end
end


function saveimgfun(~,~)
        fig.Pointer = 'watch'; drawnow;
%         hfig.savefig = figure;
%         hax.saveax = copyobj(hax.pnccd,hfig.savefig);
%         set(hax.saveax, 'Position', 'default');
%         colormap(hax.saveax, par.cmap); axis(hax.saveax, 'image'); colorbar(hax.saveax); drawnow;
%         print(hfig.savefig, fullfile(paths.db, 'png_images\with_axes', ...
%             sprintf('run_%04d_hit_%04d_trainid_%d.png', pnccd.run, hit, pnccd.trainid(hit)))),...
%             '-dpng');
%         close(hfig.savefig);
        hfig.savefig = figure('Units', 'inches',...
            'Position', [1,1,size(img,2)/size(img,1)*3,3],...
            'PaperUnits', 'inches', 'PaperSize', [size(img,2)/size(img,1)*3,3],...
            'PaperPosition', [0,0,size(img,2)/size(img,1)*3,3]);
        hax.saveax = axes('Units', 'normalized', 'Position', [0,0,1,1]);
        save_plt = imagesc(logS(img), ...
            iif(autoscalecbx.Value, logS([min(img(:)),max(img(:))]), logS(par.clims))); %#ok<NASGU>
        colormap(hax.saveax, par.cmap); colorbar(hax.saveax, 'off');
        set(hax.saveax,'visible','off')
        drawnow;
        print(hfig.savefig, fullfile(paths.img, 'png_images\without_axes',...
            sprintf('run_%04d_hit_%04d_trainid_%d.png', pnccd.run, hit, pnccd.trainid(hit))),...
            sprintf('-r%i', size(img,1)), '-dpng')
%         save(fullfile(paths.img, 'png_images\img_data',...
%             sprintf('run_%04d_hit_%04d_trainid_%d.mat', pnccd.run, hit, pnccd.trainid(hit))),...
%             'img')
        close(hfig.savefig);
        fig.Pointer = 'arrow'; drawnow;
    end
    function thisdragfun(src,evt)
        if src.CurrentAxes~=hax.lit; dragfun(src,evt); end
    end
    function thiszoomfun(src,evt)
        if src.CurrentAxes~=hax.lit; zoomfun(src,evt); end
    end
        function thisbtnupfun(src,evt)
        if src.CurrentAxes~=hAx.lit; btnupfun(src,evt); end
    end

    function centrosymmetric(~,~)
%         toShift = round(size(img)/2-round(center));
%         img = simpleshift(img, [toShift(2), toShift(1)]);
        cimg(:,:,1) = img;
        img2 = img;
        img2(isnan(img2)) = -1e12;
        img2 = rot90(imtranslate(img2, size(img)/2-round(center)),2);
        img2(img2<0) = nan;
        cimg(:,:,2) = img2;
        
        img = mean(cimg,3,'omitnan');
%         center = center + toShift;
        % imtranslate
%         center = size(img)/2;
    end
    function startsimu(src,evt,h) %#ok<INUSD>
%         if par.simulationmode
%             center = center_real;
%         else
%             center_real = center;
%         end
%         if isempty(hfig.simu) || ~isvalid(hfig.simu)
%             hfig.simu = figure(4040404); 
%             hfig.simu.Name = 'simulation figure';
%             hsim.ax(1) = mysubplot(2,3,1,'parent',hfig.simu);
%             hsim.ax(2) = mysubplot(2,3,3,'parent',hfig.simu);
%             hsim.ax(3) = mysubplot(2,3,4,'parent',hfig.simu);
%             hsim.ax(4) = mysubplot(2,3,6,'parent',hfig.simu);
%             hsim.ax(5) = mysubplot(2,3,5,'parent',hfig.simu);
%             
%             hsim.edt(1) = uicontrol(hfig.simu, 'Style', 'edit', 'String', sprintf('%.3g', var.radiusInPixel),...
%                 'Units', 'normalized', 'Position', [.5 .9 .04 .04], 'Callback', @startsimu);
%             hsim.edt(2) = uicontrol(hfig.simu, 'Style', 'edit', 'String', sprintf('%.3g', var.radiusInPixel/10),...
%                 'Units', 'normalized', 'Position', [.5 .85 .04 .04], 'Callback', @startsimu);
%             hsim.edt(3) = uicontrol(hfig.simu, 'Style', 'edit', 'String', '1',...
%                 'Units', 'normalized', 'Position', [.5 .8 .04 .04], 'Callback', @startsimu);
%             hsim.edt(4) = uicontrol(hfig.simu, 'Style', 'edit', 'String', '10',...
%                 'Units', 'normalized', 'Position', [.5 .75 .04 .04], 'Callback', @startsimu);
%             hsim.edt(5) = uicontrol(hfig.simu, 'Style', 'edit', 'String', '15',...
%                 'Units', 'normalized', 'Position', [.5 .7 .04 .04], 'Callback', @startsimu);
%             hsim.edt(6) = uicontrol(hfig.simu, 'Style', 'edit', 'String', '18',...
%                 'Units', 'normalized', 'Position', [.55 .7 .04 .04], 'Callback', @startsimu);
%             hsim.edt(7) = uicontrol(hfig.simu, 'Style', 'edit', 'String', shape.a/2,...
%                 'Units', 'normalized', 'Position', [.35 .6 .08 .04], 'Callback', @startsimu);
%             hsim.edt(8) = uicontrol(hfig.simu, 'Style', 'edit', 'String', shape.b/2,...
%                 'Units', 'normalized', 'Position', [.45 .6 .08 .04], 'Callback', @startsimu);
%             hsim.edt(9) = uicontrol(hfig.simu, 'Style', 'edit', 'String', mod(shape.rot,2*pi)/pi*180,...
%                 'Units', 'normalized', 'Position', [.55 .60 .08 .04], 'Callback', @startsimu);
%             hsim.btngrp(1) = uibuttongroup('Visible','on', 'Units', 'normalized',...
%                 'Position',[.4 .65 .2 .04], 'SelectionChangedFcn', @startsimu);
%             hsim.rdbtn(1) = uicontrol(hsim.btngrp(1), 'Style', 'radiobutton', 'String', '1 core',...
%                 'Units', 'normalized', 'Position', [.0 .0 .5 1]);
%             hsim.rdbtn(2) = uicontrol(hsim.btngrp(1), 'Style', 'radiobutton', 'String', '2 cores',...
%                 'Units', 'normalized', 'Position', [.5 0 .5 1]);
%             
%             hsim.img(1) = imagesc(zeros(1024), 'XData', [-512,511]*6, 'YData', [-512,511]*6, 'parent', hsim.ax(1)); colormap(hsim.ax(1),igray); zoom(hsim.ax(1),5);
%             hsim.img(2) = imagesc(zeros(1024), 'XData', [-512,511]*6, 'YData', [-512,511]*6, 'parent', hsim.ax(2)); colormap(hsim.ax(2),igray); zoom(hsim.ax(2),5);
%             hsim.img(3) = imagesc(zeros(1024),  'parent', hsim.ax(3), hax.pnccd.CLim); colormap(hsim.ax(3),colormap(hax.pnccd));
%             hsim.img(4) = imagesc(zeros(1024), 'parent', hsim.ax(4), hax.pnccd.CLim); colormap(hsim.ax(4),colormap(hax.pnccd));
%             hsim.img(5) = imagesc(zeros(1024), 'parent', hsim.ax(5), hax.pnccd.CLim); colormap(hsim.ax(5),colormap(hax.pnccd));
%         end
%         hfig.simu = figure(4040404);
%         arrayfun(@(a) set(hsim.ax(a), 'CLim', hax.pnccd.CLim), 3:5);
%         arrayfun(@(a) colormap(hsim.ax(a), colormap(hax.pnccd)), 3:5);
%         
%         rDroplet = str2double(hsim.edt(1).String);
%         rDopand = str2double(hsim.edt(2).String);
%         sc1 = str2double(hsim.edt(3).String);
%         sc2 = str2double(hsim.edt(4).String);
%         scattRatio = sc2/sc1;
%         posDopand = [str2double(hsim.edt(5).String)/6, str2double(hsim.edt(6).String)/6];
% %         posDopand = [0,1]*str2double(hsim.edt(5).String);
% %         rot = str2double(hsim.edt(9).String)/180*pi;
% %         posDopand = [posDopand(2)*cos(rot) - posDopand(1)*sin(rot),...
% %             posDopand(2)*sin(rot) + posDopand(1)*cos(rot)];
%         img_crop = centerAndCrop(img, center);
%         img_crop = round(img_crop);
%         [scene1, scene2, scatt1, scatt2] = singleVSdouble(rDroplet, rDopand, posDopand, scattRatio, density);
%         sv1 = nansum(img_crop(~isnan(img_crop) & ~isinf(img_crop)))/...
%             nansum(scatt1(~isnan(img_crop) & ~isinf(img_crop)));
%         sv2 = nansum(img_crop(~isnan(img_crop) & ~isinf(img_crop)))/...
%             nansum(scatt2(~isnan(img_crop) & ~isinf(img_crop)));
%         %         sm1 = img_crop(~isnan(img_crop) | (~isinf(img_crop))) ./ ( scatt1(~isnan(img_crop) | (~isinf(img_crop))) );
%         %         sm2 = img_crop(~isnan(img_crop) | (~isinf(img_crop))) ./ ( scatt2(~isnan(img_crop) | (~isinf(img_crop))) );
%         %         sv1 = nanmedian(sm1(~isnan(sm1) | ~isinf(sm1)));
%         %         sv2 = nanmedian(sm1(~isnan(sm2) | ~isinf(sm2)));
%         %         scene1 = scene1 * sv1;
%         %         scene2 = scene2 * sv2;
%         scatt1 = scatt1 * sv1;
%         scatt2 = scatt2 * sv2;
%         scatt1 = imnoise(scatt1/1e12,'poisson')*1e12;
%         scatt2 = imnoise(scatt2/1e12,'poisson')*1e12;
%         scatt1(isnan(img_crop)) = nan;
%         scatt2(isnan(img_crop)) = nan;
%         
%         hsim.img(1).CData = scene1;
%         hsim.img(2).CData = scene2;
%         hsim.img(3).CData = log10(abs(scatt1));
%         hsim.img(4).CData = log10(abs(scatt2));
%         hsim.img(5).CData = log10(abs(img_crop));
%         
%         %%%%% polar coordinate plots ins separate window %%%%%
% %         polimg = rot90(polar_matrix(img_crop,'xcenter', size(scatt1,2)/2+1,'ycenter',size(scatt1,1)/2+1));
% %         pol1 = rot90(polar_matrix(scatt1,'xcenter', size(scatt1,2)/2+1,'ycenter',size(scatt1,1)/2+1));
% %         pol2 = rot90(polar_matrix(scatt2,'xcenter', size(scatt1,2)/2+1,'ycenter',size(scatt1,1)/2+1));
% %         
% %         if isempty(hfig.simupol) || ~isvalid(hfig.simupol)
% %             hfig.simupol = figure(4040405);
% %             hsim.ax(11) = mysubplot(1,3,1, 'parent', hfig.simupol);
% %             hsim.ax(12) = mysubplot(1,3,2, 'parent', hfig.simupol);
% %             hsim.ax(13) = mysubplot(1,3,3, 'parent', hfig.simupol);
% %             hsim.img(11) = imagesc(zeros(1024), 'parent', hsim.ax(11), hax.pnccd.CLim); colormap(hsim.ax(11),colormap(hax.pnccd));
% %             hsim.img(12) = imagesc(zeros(1024), 'parent', hsim.ax(12), hax.pnccd.CLim); colormap(hsim.ax(12),colormap(hax.pnccd));
% %             hsim.img(13) = imagesc(zeros(1024), 'parent', hsim.ax(13), hax.pnccd.CLim); colormap(hsim.ax(13),colormap(hax.pnccd));
% %         end
% %         hfig.simupol = figure(4040405);
% %         arrayfun(@(a) set(hsim.ax(a), 'CLim', hax.pnccd.CLim), 11:13);
% %         arrayfun(@(a) colormap(hsim.ax(a), colormap(hax.pnccd)), 11:13);
% %         hsim.img(11).CData = log10(abs(pol1));
% %         hsim.img(12).CData = log10(abs(polimg));
% %         hsim.img(13).CData = log10(abs(pol2));
%         %%%%% /polar plots %%%%%
%         
%         %%% focus back on main figure
%         figure(fig)
%         
%         par.simulationmode = true;
%         if hsim.rdbtn(1).Value; img_sim = scatt1; end
%         if hsim.rdbtn(2).Value; img_sim = scatt2; end
%         center_sim = [513,513];
%         img = img_sim;
%         center = center_sim;
%         updateplotfun;
    end
    function getShapes(~,~)
%         while true
%             if fig.UserData.stopScript
%                 fig.UserData.stopScript = false;
%                 break
%             end
%             %             nansum(img(:))<5e4 ...
%             if ~strcmp(db_run_info(run).doping.dopant,'none') || isnan(db_sizing(run).R(hit))
%                 nextfun;
%                 continue
%             end
% %             centerfun
%             shapefun
%             nextfun
%         end
    end
    function getGapAndShift(~,~)
%         gapArray = 0;
%         shiftArray = 2;
% %         errorR(isnan(errorR))=inf;
% %         errorF(isnan(errorF))=inf;
% %         errorR = inf(31,11); % gap-> -10:20 || shift-> -5:5
% %         errorF = inf(31,11); % zero at (11,6)
%         for gi = 1:numel(gapArray)
%             for si = 1:numel(shiftArray)
%                 par.addgap = gapArray(gi);
%                 par.addshift = shiftArray(si);
%                 loadimgfun
%                 centerfun
%                 shapefun
%                 initIPR
%                 %                 startDCDI
%                 startHIO
%                 saveas(figure(20000001), fullfile(paths.storage, 'pnccd_geometry_analysis\', sprintf('recon1_g%is%i_gap_%+.0fpx_shift_%+.0fpx.png', gi, si, par.addgap, par.addshift)));
%                 saveas(figure(20000002),fullfile(paths.storage, 'pnccd_geometry_analysis\', sprintf('recon2_g%is%i_gap_%+.0fpx_shift_%+.0fpx.png', gi, si, par.addgap, par.addshift)));
%                 saveas(figure(1010101), fullfile(paths.storage, 'pnccd_geometry_analysis\', sprintf('main_g%is%i_gap_%+.0fpx_shift_%+.0fpx.png', gi, si, par.addgap, par.addshift)));
%                 saveas(figure(1010102), fullfile(paths.storage, 'pnccd_geometry_analysis\', sprintf('center_g%is%i_gap_%+.0fpx_shift_%+.0fpx.png', gi, si, par.addgap, par.addshift)));
%                 saveas(figure(1010103), fullfile(paths.storage, 'pnccd_geometry_analysis\', sprintf('shape1_g%is%i_gap_%+.0fpx_shift_%+.0fpx.png', gi, si, par.addgap, par.addshift)));
%                 saveas(figure(1010104), fullfile(paths.storage, 'pnccd_geometry_analysis\', sprintf('shape2_g%is%i_gap_%+.0fpx_shift_%+.0fpx.png', gi, si, par.addgap, par.addshift)));
%                 saveas(figure(20000003), fullfile(paths.storage, 'pnccd_geometry_analysis\', sprintf('reconErr_g%is%i_gap_%+.0fpx_shift_%+.0fpx.png', gi, si, par.addgap, par.addshift)));
% %                 save(fullfile(paths.storage, 'pnccd_geometry_analysis\mat\', sprintf('hipr_g%is%i_gap_%+.0fpx_shift_%+.0fpx.mat', gi, si, par.addgap, par.addshift)), 'hipr');
%                 errorR(gapArray(gi)+11,shiftArray(si)+6) = gather(hipr.errReal(nsteps));
%                 errorF(gapArray(gi)+11,shiftArray(si)+6) = gather(hipr.errFourier(nsteps));
%             end
%             save(fullfile(paths.storage, 'pnccd_geometry_analysis\mat\errorMatrices.mat'), 'errorR', 'errorF');
%             figure(838383); clf
%             subplot(121); imagesc(errorR, 'YData', [-10 20], 'XData', [-5 5]); title(sprintf('real space error - run %i - hit %i - id %i', run, hit, pnccd.trainid(hit) ) ); xlabel('additional shift in px'); ylabel('additional gap in px');
%             subplot(122); imagesc(errorF, 'YData', [-10 20], 'XData', [-5 5]); title(sprintf('fourier space error - run %i - hit %i - id %i', run, hit, pnccd.trainid(hit) ) ); xlabel('additional shift in px'); ylabel('additional gap in px');
%             colormap igray; drawnow;
%         end
%         par.addgap = 0;
%         par.addshift = 0;
    end
    function find_all_centers(~,~)
%         while true
%             if strcmp(db_run_info(run).doping.dopant,'none')
%                 loadfile(paths.pnccd, run+1,1);
%                 continue
%             end
%             if nansum(img(:))<5e4 ...
%                     || isnan(db_sizing(run).R(hit))...
%                     || db_sizing(run).R(hit)*1e9<30
%                 nextfun;
%                 continue
%             end
%             centerfun
%         end
    end
    function reconANDsave(~,~)
%         try d = load(fullfile(paths.db, 'db_recon.mat')); db_recon = d.db_recon; clear d;
%         catch; fprintf('could not load db_recon\n'); end
        while true
                if strcmp(db_run_info(run).doping.dopant,'none')
                    fprintf('run %i is not doped. Continuing...\n',run)
                    loadfile(paths.pnccd, run+1,1);
                    continue
                end
                if nansum(img(:))<5e4 ...
                        || isnan(db_sizing(run).R(hit)) ...
                        || db_sizing(run).R(hit)*1e9<30                    
                    nextfun;
                    continue
                end
                if run>=437 && nansum(img(:))<1e5
                    nextfun;
                    continue
                end
                centerfun;
                shapefun;
                initIPR
%                 startDCDI
%                 startHIO
                startIO
%                 finishrecon
                
                %%%% FIGURES %%%%
                saveobj.fig = figure(601); saveobj.fig.Name = 'save figure #1'; clf(saveobj.fig);
                saveobj.fig.PaperSize = [29.6774   20.9840].*[4/3,1];
                saveobj.fig.PaperPosition = [0 0 saveobj.fig.PaperSize];
                saveobj.uit = uitable(saveobj.fig, 'Units', 'normalized', 'Position', [0,.5,.25,.5], ...
                    'FontSize', 10, 'ColumnWidth', {100,230}, 'RowName', [], ...
                    'ColumnName', []);
                saveobj.fig2 = figure(602); saveobj.fig2.Name = 'save figure #2'; clf(saveobj.fig2);
                saveobj.fig2.PaperSize = [29.6774   20.9840];
                saveobj.fig2.PaperPosition = [0,0,saveobj.fig2.PaperSize];
                saveobj.ax2 = axes('parent', saveobj.fig2);
                
                hipr.ws = hipr.ws .* hipr.support;
                hipr.oneshot = hipr.oneshot .* hipr.support;
%                 hipr.density = hipr.density .* mode( real(hipr.w(hipr.support>0))./hipr.density(hipr.support>0) );
                
                % scattering image
                saveobj.ax(1) = mysubplot(2,4,2, 'parent', saveobj.fig);
                saveobj.img(1) = imagesc(hipr.plt.int(2).img.CData, ...
                    'XData', hipr.plt.int(2).img.XData, ...
                    'YData', hipr.plt.int(2).img.YData, ...
                    'parent', saveobj.ax(1), [-2 ,3]); 
                colormap(saveobj.ax(1), imorgen);
                saveobj.ax(1).YLabel.String = 'scattering angle';
                saveobj.ax(1).Title.String = 'measured intensity';
                
                % reconstructed intensity
                saveobj.ax(2) = mysubplot(2,4,6, 'parent', saveobj.fig);
                saveobj.img(2) = imagesc(hipr.plt.int(1).img.CData, ...
                    'XData', hipr.plt.int(1).img.XData, ...
                    'YData', hipr.plt.int(1).img.YData, ...
                    'parent', saveobj.ax(2), [-2,3]); 
                colormap(saveobj.ax(2), imorgen);
                saveobj.ax(2).YLabel.String = 'scattering angle';
                saveobj.ax(2).Title.String = 'reconstructed intensity';
                
                % real part of reconstruction
                saveobj.ax(3) = mysubplot(2,4,3, 'parent', saveobj.fig);
                saveobj.img(3) = imagesc(real(hipr.ws)-hipr.density*hipr.subscale, ...
                    'XData', hipr.plt.rec(2).img.XData, ...
                    'YData', hipr.plt.rec(2).img.YData, ...
                    'parent', saveobj.ax(3));
                colormap(saveobj.ax(3), b2r);
                set(saveobj.ax(3), 'XLim', hipr.ax.rec(2).XLim, 'YLim', hipr.ax.rec(2).YLim,...
                    'CLim', [-1,1]*max(abs(saveobj.img(3).CData(:))));
                saveobj.ax(3).YLabel.String = 'nanometer';
                saveobj.ax(3).Title.String = 'real part (shape substracted)';
                
                % imag part of reconstruction
                saveobj.ax(4) = mysubplot(2,4,7, 'parent', saveobj.fig);
                saveobj.img(4) = imagesc(imag(hipr.w), ...
                    'XData', hipr.plt.rec(2).img.XData, ...
                    'YData', hipr.plt.rec(2).img.YData, ...
                    'parent', saveobj.ax(4));
                colormap(saveobj.ax(4), igray);
                set(saveobj.ax(4), 'XLim', hipr.ax.rec(2).XLim, 'YLim', hipr.ax.rec(2).YLim,...
                     'CLim', [-1,1]*max(abs(saveobj.img(4).CData(:))));
                saveobj.ax(4).YLabel.String = 'nanometer';
                saveobj.ax(4).Title.String = 'imaginary part';
               
                % real oneshot part of reconstruction
                saveobj.ax(5) = mysubplot(2,4,4, 'parent', saveobj.fig);
%                 saveobj.img(5) = imagesc(imag(hipr.ws), ...
                saveobj.img(5) = imagesc(real(hipr.oneshot) - hipr.density*hipr.subscale, ...
                    'XData', hipr.plt.rec(2).img.XData, ...
                    'YData', hipr.plt.rec(2).img.YData, ...
                    'parent', saveobj.ax(5));
                colormap(saveobj.ax(5), b2r);
                set(saveobj.ax(5), 'XLim', hipr.ax.rec(2).XLim, 'YLim', hipr.ax.rec(2).YLim,...
                    'CLim', [-1,1]*max(abs(saveobj.img(5).CData(:))));
                saveobj.ax(5).YLabel.String = 'nanometer';
%                 saveobj.ax(5).Title.String = 'reconstructed imag part';
                saveobj.ax(5).Title.String = 'oneshot - real part';
                
                
                % imaginary oneshot of reconstruction
                saveobj.ax(6) = mysubplot(2,4,8, 'parent', saveobj.fig);
%                 saveobj.img(6) = imagesc(angle(hipr.ws), ...
                saveobj.img(6) = imagesc(imag(hipr.oneshot), ...
                    'XData', hipr.plt.rec(2).img.XData, ...
                    'YData', hipr.plt.rec(2).img.YData, ...
                    'parent', saveobj.ax(6));
                colormap(saveobj.ax(6), igray);
                set(saveobj.ax(6), 'XLim', hipr.ax.rec(2).XLim, 'YLim', hipr.ax.rec(2).YLim,...
                    'CLim', [-1,1]*max(abs(saveobj.img(6).CData(:))));
                saveobj.ax(6).YLabel.String = 'nanometer';
%                 saveobj.ax(6).Title.String = 'reconstructed phase';
                saveobj.ax(6).Title.String = 'oneshot - imaginary part';
                
                % shape reconstruction
                saveobj.ax(7) = mysubplot(2,4,5, 'parent', saveobj.fig);
                saveobj.img(7) = imagesc(hax.shape.Children(5).CData, ...
                    'parent', saveobj.ax(7));
                arrayfun(@(a) copyobj(hax.shape.Children(a),saveobj.ax(7)), 1:4)
                colormap(saveobj.ax(7), r2b);
                set(saveobj.ax(7), 'XLim', [512-db_sizing(run).R(hit)*1e9/6*3, ...
                    512+db_sizing(run).R(hit)*1e9/6*3],...
                    'YLim', [512-db_sizing(run).R(hit)*1e9/6*3, ...
                    512+db_sizing(run).R(hit)*1e9/6*3]);
                saveobj.ax(7).YLabel.String = 'pixel';
                saveobj.ax(7).Title.String = 'reconstructed shape';
                
                % data table
                saveobj.uit.Data = {'run #', run;...
                    'train id', pnccd.trainid(hit);...
                    'hit', hit;...
                    'T [K]', db_run_info(run).source.T;...
                    'p [bar]', db_run_info(run).source.p;...
                    'delay [ms]', db_run_info(run).source.delayTime;...
                    'R [nm]', db_sizing(run).R(hit)*1e9;...
                    'a [nm]', shape.a/2*6;...
                    'b [nm]', shape.b/2*6;...
                    'rot [°]', mod(shape.rot,2*pi)/pi*180;...
                    'center_x [px]', center(2);...
                    'center_y [px]', center(1);...
                    'photons #', round(nansum(img(:)));...
                    'lit pixel #', db_run_info(run).nlit_smooth(hit);...
                    'dopant', db_run_info(run).doping.dopant{:};...
                    'depletion [%]', db_run_info(run).doping.depletion;...
                    'AR', db_shape(run).shape(hit).ar;...
                    };
%                 saveobj.uit.Data = {'run #', sprintf('%03d',run);...
%                     'train id', sprintf('%d',pnccd.trainid(hit));...
%                     'hit', sprintf('%d',hit);...
%                     'T', sprintf('%.1f K', db_run_info(run).source.T);...
%                     'p', sprintf('%.1f bar', db_run_info(run).source.p);...
%                     'delay', sprintf('%.1f ms', db_run_info(run).source.delayTime);...
%                     'R', sprintf('%.1f nm',db_sizing(run).R(hit)*1e9);...
%                     'a', sprintf('%.1f nm',shape.a/2*6);...
%                     'b', sprintf('%.1f nm',shape.b/2*6);...
%                     'rotation angle', sprintf('%.1f °',mod(shape.rot/pi*180,2*pi));...
%                     'center', sprintf('[%.1f, %.1f] px', center(1), center(2));...
%                     'photons #', sprintf('%.0f', nansum(img(:)));...
%                     'lit pixel #', sprintf('%.0f', db_run_info(run).nlit_smooth(hit));...
%                     'dopant', sprintf('%s', db_run_info(run).doping.dopant{:});...
%                     'depletion', sprintf('%d %%', db_run_info(run).doping.depletion);...
%                     };
                
                % saving
                subpath = sprintf('%s%\\02.0fK_%02.0fbar', db_run_info(run).doping.dopant{:},...
                    round(db_run_info(run).source.T),...
                    round(db_run_info(run).source.p));
                savepath = fullfile(paths.img, 'reconstructions\png\',subpath);
                if ~exist(savepath, 'dir'); mkdir(savepath); end
                sname = sprintf('r%04d_id%d_hit%04d.png', run, pnccd.trainid(hit), hit);
                saveas(saveobj.fig, fullfile(savepath,sname));
                
                saveobj.img2 = imagesc(hipr.support.*abs(hipr.oneshot-hipr.density*~strcmp(db_run_info(run).doping.dopant,'none')),...
                    'XData', hipr.plt.rec(2).img.XData, ...
                    'YData', hipr.plt.rec(2).img.YData, ...
                    'parent', saveobj.ax2);
                limrange = ceil(hipr.ax.rec(2).XLim(2)/100)*100;
                set(saveobj.ax2, 'XLim', limrange*[-1,1], 'YLim', limrange*[-1,1]);
                colorbar(saveobj.ax2); colormap(saveobj.ax2, igray); drawnow;
                savepath = fullfile('E:\XFEL2019_He\reconstructions\png_recon_igray\',subpath);
                if ~exist(savepath, 'dir'); mkdir(savepath); end
                sname = sprintf('r%04d_id%d_hit%04d_modulus.png', run, pnccd.trainid(hit), hit);
                saveas(saveobj.fig2, fullfile(savepath, sname))
                
                colormap(saveobj.ax2, wjet); drawnow;
                savepath = fullfile('E:\XFEL2019_He\reconstructions\png_recon_wjet\',subpath);
                if ~exist(savepath, 'dir'); mkdir(savepath); end
                sname = sprintf('r%04d_id%d_hit%04d_modulus.png', run, pnccd.trainid(hit), hit);
                saveas(saveobj.fig2, fullfile(savepath, sname))
                
                recon(hit).recon = gather(hipr.ws);
                recon(hit).W = gather(hipr.W);
                recon(hit).scatt = gather( exp(1i*hipr.PHASE) .* ( ( hipr.INT .* (1-hipr.MASK) ) + ( hipr.SCATT.* hipr.MASK ) ) );
                recon(hit).droplet_shape = gather(hipr.density);
                recon(hit).oneshot = gather(hipr.oneshot);
                recon(hit).errorR = gather(hipr.errReal);
                recon(hit).errorF = gather(hipr.errFourier);
                recon(hit).parameter.run = run;
                recon(hit).parameter.hit = hit;
                recon(hit).parameter.T = db_run_info(run).source.T;
                recon(hit).parameter.p = db_run_info(run).source.p;
                recon(hit).parameter.delay =  db_run_info(run).source.delayTime;
                recon(hit).parameter.R_guinier = db_sizing(run).R(hit)*1e9;
                recon(hit).parameter.a = shape.a/2*6;
                recon(hit).parameter.b = shape.b/2*6;
                recon(hit).parameter.rot = mod(shape.rot,2*pi);
                recon(hit).parameter.center = center;
                recon(hit).parameter.photonsOnDetector = int32(nansum(img(:)));
                recon(hit).parameter.litPixel = int32(db_run_info(run).nlit_smooth(hit));
                recon(hit).parameter.dopant = db_run_info(run).doping.dopant{:};
                recon(hit).parameter.depletion = db_run_info(run).doping.depletion;
                recon(hit).parameter.ar = db_shape(run).shape(hit).ar;
                recon(hit).parameter.uit = saveobj.uit.Data;
                nextfun;
        end
    end