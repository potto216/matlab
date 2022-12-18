%cycleIndexList - provides the flexiablity to specify patient cycles which
%can then be used to match up with gold standard data such as MRI results.
%% Track data
dataBlockObj=getCollection(trialData,'col_ultrasound_bmode');
cycleIndexList=[1;inf];
d=struct([]);
for ii=1:size(cycleIndexList,2)
    cycleIndex=cycleIndexList(:,ii);
    
    
    [directoryName]=tCreateDirectoryName(trialData.track.processStream(1).filepath,'createDirectory',true);
    if isempty(d) && ii==1
        d=load(fullfile(directoryName,'tks_basic','results.mat'), ...
            'regionBox_rc', 'regionBoxCenter_rc','regionBoxOffset_rc','fullTrackPath_rc','fullTrackPathDelta_rc','dataInfo' ,...
            'regionBoxBackward_rc', 'regionBoxCenterBackward_rc','regionBoxOffsetBackward_rc','fullTrackPathBackward_rc', ...
            'fullTrackPathDeltaBackward_rc','dataInfoBackward','trialData','resultsDirectory','resultsFilename');
        
    else
        d(ii)=load(fullfile(directoryName,'tks_basic','results.mat'), ...
            'regionBox_rc', 'regionBoxCenter_rc','regionBoxOffset_rc','fullTrackPath_rc','fullTrackPathDelta_rc','dataInfo' ,...
            'regionBoxBackward_rc', 'regionBoxCenterBackward_rc','regionBoxOffsetBackward_rc','fullTrackPathBackward_rc', ...
            'fullTrackPathDeltaBackward_rc','dataInfoBackward','trialData','resultsDirectory','resultsFilename');
    end
    
    tmp=load(fullfile(directoryName,'tks_basic','tkl_regionAll','results.mat'),'trackList','trackListBackward','trackLength','trackLengthBackward','trackPathList','trackPathListBackward','matchList','matchListBackward');
    
    d(ii).trackList=tmp.trackList;
    d(ii).trackListBackward=tmp.trackListBackward;
    d(ii).trackLength=tmp.trackLength;
    d(ii).trackLengthBackward=tmp.trackLengthBackward;
    d(ii).trackPathList=tmp.trackPathList;
    d(ii).trackPathListBackward=tmp.trackPathListBackward;
    d(ii).matchList=tmp.matchList;
    d(ii).matchListBackward=tmp.matchListBackward;
    clear tmp;
    
    
    %     [d(ii).regionBox_rc, d(ii).regionBoxCenter_rc,d(ii).regionBoxOffset_rc,d(ii).fullTrackPath_rc,d(ii).fullTrackPathDelta_rc,d(ii).trackLength,d(ii).matchList,d(ii).dataInfo ,...
    %         d(ii).regionBoxBackward_rc, d(ii).regionBoxCenterBackward_rc,d(ii).regionBoxOffsetBackward_rc,d(ii).fullTrackPathBackward_rc,d(ii).fullTrackPathDeltaBackward_rc,d(ii).trackLengthBackward,d(ii).matchListBackward,d(ii).dataInfoBackward]=trackstitchCycle(track,trackBackward,dataBlockObj,cycleIndex);
    %
    d(ii).scale_mm(1)=dataBlockObj.getUnitsValue('axial','mm');
    d(ii).scale_mm(2)=dataBlockObj.getUnitsValue('lateral','mm');
    d(ii).trackChange_frameNumber=[d(ii).dataInfo.frameIndex];
    d(ii).trackChangeBackward_frameNumber=[d(ii).dataInfoBackward.frameIndex];
    d(ii).fs=dataBlockObj.getUnitsValue('frameRate','framePerSec');
    d(ii).t_sec=[0:(size(d(ii).regionBoxOffset_rc,2)-1)]/d(ii).fs;
    
    
    d(ii).dAll_mm=diag([d(ii).scale_mm(1) d(ii).scale_mm(2)])*d(ii).regionBoxOffset_rc;
    d(ii).dBackwardAll_mm=diag([d(ii).scale_mm(1) d(ii).scale_mm(2)])*d(ii).regionBoxOffsetBackward_rc;
    
    d(ii).d_mm=signedDistance(d(ii).dAll_mm,2);
    d(ii).dBackward_mm=signedDistance(d(ii).dBackwardAll_mm,2);
    
    %     d(ii).d_mm=(d(ii).regionBoxOffset_rc(2,:)*d(ii).scale_mm(2));
    %     d(ii).dBackward_mm=(d(ii).regionBoxOffsetBackward_rc(2,:)*d(ii).scale_mm(2));
    
    [d(ii).data.params.smooth.b,d(ii).data.params.smooth.a] = butter(1,.1);
    d(ii).dSmooth_mm=filtfilt(d(ii).data.params.smooth.b,d(ii).data.params.smooth.a,d(ii).d_mm);
    d(ii).dBackwardSmooth_mm=filtfilt(d(ii).data.params.smooth.b,d(ii).data.params.smooth.a,d(ii).dBackward_mm);
    
    d(ii).v_mmPerSec=diff(d(ii).d_mm)*d(ii).fs;
    d(ii).vSmooth_mmPerSec=diff(d(ii).dSmooth_mm)*d(ii).fs;
    
    d(ii).vBackward_mmPerSec=diff(d(ii).dBackward_mm)*d(ii).fs;
    d(ii).vBackwardSmooth_mmPerSec=diff(d(ii).dBackwardSmooth_mm)*d(ii).fs;
    
end

