pp = spline(objPhantom.rectusFemoris.band(1).spline.controlpt.x_m(1:8:end),objPhantom.rectusFemoris.band(1).spline.controlpt.z_m(1:8:end))
 
ppd1=fnder(pp,1)
 
xEval=objPhantom.rectusFemoris.band(1).spline.controlpt.x_m(1:8:end);
p=[xEval.'; fnval(pp,xEval.')];
  
xStep=mean(diff(xEval));
slope = fnval(ppd1,xEval);

V=[xStep*ones(size(xEval)).';slope.'*xStep];

N=1j*[1 1j]*V;
Nt=[real(N);imag(N)];
checkValue=mean(abs((180/pi*angle(N)-90)-atan2d(V(2,:),V(1,:))));



figure; fnplt(pp,'b'); hold on; plot(p(1,:),p(2,:),'.r');
hd=colvecfun(@(ptStart,ptOffset) plot([ptStart(1) (ptStart(1)+ptOffset(1))],[ptStart(2) (ptStart(2)+ptOffset(2))],'r'),p,V)
hd=colvecfun(@(ptStart,ptOffset) plot([ptStart(1) (ptStart(1)+ptOffset(1))],[ptStart(2) (ptStart(2)+ptOffset(2))],'g'),p,Nt)
 
%The purpose of this simulation is to simulate the motion  
%we want to rotate the points along the spline in the x and z dim.  the y
 %dim will stay the same 