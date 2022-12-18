function draw_sphericalshell_with_hole(xdcr,color)
% this is an internal function and should not be called
% put in a spherical transducer, get a nice pic
% axis MUST be defined prior to calling this function
% otherwise, matlab will screw something up;
% also, make sure hold on is active before calling.
% otherwise, this will replace the current image.
% n= number of points per xdcr, more = slower and better
n=20; %higher n=smoother circles, slower function;

radius=xdcr.radius(1);
hole_radius=xdcr.hole_radius(1);
radius_curvature=xdcr.rad_curvature(1);
thetamax=asin(radius/radius_curvature);
thetamin=asin(hole_radius/radius_curvature);
theta=linspace(thetamin,thetamax,n);
phi=linspace(0,2*pi,n)';

drawx=radius_curvature*cos(phi)*sin(theta);
drawy=radius_curvature*sin(phi)*sin(theta);
drawz=-radius_curvature*ones(1,n)'*cos(theta);
drawz=drawz-max(max(drawz));
% fill3(drawx,drawy,drawz,color);
surf(drawx,drawy,drawz);
end
