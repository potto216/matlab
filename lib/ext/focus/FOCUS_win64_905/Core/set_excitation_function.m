function excitation=set_excitation_function(varargin)
% Description
%   A function to create an excitation function suitable for use with fnm_tsd and other transient pressure calculation functions.
% Usage
% fn = set_excitation_function();
% fn = set_excitation_function(type, f0, w);
% fn = set_excitation_function(type, f0, w, b);
% fn = set_excitation_function(signal, sample_period, pulse_width, clipping_threshold);  
% Arguments
%   type: An integer representing the function type. Three are available:
%     1: tone burst (A0sin(2? f0 t))
%     2: hanning weighted pulse (A0(1 - cos(2?t?w))sin(2? f0 t))
%     3: broadband t3 pulse (A0 t3 e - B tsin(2? f0 t))
%   f0: Center frequency in Hz
%   w: width of the pulse in s
%   b: Exponential term in type 3 pulse.
%   signal: A MATLAB vector containing a set of time samples representing the excitation signal in m/s.
%   sample_period: The duration between points in the excitation signal in s.
%   pulse_width: The overall duration of the signal in s
%   clipping_threshold: Optional argument describing the threshold below which frequency components will be ignored. If this value is negative, it will be assumed to be in dB, otherwise any value between zero and one can be used.
% Output Parameters
%   fn: An array containing the values set by the user. The elements of the array are in the same order as the arguments of the function, i.e. fn(1) = type, fn(2) = a0, etc.
% Notes
%   Transient calculations can be performed with arbitrary input signals, however performance will be improved if one of the signal types for which an analytical TSD expression has been derived is used. Otherwise, the calculation will be performed using FDTSD. See the documentation for fnm_tsd for details.
if (nargin()==0)
	disp('Please pick a function type')
	disp('1. Tone burst')
	disp('2. Hann-weighted tone burst')
	disp('3. t-cubed pulse')
	func_type = input('select 1, 2, or 3:');
    f0 = input('center frequency (f0):');
	pulse_width = input('Pulse width (in seconds):');
	beta0 = input('Beta (only used in the ''t cubed'' pulse):');
	excitation = set_excitation_function(func_type, f0, pulse_width, beta0);
elseif (nargin() >= 3 && nargin() <= 4)
    % Determine whether input is a custom excitation or one for which an
    % analytical TSD expression exists
    if(length(varargin{1}) > 1 && isnumeric(varargin{1}))
        if nargin() == 3
            excitation = set_fdtsd_excitation(varargin{1}, varargin{2}, 0);
        else
            excitation = set_fdtsd_excitation(varargin{1}, varargin{2}, varargin{4});
        end
    else
        func_type = varargin{1};
        % If func_type is a string then convert to int
        if ischar(func_type)
            if strcmp('tone burst',func_type)
                func_type = 1;
            elseif strcmp('hann pulse',func_type) || strcmp('hanning pulse',func_type)
                func_type = 2;
            elseif strcmp('tcubed pulse',func_type)
                func_type = 3;
            else
                error('"%s" is not a valid function type. Options are "tone burst", "hanning pulse", or "tcubed pulse"; see the documentation for details.')
            end
        end
        f0 = varargin{2};
        pulse_width = varargin{3};
        if (func_type ~= 1) && (func_type ~= 2) && (func_type ~= 3),
                error('%i is not a valid function type. Options are 1, 2, or 3; see the documentation for details.')
        else 
            if f0 <= 0
                 error('Frequency must be greater than 0.')
            end
            if pulse_width <= 0
                error('Pulse width must be greater than 0.')
            end
            
            if func_type == 3
                if nargin() < 4
                    beta0 = 0;
                else
                    beta0 = varargin{4};
                end

                if beta0 < 0
                    error('Beta must be non-negative.');
                end
            else
                beta0 = 0;
            end

            % New object-based method
            excitation.type = func_type;
            excitation.f0 = f0;
            excitation.pulse_width = pulse_width;
            excitation.B = beta0;
        end
    end
else
    error('Incorrect number of arguments. Please see the documentation for the correct usage of this function.');
end
