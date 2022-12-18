%The function manages the tracking and joining of feature tracks.  It
%processes the functions recursively so that it will process from outer to
%inner and then run those commands first.
%
%INPUT
%
%trialData - a struct containing the trial data
%
%processStream - a struct containing the process stream being used process
%the data
%
%currentStack - A cell array of the current process stack
%
%parentDirectory - The directory of the calling stack
%
%runTrackEngineConfiguration - a cell array of key value pairs of
%configuration parameters.  the current valid list is:
%   skipFeatureFindIfResultFileExists - default false and will skip feature
%   processing if the results file exists. 'fpt_' is considered a valid feature detector for the process name

function [ results ] = runTrackEngine( trialData,processStream, currentStack,parentDirectory, runTrackEngineConfiguration )

p = inputParser;   % Create an instance of the class.
p.addRequired('trialData',@(x) isstruct(x));
p.addRequired('processStream',@(x) isstruct(x));
p.addRequired('currentStack',@(x) iscell(x));
p.addRequired('parentDirectory',@(x) ischar(x));
%What follows are the pair values in runTrackEngineConfiguration
p.addParamValue('skipFeatureFindIfResultFileExists',false,@(x) isscalar(x) && islogical(x));

%if isempty(runTrackEngineConfiguration)
p.parse(trialData,processStream, currentStack,parentDirectory,runTrackEngineConfiguration{:});
%else
skipFeatureFindIfResultFileExists=p.Results.skipFeatureFindIfResultFileExists;

results=[];
%RUNTRACKENGINE This function processes a stream of tarcking commands.
%   The function will unwind the stress stack to create the directories
%   then move back up the stack.
% Functions can have multiple inputs
% All outputs are eventually merged to a single output (root node)
%Files are written for each output.  This serves as logging and since the
%functions have a large data processing time to data ratio using the
%relatively slow harddrive instead of the memory makes sense.

%first process the parallel commands if any
processNodeName=currentStack{1,1};

currentDirectory=fullfile(parentDirectory,processNodeName);
if ~exist(currentDirectory,'dir')
    mkdir(currentDirectory);
else
    %do nothing
end

%Create the directory structure at current level.  We must create it here
%because the processing stack is last (outer) to first (inner) so the outer
%structure needs to be created before the inner structure can be.

%if there are any cells then these represent methods(nodes) which need to be
%processed then process all of them
totalInputMethods=sum(cellfun(@(x) iscell(x), currentStack(2:end)));
previousResults=cell(totalInputMethods,1);
for ii=1:totalInputMethods
    %call the functions recursively
    previousResults{ii} = runTrackEngine( trialData,processStream, currentStack{1+ii},currentDirectory,runTrackEngineConfiguration );
end


% processInput=currentStack{1,2};
% if inputMethods==0 && ischar(processInput{1})
%     nodeName=processInput{1};
%     switch(strtok(nodeName,'_'))
%         case 'col'
%             dataBlockObj=getCollection(trialData,nodeName);
%         otherwise
%             error([nodeName ' is not supported.']);
%     end
% end

%*************START PROCESSING THE CURRENT METHOD*****************
%call process method with current input.  It is assumed because of the
%recursive call that everything needed for the input will already be
%created
processNode=tFindNode(trialData,processNodeName);
processMethodName=fliplr(strtok(fliplr(char(processNode.object)),'.'));
processMethod=str2func(processMethodName);
processMethodArguments=processNode.object(trialData);
methodMergedArguments = processMethodArguments;
if isfield(processNode,'settings')
    if isfield(processNode.settings,'method')
        fieldNamesToReplace=fieldnames(processNode.settings.method);
        for mm=1:length(fieldNamesToReplace)
            methodMergedArguments.(fieldNamesToReplace{mm})=processNode.settings.method.(fieldNamesToReplace{mm})();
        end
    end
    
end

%TODO: overlay the fields
resultsFilename='results.mat';

if length(previousResults)==0
    %do nothing
elseif length(previousResults)==1
    previousResults=previousResults{1};
    previousResultsFullFilename{1}=fullfile(previousResults.currentDirectory,previousResults.resultsFilename);
