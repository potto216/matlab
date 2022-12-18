function xdcr_array =create_circ_ssa(radius,R,nrow,ang_open)
% Description
%     This function creates a spherical section array of circular transducers.
% Usage
%     transducer = create_circ_ssa(radius, R, nrow, ang_open); 
% Arguments
%     radius: Radius each element in m. All elements in the array will be the same size.
%     R: Radius of curvature of the array in m.
%     nrow: Number of elements in each direction.
%     ang_open: Spread of the array in each direction in radians.
% Output Parameters
%     transducer: An array of transducer structs.
% Notes
%     The array is defined such that the coordinate [0 0 0] corresponds to the center of the anchor element of the array.

if nrow==1
    xdcr_array=get_circ(radius,[0 0 0],[0 0 0]);
    return
end 
if nargin<2
    error('At least 2 input, create_circ_ssa(nrow,R,...)');
end

nele = nrow^2;
center = [0 0 R]; % center of spherical shell
width=radius*2;
height=radius*2;


delta = ang_open*2/(nrow-1);
%% default
a = width/2;
b = height/2;

%% reference rect patch at origin
rect(1,:) = [-a,b,0];
rect(2,:) = [a,b,0];
rect(3,:) = [a,-b,0];
rect(4,:) = [-a,-b,0];

%% reference row of element in x-z plane at z<0
theta = ((1.5*pi-ang_open):delta:(1.5*pi+ang_open));
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

% figure, hold on,

npitch = nrow;
rotx_ang = ang_open:(-delta):(-ang_open);
icount = 0;

%% Flip line0 along x axis
for k = 1:npitch
    %% rotation line0 along x counterclockwise
    %% determine element center
    p((icount+1):(icount+nrow),:) = rotate_vector_forward(line0,[0 rotx_ang(k) 0]);
    p((icount+1):(icount+nrow),3) = p((icount+1):(icount+nrow),3) + R;
%     plot3(p((icount+1):(icount+nrow),1),p((icount+1):(icount+nrow),2),p((icount+1):(icount+nrow),3),'.');

    %% new patch
    for i = 1:nrow
        ang(icount+i,:) = [roty_ang(i) rotx_ang(k) 0];
        for m=1:4
            rect_corners_pitch(m,:) = rotate_vector_forward(rect_corners(m,:,i),[0 rotx_ang(k) 0]);
        end
%         patch(rect_corners_pitch(:,1),rect_corners_pitch(:,2),rect_corners_pitch(:,3)+R,'r');
    end
    icount = icount+nrow;
end
% xlabel('x(cm)'); ylabel('y(cm)');

for m = 1:nele
    xdcr_array(m) = get_circ(radius,p(m,:),ang(m,:));
end
end



