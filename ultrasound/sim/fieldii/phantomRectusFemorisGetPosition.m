function  [phantomROIRectusFemoris, averageMotion_m]=phantomRectusFemorisGetPosition(objPhantom,timeIndex)
%phantomRectusFemorisGetPosition Compute the RectusFemoris scatter positions and
%returns them with their intensity setting

switch(objPhantom.name)
    
    case 'rectusFemoris_fascicle'
        
        %Override any base configurations
        phantomROIRectusFemoris.x_m=[];
        phantomROIRectusFemoris.y_m=[];
        phantomROIRectusFemoris.z_m=[];
        phantomROIRectusFemoris.amplitude=[];
        
        passLimit = @(test,clim) (test>=clim(1)) & (test<=clim(2));
       
        xMotionOffset_m=objPhantom.rectusFemoris.motion.offset_m(timeIndex);
        averageMotion_m = [xMotionOffset_m; 0; 0];
        
        for tt=1:length(objPhantom.rectusFemoris.band)
            
            ptX_m=objPhantom.rectusFemoris.band(tt).x_m+xMotionOffset_m;
            ptY_m=objPhantom.rectusFemoris.band(tt).y_m;
            ptZ_m=objPhantom.rectusFemoris.band(tt).z_m;
            
            %Although the Z and X will change slightly we can remove the
            %ones we don't care about which are outside of the phantom
            goodIdx= passLimit(ptX_m,objPhantom.xLim_m) & ...
                passLimit(ptY_m,objPhantom.yLim_m);
            ptX_m(~goodIdx)=[];
            ptY_m(~goodIdx)=[];
            ptZ_m(~goodIdx)=[];
            
            if ~isempty(ptX_m) && objPhantom.fasciclesEnabled
                splineCoefficients = spline(objPhantom.rectusFemoris.band(tt).spline.controlpt.x_m(1:8:end), ...
                    objPhantom.rectusFemoris.band(tt).spline.controlpt.z_m(1:8:end));
                splineSlopeCoefficients=fnder(splineCoefficients,1);
                
                %We need to rotate each point on the x/z axis to match
                
                slope = fnval(splineSlopeCoefficients,ptX_m.');
                Nt=colvecNorm([ones(1,size(ptX_m,1));slope]);
                Nn=1j*[1 1j]*Nt;
                Nn=[real(Nn);imag(Nn)];
                checkValue=mean(abs((180/pi*angle([1 1j]*Nn)-90)-atan2d(Nt(2,:),Nt(1,:))));
                
                
                if checkValue>1e-12
                    error('Error value is too large');
                end
                
                %We can compute the new rotated axis by finding the slope of
                %the spline which is the tangent at each point and then we
                %rotate the axis by 90 degrees to get the other axis.  The
                %tricky part is to make sure the coordinate space is correct.
                %The (x,z) spline point needs to be subtracted from the (x,z)
                %of the scatter point.  Then the rotation should take place and
                %finally the center point added back on.  Throughout this
                %transform the y position remains fixed
                
                %%
                splineX_m=objPhantom.rectusFemoris.band(tt).spline.controlpt.x_m(1:8:end);
                splinePt=[ptX_m.'; fnval(splineCoefficients,ptX_m.')];  %given an x position where should the
                xStep=mean(diff(ptX_m,1));
                %remember z s centered around zero while x runs along the
                %strand so when rotating we need to center x while leaving z
                %untouched
                %ptRotate=colvecfun(@(nt,nn,pt,cp) ((pt-cp)), Nt,Nn,[ptX_m.';ptZ_m.'],diag([1 0])*splinePt);
                ptRotate=colvecfun(@(nt,nn,pt,cp) ([nt nn]*(pt-cp)+cp), Nt,Nn,[ptX_m.';ptZ_m.'],diag([1 0])*splinePt)+diag([0 1])*splinePt;
                %ptRotate=colvecfun(@(nt,nn,pt,cp) ([nt nn]*([1;1])), Nt,Nn,[ptX_m.';(ptZ_m.'+splinePt(2,:))],splinePt);
                
                if false
                    %%
                    figure; fnplt(splineCoefficients,'b'); hold on;
                    plot(splinePt(1,:),splinePt(2,:),'.r');
                    plot(ptX_m.',ptZ_m.'+splinePt(2,:),'.b');
                    plot(ptRotate(1,:),ptRotate(2,:),'.g');
                    %hd=colvecfun(@(ptStart,ptOffset) plot([ptStart(1) (ptStart(1)+ptOffset(1))],[ptStart(2) (ptStart(2)+ptOffset(2))],'r'),splinePt,Nn)
                    %hd=colvecfun(@(ptStart,ptOffset) plot([ptStart(1) (ptStart(1)+ptOffset(1))],[ptStart(2) (ptStart(2)+ptOffset(2))],'g'),splinePt,Nt)
                end
                
                
                phantomROIRectusFemoris.x_m=[phantomROIRectusFemoris.x_m; ptRotate(1,:).'];
                phantomROIRectusFemoris.y_m=[phantomROIRectusFemoris.y_m; ptY_m];
                phantomROIRectusFemoris.z_m=[phantomROIRectusFemoris.z_m; ptRotate(2,:).'];
                phantomROIRectusFemoris.amplitude=[phantomROIRectusFemoris.amplitude; objPhantom.rectusFemoris.band(tt).amplitude(goodIdx) ];
            else
                %just skip it since there were not any points valid
            end
        end
        
        
        %Compute the motion of the background scatters
        %fm(x)=ft(x)+(1-m)*fb(x)
        %(fm(x)-ft(x))/fb(x)=1-m
        %m=(1-(fm(x)-ft(x))/fb(x))
        if ~isempty(objPhantom.rectusFemoris.background.amplitude)
            %To move the background scatters we first need to determine the
            %
            newBackgroundX_m=objPhantom.rectusFemoris.background.x_m+xMotionOffset_m;
            newBackgroundY_m=objPhantom.rectusFemoris.background.y_m;
            ftop_m = fnval(objPhantom.rectusFemoris.background.topSpline_m,newBackgroundX_m);
            fbottom_m = fnval(objPhantom.rectusFemoris.background.bottomSpline_m,newBackgroundX_m);
            %fm(x)=ft(x)+(1-m)*fb(x)
            %(fm(x)-ft(x))/fb(x)=1-m
            %m=(1-(fm(x)-ft(x))/fb(x))
            %remember top is a smaller number (closer to the origin than bottom)
            m=objPhantom.rectusFemoris.background.lambda;
            newBackgroundZ_m=ftop_m + (1-m).*(fbottom_m-ftop_m);
            
            goodIdx= passLimit(newBackgroundX_m,objPhantom.xLim_m) &  ...
                passLimit(newBackgroundY_m,objPhantom.yLim_m) & ...
                passLimit(newBackgroundZ_m,objPhantom.zLim_m);
            
            if false
                %%
                figure; plot(newBackgroundX_m(goodIdx),ftop_m(goodIdx),'b.')
                hold on;
                plot(newBackgroundX_m(goodIdx),fbottom_m(goodIdx),'b.')
                plot(newBackgroundX_m(goodIdx),newBackgroundZ_m(goodIdx),'g.')
                
                
            end
            
            phantomROIRectusFemoris.x_m=[phantomROIRectusFemoris.x_m; newBackgroundX_m(goodIdx)];
            phantomROIRectusFemoris.y_m=[phantomROIRectusFemoris.y_m; newBackgroundY_m(goodIdx)];
            phantomROIRectusFemoris.z_m=[phantomROIRectusFemoris.z_m; newBackgroundZ_m(goodIdx)];
            phantomROIRectusFemoris.amplitude=[phantomROIRectusFemoris.amplitude; objPhantom.rectusFemoris.background.amplitude(goodIdx) ];
            
            
        else
            %do nothing
        end
        
        
        
    otherwise
        error('This model has been deprecated.');
        mo=objPhantom.rectusFemoris.model.motionModelOffset;
        
        currentRectusFemorisPattern=objPhantom.rectusFemoris.model.rectusFemorisPattern((1:(length(objPhantom.rectusFemoris.band(1).amplitude))) + ...
            mo+objPhantom.rectusFemoris.model.rectusFemorisMotion(timeIndex),:);
        
        %Override any base configurations
        phantomROIRectusFemoris.x_m=[];
        phantomROIRectusFemoris.y_m=[];
        phantomROIRectusFemoris.z_m=[];
        phantomROIRectusFemoris.amplitude=[];
        
        for tt=1:length(objPhantom.rectusFemoris.band)
            
            phantomROIRectusFemoris.x_m=[phantomROIRectusFemoris.x_m; objPhantom.rectusFemoris.band(tt).x_m(currentRectusFemorisPattern(:,tt)) ];
            phantomROIRectusFemoris.y_m=[phantomROIRectusFemoris.y_m; objPhantom.rectusFemoris.band(tt).y_m(currentRectusFemorisPattern(:,tt)) ];
            phantomROIRectusFemoris.z_m=[phantomROIRectusFemoris.z_m; objPhantom.rectusFemoris.band(tt).z_m(currentRectusFemorisPattern(:,tt)) ];
            phantomROIRectusFemoris.amplitude=[phantomROIRectusFemoris.amplitude; objPhantom.rectusFemoris.band(tt).amplitude(currentRectusFemorisPattern(:,tt)) ];
        end
        
end

