function [ dMod,aligned ] = makeDMod(d, dataBlockObj,fullTrackPathDelta_rc,fullTrackPathDeltaBackward_rc,distanceMeasure,mriDatabase,imagePlane )
%MAKEDMOD Performs analysis using new track pathes
%   The purpose of this funciton is to process new track pathes that were
%   just added.

dMod=d;

if length(d)~=1
    error('Assumptions are violated');
end

scaleMatrix_mm=diag([dMod.scale_mm(1) dMod.scale_mm(2)]);
%If either the forward or backward track is empty then those results will
%not be computed.  We will compute for a data set the filtered, and
%measured values
[dMod.data.params.smooth.b,dMod.data.params.smooth.a] = butter(1,.4);
[dMod.data.params.smoothHeavy.b,dMod.data.params.smoothHeavy.a] = butter(1,.05);


if ~isempty(fullTrackPathDelta_rc)
    dMod.fullTrackPathDelta_rc=fullTrackPathDelta_rc;
else
    %do nothing
    error('Please change logic to handle no forward tracks');
end

if ~isempty(fullTrackPathDeltaBackward_rc )
    dMod.fullTrackPathDeltaBackward_rc=fullTrackPathDeltaBackward_rc;
    
else
    %do nothing
     error('Please change logic to handle no backward tracks');
end




%This is the velocity of each track computed by the distance method which
%is used to match the MRI method of calculating distance
dMod.v_mmPerSec=calculateDistance(scaleMatrix_mm*dMod.fullTrackPathDelta_rc*dMod.fs,distanceMeasure);
dMod.vBackward_mmPerSec=calculateDistance(scaleMatrix_mm*dMod.fullTrackPathDeltaBackward_rc*dMod.fs,distanceMeasure);

dMod.vSmooth_mmPerSec=filtfilt(dMod.data.params.smooth.b,dMod.data.params.smooth.a,dMod.v_mmPerSec);
dMod.vBackwardSmooth_mmPerSec=filtfilt(dMod.data.params.smooth.b,dMod.data.params.smooth.a,dMod.vBackward_mmPerSec);

dMod.vSmoothHeavy_mmPerSec=filtfilt(dMod.data.params.smoothHeavy.b,dMod.data.params.smoothHeavy.a,dMod.v_mmPerSec);
dMod.vBackwardSmoothHeavy_mmPerSec=filtfilt(dMod.data.params.smoothHeavy.b,dMod.data.params.smoothHeavy.a,dMod.vBackward_mmPerSec);


%this is the displacement motion motion of the tracks
% dMod.regionBoxOffset_rc=cumsum(dMod.fullTrackPathDelta_rc,2);
% dMod.regionBoxOffsetBackward_rc=cumsum(dMod.fullTrackPathDeltaBackward_rc,2);
% 
% dMod.dAll_mm=scaleMatrix_mm*dMod.regionBoxOffset_rc;
% dMod.dBackwardAll_mm=scaleMatrix_mm*dMod.regionBoxOffsetBackward_rc;

dMod.d_mm=calculateDistance(scaleMatrix_mm*cumsum(dMod.fullTrackPathDelta_rc,2),distanceMeasure);
dMod.dBackward_mm=calculateDistance(scaleMatrix_mm*cumsum(dMod.fullTrackPathDeltaBackward_rc,2),distanceMeasure);

dMod.dSmooth_mm=filtfilt(dMod.data.params.smooth.b,dMod.data.params.smooth.a,dMod.d_mm);
dMod.dBackwardSmooth_mm=filtfilt(dMod.data.params.smooth.b,dMod.data.params.smooth.a,dMod.dBackward_mm);

%This is find the velocity by differencing the displacement.  The begin and
%end points are doubled so there is allignmement when the backward track is
%flipped.
dMod.dvSmooth_mmPerSec=diff([dMod.dSmooth_mm dMod.dSmooth_mm(end)])*dMod.fs;
dMod.dvBackwardSmooth_mmPerSec=diff([dMod.dBackwardSmooth_mm(1) dMod.dBackwardSmooth_mm ])*dMod.fs;


%These should be the same as all the other measurements
dMod.t_sec=[0:(size(dMod.fullTrackPathDelta_rc,2)-1)]/dMod.fs;

dMod.mri=mriDatabase.getWaveform(d.trialData,dataBlockObj,imagePlane,false,distanceMeasure);
dMod.distanceMeasure=distanceMeasure;


cycleToAverage_index=(1:min(120,dataBlockObj.size(3)-2));
%%****
mriData_mmPerSec=dMod.mri.data_mmPerSec;
mriT_sec=dMod.mri.t_sec;
mriData_mm=dMod.mri.data_mm;
mriDataIndexOfBestMatch=dMod.mri.dataIndexOfBestMatch;
mriSync_Sec=dMod.mri.sync_sec;
mriSync_displacement=dMod.mri.syncDisplacement;
mriSyncCycleShift=dMod.mri.syncCycleShift;
mriIsFlexion=dMod.mri.isFlexion;

t_sec=dMod.t_sec;
%tv_sec=t_sec(1:end-1);

