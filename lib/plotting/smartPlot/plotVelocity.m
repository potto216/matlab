function plotVelocity( varargin)
%PLOTVELOCITY Summary of this function goes here
%   Detailed explanation goes here
figure
for ii=1:length(varargin)
    plotSingleVelocity( varargin{1}(1),varargin{1}(2))
end
end

function plotSingleVelocity( velocityData,filename )
%PLOTVELOCITY Summary of this function goes here
%   Detailed explanation goes here

totalFrames=size(velocityData.fullTrackPathDelta_rc,2);
t_sec=(0:(totalFrames-1))/velocityData.fs;
X_mm=(diag(velocityData.scale_mm)*velocityData.fullTrackPathDelta_rc(:,:));


subplot(2,2,1);
phs=plot3(t_sec,X_mm(1,:)*velocityData.fs,X_mm(2,:)*velocityData.fs,'b.');
xlabel('time (sec)')
ylabel('axial velocity (mm/sec)')
zlabel('lateral velocity (mm/sec)')
view([90 0])
title([filename ' Velocity Plot'],'interpreter','none');
hold on

subplot(2,2,2);
phs=plot3(t_sec,cumsum(X_mm(1,:)),cumsum(X_mm(2,:)),'b');
xlabel('time (sec)')
ylabel('axial displacement (mm)')
zlabel('lateral displacement (mm)')
view([90 0])
title([' Displacement Plot']);
hold on

subplot(2,2,3);
plot(sqrt([1 1]*(X_mm.^2))*velocityData.fs)
title(['Speed Plot']);
xlabel('frame (#)')
ylabel('speed (mm/sec)')
hold on

end

