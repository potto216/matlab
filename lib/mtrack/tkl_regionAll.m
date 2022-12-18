function [trackLength,trackLengthBackward,trackPathList,trackPathListBackward,matchList,matchListBackward ]...
    =tkl_regionAll(trackList,trackListBackward,imBlockSize,varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename','results.mat', @(x) (ischar(x)));
p.addParamValue('minBorderDistance_pel',[], @(x) (isempty(x) || isnumeric(x)));
p.addParamValue('badColumns',[], @(x) (isempty(x) || isnumeric(x)));
p.addParamValue('imErodeStrel',[], @(x) (isempty(x) || isa(x,'function_handle')));
p.addParamValue('region',[], @(x) ismatrix(x));
p.addParamValue('sourceTrackList',[], @(x) ismatrix(x));
p.addParamValue('sourceTrackListBackward',[], @(x) ismatrix(x));
p.addParamValue('sourceFilenameList',{},@(x) isempty(x) || iscell(x));
p.addParamValue('multitrackCollection',{},@(x) isempty(x) || iscell(x));


p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;
minBorderDistance_pel=p.Results.minBorderDistance_pel;
region=p.Results.region;
badColumns=p.Results.badColumns;
imErodeStrel=p.Results.imErodeStrel;
sourceTrackList=p.Results.sourceTrackList;
sourceTrackListBackward=p.Results.sourceTrackListBackward;
sourceFilenameList=p.Results.sourceFilenameList;
multitrackCollection=p.Results.multitrackCollection;
if length(trackList)~=length(trackListBackward)
    error('Expected similar lengths');
end
%% remove any points outside the roi
regionMod=region;

if ~isempty(imErodeStrel)
    regionMod.mask = imerode(regionMod.mask,imErodeStrel());
end

if ~isempty(badColumns)
    regionMod.mask(:,1:badColumns(1))=false;
    regionMod.mask(:,(end-badColumns(2)-1):end)=false;
end
%figure; imagesc(region.mask+regionMod.mask)

[filteredTrackList, filteredTrackListInfo]=filterTrackList(trackList,regionMod);
[filteredTrackListBackward, filteredTrackListBackwardInfo]=filterTrackList(trackListBackward,regionMod);

matchList=buildMatchList(filteredTrackList);
matchListBackward=buildMatchList(filteredTrackListBackward);

%%
if ~isempty(badColumns)
    badColumnsAbsolute=[1:badColumns(1) ((imBlockSize(2)-badColumns(2)+1):imBlockSize(2))];
else
    badColumnsAbsolute=[];
end

[trackLength,trackPathList]=buildTrackPath(filteredTrackList,matchList,badColumnsAbsolute);
[trackLengthBackward,trackPathListBackward]=buildTrackPath(filteredTrackListBackward,matchListBackward,badColumnsAbsolute);
disp('Finished building trackPathList');


if ~isempty(resultsDirectory)
    save(fullfile(resultsDirectory,resultsFilename),'trackList','trackListBackward','trackLength','trackLengthBackward', ...
        'trackPathList','trackPathListBackward','matchList','matchListBackward','trialData','resultsDirectory','resultsFilename', ...
        'badColumnsAbsolute','filteredTrackList','filteredTrackListBackward','region','regionMod', ...
        'sourceTrackList','sourceTrackListBackward','sourceFilenameList','filteredTrackListInfo','filteredTrackListBackwardInfo','multitrackCollection','-v7.3');
else
    %do nothing
end

end

function [trackList, filterInfo]=filterTrackList(trackList,region)
filterInfo=struct('validIndexesFromOriginal',[]);
for ii=1:length(trackList)
    pt_rc=fix(trackList(ii).pt_rc);
    ptNext_rc=fix(pt_rc+trackList(ii).ptDelta_rc);
    
    imSize=size(region.mask);
    
    isPtInBounds=pt_rc(1,:)>=1 & pt_rc(2,:)>=1 & ptNext_rc(1,:)>=1 & ptNext_rc(2,:)>=1 ...
        & pt_rc(1,:)<=imSize(1) & pt_rc(2,:)<=imSize(2) & ptNext_rc(1,:)<=imSize(1) & ptNext_rc(2,:)<=imSize(2);
    
    isPtInBoundsIdx=find(isPtInBounds);
    isPtInBoundAndValid=region.mask(sub2ind(size(region.mask),pt_rc(1,isPtInBoundsIdx),pt_rc(2,isPtInBoundsIdx))) ...
        & region.mask(sub2ind(size(region.mask),ptNext_rc(1,isPtInBoundsIdx),ptNext_rc(2,isPtInBoundsIdx)));
    
    isPtInBounds(isPtInBoundsIdx(~isPtInBoundAndValid))=false;
    trackList(ii).pt_rc(:,~isPtInBounds)=[];
    trackList(ii).ptDelta_rc(:,~isPtInBounds)=[];
    
    filterInfo(ii).validIndexesFromOriginal=isPtInBounds;
    
end
end


%For a given frame take all of the tracks in the current frame and see where they determine
%they will be in the next frame.  This function does not attempt to stitch
%the matches together, just do the matches.
function matchList=buildMatchList(trackList)
maxPointsInTrack=max(arrayfun(@(x) size(x.pt_rc,2),trackList));

matchList=cell(maxPointsInTrack,length(trackList)-1);
for ii=1:(length(trackList)-1)
    disp(['Processing frame ' num2str(ii)])
    
    %For a given frame take all of the tracks in the current frame and see where they determine
    %they will be in the next frame
    if isempty(trackList(ii).pt_rc)
        error(['No feature points to track in frame ' num2str(ii) ' could be backward or forward']);
    end
    predict_rc=trackList(ii).pt_rc+trackList(ii).ptDelta_rc;
    
    %     %compare the prediction to where actual tracks end up in current frame
    %     %+ 1  The find could match to multiple tracks
    %     findTrackMatchIndex = @(x) find(all(abs(repmat(x,[1,size(trackList(ii+1).pt_rc,2)])-trackList(ii+1).pt_rc)<=1,1));
    %     colToAdd=reshape(colvecfun(@(x) findTrackMatchIndex(x),predict_rc,'UniformOutput',false),[],1);
    %
    %     %each column could be composed of zero,1 or more tracks, but there
    %     %should be atleast 1 valid track in the set
    %     if ~all(cellfun(@isempty,colToAdd))
    %         matchList(1:size(colToAdd,1),ii)=colToAdd;
    %     else
    %The dimensions will be in (row,column)=(number of tracks in frame N+1,
    %number or tracks in frame N)
    if isempty(trackList(ii+1).pt_rc)
        error(['No feature points to track in frame ' num2str(ii+1) ' could be backward or forward']);
    end
    trackF1=(repmat(permute(predict_rc,[3,2,1]),[size(trackList(ii+1).pt_rc,2),1,1]));
    trackF2=(repmat(permute(trackList(ii+1).pt_rc,[2,3,1]),[1,size(predict_rc,2),1]));
    
    distanceBetweenPoints=(sqrt(sum((trackF2-trackF1).^2,3)));
    %find the min matching track with respect to each frame N index.  This
    %means the index that will be found will be in the frame N+1 array
    [minValue, minIndex]=min(distanceBetweenPoints,[],1);
    
    %The logic is to save all features that are less than or equal to a
    %pixel difference since that has the highest confidence.
    %Next if none of those can be found then expand to a 2 pixel
    %radius.
    %Finally if nothing else can be found just choose the lowest
    %overall distance even though this will probably not match
    %correctly it is a fly wheel to get to the next frame.
    minValueIndex=(minValue<=1);
    if ~any(minValueIndex)
        minValueIndex=(minValue<=2);
        if ~any(minValueIndex)
            minValueIndex=false(size(minValueIndex));
            [~,globalMinValueIndex]=min(minValue);
            minValueIndex(globalMinValueIndex)=true;
        else
            %go ahead and save the index values
        end
    else
        %go ahead and save the index values
    end
    
    
    
    
    if ~any(minValueIndex)
        error('Atleast one value should have been set');
    end
    
    minIndex=minIndex(:);
    colToAddAdjust=num2cell(minIndex); %,ones(size(minIndex,1),1),1);
    colToAddAdjust(minValueIndex)=repmat({zeros(1,0)},sum(minValueIndex),1);
    matchList(1:size(colToAddAdjust,1),ii)=colToAddAdjust;
end

if all(cellfun(@isempty,matchList(:,ii)))
    error('Must get some matches');
end

end


%this function will stitch the matches together to form a track
function [trackLength,trackPathList]=buildTrackPath(trackList,matchList,badColumns)

trackLength=zeros(size(matchList));
trackPathList=cell(size(matchList));
for trackIndex=1:size(trackLength,1)
    for frameIndex=1:size(trackLength,2)
        
        hopCount=0;
        
        %Make sure there is a match at that index and that the physical
        %location of where the point is is not a bad column (for bmode
        %images)
        if ~isempty(matchList{trackIndex,frameIndex}) && ~any(round(trackList(frameIndex).pt_rc(2,trackIndex))==badColumns)
            
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


badTracks=setdiff(find(all(trackLength==0,1)),size(trackLength,2));  %drop the last track since it is always bad because there is nothing to jump to
if ~isempty(badTracks)
    error(['Bad tracks found for frame indexes(could be backward or forward) of:' num2str(badTracks)]);
else
    
end
end
