%INPUT
% motionModel={'cmm','speed'} This decides if the ccm assumption of lateral
% only on a cmm grid is used or just speed tracking
%
%OUTPUT
%X(1,:) is the RF in mm/frame  (rfFramesPerSec)
%X(2,:) is the motion capture in deg/frame (rfFramesPerSec not motion capture frames per sec)

%The negative motion capture angle means the angle is decreasing so the foot is performing dorsiflexion
%The entire data set is used as the data set
%
%The positive motion capture angle means the angle is increasing so the foot is performing plantarflexion 
%The entire data set is used as the data set
%
%For Hand syncronization set a breakpoint at the end of the main code then
%run the cell titled "Hand syncronization"
%
%lateral_mm - assuming a uniform smaple grid this is the spacing between
%   points which could differ from the transducer resolution if the grid is
%   oversampled or curved.
%axial_mm - assuming a uniform smaple grid this is the spacing between
%   points which could differ from the transducer resolution if the grid is
%   oversampled or curved.

function [trackCombine,motionCaptureResampledSyncedWithRF, lateral_mm,axial_mm,rfFramesPerSec]=loadCaseRFMotionCapture(trialName,matTrueFilepath,matTrackFilename,syncManualAdjust_sec)


caseData=loadCaseData(fullfile(matTrueFilepath.root,matTrueFilepath.relativeCase,[trialName '.m']));

transducerLateral_mm=getCaseRFUnits(caseData,'lateral','mm');
transducerAxial_mm=getCaseRFUnits(caseData,'axial','mm');
rfFramesPerSec=getCaseDataFrameRate(caseData,'rf');
trackData=loadTrackDataSettingsManual;

[motionCapture.data_deg, motionCapture.fps,motionCapture.t_sec]=getCaseDataIR(caseData);


if isempty(matTrackFilename)
    matTrackFilename=trackData.(trialName)(1).calibrateFilename;
else
    %use existing term
end

dfIndex=1;
df=load(fullfile(matTrueFilepath.root,matTrueFilepath.relativeTrack,trialName,matTrackFilename),'userSettings','track','matLatticeFilename','matFilepath','matTrackFilename','processingTableIndex','generateLatticeData');

[lateral_mm,axial_mm,validTracks]=latticeComputeDistance(df,transducerLateral_mm,transducerAxial_mm);

