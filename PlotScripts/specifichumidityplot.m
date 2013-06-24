function specifichumidityplot(dbTable, dbXField, elevTag)
%%initialize database connection and field names
dbName = 'borrdata' ;
dbUser ='postgres' ;
dbPassword = 'borr' ;
%dbTable = 'TempHumidityMonthlyProps' ;
%dbXField = 'z' ;
%dbYField = 'temperature_avg' ; 
conn = database(dbName, dbUser, dbPassword, ...
                'Vendor', 'PostGreSQL', ...
                'Server', 'LocalHost') ;
switch elevTag
    case 'low'
        zCriteria = 'z<2100' ; %look only at low elevations           
    case 'high'
        zCriteria = 'z>=2100' ; %look only at high elevations
    otherwise
        zCriteria = 'z>=0' ; %look at all elevations
end
dbYFields = {'temperature_avg' ; 'humidity_avg' ; 'bpressure_avg'} ;
slopeCriteria = 'slope>12' ; %we don't trust low slope values
aspectCriteria = slopeCriteria ; %aspect values use slope data
canopyCriteria = 'canopyheight>=0' ; %canopy heights <0 are unmeasured 
%prepare output paths
topFolder = ['C:\Users\Michael\Desktop\MATLAB\regression plots\' ...
             sprintf('specifichumidity_vs_%s', dbXField) ]  ;
mkdir(topFolder) ;
%get years
yearQuery = [sprintf('SELECT DISTINCT year FROM %s ', dbTable ) ...
             'ORDER BY year' ] ;
allYears = cell2mat(fetch(conn, yearQuery) ) ;
%slopeArray = zeros(0, 2) ;
for i = 1:size(allYears, 1)
    %get months
    monthQuery = [sprintf('SELECT DISTINCT month FROM %s WHERE year=%i ', ...
                          dbTable, allYears(i) ) ...
                  'ORDER BY month' ];
    monthsThisYear = cell2mat(fetch(conn, monthQuery) ) ;
    %for each month
    for j = 1:size(monthsThisYear, 1)
        dataQuery = [sprintf('SELECT nodeid, %s, ', dbXField) ...
                     join(', ', dbYFields) ...
                     sprintf(' FROM %s ', dbTable) ...
                     sprintf('WHERE year=%i AND month=%i ', ...
                     allYears(i), monthsThisYear(j) ) ] ;
        allData = fetch(conn, dataQuery) ;
        if size(allData, 1) < 2
            fprintf('not enough data in %i-%i to perform regression\n', ...
                    monthsThisYear(j), allYears(i) ) ;
        else
            xData = cell2mat(allData(:, 2) ) ; 
            tData = cell2mat(allData(:, 3) ) ;
            rhData = cell2mat(allData(:, 4) ) ;
            pData = cell2mat(allData(:, 5) ) ;
            nodeList = cell2mat(allData(:, 1) ) ;
            shData = arrayfun(@getspecifichumidity, rhData, tData, pData) ;
            %perform the regression
            %robust regression
            [robustFitY, robustStats] = robustfit(xData, shData) ;
            [regFitY,~,~,~, regStats] = regress(shData, ...
                                                [ones(size(xData, 1), 1) xData]) ;
                        %plot the data using plotfitstats function
            filePath = sprintf('%s\\%i-%i-%s_vs_%s', ...
                               topFolder, allYears(i), monthsThisYear(j), ...
                               'specifichumidity_avg', dbXField ) ;
            plotfitstats(filePath, dbXField, 'specifichumidity_avg', ...
                         xData, shData, robustFitY, robustStats , ...
                         regFitY, regStats, nodeList ) ;
        end
    end

end
end