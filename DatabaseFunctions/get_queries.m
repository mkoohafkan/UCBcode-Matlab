function [queries, labels] = get_queries(conn, table, selectfields, ...
                                    by_node, by_year, by_month, by_day, ...
                                    by_hour, orderfield)
% generates a list of queries based on filtering criteria
% conn = database connection object
% table = the database table to query
% selectfields =  the table fields to be selected
% by_node = boolean, select data on per node basis
% by_year = boolean, select data on per year basis
% by_month = boolean, select data on per month basis
% by_day = boolean, select data on per daybasis
% order_last = boolean, order data by last cell in selectfields instead of
%              ordering according to selection basis
%outputs list of queries and corresponding list of tags

%determine total number of queries to generate
numqueries = 0 ;
if by_node
    [~, nodes] = get_nodebits ;
    for i = 1:size(nodes, 1) ;
        if by_year 
            [~, years] = get_yearbits(nodes(i) ) ;
            for j = 1:size(years, 1)
                if by_month 
                    [~, months] = get_monthbits(nodes(i), years(j) ) ;
                    for k = 1:size(months, 1)
                        if by_day 
                            [~, days] = get_daybits(nodes(i), years(j), months(k) ) ;
                            for l = 1:size(days, 1)                            
                                if by_hour % query by nodeid, year, month, day, hour
                                    [~, hours] = get_hourbits(nodes(i), years(j), months(k), days(l) ) ;
                                    numqueries = numqueries + size(hours, 1) ;
                                else %query by nodeid, year, month, day
                                    numqueries = numqueries + 1 ; 
                                end
                            end
                        else % query by nodeid, year, month
                            numqueries = numqueries + 1 ;
                        end
                    end
                else %query by nodeid, year
                    numqueries = numqueries + 1 ;
                end
            end
        else % query by nodeid
            numqueries = numqueries + 1 ;
        end
    end
elseif by_year
    [~, years] = get_yearbits(0) ;
    for j = 1:size(years, 1)
        if by_month 
            [~, months] = get_monthbits(0, years(j) ) ;
            for k = 1:size(months, 1)
                if by_day
                    [~, days] = get_daybits(0, years(j), months(k) ) ;
                    for l = 1:size(days, 1)                            
                        if by_hour % query by year, month, day, hour
                            [~, hours] = get_hourbits(0, years(j), months(k), days(l) ) ;
                            numqueries = numqueries + size(hours, 1) ;
                        else %query by year, month, day
                            numqueries = numqueries + 1 ; 
                        end
                    end
                else % query by year, month
                    numqueries = numqueries + 1 ;
                end
            end
        else %query by year
            numqueries = numqueries + 1 ;
        end
    end
elseif by_month
	[~, months] = get_monthbits(0, 0) ;
    for k = 1:size(months, 1)
        if by_day
            [~, days] = get_daybits(0, 0, months(k) ) ;
            for l = 1:size(days, 1)                            
                if by_hour % query by month, day, hour
                    [~, hours] = get_hourbits(0, 0, months(k), days(l) ) ;
                    numqueries = numqueries + size(hours, 1) ;
                else %query by month, day
                    numqueries = numqueries + 1 ; 
                end
            end
        else % query by month
            numqueries = numqueries + 1 ;
        end
    end
else % query all records
    numqueries = numqueries + 1 ;
end

