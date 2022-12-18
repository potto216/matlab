%The output is an indexed tracklet data structure, where each cell contains
%a list of track information for a unique track number over the frames
%The returned indexes are
%1 - unique trackid
%2 - track frame list index number
%3 - pt (row)
%4 - pt (column)
%5 - source tracklist id
%6 - total length of the track

function trackletDb=trackletExtract(trackFrameList,sourceFrameTrackList)
if max(arrayfun(@(t) max(t.trackletListId),trackFrameList))>=1e6
    error('max trackid of 1e6 fails and must be revised.');
end

trackletBlock=arrayfun(@(t,f,s) [(double(t.trackletListId)+double(1e6*s.trackletListId)); double(repmat(f,size(t.trackletListId))); ...
    double(t.pt_rc); double(s.trackletListId); double(t.trackletListLength)],trackFrameList.',1:length(trackFrameList),sourceFrameTrackList.','UniformOutput',false);

%The idea is to make a list of unique ids sorted in increasing order of the
%frame numbers.  Then the those blocks of track ids over frames can be captured
trackletBlock=cell2mat(trackletBlock);
trackletBlock=sortrows(trackletBlock',[1 2]).'; %sort by id,frame
trackEndIndex=[find(diff(trackletBlock(1,:))) size(trackletBlock,2)]; %find where a unique track id list ends
trackStartIndex=[1 (trackEndIndex(1:(end-1))+1)];
trackletDb=arrayfun(@(si,ei) trackletBlock(:,si:ei),  trackStartIndex,trackEndIndex,'UniformOutput',false);
end

