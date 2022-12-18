function xdcr_array=create_circ_csa(nelex,neley,radius,kerf_x,kerf_y,r_curv,override)
% Description
%     This function creates a cylindrical section array of circular transducers.
% Usage
%     transducer = create_circ_csa();
%     transducer = create_circ_csa(nx, ny, radius, kerf_x, kerf_y, r_curv);
%     transducer = create_circ_csa(nx, ny, radius, kerf_x, kerf_y, r_curv, override);
% Arguments
%     nx: Number of elements in the x direction.
%     ny: Number of elements in the y direction.
%     radius: Radius each element in m. All elements in the array will be the same size.
%     kerf_x: Kerf (edge-to-edge spacing) in the x direction.
%     kerf_y: Kerf (edge-to-edge spacing) in the y direction.
%     r_curv: Radius of curvature of the apparatus.
%     override: Omit to allow error checking, any value to bypass error checking.
% Output Parameters
%     transducer: A 2-d array of transducer structs. The first element is at transducer(1,1) and the last
% element is at transducer(nx,ny).
if nargin==0
	disp('Please enter the following arguments:')
	disp('nelex, neley, radius, x kerf, y kerf, r_curv')
	nelex=input('nelex:');
	neley=input('neley:');
	radius=input('radius:');
	if nelex~=1
        kerf_x=input('x kerf:');
    else 
        kerf_x=radius*0.1;
    end
    
    if neley~=1
        kerf_y=input('y kerf:');
    else
        kerf_y = radius*0.1;
    end
    r_curv=input('r_curv:');
end
if (kerf_x < 0 || kerf_y < 0 )&& nargin()~=7
    xdcr_array=[];
	disp('Elements are going to overlap')
	disp('array not created, if you really')
	disp('want to make the array, please set')
	error('the override flag using arguments')
end

spacing_x = kerf_x + (2 * radius);
spacing_y = kerf_y + (2 * radius);

c_length=2*pi*r_curv;
if (nelex*spacing_x) > (c_length/2)
    xdcr_array=[];
    error('element warps onto itself, make r_curv larger or nele smaller')
end

dx=spacing_x/r_curv;

theta = (-(nelex-1)/2*dx):dx:((nelex-1)/2*dx);
y_coords = floor(-(neley-1)/2):floor((neley-1)/2);

for i=1:nelex
    for j=1:neley
        z = r_curv-r_curv*cos(theta(i));
        y = spacing_y*y_coords(j);
        x = r_curv*sin(theta(i));
        xdcr_array(i,j)=get_circ(radius,[x y z],[-theta(i) 0 0]);
    end
end
%draw_array(xdcr_array,'r');
