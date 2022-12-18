clear
close all


%activeTrialCaseList
singleTrialCaseListLongRun

useParallelProcessing=false;
forceNewPhantom=false;


computerInformation=loadComputerSpecificData();

if useParallelProcessing
    localCoresToUse=min(computerInformation.numCores,8); 
    disp(['Opening ' num2str(localCoresToUse) ' cores.'])
    matlabpool('open','local',localCoresToUse);
end


parfor tt=1:length(trialNameList)
    
    [ objFieldII ] = objFieldIISetup('ultrasonix');
    
    trialName=trialNameList{tt};
    matFilepath=[];
    matFilepath.root=getenv('ULTRASPECK_ROOT');
    matFilepath.relative='workingFolders\potto\data\phantom';
    matFilepath.trialFolder=trialName;
    
    matFullFilepath=fullfile(matFilepath.root, matFilepath.relative,matFilepath.trialFolder);
   if ~exist(matFullFilepath,'dir')
        mkdir(matFullFilepath);
    else
        %do nothing
    end
    
    phantomObjectFilename=['phantom_' trialName '.mat'];
    
    caseFilename=fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\data\caseFiles',[trialName '.m']);
    [metadata]=loadCaseData(caseFilename);
        
    imageWidth_pel=getCaseLateralPixelCount(metadata);                           
    imageSize_rc=[getCaseAxialPixelCount(metadata) imageWidth_pel*4];
    
    
    
    if exist(fullfile(matFullFilepath,phantomObjectFilename),'file') && ~forceNewPhantom
        disp(['Loading ' phantomObjectFilename ' from disk']);
        objPhantom=parforLoadData_phantomSimulateTendonMotion(fullfile(matFullFilepath,phantomObjectFilename));        
    else
        totalBackgroundScatters=100000;
        totalTendonScatters=300;
        [ objPhantom ] = phantomLoad( 'tendon',{'totalBackgroundScatters',totalBackgroundScatters, ...
            'totalTendonScattersPerBand', totalTendonScatters, ...
            'caseFilename',caseFilename} ...
            ,objFieldII );
                
        tendonMotion=[(0:1:12) (11:-1:-12) (-11:1:12) (11:-1:-12) (-11:1:12) (11:-1:-12) (-11:1:12) (11:-1:-12) (-11:1:12)];
        tendonPercentDensity=0.35;
        objPhantom=phantomTendonModel(objPhantom,tendonPercentDensity,tendonMotion);
    end
    
    
    
    
    [ imBackground ] = phantomPlot(objPhantom,objPhantom.background,imageSize_rc);
    if false
        %% show the background plot
        figure; imagesc(linspace(objPhantom.xLim_m(1),objPhantom.xLim_m(2),imageSize_rc(2)),linspace(objPhantom.zLim_m(1),objPhantom.zLim_m(2),imageSize_rc(1)),abs(imBackground)); colormap(gray(256)); %#ok<UNRCH>
    end
    
    %%
    maxFrames=length(objPhantom.tendon.model.tendonMotion);
    imBlock=zeros([imageSize_rc(1) 128 maxFrames]);
    f1=figure;
    for pp=1:maxFrames
        phantomTendon=phantomTendonGetPosition(objPhantom,pp);
        [ imTendon ] = phantomPlot(objPhantom,phantomTendon,imageSize_rc);
        
        im=abs(imTendon)+abs(imBackground);
        imBlock(:,:,pp)=imresize(imfilter(im,fspecial('gaussian',[9,3],3),'replicate'),[imageSize_rc(1) 128],'bicubic');
        
        figure(f1)
        imagesc(imBlock(:,:,pp)); colormap(gray(256))
        title(['Frame ' num2str(pp) ' of ' num2str(maxFrames)]);
        pause(.3)
        
    end
    
    %%


    parforSaveData_phantomSimulateTendonMotion(matFilepath,phantomObjectFilename,objFieldII,imBlock,objPhantom);
    
end



if useParallelProcessing
    matlabpool('close') 
end
