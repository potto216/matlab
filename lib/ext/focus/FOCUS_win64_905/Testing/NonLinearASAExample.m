clc;
fprintf('==============================[ NonLinearASAExample.m ]=============================\n\n');
fprintf('This script calculates the pressure profile of a 128-element array of rectangular\n');
fprintf('transducers by using the Angular Spectrum Approach to propagate an initial field\n');
fprintf('calculated with the Fast Nearfield Method and compute the 3D pressure profile of\n');
fprintf('the array. The script produces two plots: the initial FNM pressure and the\n');
fprintf('pressure in the x-z plane as calculated with the ASA.\n\n');
fprintf(' *** To run this example you must add the "Testing" folder to your MATLAB path ***\n\n');

width = 1e-3;
height = 7e-3;
xdcr = get_rect(width,height);

medium = set_medium('liver');
medium.nonlinearityparameter = 7.48;
medium.powerlawexponent = 5;

f0 = 1e6;
lambda = medium.soundspeed / f0;

nx = 300;
ny = nx;
nz = 100;

xmin = -6e-3;
xmax = 6e-3;
ymin = -6e-3;
ymax = 6e-3;
zmin = lambda/4;
zmax = 5e-2;

dx = (xmax - xmin)/nx;
dy = (ymax - ymin)/ny;
dz = (zmax - zmin)/nz;

x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

p0_coords = set_coordinate_grid([dx dy 1], xmin, xmax, ymin, ymax, 0, 0);
coords = set_coordinate_grid([dx dy dz], xmin, xmax, ymin, ymax, zmin, zmax);

p0 = cw_pressure(xdcr, p0_coords, medium, 200, f0);
tic();
p_asa = nonlinasa(p0*sqrt(2*(1/(width*height))/(medium.density*medium.soundspeed)),z,medium,512,dx,'p',f0,10,1);
fprintf('ASA calculation complete in %f s\n', toc());

figure(1);
pcolor(x*1000, y*1000, rot90(abs(squeeze(p0))));
xlabel('x (mm)');
ylabel('y (mm)');
shading flat;

figure(2);
pcolor(z*1000, x*1000, abs(squeeze(p_asa(:,ny/2,:))));
xlabel('z (mm)');
ylabel('x (mm)');
shading flat;