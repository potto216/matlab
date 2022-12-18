%INPUT
%skipImageCreate = [forward backward]
function [trackList,trackListBackward]=fpt_cameraTrackerVoodoo(trialData,dataBlockObj, ...
    trackForward,trackBackward,detectionName,correspondenceAnalysisName,skipImageCreate, varargin)

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

outputDataDirectory=fullfile(resultsDirectory,'@private','data');
if ~exist(outputDataDirectory,'dir')
    mkdir(outputDataDirectory);
else
    %skip
end



featureTrackMethod=[detectionName '_' correspondenceAnalysisName];
%**********************************************************************
%*   FIND FEATURE POINTS
%* This is used to find the feature points in the image.  If Voodoo is
%used then need to write out image sequence.
%**********************************************************************

if trackForward==true
    cameraTrackerInputDirectory=fullfile(outputDataDirectory,'images','forward');
    cameraTrackerInputImageFilemask=fullfile(cameraTrackerInputDirectory,'image_%d.png');
    cameraTrackerInputImageFilemask = strrep(cameraTrackerInputImageFilemask, '\', '/');
    if ~skipImageCreate(1)
        mkdir(cameraTrackerInputDirectory)
        dataBlockObj.imwrite(cameraTrackerInputImageFilemask,'png',[1:dataBlockObj.size(3)]);
    else
        %skip the creation
    end
    
    
    
    cameraTrackerCommand=['voodoo -F=1 -L=' num2str(dataBlockObj.size(3)) ' -S=1 -d=1 ' strrep(cameraTrackerInputImageFilemask,'/','\')];
    
    cameraTrackerInputFeatureDirectory=fullfile(outputDataDirectory,'features','forward',featureTrackMethod);
    mkdir(cameraTrackerInputFeatureDirectory);
    cameraTrackerInputFeatureFilemask=fullfile(cameraTrackerInputFeatureDirectory,'image_%d.pnt');
    cameraTrackerInputFeatureFilemask = strrep(cameraTrackerInputFeatureFilemask, '\', '/');
    
    
    
else
    trackList=[];
end




if trackBackward==true
    cameraTrackerInputDirectoryBackward=fullfile(outputDataDirectory,'images','backward');
    cameraTrackerInputImageFilemaskBackward=fullfile(cameraTrackerInputDirectoryBackward,'image_%d.png');
    cameraTrackerInputImageFilemaskBackward = strrep(cameraTrackerInputImageFilemaskBackward, '\', '/');
    
    
    cameraTrackerCommandBackward=['voodoo -F=1 -L=' num2str(dataBlockObj.size(3)) ' -S=1 -d=1 ' cameraTrackerInputImageFilemaskBackward];
    
    if ~skipImageCreate(2)
        mkdir(cameraTrackerInputDirectoryBackward)
        dataBlockObj.imwrite(cameraTrackerInputImageFilemaskBackward,'png',[dataBlockObj.size(3):-1:1]);
    else
        %do nothing
    end
    
    cameraTrackerInputFeatureDirectoryBackward=fullfile(outputDataDirectory,'features','backward',featureTrackMethod);
    mkdir(cameraTrackerInputFeatureDirectoryBackward);
    
    cameraTrackerInputFeatureFilemaskBackward=fullfile(cameraTrackerInputFeatureDirectoryBackward,'image_%d.pnt');
    cameraTrackerInputFeatureFilemaskBackward = strrep(cameraTrackerInputFeatureFilemaskBackward, '\', '/');
    
else
    trackListBackward=[];
end


if trackForward==true        
    dispStr=[trialData.sourceMetaFilename ' Please run Voodoo using the proper FORWARD settings now for detection '  detection.name ' and correspondence '  correspondenceAnalysis.name];
    disp(dispStr);
    uiwait(msgbox(dispStr));
    system(cameraTrackerCommand);
    
end

if trackBackward==true
    dispStr=[trialData.sourceMetaFilename ' Please run Voodoo using the proper BACKWARD settings now for detection '  detection.name ' and correspondence '  correspondenceAnalysis.name];
    disp(dispStr);
    uiwait(msgbox(dispStr));
    system(cameraTrackerCommandBackward);
    
end

[trackList,trackListBackward]=loadCameraTracker(dataBlockObj,cameraTrackerInputFeatureFilemask,cameraTrackerInputFeatureFilemaskBackward);

%we want interior rectangular boundary
if ~isempty(resultsDirectory)
    region=dataBlockObj.regionInformation.region;
    save(fullfile(resultsDirectory,resultsFilename),'imBlockSize','trackForward','trackBackward','trackList','trackListBackward','trialData', ...
        'cameraTrackerInputImageFilemask','cameraTrackerInputImageFilemask','cameraTrackerInputFeatureFilemask','cameraTrackerInputFeatureFilemaskBackward',...
        'resultsDirectory','resultsFilename','region','correspondenceAnalysis','detection');
else
    %do nothing
end
end


