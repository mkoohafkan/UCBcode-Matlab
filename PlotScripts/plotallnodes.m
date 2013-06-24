%%initialize database connection and field names
clear ;
dbName = 'borrdata' ;
dbUser ='postgres' ;
dbPassword = 'borr' ;
dbTable = 'TempHumidityMonthlyProps' ;
dbField = 'temperature_avg' ;
conn = database(dbName, dbUser, dbPassword, ...
                'Vendor', 'PostGreSQL', ...
                'Server', 'LocalHost') ;

%%Plot the data
%get the nodes
nodeQuery = sprintf('SELECT DISTINCT nodeid, z FROM %s ORDER BY z', dbTable) ;
resultArray = fetch(conn, nodeQuery) ;
nodeArray = cell2mat(resultArray(:, 1) ) ;
zArray = cell2mat(resultArray(:, 2) ) ;
colorArray = distinguishable_colors(size(nodeArray, 1) ) ;
legendCell = cellstr(num2str(zArray, 'elevation = %i')) ;
%iterate over each node
h = figure() ;
hold on ;
ylabel(dbField, 'interpreter', 'none') ;
title(sprintf('%s vs time', dbField), 'interpreter', 'none' );
for j = 1:size(nodeArray, 1)
    dataQuery = sprintf(['SELECT year, month, %s, z FROM %s ' ...
                         'WHERE nodeid=%i ' ...
                         'ORDER BY year, month'], ...
                        dbField, dbTable, nodeArray(j) ) ;
     resultArray = fetch(conn, dataQuery) ;
     dateArray = datenum(cell2mat(resultArray(:,1)), ... 
                         cell2mat(resultArray(:,2)), 1) ;
     dataArray = cell2mat(resultArray(:,3)) ;
     plot(dateArray, dataArray, 'Color', colorArray(j, :) ) ;
     set(gca, 'XTick', dateArray) ;
     datetick('x','mm-yyyy', 'keepticks', 'keeplimits') 
     legend(legendCell) ;
end
hold off;