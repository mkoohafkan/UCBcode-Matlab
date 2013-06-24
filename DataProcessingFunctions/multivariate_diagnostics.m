function [fit_values, fit_diagnostics, frequency_diagnostics] = multivariate_diagnostics(mdls, cmpmdls, labels)
% get R-squared differences for mdls. Deal with differing parameters by
% checking all of them. For each parameter, show 
% Adj R^2 (best fit): adj R^2 if parameter were removed, R_with - R_without
% positive difference = parameter improves fit
% negative difference = parameter makes fit worse
% 
% mdls = cell array of linear model objects
% cmpmdls = cell array of linear model objects for use as a 'baseline' comparison
%           e.g. compare mdls to models that only use 'z' as a predictor
% labels = identifiers for linear model objects
%
% fit_values = table (below) with parameter estimates
% fit_diagnostics = table (below, last two rows omitted) with paramter
%                   differential adjusted R^2 values
%
% Table/Cell Array structure:
%
% --------------------------------------------------------------
% | tag |      parameter 1        |...| model form | model R^2 |
% |(str)|(dbl)value or R^2 effect |   |    (str)   |   (dbl)   |
% | ... |                         |   |            |           |
% | mean|           (dbl)         |...|   null     |   null    |
% | std |           (dbl)         |...|   null     |   null    |
% --------------------------------------------------------------
%
% get list of parameters
paramlist = unique(flatten(cellfun(@(x) x.CoefficientNames, mdls, ...
                                   'UniformOutput', false) ) ) ;
colnames = cat(2, 'tag', paramlist, 'model Adj Rsquared', 'comparison model Adj Rsquared', 'model form', 'comparison model form') ;
% initialize table
fit_diagnostics = cell(size(mdls, 1) + 1, size(colnames, 2) ) ;              
% first row is column names
fit_diagnostics(1, :) = colnames ;
fit_diagnostics(2:end, 1) = labels ;
fit_diagnostics(2:end, end-1) = cellfun(@(x) [x.Formula.ResponseName ' = ' ... 
                                              x.Formula.LinearPredictor], ...
                                        mdls, 'UniformOutput', false) ;                                    
fit_diagnostics(2:end, end) = cellfun(@(x) [x.Formula.ResponseName ' = ' ... 
                                              x.Formula.LinearPredictor], ...
                                        cmpmdls, 'UniformOutput', false) ;                                    
fit_diagnostics(2:end, end-3) = num2cell(cellfun(@(x) x.Rsquared.Adjusted, mdls) ) ;
fit_diagnostics(2:end, end-2) = num2cell(cellfun(@(x) x.Rsquared.Adjusted, cmpmdls) ) ;
%get frequency of each predicted model form
[modellist, ~, idx] = unique(fit_diagnostics(2:end, end-1) ) ;
modelcount = accumarray(idx(:),1,[],@sum) ;                              
frequency_diagnostics = cell(size(modellist, 1)+1, 2) ;
frequency_diagnostics{1, 2} = 'model form' ;
frequency_diagnostics{1, 1} = 'model count' ;
frequency_diagnostics(2:end, 2) = modellist ;
frequency_diagnostics(2:end, 1) = num2cell(modelcount) ;
%get parameter values
fit_values = cell(size(fit_diagnostics, 1)+2, size(fit_diagnostics, 2) ) ;
fit_values(1:end-2, :) = fit_diagnostics ;
fit_values{end, 1} = 'stdev' ;
fit_values{end-1, 1} = 'arith. mean' ;
for i=1:size(paramlist, 2) ;
    param_name = paramlist{i} ;
    [paramvals rstats] = cellfun(@R_squared_diff, mdls) ;
    fit_diagnostics(2:end, i+1) = num2cell(rstats) ;
    fit_values(2:end-2, i+1) = num2cell(paramvals) ;
end
fit_values(end-1, 2:end-4) = num2cell(mean(cell2mat(fit_values(2:end-2, 2:end-4)), 1) ) ;
fit_values(end, 2:end-4) = num2cell(std(cell2mat(fit_values(2:end-2, 2:end-4)), 1) ) ;

    function [est_val R_diff] = R_squared_diff(thismodel)
        % positive rdiff means the predictor improves the fit
        % negative rdiff means the predictor worsens the fit
        % within 0.05*thismodel.Rsquared.Adjusted means the predictor makes
        % no difference
        if strcmp(param_name, '(Intercept)')
            est_val = thismodel.Coefficients.Estimate(1) ;
            R_with = NaN ;
            R_without = NaN ;
        elseif ismember(param_name, thismodel.CoefficientNames)
            % parameter was included
            % determine value of parameter
            parammask = cellfun(@(x) strcmp(param_name, x), ...
                                thismodel.CoefficientNames) ;
            est_val = thismodel.Coefficients.Estimate(parammask) ;
            % compute the R stats
            R_with = thismodel.Rsquared.Adjusted ;
            nextmodel = removeTerms(thismodel, param_name) ;
            R_without = nextmodel.Rsquared.Adjusted ;
        else
            % parameter was removed, value == 0
            est_val = 0 ;
            % compute the R stats
            R_without = thismodel.Rsquared.Adjusted ;
            nextmodel = addTerms(thismodel, param_name) ;
            R_with= nextmodel.Rsquared.Adjusted ;
        end
        R_diff = R_with - R_without ;
    end
                       
end