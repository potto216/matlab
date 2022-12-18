function xdcr_array = create_rect_ssa(element_width, element_height, R, nrow, ang_open)
% Description
%   Creates a spherical section array of rectangular transducers.
% Usage
%   transducer = create_rect_ssa(width, height, R, nrow, ang_open); 
% Arguments
%   width: Width of a single element in meters, all elements in the array are the same size.
%   height: Height of a single element in meters, all elements in the array are the same size.
%   R: Radius of curvature of the array in m.
%   nrow: Number of elements in each direction.
%   ang_open: Spread of the array in each direction in radians.
% Output Parameters
%   transducer: An array of transducer structs.
% Notes
%   The array is defined such that the coordinate [0 0 0] corresponds to the center of the anchor element of the array.
if nrow==1
    xdcr_array=get_rect(element_width,element_height,[0 0 0],[0 0 0]);
    return
end

if nargin<2
    error('At least 2 input, create_rect_ssa(nrow,R,...)');
end

nele = nrow^2;
center = [0 0 R]; % center of spherical shell

%% default
if nargin<3
     ang_open = pi/4;
end
if  ang_open > pi/2
    fprintf('Bad design! Opening angle should be less than pi/2');
end

delta = ang_open*2/(nrow-1);
%% default
if nargin<4
    element_width = R*delta/2.5;
    element_height = element_width;
end

a = element_width/2;
b = element_height/2;
%% referecen rect patch at origin
rect(1,:) = [-a,b,0];
rect(2,:) = [a,b,0];
rect(3,:) = [a,-b,0];
rect(4,:) = [-a,-b,0];

%% reference row of element in x-z plane at z<0
theta = ((1.5*pi-ang_open):delta:(1.5*pi+ang_open))';
line0(:,1) = R*cos(theta);
line0(:,3) = R*sin(theta);
line0(:,2) = zeros(nrow,1);

%% Build patch for line0, don't draw
roty_ang = ang_open:(-delta):(-ang_open);
for i = 1:nrow
    for m=1:4
        rect_corners(m,:,i) = rotate_vector_forward(rect(m,:)-[0 0 R],[roty_ang(i) 0 0]);
    end
end

npitch = nrow;
rotx_ang = ang_open:(-delta):(-ang_open);
icount = 0;

figure(1)
%% Flip line0 along x axis
% k = 1;
for k = 1:npitch
    %% rotation line0 along x counterclockwise
    %% determine element center
    p((icount+1):(icount+nrow),:) = rotate_vector_forward(line0,[0 rotx_ang(k) 0]);
    p((icount+1):(icount+nrow),3) = p((icount+1):(icount+nrow),3) + R;
%     plot3(p((icount+1):(icount+nrow),1),p((icount+1):(icount+nrow),2),p((icount+1):(icount+nrow),3),'.');

    %% new patch
%     i = 1;
      for i = 1:nrow
        ang(icount+i,:) = [roty_ang(i) rotx_ang(k) 0];
        for m=1:4
            rect_corners_pitch(m,:) = rotate_vector_forward(rect_corners(m,:,i),[0 rotx_ang(k) 0]);
        end
%         patch(rect_corners_pitch(:,1),rect_corners_pitch(:,2),rect_corners_pitch(:,3)+R,'r');
%         rect_corners_pitch(:, 3) = rect_corners_pitch(:, 3) + R;
%         rect_corners_pitch
     end
    icount = icount+nrow;
end
% xlabel('x(cm)'); ylabel('y(cm)');

for m = 1:nele
    xdcr_array(m)  = get_rect(element_width,element_height,p(m,:),ang(m,:));
end
