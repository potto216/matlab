function xdcr_array = create_ring_array(elements,width,radius)
% elements: Number of elements in the array
% width: The width/height of each element in meters
% radius: The radius of the circle in meters
    if nargin == 0
        disp('Please enter the following arguments:')
        disp('elements, width, radius')
        elements=input('elements:');
        width=input('width:');
        radius=input('radius:');
    end
    circumference = 2*pi*radius;
    total_width = width*elements;
    if total_width > circumference
        error(['Elements are going to overlap '...
        'Decrease the number of elements and or the width,' ...
        ' or increase the radius.'])
    end
    theta_factor = 360/elements;
    theta = 0;
    x = radius + width/2;
    y = 0;
    z = 0;
    xdcr_array(1)=get_rect(width,width,[x y z],[0 0 sind(theta)]);
    if elements > 1
        for i = 2:elements
            theta = theta + theta_factor;
            y = radius + width/2;
            x = radius + width/2;
            x = x*cosd(theta);
            y = y*sind(theta);
            td = atan(y/x);
            xdcr_array(i)=get_rect(width,width,[x y z],[0 0 td]);
        end
    end
end