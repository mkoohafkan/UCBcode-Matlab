function [p, l] = get_outliers(uids, xy, rs, tolerance)
% MUST BE GIVEN COLUMN VECTORS
% identifies points whose r value exceeds the specified tolerance.
% returns a matrix of points p and a cell array of labels l for plotting.
% uid is an integer that uniquely identifies the point

vi = find(ge(abs(rs), tolerance)) ;
p = xy(vi, :) ;
sid = uids(vi) ;
l = cell(size(sid)) ;
for i = 1:size(sid, 1)
    l{i, 1} = sprintf('  %i', sid(i, 1) ) ;
end
end