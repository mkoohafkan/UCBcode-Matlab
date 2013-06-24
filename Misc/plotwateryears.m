function plotwateryears(dataset, idx)
% dataset = matrix of at least 4 columns. 
%   first three columns are year month day
%   additional columns could be flow, precip, etc.
% idx specifies which column to plot on y axis
% right now, any data before september of first year is ignored!
    uniqueyears = unique(dataset(:,1) ) ;
    cols = distinguishable_colors(length(uniqueyears) ) ;
    for i = 1:length(uniqueyears)
        figure;
        wyfilter = (dataset(:,1) == uniqueyears(i) & dataset(:,2) > 9) | ...
                   (dataset(:,1) == uniqueyears(i) + 1 & dataset(:,2) < 10) ;
        thisyear = dataset(wyfilter, :) ;
        plot(thisyear(:, idx), 'color', cols(i, :) ) ;
        title(uniqueyears(i))
    end
    
end