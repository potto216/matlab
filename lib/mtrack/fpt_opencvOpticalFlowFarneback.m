%fpt_opencvOpticalFlowFarneback
%This function performs dense feature tracking which can be used to
%estimate where feature detection functions cannot find valid features.
%Because this generates 
%INPUT
%skipImageCreate = [forward backward]
%
%REFERENCE
%Link http://vision.is.tohoku.ac.jp/~kyamagu/software/mexopencv/matlab/
function [trackList,trackListBackward]=fpt_opencvOpticalFlowFarneback(trialData,dataBlockObj, ...
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

detector = [];

region=dataBlockObj.regionInformation.region;

if trackForward==true
    [trackList] = trackBlock(blockData,detector,correspondenceAnalysis,region);
else
    trackList=[];
end


if trackBackward==true
    [trackListBackward] = trackBlock(blockData(:,:,end:-1:1),detector,correspondenceAnalysis,region);
else
    trackListBackward=[];
end



%we want interior rectangular boundary
if ~isempty(resultsDirectory)
    
    save(fullfile(resultsDirectory,resultsFilename),'imBlockSize','trackForward','trackBackward','trialData', ...
        'trackList','trackListBackward',...
        'resultsDirectory','resultsFilename','region','correspondenceAnalysis','detection','-v7.3');
else
    %do nothing
end
end


function [track] = trackBlock(imBlock,detector,correspondenceAnalysis,region)



[rowGrid,columnGrid]=ndgrid(1:size(imBlock,1),1:size(imBlock,2));

rowGrid(~region.mask)=[];
columnGrid(~region.mask)=[];

pt_rc=[rowGrid(:) columnGrid(:)]';

%build out the 
xDeltaIndex = sub2ind([size(imBlock,1) size(imBlock,2) 2],rowGrid,columnGrid,ones(size(columnGrid)));
yDeltaIndex = sub2ind([size(imBlock,1) size(imBlock,2) 2],rowGrid,columnGrid,2*ones(size(columnGrid)));

for ii = 1:(size(imBlock,3)-1)
    disp(['===================FRAME ' num2str(ii) '================'])
    im1 = imBlock(:,:,ii);
    im2 = imBlock(:,:,ii+1);  % set image2 - image1 is set in previous cycle
    
    flowFromIm1ToIm2 = cv.calcOpticalFlowFarneback(im1,im2);    
    
    %make sure the output is in row column not default of x,y (column,row)
    track(ii).pt_rc=pt_rc;
    track(ii).ptDelta_rc=[reshape(flowFromIm1ToIm2(xDeltaIndex),[],1)'; reshape(flowFromIm1ToIm2(yDeltaIndex),[],1)'];
    disp(['Found ' num2str(size(track(ii).pt_rc,2)) ' features.']);
end

end