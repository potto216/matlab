function coord_struct = set_coordinate_grid(varargin)
% Description
%   Creates a coordinate grid data structure used by FOCUS for various calculations.
% Usage
%   grid = set_coordinate_grid();
%   grid = set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);
%   grid = set_coordinate_grid(x_coords, y_coords, z_coords);
%   grid = set_coordinate_grid(vector);  
% Arguments
%   delta: The difference between two data points in a coordinate direction. Should be a matrix of the form [ dx dy dz ].
%   xmin: The lowest x plane.
%   xmax: The highest x plane.
%   ymin: The lowest y plane.
%   ymax: The highest y plane.
%   zmin: The lowest z plane.
%   zmax: The highest z plane.
%   x_coords: A list of x coordinates.
%   y_coords: A list of y coordinates.
%   z_coords: A list of z coordinates.
%   vector: a list of coordinates in [ [x1 y1 z1]; [x2 y2 z2];...] notation.
% Output Parameters
%   grid: A coordinate grid struct that can be used by FNM functions.
% Notes
%   If x_coords, y_coords, and z_coords are provided, each point is defined as point(i) = [ x_coords(i) y_coords(i) z_coords(i) ]. If no arguments are provided, the user will be prompted to enter delta, xmin, xmax, ymin, ymax, zmin, and zmax.
if nargin()==0, % manual input
	disp('Enter the following values:')
	disp('delta, xmin, xmax, ymin, ymax, zmin,zmax')
	disp('delta can be a 1x1 or a 1x3 vector')
    
	delta=input('delta: ');
	xmin=input('xmin: ');
	xmax=input('xmax: ');
	ymin=input('ymin: ');
	ymax=input('ymax: ');
    zmin=input('zmin: ');
    zmax=input('zmax: ');
    
	coord_struct = set_coordinate_grid(delta,xmin,xmax,ymin,ymax,zmin,zmax);
	
elseif nargin()==7,    
    coord_struct.delta=varargin{1};
    coord_struct.xmin=varargin{2};
    coord_struct.xmax=varargin{3};
    coord_struct.ymin=varargin{4};
    coord_struct.ymax=varargin{5};
    coord_struct.zmin=varargin{6};
    coord_struct.zmax=varargin{7};
    coord_struct.regular_grid = 1; % regular grid with equally spaced x y z coordinates
%    coord_struct.vector=[];
%    coord_struct.polar=-1;
%    coord_struct.spherical=-1;
    
    if coord_struct.delta(1)<0,
        error('delta cannot be <0')
    end
    
    if length(coord_struct.delta)==1,
    	coord_struct.delta(2)=coord_struct.delta(1);
    	coord_struct.delta(3)=coord_struct.delta(1);
    end
    
    if length(coord_struct.xmin)>1,
        error('length(xmin) > 1');
    elseif length(coord_struct.xmax)>1,
        error('length(xmax) > 1');
    elseif length(coord_struct.ymin)>1,
        error('length(ymin) > 1');
    elseif length(coord_struct.ymax)>1,
        error('length(ymax) > 1');
    elseif length(coord_struct.zmin)>1,
        error('length(zmin) > 1');
    elseif length(coord_struct.zmax)>1,
        error('length(zmax) > 1');
    end

    if (coord_struct.xmin > coord_struct.xmax) || (coord_struct.ymin > coord_struct.ymax) || (coord_struct.zmin > coord_struct.zmax),
        error('min coord value must be <= max coord value')
    end

% to check if there is an accidental divide by zero error downstream, force
% dx, dy, dz = 0 when there is only one sample in that direction
    if coord_struct.xmin == coord_struct.xmax,
        coord_struct.delta(1) = 0;
    end
    if coord_struct.ymin == coord_struct.ymax,
        coord_struct.delta(2) = 0;
    end
    if coord_struct.zmin == coord_struct.zmax,
        coord_struct.delta(3) = 0;
    end
    
elseif nargin()==1, % matrix containing the x, y, z coordinates
%    coord_struct.delta(1:3)=0;
%    coord_struct.xmin=0;
%    coord_struct.xmax=0;
%    coord_struct.ymin=0;
%    coord_struct.ymax=0;
%    coord_struct.zmin=0;
%    coord_struct.zmax=0;
%    coord_struct.vector_flag=1;
    coordinate_matrix = varargin{1};
    if length(size(coordinate_matrix)) ~= 2,
        error('expecting a 2D matrix containing (x, y, z) coordinates in ''set_coordinate_grid'',\n but instead a %dD matrix was provided', length(size(coordinate_matrix)) )
    elseif size(coordinate_matrix, 1) ~= 3 && size(coordinate_matrix, 2) ~= 3,
        error('expecting an Nx3 or a 3xN matrix containing (x, y, z) coordinates in ''set_coordinate_grid'',\n but instead the matrix was %d by %d', size(coordinate_matrix, 1),  size(coordinate_matrix, 2))
    end
    
    coord_struct.regular_grid = 0; % not a regular grid
    coord_struct.coordinates = coordinate_matrix;
% other coordinate systems are not presently supported (cartesian only at
% present)
%    coord_struct.polar=-1;
%    coord_struct.spherical=-1;
    
elseif nargin()==3, % x, y, z are the arguments (each as vectors)
%    coord_struct.delta(1:3)=0;
%    coord_struct.xmin=0;
%    coord_struct.xmax=0;
%    coord_struct.ymin=0;
%    coord_struct.ymax=0;
%    coord_struct.zmin=0;
%    coord_struct.zmax=0;
%    coord_struct.vector_flag=1;
    xvector = varargin{1};
    yvector = varargin{2};
    zvector = varargin{3};
    if length(xvector) ~= length(yvector) || length(yvector) ~= length(zvector),
        error(' xvector, yvector, and zvector need to be the same length in ''set_coordinate_grid'',\n but length(xvector) = %d, length(yvector) =  %d, and length(zvector) =  %d', length(varargin{1}), length(varargin{2}), length(varargin{3}) )
    end
    
    xfind = find(diff(xvector) <= 0);
    yfind = find(diff(yvector) <= 0);
    zfind = find(diff(zvector) <= 0);

    if ~isempty(xfind),
        error('expecting strictly increasing values for xvector in ''set_coordinate_grid''\n, but the values decreased at index %d and in %d other location(s)\n xvector failed, so yvector and zvector were not tested', xfind(1) + 1, length(xfind) - 1)
    elseif ~isempty(yfind),
        error('expecting strictly increasing values for yvector in ''set_coordinate_grid''\n, but the values decreased at index %d and in %d other location(s)\n xvector passed, but yvector failed, and zvector was not tested', yfind(1) + 1, length(yfind) - 1)
    elseif ~isempty(zfind),
        error('expecting strictly increasing values for zvector in ''set_coordinate_grid''\n, but the values decreased at index %d and in %d other location(s)\n xvector and yvector passed, but zvector failed', zfind(1) + 1, length(zfind) - 1)
    end
    
    coord_struct.regular_grid = 0; % not a regular grid
    coord_struct.coordinates=[varargin{1}; varargin{2}; varargin{3}]';
% other coordinate systems are not presently supported (cartesian only at
% present)
%    coord_struct.polar=-1;
%    coord_struct.spherical=-1;
    
else
    error('incorrect number of arguments for ''set_coordinate_grid''\n  expecting 0, 1, 3, or 7 input arguments, but %d given', nargin())
end
