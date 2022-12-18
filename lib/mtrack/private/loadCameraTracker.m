function [trackList,trackListBackward]=loadCameraTracker(dataBlockObj,cameraTrackerInputFeatureFilemask,cameraTrackerInputFeatureFilemaskBackward)

[trackList]=loadTrack(dataBlockObj,cameraTrackerInputFeatureFilemask);
[trackListBackward]=loadTrack(dataBlockObj,cameraTrackerInputFeatureFilemaskBackward);


end

% x y manual type3d px py pz ident hasprev pcx pcy support
% x : x position of 2D feature point in that image
% y : y position of 2D feature point in that image
% manual : manual feature point (1 yes, 0 no)
% type3d : 0 for no 3D point, 1 for Spherical, 2 for Cartesian
% px : x position of 3D feature point
% py : y position of 3D feature point
% pz : z position of 3D feature point
% ident : unique identifier for a 3D feature point
% hasprev : has a previous feature point (1 yes, 0 no)
% pcx : x position of 2D feature point in the previous image
% pcy : y position of 2D feature point in the previous image
% support : inlier / outlier bitmask

% #FPOINT V2.0
% 446	143	0	2	25.399020417	-5.38543631399	32.9335732638	0	0	0		0	0

%The tracking here is a little different from the tracking in the rest of
%the program because Voodoo lists if the current feature point has a match
%in the previous frame, not if the current feature point has a match in the
%next frame.  Therefore 
function [trackList]=loadTrack(dataBlockObj,cameraTrackerInputFeatureFilemask)
featureTrack=[];
for ii=1:dataBlockObj.size(3)
    featurePointFilename=sprintf(cameraTrackerInputFeatureFilemask,ii);
    [featureTrack(ii).x,featureTrack(ii).y,featureTrack(ii).manual,featureTrack(ii).type3d, featureTrack(ii).px, featureTrack(ii).py, featureTrack(ii).pz, featureTrack(ii).ident, featureTrack(ii).hasprev, featureTrack(ii).pcx, featureTrack(ii).pcy, featureTrack(ii).support] = textread(featurePointFilename,'%f %f %d %d  %f %f %f %d %d %f %f %d', 'headerlines',1);
end

%We need to remove any feature points that do not have a match in the
%previous frame
for ii=1:length(featureTrack)
    noMatchIndex=~featureTrack(ii).hasprev;
    featureTrack(ii).x(noMatchIndex)=[];
    featureTrack(ii).y(noMatchIndex)=[];
    featureTrack(ii).manual(noMatchIndex)=[];
    featureTrack(ii).type3d(noMatchIndex)=[];
    featureTrack(ii).px(noMatchIndex)=[];
    featureTrack(ii).py(noMatchIndex)=[];
    featureTrack(ii).pz(noMatchIndex)=[];
    featureTrack(ii).ident(noMatchIndex)=[];
    featureTrack(ii).hasprev(noMatchIndex)=[];
    featureTrack(ii).pcx(noMatchIndex)=[];
    featureTrack(ii).pcy(noMatchIndex)=[];
    featureTrack(ii).support(noMatchIndex)=[];
end

if ~isempty(featureTrack(1).x)
    error('The assumption of no previous tracks in frame 1 was violated.');
end

if length(featureTrack) ~= dataBlockObj.size(3)
    error('The number of feature tracks does not match the number of images.');
end

%now build the track structure
trackList=struct([]);    
for ii=2:length(featureTrack)   
    
    trackList(ii-1).pt_rc=[featureTrack(ii).pcy'; featureTrack(ii).pcx'];
    trackList(ii-1).ptDelta_rc=[featureTrack(ii).y'; featureTrack(ii).x']-trackList(ii-1).pt_rc;
    avgOffset=mean(abs(trackList(ii-1).ptDelta_rc),2);
    disp(['Processing frame ' num2str(ii-1) ' with an avg offset (row,column) of ' num2str(avgOffset')]);
end



end
%We    should now have a match list which maps a track in one frame to the
%next
