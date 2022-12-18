function [regionBox_rc, regionBoxCenter_rc,regionBoxOffset_rc,fullTrackPath_rc,fullTrackPathDelta_rc,trackLength,matchList,dataInfo]=trackstitch(trackff,dataBlockObj)
skipMaskVideo=true;
trackFilename='13-35-09';
rfBasefilename='';
showGUI=false;
showTrackVideo=false;

p = inputParser;   % Create an instance of the class.
p.KeepUnmatched=true;
p.addRequired('trackff', @(x) isstruct(x));
p.addRequired('dataBlockObj', @(x) isa(x,'DataBlockObj'));
p.parse(trackff,dataBlockObj);

imBlock=dataBlockObj.blockData;

maxPointsInTrack=max(arrayfun(@(x) size(x.pt_rc,2),trackff));

matchList=cell(maxPointsInTrack,length(trackff)-1);

for ii=1:(length(trackff)-1)
    disp(['Processing frame ' num2str(ii)])
    
    %For a given frame take all of the tracks in the current frame and see where they determine
    %they will be in the next frame
    predict_rc=trackff(ii).pt_rc+trackff(ii).ptDelta_rc;
    
    %compare the prediction to where actual tracks end up in current frame
    %+ 1  The find could match to multiple tracks
    findTrackMatchIndex = @(x) find(all(abs(repmat(x,[1,size(trackff(ii+1).pt_rc,2)])-trackff(ii+1).pt_rc)<=1,1));
    
    colToAdd=reshape(colvecfun(@(x) findTrackMatchIndex(x),predict_rc,'UniformOutput',false),[],1);
    %each column could be composed of zero,1 or more tracks
    matchList(1:size(colToAdd,1),ii)=colToAdd;
    
    %     all(cellfun(@(x) any(length(x)==[0 1]),matchList(1:size(colToAdd,1),ii)))
    %     find(~cellfun(@(x) any(length(x)==[0 1]),matchList(1:size(colToAdd,1),ii)))
    
end

%%
badColumns=[1:15 475:size(imBlock(:,:,1),2)];
%badColumns=[0];
trackLength=zeros(size(matchList));
trackPathList=cell(size(matchList));
for trackIndex=1:size(trackLength,1)
    for frameIndex=1:size(trackLength,2)
        
        hopCount=0;
        
        if ~isempty(matchList{trackIndex,frameIndex}) && ~any(trackff(frameIndex).pt_rc(2,trackIndex)==badColumns)
            
            frameIndexJmp=frameIndex;
            trackIndexPtr=trackIndex;
            hopPath_trackFrameIndex=[trackIndexPtr; frameIndexJmp];
            while(true)
                
                nextHop=matchList{trackIndexPtr,frameIndexJmp};
                if isempty(nextHop) || frameIndexJmp==size(matchList,2);
                    break;
                elseif ~isempty(nextHop)
                    hopCount=hopCount+1;
                    frameIndexJmp=frameIndexJmp+1;
                    %next hop could contain multiple hops, for now lets
                    %only choose the first one, but print how many were
                    %found.
                    trackIndexPtr=nextHop(1);
                    hopPath_trackFrameIndex=[hopPath_trackFrameIndex [trackIndexPtr; frameIndexJmp]];
                end
            end
            trackPathList{trackIndex,frameIndex}=hopPath_trackFrameIndex;
        else
            %do nothing
        end
        
        trackLength(trackIndex,frameIndex)=hopCount;
    end
end
disp('Finished building trackPathList');

%% Build the merged tracks
%The hop count includes the current position
currentFrameIndex=1;
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
while((currentTrackHopCount+currentFrameIndex)<(size(trackLength,2)))
    switch(bundleOption)
        case 'bundleByLength'
            [nextTrackHopCount, nextTrackIndex]=max(trackLength(:,currentTrackHopCount+currentFrameIndex));
            
        case 'bundleByRegion'
            minimumTrackLength=3;
            validTracksForBundle=find(trackLength(:,currentTrackHopCount+currentFrameIndex)>=minimumTrackLength);
            %not optimal should use where the track ends
            
            tracksToCompare_rc=trackff(currentTrackHopCount+currentFrameIndex).pt_rc(:,validTracksForBundle);
            originalTrack_rc=trackff(currentFrameIndex).pt_rc(:,nextTrackIndex);
            lastTrackFrame=trackPathList{nextTrackIndex,currentFrameIndex}(:,end);
            originalTrack_rc=trackff(lastTrackFrame(2)).pt_rc(:,lastTrackFrame(1));
            
            
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
end

disp('Finished computing the new track')

%% Now make a final track
fullTrackPath_rc=zeros(2,(size(trackLength,2)));
fullTrackPathDelta_rc=zeros(2,(size(trackLength,2)));
for ii=1:length(dataInfo)
    frameIndex=dataInfo(ii).frameIndex;
    hopCount=dataInfo(ii).hopCount;
    trackIndex=dataInfo(ii).trackIndex;
    for tt=0:(hopCount)
        fullTrackPath_rc(:,frameIndex+tt)=trackff(frameIndex+tt).pt_rc(:,trackIndex);
        fullTrackPathDelta_rc(:,frameIndex+tt)=trackff(frameIndex+tt).ptDelta_rc(:,trackIndex);
        trackIndex=matchList{trackIndex,frameIndex+tt}; %update to the next track index
        %!@#$ This is not optimal
        if ~any(length(trackIndex)==[1 0])
            trackIndex=trackIndex(1);
        end
    end
end
validFullTrackPathIndex=~((fullTrackPath_rc(1,:)==0) | (fullTrackPath_rc(2,:)==0));
regionBox_rc=[min(fullTrackPath_rc(:,validFullTrackPathIndex),[],2) max(fullTrackPath_rc(:,validFullTrackPathIndex),[],2)];
regionBoxCenter_rc=mean(regionBox_rc,2);
regionBoxOffset_rc=cumsum(fullTrackPathDelta_rc,2);


if false
    save('test2.mat','fullTrackPath_rc','fullTrackPathDelta_rc','regionBoxCenter_rc','regionBoxOffset_rc');
end
end