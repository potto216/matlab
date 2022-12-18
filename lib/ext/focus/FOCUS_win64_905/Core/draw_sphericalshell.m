function draw_sphericalshell(xdcr,color)
% this is an internal function and should not be called
% put in a spherical transducer, get a nice pic
% axis MUST be defined prior to calling this function
% otherwise, matlab will screw something up;
% also, make sure hold on is active before calling.
% otherwise, this will replace the current image.
% n= number of points per xdcr, more = slower and better
n=200; %higher n=smoother circles, slower function;

x=xdcr.center(1);
y=xdcr.center(2);
z=xdcr.center(3);

radius=xdcr.radius;
radius_curvature=xdcr.rad_curvature;
thetamax=asin(radius/radius_curvature);
theta=linspace(0,thetamax,n);
phi=linspace(0,2*pi,n)';

drawx=radius_curvature*cos(phi)*sin(theta);
drawy=radius_curvature*sin(phi)*sin(theta);
drawz=-radius_curvature*ones(1,n)'*cos(theta) + radius_curvature;

for i=1:n
    cord_grid=[drawx(:,i) drawy(:,i) drawz(:,i)];
    cord_grid=trans_rot(cord_grid,[x y z],[xdcr.euler(1) xdcr.euler(2) xdcr.euler(3)],1);
    drawx(:,i)=cord_grid(:,1);
    drawy(:,i)=cord_grid(:,2);
    drawz(:,i)=cord_grid(:,3);
end

%color = [zeros(1,64)' linspace(0,1,64)' zeros(1,64)'];
% Create a colormap
if size(color) ~= [1 3]
    color = [0 1 0];
end
color = [linspace(0,1,64)'*color(1) linspace(0,1,64)'*color(2) linspace(0,1,64)'*color(3)];

surf(drawx,drawy,drawz, 'linestyle', 'none');
if strcmp(color,'gray')
    colormap(gray);
else
    colormap(color);
end

xborder = radius * cos(phi);
yborder = radius * sin(phi);
zborder = - ones(size(phi)) * sqrt(radius_curvature^2 - radius^2) + radius_curvature;

nborder = length(xborder);

for i=1:nborder,
   outputvector=trans_rot([xborder(i) yborder(i) zborder(i)],[x y z],[xdcr.euler(1) xdcr.euler(2) xdcr.euler(3)],1);
    xborder(i) = outputvector(1);
    yborder(i) = outputvector(2);
    zborder(i) = outputvector(3);
end
plot3(xborder, yborder, zborder, 'k')

end