%Start generating queries
queries = cell(numqueries, 1) ;
labels = cell(numqueries, 1) ;
qi = 1 ; %query index
basebit = sprintf('SELECT %s FROM %s WHERE ', join(', ', selectfields), table) ;                               
if by_node
    [nodebits, nodes] = get_nodebits() ;
    for i = 1:size(nodes, 1)
        if by_year
            [yearbits, years] = get_yearbits(nodes(i)) ;
            for j = 1:size(years, 1)
                if by_month
                    [monthbits, months] = get_monthbits(nodes(i), years(j) ) ;
                    for k = 1:size(months, 1)
                        if by_day
                            [daybits, days] = get_daybits(nodes(i), years(j), months(k) ) ;
                            for l = 1:size(days, 1) 
                                if by_hour
                                    [hourbits, hours] = get_hourbits(nodes(i), years(j), months(k), days(l) ) ;
                                    for m=1:size(hours)
                                        if ~isempty(orderfield)
                                            orderbit = sprintf('ORDER BY %s', orderfield ) ;
                                        else
                                            orderbit = 'ORDER BY nodeid, year, month, day, hour' ;
                                        end
                                        queries{qi} = [basebit nodebits{i} 'AND ' yearbits{j} ...
                                                       'AND ' monthbits{k} 'AND ' daybits{l} ...
                                                       'AND ' hourbits{m} orderbit ] ;
                                        labels{qi} = sprintf('%i_%04d-%02d-%02d-%02d00', ...
                                                             nodes(i), years(j), months(k), ...
                                                             days(l), hours(m) ) ;
                                        qi = qi + 1 ;                                        
                                    end
                                else % noideid, month, year, day
                                    if ~isempty(orderfield)
                                        orderbit = sprintf('ORDER BY %s', orderfield ) ;
                                    else
                                        orderbit = 'ORDER BY nodeid, year, month, day' ;
                                    end
                                    queries{qi} = [basebit nodebits{i} 'AND '...
                                                   yearbits{j} 'AND ' monthbits{k} ...
                                                   'AND ' daybits{l} orderbit ] ; 
                                    labels{qi} = sprintf('%i_%04d-%02d-%02d', nodes(i), ...
                                                 years(j), months(k), days(l) ) ;                                       
                                    qi = qi + 1 ;                                    
                                end
                            end
                        else %nodeid, year, month
                            if ~isempty(orderfield)
                                orderbit = sprintf('ORDER BY %s', orderfield ) ;
                            else
                                orderbit = 'ORDER BY nodeid, year, month' ;
                            end
                            queries{qi} = [basebit nodebits{i} 'AND '...
                                           yearbits{j} 'AND ' monthbits{k} ...
                                           orderbit ] ; 
                            labels{qi} = sprintf('%i_%04d-%02d', nodes(i), years(j), months(k) ) ;                                       
                            qi = qi + 1 ;
                        end
                    end
                else % nodeid, year
                    if ~isempty(orderfield)
                        orderbit = sprintf('ORDER BY %s', orderfield ) ;
                    else
                        orderbit = 'ORDER BY nodeid, year ' ;
                    end
                    queries{qi} = [basebit nodebits{i} 'AND ' ...
                                   yearbits{j} orderbit ] ;
                    labels{qi} = sprintf('%i_%04d', nodes(i), years(j) ) ;
                    qi = qi + 1 ;                    
                end
            end
        elseif by_month
            [monthbits, months] = get_months(nodes(i), 0 ) ;
            for k = 1:size(months, 1)
                if by_day % nodeid, month, day
                    
                    [daybits, days] = get_daybits(nodes(i), 0, months(k) ) ;
                    for l = 1:size(days, 1) % nodeid, month, day
                        if ~isempty(orderfield)
                            orderbit = sprintf('ORDER BY %s', orderfield ) ;
                        else
                            orderbit = 'ORDER BY nodeid, month, day' ;
                        end
                        queries{qi} = [basebit nodebits{i} 'AND '...
                                       monthbits{k} 'AND ' daybits{l} ...
                                       orderbit ] ;
                        labels{qi} = sprintf('%i_%02d-%02d', nodes(i), months(k), days(l) ) ;                                   
                        qi = qi + 1 ;
                    end
                else % nodeid, month
                    if ~isempty(orderfield)
                        orderbit = sprintf('ORDER BY %s', orderfield ) ;
                    else
                        orderbit = 'ORDER BY nodeid, month' ;
                    end
                    queries{qi} = [basebit nodebits{i} 'AND ' ...
                                   monthbits{k} orderbit ] ;
                    labels{qi} = sprintf('%i_%02d', nodes(i), months(k) ) ;
                    qi = qi + 1 ;
                end
            end
        elseif by_day
            [daybits, days] = get_daybits(nodes(i), 0, months(k) ) ;
            for l = 1:size(days, 1) %nodeid, day
                if ~isempty(orderfield)
                    orderbit = sprintf('ORDER BY %s', orderfield ) ;
                else
                    orderbit = 'ORDER BY nodeid, day' ;
                end
                queries{qi} = [basebit nodebits{i} 'AND '...
                               daybits{l} orderbit ] ;
                labels{qi} = sprintf('%i_%02d', nodes(i), days(l) ) ;
                qi = qi + 1 ;
            end
        else % nodeid
            if ~isempty(orderfield)
                orderbit = sprintf('ORDER BY %s', orderfield ) ;
            else
                orderbit = 'ORDER BY nodeid ' ;
            end
            queries{qi} = [basebit nodebits{i} orderbit ] ;
            labels{qi} = sprintf('%i', nodes(i) ) ;
            qi = qi + 1 ;            
        end
    end
