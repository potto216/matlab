function xdcr_array = create_spherical_shell_planar_array(nelex, neley, a, R, kerf_x, kerf_y, center, override)
% Description: Creates a planar array of spherical shell transducers.
% Usage
%   transducer = create_spherical_shell_planar_array();
%   transducer = create_spherical_shell_planar_array(nx, ny, a, r, kerf_x, kerf_y);
%   transducer = create_spherical_shell_planar_array(nx, ny, a, r, kerf_x, kerf_y,center);
%   transducer = create_spherical_shell_planar_array(nx, ny, a, r, kerf_x, kerf_y,center, override);  
% Arguments
%   nx: Number of elements in the x direction.
%   ny: Number of elements in the y direction.
%   a: Radius of the elements in meters.
%   r: Radius of curvature of the elements in meters.
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
	disp('nelex, neley, a, R, x kerf, y kerf, center(a 3x1 array)')
	nelex=input('nelex:');
	neley=input('neley:');
	a=input('a:');
    R=input('R:');
	if nelex~=1
        kerf_x=input('x spacing:');
    else 
        kerf_x=a * 0.1;
    end
    if neley~=1
        kerf_y=input('y spacing:');
    else
        kerf_y = a * 0.1;
    end
    center=[0 0 0 ];
end
if ((kerf_x < 0 && (nelex ~= 1)) || (kerf_y < 0 && (neley ~=1))) && nargin()~=8, 
    xdcr_array=[];
	disp('Elements are going to overlap')
	disp('array not created, if you really')
	disp('want to make the array, please set')
	error('the override flag (using any argument)')
	return
end

if nargin() < 7,
    center=[0 0 0];
end
if length(center)~=3
    center=[ 0 0 0];
end

counter =1;
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

spacing_x = kerf_x + (2*a);
spacing_y = kerf_y + (2*a);

x_coords = floor(-(nelex-1)/2):floor((nelex-1)/2);
y_coords = floor(-(neley-1)/2):floor((neley-1)/2);

for i=1:nelex
    for j=1:neley
        x = x_coords(i)*spacing_x+xf*spacing_x+center(1);
        y = y_coords(j)*spacing_y+yf*spacing_y+center(2);
        z = center(3);
        xdcr_array(i,j) = get_spherical_shell(a, R, [x y z], [0 0 0]);
        counter = counter + 1;
    end
end