function expRunTrack_show(rfBasefilename, mriData_mmPerSec,mriT_sec,mriData_mm,mriDataIndexOfBestMatch,d,mriSync_Sec,mriSync_displacement,mriSyncCycleShift,cycleToAverage_index,manualTrack_mm)

% mriSync_Sec=6.1;
% mriSync_displacement=-5;
% mriSyncCycleShift=3;
% cycleToAverage_index=[320:450];

% case 2
% mriSync_Sec=0.6;
% mriSync_displacement=-14;
% mriSyncCycleShift=3;
% cycleToAverage_index=[1:120];
% 
% mriSync_Sec=2.4;
% mriSync_displacement=-16;
% mriSyncCycleShift=27;
% cycleToAverage_index=[140:260];

t_sec=d.t_sec;
tv_sec=t_sec(1:end-1);

d_mm=d.d_mm;
dSmooth_mm=d.dSmooth_mm;
%trackChange_frameNumber=d.trackChange_frameNumber;
v_mmPerSec=d.v_mmPerSec;
vSmooth_mmPerSec=d.vSmooth_mmPerSec;

dBackward_mm=d.dBackward_mm(end:-1:1);
dBackwardSmooth_mm=d.dBackwardSmooth_mm(end:-1:1);

vBackward_mmPerSec=-d.vBackward_mmPerSec(end:-1:1);
vBackwardSmooth_mmPerSec=-d.vBackwardSmooth_mmPerSec(end:-1:1);


w=linspace(1, 0, length(cycleToAverage_index));
alignOffset=d_mm(cycleToAverage_index(1))-dBackward_mm(cycleToAverage_index(1));
dAverage_mm=(w.*d_mm(cycleToAverage_index)+(1-w).*(dBackward_mm(cycleToAverage_index)+alignOffset));

dAverage_mm=(w.*d_mm(cycleToAverage_index)+(1-w).*(dBackward_mm(cycleToAverage_index)+alignOffset));
vAverage_mmPerSec=(w.*v_mmPerSec(cycleToAverage_index)+(1-w).*(vBackward_mmPerSec(cycleToAverage_index)));


dSmoothAverage_mm=(w.*dSmooth_mm(cycleToAverage_index)+(1-w).*(dBackwardSmooth_mm(cycleToAverage_index)+alignOffset));
vSmoothAverage_mmPerSec=(w.*vSmooth_mmPerSec(cycleToAverage_index)+(1-w).*(vBackwardSmooth_mmPerSec(cycleToAverage_index)));

%% Plot out results
ax=[];
if false
createFigure; 
subplot(2,1,1)
plot(t_sec,d_mm,'b','linewidth',2)
hold on;
plot(t_sec(trackChange_frameNumber),d_mm(trackChange_frameNumber),'bo','linewidth',1)

plot(t_sec,dSmooth_mm,'r','linewidth',2)
plot(mriT_sec+mriSync_Sec,-mriData_mm-mriSync_displacement)
%plot(mriT_sec+2.3,-mriData_mm-2)
xlabel('time (sec)');
ylabel('displacement (mm)');
title(['Muscle Displacement for ' rfBasefilename]);
legend('tracked','track change','smoothed tracked');
ax(1)=gca;

subplot(2,1,2)
plot(t_sec(1:length(v_mmPerSec)),v_mmPerSec,'b')
hold on
plot(t_sec(1:length(v_mmPerSec)),vSmooth_mmPerSec,'r','linewidth',2)
plot(mriT_sec+0.5,-mriData_mmPerSec)
xlabel('time (sec)');
ylabel('velocity (mm/sec)');
title('Muscle Velocity');
legend('tracked','smoothed tracked','MRI 1','MRI 2');
ax(2)=gca;
linkaxes(ax,'x')
end
%% Plot out results in sample time
if true
createFigure; 
ax=[];
subplot(4,1,[1 2])
imh=imagesc(d.trackLength);
basicColorMap=colormap;
zeroColorMap=basicColorMap;
zeroColorMap(1,:)=0;
colormap(zeroColorMap);
ax(1)=gca;
ylabel('tracks in frame (count)');
title(['Frame Track Density for ' rfBasefilename],'interpreter','none');

subplot(4,1,3)
plot(vSmooth_mmPerSec,'b','linewidth',2)
xlabel('time (frame #)')
ylabel('velocity (mm/sec)');
ax(2)=gca;

subplot(4,1,4)
plot(dSmooth_mm,'b','linewidth',2)
xlabel('time (frame #)')
ylabel('displacement (mm)');
ax(3)=gca;

linkaxes(ax,'x');
end
%% Plot out results for forward backward displacement
if false
createFigure; 
subplot(2,1,1)
plot(t_sec,d_mm,'b','linewidth',2)
hold on
plot(t_sec,dSmooth_mm,'k','linewidth',2)
%plot(t_sec,dBackward_mm(end:-1:1)+18,'r','linewidth',2)   
plot(t_sec,dBackward_mm,'r','linewidth',2)   
plot(t_sec,dBackwardSmooth_mm,'c','linewidth',2)   
xlabel('time (sec)');
ylabel('displacement (mm)');
title(['Muscle Displacement for ' rfBasefilename],'interpreter','none');
legend('forward','forward smooth','backward','backward smooth');

