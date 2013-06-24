function inverseData = hydrusformatter(infile, outfile, numregions)
lencolumn = 90 ;
lenregion = 90/numregions ;
    % import forward model output
    fid = fopen(infile) ;
    allData = textscan(fid, '%s', 'Delimiter', '\n') ;
    allData = allData{1} ;
    fclose(fid) ;
    % format data
    wcCells = find(~cellfun(@isempty,strfind(allData, 'W-volume'))) ;
    tCells = find(~cellfun(@isempty,strfind(allData, 'Time'))) ;
    tmpwc = allData(wcCells) ;
    tmpt = allData(tCells(2:end)) ;
    wcs = zeros(length(tmpwc), numregions) ; 
    times = zeros(length(tmpt), 1) ;
    twc = zeros(length(tmpt), 1) ;
    for i = 1:length(wcCells)
        % get times
        timeLine = splitstring(tmpt{i}) ;
        times(i) = str2double(timeLine{end}) ;
        thisLine = splitstring(tmpwc{i}) ;
        % get total water content
        twc(i) = str2double(thisLine{3})./lencolumn ;
        % get sub-region water content
        for j = 4:size(thisLine, 2)
            wcs(i, j-3) = str2double(thisLine{j})./lenregion ;
        end
    end
    % generate total wc data
    totalwc = [times(:) twc(:)] ;
    xlswrite([outfile '_total'], totalwc);
    % generate input data for inverse model
    % format is [time wc 2 layernumber weight]
    % type 2 = water content at obs point
    inverseData = zeros(numregions*length(times), 5) ;
    inverseData(:, 1) = repmat(times, numregions, 1) ;
    inverseData(:, 2) = wcs(:) ; % wc measurements
    inverseData(:, 3) = 2 ; % specifies type as wc measurement
    % generate region labels
    rl = ones(length(wcs), 1) ;
    for i = 2:numregions
        rl = vertcat(rl, i*ones(length(wcs), 1)) ;
    end
    inverseData(:, 4) = rl ;
    inverseData(:, 5) = 1 ; % specifies observation weight
    xlswrite(outfile, inverseData) ;
end