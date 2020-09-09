function recon = load_recon(newrun, reconpath)
    fprintf('loading recon file ... #%.0f ', newrun); drawnow;
    recon = [];
    f = dir(fullfile(reconpath, sprintf('r%04d_recon*', newrun)));
    if ~isempty(f)
        if numel(f)>1
            warning('WARNING run %i: more than one file in recondata directory! Loading only first file.', newrun)
        end
        load(fullfile(reconpath, f.name), 'recon');
    end
    fprintf('done!\n'); drawnow;
end