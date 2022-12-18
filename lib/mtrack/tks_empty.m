function [regionBox_rc, regionBoxCenter_rc,regionBoxOffset_rc,fullTrackPath_rc,fullTrackPathDelta_rc,dataInfo ,...
    regionBoxBackward_rc, regionBoxCenterBackward_rc,regionBoxOffsetBackward_rc,fullTrackPathBackward_rc,fullTrackPathDeltaBackward_rc,dataInfoBackward ] ...
    =tks_empty(trackList,trackListBackward,trackLength,trackLengthBackward,trackPathList,trackPathListBackward,matchList,matchListBackward,varargin)
     


p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename','results.mat', @(x) (ischar(x)));

p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;


cycleIndex=[1; size(trackPathList,2)];

%% Build the merged tracks
dataInfo=[];
dataInfoBackward=[];


disp('Finished computing the new track')

%% Now make a final track
disp('Building final forward track')
fullTrackPath_rc=[];
fullTrackPathDelta_rc=[];

disp('Building final backward track')
fullTrackPathBackward_rc=[];
fullTrackPathDeltaBackward_rc=[];

disp('Building forward region box')
regionBox_rc=[];
regionBoxCenter_rc=[];
regionBoxOffset_rc=[];

regionBoxBackward_rc=[];
regionBoxCenterBackward_rc=[];
regionBoxOffsetBackward_rc=[];

if ~isempty(resultsDirectory)
    save(fullfile(resultsDirectory,resultsFilename), ...
    'regionBox_rc', 'regionBoxCenter_rc','regionBoxOffset_rc','fullTrackPath_rc','fullTrackPathDelta_rc','dataInfo' ,...
    'regionBoxBackward_rc', 'regionBoxCenterBackward_rc','regionBoxOffsetBackward_rc','fullTrackPathBackward_rc', ...
    'fullTrackPathDeltaBackward_rc','dataInfoBackward','trialData','resultsDirectory','resultsFilename','-v7.3');
else
    %do nothing
end

end


