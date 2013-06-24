function [horz, vert, skew] = check_skew(ys)
    sortedys = sort(ys) ;
    if mod(length(ys), 2) == 0
        ind = length(ys)/2 + 1 ;
    else
        ind = ceil(length(ys)/2) ;
    end
    med = median(sortedys) ;
    horz = NaN(floor(length(ys)/2), 1) ;
    vert = horz ;
    for i = 1:ind-1
        horz(i) = med - sortedys(i) ;
        vert(i) = sortedys(end+1-i) - med ;
    end
    above = sum((vert - horz) > 0.2) ;
    below = sum((vert - horz) < -0.2) ;
    if abs(above - below)/length(ys) < 0.3
        skew = 'symmetrical' ;
    elseif (above - below)/length(ys) > 0.3
        skew = 'right' ;
    else
        skew = 'left' ;        
    end
    lin = [0.5*min(min(horz, vert)) 2*max(max(horz, vert))] ;
    plot(horz, vert, 'ko', lin, lin, 'k-') ;
end