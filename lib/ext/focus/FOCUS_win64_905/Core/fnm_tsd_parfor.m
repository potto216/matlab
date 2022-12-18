function pressure = fnm_tsd_parfor(xdcr, cg, medium, fs, ndiv, excitation_function, dflag, low_precision)
% Description
%   Calculates the transient pressure field from an arbitrary transducer array using the Fast Nearfield Method.
% Usage
%   pressure = fnm_tsd_parfor(transducer_array, coordinate_grid, medium, time_struct,ndiv, excitation_function, disp_flag); 
% Arguments
%   transducer_array: A transducer_array.
%   coordinate_grid: A coordinate grid struct like the ones created by set_coordinate_grid.
%   medium: A medium struct like the ones created by set_medium.
%   time_struct: A time samples struct created by set_time_samples.
%   ndiv: The number of integral points to use.
%   excitation_function: The excitation function to use.
%   disp_flag: Display flag, 1 = display, 0 = suppress.
% Output Parameters
%   pressure: A 3-d array representing the complex pressure at each point in space.
%   start_time: A vector containing the start time for the impulse response at each observation point.
% Notes
%   This function uses the MATLAB Parallel Computing Toolkit to perform the pressure calculation using multiple threads. The speed increase realized by this function is entirely dependent on the number of processor cores present in the computer executing the code. If the Parallel Computing Toolkit is not installed, the function will fail to run.
if nargin < 8
    low_precision = 0;
end
pressure = 0;
parfor i = 1:size(xdcr,1)*size(xdcr,2)
    pressure = pressure + fnm_tsd(xdcr(i), cg, medium, fs, ndiv, excitation_function, dflag, low_precision);
end
end