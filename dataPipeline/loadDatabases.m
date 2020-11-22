function db =  loadDatabases(paths, db)
    if nargin<2
        load(fullfile(paths.db, 'db.mat'), 'db');
    end
    if ~isfield(db, 'runInfo')
        fprintf( 'loading db_run_info from %s ... \n', fullfile(paths.db) );
        load(fullfile(paths.db, 'db_run_info.mat'), 'db_run_info');
        db.runInfo = db_run_info;
    end
    if ~isfield(db ,'center')
        fprintf( 'loading db_center from %s ... \n', fullfile(paths.db) );
        load(fullfile(paths.db, 'db_center.mat'), 'db_center');
        db.center = db_center;
    end
    if ~isfield(db, 'shape')
        fprintf( 'loading db_shape from %s ... \n', fullfile(paths.db) );load(fullfile(paths.db, 'db_shape.mat'), 'db_shape');
        db.shape = db_shape;
    end
    if ~isfield(db, 'sizing')
        fprintf( 'loading db_sizing from %s ... \n', fullfile(paths.db) );
        load(fullfile(paths.db, 'db_sizing.mat'), 'db_sizing');
        db.sizing = db_sizing;
    end

%     save(fullfile(xfelPaths.db, 'db_backups', sprintf('db_%s.mat', datestr(datetime, 'yyyymmdd_HHMM'))), 'db');
end