signFlip=-1;
mriData_mmPerSec=signFlip*mriData_mmPerSec;

%trackChange_frameNumber=dMod.trackChange_frameNumber;
v_mmPerSec=signFlip*dMod.v_mmPerSec;
vBackward_mmPerSec=signFlip*-1*dMod.vBackward_mmPerSec(end:-1:1);

vSmooth_mmPerSec=signFlip*dMod.vSmooth_mmPerSec;
vBackwardSmooth_mmPerSec=signFlip*-1*dMod.vBackwardSmooth_mmPerSec(end:-1:1);

% w=linspace(1, 0, length(cycleToAverage_index));
% alignOffset=d_mm(cycleToAverage_index(1))-dBackward_mm(cycleToAverage_index(1));


vSmoothHeavy_mmPerSec=signFlip*dMod.vSmoothHeavy_mmPerSec;
vBackwardSmoothHeavy_mmPerSec=signFlip*-1*dMod.vBackwardSmoothHeavy_mmPerSec(end:-1:1);

d_mm=dMod.d_mm;
dBackward_mm=dMod.dBackward_mm(end:-1:1);

dSmooth_mm=dMod.dSmooth_mm;
dBackwardSmooth_mm=dMod.dBackwardSmooth_mm(end:-1:1);

dvSmooth_mmPerSec=signFlip*dMod.dvSmooth_mmPerSec;
dvBackwardSmooth_mmPerSec=signFlip*-1*dMod.dvBackwardSmooth_mmPerSec(end:-1:1);

%vWeightedAverage_mmPerSec=signFlip*(w.*v_mmPerSec(cycleToAverage_index)+(1-w).*(vBackward_mmPerSec(cycleToAverage_index)));
vWeightedAverage_mmPerSec=-signFlip*(v_mmPerSec+vBackward_mmPerSec)/2;
vSmoothWeightedAverage_mmPerSec=-signFlip*(vSmooth_mmPerSec + vBackwardSmooth_mmPerSec)/2;

dWeightedAverage_mm=-signFlip*(d_mm+dBackward_mm)/2;
dSmoothWeightedAverage_mm=-signFlip*(dSmooth_mm + dBackwardSmooth_mm)/2;
% dWeightedAverage_mm=(w.*d_mm(cycleToAverage_index)+(1-w).*(dBackward_mm(cycleToAverage_index)+alignOffset));
% dSmoothWeightedAverage_mm=(w.*dSmooth_mm(cycleToAverage_index)+(1-w).*(dBackwardSmooth_mm(cycleToAverage_index)+alignOffset));

aligned=struct([]);
aligned(1).mri.roi.t_sec=mriT_sec+mriSync_Sec;
aligned.mri.roi.velocity_mmPerSec=-circshift(mriData_mmPerSec(:,mriDataIndexOfBestMatch),mriSyncCycleShift);
aligned.mri.roi.displacement_mm  =-circshift(mriData_mm(:,mriDataIndexOfBestMatch),mriSyncCycleShift)+mriSync_displacement;
aligned.mri.isFlexion=circshift(mriIsFlexion,mriSyncCycleShift);

aligned.mri.all.t_sec=mriT_sec+mriSync_Sec;
aligned.mri.all.velocity_mmPerSec=-circshift(mriData_mmPerSec,mriSyncCycleShift);
aligned.mri.all.displacement_mm  =-circshift(mriData_mm,mriSyncCycleShift)+mriSync_displacement;

aligned.ultrasound.t_sec=t_sec;

aligned.ultrasound.v_mmPerSec=v_mmPerSec;
aligned.ultrasound.vBackward_mmPerSec=vBackward_mmPerSec;

aligned.ultrasound.vSmooth_mmPerSec=vSmooth_mmPerSec;
aligned.ultrasound.vBackwardSmooth_mmPerSec=vBackwardSmooth_mmPerSec;

aligned.ultrasound.d_mm=d_mm;
aligned.ultrasound.dBackward_mm=dBackward_mm;

aligned.ultrasound.dSmooth_mm=dSmooth_mm;
aligned.ultrasound.dBackwardSmooth_mm=dBackwardSmooth_mm;

aligned.ultrasound.dvSmooth_mmPerSec=dvSmooth_mmPerSec;
aligned.ultrasound.dvBackwardSmooth_mmPerSec=dvBackwardSmooth_mmPerSec;

aligned.ultrasound.vSmoothHeavy_mmPerSec=vSmoothHeavy_mmPerSec;
aligned.ultrasound.vBackwardSmoothHeavy_mmPerSec=vBackwardSmoothHeavy_mmPerSec;

aligned.ultrasound.vWeightedAverage_mmPerSec=vWeightedAverage_mmPerSec;
aligned.ultrasound.vSmoothWeightedAverage_mmPerSec=vSmoothWeightedAverage_mmPerSec;

aligned.ultrasound.dWeightedAverage_mm=dWeightedAverage_mm;
aligned.ultrasound.dSmoothWeightedAverage_mm=dSmoothWeightedAverage_mm;

aligned.distanceMeasure=distanceMeasure;
dMod.aligned=aligned;
end

