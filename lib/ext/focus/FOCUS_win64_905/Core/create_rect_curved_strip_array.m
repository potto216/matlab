function xdcr_array=create_rect_curved_strip_array(elements_x, elements_y, width, height, kerf, r_curv)
% xdcr_array=create_rect_curved_strip_array(elements_x, elements_y, width, height, kerf, r_curv)
% elements_x: Number of elements along the x-axis
% elements_y: Number of sub-elements in y
% width: The width of each element in meters
% height: The *total* height of each element (not sub-element) in meters
% kerf: Edge-to-edge space between elements in meters
% r_curv: The radius of curvature of the array in meters
%
% The curvature of cylinder is on the y axis, with elements rotating about the
% x axis. The center of the array is defined to be the center of the
% element anchoring the array.

xspacing = width + kerf;
x = (-(elements_x-1)/2)*xspacing:xspacing:((elements_x-1)/2)*xspacing;

dtheta = 2 * asin(height / 2 / r_curv) / elements_y;
z0 = sqrt(r_curv^2 - (height/2)^2); % the center of the array

theta = (-(elements_y-1)/2*dtheta):dtheta:((elements_y-1)/2*dtheta);
halfheight = sqrt(2 * r_curv^2 * (1 - cos(dtheta)))/2;
r0 = sqrt(r_curv^2 - halfheight^2); % distance from the center of the element to z0
% Note: the distance from the edge is r_curv
for ix = 1:length(x)
    for itheta = 1:length(theta)
        z = z0 - r0 * cos(theta(itheta));
        y = r0 * sin(theta(itheta));
        xdcr_array(ix,itheta)=get_rect(width, 2 * halfheight, [x(ix) y z], [0 theta(itheta) 0]);
    end
end
