function mtrack(trialNameList,activeProcessStreamList,varargin)
%The purpose of this tracker is to determine what needs to be
%tracked in the trial and then perform the tracking.  This will get a list
%of files ready to track, load eveything up then call the tracker.
%The steps are:
%1. Load the trial data
%2. Determine what to track in the trial data and if the flags are set to
%tracking in the batch software.  The default is to track whatever is in
%trial data
%3. Call the feature tracking program
%4. Call the tracklet stitching program
%Remeber some feature tracks maybe generated by other programs such as
%Voodoo.
%
%After this additional iterations can be called through the tracking
%program to take advantage of Bayesian estimates.
%
%INPUT
%
%trialNameList - the trials to process.  This is a cell array and should be
%even if it is a single item.
%
%activeProcessStreamList - The process stream to use for each
%trial.  This decides the processing chain such as the feature tracking and
%tracklet stitching algorithms.  Can be a numeric index or a string. for
%the string the common values are:
%   standardProjection
%   standardFieldIIBMode
%   standardBMode
%   standardRF
%activeProcessStreamNameList - the name of the process stream to use for
%the processing structure.
%
%forceReprocess - this command will force the reprocessing of the tracking
%files.  This only applies to the tracking files
%
%useParallelProcessing - this will use the parallel processing toolbox to
%process the files.  If this is false then a regular for loop will be used
%without try and catch. 
%
%runTrackEngineConfiguration - this can be a cell array of pair value
%arguments which is passed to the runTrackEngine function.
%
%Example:
%{'runTrackEngineConfiguration',{'skipFeatureFindIfResultFileExists',true}}
%
%NOTE
%To debug errors use "dbstop if caught error" because of the try catch
%
%EXAMPLE
%%%%To open the analysis software and track a single file run the following:
% metadata.track.processStream(2).name='standardFieldIIBMode';
% forceReprocess=false;
% useParallelProcessing=false;
% trialNameList={'MRUS007_V1_S1_T2'};  %A cell array of strings.  Needs to be the name of a file
% %%metadata.track.processStream(2).name='standardFieldIIBMode'; is where
% %%the activeProcessStreamNameList comes from
% activeProcessStreamNameList = {'standardBMode'}; %A cell array of strings.  The most common process streams are: 'standardRF','standardBMode', 'standardProjection', 'standardFieldIIBMode'
% mtrack(trialNameList,activeProcessStreamNameList,'forceReprocess',forceReprocess, ...
%     'useParallelProcessing',useParallelProcessing, ...
%     'runTrackEngineConfiguration',{'skipFeatureFindIfResultFileExists',true});
%%%%To load multiple and process multiple files
%addpath(fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\data\subject\mriCompare'));
%addpath(fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\data\subject\mriCompare\phantom'));
%[trialNameList,activeProcessStreamNameList,fullList]=loadSubjects_3_14();
% mtrack(trialNameList,activeProcessStreamNameList,'forceReprocess',forceReprocess, ...
%     'useParallelProcessing',useParallelProcessing, ...
%     'runTrackEngineConfiguration',{'skipFeatureFindIfResultFileExists',true});
p = inputParser;   % Create an instance of the class.
p.addRequired('trialNameList',@(x) iscell(x));
p.addRequired('activeProcessStreamList',@(x) isnumeric(x) || iscell(x));
p.addParamValue('forceReprocess',false,@(x) islogical(x) && isscalar(x));
p.addParamValue('useParallelProcessing',false,@(x) islogical(x) && isscalar(x));
p.addParamValue('runTrackEngineConfiguration',{},@(x) iscell(x));
p.parse(trialNameList,activeProcessStreamList,varargin{:});

forceReprocess=p.Results.forceReprocess;
useParallelProcessing=p.Results.useParallelProcessing;
runTrackEngineConfiguration=p.Results.runTrackEngineConfiguration;

computerInformation.numCores=feature('numCores');

if useParallelProcessing
    localCoresToUse=min(computerInformation.numCores,4); %#ok<UNRCH>
    disp(['Opening ' num2str(localCoresToUse) ' cores.'])
    matlabpool('open','local',localCoresToUse);
end

if useParallelProcessing
    parfor tt=1:length(trialNameList)  %uncomment when debugging
        %warning('Not using parallel processing.')
        %parfor tt=1:length(trialNameList)  %nneded for parallel processing
        
        try
            trialName=trialNameList{tt};
            disp(['Processing trial ' trialName]);
            [trialData]=loadMetadata([trialName '.m']);
            
            activeProcessStreamIndex=tFindProcessStreamIndex(trialData,activeProcessStreamList{tt});
            
            
            %Check if data has been processed
            [directoryName]=tCreateDirectoryName(trialData.track.processStream(activeProcessStreamIndex).filepath,'createDirectory',false);
            
            if ~forceReprocess
                processTrackletStitchName=trialData.track.processStream(activeProcessStreamIndex).stack{1};
                fileList=dirPlus(fullfile(directoryName,processTrackletStitchName,'results.mat'));
                
                if isempty(fileList)
                    disp(['Processing ' trialName ' since it was not processed.']);
                    [directoryName]=tCreateDirectoryName(trialData.track.processStream(activeProcessStreamIndex).filepath,'createDirectory',true);
                    [ results ] = runTrackEngine( trialData,trialData.track.processStream(activeProcessStreamIndex),trialData.track.processStream(activeProcessStreamIndex).stack,directoryName,runTrackEngineConfiguration);
                    
                else
                    disp(['Skipping ' trialName ' since it was already processed.']);
                end
                
            else
                [directoryName]=tCreateDirectoryName(trialData.track.processStream(activeProcessStreamIndex).filepath,'createDirectory',true);
                [ results ] = runTrackEngine( trialData,trialData.track.processStream(activeProcessStreamIndex),trialData.track.processStream(activeProcessStreamIndex).stack,directoryName,runTrackEngineConfiguration);
                
            end
        catch Me
            fid=fopen(['failRun_' num2str(tt) '.txt'],'a+');
            fprintf(fid,'%s FAILED.\n',trialName);
            fclose(fid);
        end
        
    end
    
else
    for tt=1:length(trialNameList)  %uncomment when debugging
        %warning('Not using parallel processing.')
        %parfor tt=1:length(trialNameList)  %nneded for parallel processing
        
        trialName=trialNameList{tt};
        disp(['Processing trial ' trialName]);
        [trialData]=loadMetadata([trialName '.m']);
        
        activeProcessStreamIndex=tFindProcessStreamIndex(trialData,activeProcessStreamList{tt});
        
        
        %Check if data has been processed
        [directoryName]=tCreateDirectoryName(trialData.track.processStream(activeProcessStreamIndex).filepath,'createDirectory',false);
        
        if ~forceReprocess
            processTrackletStitchName=trialData.track.processStream(activeProcessStreamIndex).stack{1};
            fileList=dirPlus(fullfile(directoryName,processTrackletStitchName,'results.mat'));
            
            if isempty(fileList)
                disp(['Processing ' trialName ' since it was not processed.']);
                [directoryName]=tCreateDirectoryName(trialData.track.processStream(activeProcessStreamIndex).filepath,'createDirectory',true);
                [ results ] = runTrackEngine( trialData,trialData.track.processStream(activeProcessStreamIndex),trialData.track.processStream(activeProcessStreamIndex).stack,directoryName,runTrackEngineConfiguration);
                
            else
                disp(['Skipping ' trialName ' since it was already processed.']);
            end
            
        else
            [directoryName]=tCreateDirectoryName(trialData.track.processStream(activeProcessStreamIndex).filepath,'createDirectory',true);
            [ results ] = runTrackEngine( trialData,trialData.track.processStream(activeProcessStreamIndex),trialData.track.processStream(activeProcessStreamIndex).stack,directoryName,runTrackEngineConfiguration);
            
        end
        
    end
end



if useParallelProcessing
    matlabpool('close') %#ok<UNRCH>
end
