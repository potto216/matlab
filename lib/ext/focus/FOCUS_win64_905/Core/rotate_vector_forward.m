function newp = rotate_vector_forward(p,e_euler)
% Rotate from local to global coordinates, different from Jim's rotate.c
% Rotate the object, not axes
% Positive angle if rotation is counterclockwise looking into origin
% Useful for drawing routines
% p - NX3 matrix contains coordinates of the points
% e_euler contains rotation angles along original [y,x,z] axis

[nrow,ncol] = size(p);
if ncol ~= 3
    error('p has to be NX3 matrix');
end
theta = e_euler(1); % rotation about Y axis
psi = e_euler(2); % roation about X axis
phi = e_euler(3); % rotation about Z axis

costheta = cos(theta);
sintheta = sin(theta);
cospsi = cos(psi);
sinpsi = sin(psi);
cosphi = cos(phi);
sinphi = sin(phi);

% X - Y - Z
% a11 = costheta*cosphi;
% a21 = costheta*sinphi;
% a31 = -sintheta;
% a12 = sinpsi*sintheta*cosphi - cospsi*sinphi;
% a22 = sinpsi*sintheta*sinphi + cospsi*cosphi;
% a32 = costheta*sinpsi;
% a13 = cospsi*sintheta*cosphi + sinpsi*sinphi;
% a23 = cospsi*sintheta*sinphi - sinpsi*cosphi;
% a33 = costheta*cospsi;

% Y - X - Z
a11 = cosphi*costheta-sinphi*sinpsi*sintheta;
a21 = sinphi*costheta+cosphi*sinpsi*sintheta;
a31 = -cospsi*sintheta;
a12 =  -sinphi*cospsi;
a22 = cosphi*cospsi;
a32 = sinpsi;
a13 = cosphi*sintheta+sinphi*sinpsi*costheta;
a23 = sinphi*sintheta-cosphi*sinpsi*costheta;
a33 = cospsi*costheta;

for i = 1:nrow
    newp(i,1) = a11*p(i,1) + a12*p(i,2) + a13*p(i,3);
    newp(i,2) = a21*p(i,1) + a22*p(i,2) + a23*p(i,3);
    newp(i,3) = a31*p(i,1) + a32*p(i,2) + a33*p(i,3);
end