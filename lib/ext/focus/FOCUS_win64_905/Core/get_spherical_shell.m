function sphereshell_struct = get_spherical_shell(radius,rad_curvature, center,euler)
% Description
%   This function creates a spherical shell transducer. It is intended to be used independently.
% Usage
%   transducer = get_spherical_shell(radius, rad_curv);
%   transducer = get_spherical_shell(radius, rad_curv, center);
%   transducer = get_spherical_shell(radius, rad_curv, center, euler);  
% Arguments
%   radius: The radius of the shell in m.
%   rad_curv: The radius of curvature of the shell in m.
%   center: a 3x1 or 1x3 array with the center coordinate of the element.
%   euler_angles: a 3x1 or 1x3 array with the rotation of the element in radian. For details about how FOCUS handles Euler angles, see the documentation for rotate_vector_forward.
% Output Parameters
%   transducer: A FOCUS transducer struct.
% Notes
%   The weight of the transducer is set to 1 and the phase is set to zero. If you need to focus via phase shifting, you must manually change the phase after the function has run.
sphereshell_struct.shape = 'shel';
sphereshell_struct.radius = radius;
sphereshell_struct.rad_curvature = rad_curvature;
if nargin < 3,
    sphereshell_struct.center=[0 0 0];
elseif length(center) ~= 3
     error('CENTER is 1X3 or 3X1 vector.');
else
     sphereshell_struct.center = center;
end

if nargin < 4,
    sphereshell_struct.euler=[0 0 0];
elseif length(euler) ~= 3
     error('EULER is 1X3 or 3X1 vector.');
else
     sphereshell_struct.euler = euler;
end

sphereshell_struct.time_delay=0;

sphereshell_struct.amplitude = 1;
sphereshell_struct.phase = 0;