function windplot()
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
dbXFields = {'z'; 'aspect'} ;
dbYFields = {'windavg' ; 'winddiravg'} ;
%criteria for filtering bad data
hours = [20:23]' ;
hourMarkers = {'b^' ; 'g^' ; 'c^' ; 'r^'} ;
zCriteria = 'z<2100' ;
slopeCriteria = 'slope>12' ;
aspectCriteria = slopeCriteria ;
%prep output path
topFolder = 'C:\Users\Michael\Desktop\MATLAB\wind_plots\' ;
mkdir(topFolder) ;
%get years
yearQuery = [sprintf('SELECT DISTINCT year FROM %s ', dbTable ) ...
             'ORDER BY year' ] ;
allYears = cell2mat(fetch(conn, yearQuery) ) ;
%for each year
for j = 1:size(allYears, 1)
    %get months
    monthQuery = [sprintf('SELECT DISTINCT month FROM %s WHERE year=%i ', ...
                          dbTable, allYears(j) ) 'ORDER BY month' ] ;
    monthsThisYear = cell2mat(fetch(conn, monthQuery) ) ;
    %for each month
    for k = 1:size(monthsThisYear, 1)
        dayQuery = [sprintf('SELECT DISTINCT day FROM %s ', dbTable) ...
                    sprintf('WHERE year=%i AND month=%i', ...
                            allYears(j), monthsThisYear(k) ) ... 
                    'ORDER BY day' ] ;
        daysThisMonth = cell2mat(fetch(conn, dayQuery) ) ;
        %for each day
        for i = 1:size(daysThisMonth, 1)
            clf ;
            %for each hour
            usedHours = cell(0) ;
            usedNodes = [] ;
            for l = 1:size(hours, 1) 
                dataQuery = ['SELECT nodeid, hour, ' ...
                             join(', ', dbXFields) ', ' join(', ', dbYFields) ...
                             sprintf(' FROM %s ', dbTable) ...
                             sprintf('WHERE year=%i AND month=%i ', ...
                                     allYears(j), monthsThisYear(k) ) ...  
                             sprintf('AND day=%i AND hour=%i ', ...
                                     daysThisMonth(i), hours(l) ) ...
                             'ORDER BY year, month, day, hour' ] ;
               allData = cell2mat(fetch(conn, dataQuery) ) ;
               %if any data was returned
                if isempty(allData) == 0
                   usedHours{end+1} = num2str(hours(l) , 'hour %i');
                   usedNodes = unique([usedNodes ; allData(:,1) ] )  ; 
                   subplot(2, 1, 1) ;
                   hold on ;
                   %plot aspect vs elevation (essentially, aspect of each node)                 
                   plot(allData(:,3), allData(:,4), 'k.') ;
                   %plot winddir vs elevation (winddir at each node)
                   plot(allData(:,3), allData(:,6), hourMarkers{l} ) ;
                   hold off ;
                   subplot(2, 1, 2) ;
                   hold on ;
                   %plot elevation vs wind speed
                   plot(allData(:,3), allData(:,5), hourMarkers{l} ) ;
                   hold off ;
                end
            end
            if any(usedNodes)
                subplot(2,1,1) ;
                ylabel('aspect');   
                subplot(2,1,2) ;
                title('blue = hour 20, green = hour 21, cyan = hour 22, red = hour 23, black = node') ;
                ylabel('average wind speed') ;
                xlabel('elevation') ; 
                titleString = {'wind speed and direction vs. elevation' ; ...
                               sprintf('for %i-%i-%i', allYears(j), monthsThisYear(k), daysThisMonth(i) )} ;
                suptitle(titleString) ;  
                outPath = [topFolder sprintf('windplot_%i-%i-%i', ...
                                     allYears(j), monthsThisYear(k), ...
                                     daysThisMonth(i) ) ] ;
                hgsave(outPath) ;
            end
        end        
    end
end
end