function multimonthplot(xycells, tags, n, indvar, depvar)
% develops a series of plots showing n consecutive months
% xy = the data to be plotted, in the form {[xs1 ys1] ; [xs2 ys2] ; etc.}
% tags = the labels for each dataset (cell) in xycells
% n = the number of consecutive months to be plotted at a time
c = distinguishable_colors(n) ;
for i = n:size(xycells, 1)
    clf ;
    hold on ;
    ci = 0 ;
    for j = i:-1:i-n+1
        ci = ci + 1 ;
        plot(xycells{i-j+1}(:, 1), xycells{i-j+1}(:, 2), '.', 'color', c(ci, :) ) ;
    end
    title([tags{i-n+1} '--' tags{i}]) ;
    xlabel(indvar) ;
    ylabel(depvar) ;
    hold off ;
end