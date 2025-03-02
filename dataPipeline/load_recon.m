function hRecon = load_recon(newrun, reconpath)
    fprintf('loading recon file ... #%.0f ', newrun); drawnow;
    hRecon = [];
    f = dir(fullfile(reconpath, sprintf('r*%03d_recon*', newrun)));
    if ~isempty(f)
        if numel(f)>1
            warning('WARNING run %i: more than one file in recondata directory! Loading only first file.', newrun)
        end
        load(fullfile(reconpath, f.name), 'hRecon');
    end
    fprintf('done!\n'); drawnow;
end
