function [Nfasx,Nfasy,fl,pen] = ProcessFascicle(fas_x,fas_y, w, image_scale)

%Sort the fascicle endpoint coords and multiply by warp matrix
newpos = [fas_x(:),fas_y(:),ones(2,1)] * w;
%Assign new coords
Nfasx(:,1) = newpos(:,1);
Nfasy(:,1) = newpos(:,2);

%Calculate the length and pennation for the current frame
pen = atan2(abs(diff(Nfasy)),abs(diff(Nfasx)));
fl = image_scale*sqrt(diff(Nfasy).^2 + diff(Nfasx).^2);