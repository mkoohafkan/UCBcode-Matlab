% perform multivariate regression on monthly data
% THIS SCRIPT IS INTENDED TO BE MODIFIED FOR DIFFERENT OUTPUTS
%% initialize variables
INITFLAG = true ; %change to false if you plan to use a wrapper
if INITFLAG ;
    clearvars ;
    dbtable = 'alltemphumiditymonthlyprops' ;
    dbfields = {'nodeid' ;  % or alternative uid; uid must always be first! 
                'z' ; 'slope' ; 'aspect' ; 'canopyheight' ; % predictors next
                'dist2pond' ; 
                'temperature_avg' ; % for specific humidity
                'temperature_avgmin'} ; % response variable must always be last!
    modeltype = 'linear' ; % see LinearModel.fit class for details
    pcrit = 'sse' ;
    elevtag = 'highelev' ; % 'highelev' 'allelev'
    pcols = logical([0 1 1 1 1 1 0 0]) ; % specify which fields are predictors
    sh = false ; % flag indicating relative humidity is to be converted to specific humidity
    %extractnodes = [41 42 43 31 32 44 45 33] ; % nodes to be extracted from set
    extractnodes = [] ;
end
if sh
    tcol = ismember(dbfields, 'temperature_avg') ;
end

%% connect to database
conn = connect_to_BORR ;

%% build queries and output paths for investigation
[mvqueries, outpaths] = get_queries(conn, dbtable, dbfields, ...
                                    false, true, true, false, ...
                                    dbfields{2} ) ;
topfolder = ['C:\Users\Michael\Desktop\ANALYSIS\mv plots no 32\' ...
                 sprintf('%s\\%s\\', dbtable, pcrit) ...
                 sprintf('%s\\', elevtag)] ;
if sh
    topfolder = [topfolder sprintf('%s\\', ['specifichumidity' dbfields{end}(9:end)] ) ] ;    
else
    topfolder = [topfolder sprintf('%s\\', dbfields{end} ) ] ; 
end
mkdir(topfolder) ;
mkdir([topfolder 'z only'])

%% run the regression on each query 
% initialize variables for comparisons
models = cell(size(mvqueries) ) ;
zmodels = cell(size(mvqueries) ) ;
tags = cell(size(mvqueries) ) ;
for i = 1:size(mvqueries, 1)
    alldata = cell2mat(fetch(conn, mvqueries{i} ) ) ;
    % extract specified nodes from dataset (if any)
    if ~isempty(extractnodes)
        alldata = alldata(ismember(alldata(:, 1), extractnodes), :) ;
    end
    % pull the predictor and response data
    X = alldata(:, pcols) ;
    Xpredictors = dbfields(pcols) ;
    observationvar = dbfields{end} ;
    % treat the predictor data
    for j = 1:size(X, 2)
        X(:, j) = clean_data(X(:, j), Xpredictors{j} ) ;
    end
    % treat the response data
    y = clean_data(alldata(:, end), observationvar) ;
    % special case--treat slope aspect data
    sa = ismember(Xpredictors, {'slope' 'aspect'} )  ;
    if sum(sa) == 2
        X(:, sa) = clean_data(X(:, sa), 'slope-aspect') ;
    end
    % filter by elevation
    switch elevtag
        case 'lowelev'
            X(gt(X(:, 1), 2100), 1) = NaN ;
        case 'highelev'
            X(le(X(:, 1), 2100), 1) = NaN ;     
    end
    % invert values of dist2pond
    sa = ismember(Xpredictors, 'dist2pond') ;
    if sum(sa) == 1
        X(:, sa) = 1./X(:, sa) ;
        Xpredictors(sa) = {'inv_dist2pond'} ;
    end
    % invert values of dist2creek
    sa = ismember(Xpredictors, 'dist2creek') ;
    if sum(sa) == 1
        X(:, sa) = 1./X(:, sa) ;
        Xpredictors(sa) = {'inv_dist2creek'} ;
    end
    % Take cosine of aspect to make it linear
    sa = ismember(Xpredictors, 'aspect') ;
    if sum(sa) == 1
        X(:, sa) = arrayfun(@cosd, X(:, sa) );
        Xpredictors(sa) = {'cos_aspect'} ;
    end
    % convert relative humidity to specific humidity, if specified
    if sh
        y = arrayfun(@getspecifichumidity, y, alldata(:, tcol) ) ;
        observationvar = ['specifichumidity' observationvar(9:end)] ;
    end
    % remove outlier nodes
	badnodes = isnan(clean_data(alldata(:, 1), dbfields{1} ) ) ;
    y(badnodes, 1) = NaN ;
    % filter out bad rows
    dataflags = ~any(isnan([X y]), 2) ;
    X = X(dataflags, :) ;
    y = y(dataflags, 1) ;
    ids = alldata(dataflags, 1) ;
    if size(y, 1) < 2
        fprintf(['not enough good observations returned by query \n' ...
                 mvqueries{i} '\n' 'regression will not be performed.' ...
                 '\n'] ) ;
    else 
        [~, models{i}] = multivariate_plot(X, y, modeltype, ...
                                   'outpath', [topfolder outpaths{i} ], ...
                                   'predictorfields', Xpredictors, ...
                                   'observationfield', observationvar, ...
                                   'predictorcriterion', pcrit, ...
                                   'uidlist', ids ) ;
        [~, zmodels{i}] = multivariate_plot(X(:, 1), y, modeltype, ...                                   
                                   'outpath', [topfolder 'z only\' outpaths{i} '_z-only'], ...                               
                                   'predictorfields', Xpredictors(1), ...
                                   'observationfield', observationvar, ...
                                   'predictorcriterion', pcrit, ...
                                   'uidlist', ids ) ;                               
        tags{i} = outpaths{i} ;
    end
end

%% compare coefficients
% filter out empty cells (regression was not performed)
models = models(~cellfun('isempty', models) ) ;
zmodels = zmodels(~cellfun('isempty', zmodels) ) ;
tags = tags(~cellfun('isempty', tags) ) ; 
% run diagnostics on regression runs
[modelvals, modelstats, freqstats] = multivariate_diagnostics(models, zmodels, tags) ;

%% output results to file
dlmcell([topfolder 'diagnostics.csv'], {'Model form frequency'}, ',') ;
dlmcell([topfolder 'diagnostics.csv'], freqstats, ',', '-a') ;
dlmcell([topfolder 'diagnostics.csv'], {'Parameter estimates'}, ',', '-a') ;
dlmcell([topfolder 'diagnostics.csv'], modelvals, ',', '-a') ;
dlmcell([topfolder 'diagnostics.csv'], {'Parameter differential Adjusted R^2'}, ',', '-a') ;
dlmcell([topfolder 'diagnostics.csv'], modelstats, ',', '-a') ;

%% plot coefficients across runs
plot_diagnostics(modelvals, topfolder) ;

%% plot multiple months together


%% clean up after yourself
close('all') ;