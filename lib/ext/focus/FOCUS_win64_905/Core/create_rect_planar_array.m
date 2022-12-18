function xdcr_array = create_rect_planar_array(nelex,neley,element_width,element_height,kerf_x,kerf_y,center,override)
% Description
%   This function creates a planar array of rectangular transducers.
% Usage
%   transducer = create_rect_planar_array();
%   transducer = create_rect_planar_array(nx, ny, width, height, kerf_x, kerf_y);
%   transducer = create_rect_planar_array(nx, ny, width, height, kerf_x, kerf_y,center);
%   transducer = create_rect_planar_array(nx, ny, width, height, kerf_x, kerf_y,center, override);  
% Arguments
%   nx: Number of elements in the x direction.
%   ny: Number of elements in the y direction.
%   width: Width of a single element in meters, all elements in the array are the same size.
%   height: Height of a single element in meters, all elements in the array are the same size.
%   kerf_x: Kerf (edge-to-edge spacing) in the x direction.
%   kerf_y: Kerf (edge-to-edge spacing) in the y direction.
%   center: Three element array describing the coordinates of the center of the array.
%   override: Omit to allow error checking, any value to bypass error checking.
% Output Parameters
%   transducer: An array of transducer structs.
% Notes
%   The center of the array is defined to be the geometric center of the rectangle that bounds the array. All coordinates are expressed in meters.
if nargin==0
	disp('Please enter the following arguments:')
	disp('nelex, neley, element halfwidth, element halfheight, x kerf, y kerf, center(a 3x1 array)')
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
        kerf_y=element_height*0.1;
    end
	center=[0 0 0];
end
if (kerf_x < 0 || kerf_y < 0) && nargin()~=7 && (nelex~=1 && neley ~=1)
    xdcr_array=[];
	disp('Elements are going to overlap')
	disp('array not created, if you really')
	disp('want to make the array, please set')
	error('the override flag')
end
if nargin()==6
    center=[0 0 0];
end
if length(center)~=3
    center=[ 0 0 0];
end
if mod(nelex,2)==1 
    xf=0;
else
    xf=.5;
end
if mod(neley,2)==1 
    yf=0;
else
    yf=.5;
end

spacing_x = kerf_x + element_width;
spacing_y = kerf_y + element_height;

x_coords = floor(-(nelex-1)/2):floor((nelex-1)/2);
y_coords = floor(-(neley-1)/2):floor((neley-1)/2);

for i=1:nelex
    for j=1:neley
        x = x_coords(i)*spacing_x+xf*spacing_x+center(1);
        y = y_coords(j)*spacing_y+yf*spacing_y+center(2);
        z = center(3);
        xdcr_array(i,j)=get_rect(element_width,element_height,[x y z],[0 0 0]);
    end
end