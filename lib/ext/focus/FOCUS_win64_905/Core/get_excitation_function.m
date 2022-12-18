function excitation = get_excitation_function(varargin)
%GET_EXCITATION_FUNCTION Generates a series of points along an excitation
%function
% 
% USAGE 1
% argument order is [type f0 w B dt]
% type:
% type 1 = tone burst, A0*sin(2.0*PI*f0*t)
% type 2 = hanning weighted pulse, .5*(1-cos(2*PI*t/w))*sin(2*PI*f0*t)
% type 3= paper function, A0*pow(t, 3)*exp(-B*t)*sin(2.0*PI*f0*t)
% f0 - center frequency (Hz)
% w - pulse width (seconds)
% B - exponential term in type 3 pulse
% dt - Sampling period
% deriv - if this flag is set, the derivative is returned
%
% USAGE 2: Generate points from existing EF
% excitation_function - Generated with set_excitation_function
% dt - Sampling period
% deriv - if this flag is set, the derivative is returned

    if nargin() ~= 5 && nargin() ~= 2 && nargin() ~= 6 && nargin() ~= 3
        error('This function requires either 2 or 5 arguments. See the documentation for details.');
    elseif nargin() == 5 || nargin() == 6
        input_ef = set_excitation_function(varargin{1}, varargin{2}, varargin{3}, varargin{4});
        dt = varargin{5};
    else
        input_ef = varargin{1};
        dt = varargin{2};
    end

    if nargin() == 3
        deriv = varargin{3};
    elseif nargin() == 6
        deriv = varargin{6};
    else
        deriv = 0;
    end

    epsilon = 1e-15;
    f0 = input_ef.f0;
    w = input_ef.pulse_width;
    b = input_ef.B;
    
    time = 0:dt:w;
    % Calculate function value at each time point
    excitation = zeros(size(time)-1);

    if deriv == 0
        for i = 1:length(time)
            t = time(i);
            % Tone burst
            if input_ef.type == 1
                exc = sin(2*pi*f0*t);
                % Do not include final zero
                if ~(i == length(time) && abs(exc) <= epsilon)
                    excitation(i) = exc;
                end
            % Hanning-weighted pulse
            elseif input_ef.type == 2
                excitation(i) = 0.5 * (1 - cos(2*pi * t/w)) * sin(2*pi*f0*t);
            % T-cubed pulse
            elseif input_ef.type == 3
                excitation(i) = (t^3) * exp(-b * t) * sin(2*pi*f0 * t);
            else
                error('Invalid excitation function type.');
            end
        end
    else
        for i = 1:length(time)
            t = time(i);
            % Tone burst
            if input_ef.type == 1
                exc = 2*pi*f0*cos(2*pi*f0*t);
                % Do not include final zero
                if ~(i == length(time) && abs(exc) <= epsilon)
                    excitation(i) = exc;
                end
            % Hanning-weighted pulse
            elseif input_ef.type == 2
                excitation(i) = pi * (f0*(1 - cos(2*pi * t/w)) * cos(2*pi*f0*t) + 1/w * sin(2*pi*f0*t) * sin(2*pi * t/w));
            % T-cubed pulse
            elseif input_ef.type == 3
                error('Not implemented yet.');
            else
                error('Invalid excitation function type.');
            end
        end
    end
end