elseif by_year
    [yearbits, years] = get_yearbits(0) ;
    for j = 1:size(years, 1)
        if by_month
            [monthbits, months] = get_monthbits(0, years(j) ) ;
            for k = 1:size(months, 1)
                if by_day
                    [daybits, days] = get_daybits(0, years(j), months(k) ) ;
                    for l = 1:size(days, 1) % year, month, day
                        if by_hour
                            [hourbits, hours] = get_hourbits(0, years(j), months(k), days(l) ) ;
                            for m = 1:size(hours, 1)
                                if ~isempty(orderfield)
                                    orderbit = sprintf('ORDER BY %s', orderfield ) ;
                                else
                                    orderbit = 'ORDER BY year, month, day, hour' ;
                                end
                                queries{qi} = [basebit yearbits{j} 'AND ' ...
                                               monthbits{k} 'AND ' daybits{l} ...
                                               'AND ' hourbits{m} orderbit ] ;
                                labels{qi} = sprintf('%04d-%02d-%02d-%02d00', years(j), months(k), days(l), hours(m) ) ;
                                qi = qi + 1 ;                                
                            end
                        else
                            if ~isempty(orderfield)
                                orderbit = sprintf('ORDER BY %s', orderfield ) ;
                            else
                                orderbit = 'ORDER BY year, month, day' ;
                            end
                            queries{qi} = [basebit yearbits{j} 'AND ' ...
                                           monthbits{k} 'AND ' daybits{l} ...
                                           orderbit ] ;
                            labels{qi} = sprintf('%04d-%02d-%02d', years(j), months(k), days(l) ) ;
                            qi = qi + 1 ;
                        end
                    end
                else % year, month
                    if ~isempty(orderfield)
                        orderbit = sprintf('ORDER BY %s', orderfield ) ;
                    else
                        orderbit = 'ORDER BY year, month' ;
                    end
                    queries{qi} = [basebit yearbits{j} 'AND ' ...
                                   monthbits{k} orderbit ] ;
                    labels{qi} = sprintf('%04d-%02d', years(j), months(k) ) ;
                    qi = qi + 1 ;
                end
            end
        elseif by_day
            [daybits, days] = get_daybits(0, years(j), 0 ) ;
            for l = 1:size(days, 1) % year, day
                if ~isempty(orderfield)
                    orderbit = sprintf('ORDER BY %s', orderfield ) ;
                else
                    orderbit = 'ORDER BY year, day' ;
                end
                queries{qi} = [basebit yearbits{j} 'AND ' daybits{l} ...
                               orderbit ] ;
                labels{qi} = sprintf('%04d-%02d', years(j), days(l) ) ;
                qi = qi + 1 ;
            end
        else % year
            if ~isempty(orderfield)
                orderbit = sprintf('ORDER BY %s', orderfield ) ;
            else
                orderbit = 'ORDER BY year ' ;
            end
            queries{qi} = [basebit yearbits{j} orderbit ] ;
            labels{qi} = sprintf('%04d', years(j) ) ;
            qi = qi + 1 ;
        end
    end
elseif by_month
    [monthbits, months] = get_monthbits(0, 0 ) ;
    for k = 1:size(months, 1)
        if by_day
            [daybits, days] = get_daybits(0, 0, months(k) ) ;
            for l = 1:size(days, 1) % month, day
                if ~isempty(orderfield)
                    orderbit = sprintf('ORDER BY %s', orderfield ) ;
                else
                    orderbit = 'ORDER BY month, day' ;
                end
                queries{qi} = [basebit monthbits{k} 'AND ' daybits{l} ...
                               orderbit ] ;
                labels{qi} = sprintf('%02d-%02d', months(k), days(l) ) ;
                qi = qi + 1 ;
            end
        else % month
            if ~isempty(orderfield)
                orderbit = sprintf('ORDER BY %s', orderfield ) ;
            else
                orderbit = 'ORDER BY month' ;
            end
            queries{qi} = [basebit monthbits{k} orderbit ] ;
            labels{qi} = sprintf('%02d', months(k) ) ;
            qi = qi + 1 ;
        end
    end
elseif by_day
    [daybits, days] = get_daybits(0, 0, 0 ) ;
    for l = 1:size(days, 1) % by day
        if ~isempty(orderfield)
            orderbit = sprintf('ORDER BY %s', orderfield ) ;
        else
            orderbit = 'ORDER BY day' ;
        end
        queries{qi} = [basebit daybits{l} orderbit ] ;
        labels{qi} = sprintf('%02d', days(l) ) ;
        qi = qi + 1 ;
    end
else % all data
    basebit = sprintf('SELECT %s FROM %s ', join(', ', selectfields), table) ;
    orderbit = sprintf('ORDER BY %s', orderfield ) ;
    queries{qi} =  [basebit orderbit] ;
    labels{qi} = 'all' ;
end
    
