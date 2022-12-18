function ring_struct = get_ring(inner_radius, outer_radius, center, euler)
% Description
%   This function creates a planar ring transducer. It is intended to work with the create_ring_arrray functions, but it can be used independently.
% Usage
%   transducer = get_ring(inner_radius, outer_radius);
%   transducer = get_ring(inner_radius, outer_radius, center);
%   transducer = get_ring(inner_radius, outer_radius, center, euler);  
% Arguments
%   inner_radius: inner radius of the transducer in m.
%   outer_radius: outer radius of the transducer in m.
%   center: a 3x1 or 1x3 array with the center coordinate of the element.
%   euler: a 3x1 or 1x3 array with the rotation of the element in radian. For details about how FOCUS handles Euler angles, see the documentation for rotate_vector_forward.
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

    ring_struct.shape = 'ring';
    ring_struct.inner_radius = inner_radius;
    ring_struct.outer_radius = outer_radius;
    ring_struct.amplitude = 1;
    ring_struct.phase = 0;
    ring_struct.time_delay=0;

    if length(center) ~= 3
        error('CENTER is 1X3 or 3X1 vector.');
    else
        ring_struct.center = center;
    end
    if length(euler) ~= 3
        error('EULER is 1X3 or 3X1 vector.');
    else
        ring_struct.euler = euler;
    end
end