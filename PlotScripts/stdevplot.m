function stdevplot(dbTable, dbXField, dbYField)
%%initialize database connection and field names
dbName = 'borrdata' ;
dbUser ='postgres' ;
dbPassword = 'borr' ;
conn = database(dbName, dbUser, dbPassword, ...
                'Vendor', 'PostGreSQL', ...
                'Server', 'LocalHost') ;
%prepare output paths
topFolder = ['C:\Users\Michael\Desktop\MATLAB\stdev_plots\' ...
             sprintf('%s_vs_%s', dbYField, dbXField) ]  ;
mkdir(topFolder) ;
%get years
yearQuery = [sprintf('SELECT DISTINCT year FROM %s ', dbTable ) ...
             'ORDER BY year' ] ;
allYears = cell2mat(fetch(conn, yearQuery) ) ;
for j = 1:size(allYears, 1)
    %get months
    monthQuery = [sprintf('SELECT DISTINCT month FROM %s WHERE year=%i ', ...
                          dbTable, allYears(j) ) 'ORDER BY month' ];
    monthsThisYear = cell2mat(fetch(conn, monthQuery) ) ;
    %for each month
    for k = 1:size(monthsThisYear, 1)
        dataQuery = [sprintf('SELECT %s, %s, %s FROM %s ', ...
                             dbXField, dbYField, 'nodeid', dbTable ) ...
                     sprintf('WHERE year=%i AND month=%i ', ...
                                 allYears(j), monthsThisYear(k) ) ...
                     sprintf('ORDER BY %s', dbXField) ] ;     
        %get the data
        allData = fetch(conn, dataQuery) ;
        xData = cell2mat(allData(:, 1) ) ;
        yData = cell2mat(allData(:, 2) ) ;
        nodeList = cell2mat(allData(:, 3) ) ;
       %plot the data
       plot(xData, yData, 'bo') ;
       title(sprintf('%s vs. %s', dbYField, dbXField), ...
             'interpreter', 'none') ;
       ylabel(dbYField, 'interpreter', 'none') ;
       xlabel(dbXField, 'interpreter', 'none') ;
       filePath = sprintf('%s\\%i-%i-%s_vs_%s', ...
                          topFolder, allYears(j), monthsThisYear(k), ...
                          dbYField, dbXField ) ;
       hgsave(filePath) ;
       clf ;
    end
end
       