elseif any(length(previousResults)==[2:20])
    previousResultsFullFilename={};
    for pp=1:length(previousResults)
        pr=previousResults{pp};
        previousResultsFullFilename{pp}=fullfile(pr.currentDirectory,pr.resultsFilename);
    end
    
else
    error('Please add code to process');
end

%Use known interfaces to create the function calls

forceProcessNodeToBeSkipped=false;

resultsFullfilenameWithPath=fullfile(currentDirectory,resultsFilename);
if skipFeatureFindIfResultFileExists && strcmpi(processMethodName(1:4),'fpt_') && exist(resultsFullfilenameWithPath,'file')
    disp(['Skipping ' processMethodName ' because skipFeatureFindIfResultFileExists is true and the file: ' resultsFullfilenameWithPath ' exists.']);
    forceProcessNodeToBeSkipped=true;
else
    %do nothing don't set to false because this maybe in a chain of tests
end

if (~isfield(processNode,'skip') || isempty(processNode.skip) || ~processNode.skip) && ~forceProcessNodeToBeSkipped
    disp(['Processing node ' processNode.name ' of type ' processMethodName]);
    
    switch(processMethodName)
        case {'col_ultrasound_bmode','col_ultrasound_rf','col_ultrasound_fieldii_bmode','col_projection','col_verasonics_v1'}
            results.dataBlockObj=getCollection(trialData,processMethodName);
            
        case 'fpt_correlationCorrespondence'
            correlationCorrespondenceSettings={{'featurePatchSize','searchPatchSize','searchBox'},methodMergedArguments};
            fpt_correlationCorrespondence(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData, ...
                'correlationCorrespondenceSettings',correlationCorrespondenceSettings);
            
        case 'fpt_correlationCorrespondencePyramid'
            correlationCorrespondenceSettings={{'featurePatchSize','searchPatchSize','searchBox'},methodMergedArguments};
            fpt_correlationCorrespondencePyramid(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                methodMergedArguments.reductionFactor, ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData, ...
                'correlationCorrespondenceSettings',correlationCorrespondenceSettings);
            
        case 'fpt_crosscorrOversample'
            crosscorrOversampleSettings={setdiff(fields(methodMergedArguments),{'trackForward','trackBackward'}),methodMergedArguments};
            fpt_crosscorrOversample(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData, ...
                'crosscorrOversampleSettings',crosscorrOversampleSettings);
            
        case 'fpt_cameraTrackerVoodoo'
            tpIdx=find(structFieldStringIsEqual(methodMergedArguments.trackPackage,@(x) x.name,processNode.trackPackageName));
            fpt_cameraTrackerVoodoo(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                methodMergedArguments.trackPackage(tpIdx).detection.name,    methodMergedArguments.trackPackage(tpIdx).correspondenceAnalysis.name, ...
                methodMergedArguments.skipImageCreate, ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData, ...
                'detection',methodMergedArguments.trackPackage(tpIdx).detection, 'correspondenceAnalysis',methodMergedArguments.trackPackage(tpIdx).correspondenceAnalysis);
            
        case 'fpt_opencvKeypointTrack'
            tpIdx=find(structFieldStringIsEqual(methodMergedArguments.trackPackage,@(x) x.name,processNode.trackPackageName));
            fpt_opencvKeypointTrack(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                methodMergedArguments.trackPackage(tpIdx).detection.name,    methodMergedArguments.trackPackage(tpIdx).correspondenceAnalysis.name, ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData, ...
                'detection',methodMergedArguments.trackPackage(tpIdx).detection, 'correspondenceAnalysis',methodMergedArguments.trackPackage(tpIdx).correspondenceAnalysis,'settings',processNode.settings);
            
        case 'fpt_opencvOpticalFlowFarneback'
            
            fpt_opencvOpticalFlowFarneback(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                [],   [], ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData );
            
        case 'fpt_koseckaTracker'
            
            fpt_koseckaTracker(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                [],   [], ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData,'settings',processNode.settings );
            
        case {'fpt_activeContourEdgeTrack','fpt_activeContourOpenSpline'}
            
            fpt_activeContour(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                [],   [], ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData,'settings',processNode.settings,'processMethodName',processMethodName );
            
        case 'fpt_opencvFeatureDetectMultitrack'
            
            fpt_opencvFeatureDetectMultitrack(trialData,previousResults.dataBlockObj,methodMergedArguments.trackForward,methodMergedArguments.trackBackward, ...
                methodMergedArguments.trackPackage,    processNode.activeTrackPackageNameList, ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData);
            
        case {'tkl_regionAll','tkl_empty'}
            trackCollection=struct([]);
            multitrackCollection={};
            %there are two types of feature trackers that can be loaded.
            %First is the single feature tracker and the other is a
            %multiple feature tracker.  To properly load everything it is
            %assumed the regions and image data is the same for all of the
            %trackers.
            for tt=1:length(previousResultsFullFilename)
                variableInformation=whos('-file',previousResultsFullFilename{tt});
                multitrackOccurances=numel(strmatch('multitrack',{variableInformation.name}));
                if multitrackOccurances==0
                    if isempty(trackCollection)
                        trackCollection=load(previousResultsFullFilename{tt},'trackList','trackListBackward','imBlockSize','region');
                    else
                        trackCollection(end+1)=load(previousResultsFullFilename{tt},'trackList','trackListBackward','imBlockSize','region');
                    end
                elseif multitrackOccurances==1
                    multitrackCollection{end+1}=load(previousResultsFullFilename{tt},'multitrack','imBlockSize','region', ...
                        'correspondenceNameFromList',  'featureDetectNameFromList', 'uniqueFeatureDetectNameFromList', ...
                        'activeTrackPackageNameList');
                else
                    error(['Unable to load track data for ' previousResultsFullFilename{tt}]);
                end
                
            end
            
            %TODO need to do a better check
            imBlockSize=trackCollection(1).imBlockSize;
            region=trackCollection(1).region;
            
            
            [joinedTrackList, sourceTrackList, metainformationTrackList]=joinTracks(trackCollection,'trackList');
            [joinedTrackListBackward, sourceTrackListBackward, metainformationTrackListBackward]=joinTracks(trackCollection,'trackListBackward');
            
            extendedArguments={};
            if isfield(methodMergedArguments,'badColumns')
                extendedArguments{end+1}='badColumns';
                extendedArguments{end+1}=methodMergedArguments.badColumns;
            end
            
            if isfield(methodMergedArguments,'imErodeStrel')
                extendedArguments{end+1}='imErodeStrel';
                extendedArguments{end+1}=methodMergedArguments.imErodeStrel;
            end
            
            if isfield(methodMergedArguments,'minBorderDistance_pel')
                extendedArguments{end+1}='minBorderDistance_pel';
                extendedArguments{end+1}=methodMergedArguments.minBorderDistance_pel;
            end
            
            processMethod(joinedTrackList,joinedTrackListBackward,imBlockSize,'resultsDirectory',currentDirectory, ...
                'resultsFilename',resultsFilename,'trialData',trialData, 'region',region, ...
                'sourceTrackList',sourceTrackList,'sourceTrackListBackward',sourceTrackListBackward,'sourceFilenameList', ...
                previousResultsFullFilename,'multitrackCollection',multitrackCollection,extendedArguments{:}, ...
                'metainformationTrackList',metainformationTrackList, 'metainformationTrackListBackward',metainformationTrackListBackward);
        case {'tkl_frameMerge'}
            trackCollection={};
            multitrackCollection={};
            %there are two types of feature trackers that can be loaded.
            %First is the single feature tracker and the other is a
            %multiple feature tracker.  To properly load everything it is
            %assumed the regions and image data is the same for all of the
            %trackers.
            for tt=1:length(previousResultsFullFilename)
                variableInformation=whos('-file',previousResultsFullFilename{tt});
                multitrackOccurances=numel(strmatch('multitrack',{variableInformation.name}));
                [matFileType]=matfileType(previousResultsFullFilename{tt});
                if ~strcmp(matFileType,'7.3')
                    error(['The file ' previousResultsFullFilename{tt} ' must be version 7.3 to be used with tkl_frameMerge']);
                end
                if multitrackOccurances==0
                    trackCollection{end+1}=matfile(previousResultsFullFilename{tt});
                elseif multitrackOccurances==1
                    error('Cannot handle multitrack data.');
                else
                    error(['Unable to load track data for ' previousResultsFullFilename{tt}]);
                end
                
            end
            
            %TODO need to do a better check
            imBlockSize=trackCollection{1}.imBlockSize;
            region=trackCollection{1}.region;
            
            extendedArguments={};
            if isfield(methodMergedArguments,'badColumns')
                extendedArguments{end+1}='badColumns';
                extendedArguments{end+1}=methodMergedArguments.badColumns;
            end
            
            if isfield(methodMergedArguments,'imErodeStrel')
                extendedArguments{end+1}='imErodeStrel';
                extendedArguments{end+1}=methodMergedArguments.imErodeStrel;
            end
            
            if isfield(methodMergedArguments,'minBorderDistance_pel')
                extendedArguments{end+1}='minBorderDistance_pel';
                extendedArguments{end+1}=methodMergedArguments.minBorderDistance_pel;
            end
            
            processMethod(trackCollection,imBlockSize,'resultsDirectory',currentDirectory, ...
                'resultsFileBasename',resultsFilename,'trialData',trialData, 'region',region, ...
                'sourceFilenameList',previousResultsFullFilename, ...
                extendedArguments{:});
            
        case {'tks_basic','tks_empty'}
            %Load the version information if it exists.  If so then switch
            %the interface otherwise load the old interface where you
            %assume all of the variables exist
            variableInformation=whos('-file',previousResultsFullFilename{1});
            generatorFunctionIndex=any(arrayfun(@(x) strcmp(x.name,'generatorFunction'), variableInformation,'UniformOutput',true));
            %If the generator function is listed then run based on it.
            if any(generatorFunctionIndex)
                tmp=load(previousResultsFullFilename{1},'generatorFunction');
                generatorFunction=tmp.generatorFunction;
                switch(generatorFunction)
                    case 'tkl_frameMerge'
                        filteredTrackList=[];         filteredTrackListBackward=[];        trackLength=[];        trackLengthBackward=[];
                        trackPathList=[];         trackPathListBackward=[];         matchList=[];         matchListBackward=[];
                        
                    otherwise
                        error(['generatorFunction, ' generatorFunction ', is not supported.']);
                end
            else
                load(previousResultsFullFilename{1},'filteredTrackList','filteredTrackListBackward','trackLength','trackLengthBackward','trackPathList','trackPathListBackward','matchList','matchListBackward');
            end
            processMethod(filteredTrackList,filteredTrackListBackward,trackLength,trackLengthBackward,trackPathList,trackPathListBackward,matchList,matchListBackward, ...
                'resultsDirectory',currentDirectory,'resultsFilename',resultsFilename,'trialData',trialData);
            
        otherwise
            error(['Unsupported processMethodName of ' processMethodName]);
    end
