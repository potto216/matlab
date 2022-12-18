function rect_struct = get_rect(width,height,center,euler)
% Description
%   Creates a rectangular transducer. It is intended to work with the create_rect_array functions, but it can be used independently.
% Usage
%   transducer = get_rect(width, height);
%   transducer = get_rect(width, height, center);
%   transducer = get_rect(width, height, center, euler);  
% Arguments
%   width: Width of the transducer in m.
%   height: Height of the transducer in m.
%   center: a 3x1 or 1x3 array with the center coordinate of the element.
%   euler_angles: a 3x1 or 1x3 array with the rotation of the element in radian. For details about how FOCUS handles Euler angles, see the documentation for rotate_vector_forward.
% Output Parameters
%   transducer: A FOCUS transducer struct.
% Notes
%   The weight of the transducer is set to 1 and the phase is set to zero. If you need to focus via phase shifting, you must manually change the phase after the function has run.

if nargin < 4,
	euler = [0 0 0];
end
if nargin < 3,
	center = [0 0 0];
end

rect_struct.shape = 'rect';
rect_struct.width = width;
rect_struct.height = height;
rect_struct.amplitude = 1;
rect_struct.phase = 0;
rect_struct.time_delay=0;
if length(center) ~= 3
    error('CENTER is 1X3 or 3X1 vector.');
else
    rect_struct.center = center;
end
if length(euler) ~= 3
    error('EULER is 1X3 or 3X1 vector.');
else
    rect_struct.euler = euler;
end
