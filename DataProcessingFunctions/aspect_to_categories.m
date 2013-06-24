function C = aspect_to_categories(M)
% converts aspect data in degrees to category
% assumes data has already been cleaned!

% M = vector of aspect data
% C = vector of slope facings

    % East: >= 45 and < 135
    % South: >= 135 and < 225
    % West: >= 225 and < 315
    % North: >= 315 and <= 360, or < 45
    % flat: < 0

    east = M >= 45 & M < 135 ; % 1
    south = M >= 135 & M < 225 ; % 2
    west = M >= 225 & M < 315 ; % 3
    north = M >= 315 & M <= 360 | M < 45 ; % 4
    flat  = M < 0 ; % 5

    C = NaN(size(M) ) ;
    C(east) = 1 ;
    C(south) = 2 ;    
    C(north) = 3 ;
    C(west) = 4 ;
    C(flat) = 5 ;
end