clear
close all

useParallelProcessing=true;
computerInformation=loadComputerSpecificData();

if useParallelProcessing
    localCoresToUse=min(computerInformation.numCores,8); %#ok<UNRCH>
    disp(['Opening ' num2str(localCoresToUse) ' cores.'])
    matlabpool('open','local',localCoresToUse);
end

activeTrialCaseList
singleTrialCaseListLongRun

for tt=1:length(trialNameList)
    trialName=trialNameList{tt};
    
    matFilepath=[];
    matFilepath.root=getenv('ULTRASPECK_ROOT');
    matFilepath.relative='workingFolders\potto\data\phantom';
    matFilepath.trialFolder=trialName;
    matFullFilepath=fullfile(matFilepath.root, matFilepath.relative,matFilepath.trialFolder);
    
    phantomObjectFilename=['phantom_' trialName '.mat'];
    load(fullfile(matFullFilepath,phantomObjectFilename),'objPhantom');
    
    [ objFieldII ] = objFieldIISetup('ultrasonix');
    
    
    phantomObjectFilename=['phantom_' trialName '.mat'];
    
    fieldIISimulateTendonMotion
    objFieldIIShutdown( objFieldII );
end




if useParallelProcessing
    matlabpool('close') %#ok<UNRCH>
end
