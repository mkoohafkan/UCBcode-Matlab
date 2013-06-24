function res = plotyears(dataset, idx)
    uniqueyears = unique(dataset(:,1) ) ;
    cols = distinguishable_colors(length(uniqueyears) ) ;
    for i = 1:length(uniqueyears)
        fig(i) = figure;
        thisyear = dataset(dataset(:,1) == uniqueyears(i), :);
        plot(thisyear(:, idx), 'color', cols(i, :) ) ;
        title(uniqueyears(i))
    end
    
end