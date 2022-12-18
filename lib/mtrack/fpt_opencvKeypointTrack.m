%INPUT
%skipImageCreate = [forward backward]
function [trackList,trackListBackward]=fpt_opencvKeypointTrack(trialData,dataBlockObj, ...
    trackForward,trackBackward,detectionName,correspondenceAnalysisName, varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename','results.mat', @(x) (ischar(x)));
p.addParamValue('correspondenceAnalysis',[],@(x) isempty(x) || isstruct(x));
p.addParamValue('detection',[],@(x) isempty(x) || isstruct(x));
p.addParamValue('settings',[],@(x) isempty(x) || isstruct(x));

p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;
correspondenceAnalysis=p.Results.correspondenceAnalysis;
detection=p.Results.detection;
settings=p.Results.settings;

imBlockSize=[dataBlockObj.size(1) dataBlockObj.size(2) dataBlockObj.size(3)];

if ~isempty(detection) && ~strcmpi(detection.name,detectionName)
    error('The detection name does not match.');
end

if ~isempty(correspondenceAnalysis) && ~strcmpi(correspondenceAnalysis.name,correspondenceAnalysisName)
    error('The correspondenceAnalysis name does not match.');
end
%      row(start,end) col(start,end)
%trim=[10 10 110  110];
%trim=[128 (dataBlockObj.size(1)-287)  43  (dataBlockObj.size(2)-446)]
trim_rc=settings.trim.border_rc;
blockData=dataBlockObj.getSlice(1:dataBlockObj.size(3));
if ~isempty(trim_rc)
    %chec if it is a string command
    if iscell(trim_rc)
        switch(trim_rc{1})
            case 'trimBlack'
                trim_rc=findBlockBoundry(blockData);
                if isempty(trim_rc)
                    %no more adjustments
                else
                    %additional adjustments may be needed
                end
                %don't know why I put this here
                %                 trim_rc(3)=trim_rc(3)+15;
                %                 trim_rc(4)=trim_rc(4)+15;
            case 'trimNone'
                trim_rc=[];
                %don't trim anything
            otherwise
                error(['The trim_rc argument of ' trim_rc{1} ' is not supported.']);
        end
    elseif isnumeric(trim_rc) && isvector(trim_rc)
        %do nothing and just use the values given
    else
        error('Unsupported type for trim_rc');
    end
    %make sure if in automatic mode to handle the case if nothing was found
    if ~isempty(trim_rc)
        blockData=blockData(trim_rc(1):(end-trim_rc(2)+1),trim_rc(3):(end-trim_rc(4)+1),:);
    end
else
    %do nothing
end

if (any(blockData(:)<0) || any(blockData(:)>255)) || (max(blockData(:)-min(blockData(:)))<100)
    disp('--Data values are outside the range, performing a uniform scale');
    %perform a uniform scale
    blockData=uint8(255*((blockData-min(blockData(:)))/max(blockData(:))));
else
    blockData=uint8(blockData);
end

detector = cv.FeatureDetector(detection.parameters.type);


if trackForward==true
    [trackList] = trackBlock(blockData,detector,correspondenceAnalysis,trim_rc);
else
    trackList=[];
end




if trackBackward==true
    [trackListBackward] = trackBlock(blockData(:,:,end:-1:1),detector,correspondenceAnalysis,trim_rc);
else
    trackListBackward=[];
end



%we want interior rectangular boundary
if ~isempty(resultsDirectory)
    region=dataBlockObj.regionInformation.region;
    save(fullfile(resultsDirectory,resultsFilename),'imBlockSize','trackForward','trackBackward','trialData', ...
        'trackList','trackListBackward',...
        'resultsDirectory','resultsFilename','region','correspondenceAnalysis','detection','-v7.3');
else
    %do nothing
end
end


function [track] = trackBlock(imBlock,detector,correspondenceAnalysis,trim_rc)
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
%Tracklet ids may never show up.  This could occur when the tracklet was
%created and killed in the frame pair.  This would occur because the
%quality factor was not high enough.

tracklet.freeid=int32(1);  %The id 1 is the first valid id.  0 is empty and negative numbers are reserved.
% tracklet.active.row.id=1;
% tracklet.active.row.position=2;
% tracklet.active.row.length=3;
% tracklet.active.state.notAssigned=0;
% tracklet.active.state.trackletStart=1;
% tracklet.active.state.trackletInterior=2;
% tracklet.active.state.trackletEnd=3;
% tracklet.active.state.trackletSingleton=4;
activeTrackletList.id=zeros(1,0,'int32');  %this is the count and the id
activeTrackletList.position=zeros(1,0,'int16');
activeTrackletList.length=zeros(1,0,'int16');

savePreviousPtSet=[];
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
        tmpKeyptIm1=fix(flipud(cell2mat(keypointsFromIm1')')).';
        tmpSavePreviousSet=fix(flipud(cell2mat(savePreviousPtSet')')).';
        if isempty(tmpKeyptIm1)
            indexOfNewFeatures=[];
        elseif size(tmpKeyptIm1,2)~=size(tmpSavePreviousSet,2)
            disp('WARNING: tmpKeyptIm1 and tmpSavePreviousSet should have the same size.  Please investigate.')
            keyboard;
        else
            [~,indexOfNewFeatures]=setdiff(tmpKeyptIm1,tmpSavePreviousSet,'rows');
        end
        
        
    else
        %This happens the first time it is run
        indexOfNewFeatures=1:length(keypointsFromIm1);
    end
    
    %This will be a little different from just keypointsFromIm1 at a sub
    %pixel level, but it will allow the tracklets to stay accurate
    keypointsFromIm1 = [savePreviousPtSet keypointsFromIm1(indexOfNewFeatures)];
    
    %This array holds the information about each track.  We don't assign a
    %tarck number yet because we don't know if the track will be valid
    activeTrackletList.id = [activeTrackletList.id  zeros(size(activeTrackletList.id,1),length(indexOfNewFeatures),class(activeTrackletList.id))];
    activeTrackletList.position = [activeTrackletList.position  zeros(size(activeTrackletList.position,1),length(indexOfNewFeatures),class(activeTrackletList.position))];
    activeTrackletList.length = [activeTrackletList.length  zeros(size(activeTrackletList.length,1),length(indexOfNewFeatures),class(activeTrackletList.length))];
    
    
    if size(activeTrackletList.id,2)~=length(keypointsFromIm1)
        error('Lost sync between tracklet and keypoint lengths');
    end
    
    [keypointsMovedToInIm2,statusOfKeypoints, errOfKeypoints]  = cv.calcOpticalFlowPyrLK(im1,im2, keypointsFromIm1,'MaxLevel',3,'WinSize',[11 11],'GetMinEigenvals',true,'MinEigThreshold',.01);
    
    
    trackFailIdx=find(~statusOfKeypoints);
    
    %The trackFailIdx will indicate bad tracks that will need to be
    %deleted.  But before we can delete the tracks we need to first set the
    %track states.  So if they only existed in this image pair we can forget
    %about them because while they were detected in the first image they could
    %not be tracked, but if they started in the last image pair that means
    %they were only valid for that pair (trackletSingleton), but if they
    %have existed longer then they end with a trackletEnd
    activeTrackletFailList=activeTrackletList.id(:,trackFailIdx);
    
    
    keypointsFromIm1(trackFailIdx)=[];
    keypointsMovedToInIm2(trackFailIdx)=[];
    statusOfKeypoints(trackFailIdx)=[];
    errOfKeypoints(trackFailIdx)=[];
    activeTrackletList.id(:,trackFailIdx)=[];
    activeTrackletList.position(:,trackFailIdx)=[];
    activeTrackletList.length(:,trackFailIdx)=[];
    
    savePreviousPtSet=keypointsMovedToInIm2;  %this is needed for the next pass to make sure we do not retrack these points in the next pass when the feature detect is rerun
    
    if ~all(statusOfKeypoints)
        error('The wrong tracks were deleted.');
    else
        %Assign any new tracks an id number:
        newTrackIndex=find(activeTrackletList.id==0);
        if ~isempty(newTrackIndex)
            freeIdList=tracklet.freeid + int32((0:(length(newTrackIndex)-1)));
            tracklet.freeid=freeIdList(end)+1;
            activeTrackletList.id(newTrackIndex)=freeIdList;
        else
            %don't need to add new tracks
        end
        if any(activeTrackletList.id<1 | (activeTrackletList.id>=tracklet.freeid))
            error('Invalid track ids');
        end
        
        activeTrackletList.position=activeTrackletList.position+1;
    end
    
    
    
    %make sure the output is in row column not default of x,y (column,row)
    if isempty(trim_rc)
        track(ii).pt_rc=single(flipud(cell2mat(keypointsFromIm1')'));
    else
        track(ii).pt_rc=single(flipud(cell2mat(keypointsFromIm1')'))+repmat([trim_rc(1); trim_rc(3)],1,length(keypointsFromIm1));
    end
    track(ii).ptDelta_rc=single(flipud(cell2mat(keypointsMovedToInIm2')'-cell2mat(keypointsFromIm1')'));
    track(ii).ptMetric=reshape(errOfKeypoints,1,[]);
    %Leave out because should be a program parm  track(ii).ptMetricType='eigenValue';
    track(ii).trackletListId=activeTrackletList.id;
    track(ii).trackletListPosition=activeTrackletList.position;
    track(ii).trackletListLength=activeTrackletList.length;
    
    
    disp(['Found ' num2str(size(track(ii).pt_rc,2)) ' features.']);
end
track = calcTrackletLength( track );
end