function sampled_points = get_sampled_points(conn, table, year, month, fields)
% conn = database connection object
% table = table in database to be queried
% year = year that data is to be selected from
% month = month that data is to be selected from
% fields = array of fields to query

% example
% conn = connect_to_BORR
% table = my_table
% fields = {'x', 'y', 'z', 'temperature_avgmin', 'temperature_avgmax'}
% year = 2011
% month = 6
% => query = 'SELECT x, y, z, temperature_avg 
%          FROM my_table 
%          WHERE year = 2011 AND month = 6'
% fetch(conn, q)
% => sampled_points = [x(:) y(:) z(:) temperature_avg(:)]

q = ['SELECT ' join(', ', fields) ' FROM ' table ' WHERE '
     sprintf('year = %i AND month = %i', year, month)] ;
sampled_points = cell2mat(fetch(conn, q)) ;
end