subplot(2,1,2)
plot(tv_sec,v_mmPerSec,'b','linewidth',2)
hold on
plot(tv_sec,vSmooth_mmPerSec,'k','linewidth',2)
plot(tv_sec,vBackward_mmPerSec,'r','linewidth',2)  
plot(tv_sec,vBackwardSmooth_mmPerSec,'c','linewidth',2)   
xlabel('time (sec)');
ylabel('velocity (mm/sec)');
title('Muscle Velocity');
legend('forward','forward smooth','backward','backward smooth');
end


%% Plot out results with MRI and averaged pulse
ax=[];
createFigure; 
ax(1)=subplot(2,1,1);
hMri=plot(mriT_sec+mriSync_Sec,-circshift(mriData_mm,mriSyncCycleShift)+mriSync_displacement); %stop of 
set(hMri,'Color',[0.5 0.5 0.5]);
hold on
hMriROI=plot(mriT_sec+mriSync_Sec,-circshift(mriData_mm(:,mriDataIndexOfBestMatch),mriSyncCycleShift)+mriSync_displacement); %stop of 
set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
hFor=plot(t_sec,d_mm,'g','linewidth',2);
hBack=plot(t_sec,dBackward_mm+alignOffset,'r','linewidth',2);  
hAvg=plot(t_sec(cycleToAverage_index),dAverage_mm,'b','linewidth',2);

xlabel('time (sec)');
ylabel('displacement (mm)');
title(['Muscle Displacement for ' rfBasefilename],'interpreter','none');
legend([hFor hBack hAvg hMri(1) hMriROI(1)], 'forward track','backward track','averaged','MRI','MRI ROI');


ax(2)=subplot(2,1,2);
hMri=plot(mriT_sec+mriSync_Sec,-circshift(mriData_mmPerSec,mriSyncCycleShift)); %stop of 
set(hMri,'Color',[0.5 0.5 0.5]);
hold on
hMriROI=plot(mriT_sec+mriSync_Sec,-circshift(mriData_mmPerSec(:,mriDataIndexOfBestMatch),mriSyncCycleShift)); %stop of 
set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
hFor=plot(t_sec,v_mmPerSec,'g','linewidth',2);
hBack=plot(t_sec,vBackward_mmPerSec,'r','linewidth',2);
hAvg=plot(t_sec(cycleToAverage_index),vAverage_mmPerSec,'b','linewidth',2);

xlabel('time (sec)');
ylabel('pseudovelocity (mm/sec)');
title('Muscle Pseudovelocity');
%legend([hFor hBack hAvg hMri(1) hMriROI(1)], 'forward track','backward track','averaged','MRI','MRI ROI');
linkaxes(ax,'x');

%% Plot out results with MRI and smoothed averaged pulse
ax=[];
createFigure; 
ax(1)=subplot(2,1,1);
hMri=plot(mriT_sec+mriSync_Sec,-circshift(mriData_mm,mriSyncCycleShift)+mriSync_displacement); %stop of 
set(hMri,'Color',[0.5 0.5 0.5]);
hold on
hMriROI=plot(mriT_sec+mriSync_Sec,-circshift(mriData_mm(:,mriDataIndexOfBestMatch),mriSyncCycleShift)+mriSync_displacement); %stop of 
set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
hFor=plot(t_sec,dSmooth_mm,'g','linewidth',2);
hBack=plot(t_sec,dBackwardSmooth_mm+alignOffset,'r','linewidth',2);  
hAvg=plot(t_sec(cycleToAverage_index),dSmoothAverage_mm,'b','linewidth',2);

xlabel('time (sec)');
ylabel('displacement (mm)');
title(['Smoothed Muscle Displacement for ' rfBasefilename],'interpreter','none');
legend([hFor hBack hAvg hMri(1) hMriROI(1)], 'forward track (smooth)','backward track(smooth)','averaged','MRI','MRI ROI');


ax(2)=subplot(2,1,2);
hMri=plot(mriT_sec+mriSync_Sec,-circshift(mriData_mmPerSec,mriSyncCycleShift)); %stop of 
set(hMri,'Color',[0.5 0.5 0.5]);
hold on
hMriROI=plot(mriT_sec+mriSync_Sec,-circshift(mriData_mmPerSec(:,mriDataIndexOfBestMatch),mriSyncCycleShift)); %stop of 
set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
hFor=plot(tv_sec,vSmooth_mmPerSec,'g','linewidth',2);
hBack=plot(tv_sec,vBackwardSmooth_mmPerSec,'r','linewidth',2);
hAvg=plot(tv_sec(cycleToAverage_index),vSmoothAverage_mmPerSec,'b','linewidth',2);

xlabel('time (sec)');
ylabel('velocity (mm/sec)');
title('Smoothed Muscle Velocity');
%legend([hFor hBack hAvg hMri(1) hMriROI(1)], 'forward track','backward track','averaged','MRI','MRI ROI');
linkaxes(ax,'x');
return

%% Show only the smooth track
createFigure; 
hFor=plot(t_sec,dSmooth_mm,'g','linewidth',2);
xlabel('time (sec)');
ylabel('displacement (mm)');
title(['Smoothed Muscle Displacement for ' rfBasefilename],'interpreter','none');
hold on;
if ~isempty(manualTrack_mm)
    hManual=plot(t_sec(1:size(manualTrack_mm,2)),manualTrack_mm,'r','linewidth',1);
end
legend('smooth track','manual track');


end
function createFigure
figure('units','normalized','outerposition',[0 0 1 1])
end