%--------------------------------------------------------------------------                             
    function [y, r] = get_nodebits()
        %determine number of years
        q = [sprintf('SELECT DISTINCT nodeid FROM %s ', table ) ...
             'ORDER BY nodeid' ] ;
        r = cell2mat(fetch(conn, q) ) ;
        n = size(r, 1) ;
        y = cell(n, 1) ;
        for ii = 1:n
            y{ii} = sprintf('nodeid=%i ', r(ii) ) ;
        end
    end
%--------------------------------------------------------------------------
    function [y, r] = get_yearbits(thisnode)
        %determine number of years
        q = sprintf('SELECT DISTINCT year FROM %s ', table ) ;
        if thisnode ~= 0
            q = [q sprintf('WHERE nodeid=%i ', thisnode)]  ;
        end
        q = [q 'ORDER BY year' ] ;
        r = cell2mat(fetch(conn, q) ) ;
        n = size(r, 1) ;
        y = cell(n, 1) ;
        for ii = 1:n
            y{ii} = sprintf('year=%i ', r(ii) ) ;
        end
    end
%--------------------------------------------------------------------------
    function [m, r] = get_monthbits(thisnode, thisyear)
        %determine number of months
        q = sprintf('SELECT DISTINCT month FROM %s ', table ) ;
        if thisnode ~= 0
            q = [q sprintf('WHERE nodeid=%i ', thisnode) ] ;
            if thisyear ~= 0
                q = [q sprintf('AND year=%i ', thisyear) ] ;
            end
        elseif thisyear ~= 0
            q = [q sprintf('WHERE year=%i ', thisyear) ] ;
        end
        q = [q 'ORDER BY month' ] ;
        r = cell2mat(fetch(conn, q) ) ;
        n = size(r, 1) ;
        m = cell(n, 1) ;
        for ii = 1:n
            m{ii} = sprintf('month=%i ', r(ii) ) ;
        end
    end
%--------------------------------------------------------------------------
    function [d, r] = get_daybits(thisnode, thisyear, thismonth)
        %determine number of months
        q = sprintf('SELECT DISTINCT day FROM %s ', table ) ;
        if thisnode ~= 0
            q = [q sprintf('WHERE nodeid=%i ', thisnode) ] ;
            if thisyear ~= 0
                q = [q sprintf('AND year=%i ', thisyear) ] ;
                if thismonth ~= 0
                    q = [q sprintf('AND month=%i ', thismonth) ] ;
                end
            end
        elseif thisyear ~= 0
            q = [q sprintf('WHERE year=%i ', thisyear) ] ;
            if thismonth ~= 0
                q = [q sprintf('AND month=%i ', thismonth) ] ;
            end        
        elseif thismonth ~=0
            q = [q sprintf('WHERE month=%i ', thismonth) ] ;
        end
        q = [q 'ORDER BY day' ] ;
        r = cell2mat(fetch(conn, q) ) ;
        n = size(r, 1) ;
        d = cell(n, 1) ;
        for ii = 1:n
            d{ii} = sprintf('day=%i ', r(ii) ) ;
        end
    end
%--------------------------------------------------------------------------
    function [d, r] = get_hourbits(thisnode, thisyear, thismonth, thisday)
        %determine number of months
        q = sprintf('SELECT DISTINCT hour FROM %s ', table ) ;
        if thisnode ~= 0
            q = [q sprintf('WHERE nodeid=%i ', thisnode) ] ;
            if thisyear ~= 0
                q = [q sprintf('AND year=%i ', thisyear) ] ;
                if thismonth ~= 0
                    q = [q sprintf('AND month=%i ', thismonth) ] ;
                    if thisday ~= 0
                        q = [q sprintf('AND day=%i ', thisday) ] ;                        
                    end
                end
            end
        elseif thisyear ~= 0
            q = [q sprintf('WHERE year=%i ', thisyear) ] ;
            if thismonth ~= 0
                q = [q sprintf('AND month=%i ', thismonth) ] ;
                if thisday ~= 0
                    q = [q sprintf('AND day=%i ', thisday) ] ;
                end
            end        
        elseif thismonth ~=0
            q = [q sprintf('WHERE month=%i ', thismonth) ] ;    
            if thisday ~= 0
                q = [q sprintf('AND day=%i ', thisday) ] ;
            end
        end
        q = [q 'ORDER BY hour' ] ;
        r = cell2mat(fetch(conn, q) ) ;
        n = size(r, 1) ;
        d = cell(n, 1) ;
        for ii = 1:n
            d{ii} = sprintf('hour=%i ', r(ii) ) ;
        end
    end
%--------------------------------------------------------------------------
end