trackCombine=[];
ff=1;
trackCombine(ff).X_pelPerFrame=cell2mat(arrayfun(@(x) x.ptDelta_rc(2,validTracks)',df(dfIndex).track,'UniformOutput',false));
trackCombine(ff).Y_pelPerFrame=cell2mat(arrayfun(@(x) x.ptDelta_rc(1,validTracks)',df(dfIndex).track,'UniformOutput',false));
trackCombine(ff).T_sec=repmat(((1:size(trackCombine(ff).Y_pelPerFrame,2))-1)/rfFramesPerSec,size(trackCombine(ff).Y_pelPerFrame,1),1);
trackCombine(ff).X_mmPerFrame=trackCombine(ff).X_pelPerFrame*lateral_mm;
trackCombine(ff).Y_mmPerFrame=trackCombine(ff).Y_pelPerFrame*axial_mm;

% addpath(fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\data\Walkaid'));
% trackData=loadTrackDataSettingsManual;
%rfFramesPerSecond=getCaseDataFrameRate(caseFullFilename,'rf');
%rfTime_Sec=(1:length(userSplineMotion_mmPerSec))/rfFramesPerSecond+trackData.(caseName).timeOffsetMotionCaptureToTrack_sec;



if false
%%
    figure;
    subplot(1,2,1)
    hist(trackCombine(ff).X_mmPerFrame(:),101); 
    title([ matTrackFilename ' X delta hist'],'interpreter','none');
    xlabel('mm');
    ylabel('count');
    
    subplot(1,2,2)
    hist(trackCombine(ff).Y_mmPerFrame(:),101); 
    title('Y delta hist','interpreter','none');
    xlabel('mm');
    ylabel('count');
    
end

if isempty(motionCapture.data_deg)
    error(['No motion capture data for ' trialName ' rf file ' caseData.rfFilename]);
else
    %do nothing
end



%%

%If the trial name exists then try to load the preset valies
if isfield(trackData,trialName)   
    trialDataset=trackData.(trialName);
    scaleMotionCaptureToRF=[];
    timeOffsetMotionCaptureToTrack_sec=[];
    for cfIndex=1:length(trialDataset)
        if strcmp(trialDataset(cfIndex).calibrateFilename,matTrackFilename)
            scaleMotionCaptureToRF=trialDataset(cfIndex).scaleMax;
            timeOffsetMotionCaptureToTrack_sec=trialDataset(cfIndex).timeOffsetMotionCaptureToTrack_sec;
            maxLag_sample=trialDataset(cfIndex).maxSearchLagForOptimum_sample;
            break;
        else
            %do nothing
        end
    end
    %If the timeoffset is empty then use the last valid index for that
    %trial
    if isempty(timeOffsetMotionCaptureToTrack_sec)
        timeOffsetMotionCaptureToTrack_sec=trialDataset(cfIndex).timeOffsetMotionCaptureToTrack_sec;
        scaleMotionCaptureToRF=trialDataset(cfIndex).scaleMax;
        maxLag_sample=trialDataset(cfIndex).maxSearchLagForOptimum_sample;
        disp(['Could not find match for ' matTrackFilename ' using offset time of ' num2str(timeOffsetMotionCaptureToTrack_sec)]);
    else
        %do nothing
    end
            
else
    scaleMotionCaptureToRF=[];
    timeOffsetMotionCaptureToTrack_sec=[];
    maxLag_sample=0;
end

if  isempty(scaleMotionCaptureToRF)
    disp(['No data found for ' trialName ' using defaults.']);
    scaleMotionCaptureToRF=1;
    if isempty(timeOffsetMotionCaptureToTrack_sec)
        timeOffsetMotionCaptureToTrack_sec=0;
    end
end



%resample the motion capture data to match the time of the rf data.
motionCaptureResampledSyncedWithRF.t_sec=trackCombine(ff,1).T_sec(1,:);
motionCaptureResampledSyncedWithRF.data_deg=interp1(motionCapture.t_sec+timeOffsetMotionCaptureToTrack_sec,motionCapture.data_deg, ...
motionCaptureResampledSyncedWithRF.t_sec,'spline',NaN);

indexesToTrim=isnan(motionCaptureResampledSyncedWithRF.data_deg);
if any(indexesToTrim)
    motionCaptureResampledSyncedWithRF.t_sec(indexesToTrim)=[];
    motionCaptureResampledSyncedWithRF.data_deg(indexesToTrim)=[];
else
    %don't trim anything
end

motionCaptureResampledSyncedWithRF.data_degPerFrame=diff(motionCaptureResampledSyncedWithRF.data_deg);
motionCaptureResampledSyncedWithRF.data_degPerFrame=[motionCaptureResampledSyncedWithRF.data_degPerFrame ...
    motionCaptureResampledSyncedWithRF.data_degPerFrame(end)];  %make the sample size as the original data
motionCaptureResampledSyncedWithRF.data_degPerSec=motionCaptureResampledSyncedWithRF.data_degPerFrame/rfFramesPerSec;

mark=getCaseMotionTrackDorsiflexPlantarFlexDB(caseData,true);
motionCaptureResampledSyncedWithRF.mark.dorsiflexion=mark.dorsiflexion+timeOffsetMotionCaptureToTrack_sec;
motionCaptureResampledSyncedWithRF.mark.plantarflexion=mark.plantarflexion+timeOffsetMotionCaptureToTrack_sec;





return


%% Hand syncronization

%we want to plot the full motion capture uses the rf sample rate.  The
%purpose of this plot is to aid in aligning the rf and the motion capture.
%It is assumed the motion capture is a longer file than the rf.

totalTimeSamples = floor((motionCapture.t_sec(end)-motionCapture.t_sec(1))*rfFramesPerSec); %#ok<UNRCH>
tMotionCaptureWithRf=(0:(totalTimeSamples-1))/rfFramesPerSec+motionCapture.t_sec(1);
xdFull=interp1(motionCapture.t_sec,motionCapture.data_deg,tMotionCaptureWithRf,'spline');
dxdFull=diff(xdFull);
dxdFull=[dxdFull dxdFull(end)];

f1=figure;
%%
figure(f1);
clf;
%plot(trackCombine(ff).X_pelPerFrame(:),'b')
plot(rfX_mmPerFrame,'b')

hold on;
%plot((1:length(dxdFull))-29,dxdFull,'r')
sampleDelay=-158;
scaleMax=-0.75;
plot((1:length(dxdFull))+sampleDelay,scaleMax*dxdFull,'r')

%% Output
disp(['delay=' num2str(sampleDelay/rfFramesPerSec)]);
matTrackFilename
trialName

disp(['%' trialName ]);
disp(['trackData.' trialName '(1).calibrateFilename=''' matTrackFilename ''';']);
disp(['trackData.' trialName '(1).scaleMax=' num2str(scaleMax) ';']);
disp(['trackData.' trialName '(1).timeOffsetMotionCaptureToTrack_sec=' num2str(sampleDelay/rfFramesPerSec) ';']);
disp(['trackData.' trialName '(1).notes=' ''''';']);
disp(['trackData.' trialName '(1).inlinerMotionCaptureRFTrack=[];']);
disp(['trackData.' trialName '(1).maxSearchLagForOptimum_sample=[];']);
%% Get inliers
%the first point should be the min,min(bottom left) and the next point
%should be max,max(top right)
[gx gy]=ginput(2)
disp(['inlinerMotionCaptureRFTrack=[' num2str(gx(1)) ' ' num2str(gx(2)) ';' num2str(gy(1)) ' ' num2str(gy(2)) '];'])
end

