%%initialize database connection and field names
clear ;
dbName = 'borrdata' ;
dbUser ='postgres' ;
dbPassword = 'borr' ;
dbTable = 'TempHumidityDailyProps' ;
dbFieldArray = {'temperature_avg'; ...
                'temperature_min'; ... 
                'temperature_max'} ;
conn = database(dbName, dbUser, dbPassword, ...
                'Vendor', 'PostGreSQL', ...
                'Server', 'LocalHost') ;

%%Plot the data
%get the nodes
nodeQuery = sprintf('SELECT DISTINCT nodeid FROM %s', dbTable) ;
nodeArray = cell2mat(fetch(conn, nodeQuery) );
%iterate over each node
topFolder = 'C:\Users\Michael\Desktop\MATLAB\timeseries_bynode\daily' ;
warning off MATLAB:MKDIR:DirectoryExists ;
mkdir(topFolder) ;
for j = 1:size(nodeArray, 1)
    %iterate over each field
    for i = 1:size(dbFieldArray, 1) ;
        dataQuery = sprintf(['SELECT year, month, day, %s FROM %s ' ...
                             'WHERE nodeid=%i ' ...
                             'ORDER BY year, month, day'], ...
                            dbFieldArray{i}, dbTable, nodeArray(j) ) ;
        resultArray = fetch(conn, dataQuery) ;
        dateArray = datenum(cell2mat(resultArray(:,1)), ... 
                            cell2mat(resultArray(:,2)), ...
                            cell2mat(resultArray(:,3))) ;
        dataArray = cell2mat(resultArray(:,4)) ;
        xTickQuery = sprintf(['SELECT DISTINCT year, month FROM %s ' ...
                              'WHERE nodeid=%i ' ...
                              'ORDER BY year, month'], ...
                              dbTable, nodeArray(j) ) ;
        xTickQueryResultArray = fetch(conn, xTickQuery) ;
        xTickArray = datenum(cell2mat(xTickQueryResultArray(:,1)), ... 
                            cell2mat(xTickQueryResultArray(:,2)), 1) ;
        h = figure() ;
        hold on ;
        plot(dateArray, dataArray, 'ro', dateArray, dataArray, 'k:') ;
        axis tight ;
        set(gca, 'XTick', xTickArray) ;
        datetick('x','mm-yyyy', 'keepticks', 'keeplimits') ;
        
        titleString = sprintf('Monthly %s for Node %i', ...
                              dbFieldArray{i}, nodeArray(j) ) ;
        title(titleString, 'interpreter', 'none') ;
        ylabel(dbFieldArray{i}, 'interpreter', 'none') ;
        
        mkdir(topFolder, dbFieldArray{i}) ;
        fileName = sprintf('node_%i_%s_timeseries', ...
                           nodeArray(j), dbFieldArray{i} ) ;
        filePath = sprintf('%s\\%s\\%s', ...
                           topFolder, dbFieldArray{i}, fileName) ;
        hgsave(h, filePath) ;
        close(h) ;
        clf('reset') ;
        clearvars dataQuery resultArray dateArray fig ...
                  titleString fileName filePath ;
    end
end
close('all') ;
clear;