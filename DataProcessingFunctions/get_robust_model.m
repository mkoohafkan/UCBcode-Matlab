function [fitresult, gof] = get_robust_model(ft, xData, yData)
% fit a 1-variable nonlinear model to the dataset
%
% ft = fittype, e.g. ft = fittype('rat11') or fittype('m*x + b')
% ds = dataset
% pfield = selected predictor (independent variable)
% rfield = selected response (dependent) variable
%
% fitresult : a fit object representing the fit.
% gof : structure with goodness-of fit info.

% Set up fittype and options.
opts = fitoptions(ft);
switch class(opts)
    case 'curvefit.nlsqoptions'
        opts.Algorithm = 'Levenberg-Marquardt';
        opts.Display = 'Off';
        opts.Lower = [-Inf -Inf -Inf];
        opts.MaxFunEvals = 6000;
        opts.MaxIter = 4000;
        opts.Robust = 'Bisquare';
        opts.StartPoint = [0.319552490429984 0.654040120941537 0.161972859920309];
        opts.Upper = [Inf Inf Inf];
    case 'curvefit.llsqoptions'
        opts.Robust = 'on' ;
end
% Fit model to data.
[fitresult, gof] = fit(xData, yData, ft, opts);
end