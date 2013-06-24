function C = correct_slopeaspect(M)
% correct aspect data based on slope
% M = [slope aspect]
% C = corrected [slope aspect]

threshold = @(x) lt(x, 5) ; % define slope < 5 has no aspect
C = M ;

% identify slopes that are probably artifacts (< 5)
a = arrayfun(threshold, M(:, 1) ) ;
C(a, 1) = 0 ; 
%change aspect to 'east-facing' for slopes that are flat
C(a, 2) = 90 ;

end