function [ track ] = calcTrackletLength( track )
%CALCTRACKLETLENGTH Find the tracklet length from the tracklet counts and
%back assigns it to all of the tracklet points.  This can be used to
%compute the head and tail and select tracklets based on length.  This
%function is not designed to be fast, but instead to double check work and
%be accurate.

tracklet.active.row.id=1;
tracklet.active.row.position=2;
tracklet.active.row.length=3;
activeIdList=[];
activeIdTrackletLengthList=[];
retiredIdList=[];  %once retired the ids should not appear again

for ii=length(track):-1:1
    disp(['calcTrackletLength processing track ' num2str(ii)]);
    %look for tracks that have stopped being tracked.  These will be moved
    %to the retired list
    activeIdNowMissingList=setdiff(activeIdList,track(ii).trackletListId);
    retiredIdList=[retiredIdList activeIdNowMissingList];
    
    if length(retiredIdList)~= length(unique(retiredIdList))
        error('Duplicate ids trying to be retired.');
    end
    
    if ~isempty(intersect(track(ii).trackletListId,retiredIdList))
        error('the track id list should never have a retired track in it.');        
    end
    
    originalActiveIdListLength=length(activeIdList);
    
    %Keep only the active ids that exist in the current track
    [~,activeIdListIndex]=intersect(activeIdList,track(ii).trackletListId);
    activeIdNowMissingIndex=setdiff(1:length(activeIdList),activeIdListIndex);
    %remove the tracks that are not active
    activeIdList(activeIdNowMissingIndex)=[];
    activeIdTrackletLengthList(activeIdNowMissingIndex)=[];
    
    if (length(activeIdList)+length(activeIdNowMissingList)) ~= originalActiveIdListLength
        error('Active Id list length does not match.');
    end
    
    %check for any tracks that are new.  If so we need to get the count and
    %assign it to the length count.
    newIdList=setdiff(track(ii).trackletListId,activeIdList);    
    newIdListIndex=arrayfun(@(x) find(x==track(ii).trackletListId),newIdList);
    %newIdactiveIdTrackletLengthList=arrayfun(@(x) find(x==track(ii).trackletListId),newIdList);
    newIdListIndex=arrayfun(@(x) find(x==track(ii).trackletListId),newIdList);
    newLengthList=track(ii).trackletListPosition(newIdListIndex);
    
    activeIdList=[activeIdList newIdList];
    activeIdTrackletLengthList=[activeIdTrackletLengthList newLengthList];
        
    %now the active list length 
    if length(activeIdList) ~= length(activeIdTrackletLengthList)
        error('activeIdList and activeIdTrackletLengthList is out of sync.');
    end
    
    %Now lookup the id's there should be a one to one match between the
    %current tracklet frame and the active id list
    trackletListIndex=arrayfun(@(x) find(x==track(ii).trackletListId),activeIdList);        
    track(ii).trackletListLength(trackletListIndex)=activeIdTrackletLengthList;
    
    if ~all(track(ii).trackletListPosition<=track(ii).trackletListLength)
        error('position is not less than or equal to the length.');
    end

    if track(ii).trackletListPosition==0
        error('position was zero.');
    end    
end

end

function tmp
    trackSingletonIndexList=find(activeTrackletList(tracklet.active.row.length,trackFailIdx)==1);
    trackEndIndexList=find(activeTrackletList(tracklet.active.row.length,trackFailIdx)>1);
    
    if ~isempty(trackSingletonIndexList)
        %We know if the features were in the last frame then they should
        %have the same order as these
        if ii==1
            error('This should never run on the first frame.');
        end
        if ~all(track(ii-1).trackletList(tracklet.active.row.id,trackSingletonIndexList)==activeTrackletList(tracklet.active.row.id,trackSingletonIndexList))
            error('The track ids have lost sync between frame ii-1 and frame ii');
        end
        track(ii-1).trackletList(tracklet.active.row.state,trackSingletonIndexList)=tracklet.active.state.trackletSingleton;
                
    else
        %do nothing
    end
  
    if ~isempty(trackEndIndexList)
        if ii==1
            error('This should never run on the first frame.');
        end
        if ~all(track(ii-1).trackletList(tracklet.active.row.id,trackEndIndexList)==activeTrackletList(tracklet.active.row.id,trackEndIndexList))
            error('The track ids have lost sync between frame ii-1 and frame ii');
        end
        track(ii-1).trackletList(tracklet.active.row.state,trackEndIndexList)=tracklet.active.state.trackletEnd;
    else
        %do nothing
    end    
end