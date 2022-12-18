function [regionBox_rc, regionBoxCenter_rc,regionBoxOffset_rc,fullTrackPath_rc,fullTrackPathDelta_rc,dataInfo ,...
    regionBoxBackward_rc, regionBoxCenterBackward_rc,regionBoxOffsetBackward_rc,fullTrackPathBackward_rc,fullTrackPathDeltaBackward_rc,dataInfoBackward ] ...
    =tks_basic(trackList,trackListBackward,trackLength,trackLengthBackward,trackPathList,trackPathListBackward,matchList,matchListBackward,varargin)
     


p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename','results.mat', @(x) (ischar(x)));

p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;


cycleIndex=[1; size(trackPathList,2)];

%% Build the merged tracks
[dataInfo]=buildMergedTracks(trackLength,trackPathList,cycleIndex(1));
[dataInfoBackward]=buildMergedTracks(trackLengthBackward,trackPathListBackward,cycleIndex(1));


disp('Finished computing the new track')

%% Now make a final track
disp('Building final forward track')
[fullTrackPath_rc,fullTrackPathDelta_rc]=buildFinalTrack(trackList,trackLength,matchList,dataInfo);
disp('Building final backward track')
[fullTrackPathBackward_rc,fullTrackPathDeltaBackward_rc]=buildFinalTrack(trackListBackward,trackLengthBackward,matchListBackward,dataInfoBackward);

disp('Building forward region box')
[regionBox_rc,regionBoxCenter_rc,regionBoxOffset_rc]=buildRegionBox(fullTrackPath_rc,fullTrackPathDelta_rc);

[regionBoxBackward_rc,regionBoxCenterBackward_rc,regionBoxOffsetBackward_rc]=buildRegionBox(fullTrackPathBackward_rc,fullTrackPathDeltaBackward_rc);

if ~isempty(resultsDirectory)
    save(fullfile(resultsDirectory,resultsFilename), ...
    'regionBox_rc', 'regionBoxCenter_rc','regionBoxOffset_rc','fullTrackPath_rc','fullTrackPathDelta_rc','dataInfo' ,...
    'regionBoxBackward_rc', 'regionBoxCenterBackward_rc','regionBoxOffsetBackward_rc','fullTrackPathBackward_rc', ...
    'fullTrackPathDeltaBackward_rc','dataInfoBackward','trialData','resultsDirectory','resultsFilename','-v7.3');
else
    %do nothing
end

end


function [dataInfo]=buildMergedTracks(trackLength,trackPathList,currentFrameIndex)
switch(nargin)
    case 2
       %The hop count includes the current position
        currentFrameIndex=1;
    case 3
        %do nothing
    otherwise
        error('Invalid number of input arguments');
end
     
%[currentTrackHopCount, startTrackIndex]=max(trackLength(:,currentFrameIndex));
[sortedTrackHopCount,sortedTrackHopCountIndex]=sort(trackLength(:,currentFrameIndex),'descend');
%**********MAX COUNT GOES HERE
startTrackIndex=sortedTrackHopCountIndex(1);
currentTrackHopCount=sortedTrackHopCount(1);

dataInfo=[];
dataInfo(1).frameIndex=currentFrameIndex;
dataInfo(1).trackIndex=startTrackIndex;
dataInfo(1).hopCount=currentTrackHopCount;
bundleOption='bundleByLength';
nextTrackIndex=startTrackIndex;
loopCount=0;
while((currentTrackHopCount+currentFrameIndex)<(size(trackLength,2)))
    switch(bundleOption)
        case 'bundleByLength'
            [nextTrackHopCount, nextTrackIndex]=max(trackLength(:,currentTrackHopCount+currentFrameIndex));
            
            if nextTrackHopCount==0
                error('Track lockup occured');
            end
        case 'bundleByRegion'
            minimumTrackLength=3;
            validTracksForBundle=find(trackLength(:,currentTrackHopCount+currentFrameIndex)>=minimumTrackLength);
            %not optimal should use where the track ends
            
            tracksToCompare_rc=trackList(currentTrackHopCount+currentFrameIndex).pt_rc(:,validTracksForBundle);
            originalTrack_rc=trackList(currentFrameIndex).pt_rc(:,nextTrackIndex);
            lastTrackFrame=trackPathList{nextTrackIndex,currentFrameIndex}(:,end);
            originalTrack_rc=trackList(lastTrackFrame(2)).pt_rc(:,lastTrackFrame(1));
            
            
            [~,closestTrackIndex]=min(sum(abs(repmat(originalTrack_rc,1,size(tracksToCompare_rc,2))-tracksToCompare_rc).^2,1));
            
            nextTrackIndex=validTracksForBundle(closestTrackIndex);
            nextTrackHopCount=trackLength(nextTrackIndex,currentTrackHopCount+currentFrameIndex);
            
            
        otherwise
            error(['Unsupported bundle option of ' bundleOption]);
    end
    
    
    
    
    currentFrameIndex=currentTrackHopCount+currentFrameIndex;
    currentTrackHopCount=nextTrackHopCount;
    
    dataInfo(end+1).frameIndex=currentFrameIndex;
    dataInfo(end).trackIndex=nextTrackIndex;
    dataInfo(end).hopCount=currentTrackHopCount;
    loopCount=loopCount+1;
    
end

end

function [fullTrackPath_rc,fullTrackPathDelta_rc]=buildFinalTrack(trackList,trackLength,matchList,dataInfo)

fullTrackPath_rc=zeros(2,(size(trackLength,2)));
fullTrackPathDelta_rc=zeros(2,(size(trackLength,2)));
for ii=1:length(dataInfo)
    frameIndex=dataInfo(ii).frameIndex;
    hopCount=dataInfo(ii).hopCount;
    trackIndex=dataInfo(ii).trackIndex;
    for tt=0:(hopCount)
        fullTrackPath_rc(:,frameIndex+tt)=trackList(frameIndex+tt).pt_rc(:,trackIndex);
        fullTrackPathDelta_rc(:,frameIndex+tt)=trackList(frameIndex+tt).ptDelta_rc(:,trackIndex);
        trackIndex=matchList{trackIndex,frameIndex+tt}; %update to the next track index
        %!@#$ This is not optimal
        if ~any(length(trackIndex)==[1 0])
            trackIndex=trackIndex(1);
        end
    end
end
end

function [regionBox_rc,regionBoxCenter_rc,regionBoxOffset_rc]=buildRegionBox(fullTrackPath_rc,fullTrackPathDelta_rc)
validFullTrackPathIndex=~((fullTrackPath_rc(1,:)==0) | (fullTrackPath_rc(2,:)==0));
regionBox_rc=[min(fullTrackPath_rc(:,validFullTrackPathIndex),[],2) max(fullTrackPath_rc(:,validFullTrackPathIndex),[],2)];
regionBoxCenter_rc=mean(regionBox_rc,2);
regionBoxOffset_rc=cumsum(fullTrackPathDelta_rc,2);
end