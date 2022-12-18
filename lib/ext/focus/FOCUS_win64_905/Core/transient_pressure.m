function pressure = transient_pressure(xdcr_array, coord_grid, medium, time_samples, ndiv, excitation_function, calc_method)
%TRANSIENT_PRESSURE Summary of this function goes here
%   Detailed explanation goes here
if nargin < 7
    calc_method = 'fnm tsd';
end

if strfind(calc_method, 'fnm')
    if strfind(calc_method, 'tsd')
        pressure = fnm_tsd(xdcr_array, coord_grid, medium, time_samples, ndiv, excitation_function, 0);
    else
        pressure = fnm_transient(xdcr_array, coord_grid, medium, time_samples, ndiv, excitation_function, 0);
    end
elseif strfind(calc_method, 'rayleigh')
    pressure = rayleigh_transient(xdcr_array, coord_grid, medium, time_samples, ndiv, excitation_function, 0);
else
    error('Unrecognized calculation method');
end

end
