function xdcr_array = create_spherically_focused_ring_array(ring_count, ring_width, kerf, geometric_focus, flatten_array)
% Description
%   Creates an array of spherically focused ring transducers.
% Usage
%   transducer = create_spherically_focused_ring_array(ring_count, ring_width, kerf,geometric_focus);  
% Arguments
%   ring_width: The with of each ring in meters.
%   kerf: The spacing between the rings in meters.
%   ring_count: The number of rings in the array.
%   geometric_focus: The geometric focus of the array elements.
% Output Parameters
%   transducer: An array of transducer structs.
% Notes
%   Transducer arrays used one-dimensional indexing prior to FOCUS version 0.332. One-dimensional indexing is still possible, though the indices may not match those used in older versions of FOCUS.
center = [0 0 0];
euler = [0 0 0];

x = center(1);
y = center(2);
z0 = center(3);

if nargin < 5
    flatten_array = 0;
end

if size(ring_width) == [1 1]
    for i=1:ring_count
        inner_radius = (i-1)*(ring_width + kerf);
        outer_radius = inner_radius + ring_width;

        alpha = inner_radius / geometric_focus;
        if flatten_array
            z = 0;
        else
            z = geometric_focus * (1 - cos(alpha)) + z0;
        end
        xdcr_array(i) = get_spherically_focused_ring(inner_radius, outer_radius, geometric_focus, [x y z], euler);
    end
else
    ring_count = ring_count;
    inner_radii = ring_width;
    outer_radii = kerf;
    
    for i = 1:ring_count
        xdcr_array(i) = get_spherically_focused_ring(inner_radii(i), outer_radii(i), geometric_focus);
    end
end
end