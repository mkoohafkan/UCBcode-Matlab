function status = grid_to_matfile(inpath, outpath)
% this function is custom designed for the output of my GIS grid process
% expects a multicolumn (> 3) file, but only 4 of the columns matter
% ASSUMES THAT:
% the last column is y coordinates
% second-to-last column is x coordinates
% third-to-last column is aspect
% fourth-to-last column is elevation
% other columns are garbage data
    raw = importdata(inpath, ',', 1) ;
    basegrid = zeros(size(raw.data, 1), 3) ;
    basegrid(:, 1) = raw.data(:, end-1) ; % projx
    basegrid(:, 2) = raw.data(:, end) ; % projy
    %basegrid(:, 4) = raw.data(:, end-2) ; % aspect
    basegrid(:, 3) = raw.data(:, end-2) ; %elevation    
    try
        save(outpath, 'basegrid') ;
        status = 0 ;
    catch
        status = -1 ;
    end
end