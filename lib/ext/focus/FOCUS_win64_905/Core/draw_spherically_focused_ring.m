function draw_spherically_focused_ring(xdcr, color)
%DRAW_SPHERICALLY_FOCUSED_RING Draw a spherically focused ring
% this is an internal function and should not be called
% put in a spherical transducer, get a nice pic
% axis MUST be defined prior to calling this function
% otherwise, matlab will screw something up;
% also, make sure hold on is active before calling.
% otherwise, this will replace the current image.
% n= number of points per xdcr, more = slower and better
n=40; %higher n=smoother circles, slower function;

inner_radius=xdcr.inner_radius;
outer_radius=xdcr.outer_radius;
radius_curvature=xdcr.geometric_focus;
thetamax=asin(outer_radius/radius_curvature);
thetamin=asin(inner_radius/radius_curvature);
theta=linspace(thetamin,thetamax,n);
phi=linspace(0,2*pi,n)';

drawx=real(radius_curvature*cos(phi)*sin(theta));
drawy=real(radius_curvature*sin(phi)*sin(theta));
drawz=real(-radius_curvature*ones(1,n)'*cos(theta));
drawz=drawz-max(max(drawz));
coordinates = [drawx(:) drawy(:) drawz(:)];
coordinates = trans_rot(coordinates,[xdcr.center(1) xdcr.center(2) xdcr.center(3)],[xdcr.euler(1) xdcr.euler(2) xdcr.euler(3)],1);
% Reshape coordinates
drawx = reshape(coordinates(:,1), size(drawx));
drawy = reshape(coordinates(:,2), size(drawy));
drawz = reshape(coordinates(:,3), size(drawz));

color = [zeros(1,64)' linspace(0,1,64)' zeros(1,64)'];

surf(drawx, drawy, drawz);
shading flat;
%set(hSurface,'FaceColor',color,'FaceAlpha',1);
colormap(color);
end