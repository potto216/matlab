%Written by Hailin Jin and Paolo Favaro
%Copyright (c) Washington University, 2001
%All rights reserved
%Last updated 10/18/2001
%function [xtt] = SelectFeature(Ipi,thresh,boundary,spacing,winx,winy,Nmax,method)
% Selects feature points on the given image
%
% DEBUGGED February 14, 1995.
% stupid mistake for computing maxq (before boundary)
%
% method= 0 -> old method of thresh = max(q(:))/10
% method = 1 -> new method of thresh = 10*mean(q(:))

function [xtt] = SelectFeature(Ipi)

global resolution winx winy saturation ...
    wintx winty spacing boundary boundary_t ...
    Nmax thresh levelmin levelmax ThreshQ ...
    N_max_feat method;

[nx, ny] = size(Ipi);

%disp('Quality computation...');
q = GridQuality(Ipi,winx,winy);

%compute boundary mask
windboundary = zeros(nx,ny);
windboundary(boundary:nx-boundary+1,boundary:ny-boundary+1) = ...
    ones(nx-2*boundary+2,ny-2*boundary+2);
%mask out the boundary
q = q.*windboundary;


if method,
%   maxq = max(max(q(find(q<saturation))));
   maxq = min(max(q(:)),saturation*min(winx,winy));
else
   maxq = max(max(q));
end;

thq = thresh*maxq;

%Q = (q > (thresh * maxq)) & LocalMax(q);
Q = (q > thq) & (LocalMax(q));

i = find(Q(:));

%disp('Local max computation...')

[Y,I] = sort(-q(i));

if (size(Y,1)>Nmax),
	Y = Y(1:Nmax);
	I = I(1:Nmax);
end;

%keyboard;

C = ceil(i(I)/nx);
R = rem(i(I)-1,nx)+1;

CC = C * ones(1,size(C,1));
RR = R * ones(1,size(R,1));

D2 = (CC - CC').^2 + (RR-RR').^2;	%% matrix of square distances between features
D2_mod = tril(D2-spacing^2,-1);		%% take the lower-triangle

good_features = ~sum(D2_mod'<0);	%% if the sum is 0 it is a good feature
indexgood = find(good_features);

%keyboard;

featR = R(indexgood);
featC = C(indexgood);

xtt = [featR,featC]';

indxtt = (xtt(2,:)-1)*nx + xtt(1,:);
qxtt = q(indxtt);

return;

% Some graphical output :

N = size(xtt,2);
figure(1);
image(Ipi);         
colormap(gray(256));
zoom off;
%colormap(gray(256));
hold on;

ind = find(goodfeat);
Nf = size(ind);


for k=1:Nf,
   i = ind(k);
   figure(1);
   plot(xtt(2,i),xtt(1,i),'r+');
   title(['k = ' num2str(k) ', quality = ' num2str(Qtt(i))]);
   figure(2);
   image(Ipi(round(xtt(1,i) - 10:xtt(1,i) + 10),round(xtt(2,i) - 10:xtt(2,i) + 10)));
   colormap(gray(256));
   waitforbuttonpress;
   figure(1);
   plot(xtt(2,i),xtt(1,i),'b+');
end;

hold off;

