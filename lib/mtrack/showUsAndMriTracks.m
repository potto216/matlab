function figureList=showUsAndMriTracks(trialName,rfBasefilename,report,showPlot)

% aligned(1).mri.roi.t_sec=mriTSync_sec;
% aligned.mri.roi.velocity_mmPerSec=mriRoiVelocity_mmPerSec;
% aligned.mri.isFlexion=circshift(mriIsFlexion,mriSyncCycleShift);
%
% aligned.mri.all.t_sec=mriTSync_sec;
% aligned.mri.all.velocity_mmPerSec=mriAllVelocity_mmPerSec;

t_sec=report.ultrasound.t_sec;

d_mm=report.ultrasound.d_mm;
dSmooth_mm=report.ultrasound.dSmooth_mm;

v_mmPerSec=report.ultrasound.v_mmPerSec;
vSmooth_mmPerSec=report.ultrasound.vSmooth_mmPerSec;

dBackward_mm=report.ultrasound.dBackward_mm;
dBackwardSmooth_mm=report.ultrasound.dBackwardSmooth_mm;

vBackward_mmPerSec=report.ultrasound.vBackward_mmPerSec;
vBackwardSmooth_mmPerSec=report.ultrasound.vBackwardSmooth_mmPerSec;

vWeightedAverage_mmPerSec=report.ultrasound.vWeightedAverage_mmPerSec;
vSmoothWeightedAverage_mmPerSec=report.ultrasound.vSmoothWeightedAverage_mmPerSec;

vSmoothHeavy_mmPerSec=report.ultrasound.vSmoothHeavy_mmPerSec;
vBackwardSmoothHeavy_mmPerSec=report.ultrasound.vBackwardSmoothHeavy_mmPerSec;

dWeightedAverage_mm=report.ultrasound.dWeightedAverage_mm;
dSmoothWeightedAverage_mm=report.ultrasound.dSmoothWeightedAverage_mm;

dvSmooth_mmPerSec=report.ultrasound.vSmooth_mmPerSec;
dvBackwardSmooth_mmPerSec=report.ultrasound.vBackwardSmooth_mmPerSec;

vPtAvg_mmPerSec=report.ultrasound.vPtAvg_mmPerSec;
vPtAvgBackward_mmPerSec= report.ultrasound.vPtAvgBackward_mmPerSec;
vPtAvgSmooth_mmPerSec=report.ultrasound.vPtAvgSmooth_mmPerSec;
vPtAvgBackwardSmooth_mmPerSec=report.ultrasound.vPtAvgBackwardSmooth_mmPerSec;


mriTSync_sec=report.mri.all.t_sec;
mriAllDisplacement_mm=report.mri.all.displacement_mm;
mriRoiDisplacement_mm=report.mri.roi.displacement_mm;


mriRoiVelocity_mmPerSec=report.mri.roi.velocity_mmPerSec;
mriAllVelocity_mmPerSec=report.mri.all.velocity_mmPerSec;

distanceMeasure=report.distanceMeasure;

