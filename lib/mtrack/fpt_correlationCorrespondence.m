function [trackList,trackListBackward]=fpt_correlationCorrespondence(trialData,dataBlockObj,trackForward,trackBackward,varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('correlationCorrespondenceSettings',{}, @(x) (iscell(x)));

p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;
correlationCorrespondenceSettings=p.Results.correlationCorrespondenceSettings;
imBlockSize=[dataBlockObj.size(1) dataBlockObj.size(2) dataBlockObj.size(3)];

%**********************************************************************
%*   FIND FEATURE POINTS
%* This is used to find the feature points in the image.  If Voodoo is
%used then need to write out image sequence.
%**********************************************************************
%[directoryName]=tCreateDirectoryName(trialData.collection.fieldii.bmode.filepath,'createDirectory',false);

roiPoints_rc=[];

if trackForward==true
    
    [trackList] = motionfield(dataBlockObj,roiPoints_rc,'algorithm','correlationCorrespondence','correlationCorrespondenceSettings',correlationCorrespondenceSettings);
else
    trackList=[];
end

if trackBackward==true
    [trackListBackward] = motionfield(dataBlockObj,roiPoints_rc,'algorithm','correlationCorrespondence','frameDirection','backward','correlationCorrespondenceSettings',correlationCorrespondenceSettings);
else
    trackListBackward=[];
end


%we want interior rectangular boundary
if ~isempty(resultsDirectory)
    region=dataBlockObj.regionInformation.region;
    save(fullfile(resultsDirectory,resultsFilename),'imBlockSize','trackForward','trackBackward','trackList','trackListBackward','trialData','resultsDirectory','resultsFilename','region','correlationCorrespondenceSettings','-v7.3');
else
    %do nothing
end
end


