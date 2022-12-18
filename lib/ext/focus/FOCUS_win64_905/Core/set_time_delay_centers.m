function transducer = set_time_delay_centers(xdcr, x, y, z, medium, center, fs)
% Description
%   Determine the time delays required to focus a transducer array at a given point. Time delays calculated with set_time_delays may fall between temporal samples unless the sampling frequency is provided, in which case the delays are shifted to fit the temporal grid (digitized) rather than being allowed to fall between temporal samples.
% Usage
%   transducer = set_time_delays(transducer, x, y, z, medium, fs);  
% Arguments
%   transducer: A transducer array, e.g. one created by create_circ_csa.
%   x: The x coordinate of the focus.
%   y: The y coordinate of the focus.
%   z: The z coordinate of the focus.
%   medium: A medium struct.
%   fs: Optional sampling frequency in Hz. If provided, digitized time delays will be used.
%   center: zero delay position.
% Output Parameters
%   transducer: The input transducer array with adjusted time delays.
% Notes
%   This function alters the transducer struct, the output transducer should be the same as the input transducer (transducer).

if nargin() < 5 || nargin() > 7
	error('Correct usage is xdc = set_time_delays(xdc, x, y, z, medium) or xdc = set_time_delays(xdc, x, y, z, medium, fs) or xdc = set_time_delays(xdc, x, y, z, medium, fs, center)')
end

array_length = size(xdcr,1);
array_height = size(xdcr,2);
array_center = ceil(array_height/2);

if array_length==1
   warning('single element: the time delay has been set to 0');
   xdcr.time_delay=0;
   transducer = xdcr;
   return;
end

speedofsound = medium.soundspeed;
timevector = zeros(1, array_length);
for ie = 1:array_length
    elementcenter = xdcr(ie,array_center).center;
	timevector(ie) = sqrt((elementcenter(1) - x)^2 + (elementcenter(2) - y)^2 + (elementcenter(3) - z)^2)/ speedofsound;
end

% time reverse to focus and also make all time delays positive or zero
if nargin() ==5
    timevector = max(timevector) - timevector;
end

if nargin() >5 && ~isempty(center)
    reference = sqrt((center(1) - x)^2 + (center(2) - y)^2 + (center(3) - z)^2)/ speedofsound;
    timevector = reference - timevector + 5e-5;
    
    % Digitize time delays if sample frequency is provided
    if nargin() == 7
        dt = 1/fs;
        timevector = round(timevector / dt) * dt;
    end
    
end

% timevector = timevector - min(timevector);

for ie = 1:array_length
    for ih = 1:array_height
        xdcr(ie,ih).time_delay = timevector(ie);
    end
end

transducer = xdcr;
