%It uses the forward tracks for the cycle timels
%The cycle time output always starts with a extension and is a complete
%number of cycles (extension/flexion), therefor sometimes a half cycle will be
%cut off to make sure everything is aligned.
%OUTPUT
%vSmoothWeightedAverage_mmPerSec - will be smoother than the input
%vSmoothWeightedAverage_mmPerSec because it is interporlated using interp1
%with pchip
function [cycle, positionData_sec_mm,findFlexionExtension_sec_mm,flexionExtensionFromDisplacement_mmPerSec, ...
    isFlexion,cycleDisplacementError_mm,cycleDisplacement_mm,cycleDisplacementPercentError, ...
    mriCompare]=calcUsMriCycles(trialData,activeProcessStreamIndex,aligned)

%% Get the marked cycle positions
node=tFindNode(trialData,trialData.track.processStream(activeProcessStreamIndex).sourceNode);
data=node.object(trialData);
if ~isempty(strfind(char(data.source),'ultrasound.rf'))
    queryForward={{'source','ultrasound.rf'},{'name','forwardTrackPositionMarked_sec_mm'}};
    %queryBackward={{'source','ultrasound.rf'},{'name','backwardTrackPositionMarked_sec_mm'}};
elseif ~isempty(strfind(char(data.source),'ultrasound.bmode'))
    queryForward={{'source','ultrasound.bmode'},{'name','forwardTrackPositionMarked_sec_mm'}};
    %queryBackward={{'source','ultrasound.bmode'},{'name','backwardTrackPositionMarked_sec_mm'}};
elseif ~isempty(strfind(char(data.source),'fieldii.bmode'))
    error('Please add');   
elseif ~isempty(strfind(char(data.source),'projection'))
   error('Please add');   
else
    error(['Unsupported data source of ' char(data.source)]);
end

[forwardTrack]=structFind(trialData.analysis.track.cyclePeaks, queryForward);
if isempty(forwardTrack)
    error(cell2mat((['Unable to find forward track peak markers for ' [queryForward{:}]])));
end
%[backwardTrack]=structFind(trialData.analysis.track.cyclePeaks, queryBackward);

positionData_sec_mm=[forwardTrack.time_sec; ...
    interp1(aligned.ultrasound.t_sec,aligned.ultrasound.d_mm,forwardTrack.time_sec)];
findFlexionExtension_sec_mm=diff(positionData_sec_mm,1,2);
flexionExtensionFromDisplacement_mmPerSec=findFlexionExtension_sec_mm(2,:)./findFlexionExtension_sec_mm(1,:);
if any(isnan(flexionExtensionFromDisplacement_mmPerSec))
    disp('NaN');
    keyboard
end
isFlexion=(flexionExtensionFromDisplacement_mmPerSec)>0;

%the goal here is to form the cycle times
halfCycleTimes_sec=[forwardTrack.time_sec(1:end-1)' forwardTrack.time_sec(2:end)'];
if size(halfCycleTimes_sec,1)~=length(isFlexion)
    error('halfCycleTimes_sec is not sync with isFlexion');
else
    %do nothing
end


%we will always start with a extension and be a complete number of cycles 
if  isFlexion(1)
    halfCycleTimes_sec=halfCycleTimes_sec(2:end,:);
    isFlexion=isFlexion(2:end);
    positionData_sec_mm=positionData_sec_mm(:,2:end);
    findFlexionExtension_sec_mm=findFlexionExtension_sec_mm(:,2:end);
    flexionExtensionFromDisplacement_mmPerSec=flexionExtensionFromDisplacement_mmPerSec(2:end);
end

%make sure it is a complete number of cycles
if mod(size(halfCycleTimes_sec,1),2)==1
    halfCycleTimes_sec=halfCycleTimes_sec(1:(end-1),:);
    isFlexion=isFlexion(1:(end-1));
    positionData_sec_mm=positionData_sec_mm(:,1:(end-1));
    findFlexionExtension_sec_mm=findFlexionExtension_sec_mm(:,1:(end-1));
    flexionExtensionFromDisplacement_mmPerSec=flexionExtensionFromDisplacement_mmPerSec(1:(end-1));
end

if size(halfCycleTimes_sec,1)<2
    error('Not a complete cycle');
end

vAvgSmooth_mmPerSec=mean([aligned.ultrasound.vSmooth_mmPerSec;aligned.ultrasound.vBackwardSmooth_mmPerSec]);
vSmoothWeightedAverage_mmPerSec=aligned.ultrasound.vSmoothWeightedAverage_mmPerSec;

% rmsError = @(startTime_sec,stopTime_sec) mean(interp1(aligned.ultrasound.t_sec,vAvgSmooth_mmPerSec,linspace(startTime_sec,stopTime_sec,512),'pchip'));
% flexionExtensionFromVelocity_mmPerSec=arrayfun(@(startTime_sec,stopTime_sec), halfCycleTimes_sec(:,1),halfCycleTimes_sec(:,2)) ;

