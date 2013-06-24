function kriging_comparison_plot(m)
% expects n number of kriging prediction matrices
% matrix = [x y z prediction kriging_standard_error]

pmin = realmax ;
vmin = pmin ;
pmax = realmin ;
vmax = pmax ;
pcols = logical([1 1 0 1 0]) ;
vcols = logical([1 1 0 0 1]) ;
for i=1:length(m)
    pmin = min(pmin, min(m{i}(:, 4) ) ) ;
    vmin = min(vmin, min(m{i}(:, 5) ) ) ;  
    pmax = max(pmax, max(m{i}(:, 4) ) ) ;
    vmax = max(vmax, max(m{i}(:, 5) ) ) ;  
end
% pmin = floor(pmin) ;
% vmin = floor(vmin) ;
% pmax = ceil(pmax) ;
% vmax = ceil(vmax) ;
for i =1:nargin
    % plot predicted values
    subplot(1, 2, 1)
    pcolor(m{i}(:, pcols) );
	% plot error
    subplot(1, 2, 2)
    pcolor(m{i}(:, vcols) );
end
end