else
    disp(['Skipping node ' processNode.name ' of type ' processMethodName]);
end

results.currentDirectory=currentDirectory;
results.resultsFilename=resultsFilename;
end

%for something in the form of
%collection(colletionIndex).frame(frameNumber).property
%we would like to convert it to the form:
%frame(frameNumber).property(:,[1:collection1 1:collection2 1:collection3])
%
%
%c1,f1,p1
%c2,f1,p1
%...
%cK,f1,p1
%
%
%c1,f2,p1
%c2,f2,p1
%...
%cK,f2,p1
%
%
%c1,fN,p1
%c2,fN,p1
%...
%cK,fN,p1

function [joinedTrackList, source, metainformation]=joinTracks(collection,trackName)

%frameLength=@(c) length(c.trackList);
frameLength=str2func(['@(c) length(c.' trackName ')']);
property={};
%fieldList={'pt_rc','ptDelta_rc','ptMetric','trackletListId','trackletListPosition','trackletListLength'};
fieldList={'pt_rc','ptDelta_rc'};
% property{1}=@(c,frameIdx) c.trackList(frameIdx).pt_rc;
% property{2}=@(c,frameIdx) c.trackList(frameIdx).ptDelta_rc;
for ii=1:length(fieldList)
    property{ii}=str2func(['@(c,frameIdx) c.' trackName '(frameIdx).' fieldList{ii}]);
