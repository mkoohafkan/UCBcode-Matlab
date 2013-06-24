function C = correct_wind(M)
% removes wind direction data if speed is below threshold
% M = [windspeed winddir]
% C = corrected [windspeed winddir]

threshold = @(x) lt(x, 0) ; %identify windspeed < 0 as having no direction
C = M ;

% identify windspeeds below threshold
a = arrayfun(threshold, M(:, 1) ) ;
% remove direction data for windspeeds below threshold
C(a, 2) = NaN ;

end
