function coordinate_grid=set_center_coordinate_grid(delta,x,y,z,nx,ny,nz)
% Description
%   Creates a coordinate grid centered at the given point.
% Usage
%   cg = set_center_coordinate_grid(delta, x, y, z, nx, ny, nz);  
% Arguments
%   delta: An integer or vector ([dx dy dz]) representing the difference between two points in the grid.
%   x: The x coordinate of the center of the grid.
%   y: The y coordinate of the center of the grid.
%   z: The z coordinate of the center of the grid.
%   nx: The number of points in the x direction of the grid.
%   ny: The number of points in the y direction of the grid.
%   nz: The number of points in the z direction of the grid.
% Output Parameters
%   cg: A coordinate grid struct with the given center.
% Notes
%   If nx, ny, or nz is set to one, there will be no points in that direction of the grid, resulting in a coordinate plane or coordinate line instead of a 3-d grid.
if length(delta)==1
    delta(2)=delta(1);
    delta(3)=delta(1);
end
xmin=x-delta(1)*nx/2;
xmax=x+delta(1)*nx/2;
ymin=y-delta(2)*ny/2;
ymax=y+delta(2)*ny/2;
zmin=z-delta(3)*nz/2;
zmax=z+delta(3)*nz/2;
if (nx==1)
    xmin=x;
    xmax=x;
end
if (ny==1)
    ymin=y;
    ymax=y;
end
if(nz==1)
    zmin=z;
    zmax=z;
end
coordinate_grid=set_coordinate_grid(delta,xmin,xmax,ymin,ymax,zmin,zmax);
