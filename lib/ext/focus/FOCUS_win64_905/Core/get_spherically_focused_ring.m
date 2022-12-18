function xdcr_struct = get_spherically_focused_ring(inner_radius, outer_radius, geometric_focus, center, euler)
% Description
%   This function creates a planar ring transducer. It is intended to work with the create_ring_arrray functions, but it can be used independently.
% Usage
%   transducer = get_spherically_focused_ring(inner_radius, outer_radius, geometric_focus);
%   transducer = get_spherically_focused_ring(inner_radius, outer_radius, geometric_focus,center);
%   transducer = get_spherically_focused_ring(inner_radius, outer_radius, geometric_focus,center, euler);  
% Arguments
%   inner_radius: inner radius of the transducer in m.
%   outer_radius: outer radius of the transducer in m.
%   geometric_focus: geometric focus of the transducer in m.
%   center: a 3x1 or 1x3 array with the center coordinate of the element.
%   euler: a 3x1 or 1x3 array with the rotation of the element in radian. For details about how FOCUS handles Euler angles, see the documentation for rotate_vector_forward.
% Output Parameters
%   transducer: A FOCUS transducer struct.
% Notes
%   The weight of the transducer is set to 1 and the phase is set to zero. If you need to focus via phase shifting, you must manually change the phase after the function has run.
    xdcr_struct.shape = 'sph ring';
    xdcr_struct.inner_radius = inner_radius;
    xdcr_struct.outer_radius = outer_radius;
    xdcr_struct.geometric_focus = geometric_focus;
    if nargin < 4,
        xdcr_struct.center=[0 0 0];
    elseif length(center) ~= 3
         error('CENTER is 1X3 or 3X1 vector.');
    else
         xdcr_struct.center = center;
    end

    if nargin < 5,
        xdcr_struct.euler=[0 0 0];
    elseif length(euler) ~= 3
         error('EULER is 1X3 or 3X1 vector.');
    else
         xdcr_struct.euler = euler;
    end
    xdcr_struct.time_delay=0;
    xdcr_struct.amplitude = 1;
    xdcr_struct.phase = 0;
end