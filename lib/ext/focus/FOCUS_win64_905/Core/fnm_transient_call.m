function transient_pressure=fnm_transient_call(transducer_array,coordinate_grid,medium,time_struct,ndiv,input_func,disp_flag)
% Description
%   Calculates the transient pressure field from an arbitrary transducer array using the Fast Nearfield Method.
% Usage
% pressure, start_time = fnm_transient_call(transducer_array, coordinate_grid, medium,time_samples, ndiv, excitation_function, disp_flag); 
% Arguments
%   transducer_array: A FOCUS transducer array.
%   coordinate_grid: A FOCUS coordinate grid.
%   medium: A FOCUS medium.
%   time_samples: A time samples struct created by set_time_samples.
%   f0: The frequency of the array in Hz.
%   ndiv: The number of integral points to use.
%   excitation_function: The excitation function to use.
%   disp_flag: Display flag, 1 = display, 0 = suppress.
% Output Parameters
%   pressure: A 4-d array representing the complex pressure at each point in spacetime.
%   start_time: A vector containing the start time for the impulse response at each observation point.
% Notes
%   This function has not been validated to the same extent as fnm_call and is still in unstable development. The calling structure may change between releases.
transient_pressure = fnm_tsd(transducer_array, coordinate_grid, medium, time_struct, ndiv, input_func, disp_flag);