figureList=[];
%% Plot out results with MRI and averaged pulse
ax=[];
if showPlot.avgMuscleSpeed
    figureList(end+1)=createFigure;
    ax(1)=subplot(2,1,1);
    hMri=plot(mriTSync_sec,mriAllVelocity_mmPerSec); %stop of
    set(hMri,'Color',[0.5 0.5 0.5]);
    hold on
    hMriROI=plot(mriTSync_sec,mriRoiVelocity_mmPerSec); %stop of
    set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
    hFor=plot(t_sec,v_mmPerSec,'g','linewidth',2);
    hBack=plot(t_sec,vBackward_mmPerSec,'r','linewidth',2);
    hAvg=plot(t_sec,vSmoothWeightedAverage_mmPerSec,'b','linewidth',2);
    
    
    xlabel('time (sec)');
    ylabel('signed speed (mm/sec)');
    title(['Averaged Muscle Signed Speed for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
    legend([hFor hBack hAvg hMri(1) hMriROI(1)], 'forward track','backward track','averaged','MRI','MRI ROI');
    
    ax(2)=subplot(2,1,2);
    hMri=plot(mriTSync_sec,mriAllVelocity_mmPerSec); %stop of
    set(hMri,'Color',[0.5 0.5 0.5]);
    hold on
    hMriROI=plot(mriTSync_sec,mriRoiVelocity_mmPerSec); %stop of
    set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
    hFor_dv=plot(t_sec,dvSmooth_mmPerSec,'c','linewidth',2);
    hBack_dv=plot(t_sec,dvBackwardSmooth_mmPerSec,'m','linewidth',2);
    hFor=plot(t_sec,vSmooth_mmPerSec,'g','linewidth',2);
    hBack=plot(t_sec,vBackwardSmooth_mmPerSec,'r','linewidth',2);
    legend([hFor hBack hFor_dv hBack_dv], 'signed speed forward track','signed speed backward track', 'der of distance forward track','der of distance backward track');
    hold off;
    xlabel('time (sec)');
    ylabel('signed speed (mm/sec)');
    title(['Muscle Signed Speed '  ' distance metric ' distanceMeasure.key]);
    %legend([hFor hBack hAvg hMri(1) hMriROI(1)], 'forward track','backward track','averaged','MRI','MRI ROI');
    linkaxes(ax,'x');
end
%% Plot out results with MRI and smoothed averaged pulse
ax=[];
if showPlot.avgMuscleDisplacement
    figureList(end+1)=createFigure;
    ax(1)=subplot(2,1,1);
    hMri=plot(mriTSync_sec,mriAllDisplacement_mm); %stop of
    set(hMri,'Color',[0.5 0.5 0.5]);
    hold on
    hMriROI=plot(mriTSync_sec,mriRoiDisplacement_mm); %stop of
    set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
    hFor=plot(t_sec,dSmooth_mm,'g','linewidth',2);
    hBack=plot(t_sec,dBackwardSmooth_mm,'r','linewidth',2);
    %hBack=plot(t_sec,dBackwardSmooth_mm+alignOffset,'r','linewidth',2);
    hAvg=plot(t_sec,dSmoothWeightedAverage_mm,'b','linewidth',2);
    
    xlabel('time (sec)');
    ylabel('displacement (mm)');
    title(['Smoothed Muscle Displacement for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
    legend([hFor hBack hAvg hMri(1) hMriROI(1)], 'forward track (smooth)','backward track(smooth)','averaged','MRI','MRI ROI');
    
    
    ax(2)=subplot(2,1,2);
    hMri=plot(mriTSync_sec,mriAllVelocity_mmPerSec); %stop of
    set(hMri,'Color',[0.5 0.5 0.5]);
    hold on
    hMriROI=plot(mriTSync_sec,mriRoiVelocity_mmPerSec); %stop of
    set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
    hFor=plot(t_sec,dvSmooth_mmPerSec,'g','linewidth',2);
    hBack=plot(t_sec,dvBackwardSmooth_mmPerSec,'r','linewidth',2);
    hold off;
    xlabel('time (sec)');
    ylabel('velocity (mm/sec)');
    title(['Derivative of Smoothed Displacement '  ' distance metric ' distanceMeasure.key]);
    linkaxes(ax,'x');
end



%% Plot out results with MRI and averaged pulse

ax=[];


if showPlot.avgMuscleSpeedSinglePlot
    figureList(end+1)=createFigure;
    
    hMri=plot(mriTSync_sec,mriAllVelocity_mmPerSec); %stop of
    set(hMri,'Color',[0.5 0.5 0.5]);
    hold on
    hMriROI=plot(mriTSync_sec,mriRoiVelocity_mmPerSec); %stop of
    set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
    %     hFor=plot(t_sec,v_mmPerSec,'g','linewidth',1);
    %     hBack=plot(t_sec,vBackward_mmPerSec,'r','linewidth',1);
    %hAvg=plot(t_sec(cycleToAverage_index),vWeightedAverage_mmPerSec,'b','linewidth',1);
    
    hForSmooth=plot(t_sec,vSmooth_mmPerSec,'linewidth',2,'Color',0.5*[0 1 0]);
    hBackSmooth=plot(t_sec,vBackwardSmooth_mmPerSec,'linewidth',2,'Color',0.5*[1 0 0]);
    
    hForSmoothHeavy=plot(t_sec,vSmoothHeavy_mmPerSec,'linewidth',1,'Color',0.7*[0 0 1]);
    hBackSmoothHeavy=plot(t_sec,vBackwardSmoothHeavy_mmPerSec,'linewidth',1,'Color',0.7*[1 0 1]);
    hold off;
    xlabel('time (sec)');
    ylabel('signed speed (mm/sec)');
    title(['Averaged Muscle Signed Speed for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
    legend([ hForSmooth hBackSmooth hForSmoothHeavy hBackSmoothHeavy hMri(1) hMriROI(1)], 'forward light smoothing','backward light smoothing', 'forward smoothed','backward smoothed','MRI','MRI ROI');
end
%%
if showPlot.avgMuscleSpeedWeightedSinglePlot
    figureList(end+1)=createFigure;
    
    %    subplot(2,1,1)
    %     hMri=plot(mriTSync_sec,mriAllVelocity_mmPerSec); %stop of
    %     set(hMri,'Color',[0.5 0.5 0.5]);
    %     hold on
    %     hFor=plot(t_sec,v_mmPerSec,'g','linewidth',1);
    %     hBack=plot(t_sec,vBackward_mmPerSec,'r','linewidth',1);
    %hAvg=plot(t_sec(cycleToAverage_index),vWeightedAverage_mmPerSec,'b','linewidth',1);
    
    hWeightedSmooth=plot(t_sec,vSmoothWeightedAverage_mmPerSec,'linewidth',2,'Color','b');
    hold on;
    
    hMriROI=plot(mriTSync_sec,mean(mriRoiVelocity_mmPerSec,2),'r','linewidth',2); %stop of
    %set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
    
    hold off;
    xlabel('time (sec)');
    ylabel('velocity (mm/sec)');
    
    
    if (mean(diff(mriTSync_sec))~=mean(diff(t_sec)))
        title(['Averaged Muscle Signed Speed for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
    else
        title(['Phantom (sample rate equal) Averaged Muscle Signed Speed for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
        mriRoiVelocity_mmPerSec=mriRoiVelocity_mmPerSec(1:length(vSmoothWeightedAverage_mmPerSec),1);
        
        mri.t_sec=t_sec;
        mri.velocity_mmPerSec=reshape(mriRoiVelocity_mmPerSec,1,[]);
        [ tableData,meanMri_mmPerSec,pt_sec, stdMri_mmPerSec ] = measureCycleValues(mri, t_sec, vSmoothWeightedAverage_mmPerSec,0*vSmoothWeightedAverage_mmPerSec,0 );
        %legend([ hWeightedSmooth hMriROI(1)], 'US', 'MRI');
        legend([ hWeightedSmooth hMriROI(1)], 'Tracked Velocity', 'Actual Velocity');
        
        
        disp(['US cycle displacement: ' num2str(sum(abs(vSmoothWeightedAverage_mmPerSec*mean(diff(t_sec))))) 'mm']);
        disp(['MR cycle displacement: ' num2str(sum(abs(mean(mriRoiVelocity_mmPerSec,2)*mean(diff(mriTSync_sec))))) 'mm']);
        
        mean(abs(mean(mriRoiVelocity_mmPerSec(:,1),2)-vSmoothWeightedAverage_mmPerSec(:)))
        
    end
    
    if false
        %%
        [~,minIdx]=min(abs(t_sec-1))
        figure;
        
        subplot(1,3,1);
        t1=t_sec(1:(minIdx-1));
        d1_1=cumsum(vSmoothWeightedAverage_mmPerSec(1:(minIdx-1))')*mean(diff(t_sec));
        d1_2=cumsum(mriRoiVelocity_mmPerSec(1:(minIdx-1)))*mean(diff(t_sec));
        h1=plot(t1,abs(d1_1),'linewidth',2,'Color','b');
        hold on
        h2=plot(t1,abs(d1_2),'linewidth',2,'Color','r');
        xlabel('time (sec)');
        ylabel('distance (mm)');
        legend([ h1 h2], 'Tracked', 'Actual');
        
        subplot(1,3,2);
        t2=t_sec(minIdx:end);
        d2_1=cumsum(vSmoothWeightedAverage_mmPerSec(minIdx:end)')*mean(diff(t_sec));
        d2_2=cumsum(mriRoiVelocity_mmPerSec(minIdx:end))*mean(diff(t_sec));
        h1=plot(t2,d2_1,'linewidth',2,'Color','b');
        hold on
        h2=plot(t2,d2_2,'linewidth',2,'Color','r');
        xlabel('time (sec)');
        ylabel('distance (mm)');
        legend([ h1 h2], 'Tracked', 'Actual');
        
        subplot(1,3,3);
        h1=plot(t1-t1(1),abs(d1_1-d1_2),'linewidth',2,'Color','b');
        hold on
        h2=plot(t2-t2(1),abs(d2_1-d2_2),'linewidth',2,'Color','r');
        xlabel('time (sec)');
        ylabel('distance (mm)');
        legend([ h1 h2], 'Flexion', 'Extension');
    end
    %     subplot(2,1,2)
    %     hWeightedSmooth=plot(vSmoothWeightedAverage_mmPerSec,'linewidth',2,'Color',[0 1 0]);
    %     hold on
    %     hForSmooth=plot(vSmooth_mmPerSec,'linewidth',2,'Color',0.5*[0 1 0]);
    %     hBackSmooth=plot(vBackwardSmooth_mmPerSec,'linewidth',2,'Color',0.5*[1 0 0]);
    %
    %     xlabel('sample ');
    %     ylabel('signed speed (mm/sec)');
    %     title(['Averaged Muscle Signed Speed for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
    %     legend([ hWeightedSmooth hForSmooth hBackSmooth], 'US Weighted', 'forward','backward');
end

%%
% only use with synth data
if false && showPlot.avgMuscleSpeedWeightedSinglePlot
    %%
    figureList(end+1)=createFigure;
    
    
    hWeightedSmooth=plot(t_sec-t_sec(1),vSmoothWeightedAverage_mmPerSec,'linewidth',2,'Color','k');
    hold on
    
    motion_mm=[   -0.6125   -0.8617   -1.1655   -1.5154   -1.9034   -2.3245   -2.8139   -3.3696   -3.9754   -4.6148   -5.2874 ...
        -6.0261   -6.8131   -7.6265   -8.4447   -9.2852  -10.1608  -11.0418  -11.8989  -12.7071  -13.5012  -14.2770 ...
        -15.0113  -15.6812  -16.2807  -16.8471  -17.3715  -17.8409  -18.2425  -18.5922  -18.9108  -19.1929  -19.4329 ...
        -19.6263  -19.7860  -19.9233  -20.0464  -20.1635  -20.2826  -20.4041  -20.5185  -20.6159  -20.6866  -20.7326 ...
        -20.7671  -20.7972  -20.8302  -20.8742  -20.9422  -21.0203  -21.0888  -21.1278  -21.1137  -21.0346  -20.9109 ...
        -20.7652  -20.6196  -20.4719  -20.3042  -20.1151  -19.9036  -19.6675  -19.3930  -19.0778  -18.7237  -18.3326 ...
        -17.8929  -17.3731  -16.7916  -16.1707  -15.5328  -14.8602  -14.1367  -13.3864  -12.6334  -11.8987  -11.1603 ...
        -10.4191   -9.6880   -8.9804   -8.3019   -7.6379   -6.9925   -6.3715   -5.7805   -5.2145   -4.6678   -4.1455 ...
        -3.6523   -3.1917   -2.7503   -2.3298   -1.9384   -1.5842   -1.2664   -0.9649   -0.6879   -0.4458   -0.2492  ...
        -0.0745    0.0937    0.2329    0.3206    0.3383    0.3214    0.2774    0.1981    0.0755];
    
    
    % plot(t_sec,mriInterp_mmPerSec,'g')
    motion_mmPerSec=56*diff(motion_mm(1:length(t_sec)+1));
    plot(t_sec,motion_mmPerSec,'r:','linewidth',2)  %check to make

        mriAlign_mmPerSec=circshift(mean(mriRoiVelocity_mmPerSec(:,1),2),1);
    % hMriROI=plot(mriTSync_sec,mriAlign_mmPerSec,'r','linewidth',2); %stop of
    mriInterp_mmPerSec=interp1([mriTSync_sec (mriTSync_sec(2)+mriTSync_sec(end))],[mriAlign_mmPerSec; mriAlign_mmPerSec(1)],t_sec,'cubic');
    mriInterp_mmPerSec=circshift(mriInterp_mmPerSec,[1 2]);
    warning('Make sure circ is aligned properly at the end points.');

    
    tdelta_sec=mean(diff(t_sec));
    cycleSplitIndex=floor(length(vSmoothWeightedAverage_mmPerSec)/2);
    tdelta_sec*sum(abs(motion_mmPerSec(1:cycleSplitIndex)));
    tdelta_sec*sum(abs(vSmoothWeightedAverage_mmPerSec(1:cycleSplitIndex)));
    
    mean(std(motion_mmPerSec(1:cycleSplitIndex)-vSmoothWeightedAverage_mmPerSec(1:cycleSplitIndex)))
    mean(abs(motion_mmPerSec(1:cycleSplitIndex)-vSmoothWeightedAverage_mmPerSec(1:cycleSplitIndex)))
    
    
    tdelta_sec*sum(abs(motion_mmPerSec(cycleSplitIndex:end)));
    tdelta_sec*sum(abs(vSmoothWeightedAverage_mmPerSec(cycleSplitIndex:end)));
    
    mean(std(motion_mmPerSec(cycleSplitIndex:end)-vSmoothWeightedAverage_mmPerSec(cycleSplitIndex:end)))
    mean(abs(motion_mmPerSec(cycleSplitIndex:end)-vSmoothWeightedAverage_mmPerSec(cycleSplitIndex:end)))
    %sure close to MRI
    %set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
    
    %print the error
    hold off;
    
    xlabel('time (sec)');
    ylabel('velocity (mm/sec)');
    title(['Averaged Muscle Signed Speed for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
    legend([ hWeightedSmooth hMriROI(1)], 'Tracked Velocity', 'Actual Velocity');
    
end

if false
    figureList(end+1)=createFigure;
    
    hMri=plot(mriTSync_sec,mriAllVelocity_mmPerSec); %stop of
    set(hMri,'Color',[0.5 0.5 0.5]);
    hold on
    hMriROI=plot(mriTSync_sec,mriRoiVelocity_mmPerSec); %stop of
    set(hMriROI,'Color',0*[0.1 0.1 0.1],'linewidth',2);
    
    hForSmooth=plot(t_sec,vSmooth_mmPerSec,'linewidth',2,'Color',0.5*[0 1 0]);
    hBackSmooth=plot(t_sec,vBackwardSmooth_mmPerSec,'linewidth',2,'Color',0.5*[1 0 0]);
    
    %     aligned.ultrasound.vPtAvg_mmPerSec=vPtAvg_mmPerSec;
    % aligned.ultrasound.vPtAvgBackward_mmPerSec=vPtAvgBackward_mmPerSec;
    % aligned.ultrasound.vPtAvgSmooth_mmPerSec=vPtAvgSmooth_mmPerSec;
    % aligned.ultrasound.vPtAvgBackwardSmooth_mmPerSec=vPtAvgBackwardSmooth_mmPerSec;
    
    hForPtAvgSmooth=plot(t_sec,vPtAvgSmooth_mmPerSec,'linewidth',1,'Color',0.7*[0 0 1]);
    hBackPtAvgSmooth=plot(t_sec,vPtAvgBackwardSmooth_mmPerSec,'linewidth',1,'Color',0.7*[1 0 1]);
    hold off;
    xlabel('time (sec)');
    ylabel('signed speed (mm/sec)');
    title(['Averaged Muscle Signed Speed for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
    legend([ hForSmooth hBackSmooth hForPtAvgSmooth hBackPtAvgSmooth hMri(1) hMriROI(1)], 'forward light smoothing','backward light smoothing', 'forward pt avg smoothed','backward pt avg smoothed','MRI','MRI ROI');
end


end

function f1=createFigure
%f1=figure('units','normalized','outerposition',[0 0 1 1])
f1=figure('units','normalized','outerposition',[0.1 0.1 0.7 0.7]);
end