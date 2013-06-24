function [h, mdl] =  multivariate_plot(predictors, observations, mtype, varargin)
% develops plots detailing multivariate regression results
% accepts a matrix of predictors corresponding to a vector of observations
%   predictors = n x m matrix
%   observations = n x 1 vector
%   mtype = the model type. See LinearModel.fit for specifications
% accepts the following optional key-value pair arguments
%    outpath = the location to save the figure. can be relative or absolute
%    ptitle = the figure title
%    pfields = the names of each column in predictors
%    ofield = the name of the observation variable
%    uidlist = the unique ids of the observation locations (rows)
%    lstyle = overrides the default matlab plot line or marker style
P = predictors ;
n = observations ;
pcriterion = 'sse' ;
%defaults
outpath = '' ;
ptitle = [sprintf('multivariate regression of %i ', size(n, 1) ) ...
          sprintf('observations based on %i predictors', size(P, 2) ) ] ;
pfields = cell(size(P, 2), 1) ;
for i = 1:size(pfields)
    pfields{i} = sprintf('x%i', i) ;
end
ofield = 'y' ;
pcol = 1 ; %predictor column used for plotting
uidlist = cell(0) ;
%get values of optional arguments
if nargin > 3
    for i = 1:2:size(varargin, 2)
        switch varargin{1, i}
            case 'pcol'
                pcol = varargin{1, i+1} ;
            case 'predictorfields'
                pfields = varargin{1, i+1};
            case 'observationfield'
                ofield = varargin{1, i+1} ;
            case 'predictorcriterion'
                pcriterion = varargin{1, i+1} ;
            case 'labtitle'
                ptitle = varargin{1, i+1} ;
            case 'uidlist'
                uidlist = varargin{1, i+1} ;
            case 'outpath'
                outpath = varargin{1, i+1} ;
            otherwise
                error(fprintf('input argument %i not recognized.', i) ) ;
        end
    end
end
%prep the plots
stitle{4} = '' ; % normal probability plot already has title by default
stitle{1} = 'regression fit' ;
stitle{3} = 'residuals' ;
stitle{2} = 'fit statistics' ;
h = figure ;
suptitle({ptitle ; ''}) ;
%prepare fit plot
subplot(2, 2, 1) ;
title(stitle{1} ) ; 
ylabel(ofield, 'interpreter', 'none') ;
%prepare fit statistics box
subplot(2, 2, 2) ;
title(stitle{2} ) ;
%prepare residuals plot
subplot(2, 2, 3) ;
title(stitle{3} ) ;
xlabel(pfields{pcol}, 'interpreter', 'none') ;
%prepare normal plot
subplot(2, 2, 4) ;
%do stepwise regression 
mdl = LinearModel.stepwise(P, n, mtype, 'PredictorVars', pfields, ...
                           'ResponseVar', ofield, 'Criterion', pcriterion) ;
%get predicted values, residuals and outliers
npred = predict(mdl, P) ;
studres = mdl.Residuals.Studentized ;
% plot the data and fit
subplot(2, 2, 1) ;
hold on ;
plot(P(:, pcol), n, 'o', P(:, pcol), npred, 'x:') ;
[outliers, labels] = get_outliers(uidlist, [P(:, pcol) n], studres, 2) ;
text(outliers(:, 1), outliers(:, 2), labels) ;
hold off ;
%plot the residuals and outlier labels
subplot(2, 2, 3) ;
hold on ;
my_residual_plot(P(:, pcol), studres) ;
[outliers, labels] = get_outliers(uidlist, [P(:, pcol) studres], studres, 2) ;
text(outliers(:, 1), outliers(:, 2), labels) ;
hold off ;
% normal plot
subplot(2, 2, 4) ;
hold on;
normplot([mdl.Residuals.Raw n]) ;
legend({'raw residuals'; 'observations'}, 'Location', 'SouthEast')
%plotResiduals(mdl, 'probability') ;
hold off;
subplot(2, 2, 2) ;
hold on ;
%print the theoretical equation
text(.05, .9, [mdl.Formula.ResponseName ' = ' mdl.Formula.LinearPredictor], ...
     'interpreter', 'none' ) ;
%print the parameter values
rsq = cell(2, 1) ;
rsqvals = struct2cell(mdl.Rsquared) ;
rsq{1, 1} = sprintf('R^2 = %f', rsqvals{1, 1} ) ;
rsq{2, 1} = sprintf('Adjusted R^2 = %f', rsqvals{2, 1} ) ;
params = dataset2cell(mdl.Coefficients(:, 1) ) ;
params = params(2:end, :) ;
displayparams = cell(size(params, 1), 1) ;
for i = 1:size(displayparams, 1)
    displayparams{i} = sprintf('%s = %f', params{i, 1}, params{i, 2} ) ;
end
text(.05, .75, join(', ', displayparams), 'interpreter', 'none') ;
text(.05, .6, join(', ', rsq) ) ;
hold off ;
%save the plot
if ~isempty(outpath) ;
    hgsave(outpath) ;
    saveas(h, [outpath '.png'])
end
close(h) ;
end