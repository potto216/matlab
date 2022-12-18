clc;
fprintf('==============================[ ASALayeredMedia.m ]===============================\n\n');
fprintf('This script calculates the pressure profile of a 32-element array under continuous-\n');
fprintf('wave excitation through layered media. The first layer extends from the face of the\n');
fprintf('array and ends at z = 12mm. The second layer extends from z = 12mm to infinity.\n\n');
fprintf(' *** To run this example you must add the "Testing" folder to your MATLAB path ***\n\n');

% Set up the array
ele_x = 32;
ele_y = 1;
width = 0.245e-3;
height = 7e-3;
kerf_x = 0.03e-3;
kerf_y = 0;

xdcr_array = create_rect_planar_array(ele_x, ele_y, width, height, kerf_x, kerf_y);

% Use a layered medium
medium = set_layered_medium([0,12e-3],[set_medium('water'),set_medium('fat')]);

% Center frequency and wavelength
f0 = 1e6;
lambda = medium(1).soundspeed/f0;

% Set up the coordinate grid
xmin = -((ele_x/2) * (width+kerf_x))*1.5;
xmax = -xmin;
ymin = -((ele_y/2) * (height+kerf_y))*1.5;
ymax = -ymin;
zmin = 0;
zmax = 40*lambda;

focus_x = 0;
focus_y = 0;
focus_z = 20 * lambda;

dx = lambda/8;
dy = lambda/8;
dz = lambda/8;

x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

% Determine where the source pressure will be calculated
z0 = lambda/4;
y_index = floor((ymax-ymin)/2/dy);

cg_p0 = set_coordinate_grid([dx dy 1], xmin,xmax,ymin,ymax,z0,z0);
cg_z = set_coordinate_grid([dx 1 dz],xmin,xmax,0,0,zmin,zmax);

% Focus the array
xdcr_array = find_single_focus_phase(xdcr_array,focus_x,focus_y,focus_z,medium,f0,200);

% Calculate the pressure
ndiv = 10;
fprintf('Calculating p0 with FNM... ');
tic();
p0 = cw_pressure(xdcr_array,cg_p0,medium,ndiv,f0);
fprintf('done in %f s.\n', toc());

fprintf('Calculating 3D pressure (%i points) with ASA... ', (length(x) * length(y) * length(z)));
tic();
p_asa = layerasa(p0,z,medium,1024,dz,f0);
fprintf('done in %f s.\n', toc());

figure(1);
pcolor(x*1000, y*1000, rot90(abs(squeeze(p0(:,:,1)))));
xlabel('x (mm)');
ylabel('y (mm)');
shading flat;
title(['p0 (Calculated with FNM at z = ', num2str(z0*1000), ' mm)']);

figure(2);
pcolor(z*1000, x*1000, abs(squeeze(p_asa(:,y_index,:))));
xlabel('z (mm)');
ylabel('x (mm)');
shading flat;
title('ASA Pressure (y=0)');
