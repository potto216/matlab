function [trackList,trackListBackward]=fpt_correlationCorrespondencePyramid(trialData,dataBlockObj,trackForward,trackBackward,reductionFactor,varargin) %#ok<INUSL>

p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('correlationCorrespondenceSettings',{}, @(x) (iscell(x)));

p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData; %#ok<NASGU>
correlationCorrespondenceSettings=p.Results.correlationCorrespondenceSettings;
imBlockSize=[dataBlockObj.size(1) dataBlockObj.size(2) dataBlockObj.size(3)]; %#ok<NASGU>

%**********************************************************************
%*   FIND FEATURE POINTS
%* This is used to find the feature points in the image.  If Voodoo is
%used then need to write out image sequence.
%**********************************************************************
%[directoryName]=tCreateDirectoryName(trialData.collection.fieldii.bmode.filepath,'createDirectory',false);

roiPoints_rc=[];

imSource=dataBlockObj.getSlice(1:dataBlockObj.size(3));

for rr=1:reductionFactor
    imSource = impyramid(imSource, 'reduce');
end

if trackForward==true
    [trackList] = motionfield(imSource,roiPoints_rc,'algorithm','correlationCorrespondence','correlationCorrespondenceSettings',correlationCorrespondenceSettings);
else
    trackList=[];
end

if trackBackward==true
    [trackListBackward] = motionfield(imSource,roiPoints_rc,'algorithm','correlationCorrespondence','frameDirection','backward','correlationCorrespondenceSettings',correlationCorrespondenceSettings);
else
    trackListBackward=[];
end

reductionScale=2^reductionFactor;

for rr=1:length(trackList)
    trackList(rr).pt_rc=reductionScale*trackList(rr).pt_rc;
    trackList(rr).ptDelta_rc=reductionScale*trackList(rr).ptDelta_rc;
end

for rr=1:length(trackListBackward)
    trackListBackward(rr).pt_rc=reductionScale*trackListBackward(rr).pt_rc;
    trackListBackward(rr).ptDelta_rc=reductionScale*trackListBackward(rr).ptDelta_rc;
end

%we want interior rectangular boundary
if ~isempty(resultsDirectory)
    region=dataBlockObj.regionInformation.region; %#ok<NASGU>
    save(fullfile(resultsDirectory,resultsFilename),'imBlockSize','trackForward','trackBackward','trackList','trackListBackward','trialData','resultsDirectory','resultsFilename','region','correlationCorrespondenceSettings','-v7.3');
else
    %do nothing
end
end


