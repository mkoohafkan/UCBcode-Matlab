function slopeArray = regressionplot(dbTable, dbXField, dbYField, elevTag)
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
        zCriteria = 'z>=00' ; %look at all elevations
end
slopeCriteria = 'slope>12' ; %we don't trust low slope values
aspectCriteria = slopeCriteria ; %aspect values use slope data
canopyCriteria = 'canopyheight>=0' ; %canopy heights <0 are unmeasured 
%prepare output paths
topFolder = ['C:\Users\Michael\Desktop\MATLAB\regression plots\' ...
             sprintf('%s_vs_%s', dbYField, dbXField) ]  ;
mkdir(topFolder) ;
%get years
yearQuery = [sprintf('SELECT DISTINCT year FROM %s ', dbTable ) ...
             'ORDER BY year' ] ;
allYears = cell2mat(fetch(conn, yearQuery) ) ;
slopeArray = zeros(0, 2) ;
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
                                 allYears(j), monthsThisYear(k) ) ] ;
        %get data, but ignore bad values       
        if strcmp(dbXField, 'z') == 1
            dataQuery = [dataQuery sprintf('AND %s ', zCriteria) ] ;
        elseif strcmp(dbXField, 'slope') == 1
            dataQuery = [dataQuery sprintf('AND %s ', slopeCriteria) ] ;
        elseif strcmp(dbXField, 'aspect') == 1
            dataQuery = [dataQuery sprintf('AND %s ', aspectCriteria) ] ;        
        elseif strcomp(dbXField, 'canopyheight') == 1
            dataQuery = [dataQuery sprintf('AND %s ', canopyCriteria) ] ;
        else
            %x field wasn't recognized; nofilter applied
        end
        dataQuery = [dataQuery sprintf('ORDER BY %s', dbXField) ] ;
        %get the data
        allData = fetch(conn, dataQuery) ;
        if size(allData, 1) < 2
            fprintf('not enough data in %i-%i to perform regression\n', ...
                    monthsThisYear(k), allYears(j) ) ;
        else
            xData = cell2mat(allData(:, 1) ) ;
            yData = cell2mat(allData(:, 2) ) ;
            nodeList = cell2mat(allData(:, 3) ) ;
            %perform the regression
            %robust regression
            [robustFitY, robustStats] = robustfit(xData, yData) ;
            %regular regression
            [regFitY,~,~,~, regStats] = regress(yData, ...
                                                [ones(size(xData, 1), 1) xData]) ;
            %plot the data using plotfitstats function
            filePath = sprintf('%s\\%i-%i-%s_vs_%s', ...
                               topFolder, allYears(j), monthsThisYear(k), ...
                               dbYField, dbXField ) ;
            plotfitstats(filePath, dbXField, dbYField, ...
                         xData, yData, robustFitY, robustStats , ...
                         regFitY, regStats, nodeList ) ;
            %slope array is returned by function
            slopeArray(end + 1, 1) = datenum(allYears(j), ...
                                             monthsThisYear(k), 1) ;
            slopeArray(end, 2) = robustFitY(2) ;
        end
    end   
end
plotslopes(topFolder, slopeArray(:, 1), slopeArray(:, 2), dbYField)  ;
close('all') ;


    function plotslopes(outPath, x, m, field)
        plot(x, m, 'ko', x, m, 'r:') ;
        ylabel('slope') ;
        title(sprintf('Robust fit slope of %s vs. date', field), ...
              'interpreter', 'none') ;
        axis tight ;
        set(gca, 'XTick', x) ;
        datetick('x','mm-yyyy', 'keepticks', 'keeplimits') ;        
        fPath = sprintf('%s\\slope_vs_date', outPath) ;
        hgsave(fPath) ;
        clf ;
    end

end