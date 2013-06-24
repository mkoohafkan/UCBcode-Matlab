function cleaned_data = clean_data(measurements, otype)
%cleans up raw data based on predefined 'flags' defined in the subfunctions
%  measurements = an nx1 vector of measurements or observations
%                 or the nx2 array [winddir windspeed] 
%  otype = a database field such as 'canopyheight' or 'aspect'
%  unrecognized values of type are ignored, data won't be processed
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%threshold values
canopyheight_threshold = @(x) lt(x, 0) ; %flag negative values
aspect_threshold = @(x) lt(x, -1) ; %flag values less than -1 (-1 = flat)
slope_threshold = @(x) le(x, 0) ;  %flag 0 slope values
dist2pond_threshold = @(x) lt(x, 0) ; %flag negative values 
dist2creek_threshold = @(x) lt(x, 0) ; %flag negative values 
aspect_reliability_threshold = @(x) lt(x, 5) ; %identify slope < 5 as having no aspect
bpressure_threshold = @(x) lt(x, 0) ; %remove negative values
z_threshold = @(x) lt(x, 0) ; %remove negative values
z_conv = @(x) 0.3048.*x ; %convert feet to meters
xy_conv = @(x) (0.3048/1000).*x ; %convert feet to kilometers
windspeed_threshold = @(x) lt(x, 0) ; %remove negative values
winddir_reliability_threshold = @(x) lt(x, 0) ; %identify windspeed < 0 as having no direction
bad_nodes = [] ; %list of outlier nodes to ignore
humidity_threshold = @(x) gt(x, 200) ; % remove RH > 200%
temp_conv = @(x) x + 459.67 ; % convert Farenheit to Rankine
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
n = measurements ;
field = otype;
switch field
    case 'canopyheight'
        cleaned_data = clean_canopy_data ;
    case 'aspect'
        cleaned_data = clean_aspect_data ;
        cleaned_data = aspect_to_categories(cleaned_data) ;
    case 'slope'
        cleaned_data = clean_slope_data ;
    case 'dist2pond'
        cleaned_data = clean_dist2pond_data ;
    case 'dist2creek'
        cleaned_data = clean_dist2creek_data ;
    case 'slope-aspect'
        if size(measurements, 2) ~= 2
            Error('slope-aspect data must be supplied as [slope aspect]') ;
        end
        cleaned_data = zeros(size(measurements) ) ;
        n = measurements(:, 1) ;
        cleaned_data(:, 1) = clean_slope_data ;
        n = measurements(:, 2) ;
        cleaned_data(:, 2) = clean_aspect_data ;
        %flatten slopes that are probably artifacts
        cleaned_data(arrayfun(aspect_reliability_threshold, ...
                              measurements(:, 1) ), 1) = 0 ; 
        %change aspect to 'east-facing' for slopes that are basically flat
        cleaned_data(arrayfun(aspect_reliability_threshold, ...
                              measurements(:, 1) ), 2) = 90 ; 
    case 'bpressure'
        cleaned_data = clean_bpressure_data ;
    case 'z'
        cleaned_data = clean_z_data ;
    case {'projx' 'projy'}
        cleaned_data = clean_xy_data ;
    case 'windspeed'
        cleaned_data = clean_windspeed_data ;
    case 'winddir'
        cleaned_data = clean_aspect_data ;
        cleaned_data = aspect_to_categories(cleaned_data) ;
    case 'wind'
        if size(measurements, 2) ~= 2
            Error('wind data must be supplied as [windspeed winddir]') ;
        end
        cleaned_data = zeros(size(measurements) ) ;
        n = measurements(:, 1) ;
        cleaned_data(:, 1) = clean_windspeed_data ;
        n = measurements(:, 2) ;
        cleaned_data(:, 2) = clean_aspect_data ;
        %remove direction data for winds too weak to move the weathervanes
        cleaned_data(arrayfun(winddir_reliability_threshold, ...
                              measurements(:, 1) ), 2) = NaN ; 
    case 'nodeid'
        cleaned_data = clean_node_data ;
    case {'humidity_avg' 'humidity_avgmin' 'humidity_avgmax'}
        cleaned_data = clean_rh_data ;
    case {'temperature_avg' 'temperature_avgmin' 'temperature_avgmax'}
        cleaned_data = clean_temp_data ;
    otherwise
        %return the data unchanged
        cleaned_data = measurements ;
end

%--------------------------------------------------------------------------
    function cleandata = clean_rh_data
    %converts bad or placeholder values to NaN 
    cleandata = n ;
    cleandata(arrayfun(humidity_threshold, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_temp_data
    %converts temperature scale as defined by temp_conv 
    cleandata = temp_conv(n) ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_z_data
    %converts bad or placeholder values to NaN 
    cleandata = n ;
    cleandata(arrayfun(z_threshold, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_xy_data
    %converts bad or placeholder values to NaN 
    cleandata = n ;
    cleandata(arrayfun(z_conv, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_dist2pond_data
    %converts bad or placeholder values to NaN 
    cleandata = n ;
    cleandata(arrayfun(dist2pond_threshold, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_dist2creek_data
    %converts bad or placeholder values to NaN 
    cleandata = n ;
    cleandata(arrayfun(dist2creek_threshold, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_canopy_data
    %converts bad or placeholder values to NaN 
    cleandata = n ;
    cleandata(arrayfun(canopyheight_threshold, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_bpressure_data
    %converts bad or placeholder value to NaN
    cleandata = n ;
    %threshold = less than 0
    cleandata(arrayfun(bpressure_threshold, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_slope_data
    %converts uncertain slope values to NaN
    cleandata = n ;
    cleandata(arrayfun(slope_threshold, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_aspect_data
    %converts bad or placeholder values to NaN
    %converts measurements of 360 to 0
    cleandata = n ;
    cleandata(arrayfun(aspect_threshold, n) ) = NaN ;
    cleandata(eq(n, 360)) = 0 ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_windspeed_data
    %converts bad or placeholder values to NaN
    cleandata = n ;
    cleandata(arrayfun(windspeed_threshold, n) ) = NaN ;
    end
%--------------------------------------------------------------------------
    function cleandata = clean_node_data
    %converts bad nodes to NaN
    cleandata = n ;
    cleandata(ismember(n, bad_nodes) ) = NaN ;
    end
%--------------------------------------------------------------------------
end