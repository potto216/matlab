function circ_struct = get_circ(radius,center,euler, piston_apodization_index)
% Description
%   This function creates a circular transducer. It is intended to work with the create_circ_arrray functions, but it can be used independently.
% Usage
%   transducer = get_circ(radius);
%   transducer = get_circ(radius, center);
%   transducer = get_circ(radius, center, euler);
%   transducer = get_circ(radius, center, euler, piston_apodization_index);  
% Arguments
%   radius: radius of the transducer in m.
%   center: a 3x1 or 1x3 array with the center coordinate of the element.
%   euler_angles: a 3x1 or 1x3 array with the rotation of the element in radian. For details about how FOCUS handles Euler angles, see the documentation for rotate_vector_forward.
%   piston_apodization_index: Type of apodization to use. Must be one of the following:
%     0: uniform - this is the default.
%     1: cosine
%     2: raised cosine
%     3: quadratic
%     4: quartic
% Output Parameters
%     transducer A FOCUS transducer struct.
% Notes
%   The weight of the transducer is set to 1 and the phase is set to zero. If you need to focus via phase shifting, you must manually change the phase after the function has run. Piston apodization is currently defined only for this transducer geometry.

if nargin < 4,
        piston_apodization_index = 0;
end
if nargin < 3,
        euler = [0 0 0];
end
if nargin < 2,
        center = [0 0 0];
end

circ_struct.shape = 'circ';
circ_struct.radius = radius;
circ_struct.amplitude = 1;
circ_struct.phase = 0;
circ_struct.time_delay=0;
circ_struct.piston_apodization_index = piston_apodization_index;
if length(center) ~= 3
    error('CENTER is 1X3 or 3X1 vector.');
else
    circ_struct.center = center;
end
if length(euler) ~= 3
    error('EULER is 1X3 or 3X1 vector.');
else
    circ_struct.euler = euler;
end
