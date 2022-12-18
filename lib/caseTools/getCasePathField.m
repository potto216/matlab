%This function returns the various directories for writing different data
%files  These must be defined in the case metadata
%Examples:
%  latticePath
%  motionPath
%  analysisPath
%This also returns if a new path was created
function [dataPath, isNewPath]=getCasePathField(metadata,fieldName)
dataPath=getfield(metadata,fieldName);


if ~exist(dataPath,'dir')
     mkdir(dataPath);
     isNewPath=true;
else
    %do nothing
    isNewPath=false;
end

if ~exist(dataPath,'dir')
    error('data path cannot be created.')
else
    %do nothing
end