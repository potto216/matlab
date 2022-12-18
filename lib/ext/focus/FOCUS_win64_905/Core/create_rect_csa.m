function xdcr_array =create_rect_csa(nelex,neley,element_width,element_height,kerf_x,kerf_y,r_curv,override)
% Description
%   This function creates a cylindrical section array of rectangular transducers.
% Usage
%   transducer = create_rect_csa();
%   transducer = create_rect_csa(nx, ny, width, height, kerf_x, kerf_y, r_curv);
%   transducer = create_rect_csa(nx, ny, width, height, kerf_x, kerf_y, r_curv,override);  
% Arguments
%   nx: Number of elements in the x direction.
%   ny: Number of elements in the y direction.
%   width: Width of a single element in meters, all elements in the array are the same size.
%   height: Height of a single element in meters, all elements in the array are the same size.
%   kerf_x: Kerf (edge-to-edge spacing) in the x direction.
%   kerf_y: Kerf (edge-to-edge spacing) in the y direction.
%   r_curv: Radius of curvature of the array.
%   override: Omit to allow error checking, any value to bypass error checking.
% Output Parameters
%   transducer: An array of transducer structs.
% Notes
%   The curve of cylinder is on the X axis, with elements rotating about the Y axis. The center of the array is defined to be the center of the element anchoring the array. All coordinates are expressed in meters.
if nargin==0
	disp('Please enter the following arguments:')
	disp('nelex, neley, element_width, element_height, x kerf, y kerf, r_curv')
	nelex=input('nelex:');
	neley=input('neley:');
	element_width=input('element_width:');
	element_height=input('element_height:');
   	if nelex~=1
        kerf_x=input('x kerf:');
    else 
        kerf_x=element_width*0.1;
    end
    if neley~=1
        kerf_y=input('y kerf:');
    else
        kerf_y = element_height*0.1;
    end
	r_curv=input('r_curv:');
end
if(kerf_x < 0 || kerf_y < 0)&& nargin()~=7
    xdcr_array=[];
	disp('Elements are going to overlap')
	disp('array not created, if you really')
	disp('want to make the array, please set')
	error('the override flag')
end

spacing_x = kerf_x + element_width;
spacing_y = kerf_y + element_height;

c_length=2*pi*r_curv;
if (nelex*spacing_x) > (c_length/2)
    xdcr_array=[];
    error('element warps onto itself, make r_curv larger or nele smaller')
end

dx=spacing_x/r_curv;

y_coords = floor(-(neley-1)/2):floor((neley-1)/2);
theta = (-(nelex-1)/2*dx):dx:((nelex-1)/2*dx);

for i=1:nelex
    for j=1:neley
        z=r_curv-r_curv*cos(theta(i));
        y = spacing_y * y_coords(j);
        x=r_curv*sin(theta(i));
        xdcr_array(i,j)=get_rect(element_width,element_height,[x y z],[-theta(i) 0 0]);
    end
end
%draw_array(xdcr_array,'r')
