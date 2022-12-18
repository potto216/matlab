function transducer = set_time_delays(varargin)
% Description
%   Determine the time delays required to focus a transducer array at a given point. Time delays calculated with set_time_delays may fall between temporal samples unless the sampling frequency is provided, in which case the delays are shifted to fit the temporal grid (digitized) rather than being allowed to fall between temporal samples.
% Usage
%   transducer = set_time_delays(transducer, x, y, z, medium);
%   transducer = set_time_delays(transducer, x, y, z, medium, fs);
%   transducer = set_time_delays(transducer, x, y, z, medium, fs, linear_array);
%   transducer = set_time_delays(transducer, delays);
% Arguments
%   transducer: A transducer array, e.g. one created by create_circ_csa.
%   x: The x coordinate of the focus.
%   y: The y coordinate of the focus.
%   z: The z coordinate of the focus.
%   medium: A medium struct.
%   fs: Optional sampling frequency in Hz. If provided, digitized time delays will be used.
%   linear_array - Whether to treat the array as a linear array, i.e. all
%   array elements with the same x-coordinate will be focused together and
%   have the same phase.
%   delays: The time delays to assign to the individual array elements such
%   that the time delay of element n = delays(n)
% Output Parameters
%   transducer: The input transducer array with adjusted time delays.
% Notes
%   This function alters the transducer struct, the output transducer should be the same as the input transducer (transducer).

if nargin ~= 2 && nargin < 5 || nargin > 7
	error('This function requires at least 5 and no more than 7 arguments. See the documentation for the correct usage.')
end

% Assign argument values
xdcr_array = varargin{1};
if nargin == 2
    delays = varargin{2};
else
    x = varargin{2};
    y = varargin{3};
    z = varargin{4};
    medium = varargin{5};
    linear_array = 0;
end

array_length = size(xdcr_array,1);
array_height = size(xdcr_array,2);

if nargin >= 6
    fs = varargin{6};
else
    fs = 0;
end

if nargin == 7
    linear_array = varargin{7};
elseif nargin == 2
    if array_length*array_height ~= length(delays)
        error('The number of time delays must be equal to the number of transducers.')
    else
        for i = 1:array_length*array_height
            xdcr_array(i).time_delay = delays(i);
        end
        transducer = xdcr_array;
        return;
    end
