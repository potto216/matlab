function xdcr_array=create_rect_convex_array(elements_x, sub_x, sub_y, width, height, kerf, r_curv)
% xdcr_array=create_rect_convex_array(elements_x, elements_y, width, height, kerf, r_curv)
% elements_x: Number of elements along the x-axis
% width: The width of each element in meters
% height: The *total* height of each element (not sub-element) in meters
% kerf: Edge-to-edge space between elements in meters
% r_curv: The radius of curvature of the array in meters
% sub_x: Number of sub-divisions in x-direction of elements.
% sub_y: Number of sub-divisions in y-direction of elements.

xspacing = width + kerf;

ele_x_divide_2 = ceil(elements_x/2)
odd_array=mod(elements_x,2);
for ix = 1:ele_x_divide_2
    %for iy = 1:length(elements_y) % currently only testing 1 element no subdivisions
    
        if ( odd_array ==1 )
            z   = r_curv * cos( (xspacing * (ix-1))  / r_curv);
            y   = 0;  % currently only testing 1 element no subdivisions
            x  = r_curv * sin(xspacing * (ix-1) / r_curv);
        else
            z   = r_curv * cos( (xspacing * (ix-1) + xspacing/2)  / r_curv); 
            y   = 0;  % currently only testing 1 element no subdivisions
            x  = r_curv * sin( (xspacing * (ix-1) + xspacing/2) / r_curv);
        end
        
        td = atan( x /z);  % calcuate euler
        z = z - r_curv;    % subtract height of curve to start transducer at "0"
         
        if ((odd_array == 1) && (ix == 1))
            xdcr_array(ele_x_divide_2,1)=get_rect(width, height, [ x y z], [td 0 0]);
        elseif (odd_array == 1)
            xdcr_array(ele_x_divide_2-1+ix,1)=get_rect(width, height, [ x y z], [td 0 0]);
            xdcr_array(ele_x_divide_2+1-ix,1)=get_rect(width, height, [ -x y z], [-td 0 0]);
        else
            xdcr_array(ele_x_divide_2+ix,1)=get_rect(width, height, [ x y z], [td 0 0]);
            xdcr_array(ele_x_divide_2+1-ix,1)=get_rect(width, height, [ -x y z], [-td 0 0]);
        end
    %end
end
