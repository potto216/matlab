function plot_excitation_function(excitation_function, time_struct)
%PLOT_EXCITATION_FUNCTION Plot the transducer excitation as a function of
%time. If no time struct is provided, the excitation function will be shown
%in continuous time rather than discrete time.
%   excitation_function: The excitation function created using
%                        set_excitation_function()
%   time_struct: A time struct created using set_time_samples()

if nargin < 1 || nargin > 2
    error('Wrong number of arguments provided. This function requires 1 or 2 arguments.');
end

a0 = excitation_function(2);
f0 = excitation_function(3);
w = excitation_function(4);
b = excitation_function(5);

resolution = 200;

% Calculate time points
if nargin == 1
    time = 0:w/resolution:w;
    % Calculate function value at each time point
    excitation = zeros(size(time));
    for i = 1:length(time)
        t = time(i);
        % Tone burst
        if excitation_function(1) == 1
            excitation(i) = a0 * sin(2*pi*f0*t);
        % Hanning-weighted pulse
        elseif excitation_function(1) == 2
            excitation(i) = a0 * (1 - cos(2*pi * t/w)) * sin(2*pi*f0*t);
        % T-cubed pulse
        elseif excitation_function(1) == 3
            excitation(i) = a0 * (t^3) * exp(-b * t) * sin(2*pi*f0 * t);
        end
    end
else
    time = time_struct.tmin:time_struct.deltat:time_struct.tmax;
    % Calculate function value at each time point
    excitation = zeros(size(time));
    for i = 1:length(time)
        t = time(i);
        if t < w
            % Tone burst
            if excitation_function(1) == 1
                excitation(i) = a0 * sin(2*pi*f0*t);
            % Hanning-weighted pulse
            elseif excitation_function(1) == 2
                excitation(i) = a0 * (1 - cos(2*pi * t/w)) * sin(2*pi*f0*t);
            % T-cubed pulse
            elseif excitation_function(1) == 3
                excitation(i) = a0 * (t^3) * exp(-b * t) * sin(2*pi*f0 * t);
            end
        end
    end
end

figure();
plot(time, excitation);
xlabel('Time (s)');
ylabel('Velocity (m/s)');
% Display type of excitation
if excitation_function(1) == 1
    title('Tone Burst');
elseif excitation_function(1) == 2
    title('Hanning-weighted Pulse');
elseif excitation_function(1) == 3
    title('T-Cubed Pulse');
end
end
