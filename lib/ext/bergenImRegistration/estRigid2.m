function M = estTranslation2(im1,im2)
%
% function M = estAffine2(im1,im2)
%
% im1 and im2 are images
%
% M is 3x3 affine transform matrix: X' = M X
% where X=(x,y,1) is starting position in homogeneous coords
% and X'=(x',y',1) is ending position
%
% Solves fs^t theta + ft = 0
% where theta = B p is image velocity at each pixel
%       B is 2x6 matrix that depends on image positions
%       p is vector of affine motion parameters
%       fs is vector of spatial derivatives at each pixel
%       ft is temporal derivative at each pixel
% Mulitplying fs^t B gives a 1x6 vector for each pixel.  Piling
% these on top of one another gives A, an Nx6 matrix, where N is
% the number of pixels.  Solve M p = ft where ft is now an Nx1
% vector of the the temporal derivatives at every pixel.

% Compute the derivatives of the image
[fx,fy,ft]=computeDerivatives2(im1,im2);

% Create a mesh for the x and y values
[xgrid,ygrid]=meshgrid(1:size(fx,2),1:size(fx,1));
pts=find(~isnan(fx));
fx = fx(pts);
fy = fy(pts);
ft = ft(pts);

xgrid = xgrid(pts);
ygrid = ygrid(pts);

A= [fx(:).*xgrid(:)+fy(:).*ygrid(:) fy(:).*xgrid(:)+fx(:).*ygrid(:) fx(:) fy(:)];
b = -ft(:);

% Solve overconstrained least squares solution
p = A\b;

M= [1+p(1) p(2) p(3);
    p(2) 1+p(1) p(4);
    0 0 1];

return;