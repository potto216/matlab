function xdcr_array=create_rect_enclosed_csa(nelecirc,neley,element_width,element_height,kerf_y,r_curv)
% Description
%   This function creates a cylindrical section array of rectangular transducers.
% Usage
%   transducer = create_rect_csa2();
%   transducer = create_rect_csa2(nelecirc,neley,element_width,element_height,kerf_y,r_curv);

% Arguments
%   ncirc: Number of elements in the circle.
%   ny: Number of elements in the y direction.
%   width: Width of a single element in meters, all elements in the array are the same size.
%   height: Height of a single element in meters, all elements in the array are the same size.
%   kerf_y: Kerf (edge-to-edge spacing) in the y direction.
%   r_curv: Radius of curvature of the array.

% Output Parameters
%   transducer: An array of transducer structs.
% Notes
%   The curve of cylinder is on the X axis, with elements rotating about the Y axis. The center of the array is defined to be the center of the element anchoring the array. All coordinates are expressed in meters.
if nargin==0
	disp('Please enter the following arguments:')
	disp('nelecirc, neley, element_width, element_height, r_curv')
	nelecirc=input('nelecirc:');
    neley=input('neley:');
	element_width=input('element_width:');
	element_height=input('element_height:');
   	if nelecirc<=1
        error('nelecirc need to be larger than 1')
    end
    r_curv=input('r_curv:');
end

if kerf_y < 0 
    xdcr_array=[];
	disp('Elements are going to overlap')
	error('array not created');
end

if nelecirc<=1
    error('nelecirc need to be larger than 1')
end
 
spacing_y = kerf_y + element_height;

if (element_width) > (r_curv * tan(pi / nelecirc))
    xdcr_array=[];
    error('element warps onto itself, make r_curv larger or nele smaller')
end

y_coords = floor(-(neley-1)/2):floor((neley-1)/2);
theta = -pi*(1-1/nelecirc):2*pi/nelecirc:pi*(1-1/nelecirc);%(-(nelex-1)/2*dx):dx:((nelex-1)/2*dx);

for i=1:nelecirc
    for j=1:neley
        z = -r_curv*cos(theta(i));
        y = spacing_y * y_coords(j);
        x = r_curv*sin(theta(i));
        xdcr_array(i,j)=get_rect(element_width,element_height,[x y z],[-theta(i) 0 0]);
    end
end
%draw_array(xdcr_array,'r')
