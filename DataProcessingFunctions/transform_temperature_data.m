function returnval = transform_temperature_data(ts, vals)
% zs = elevations (not needed for transformation)
% ts = values of either temperature or transformed temperature
% vals = (optional) transformed values, to be converted back to ts
%
% returnval = either trans or ts, depending on value of dattype 
% we assume ts is something like a rational function of zs
% therefore the complement of the temperature data t_c = max(ts) .- ts)
% follows an exponential decay function t_c = a*exp(b.*zs)
% we linearize the data as follows:
% lt = ln(t_c) = ln(a) + b.*zs
%
% the transformation of trans back to ts is
% ts = max(y) - l_c 
%    = max(y) - exp(lt) 
%    = max(y) - a*exp(b.*zs)
kelvin = ts + 273.15 ;
if nargin < 2
    returnval = log(1.001*max(kelvin) - kelvin) ;
else
    returnval = 1.001*max(ts) - exp(vals) ;
end