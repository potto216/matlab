%The coordinates retured are in world space. Clipping is done here
function  [phantomAllScatters, averageMotion_m]=phantomCystGetPosition(objPhantom,timeIndex)

%The model is referenced to time = 0 theremore we have to do a cumsum of
%velocity to get the new position
zOffset_m=sum(objPhantom.parameters.offset_mPerSec(1:timeIndex));

%We set everything up in scatter space move the points and clip
phantomAllScatters.x_m=objPhantom.background.x_m;
phantomAllScatters.y_m=objPhantom.background.y_m;
phantomAllScatters.z_m=objPhantom.background.z_m+zOffset_m;
phantomAllScatters.amplitude=objPhantom.background.amplitude;

%Now clip in scatter space
badIndexes = (phantomAllScatters.z_m < objPhantom.parameters.scatterField.clipZ_m(1)) | (phantomAllScatters.z_m > objPhantom.parameters.scatterField.clipZ_m(2));

phantomAllScatters.x_m(badIndexes)=[];
phantomAllScatters.y_m(badIndexes)=[];
phantomAllScatters.z_m(badIndexes)=[];
phantomAllScatters.amplitude(badIndexes)=[];

%then transform to world coordinates
phantomAllScatters.x_m=phantomAllScatters.x_m+objPhantom.parameters.scatterField.originToWorld_m(1);
phantomAllScatters.y_m=phantomAllScatters.y_m+objPhantom.parameters.scatterField.originToWorld_m(2);
phantomAllScatters.z_m=phantomAllScatters.z_m+objPhantom.parameters.scatterField.originToWorld_m(3);

averageMotion_m = [0; 0; zOffset_m];

 

%         passLimit = @(test,clim) (test>=clim(1)) & (test<=clim(2));
%         xMotionOffset_m=objPhantom.rectusFemoris.motion.offset_m(timeIndex);

