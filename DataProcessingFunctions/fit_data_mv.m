function [fitresult, trend_fit, trended_locs] = fit_data_mv(sample_data, new_locations, fields)
% assumes that data has already been cleaned (including conversion to
% categorical)
% sample_data = numeric array of predictors and observations
%               last column is observation!
% new locations = the grid (must include all predictors)
% fields = the labels of the columns in sample_data

% identify categorical fields
P = sample_data(:, 1:end-1) ;
R = sample_data(:, end) ;
catfields = zeros(length(fields) - 1, 1) ; % last field is the response variable
for i = 1:length(catfields)
    switch fields{i}
        case {'aspect', 'wind_dir'}
            catfields(i) = 1 ;
    end
end
fitresult = LinearModel.fit(P, R, 'linear', 'CategoricalVars', logical(catfields), ...
                      'VarNames', fields', 'RobustOpts', 'on') ;
trend_fit = predict(fitresult, P) ;
trended_locs = predict(fitresult, new_locations) ;
end