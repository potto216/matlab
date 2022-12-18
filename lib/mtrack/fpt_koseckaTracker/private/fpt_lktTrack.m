% Functionality:
% The main script is called trackTK.m. It will called the other routines. The result is saved in a Matlab 
% data file called result.mat. It will have four variables: good featx featy featq. good is information about whether a feature is present on a given time instance. featx and featy records the x-y position. The corresponding feature quality is encoded in featq.
% 
% How it works:
% The main script will first setup the running environment for the track, i.e. all the constants.
% Then it will select some feature points (fewer than the user-specified maximum) from the first image.
% (This step can disable. You can manually specify the feature position.) Then it goes into a loop to 
% track features from image to image. The script is currently set up for the L-K-T tracker.
% But you can replace the routine to make it work with J-F-S tracker.
% 
%
%INPUT
%skipImageCreate = [forward backward]
% 
%AUTHOR
% Hailin Jin and  Paolo Favaro
% Washington University
% October 18, 2001
% modified: Jana Kosecka
%
%REFERENCES
% For more details on the algorithm, please refer to
% B. D. Lucas and T. Kanade. An iterative image registration technique with an application to stereo vision. In International Joint Conference on Artificial Intelligence, 1981.
% C. Tomasi and J. Shi. Good features to track. In IEEE Computer Vision and Pattern Recognition, 1994.
% H. Jin, P. Favaro and S. Soatto. Real-time feature tracking and outlier rejection with changes in illumination. In International Conference on Computer Vision, 2001.
function [trackList,trackListBackward]=fpt_lktTrack(trialData,dataBlockObj, ...
    trackForward,trackBackward,detectionName,correspondenceAnalysisName, varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename','results.mat', @(x) (ischar(x)));
p.addParamValue('correspondenceAnalysis',[],@(x) isempty(x) || isstruct(x));
p.addParamValue('detection',[],@(x) isempty(x) || isstruct(x));

p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;
correspondenceAnalysis=p.Results.correspondenceAnalysis;
detection=p.Results.detection;

imBlockSize=[dataBlockObj.size(1) dataBlockObj.size(2) dataBlockObj.size(3)];

if ~isempty(detection) && ~strcmpi(detection.name,detectionName)
    error('The detection name does not match.');
end

if ~isempty(correspondenceAnalysis) && ~strcmpi(correspondenceAnalysis.name,correspondenceAnalysisName)
    error('The correspondenceAnalysis name does not match.');
end

blockData=dataBlockObj.getSlice(1:dataBlockObj.size(3));

if (any(blockData(:)<0) || any(blockData(:)>255)) || (max(blockData(:)-min(blockData(:)))<100)
    disp('--Data values are outside the range, performing a uniform scale');
    %perform a uniform scale
    blockData=uint8(255*((blockData-min(blockData(:)))/max(blockData(:))));
else
    blockData=uint8(blockData);
end

%detector = cv.FeatureDetector(detection.parameters.type);


if trackForward==true
    [trackList] = trackBlock(blockData,detection,correspondenceAnalysis);
else
    trackList=[];
end




if trackBackward==true
    [trackListBackward] = trackBlock(blockData(:,:,end:-1:1),detection,correspondenceAnalysis);
else
    trackListBackward=[];
end



%we want interior rectangular boundary
if ~isempty(resultsDirectory)
    region=dataBlockObj.regionInformation.region;
    save(fullfile(resultsDirectory,resultsFilename),'imBlockSize','trackForward','trackBackward','trialData', ...
        'trackList','trackListBackward',...
        'resultsDirectory','resultsFilename','region','correspondenceAnalysis','detection');
else
    %do nothing
end
end


function [track] = trackBlock(imBlock,detection,correspondenceAnalysis)
% %!@TEMPLATE!@
% [ keyIdx ] = findKeyInPairList( varargin,'correlationCorrespondenceSettings' );
% correlationCorrespondenceSettings=varargin{keyIdx+1};
% keyList=correlationCorrespondenceSettings{1};
% values=correlationCorrespondenceSettings{2};
% for ii=1:length(keyList)
%
%     switch(keyList{ii})
%         case 'featurePatchSize'
%             cc.featurePatchSize=values.(keyList{ii});
%         case 'relThresh'
%             cc.relThresh=values.(keyList{ii});
%         case 'searchPatchSize'
%             cc.searchPatchSize=values.(keyList{ii});
%         case 'searchBox'
%             cc.searchBox=values.(keyList{ii});
%         otherwise
%             error(['Unsupported correlationCorrespondenceSettings of ' keyList{ii}]);
%     end
% end


%The basic idea is for every image frame to search for new features, and
%track existing features.  So index K are the valid feature points for frame K and where they tracked into frame K+1
%The points have the following :
%A tracklet must be at least 2 points to use START/STOP
%states will be a uint8
%TRACKLET_START - implies a next tracklet
%TRACKLET_STOP - implies there was a tracklet start
%TRACKLET_SINGLEPOINT - This represents a single point
%uint32 - We need a tracklet ID.  We will assign this tracklet id at the start of a
%track.  They are gaurenteed to be unique for a track, but only forward,
%not forward and backward
%
%statusOfKeypoints depends on MinEigThreshold 
tracklet.freeid=int32(1);  %The id 1 is the first valid id.  0 is empty and negative numbers are reserved.
tracklet.active.row.id=1;
tracklet.active.row.length=2;
activeTrackletList=zeros(2,0,'int32');  %this is the count and the id

savePreviousPtSet=[];
interlaced=0;
bPlot=0;
bMovieout=0;
 tlkTrackerTest(imBlock,interlaced,bPlot,bMovieout)

for ii = 1:(size(imBlock,3)-1)
    disp(['===================FRAME ' num2str(ii) '================'])
    im1 = imBlock(:,:,ii);
    im2 = imBlock(:,:,ii+1);  % set image2 - image1 is set in previous cycle
    
    originalKeypointsFromIm1 = detector.detect(im1);
        
    if isstruct(originalKeypointsFromIm1)
        keypointsFromIm1={originalKeypointsFromIm1.pt};
    else
        %do nothing
        keypointsFromIm1=originalKeypointsFromIm1;
    end
    
    %Find only the new features that are not currently being tracked.
    %Assume that if a feature is in the same pixel (even if subpixel is
    %different then it can be tracked)
    if ~isempty(savePreviousPtSet)    
        [~,indexOfNewFeatures]=setdiff(fix(flipud(cell2mat(keypointsFromIm1')')).',fix(flipud(cell2mat(savePreviousPtSet')')).','rows');
    else
        %This happens the first time it is run
        indexOfNewFeatures=1:length(keypointsFromIm1);
    end
        
    %This will be a little different from just keypointsFromIm1 at a sub
    %pixel level, but it will allow the tracklets to stay accurate
    keypointsFromIm1 = [savePreviousPtSet keypointsFromIm1(indexOfNewFeatures)];
    
    %This array holds the information about each track.  We don't assign a
    %tarck number yet because we don't know if the track will be valid  
    activeTrackletList = [activeTrackletList  zeros(2,length(indexOfNewFeatures),'int32')];
    
    if size(activeTrackletList,2)~=length(keypointsFromIm1)
        error('Lost sync between tracklet and keypoint lengths');
    end
    
    [keypointsMovedToInIm2,statusOfKeypoints, errOfKeypoints]  = cv.calcOpticalFlowPyrLK(im1,im2, keypointsFromIm1,'MaxLevel',3,'WinSize',[11 11],'GetMinEigenvals',true,'MinEigThreshold',.01);
    
    
    trackFailIdx=find(~statusOfKeypoints);
    
    %delete any tracks that failed
    keypointsFromIm1(trackFailIdx)=[];
    keypointsMovedToInIm2(trackFailIdx)=[];
    statusOfKeypoints(trackFailIdx)=[];
    errOfKeypoints(trackFailIdx)=[];
    activeTrackletList(:,trackFailIdx)=[];
    
    savePreviousPtSet=keypointsMovedToInIm2;  %this is needed for the next pass to make sure we do not retrack these points in the next pass when the feature detect is rerun
    
    if ~all(statusOfKeypoints)
        error('The wrong tracks were deleted.');
    else
        %Assign any new tracks an id number:
        newTrackIndex=find(activeTrackletList(tracklet.active.row.id,:)==0);
        freeIdList=tracklet.freeid + int32((0:(length(newTrackIndex)-1)));
        tracklet.freeid=freeIdList(end)+1;
        activeTrackletList(tracklet.active.row.id,newTrackIndex)=freeIdList;
        if any(activeTrackletList(tracklet.active.row.id,:)<1 | (activeTrackletList(tracklet.active.row.id,:)>=tracklet.freeid))
            error('Invalid track ids');
        end
        
        activeTrackletList(tracklet.active.row.length,:)=activeTrackletList(tracklet.active.row.length,:)+1;
    end
    
    
    
    %make sure the output is in row column not default of x,y (column,row)
    track(ii).pt_rc=single(flipud(cell2mat(keypointsFromIm1')'));
    track(ii).ptDelta_rc=single(flipud(cell2mat(keypointsMovedToInIm2')'-cell2mat(keypointsFromIm1')'));
    track(ii).ptState=statusOfKeypoints;
    track(ii).ptMetric=errOfKeypoints;
    track(ii).ptMetricType='err';
    disp(['Found ' num2str(size(track(ii).pt_rc,2)) ' features.']);
end

end