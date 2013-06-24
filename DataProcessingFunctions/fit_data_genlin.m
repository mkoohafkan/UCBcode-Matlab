function [fitresult, gof, trend_fit, trended_locs] = fit_data(sample_data, new_locations, varname)
% fits a function to data based on predefined trend
% sample_data = data used to fit function, expects [x y z ... var]
% new_locations = data points to predict based on fit
% varname = field name that defines trend to use
switch varname
    case {'temperature_avgmin'}
        % rational function of elevation only
        ft = fittype('poly1') ;
        pcols = 3 ;
        [xData, yData] = prepareCurveData(sample_data(:, pcols), ...
                         transform_temperature_data(sample_data(:, end)) );
        [fitresult, gof] = get_robust_model(ft, xData, yData) ;
    case {'temperature_avg', 'humidity_avgmin', 'humidity_avg', 'humidity_avgmax', 'temperature_avgmax'}
        % linear function of elevation only
        ft = fittype('poly1') ;
        pcols = 3 ;
        [xData, yData] = prepareCurveData(sample_data(:, pcols), sample_data(:, end) ) ;        
        [fitresult, gof] = get_robust_model(ft, xData, yData) ;
end
% predict at sample locations and unsampled locations
switch varname
    case {'temperature_avgmin'}
        trend_fit = transform_temperature_data(sample_data(:, end), ...
                                               fitresult(xData) ) ;
        trended_locs = transform_temperature_data(sample_data(:, end), ...
                                     fitresult(new_locations(:, pcols)) ) ;
    otherwise
        trend_fit = fitresult(xData) ;
        trended_locs = fitresult(new_locations(:, pcols) ) ;
end
end