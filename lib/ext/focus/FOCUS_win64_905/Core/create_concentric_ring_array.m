function xdcr_array = create_concentric_ring_array(el_count, el_width, kerf)
% Description
%   Creates an array of concentric ring transducers.
% Usage
%   transducer = create_concentric_ring_array(ring_count, ring_width, kerf);
% Arguments
%   ring_count: The number of rings in the array.
%   ring_width: The with of each ring in meters.
%   Can also be used for inner radii, A vector of values specifying the
%   inner radius (in meters) of each element in the array, starting with
%   the center element and ending with the outer element.
%   kerf: The edge-to-edge spacing of the rings in meters.
%   Can also be used for outer radii, A vector of values specifying the
%   inner radius (in meters) of each element in the array, starting with
%   the center element and ending with the outer element.
% Output Parameters
%   transducer: An array of transducer structs.
% Notes
%   Ring transducer arrays always use one-dimensional indexing starting with the innermost element.

% All elements have the same width
if size(el_width) == [1 1]
    for i=1:el_count
       xdcr_array(i) = get_ring((el_width + kerf)*(i-1), (el_width + kerf)*(i-1) + el_width);
    end
% Vectors of inner and outer radii
elseif size(el_width) == [1 el_count]
    for i=1:el_count
       xdcr_array(i) = get_ring(el_width(i), kerf(i));
    end
end

