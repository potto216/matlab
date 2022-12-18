%INPUT
%skipImageCreate = [forward backward]
function [trackList,trackListBackward]=fpt_koseckaTracker(trialData,dataBlockObj, ...
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
%      row(start,end) col(tart,end)
%trim=[10 10 110  110];
%trim=[128 (dataBlockObj.size(1)-287)  43  (dataBlockObj.size(2)-446)];
trim_rc=settings.trim.border_rc;

blockData=dataBlockObj.getSlice(1:dataBlockObj.size(3));
%blockData=blockData(trim(1):(end-trim(2)+1),trim(3):(end-trim(4)+1),:);
if ~isempty(trim_rc)
    blockData=blockData(trim_rc(1):(end-trim_rc(2)+1),trim_rc(3):(end-trim_rc(4)+1),:);
else
    %do nothing
end

detector = []; %cv.FeatureDetector('HARRIS');

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

interlaced=0;
bPlot=0;
bMovieout=0;
%track all of the frames
[featx,featy,featq,good]=tlkTrackerTest(imBlock,interlaced,bPlot,bMovieout);

endIndex=find(good(:,1),1,'last');
featx((endIndex+1):end,:)=[];
featy((endIndex+1):end,:)=[];
featq((endIndex+1):end,:)=[];
good((endIndex+1):end,:)=[];
good=(good==1);

trackLength=sum(good,2);


for ii = 1:(size(imBlock,3)-1)
    ptN1_rc=[featy(good(:,ii),ii) featx(good(:,ii),ii)]';
    ptN2_rc=[featy(good(:,ii),ii+1) featx(good(:,ii),ii+1)]'; %it is not good+1 because we want even thefeatures that don't track to the next frame
    
    
    if isempty(trim_rc)
        track(ii).pt_rc=single(ptN1_rc);
    else        
        track(ii).pt_rc=single(ptN1_rc+repmat([trim_rc(1); trim_rc(3)],1,size(ptN1_rc,2)));
    end
    track(ii).ptDelta_rc=single(ptN2_rc-ptN1_rc);
    track(ii).ptMetric=single(reshape(featq(good(:,ii),ii),1,[]));  
    track(ii).trackletListId=int32(reshape(find(good(:,ii)),1,[]));
    track(ii).trackletListPosition=int16(reshape(sum(good(good(:,ii),1:ii),2),1,[]));
    track(ii).trackletListLength=int16(reshape(trackLength(good(:,ii)),1,[]));
    

    
    if ~all(size(track(ii).ptMetric)==size(track(ii).trackletListId)) || ...
            ~all(size(track(ii).ptMetric)==size(track(ii).trackletListPosition)) || ...
            ~all(size(track(ii).ptMetric)==size(track(ii).trackletListLength)) || ...
            ~all(size(track(ii).ptMetric,2)==size(track(ii).pt_rc,2)) || ...
            ~all(size(track(ii).ptMetric,2)==size(track(ii).ptDelta_rc,2))
        error('The sizes do not match.');
    end
    
    disp(['Found ' num2str(size(track(ii).pt_rc,2)) ' features.']);
end

end