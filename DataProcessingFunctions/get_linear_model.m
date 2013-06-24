function mdl = get_linear_model(ds, pfields, rfield)
% given a query and a database connection object, produce a fit for the
% data

% query = an SQL query string
% conn = database connection object

mdl = LinearModel.fit(ds, 'PredictorVars', pfields, ...
                          'ResponseVar', rfield, ...
                          'RobustOpts', 'on') ;
end