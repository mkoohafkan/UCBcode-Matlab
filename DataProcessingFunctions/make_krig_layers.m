% kriging script
%% define parameters
inittime = cputime ;
inoutpath = 'C:\Users\Michael\Desktop\KrigLayers\hourly\' ; % base path and common file folder
gridpath = [inoutpath 'unsampled_space_BORR_xyz.mat'] ; % path to unsampled xyz .mat file (matrix basegrid)
rpath = 'C:\PROGRA~1\R\R-2.15.2\bin\x64\Rscript' ;
Rscriptbasepath = 'C:\Users\Michael\Desktop\GITrepo\R\borr-kriging\' ;
krigescriptpath = strrep([Rscriptbasepath 'make_krig_layers.R'], '\', '/') ; % path to my R script
colorscalescriptpath = strrep([Rscriptbasepath 'define_colormap.R'], '\', '/') ; 
plotscriptpath = strrep([Rscriptbasepath 'plot_krige_results.R'], '\', '/') ;
dbtable = 'krigetemphumiditymonthly' ; % database table to pull fields from
basefields = {'projx'; 'projy'; 'z'} ; % fields that may be used for variogram fit
% fields to be interpolated (separate output for each one!)
varfield = {'temperature_avgmin'} ;
addfields = {} ;
dbfields = vertcat(basefields, varfield, addfields) ; 
% start log file
diary([inoutpath 'log.txt']) ;
fprintf('program initialized.\n')
preptime = cputime ;
queryfilter = 'year=2011' ; % set to empty string if no filter is to be applied
queryfilter2 = '';%'month=4' ;
queryfilter3 = '';%'day=16' ;
converttometers = false ; % assume elevation is in feet, convert to meters

%% load the data
fprintf('querying database... \n \n') ;
% connect to database
conn = connect_to_BORR ;
% query the database for sample data
[mvqueries, outpaths] = get_queries(conn, dbtable, dbfields, ...
                                    false, true, true, false, false, '') ;
nqueries = size(mvqueries, 1) ;
% filter the queries using queryfilter (if specified)
if ~isempty(queryfilter)
    selectedqueries = zeros(nqueries, 1) ;
    for i=1:nqueries
        selectedqueries(i) = ~isempty(strfind(mvqueries{i}, queryfilter) ) ;
    end
    mvqueries = mvqueries(logical(selectedqueries) ) ;
    outpaths = outpaths(logical(selectedqueries) ) ;
    nqueries = size(mvqueries, 1) ;
end
if ~isempty(queryfilter2)
    selectedqueries = zeros(nqueries, 1) ;
    for i=1:nqueries
        selectedqueries(i) = ~isempty(strfind(mvqueries{i}, queryfilter2) ) ;
    end
    mvqueries = mvqueries(logical(selectedqueries) ) ;
    outpaths = outpaths(logical(selectedqueries) ) ;
    nqueries = size(mvqueries, 1) ;
end
if ~isempty(queryfilter3)
    selectedqueries = zeros(nqueries, 1) ;
    for i=1:nqueries
        selectedqueries(i) = ~isempty(strfind(mvqueries{i}, queryfilter3) ) ;
    end
    mvqueries = mvqueries(logical(selectedqueries) ) ;
    outpaths = outpaths(logical(selectedqueries) ) ;
    nqueries = size(mvqueries, 1) ;
end
nvars = size(varfield, 1) ;
nsets = nqueries*nvars ;
nbase = size(basefields, 1) ;
sampleset = cell(size(nsets, nvars) ) ;
samplelabel = cell(size(sampleset) ) ;
sampletimestamp = cell(size(sampleset) ) ;
for i = 1:nqueries
    thisdata = cell2mat(fetch(conn, mvqueries{i}) ) ; 
    thistimestamp = outpaths{i} ;
    for j = 1:nvars
        sampleset{i, j} = thisdata(:, [1:nbase nbase+j]) ;
        samplelabel{i, j} = varfield{j} ;
        sampletimestamp{i, j} = thistimestamp ;
    end
end
% reshape sample set, timestamps and outpaths
sampleset = sampleset(:) ;
samplelabel = samplelabel(:) ;
sampletimestamp = sampletimestamp(:) ;
% seperate out additional fields 
if ~isempty(addfields)
    % splitindex = 1st index of 1st addfield
    splitindex = (nsets/length(dbfields))*(nbase + nvars) + 1 ;
    % seperate additional data for each sampleset
    addset = sampleset(addfieldscutoff:end) ;
    sampleset(addfieldscutoff:end) = [] ;
    % seperate data labels
    addlabel = samplelabel(addfieldscutoff:end) ;
    samplelabel(addfieldscutoff:end) = [] ;
    % seperate timestamps
    addtimestamp = sampletimestamp(addfieldscutoff:end) ;
    sampletimestamp(addfieldscutoff:end) = [] ;
end
nsets = size(sampleset, 1) ;
% get rid of sample sets with only 1 data point
emptyelements = false(size(sampleset) )  ;
for i = 1:nsets
    if size(sampleset{i}, 1) < 2
        emptyelements(i, 1) = true ;
    end
end
sampleset(emptyelements) = [] ;
samplelabel(emptyelements) = [] ;
sampletimestamp(emptyelements) = [] ;
% drop corresponding additional data
if ~isempty(addfields)
    addset(emptyelements) = [] ;
    addlabel(emptyelements) = [] ;
    addtimestamp(emptyelements) = [] ;
end
plotwindow = 1:nsets ;
clearvars mvqueries outpaths thistimestamp splitindex emptyelements          

%% prep the file paths
fprintf('creating output directories...\n \n')
outfolder_fp = cell(size(nsets) ) ;
Rdataout_fp = outfolder_fp ;
for i=1:nsets
    % define folder paths
    %will look like <basepath>\<variable>\<timestamp>\
    outfolder_fp{i} = [inoutpath samplelabel{i} '\' sampletimestamp{i} '\'] ;
    % create output folders
    mkdir(outfolder_fp{i}) ;
    % define partial paths for files within outfolder
    % will look like <basepath>/<variable>/<timestamp>/<variable>_timestamp
	Rdataout_fp{i} = strrep([outfolder_fp{i} samplelabel{i} '_' sampletimestamp{i}], '\', '/') ;
end

%% prep the grid
fprintf('preparing base grid...\n \n')
% load the unsampled point grid (exported from ArcGIS) 
load(gridpath) ; % adds matrix basegrid to workspace
% calculate distance scaling factor to redefine location grid
%xyzmins = min(basegrid) ;
unsampled_locs = zeros(length(basegrid), nbase) ;
unsampled_locs(:, 1) = basegrid(:, 1) %- xyzmins(1) ;
unsampled_locs(:, 2) = basegrid(:, 2) %- xyzmins(2) ;
unsampled_locs(:, 3:end) = basegrid(:, 3:nbase) ; % elevation is not scaled
% save unsampled_locs to R file
Rgridpath = strrep([inoutpath 'krigegrid.Rdata'], '\', '/') ;
saveR(Rgridpath, 'unsampled_locs') ;

%% prep the sample data
fprintf('formatting data for R...\n \n')
treated_dat = cell(nsets, 1) ;
for i=1:nsets
    % get the sample data and correct coordinates to match base grid
    sample_dat = zeros(size(sampleset{i}) ) ;
	sample_dat(:, 1) = sampleset{i}(:, 1) - xyzmins(1) ;
	sample_dat(:, 2) = sampleset{i}(:, 2) - xyzmins(2) ;    
    for j = 3:length(dbfields)
     sample_dat(:, j) = clean_data(sampleset{i}(:, j), dbfields{j}) ;    
    end
    % remove NaNs
    badrows = any(isnan(sample_dat), 2) ;
    sample_dat(badrows, :) = [] ;
    treated_dat{i} = sample_dat ;
    % save the R input data
    varname = varfield{1} ;
    saveR([Rdataout_fp{i} '_rundata.Rdata'], 'Rgridpath', 'sample_dat', 'varname') ; 
    clearvars sample_dat badrows
end
fprintf('data preparation completed. \n') ;
fprintf('elapsed time: %10.2f \n \n', cputime - preptime) ;
diary off ;
clearvars varname

%% run through some fitting methods (optional)
diary on ;
fittime = cputime ;
fprintf('performing optional fits... \n \n') ;
fits = cell(nsets, 1) ;
%gofs = cell(nsets, 1) ;
for i =1:nsets
    % fit the data (predefined trends in fitdata)
    sample_dat = treated_dat{i} ;
    % hourly
    %[fitresult, sample_predictions, unsampled_predictions] = fit_data_mv(sample_dat(:, 3:end), basegrid(:, 3:end), dbfields(3:end) ) ;
    % monthly
    [fitresult, gof, sample_predictions, unsampled_predictions] = fit_data(sample_dat, basegrid, varfield{1}) ;
    fits{i} = fitresult ;
    gofs{i} = gof ;
    % save results to file
    save([Rdataout_fp{i} '_fitresults.mat'], 'fitresult', 'gof', ...
         'sample_predictions', 'unsampled_predictions', 'sample_dat') ;
    if strcmp(varfield{1}, 'temperature_avgmin')
        saveR([Rdataout_fp{i} '_mintempvals.Rdata'], 'sample_predictions', ...
              'unsampled_predictions') ;
    end
    clearvars fitresult gof sample_dat sample_predictions unsampled_predictions ;
end
% summarize the results
% monthly
fitcoeffs = NaN(nsets, numcoeffs(fits{1}) ) ;
% hourly
%fitcoeffs = NaN(nsets, fits{1}.NumCoefficients) ;
fitlowerconf= fitcoeffs ;
fitupperconf = fitcoeffs ;
for i = 1:nsets
    % pull the parameter values
    % monthly/daily
    fitcoeffs(i, :) = coeffvalues(fits{i}) ;
    intervals = confint(fits{i}) ; % [p1low p2low ; p1high p2high]    
    % hourly
    %fitcoeffs(i, :) = fits{i}.Coefficients.Estimate' ;
    %intervals = coefCI(fits{i})' ;
    fitlowerconf(i, :) = intervals(1, :) ;
    fitupperconf(i, :) = intervals(2, :) ;
    clearvars intervals ;
end
save([inoutpath varfield{1} '\robustfit_results.mat'], 'fitcoeffs', ...
     'fitlowerconf', 'fitupperconf', 'fits') ; %, 'gofs'
fprintf('fitting completed.\n')
fprintf('elapsed time: %10.2f \n \n', cputime - fittime) ;
diary off ;

%% plot seasonal trend
plotseason = true ;
if plotseason
    datelabels = {'J', 'F', 'M', 'A', 'M', 'J', ... 
                  'J', 'A', 'S', 'O', 'N', 'D'} ;
    fig = figure ;
    set(gcf, 'position', [10 10 800, 400], 'units', 'inches')
    if strcmp(varfield{1}(1:8), 'humidity')
        fcolor = {'9E9' 'FFF' 'FF'} ;
    elseif strcmp(varfield{1}(1:11), 'temperature')
        fcolor = {'FFB' '343' 'FF'} ;
    end
    bar(fitcoeffs(:, 1)./0.3048, 'FaceColor', rgbconv(fcolor) ) ;
    set(gcf,'color','w');
    set(gca, 'TickLength', [0 0], 'FontSize', 14, 'xlim', [0 13], 'XTickLabel', datelabels)
    ylabel('Strength of elevation gradient')
    export_fig([inoutpath varfield{1} '\' varfield{1} '_seasonal.eps'])
    close(fig)
end

%% plot the fits
plotfits = true ;
if plotfits
    for i=plotwindow
        minz = min(basegrid(:, 3) ) ;
        maxz = max(basegrid(:, 3) ) ;
        zspace = linspace(minz, maxz)' ;
        confintcolor = [0.9 0.9 0.9] ;
        sample_dat = treated_dat{i}(:, 3:end) ;
        sample_fit = fits{i} ;
        %sample_gof = gofs{i} ;
%        if strcmp(varfield{1}(1:11), 'temperature') && ...
%                  ~strcmp(varfield{1}(end-2:end), 'max')
%            orig = sample_dat(:, 2) ;
%            sample_dat(:, 2) = transform_temperature_data(sample_dat(:, 2) ) ;
%        end
        % monthly
        confspace = linspace(min(sample_dat(:, 1)), max(sample_dat(:, 1)) )' ;
        predvals = sample_fit(zspace) ;
        resid = sample_fit(sample_dat(:, 1)) - sample_dat(:, 2) ;
        confpred = predint(sample_fit, confspace ) ;
        % hourly
        %predvals = predict(sample_fit, zspace) ;
        %resid = sample_fit.Residuals.Studentized ;        
        %[~, confpred] = predict(sample_fit, confspace ) ;        
%         if strcmp(varfield{1}(1:11), 'temperature') && ...
%                   ~strcmp(varfield{1}(end-2:end), 'max')
%             sample_dat(:, 2) = transform_temperature_data(orig, sample_dat(:, 2) ) ;
%             confpred(:, 1) = transform_temperature_data(orig, confpred(:, 1) ) ;
%             confpred(:, 2) = transform_temperature_data(orig, confpred(:, 2) ) ;
%             predvals = transform_temperature_data(orig, predvals) ;
%         end
        fig = figure ;
        ciplot(confpred(:, 1), confpred(:, 2), confspace*0.3048, confintcolor) ;
        hold on ;
        plot(zspace*0.3048, predvals, 'k--', 'LineWidth', 2) ;
        plot(sample_dat(:, 1)*0.3048, sample_dat(:, 2), 'ko', 'MarkerSize', 5, ...
             'MarkerFaceColor', 'k') ;
        xlabel('Elevation (m)', 'fontsize', 18)
        if strcmp(varfield{1}(1:8), 'humidity')
            ylabel('Relative humidity (%)', 'fontsize', 18)
        elseif strcmp(varfield{1}(1:11), 'temperature')
            ylabel('Temperature (\circC)', 'fontsize', 18)
        end
        set(gca, 'TickLength', [0 0], 'FontSize', 14)
        set(gcf,'color','w');
        hold off ;
        export_fig([Rdataout_fp{i} ' confplot.eps'])
        close(fig)
        % normal probability plot of residuals
        fig = figure ;
        bins = floor(min(resid)):ceil(max(resid) ) ;
        if bins(1) > -3 && bins (end) < 3
            bins = -3:0.5:3 ;
        end
        [n, xout]=hist(resid,bins) ;
        bar(xout, n/trapz(xout,n), 'FaceColor', [0.9 0.9 0.9]) ;
        hold on ;
        mu = 0;
        sd = 1;
        ix = linspace((xout(1) - 1)*sd, (xout(end) + 1)*sd, 300) ; %covers more than 99% of the curve
        iy = pdf('normal', ix, mu, sd);
        set(gca, 'XLim', get(gca, 'Xlim') + [0.5 -0.5]) ;
        plot(ix, iy, 'Color', 'k', 'LineWidth', 2)
        set(gca, 'TickLength', [0 0], 'FontSize', 14)
        set(gcf,'color','w');
        export_fig([Rdataout_fp{i} ' normplot.eps'])
        close(fig)
        hold off ;
    end
end

%% krig everything (using R)
% define initial mins/maxes for future plotting
% columns of vals variables are [min avg max]
okpredvals = NaN(nsets, 3) ; 
kedpredvals = okpredvals ;
okvarvals = okpredvals ;
kedvarvals = okvarvals ;
okstdevvals = okpredvals ;
kedstdevvals = okstdevvals ;
% begin looping through sample data sets
for i = plotwindow
    % start generating the log file
    diary([Rdataout_fp{i} '_log.txt']) ;
    itertime = cputime ;
    fprintf('running %s %s\n \n', sampletimestamp{i}, samplelabel{i}) ;
    fprintf('Calling R...\n') ;
    
    %%%%%%%%%%%%%%%%%%%% CALL R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % e.g. C:\Rscript.exe C:/myscript.R "myfilepath"
    status = system([rpath ' ' krigescriptpath ' ' Rdataout_fp{i}]) ;        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf('\n R procedure completed. Resuming Matlab...\n') ;
    % load the results of the R script
    load([Rdataout_fp{i} '_krigeresults.mat']) ; % must match R script!
    % update mins, avgs and maxes
    okpredvals(i, :) = okpredrange ; 
    kedpredvals(i, :) = kedpredrange ;
    okvarvals(i, :) = okvarrange ; 
    kedvarvals(i, :) = kedvarrange ;
    okstdevvals(i, :) = okstdevrange ;
    kedstdevvals(i, :) = kedstdevrange ;    
    % pair predictions with original location data
    kedgrid = [basegrid kedpredictionval kedpredictionvar kedpredictionstdev] ;
    okgrid = [basegrid okpredictionval okpredictionvar okpredictionstdev] ;
    % save prediction data to a mat file for later use
    fprintf('Writing data to files... \n') ;
    save([Rdataout_fp{i} '_krigeresults.mat'], 'kedgrid', 'okgrid') ;
    % also write prediction values to csv file
    %colnames = {'projx', 'projy', 'z', 'prediction', 'variance', 'stdev'} ;
    %csvwrite_with_headers([dataout_fp '_predicted(OK).csv'], okgrid, colnames) ;
    %csvwrite_with_headers([dataout_fp '_predicted(KED).csv'], kedgrid, colnames) ;
    fprintf('%s %s Completed.\n', sampletimestamp{i}, samplelabel{i}) ;
    fprintf('Total elapse time: %10.2f \n \n', cputime - itertime) ;
    diary off ;
    % clean up for next iteration
    clearvars kedgrid okgrid kedpredictionval okpredictionval ...
              kedpredictionvar okpredictionvar ...
              kedpredictionsd okpredictionsd ...
              okpredrange okvarrange okstdevrange ... 
              kedpredrange kedvarrange kedstdevrange ;
end

% generate limits for color scale data
makemovie = false ;
comparekrige = false ;
diary([inoutpath 'log.txt']) ;
if makemovie % standardize limits throughout query range
    % ok
    okpredrange = NaN(nsets, 3) ;
    okvarrange = okpredrange ;
    okstdevrange = okpredrange ;
    okpredrange(:, 1) = min(okpredvals(:,1) ) ;
    okpredrange(:, 2) = mean(okpredvals(:,2) ) ;
    okpredrange(:, 3) = max(okpredvals(:,2) ) ;
    okvarrange(:, 1) = min(okvarvals(:,1) ) ;
    okvarrange(:, 2) = mean(okvarvals(:,2) ) ;
    okvarrange(:, 3) = max(okvarvals(:,2) ) ;
    okstdevrange(:, 1) = min(okstdevvals(:,1) ) ;
    okstdevrange(:, 2) = mean(okstdevvals(:,2) ) ;
    okstdevrange(:, 3) = max(okstdevvals(:,2) ) ;
    % ked
    kedpredrange = NaN(nsets, 3) ;
    kedvarrange = kedpredrange ;
    kedstdevrange = kedpredrange ;
    kedpredrange(:, 1) = min(kedpredvals(:,1) ) ;
    kedpredrange(:, 2) = mean(kedpredvals(:,2) ) ;
    kedpredrange(:, 3) = max(kedpredvals(:,2) ) ;
    kedvarrange(:, 1) = min(kedvarvals(:,1) ) ;
    kedvarrange(:, 2) = mean(kedvarvals(:,2) ) ;
    kedvarrange(:, 3) = max(kedvarvals(:,2) ) ;
    kedstdevrange(:, 1) = min(kedstdevvals(:,1) ) ;
    kedstdevrange(:, 2) = mean(kedstdevvals(:,2) ) ;
    kedstdevrange(:, 3) = max(kedstdevvals(:,2) ) ;
else % keep ked and ok limits for each query
    % this is a bit clunky, but it avoids modifying data from previous cell
    okpredrange = okpredvals ;
    okvarrange = okvarvals ;
    okstdevrange = okstdevvals ;
    kedpredrange = kedpredvals ;
    kedvarrange = kedvarvals ;
    kedstdevrange = kedstdevvals ;
end
if comparekrige % standardize ok and ked ranges for method comparison
    okpredrange(:, 1) = min(okpredvals(:,1), kedpredvals(:,1) ) ;
    okpredrange(:, 2) = mean(okpredvals(:,2), kedpredvals(:,2) ) ;
    okpredrange(:, 3) = max(okpredvals(:,2), kedpredvals(:,2) ) ;
    okvarrange(:, 1) = min(okvarvals(:,1), kedvarvals(:,1) ) ;
    okvarrange(:, 2) = mean(okvarvals(:,2), kedvarvals(:,2) ) ;
    okvarrange(:, 3) = max(okvarvals(:,2), kedvarvals(:,2) ) ;
    okstdevrange(:, 1) = min(okstdevvals(:,1), kedstdevvals(:,1) ) ;
    okstdevrange(:, 2) = mean(okstdevvals(:,2), kedstdevvals(:,2) ) ;
    okstdevrange(:, 3) = max(okstdevvals(:,2), kedstdevvals(:,2) ) ;
    kedprange = okpredrange ;
    kedvrange = okvarrange ;
    kedsdrange = okstdevrange ;
end
% generate the limits files
fprintf('saving data to R files for color scale generation... \n') ;
varname = varfield{1} ;
for i = 1:nsets
    limitsdatapath = strrep([Rdataout_fp{i} '_limits.Rdata'], '\', '/') ;
    okprange = okpredrange(i, :) ;
    okvrange = okvarrange(i, :) ;
    oksdrange = okstdevrange(i, :) ;
    kedprange = kedpredrange(i, :) ;
    kedvrange = kedvarrange(i, :) ;
    kedsdrange = kedstdevrange(i, :) ;    
    fprintf(['Saving ' limitsdatapath '\n']) ;
    saveR(limitsdatapath , 'okprange', 'okvrange', 'oksdrange', ...
          'kedprange', 'kedvrange', 'kedsdrange', 'varname') ; 
end
fprintf('limits data generated.\n')
diary off ; 
clearvars okprange okvrange oksdrange okpredrange okvarrange okstdevrange ...
          kedprange kedvrange kedsdrange kedpredrange kedvarrange kedstdevrange ...
          varname 

%% make an elevation plot of the results
makeelevplot = false ;
whichgrid = 'ked' ;
if makeelevplot
    for i = plotwindow
        load([Rdataout_fp{i} '_krigeresults.mat']) ;
        fig = figure ;
        if strcmp(whichgrid, 'ked')
            plot(kedgrid(1:end, 3)*0.3048, kedgrid(1:end, 4), 'k.', 'MarkerSize', 5, ...
                 'MarkerFaceColor', 'k') ;
        else
            plot(okgrid(:, 3)*0.3048, okgrid(:, 4), 'ko', 'MarkerSize', 5, ...
                 'MarkerFaceColor', 'k') ;
        end    
        set(gca, 'TickLength', [0 0], 'FontSize', 14)
        set(gcf,'color','w');
        xlabel('Elevation (m)', 'fontsize', 18)
        if strcmp(varfield{1}(1:8), 'humidity')
            ylabel('Relative humidity (%)', 'fontsize', 18)
        elseif strcmp(varfield{1}(1:11), 'temperature')
            ylabel('Temperature (\circC)', 'fontsize', 18)
        end
        export_fig([Rdataout_fp{i} ' elevplot.eps'])
        close(fig)
        clearvars kedgrid okgrid ;
    end
end


%% generate the color scales
% cstime = cputime ;
% diary([inoutpath 'log.txt']) ;
% fprintf('Generating color scales...\n \n') ;
% for i=1:nsets
%     fprintf('calling R...\n')
%     %%%%%%%%%%%%%%%%%%%% CALL R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     status = system([rpath ' ' colorscalescriptpath ' ' Rdataout_fp{i}]) ;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     fprintf('R procedure completed. Resuming Matlab... \n ') ;  
% end
% fprintf('colorscale data generated.\n')
% fprintf('total elapsed time: %10.2f \n \n', cputime - cstime) ;
% diary off ;

%% plot the data
plotraster = true ;
if plotraster
    plottime = cputime ;
    fprintf('preparing to plot data... \n')
    diary off ;
    for i=plotwindow
        diary([Rdataout_fp{i} '_log.txt']) ;
        fprintf('plotting %s %s\n \n', sampletimestamp{i}, samplelabel{i}) ;
        %%%%%%%%%%%%%%%%%%%% CALL R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        status = system([rpath ' ' plotscriptpath ' ' Rdataout_fp{i}]) ;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('%s %s plotted.\n \n', sampletimestamp{i}, samplelabel{i}) ;
        diary off ;
    end
    diary([inoutpath 'log.txt']) ;
    fprintf('all plots completed.\n') ;
    diary off ;
    clearvars okprange okvrange oksdrange kedprange kedvrange kedsdrange ...
              okpredrange okvarrange okstdevrange ...
              kedpredrange kedvarrange kedstdevrange ;
end
%% make a movie
if makemovie
    % define paths to frames
    kedimagepaths = cell(nsets, 1) ;
    okimagepaths = kedimagepaths ;
    imageformat = '.png' ;
    for i = 1:nsets
        kedimagepaths{i} = [Rdataout_fp{i} '_(KED)prediction' imageformat] ;
        okimagepaths{i} = [Rdataout_fp{i} '_(OK)prediction' imageformat] ;
    end
    diary([inoutpath 'log.txt']) ;
    fprintf('combining prediction images into movie... \n') ;
    images_to_movie(kedimagepaths, [inoutpath '(KED)prediction.avi'], imageformat) ;
    %images_to_movie(okimagepaths, [inoutpath '(OK)prediction.avi'], imageformat) ;
    fprintf('movies created successfully\n') ;
    fprintf('elapsed time: %10.2f.\n \n', cputime-plottime) ;
    fprintf('procedure completed successfully.\n')
    fprintf('total elapsed time: %10.2f \n \n', cputime - inittime) ;
    diary off ;
end

%% predict ep using hargreaves
plotET = false ;
minTpath = 'C:/Users/Michael/Desktop/KrigLayers/temperature_avgmin/2011-04/temperature_avgmin_2011-04' ;
maxTpath = 'C:/Users/Michael/Desktop/KrigLayers/temperature_avgmax/2011-04/temperature_avgmax_2011-04' ;
EPcomputescriptpath = strrep('C:\Users\Michael\Desktop\GITrepo\R\borr-kriging\compute_hargreavesET.R', '\', '/') ;
EPplotscriptpath = strrep('C:\Users\Michael\Desktop\GITrepo\R\borr-kriging\plot_hargreaves.R', '\', '/') ;
if (plotET)
    fprintf('Writing ETo maps...\n') ;
    status = system([rpath ' ' EPcomputescriptpath ' ' minTpath ' ' maxTpath]) ;
    status = system([rpath ' ' EPplotscriptpath ' ' maxTpath]) ;
    fprintf('ETo maps written.\n')
end
