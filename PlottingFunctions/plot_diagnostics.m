function h = plot_diagnostics(estimates, outpath)
% designed for plotting output from multivariate_diagnostics
% estimates = parameter value estimates as output by plot_diagnostics
% diagnostics = parameter fit diagnostics as output by plot_diagnostics
% outpath = the path to save the fig files to
%
% pull data for plots, converting to numeric arrays as needed
tags = estimates(2:end-2, 1) ;
num_tags = size(tags, 1) ;
parameter_names = estimates(1, 2:end-4) ;
parameter_values = cell2mat(estimates(2:end-2, 2:end-4) ) ;
num_parameters = size(parameter_names, 2) ;
parameter_means = cell2mat(estimates(end-1, 2:end-4) ) ;
parameter_stdevs = cell2mat(estimates(end, 2:end-4) ) ;
% initialize plot cell array
for j = 1:num_parameters
    % get data for current parameter
    this_param = parameter_names{1, j} ;
    this_param_values = parameter_values(:, j) ;
    this_mean = parameter_means(1, j) ;
    this_stdev = parameter_stdevs(1, j) ;
    % plot stuff
    h = plot(1:num_tags,  this_param_values, 'bx--', ...
             [1 num_tags], [this_mean this_mean], 'g-', ...
             [1 num_tags], [this_mean+this_stdev this_mean+this_stdev], 'r:', ...
             [1 num_tags], [this_mean-this_stdev this_mean-this_stdev], 'r:' ) ;
    % modify axes and add title, etc
    legend('Estimate', 'arithmetic mean', 'standard deviation') ;
    ylabel('Estimated value') ;
    xlabel('identifier') ;
    title(this_param) ;
    set(gca, 'XTick', 1:num_tags) ;
    set(gca, 'XTickLabel', tags) ;
    if ~isempty(outpath)
        hgsave([outpath regexprep(this_param, '\W', '-')] ) ;        
        clf ;
    end
end
end