end

totalFrames=arrayfun(@(c) frameLength(c),collection);
if ~all(totalFrames==totalFrames(1))
    error('This assumes all of the frames will be equal.');
end


finalResults=cell(length(property),totalFrames(1));
sourceResults=cell(1,totalFrames(1));

%This is a way to transform a field at a time
%collection(C).frames(F).featurePointList(P) to
%frames(F).featurePointList(P*C)
for pp=1:length(property)
    groupedFeaturesForFrame = @(frameIndex) arrayfun(@(cc,ff) property{pp}(collection(cc),ff),(1:length(collection)),frameIndex*ones(1,length(collection)),'UniformOutput',false);
    results=arrayfun(@(fIdx) groupedFeaturesForFrame(fIdx), 1:totalFrames(1),'UniformOutput',false);
    
    %ASSUME the pt_rc and ptDelta_rc are from the same source
    
    sourceLengthList=cellfun(@(pointGroup) cellfun(@(x) size(x,2),pointGroup),results,'UniformOutput',false);
    
    %This builds a reference back to the collection index which is assumed
    %to be the length(sourceLength)
    %     expandedSourceLength = @(sourceLength) cell2mat(arrayfun(@(id,len) id*ones(1,len),1:length(sourceLength),sourceLength,'UniformOutput',false));
    %     expandedSourceLengthForAllFrames=cellfun(expandedSourceLength,sourceLengthList,'UniformOutput',false);
    
    expandeSourceAndIndex = @(sourceLength) cell2mat(arrayfun(@(id,len) int32([id*ones(1,len);1:len ]),1:length(sourceLength),sourceLength,'UniformOutput',false));
    expandedSourceAndIndexForAllFrames=cellfun(expandeSourceAndIndex,sourceLengthList,'UniformOutput',false);
    
    %finalResults(pp,:)=cellfun(@(x) cell2mat(x),results,'UniformOutput',false);
    %this is really slow to do it one vector at a time.  Clean it
    %up later
    %finalResults(pp,:)=cellfun(@(x) cell2mat(cellfun(@(x) single(x),x,'UniformOutput',false)),results,'UniformOutput',false);
    
    finalResults(pp,:)=cellfun(@(x) single(cat(2,x{:})),results,'UniformOutput',false);
    switch(fieldList{pp})
        case 'pt_rc'
            %sourceResults(pp,:)=expandedSourceLengthForAllFrames;
            sourceResults(1,:)=expandedSourceAndIndexForAllFrames;
        case 'ptDelta_rc'
        otherwise
            error(['Undefined field list of ' fieldList{pp}]);
    end
    
end

% joinedTrackList.pt_rc
% joinedTrackList.ptDelta_rc
% source
% joinedTrackListBackward.pt_rc
% joinedTrackListBackward.ptDelta_rc
%
% collection(2).trackList
joinedTrackList = cell2struct(finalResults, fieldList, 1);
source = cell2struct(sourceResults, 'pt_rc', 1);

metainformation=collection;
fieldsToRemove=setdiff(fieldnames(metainformation),trackName);
for ii=1:length(fieldsToRemove)
    metainformation=rmfield(metainformation,fieldsToRemove{ii});
end

for cc=1:length(metainformation)
    fieldsToRemove=intersect(fieldnames(metainformation(cc).(trackName)),fieldList);
    for ii=1:length(fieldsToRemove)
        metainformation(cc).(trackName)=rmfield(metainformation(cc).(trackName),fieldsToRemove{ii});
    end
end

end


