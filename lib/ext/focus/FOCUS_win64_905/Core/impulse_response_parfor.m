function pressure = impulse_response_parfor(xdcr, cg, medium, time_samples, dflag)
% Description
%   Calculates the impulse response of a transducer array.
% Usage
%   pressure = impulse_response_parfor(transducer_array, coordinate_grid, medium, time_samples,disp_flag); 
% Arguments
%   transducer_array: A transducer_array.
%   coordinate_grid: A coordinate grid struct like the ones created by set_coordinate_grid.
%   medium: A medium struct like the ones created by set_medium.
%   time_samples: A time sample struct created by set_time_samples.
%   disp_flag: Display flag, 1 = display, 0 = suppress.
% Output Parameters
%   pressure: A 3-d array representing the complex pressure at each point in space.
% Notes
%   This function uses the MATLAB Parallel Computing Toolkit to perform the pressure calculation using multiple threads. The speed increase realized by this function is entirely dependent on the number of processor cores present in the computer executing the code. If the Parallel Computing Toolkit is not installed, the function will fail to run.
pressure = 0;
parfor i = 1:size(xdcr,1)*size(xdcr,2)
    pressure = pressure + impulse_response(xdcr(i), cg, medium, time_samples, dflag, 1);
end
end

