function windroseplot()
clear ;
clf ;
%connection details
dbName = 'borrdata' ;
dbUser ='postgres' ;
dbPassword = 'borr' ;
conn = database(dbName, dbUser, dbPassword, ...
                'Vendor', 'PostGreSQL', ...
                'Server', 'LocalHost') ;
%query details
dbTable = 'windtempprops' ;
dbYFields = {'windavg' ; 'winddiravg'} ;
%prep output path
topFolder = 'C:\Users\Michael\Desktop\MATLAB\windrose_plots\' ;
mkdir(topFolder) ;
%get years
yearQuery = [sprintf('SELECT DISTINCT year FROM %s ', dbTable ) ...
             'ORDER BY year' ] ;
allYears = cell2mat(fetch(conn, yearQuery) ) ;
%for each year
for i = 1:size(allYears, 1)
    %get months
    monthQuery = [sprintf('SELECT DISTINCT month FROM %s WHERE year=%i ', ...
                          dbTable, allYears(i) ) 'ORDER BY month' ] ;
    monthsThisYear = cell2mat(fetch(conn, monthQuery) ) ;
    %for each month
    for j = 1:size(monthsThisYear, 1)
        %get nodes
        nodeQuery = [sprintf('SELECT DISTINCT nodeid FROM %s ', dbTable ) ...
                     sprintf('WHERE year=%i and month=%i ', ...
                             allYears(i), monthsThisYear(j) ) ...
                     'ORDER BY nodeid' ] ;
        nodesThisMonth = cell2mat(fetch(conn, nodeQuery) ) ;
        for k = 1:size(nodesThisMonth)
            dataQuery = ['SELECT ' join(', ', dbYFields) ...
                         sprintf(' FROM %s ', dbTable) ...
                         sprintf('WHERE year=%i AND month=%i AND nodeid=%i ', ...
                                 allYears(i), monthsThisYear(j), nodesThisMonth(k) ) ...  
                         'AND hour>=7 AND hour<=19 ' ...
                         'ORDER BY hour' ] ;
            allData = cell2mat(fetch(conn, dataQuery) ) ;
            speedData = allData(:,1) ;
            dirData = allData(:,2) ;
            nodePropsQuery = sprintf('SELECT z, aspect FROM %s WHERE nodeid=%i', ...
                                     dbTable, nodesThisMonth(k) ) ;
            props = cell2mat(fetch(conn, nodePropsQuery) ) ;
            z = props(1,1) ;
            a = props(1,2) ;
            plotTitle = sprintf('%i-%i-node-%i', allYears(i), ...
                                monthsThisYear(j), nodesThisMonth(k) ) ;
            outPath = [topFolder plotTitle] ;
            plotTitle = [plotTitle sprintf(' z=%i, aspect=%5.2f', z, a) ] ; 
            [~, roseData] = wind_rose(dirData, speedData, ...
                                      'labtitle', plotTitle, ...
                                      'lablegend', 'windspeed') ; %dtype=?
            hgsave(outPath) ;
            clf ;
        end
    end
    clearvars monthQuery monthsThisYear nodeQuery nodesThisMonth ...
              dataQuery allData speedData dirData roseData props z a
end

end