disp(['Ready to show the results.']);
return;
%%
showDisplay=false;
if showDisplay
    %%
    ii=1;
    showTrackstitch(dataBlockObj, d(ii).regionBoxCenter_rc,d(ii).regionBoxOffset_rc,  d(ii).fullTrackPath_rc ,true,[dataBlockObj.activeCaseName ],[]);
    
    showTrackstitchDetails(dataBlockObj, [], d(ii).matchList, d(ii).trackLength);
    title('Forward');
    
    showTrackstitchDetails(dataBlockObj,[], d(ii).matchListBackward, d(ii).trackLengthBackward);
    title('Backward');
end



%% Load MRI data
fullPath='E:\Users\potto\ultraspeck\workingFolders\potto\MATLAB\trackingMRIvsUS';
mriDataFilename='MRIData.xlsx';
mriData_mmPerSec=xlsread(fullfile(fullPath,mriDataFilename));
mriTs_sec=0.083333333;
mriT_sec=[0:(size(mriData_mmPerSec,1)-1)]*mriTs_sec;
mriData_mm=cumsum(mriData_mmPerSec,1)*mriTs_sec;
% [ positionDeltaManualTrack_rcSlice ] = loadManualTrack(fullfile(fullPath,'18-50-32manual.mat') );
% positionManualTrack_rc=cumsum(positionDeltaManualTrack_rcSlice(1:2,:),2);
% 
% manualTrack_mm=signedDistance(diag(scale_mm)*positionManualTrack_rc,2);
manualTrack_mm=[];


%% Show results
[~, rfBasefilename, ext]=fileparts(dataBlockObj.blockSource);
rfBasefilename=[rfBasefilename ext];
switch(rfBasefilename)
    
    case '18-50-32.b8'
        mriSync_Sec=0.6486;
        mriSync_displacement=-17.2234;
        mriSyncCycleShift=3;
        cycleToAverage_index=[1:120];
    case '18-53-49.b8'
        mriSync_Sec=0.15;
        mriSync_displacement=-4.1;
        mriSyncCycleShift=3;
        cycleToAverage_index=[1:120];
    case '19-10-13.b8'
        mriSync_Sec=0.1+3.0484;
        mriSync_displacement=-4.1 -7.5362;
        mriSyncCycleShift=3;
        cycleToAverage_index=[1:120];
    otherwise
        mriSync_Sec=0.1+3.0484;
        mriSync_displacement=-4.1 -7.5362;
        mriSyncCycleShift=3;
        cycleToAverage_index=[1:120];
end
expRunTrack_show(rfBasefilename,mriData_mmPerSec,mriT_sec,mriData_mm,d(1),mriSync_Sec,mriSync_displacement,mriSyncCycleShift,cycleToAverage_index,manualTrack_mm);


return;
%% Create a track histogram
histn([track.ptDelta_rc])
title(['Histogram of track changes for ' rfBasefilename])
xlabel('axial motion (pel)');
ylabel('lateral motion (pel)');
zlabel('Count')
imExample=dataBlockObj.getSlice(4,[]);
histn([track.pt_rc],imExample)
title(['Location of high density tracking features for ' rfBasefilename])

%%
dataTip_xy=cell2mat(arrayfun(@(x) x.Position(:), cursor_info,'UniformOutput',false))
[sx,si]=sort(dataTip_xy(1,:))
avgData_xy=dataTip_xy(:,si);


switch(rfBasefilename)
    
    case '18-50-32.b8'
        %18-50-32 Datapoints
        %     0.6607    1.6429    2.5179    3.4821    4.6607    5.6429    6.7321
        %   -11.0414    5.0239  -14.6373   -1.3467  -15.6506    1.4569  -10.6651
        
        avgCycleTime_sec=diff(avgData_xy(1,1:2:end));
        %1.8571    2.1429    2.0714
        
        
        avgSlope_mmPersec=diff(avgData_xy,1,2);
        avgVelocity_mmPersec=avgSlope_mmPersec(2,:)./avgSlope_mmPersec(1,:)
        % 16.3573  -22.4699   13.7829  -12.1366   17.4185  -11.1284
        
    case '18-53-49.b8'
        %18-53-49.b8 Datapoints
        %     0.3036    1.2500    2.1786    3.2321    4.2679    5.3393    6.2500    7.2143
        %    -2.4891   18.4507   -0.3072   16.2976   -4.5666   11.1585   -3.1009   20.0897
        avgCycleTime_sec=diff(avgData_xy(1,1:2:end));
        
        % 1.8750    2.0893    1.9821
        
        avgSlope_mmPersec=diff(avgData_xy,1,2);
        avgVelocity_mmPersec=avgSlope_mmPersec(2,:)./avgSlope_mmPersec(1,:)
        % 22.1251  -20.2009   15.7605  -20.1447   14.6768  -15.6573   24.0495
        
    case '19-10-13.b8'
        %    1.2321    2.3036    3.1429    4.2679    5.1964    6.2679    7.2143
        %   -25.7924    2.4651  -15.2610   12.8166  -20.7359    4.8204  -16.1431
        avgCycleTime_sec=diff(avgData_xy(1,1:2:end));
        %1.9107    2.0536    2.0179
        
        avgSlope_mmPersec=diff(avgData_xy,1,2);
        avgVelocity_mmPersec=avgSlope_mmPersec(2,:)./avgSlope_mmPersec(1,:)
        %  26.7536  -21.6644   22.8597  -39.0504   21.8993  -24.3761
        % 26.3737  -21.1205   24.9579  -36.1335   23.8526  -22.1501
        
    otherwise(['Please add ' rfBasefilename]);
end

%%
