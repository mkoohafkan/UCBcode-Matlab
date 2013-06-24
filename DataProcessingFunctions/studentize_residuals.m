function sr = studentize_residuals(r, m)
% studentizes residuals
% r = vector of residuals
% m = number of parameters in model

% sr = vector of studentized residuals
n = length(r) ;
X = [ones(n, 1) r] ;
H = diag((X/(X'*X))*X') ;
sigmasq = NaN(n, 1) ;
sr = NaN(n, 1) ;
for i = 1:n
    sumres = 0 ;
    for j = 1:n
        if i ~= j
            sumres = sumres + r(j)^2 ;
        end
    end
    sigmasq(i) = sumres/(n - m - 1) ;
    sr(i) = r(i)/(sqrt(sigmasq(i))*sqrt(1 - H(i) ) ) ;
end
end