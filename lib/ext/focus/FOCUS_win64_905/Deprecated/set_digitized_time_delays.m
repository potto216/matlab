function transducer = set_digitized_time_delays(xdcr, x, y, z, medium, fs)
% set_time_delays determines the time delay needed 
% for each element so that the array is focused at a 
% given point. The input arguments are:
% xdcr - the array structure,
% x, y, z - the focal point coordinates, and 
% medium - a structure that contains the speed of sound and other parameters.
% fs - the sampling frequency
%
% This function changes the transducer struct - the input transducer/array
% structure is copied over the 
% output transducer array structure.
% The time delays are determined with a time of flight approach that returns 
% only positive and zero time delay values.  The first transducer is excited
% at time t=0.

warning('''set_digitized_time_delays'' is no longer supported. This functionality is now a part of ''set_time_delays.''');

if nargin() ~= 6,
	disp('The proper usage of this function is:')
	error('xdcr = set_digitized_time_delays(xdcr, x, y, z, medium, fs)')
end

nelements = length(xdcr);
if nelements==1
    warning('single element: the time delay has been set to 0');
    xdcr.time_delay=0;
    transducer = xdcr;
    return;
end

speedofsound = medium.soundspeed;
timevector = zeros(1, nelements);
for ie = 1:nelements,
	elementcenter = xdcr(ie).center;
	timevector(ie) = sqrt((elementcenter(1) - x)^2 + (elementcenter(2) - y)^2 + (elementcenter(3) - z)^2)/ speedofsound;
end

% time reverse to focus and also make all time delays positive or zero
timevector = max(timevector) - timevector;
dt = 1/fs;
timevector = round(timevector / dt) * dt;

for ie = 1:nelements,
	xdcr(ie).time_delay = timevector(ie);
end
transducer = xdcr;
