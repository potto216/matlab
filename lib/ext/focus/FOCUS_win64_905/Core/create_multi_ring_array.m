function xdcr_array = create_multi_ring_array(elements,widths,radii)
% elements: Number of elements in each array (a vector)
% widths: The width/height of each element in meters for each array
%(a vector)
% radii: The radius of each circle in meters (a vector)
    if nargin == 0
        disp('Please enter the following arguments:')
        disp('elements (a vector), widths (a vector), radii (a vector)')
        elements=input('elements:');
        widths=input('widths:');
        radii=input('radii:');
    end
    elements_len = length(elements);
    widths_len = length(widths);
    radii_len = length(radii);
    if (elements_len ~= widths_len) || (widths_len ~= radii_len)
       error('Vector lengths do not match') 
    end
    for i = 1:elements_len
        circumference = 2*pi*radii(i);
        total_width = widths(i)*elements(i);
        if total_width > circumference
            error(['Elements are going to overlap '...
            'Decrease the number of elements and or the width,' ...
            ' or increase the radius.'])
        end
        theta_factor = 360/elements(i);
        theta = 0;
        x = radii(i) + widths(i)/2;
        y = 0;
        z = 0;
        xdcr_array(i,1)=get_rect(widths(i),widths(i),[x y z],[0 0 sind(theta)]);
        if elements > 1
            for j = 2:elements(i)
                theta = theta + theta_factor;
                y = radii(i) + widths(i)/2;
                x = radii(i) + widths(i)/2;
                x = x*cosd(theta);
                y = y*sind(theta);
                td = atan(y/x);
                x = x;
                y = y;
                z = 0;
                xdcr_array(i,j)=get_rect(widths(i),widths(i),[x y z],[0 0 td]);
            end
        end
    end
end