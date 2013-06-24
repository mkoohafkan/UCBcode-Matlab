function plotfitstats(outPath, xLabel, yLabel, x, y, fitCoeffs, ...
                      fitStats, regFitCoeffs, regFitStats, nodes)
%develop plots of data for visual analysis
%plot the actual data and the fitted trend
h{1, 1}= subplot(3, 2, 1) ;
yFit = fitCoeffs(1) + fitCoeffs(2)*x ;
regYFit = regFitCoeffs(1) + regFitCoeffs(2)*x ;
h{1, 2} = plot(x, y, 'b.',  ...
               x, yFit, 'r-', ...
               x, regYFit, 'g-') ;
ylabel(yLabel, 'interpreter', 'none') ;
xlabel(xLabel, 'interpreter', 'none') ;
title(sprintf('%s vs. %s', yLabel, xLabel), 'interpreter', 'none' )
%plot the residuals against x data
h{3, 1}= subplot(3, 2, 3) ;
h{3, 2} = plot(x, fitStats.rstud, 'r.') ;
%plot guidelines to easily identify outliers
hold on ;
plot(get(gca,'xlim'), [1 1], 'k:', ...
     get(gca,'xlim'), [-1 -1], 'k:', ...
     get(gca,'xlim'), [2 2], 'k--', ...
     get(gca,'xlim'), [-2 -2], 'k--');
% label outliers with node id 
[outliers, olabels] = getoutliers(nodes, x, fitStats.rstud, 2) ;
text(outliers(:,1), outliers(:,2), olabels ) ;
hold off ;
clearvars outliers ;
title(sprintf('studentized residual vs. %s', xLabel), 'interpreter', 'none' )
ylabel('studentized residual', 'interpreter', 'none') ;
xlabel(xLabel, 'interpreter', 'none') ;
%plot the residuals against y data
h{5, 1} = subplot(3, 2, 5) ;
h{5, 2} = plot(y, fitStats.rstud, 'r.') ;
%plot guidelines to easily identify outliers
hold on ;
plot(get(gca,'xlim'), [1 1], 'k:', ...
     get(gca,'xlim'), [-1 -1], 'k:', ...
     get(gca,'xlim'), [2 2], 'k--', ...
     get(gca,'xlim'), [-2 -2], 'k--');
% label outliers with node id
outliers = getoutliers(nodes, y, fitStats.rstud, 2) ;
text(outliers(:,1), outliers(:,2), olabels )  ;
hold off ;
title(sprintf('studentized residual vs. %s', yLabel), ...
      'interpreter', 'none' )
ylabel('studentized residual', 'interpreter', 'none') ;
xlabel(yLabel, 'interpreter', 'none') ;
%plot the y data vs the y predictions
h{4, 1} = subplot(3, 2, 4) ;
h{4, 2} = plot(y, yFit, 'g.', ...
               y, y, 'k:') ;
ylabel(sprintf('predicted %s', yLabel), 'interpreter', 'none') ;
xlabel(sprintf('observed %s', yLabel), 'interpreter', 'none') ;
title(sprintf('predicted vs. observed %s', yLabel), 'interpreter', 'none') ;
%plot the normal plot of the studentized residuals
h{6, 1} = subplot(3, 2, 6) ;
h{6, 2} = normplot(fitStats.rstud) ;
grid off ;
%display fit information
[correlation, significance] = robustfitsignificance(x, fitCoeffs, fitStats) ;
h{2, 1} = subplot(3, 2, 2) ;
set(h{2,1}, 'XTickLabel', '', 'YTickLabel', '', ...
    'XTick', [], 'YTick', [], ...
    'XColor', get(gca, 'Color'), 'YColor', get(gca, 'Color') ) ;
%robust fit
text(.05, .9, 'Robust Fit')
text(.05, .75, sprintf('Slope : %f', fitCoeffs(2)) ) ;
text(.05, .6, sprintf('Intercept : %f', fitCoeffs(1)) ) ;
text(.05, .45, sprintf('Coefficient of correlation : %f', ...
                     correlation) ) ;
text(.05, .3, sprintf('Significance of fit : %f', ...
                     significance) ) ;
%regular fit                     
text(.55, .9, 'Regular Fit')
text(.55, .75, sprintf('Slope : %f', regFitCoeffs(2)) ) ;
text(.55, .6, sprintf('Intercept : %f', regFitCoeffs(1)) ) ;
text(.55, .45, sprintf('Coefficient of correlation : %f', ...
                     sqrt(regFitStats(1)) ) ) ;
text(.55, .3, sprintf('Significance of fit : %f', ...
                     regFitStats(1) ) ) ;
                 title('fit statistics', 'interpreter', 'none') ;
hgsave(outPath) ;
clf ;
clearvars h outliers yFit correlation significance ;

    function [points, labels] = getoutliers(nodeids, xs, rs, tolerance)
        vi = find(ge(abs(rs), tolerance)) ;
        points = [xs(vi) rs(vi)] ;
        selectedNodes = nodeids(vi) ;
        labels = cell(size(selectedNodes)) ;
        for i = 1:size(selectedNodes, 1)
            labels{i} = sprintf('  %i', selectedNodes(i) ) ;
        end
        clearvars vi ;
    end

    function [r, r2] = robustfitsignificance(xs, params, theStats)
        sse = theStats.dfe * theStats.robust_s^2 ;
        phat = params(1) + params(2)*xs ;
        ssr = norm(phat - mean(phat))^2 ;
        r = 1 - sse/(sse + ssr) ;
        r2 = r^2 ;
    end
end