%             %Although the Z and X will change slightly we can remove the
%             %ones we don't care about which are outside of the phantom
%             goodIdx= passLimit(ptX_m,objPhantom.xLim_m) & ...
%                 passLimit(ptY_m,objPhantom.yLim_m);
%             ptX_m(~goodIdx)=[];
%             ptY_m(~goodIdx)=[];
%             ptZ_m(~goodIdx)=[];
%
%             if ~isempty(ptX_m) && objPhantom.fasciclesEnabled
%                 splineCoefficients = spline(objPhantom.rectusFemoris.band(tt).spline.controlpt.x_m(1:8:end), ...
%                     objPhantom.rectusFemoris.band(tt).spline.controlpt.z_m(1:8:end));
%                 splineSlopeCoefficients=fnder(splineCoefficients,1);
%
%                 %We need to rotate each point on the x/z axis to match
%
%                 slope = fnval(splineSlopeCoefficients,ptX_m.');
%                 Nt=colvecNorm([ones(1,size(ptX_m,1));slope]);
%                 Nn=1j*[1 1j]*Nt;
%                 Nn=[real(Nn);imag(Nn)];
%                 checkValue=mean(abs((180/pi*angle([1 1j]*Nn)-90)-atan2d(Nt(2,:),Nt(1,:))));
%
%
%                 if checkValue>1e-12
%                     error('Error value is too large');
%                 end
%
%                 %We can compute the new rotated axis by finding the slope of
%                 %the spline which is the tangent at each point and then we
%                 %rotate the axis by 90 degrees to get the other axis.  The
%                 %tricky part is to make sure the coordinate space is correct.
%                 %The (x,z) spline point needs to be subtracted from the (x,z)
%                 %of the scatter point.  Then the rotation should take place and
%                 %finally the center point added back on.  Throughout this
%                 %transform the y position remains fixed
%
%                 %%
%                 splineX_m=objPhantom.rectusFemoris.band(tt).spline.controlpt.x_m(1:8:end);
%                 splinePt=[ptX_m.'; fnval(splineCoefficients,ptX_m.')];  %given an x position where should the
%                 xStep=mean(diff(ptX_m,1));
%                 %remember z s centered around zero while x runs along the
%                 %strand so when rotating we need to center x while leaving z
%                 %untouched
%                 %ptRotate=colvecfun(@(nt,nn,pt,cp) ((pt-cp)), Nt,Nn,[ptX_m.';ptZ_m.'],diag([1 0])*splinePt);
%                 ptRotate=colvecfun(@(nt,nn,pt,cp) ([nt nn]*(pt-cp)+cp), Nt,Nn,[ptX_m.';ptZ_m.'],diag([1 0])*splinePt)+diag([0 1])*splinePt;
%                 %ptRotate=colvecfun(@(nt,nn,pt,cp) ([nt nn]*([1;1])), Nt,Nn,[ptX_m.';(ptZ_m.'+splinePt(2,:))],splinePt);
%
%                 if false
%                     %%
%                     figure; fnplt(splineCoefficients,'b'); hold on;
%                     plot(splinePt(1,:),splinePt(2,:),'.r');
%                     plot(ptX_m.',ptZ_m.'+splinePt(2,:),'.b');
%                     plot(ptRotate(1,:),ptRotate(2,:),'.g');
%                     %hd=colvecfun(@(ptStart,ptOffset) plot([ptStart(1) (ptStart(1)+ptOffset(1))],[ptStart(2) (ptStart(2)+ptOffset(2))],'r'),splinePt,Nn)
%                     %hd=colvecfun(@(ptStart,ptOffset) plot([ptStart(1) (ptStart(1)+ptOffset(1))],[ptStart(2) (ptStart(2)+ptOffset(2))],'g'),splinePt,Nt)
%                 end
%
%
%                 phantomROICyst.x_m=[phantomROICyst.x_m; ptRotate(1,:).'];
%                 phantomROICyst.y_m=[phantomROICyst.y_m; ptY_m];
%                 phantomROICyst.z_m=[phantomROICyst.z_m; ptRotate(2,:).'];
%                 phantomROICyst.amplitude=[phantomROICyst.amplitude; objPhantom.rectusFemoris.band(tt).amplitude(goodIdx) ];
%             else
%                 %just skip it since there were not any points valid
%             end
%         end


%         %Compute the motion of the background scatters
%         %fm(x)=ft(x)+(1-m)*fb(x)
%         %(fm(x)-ft(x))/fb(x)=1-m
%         %m=(1-(fm(x)-ft(x))/fb(x))
%         if ~isempty(objPhantom.rectusFemoris.background.amplitude)
%             %To move the background scatters we first need to determine the
%             %
%             newBackgroundX_m=objPhantom.rectusFemoris.background.x_m+xMotionOffset_m;
%             newBackgroundY_m=objPhantom.rectusFemoris.background.y_m;
%             ftop_m = fnval(objPhantom.rectusFemoris.background.topSpline_m,newBackgroundX_m);
%             fbottom_m = fnval(objPhantom.rectusFemoris.background.bottomSpline_m,newBackgroundX_m);
%             %fm(x)=ft(x)+(1-m)*fb(x)
%             %(fm(x)-ft(x))/fb(x)=1-m
%             %m=(1-(fm(x)-ft(x))/fb(x))
%             %remember top is a smaller number (closer to the origin than bottom)
%             m=objPhantom.rectusFemoris.background.lambda;
%             newBackgroundZ_m=ftop_m + (1-m).*(fbottom_m-ftop_m);
%
%             goodIdx= passLimit(newBackgroundX_m,objPhantom.xLim_m) &  ...
%                 passLimit(newBackgroundY_m,objPhantom.yLim_m) & ...
%                 passLimit(newBackgroundZ_m,objPhantom.zLim_m);
%
%             if false
%                 %%
%                 figure; plot(newBackgroundX_m(goodIdx),ftop_m(goodIdx),'b.')
%                 hold on;
%                 plot(newBackgroundX_m(goodIdx),fbottom_m(goodIdx),'b.')
%                 plot(newBackgroundX_m(goodIdx),newBackgroundZ_m(goodIdx),'g.')
%
%
%             end
%
%             phantomROICyst.x_m=[phantomROICyst.x_m; newBackgroundX_m(goodIdx)];
%             phantomROICyst.y_m=[phantomROICyst.y_m; newBackgroundY_m(goodIdx)];
%             phantomROICyst.z_m=[phantomROICyst.z_m; newBackgroundZ_m(goodIdx)];
%             phantomROICyst.amplitude=[phantomROICyst.amplitude; objPhantom.rectusFemoris.background.amplitude(goodIdx) ];
%
%
%         else
%             %do nothing
%         end


end

