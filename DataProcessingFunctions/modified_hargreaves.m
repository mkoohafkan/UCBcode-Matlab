function EP = modified_hargreaves(minpath, maxpath, krigetype)
% implements the hargreaves equation
% krigetype = 'ok' or 'ked'    
% a + (b/lambda)*(  )
    
a = 0 ; % calibration coefficient, default = 0
b = 1 ; % calibration coefficient, default = 0
Ra = 0 ; % extraterrestrial solar radiation

% get Tmin
load([minpath '_krigeresults.mat']) ;
basegrid = kedgrid(:, 1:3) ; % doesn't matter which you pick
if strcmp(krigetype, 'ok')
    Tmin = kedgrid(:, 4) ;
elseif strcmp(krigetype, 'ked')
    Tmin = okgrid(:, 4) ;
end
clearvars kedgrid okgrid ;
% get Tmax
load([maxpath '_krigeresults.mat']) ;
if strcmp(krigetype, 'ok')
    Tmax = kedgrid(:, 4) ;
elseif strcmp(krigetype, 'ked')
    Tmax = okgrid(:, 4) ;
end
clearvars kedgrid okgrid ;
end