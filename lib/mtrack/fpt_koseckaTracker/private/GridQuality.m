%Written by Hailin Jin and Paolo Favaro
%Copyright (c) Washington University, 2001
%All rights reserved
%Last updated 10/18/2001
function [quality] = GridQuality(ima,winx,winy);

[grad_y, grad_x] = gradient(ima);	

a = conv2(conv2(grad_x .* grad_x, ones(2*winx+1,1), 'same'),ones(1,2*winy+1), 'same');
b = conv2(conv2(grad_x .* grad_y, ones(2*winx+1,1), 'same'),ones(1,2*winy+1), 'same');
c = conv2(conv2(grad_y .* grad_y, ones(2*winx+1,1), 'same'),ones(1,2*winy+1), 'same');

clear grad_x grad_y;

m = (a + c ) / 2;
d = a .* c - b .^ 2;
n = sqrt(m .^ 2 - d);

quality = min(abs(m - n),abs(m + n));

% normalization JY, March 1, 1995 : it is actually a good idea !!!

%quality = quality / (4*min(winx,winy)-1);
%quality = quality / (2*min(winx,winy)); % other option