cycleDisplacement_mm = @(startTime_sec,stopTime_sec) sum(interp1(aligned.ultrasound.t_sec,vAvgSmooth_mmPerSec,linspace(startTime_sec,stopTime_sec,512),'pchip'))*((stopTime_sec-startTime_sec)/512);
absCycleDisplacement_mm = @(startTime_sec,stopTime_sec) sum(abs(interp1(aligned.ultrasound.t_sec,vAvgSmooth_mmPerSec,linspace(startTime_sec,stopTime_sec,512),'pchip')))*((stopTime_sec-startTime_sec)/512);

cycleDisplacementFromVelocity_mm=arrayfun(@(startTime_sec,stopTime_sec) cycleDisplacement_mm(startTime_sec,stopTime_sec), halfCycleTimes_sec(:,1),halfCycleTimes_sec(:,2)) ;
absCycleDisplacementFromVelocity_mm=arrayfun(@(startTime_sec,stopTime_sec) absCycleDisplacement_mm(startTime_sec,stopTime_sec), halfCycleTimes_sec(:,1),halfCycleTimes_sec(:,2)) ;


cycleDisplacementError_mm=sum(reshape(cycleDisplacementFromVelocity_mm,2,[]),1);
cycleDisplacement_mm=sum(reshape(absCycleDisplacementFromVelocity_mm,2,[]),1);
cycleDisplacementPercentError=cycleDisplacementError_mm./cycleDisplacement_mm;

%We know the cycles start on a extension cycle
fullCycle_sec=halfCycleTimes_sec(1:2:end,1)';
fullCycleTimes_sec=[fullCycle_sec(1:end-1)' fullCycle_sec(2:end)']';

mriTs_sec=mean(diff(aligned.mri.all.t_sec));

mriCompare=zeros(size(fullCycleTimes_sec,2),size(aligned.mri.all.velocity_mmPerSec,2),2);

%The purpose of this data structure is to provide a way to overlay the
%us and mri cycles for comparison.  For this to work a common time step
%must be choosen.  The time sample is 1/16 of the smallest time difference
%between the us and mri.
cycle=[];
cycle.tDelta_sec=min(mean(diff(aligned.mri.roi.t_sec)),mean(diff(aligned.ultrasound.t_sec)))/16;
mriTDelta_sec=mean(diff(aligned.mri.roi.t_sec));
%first save the MRI cycles
%When we save the cycle we need to make sure since it will be upsamapled
%and since this is a repeating cycle that we extend the cycle to the first
%point of the next cycle.  Then we can integrate and remove the point.
for ff=1:size(aligned.mri.roi.velocity_mmPerSec,2)
    
    startTime_sec=aligned.mri.roi.t_sec(1);
    stopTime_sec =aligned.mri.roi.t_sec(end)+mriTDelta_sec; %add the start of the next cycle
     
    fullCycleExtendedT_sec=cycle.tDelta_sec*(0:(ceil((stopTime_sec-startTime_sec)/cycle.tDelta_sec)-1))+startTime_sec;
    mriCycleExtendedVelocity_mmPerSec=interp1([aligned.mri.roi.t_sec stopTime_sec(end) ],[aligned.mri.roi.velocity_mmPerSec(:,ff); aligned.mri.roi.velocity_mmPerSec(1,ff)] ,fullCycleExtendedT_sec,'pchip');
    
    
    cycle.mri(ff).t_sec=fullCycleExtendedT_sec;
    cycle.mri(ff).velocity_mmPerSec=mriCycleExtendedVelocity_mmPerSec;
    cycle.mri(ff).selectedRoi=aligned.mri.selectedRoi;
    
    if fullCycleExtendedT_sec(end)>=stopTime_sec
        error('Must remove cycles last sample')
    end
end