else
    % Test whether or not the array contains sub-elements that must be
    % focused together
    % A 1-d array can't have sub-elements
    if array_height > 1
        % Neither can an array with non-rectangular elements
        all_rect = 1;
        for ie = 1:array_length
            for je = 1:array_height
                if ~strcmp(xdcr_array(ie,je).shape,'rect')
                    all_rect = 0;
                    ie = array_length;
                    je = array_height;
                end
            end
        end
        
        % The array elements must also be the same size
        uniform_elements = 0;
        if all_rect
            w = xdcr_array(1).width;
            h = xdcr_array(1).height;

            for ie = 1:array_length
                for je = 1:array_height
                    if xdcr_array(ie,je).height ~= h || xdcr_array(ie,je).width ~= w
                        uniform_elements = 1;
                    end
                end
            end
        end
        
        % If all transducers are rectangular, check for common edges
        if all_rect && uniform_elements
            warning('Focusing method not specified. Will attempt to determine whether array contains sub-elements.');
            % Check along y-axis
            linear_array = 1;
            for ie=1:array_length-1
                for je=1:array_height-1
                    
                    fprintf(' (%i,%i) / (%i,%i)\n', ie, je, array_length, array_height);
                    
                    % Get element width and height (assumes all elements are the same)
                    width = xdcr_array(ie,je).width;
                    height = xdcr_array(ie,je).height;
                    % Calculate coordinates of the element edges
                    center = xdcr_array(ie,je).center;
                    center_above = xdcr_array(ie,je+1).center;
                    center_right = xdcr_array(ie+1,je).center;
                    euler = xdcr_array(ie,je).euler;
                    euler_above = xdcr_array(ie,je+1).euler;
                    euler_right = xdcr_array(ie+1,je).euler;
                    % Get corner coordinates for the first element assuming center at [0 0 0]
                    corners_x=[-width/2 width/2 width/2 -width/2];
                    corners_y=[height/2 height/2 -height/2 -height/2];
                    corners_z=zeros(1,4);
                    % Translate and rotate coordinates to global coord system
                    coord_grid=[corners_x(:) corners_y(:) corners_z(:)];
                    coord_grid=trans_rot(coord_grid,center,euler,1);
                    % Get the top edge of the first transducer
                    top_left_a = [coord_grid(1,1) coord_grid(1,2) coord_grid(1,3)];
                    top_right_a = [coord_grid(2,1) coord_grid(2,2) coord_grid(2,3)];
                    bottom_left_a = [coord_grid(4,1) coord_grid(4,2) coord_grid(4,3)];
                    bottom_right_a = [coord_grid(3,1) coord_grid(3,2) coord_grid(3,3)];
                    
                    % Repeat for the element above
                    coord_grid=[corners_x(:) corners_y(:) corners_z(:)];
                    coord_grid=trans_rot(coord_grid,center_above,euler_above,1);
                    % Get the bottom edge
                    top_left_b = [coord_grid(1,1) coord_grid(1,2) coord_grid(1,3)];
                    top_right_b = [coord_grid(2,1) coord_grid(2,2) coord_grid(2,3)];
                    bottom_left_b = [coord_grid(4,1) coord_grid(4,2) coord_grid(4,3)];
                    bottom_right_b = [coord_grid(3,1) coord_grid(3,2) coord_grid(3,3)];
                    
                    % Repeat for the element to the right
                    coord_grid=[corners_x(:) corners_y(:) corners_z(:)];
                    coord_grid=trans_rot(coord_grid,center_right,euler_right,1);
                    % Get the bottom edge
                    top_left_c = [coord_grid(1,1) coord_grid(1,2) coord_grid(1,3)];
                    top_right_c = [coord_grid(2,1) coord_grid(2,2) coord_grid(2,3)];
                    bottom_left_c = [coord_grid(4,1) coord_grid(4,2) coord_grid(4,3)];
                    bottom_right_c = [coord_grid(3,1) coord_grid(3,2) coord_grid(3,3)];
                    
                    % If bottom and top aren't a common edge, these are not sub-elements
                    if max(abs(top_right_a - bottom_right_b)) > eps || max(abs(top_left_a - bottom_left_b)) > eps
                        linear_array = 0;
                        break;
                    end
                    
                    % On the other hand, if the left and right edges are
                    % also common, these are not sub-elements
                    disp('corners:');
                    disp(top_left_a);
                    disp(top_right_a);
                    disp(bottom_right_a);
                    disp(bottom_left_a);
                    
                    disp('corners above:');
                    disp(top_left_b);
                    disp(top_right_b);
                    disp(bottom_right_b);
                    disp(bottom_left_b);
                    
                    disp('corners right:');
                    disp(top_left_c);
                    disp(top_right_c);
                    disp(bottom_right_c);
                    disp(bottom_left_c);
                    
                    disp(top_left_a - top_right_b);
                    disp(top_right_a - top_left_b);
                    
                    % If the element to the right shares an edge, the array
                    % does not have sub-elements
                    if (max(abs(top_left_a - top_right_c)) < eps && max(abs(bottom_left_a - bottom_right_c)) < eps) || (max(abs(top_right_a - top_left_c)) < eps && max(abs(bottom_right_a - bottom_left_c)) < eps)
                        linear_array = 0;
                        break;
                    end
                end
                
                if ~linear_array
                    break;
                end
            end
            
            % The linear elements must also have the same amplitudes,
            % phases, and time delays
            if linear_array
                a = xdcr_array(1).amplitude;
                p = xdcr_array(1).phase;
                t = xdcr_array(1).time_delay;
                
                for ie = 1:array_length
                    for je = 1:array_height
                        if xdcr_array(ie,je).amplitude ~= a || xdcr_array(ie,je).phase ~= p || xdcr_array(ie,je).time_delay ~= t
                            linear_array = 0;
                            break;
                        end
                    end
                    if ~linear_array
                        break;
                    end
                end
            end
            
            % Tell the user how the array will be treated
            if linear_array
                warning('Common edges detected; focusing as subelements in y. To disable this message, specify how to focus the array.');
            else
                warning('No common edges detected or common edges detected in two dimensions; focusing as individual elements. To disable this message, specify how to focus the array.');
            end
        end
    end
end

% Use zero time delay for a single element
if array_length*array_height == 1
   warning('single element: the time delay has been set to 0');
   xdcr_array.time_delay=0;
   transducer = xdcr_array;
   return;
end

speedofsound = medium.soundspeed;
timevector = zeros(array_length, array_height);
% Calculate the time delays
if linear_array
    for ie = 1:array_length
        % If the array height is odd, use the center of the central element
        if mod(array_height,2) == 1
            elementcenter = xdcr_array(ie,ceil(array_height/2)).center;
        % If the height is even, use the mean of the centers of the two
        % central elements
        else
            elementcenter = (xdcr_array(ie,array_height/2).center + xdcr_array(ie,array_height/2+1).center)/2;
        end
        if abs(xdcr_array(ie,1).amplitude) > eps
            timevector(ie,:) = sqrt((elementcenter(1) - x)^2 + (elementcenter(2) - y)^2 + (elementcenter(3) - z)^2)/ speedofsound;
        else
            timevector(ie,:) = 0;
        end
    end
else
    for ie = 1:array_length
        for je = 1:array_height
            elementcenter = xdcr_array(ie,je).center;
            if abs(xdcr_array(ie,je).amplitude) > eps
                timevector(ie,:) = sqrt((elementcenter(1) - x)^2 + (elementcenter(2) - y)^2 + (elementcenter(3) - z)^2)/ speedofsound;
            else
                timevector(ie,:) = 0;
            end
        end
    end
end
% time reverse to focus and also make all time delays positive or zero
timevector = max(max(timevector)) - timevector;

% Digitize time delays if sample frequency is provided
if fs > 0
    timevector = round(timevector * fs) / fs;
end
% Store the time delays in the structure
for ie = 1:array_length
    for je = 1:array_height
        xdcr_array(ie,je).time_delay = timevector(ie,je);
    end
end
transducer = xdcr_array;
