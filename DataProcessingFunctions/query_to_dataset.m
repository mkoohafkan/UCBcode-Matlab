function ds = query_to_dataset(query, conn, fields)
% query the database, treat the data, and convert to a dataset
% treating the data is baed on additional functions treat_data,
% aspect_to_categories

% query = SQL query string
% conn = the databsed connection object
% fields = the cell array of field names

% ds = the resulting dataset

% query the database
raw = cell2mat(fetch(conn, query) ) ;
% check that the query matched the fields cell provided
if length(fields) ~= size(raw, 2)
    fprintf('error: number of fields does not match size of data returned by query') ;
    return
end
% check if both slope and aspect data exist
sidx = find(strcmp(fields, 'slope'), 1) ;
aidx = find(strcmp(fields, 'aspect'), 1) ;
if ~isempty(sidx) && ~isempty(aidx)
    sa = true ;
else
    sa = false ;
end
% check if both wind speed and direction exist
wsidx = find(strcmp(fields, 'windspeed'), 1) ;
wdidx = find(strcmp(fields, 'winddir'), 1) ;
if ~isempty(wsidx) && ~isempty(wdidx)
    wsd = true ;
else
    wsd = false ;
end
% clean the data
clean = nan(size(raw) ) ;
for i = 1:length(fields)
    clean(:, i) = clean_data(raw(:, i), fields{i}) ;
end
% additional processing
if sa
    % clean slope and aspect together
    clean(:, [sidx aidx]) = correct_slopeaspect(clean(:, [sidx aidx]) ) ;
end
if wsd
    % clean winddir based on windspeed
    clean(:, [wsidx wdidx]) = correct_wind(clean(:, [wsidx wdidx]) ) ;
end
% removal of rows containing NaN 
badrows = any(isnan(clean), 2) ;
clean(badrows, :) = [] ;
% categorical processing and conversion to dataset
ds = dataset() ;
for i = 1:length(fields)
    % process categorical data where necessary
    switch fields{i}
        case 'aspect'
            processed = aspect_to_categories(clean(:, i) ) ;
        otherwise
            processed = clean(:, i) ;
    end            
    tmpds = dataset({processed, fields{i} }) ;
    ds = [ds tmpds] ; % matlab compains. Maybe they should give the option
                      % of adding columns to an existing dataset then!!
end