for ff=1:size(fullCycleTimes_sec,2)
    
    startTime_sec=fullCycleTimes_sec(1,ff);
    stopTime_sec=fullCycleTimes_sec(2,ff);
     
    cycle.ultrasound(ff).t_sec=cycle.tDelta_sec*(0:(ceil((stopTime_sec-startTime_sec)/cycle.tDelta_sec)-1))+startTime_sec;    
    cycle.ultrasound(ff).vAvgSmooth_mmPerSec=interp1(aligned.ultrasound.t_sec,vAvgSmooth_mmPerSec,cycle.ultrasound(ff).t_sec,'pchip');
    cycle.ultrasound(ff).vSmoothWeightedAverage_mmPerSec=interp1(aligned.ultrasound.t_sec,vSmoothWeightedAverage_mmPerSec,cycle.ultrasound(ff).t_sec,'pchip');
    
    
    uDisplacement_mm = cumsum(interp1(aligned.ultrasound.t_sec,vAvgSmooth_mmPerSec,linspace(startTime_sec,stopTime_sec,512),'pchip')*((stopTime_sec-startTime_sec)/512));
        
    for mm=1:size(aligned.mri.all.velocity_mmPerSec,2)
        alignmentList=[];
        avgErrorList_mm=[];
        for aa=0:(size(aligned.mri.all.velocity_mmPerSec,1)-1)
            
            mriCycle_mm=cumsum(circshift(aligned.mri.all.velocity_mmPerSec(:,mm)*mriTs_sec,aa));
            error_mm=interp1(1:length(uDisplacement_mm),uDisplacement_mm,linspace(1,length(uDisplacement_mm),512),'pchip') ...
                - interp1(1:length(mriCycle_mm),mriCycle_mm,linspace(1,length(mriCycle_mm),512),'pchip');
            error_mm=mean(abs(error_mm));
            alignmentList(end+1)=aa; %#ok<AGROW>
            avgErrorList_mm(end+1)=error_mm; %#ok<AGROW>
            
            if false
                %% debug plot
                figure; %#ok<UNRCH>
                plot(interp1(1:length(uDisplacement_mm),uDisplacement_mm,linspace(1,length(uDisplacement_mm),512),'pchip') ,'b');
                hold on
                plot(interp1(1:length(mriCycle_mm),mriCycle_mm,linspace(1,length(mriCycle_mm),512),'pchip'),'r')
            end
        end
        
        [mriCompare(ff,mm,1), idx]=min(avgErrorList_mm);
        mriCompare(ff,mm,2)=alignmentList(idx);
    end
    
end


%%
if false
    %% This is used to save the track velocities
    flexionVelocity_mmPerSec=[]; %#ok<UNRCH>
    extensionVelocity_mmPerSec=[];
    for pp=1:(size(results.ultrasound.forwardTrackPositionMarked_sec_mm,2)-1)
        timeInterval_sec=results.ultrasound.forwardTrackPositionMarked_sec_mm(1,(pp:(pp+1)));
        indexOfPulse=find(results.ultrasound.t_sec>timeInterval_sec(1) & results.ultrasound.t_sec<timeInterval_sec(2));
        valToAvg=results.ultrasound.v_mmPerSec(indexOfPulse);
        veloctitySign=sign(mean(valToAvg));
        
        if veloctitySign>0
            extensionVelocity_mmPerSec=[extensionVelocity_mmPerSec mean(valToAvg)];
        else
            flexionVelocity_mmPerSec=[flexionVelocity_mmPerSec mean(valToAvg)];
        end
    end
    
    %only save when the plots are being marked
    if showPlot.markPositionPlotForward
        save(matResultFilename,'extensionVelocity_mmPerSec','flexionVelocity_mmPerSec','results','trialData');
    end
    
    
    if false
        figure;
        plot(results.ultrasound.t_sec,results.ultrasound.vSmoothHeavy_mmPerSec)
        hold on;
        plot(results.ultrasound.t_sec,results.ultrasound.d_mm,'r')
    end
    
    if ~isempty(OutputPlotsFilename)
        saveppt(OutputPlotsFilename,slideTitle);
        close(gcf);
    end
    
    if false
        %% Show video
        %trackingAnalysis.showFeature([140 141],false,[]);
        dMod.regionBoxCenter_rc=mean(dataBlockObj.regionInformation.region.interiorBoundary_rc,2);
        showTrackstitch(dataBlockObj, dMod.regionBoxCenter_rc,dMod.regionBoxOffset_rc,  [] ,true,[dataBlockObj.activeCaseName ],[]);
    end
    
    
    % %% Run the adaptive processing
    % [totalPtDelta_rc, sourcePtDelta_rc]=trackingAnalysis.genTrackAdaptive([],false,'forward',-dMod.vSmooth_mmPerSec);
    % [totalPtDeltaBackward_rc, sourcePtDeltaBackward_rc]=trackingAnalysis.genTrackAdaptive([],false,'backward',-dMod.vBackwardSmooth_mmPerSec);
    % [ dMod2 ] = makeDMod(d, fullTrackPathDelta_rc,fullTrackPathDeltaBackward_rc );
    %
    % %% Show values from the modified original processing.
    % expRunTrack_show(rfFullFilename,mri.data_mmPerSec,mri.t_sec,mri.data_mm, ...
    %     mri.dataIndexOfBestMatch, dMod2,mri.sync_sec,mri.syncDisplacement,mri.syncCycleShift, ...
    %     cycleToAverage_index, manualTrack_mm);
    %
    % if false
    % %% Show video
    %     trackingAnalysis.showFeature([140 141],false,[]);
    %     dMod2.regionBoxCenter_rc=mean(dataBlockObj.regionInformation.region.interiorBoundary_rc,2);
    %     showTrackstitch(dataBlockObj, dMod2.regionBoxCenter_rc,dMod2.regionBoxOffset_rc,  [] ,true,[dataBlockObj.activeCaseName ],[]);
    % end
end

if length(isFlexion)~=(size(positionData_sec_mm,2)-1)
    error('positionData_sec_mm is not synced with isFlexion');
end
end