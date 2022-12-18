function transducer = find_single_focus_phase(varargin)
% find_single_focus_phase will produce an array of complex_weight shifts to focus an array defined by xdcr_array at a 
% given point (x,y,z). The input arguments is the xdcr_array array, array parameters
% and the focal point. 
% Input parameters:
% xdcr_array - pointer to array aperture
% x   - x coordinate of the focus point, unit: m
% y   - y coordinate of the focus point, unit: m
% z   - z coordinate of the focus point, unit: m
% medium - defines the acoustic properties of the medium contains the fields: wb, rho, c, b,wavelen, atten, ct, kappa, beta
% f0 - center frequency of the array, unit: Hz
% ndiv - number of abscissas used for calculations, this parameter is
% optional, the default value is 200.
% linear_array - Whether to treat the array as a linear array, i.e. all
% array elements with the same x-coordinate will be focused together and
% have the same phase.
% Output parameters:
% transducer - pointer to array aperture
% This function alters the transducer struct, the output transducer should
% be the same as the input transducer (xdcr_array). The logic is that if all elements have a complex_weight of 0 at the target point,
% the intensity at the point is the highest

if nargin < 6 || nargin > 8
	error('This function requires at least 6 arguments. See the documentation for the correct usage.');
end

epsilon = 1e-15;

xdcr_array = varargin{1};
x = varargin{2};
y = varargin{3};
z = varargin{4};
medium = varargin{5};
f0 = varargin{6};

if nargin < 7
    ndiv = 200;
else
    ndiv = varargin{7};
end

if nargin < 8
    linear_array = 0;
else
    linear_array = varargin{8};
end

array_length = size(xdcr_array, 1);
array_height = size(xdcr_array, 2);

if nargin < 8
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
        uniform_elements = 1;
        if all_rect
            w = xdcr_array(1).width;
            h = xdcr_array(1).height;

            for ie = 1:array_length
                for je = 1:array_height
                    if xdcr_array(ie,je).height ~= h || xdcr_array(ie,je).width ~= w
                        uniform_elements = 0;
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
                    if max(abs(top_right_a - bottom_right_b)) > epsilon || max(abs(top_left_a - bottom_left_b)) > epsilon
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
                    if (max(abs(top_left_a - top_right_c)) < epsilon && max(abs(bottom_left_a - bottom_right_c)) < epsilon) || (max(abs(top_right_a - top_left_c)) < epsilon && max(abs(bottom_right_a - bottom_left_c)) < epsilon)
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

% This no longer works for some reason
%my_cg = set_coordinate_grid([x, y, z]);
my_cg = set_coordinate_grid([0 0 0], x, x, y, y, z, z);

if ~exist('ndiv')
    ndiv = 200;
end

if ndiv<20 
    ndiv=20;
end

% Calculate phases
complex_weight_vector = zeros(size(xdcr_array));
for ie=1:array_length
    for je = 1:array_height
        xdcr_array(ie,je).phase = 0;
        if ~linear_array
            complex_weight_vector(ie,je) = fnm_cw(xdcr_array(ie,je), my_cg, medium, ndiv, f0, 0);
        end
    end
    if linear_array
        complex_weight_vector(ie,:) = fnm_cw(xdcr_array(ie,:), my_cg, medium, ndiv, f0, 0);
    end
end

for ie=1:array_length
    for je = 1:array_height
        xdcr_array(ie,je).phase = -angle(complex_weight_vector(ie,je));
    end
end
transducer = xdcr_array;
