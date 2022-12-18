%This function will track the evolution of an active contour over a set of
%frames.  The agent name needs to be specified and the tracking will be
%forward and backward from the initial marking.  Tracking will stop when
%1. The start or end of the frame sequence is met
%2. Hard limits given by trackLimit which defaults to [-inf, inf]
%3. Stop tracking based on some metric such as energy quality.  The use of
%the tracking method is given by trackLimitMethod={'methodName'}.  The
%default of empty means only the limit is used.
%
%INPUT
%Really this only tracks forward depending on the
%skipImageCreate = [forward backward]
%
%OUTPUT
%trackList(ii).ptDelta_rc - the delta is defined as where the iith frame
%moves to the ii+1 frame.
%trackList(ii).ptDelta_rc=trackList(ii+1).pt_rc-trackList(ii).pt_rc
function [trackList,trackListBackward]=fpt_activeContour(trialData,dataBlockObj, ...
    trackForward,trackBackward,detectionName,correspondenceAnalysisName, varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename','results.mat', @(x) (ischar(x)));
p.addParamValue('correspondenceAnalysis',[],@(x) isempty(x) || isstruct(x));
p.addParamValue('detection',[],@(x) isempty(x) || isstruct(x));
p.addParamValue('settings',[],@(x) isempty(x) || isstruct(x));
p.addParamValue('processMethodName',[],@(x) ischar(x));

p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;
correspondenceAnalysis=p.Results.correspondenceAnalysis;
detection=p.Results.detection;
settings=p.Results.settings;
processMethodName=p.Results.processMethodName;

imBlockSize=[dataBlockObj.size(1) dataBlockObj.size(2) dataBlockObj.size(3)];

agentToTrack=trialData.collection.ultrasound.bmode.region.agent(arrayfun(@(x) strcmp(settings.agentToTrack,x.name),trialData.collection.ultrasound.bmode.region.agent));

if length(agentToTrack)~=1
    error('Unable to track the agent');
else
    forwardFramesToTrack=(agentToTrack.frame:imBlockSize(3));
    backwardFramesToTrack=fliplr((1:agentToTrack.frame));
end

% forwardFramesToTrack=forwardFramesToTrack(1:10);
% backwardFramesToTrack=backwardFramesToTrack(1:10);

activeContourVertices_rc=agentToTrack.vpt;
%metadata.track.node(end+1).name='fpt_activeContourEdgeTrack';
switch(processMethodName)
    case 'fpt_activeContourEdgeTrack'        
        activeContourMethod='trackContourEdgeTrak';
    case 'fpt_activeContourOpenSpline'
        activeContourMethod='trackContourOpenSpline';
    otherwise
        error(['Unsupported method of ' processMethodName]);
end



if trackForward==true
    [trackListForwardSegment] = activeContourRun(dataBlockObj,forwardFramesToTrack,activeContourVertices_rc,settings.brightRegionPosition,false,activeContourMethod);
    [trackListBackwardSegment] = activeContourRun(dataBlockObj,backwardFramesToTrack,activeContourVertices_rc,settings.brightRegionPosition,false,activeContourMethod);
else
    trackList=[];
end
trackList=repmat(struct('pt_rc',[]),1,imBlockSize(3));
trackList(forwardFramesToTrack)=trackListForwardSegment;
trackList(backwardFramesToTrack)=trackListBackwardSegment;
trackList(1).ptDelta_rc=[];

for ii=1:(length(trackList)-1)
    if ~isempty(trackList(ii).pt_rc)  && ~isempty(trackList(ii+1).pt_rc)
        trackList(ii).ptDelta_rc=trackList(ii+1).pt_rc-trackList(ii).pt_rc;
    else
        %do nothing
    end
end

%the backward track is undefined
trackListBackward=[];


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


