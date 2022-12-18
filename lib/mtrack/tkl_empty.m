%This function does not generate actual tracks, but only creates empty
%objects.  This function is useful when testing lower level functionality
%such as feature tracking
function [trackLength,trackLengthBackward,trackPathList,trackPathListBackward,matchList,matchListBackward ]...
    =tkl_empty(trackList,trackListBackward,imBlockSize,varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename','results.mat', @(x) (ischar(x)));
p.addParamValue('minBorderDistance_pel',[], @(x) (isempty(x) || isnumeric(x)));
p.addParamValue('badColumns',[], @(x) (isempty(x) || isnumeric(x)));
p.addParamValue('imErodeStrel',[], @(x) (isempty(x) || isa(x,'function_handle')));
p.addParamValue('region',[], @(x) ismatrix(x));
p.addParamValue('sourceTrackList',[], @(x) ismatrix(x));
p.addParamValue('sourceTrackListBackward',[], @(x) ismatrix(x));
p.addParamValue('sourceFilenameList',{},@(x) isempty(x) || iscell(x));
p.addParamValue('multitrackCollection',{},@(x) isempty(x) || iscell(x));
p.addParamValue('metainformationTrackList', @(x) (isempty(x) || isstruct(x)))
p.addParamValue('metainformationTrackListBackward', @(x) (isempty(x) || isstruct(x)))



p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;
minBorderDistance_pel=p.Results.minBorderDistance_pel;
region=p.Results.region;
badColumns=p.Results.badColumns;
imErodeStrel=p.Results.imErodeStrel;
sourceTrackList=p.Results.sourceTrackList;
sourceTrackListBackward=p.Results.sourceTrackListBackward;
sourceFilenameList=p.Results.sourceFilenameList;
multitrackCollection=p.Results.multitrackCollection;
metainformationTrackList=p.Results.metainformationTrackList;
metainformationTrackListBackward=p.Results.metainformationTrackListBackward;
if length(trackList)~=length(trackListBackward)  && ~isempty(trackListBackward)
    error('Expected similar lengths');
end
%% remove any points outside the roi
regionMod=region;

if ~isempty(imErodeStrel)
    regionMod.mask = imerode(regionMod.mask,imErodeStrel());
end

if ~isempty(badColumns)
    regionMod.mask(:,1:badColumns(1))=false;
    regionMod.mask(:,(end-badColumns(2)-1):end)=false;
end
%figure; imagesc(region.mask+regionMod.mask)

filteredTrackList=[];
filteredTrackListInfo=[];
filteredTrackListBackward=[];
filteredTrackListBackwardInfo=[];

matchList=[];
matchListBackward=[];

badColumnsAbsolute=[];
trackLength=[];
trackPathList=[];

trackLengthBackward=[];
trackPathListBackward=[];

%just save all of the values and skip any processing
disp('Finished building trackPathList');


if ~isempty(resultsDirectory)
    save(fullfile(resultsDirectory,resultsFilename),'trackList','trackListBackward','trackLength','trackLengthBackward', ...
        'trackPathList','trackPathListBackward','matchList','matchListBackward','trialData','resultsDirectory','resultsFilename', ...
        'badColumnsAbsolute','filteredTrackList','filteredTrackListBackward','region','regionMod', ...
        'sourceTrackList','sourceTrackListBackward','sourceFilenameList','filteredTrackListInfo','filteredTrackListBackwardInfo','multitrackCollection', ...
        'metainformationTrackList','metainformationTrackListBackward','-v7.3');
else
    %do nothing
end

end

%This forms a collection of column vectorssingle set of feature blocks that combines multitrack and
%single track.  A single track is where 
function [featureBlock, featureBlockLabels,  multifeatureBlockCollection, multifeatureBlockCollectionLabels]=createFeatureBlock(this,frameIndex,useAllArea,filterConditions)
switch(nargin)
    case 2
        useAllArea=true;
        filterConditions=[];
    case 3
        filterConditions=[];
    case 4
        %do nothing
    otherwise
        error('Invalid number of input arguments.');
end

[sourcePlotFormatList,sourceLinePlotFormatList]= this.loadSourceList(frameIndex);


im=this.dataBlockObj.getSlice(frameIndex);


d=this.nodeDB(this.defaultNameIndex).data;

trackFrameList=d.trackList(frameIndex);
sourceFrameTrackList=d.sourceTrackList(frameIndex);
sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);

if ~useAllArea
    [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList);
    for ii=1:length(sourceFrameTrackList)
        sourceFrameTrackList(ii).pt_rc(~filterInfo(ii).validIndexesFromOriginal)=[];
        error('This needs to be updated to handle all fields in the array');
    end
else
    %do nothing
end

%% Display the results
featureBlock=[];
for ii=1:length(frameIndex)
    featureSubBlock=[trackFrameList(ii).pt_rc; trackFrameList(ii).ptDelta_rc; frameIndex(ii)*ones(size( sourceFrameTrackList(ii).pt_rc)); sourceFrameTrackList(ii).pt_rc ];
    featureBlock=[featureBlock featureSubBlock];
end
featureBlockLabels={'pt_rc','ptDelta_rc','frameNumber','sourceId'};


if isfield(d,'multitrackCollection')
    [ multifeatureBlockCollection, multifeatureBlockCollectionLabels] = createMultitrackFeatureBlock( d.multitrackCollection );
    
end


end
