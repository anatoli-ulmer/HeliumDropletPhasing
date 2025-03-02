function db =  loadDatabases(paths, db)
    if nargin<2
        load(fullfile(paths.db, 'db.mat'), 'db');
    end
%     save(fullfile(xfelPaths.db, 'db_backups', sprintf('db_%s.mat', datestr(datetime, 'yyyymmdd_HHMM'))), 'db');
end
