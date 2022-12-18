%This function will run the tracker over a set of files using an active stream.
function [d,trackingAnalysis,dataBlockObj]=mstitch(varargin)
%mriDatabase, runSetting,distanceMeasure, imagePlane, ,syntheticData,OutputPlotsFilename,saveResultsInMatDb,matdb
%% Track data

%Is this usign the old interface?
if isstruct(varargin{1})
    
    trialData=varargin{1};
    dataBlockObj=varargin{2};
    activeProcessStreamIndex=varargin{3};
    runSetting=varargin{4};
    OutputPlotsFilename=varargin{5};
    
    %If using the new interface which is trialName,activeProcessStreamName and
    %then pair value
else ischar(varargin{1})
    %To open the analysis software run the following:
    trialName=varargin{1}; %= 'MRUS007_V1_S1_T2';  %A cell array of strings.  Needs to be the name of a file
    activeProcessStreamName=varargin{2}; % = 'standardBMode'; %A cell array of strings.  The most common process streams are: 'standardRF','standardBMode', 'standardProjection', 'standardFieldIIBMode'
    [trialData]=loadMetadata([trialName '.m']);
    activeProcessStreamIndex=tFindProcessStreamIndex(trialData,activeProcessStreamName);
    dataBlockObj=getCollection(trialData,trialData.track.processStream(activeProcessStreamIndex).sourceNode);
    
    runSetting(1).mriRoiList.name='baseline';
    runSetting(end).mriRoiList.value=[];
    runSetting(end).featureTrack.filter.setting={};
    runSetting(end).featureTrack.filter.name='none';
    runSetting(end).featureTrack.useAdaptive=false;
    runSetting(end).featureTrack.useCluster=false;
    borderTrim_rc = dataBlockObj.findBorder;
    if ~isempty(borderTrim_rc)
        borderTrim_rc=borderTrim_rc+10; %pad inwards more;
        runSetting.featureTrack.filter.setting{end+1}={'borderTrim_rc',str2func(['@(x) [' num2str(borderTrim_rc) ']'])};
    else
        %this means there is not a border so don't force one
    end
    OutputPlotsFilename=[];
    
    
end



trackingAnalysis=TrackingAnalysis(trialData,dataBlockObj,activeProcessStreamIndex);
defaultNode = @() trialData.track.processStream(activeProcessStreamIndex).stack{2}{1};
trackingAnalysis.setDefaultNodeName(defaultNode());

%dataBlockObj=trackingAnalysis.dataBlockObj;



%Setup the file titles
rfFullFilename=dataBlockObj.blockSource;
if isempty(rfFullFilename)
    rfFullFilename='none.none';
else
    
end

[~,baseDatafilename,extDatafilename]=fileparts(rfFullFilename);
rfFilename=[baseDatafilename extDatafilename];
slideTitle=rfFilename;

if ~isempty(OutputPlotsFilename)
    %Show the region information
    figure;
    dataBlockObj.regionInformation.plot();
    saveppt(OutputPlotsFilename,slideTitle);
    close(gcf);
end

%% Run track

%prb1={{'srcNot',{'fpt_crosscorrOversampleFast'}},{'deltaKeep',@(x) sum(x.^2)>0.5}};
%prb1={{'deltaKeep',@(x) sum(x.^2)>0.5}};
%prb1={{'deltaKeep',@(x) sum(x.^2)>0}};
%prb1={{'src',{'fpt_correlationCorrespondencePyramidFast'}},{'velocityMagKeep_mmPerSec',@(x) x>1 & x<50}};
%prb1={{'velocityMagKeep_mmPerSec',@(x) x>0 & x<50}};


if isempty(OutputPlotsFilename) && false
    trackingAnalysis.showFeature([150 151],false,{{'srcNot',{'fpt_crosscorrOversampleFast'}},{'deltaKeep',@(x) sum(x.^2)<6^2}});
    trackingAnalysis.showFeature([8],false,{{'srcNot',{'fpt_crosscorrOversampleFast'}}});
end
%
if false
    trackingAnalysis.showFeatureVideo([],false,[]);
    trackingAnalysis.showFeatureVideo([],false,dMod.vSmooth_mmPerSec);
end




if false
    % frameOfInterest=224;  %fast
    % frameOfInterest=20;  %slow
    frameOfInterest=36;  %slow
    borderTrim_rc = dataBlockObj.findBorder;
    borderTrim_rc=borderTrim_rc+10; %pad inwards more;
    {{'borderTrim_rc',@(x) borderTrim_rc}};
    trackingAnalysis.showFeature([frameOfInterest],false,{{'borderTrim_rc',@(x) borderTrim_rc}}); %#ok<*NBRAK>
    
    trackingAnalysis.showFeature([frameOfInterest],false,{{'trackletListLength',@(x) x>2}});
    trackingAnalysis.showFeature([frameOfInterest],false);
    trackingAnalysis.showFeatureDirection([frameOfInterest],false);
    trackingAnalysis.showFeatureLength([frameOfInterest],false);
    trackingAnalysis.showFeatureSpeed([frameOfInterest],false);
    trackingAnalysis.showHist([frameOfInterest],false);
    %trackingAnalysis.showTrackletVideo([18:24],false,{{'trackletListLength',@(x) x>3}});
    trackingAnalysis.showTrackletVideo([18:24],false,{{'trackletListLength',@(x) x>2}});
    trackingAnalysis.showTrackletVideo([18:24],false);
    trackingAnalysis.showHistAngle([frameOfInterest],false);
    
    frameOfInterest=20;
    trackingAnalysis.showFeatureColorPlot([frameOfInterest],true);
end



%% Modify the processing to use the average
% prb1={{'srcNot',{'fpt_correlationCorrespondencePyramidFast','fpt_crosscorrOversampleFast'}},{'velocityMagKeep_mmPerSec',@(x) x>0}};
% prb1={{'srcNot',{'fpt_correlationCorrespondencePyramidFast'}},{'velocityMagKeep_mmPerSec',@(x) x>0}};
% prb1={{'velocityMagKeep_mmPerSec',@(x) x>0}};
% prb1={{'srcNot',{'fpt_correlationCorrespondencePyramidFast'}},{'angleFilter',@(x) x}};
%prb1={{'angleFilter',@(x) x}};
%prb1={{'velocityMagKeep_mmPerSec',@(x) x>50}};
%prb1(end+1)={{'trackletListLength',@(x) x>3}};
%runAdaptive=true;

runAdaptive=runSetting.featureTrack.useAdaptive;
runCluster=runSetting.featureTrack.useCluster;
prb1=runSetting.featureTrack.filter.setting;

%[d]=trackingAnalysis.genTrack([],false,prb1,runCluster,runAdaptive);
[d]=trackingAnalysis.calcRegionVelocity(prb1);

if ~isempty(OutputPlotsFilename)
    close(gcf);
end
