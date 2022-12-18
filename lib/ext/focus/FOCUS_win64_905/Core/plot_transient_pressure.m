function plot_transient_pressure(pressure, coord_grid, time_samples, plane, plot_type)
%plot_transient_pressure Open a new figure and display an animation of the
%transient pressure
%   pressure: A 4D transient pressure field
%   coord_grid: A FOCUS coordinate grid
%   time_samples: A FOCUS time samples struct
%   plane: The plane to display the pressure in. Valid values are 'xy',
%          'xz', and 'yz'.
%   plot_type: Type of plot to use. Valid values are 'mesh' and 'pcolor'.
%              This argument is optional.

% Determine whether correct number of args was passed
if nargin < 4 || nargin > 5
    error('Invalid number of arguments. Correct usage is plot_transient_pressure(pressure, time_samples, plane, plot_type).');
end
% Check for valid pressure
if size(size(pressure),2) ~= 4
    error('Pressure matrix must have 4 dimensions.');
end
% Check for valid coord_grid
if ~(isfield(coord_grid, 'delta') && isfield(coord_grid, 'xmin') && isfield(coord_grid, 'xmax') && isfield(coord_grid, 'ymin') && isfield(coord_grid, 'ymax') && isfield(coord_grid, 'zmin') && isfield(coord_grid, 'zmax'))
    error('Invalid coordinate grid. Please use set_coordinate_grid() to create this object.');
end
% Check for valid time_samples
if ~(isfield(time_samples, 'deltat') && isfield(time_samples, 'tmin') && isfield(time_samples, 'tmax'))
    error('Invalid time structure. Please use set_time_samples() to create this object.');
end
% Check for valid plane
if ~strcmpi(plane, 'xy') && ~strcmpi(plane, 'xz') && ~strcmpi(plane, 'yz')
    error('Invalid plane selection. Valid choices are xy, xz, and yz.');
end
% Check for valid plot type
if nargin == 4
    plot_type = 'mesh';
else
    if ~strcmpi(plot_type, 'pcolor') && ~strcmpi(plot_type, 'mesh')
        error('Invalid plot type. Valid values are pcolor and mesh.');
    end
end

% Plot pressure
t_vector = time_samples.tmin:time_samples.deltat:time_samples.tmax;
nt = length(t_vector);

x = coord_grid.xmin:coord_grid.delta(1):coord_grid.xmax;
y = coord_grid.ymin:coord_grid.delta(2):coord_grid.ymax;
z = coord_grid.zmin:coord_grid.delta(3):coord_grid.zmax;

% Determine which set of coordinates to use
if strcmp(plane, 'xz')
    a = x;
    b = z;
    alabel = 'x (m)';
    blabel = 'z (m)';
elseif strcmp(plane, 'yz')
    a = y;
    b = z;
    alabel = 'y (m)';
    blabel = 'z (m)';
else
    a = x;
    b = y;
    alabel = 'x (m)';
    blabel = 'y (m)';
end

maxpressure = max(max(max(max(pressure))));

figure();
for it=1:nt
    if strcmp(plane, 'xz')
        slice = squeeze(pressure(:,1,:,it));
    elseif strcmp(plane, 'yz')
        slice = squeeze(pressure(1,:,:,it));
    else
        slice = squeeze(pressure(:,:,1,it));
    end
    if strcmp(plot_type, 'pcolor')
        pcolor(a, b, slice);
        % Label axes
        xlabel(alabel);
        ylabel(blabel);
    else
        mesh(b, a, slice);
        % Scale axes
        temp=axis();
        temp(5)=-maxpressure;
        temp(6)=maxpressure;
        axis(temp);
        % Label axes
        xlabel(blabel);
        ylabel(alabel);
        zlabel('Pressure (Pa)');
    end
    % Add title
    title(sprintf('t = %04.2f us', t_vector(it) * 1e6));
    drawnow;
end

end
