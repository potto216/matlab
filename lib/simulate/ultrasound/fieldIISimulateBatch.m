function fieldIISimulateBatch(trialNameList, useParallelProcessing)

if useParallelProcessing
    computerInformation.numCores=feature('numCores');
    localCoresToUse=min(computerInformation.numCores,8); %#ok<UNRCH>
    disp(['Opening ' num2str(localCoresToUse) ' cores.'])   
    matlabpool=parpool('local',localCoresToUse);
end





%This should not be a parfor because that is used in fieldIISimulate.m
for tt=1:length(trialNameList)
    trialName=trialNameList{tt};
    [trialData]=loadMetadata([trialName '.m']);
    
    matFullFilepath=fullfile(trialData.subject.phantom.filepath.pathToRoot, ...
    trialData.subject.phantom.filepath.root, ...
    trialData.subject.phantom.filepath.relative);
    phantomObjectFilename=trialData.subject.phantom.filename;
        
    fieldIIRFDataFullFilepath=fullfile(trialData.collection.fieldii.rf.filepath.pathToRoot, ...
    trialData.collection.fieldii.rf.filepath.root, ...
    trialData.collection.fieldii.rf.filepath.relative);

    trialNameFileInfo=dir(which([trialName '.m']));
    if isempty(trialNameFileInfo)
        error(['Unable to access the file info for  ' which([trialName '.m']) ' check the file permissions and that you can open it.' ]);
    end
    
    phantomFilenameInfo=dir(fullfile(matFullFilepath,phantomObjectFilename)); 
   if isempty(phantomFilenameInfo)
        error(['Please create the phantom model by running phantomSimulateMotion for ' fullfile(matFullFilepath,phantomObjectFilename)]);
    end
    
    if trialNameFileInfo.datenum > phantomFilenameInfo.datenum
        error(['The trial ' trialName ' file is newer than the phantom file '  phantomFilenameInfo.name ]) 
    else
        %do nothing 
    end
   % phantomFilenameInfo.datenum
    
    load(fullfile(matFullFilepath,phantomObjectFilename),'objPhantom');
   % offsetZ_m=trialData.collection.fieldii.offsetZ_m;
    
    [ objFieldII ] = objFieldIISetup('ultrasonix');
            
    fieldIISimulate
    objFieldIIShutdown( objFieldII );
end




if useParallelProcessing
    %matlabpool('close') %#ok<UNRCH>
    delete(matlabpool);
end
