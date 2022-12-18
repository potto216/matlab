%TODO this assumes the same x/z world axis for all data
function phantomSimulateMotion(trialNameList,forceNewPhantom,useParallelProcessing)


if useParallelProcessing
    computerInformation.numCores=feature('numCores');
    localCoresToUse=min(computerInformation.numCores,8); %#ok<UNRCH>
    disp(['Opening ' num2str(localCoresToUse) ' cores.'])
    matlabpool=parpool('local',localCoresToUse);
end

physicalLengthUnits='mm';
for tt=1:length(trialNameList)
    
    trialName=trialNameList{tt};
    [trialData]=loadMetadata([trialName '.m']);
    %alias needed data
    matFullFilepath=fullfile(trialData.subject.phantom.filepath.pathToRoot, ...
        trialData.subject.phantom.filepath.root, ...
        trialData.subject.phantom.filepath.relative);
    phantomObjectFilename=trialData.subject.phantom.filename;
    
    if tIsBranch(trialData.subject.phantom,'reference.rfFilename')
        dataBlockObj=DataBlockObj(trialData.subject.phantom.reference.rfFilename,@uread,'openArgs',[]);
        dataBlockObj.open('cacheMethod','auto');
        dataBlockObj.newProcessStream('agentLab',trialData.subject.phantom.reference.processFunction, true);
    else
        dataBlockObj=[];
    end
    
    [ objFieldII ] = objFieldIISetup('ultrasonix');
    
    if ~exist(matFullFilepath,'dir')
        mkdir(matFullFilepath);
    else
        %do nothing
    end
    
    if exist(fullfile(matFullFilepath,phantomObjectFilename),'file') && ~forceNewPhantom
        disp(['Loading ' phantomObjectFilename ' from disk']);
        objPhantom=parforLoadData_phantomSimulateMotion(fullfile(matFullFilepath,phantomObjectFilename));
    else
        objPhantom=phantomCreateModel(trialData,objFieldII,dataBlockObj);
    end
    
    if isempty(dataBlockObj)
        rfHeight_pel=trialData.collection.ultrasound.rf.header.h;
        rfWidth_pel=trialData.collection.ultrasound.rf.header.w;
        rfAxialUnitsValue_mmPerPel=trialData.collection.ultrasound.rf.header.pixel.scale.axial.value;
        rfLateralUnitsValue_mmPerPel=trialData.collection.ultrasound.rf.header.pixel.scale.lateral.value;
    else
        rfHeight_pel=dataBlockObj.size(1);
        rfWidth_pel=dataBlockObj.size(2);
        rfAxialUnitsValue_mmPerPel=dataBlockObj.getUnitsValue('axial',physicalLengthUnits);
        rfLateralUnitsValue_mmPerPel=dataBlockObj.getUnitsValue('lateral',physicalLengthUnits);
    end
    
    maxFrames=phantomGetTotalFrames(objPhantom);
    
    %%%%%%%FOR LOOP START%%%%%
    imOutputFormatList=trialData.collection.projection.bmode.imOutputFormat;
    %{{'matchrf'},{'squarePixel','rowdim',512}};
    im=[];
    for ii=1:length(imOutputFormatList)
        switch(imOutputFormatList(ii).type)
            case 'matchrf'
                im(ii).finalHeight_pel=rfHeight_pel;
                im(ii).finalWidth_pel=rfWidth_pel;
                im(ii).rfAxialUnitsValue_mmPerPel=rfAxialUnitsValue_mmPerPel;
                im(ii).rfLateralUnitsValue_mmPerPel=rfLateralUnitsValue_mmPerPel;
                im(ii).oversampleFactor=4;
                im(ii).background.imFinalGain=imOutputFormatList(ii).background.imFinalGain;
                
            case 'squarePixel'
                if ~strcmp(imOutputFormatList(ii).dim.type,'axial')
                    error(['Only the axial axis is supported not the ' imOutputFormatList(ii).dim.type]);
                end
                
                totalAxialPixels=round(imOutputFormatList(ii).dim.size);
                %For square pixels we need to find the size factor.  If the
                %lateral dimension is larger then we need more pixels in
                %the lateral dimension so to find the ratio of lateral to
                %axial we use the following formula which takes the ratio
                %of the lateraltotal view length to the axial total view
                %length. If the ratio is greater than 1 it says how much 
                %wider the image is than it is longer. For example if 
                %ratioLateralToAxial = 1.725 could result from a lateral length of 60.4 mm
                %and a axial length of 35 mm. 
                ratioLateralToAxial=(rfLateralUnitsValue_mmPerPel*rfWidth_pel)/(rfHeight_pel*rfAxialUnitsValue_mmPerPel);
                %Also this ration means that if the lateral dimension is
                %twice as large the ratio would be two. Therefore because 
                %we are dealing with square pixels there should
                %be twice as many pixels in the lateral dimension. This is
                %relaized by the below equation
                totalLateralPixels=round(totalAxialPixels*ratioLateralToAxial);
                im(ii).finalHeight_pel=totalAxialPixels;
                im(ii).finalWidth_pel=totalLateralPixels;
                im(ii).rfAxialUnitsValue_mmPerPel=(rfHeight_pel*rfAxialUnitsValue_mmPerPel)/totalAxialPixels;
                im(ii).rfLateralUnitsValue_mmPerPel=(rfLateralUnitsValue_mmPerPel*rfWidth_pel)/totalLateralPixels;
                im(ii).oversampleFactor=4;
                im(ii).background.imFinalGain=imOutputFormatList(ii).background.imFinalGain;
                
            otherwise
                error(['The output format ' imOutputFormatList(ii).type ' is not defined.']);
        end
        
        
        %         [ im(ii).background_rc ] = phantomPlot(objPhantom,objPhantom.background,im(ii).oversample_rc);
        %         if false
        %             %% show the background plot (fix for new code)
        %             %figure; imagesc(linspace(objPhantom.xLim_m(1),objPhantom.xLim_m(2),im(ii).oversample_rc(2)),linspace(objPhantom.zLim_m(1),objPhantom.zLim_m(2),im(ii).oversample_rc(1)),abs(im(ii).background_rc)); colormap(gray(256)); %#ok<UNRCH>
        %         end
        
        %%
        im(ii).finalBlockSize_rc=[im(ii).finalHeight_pel im(ii).finalWidth_pel maxFrames];
        im(ii).finalBlock=zeros(im(ii).finalBlockSize_rc);
        
    end
    %%%%%%%FOR LOOP END%%%%%%%
    
    %     %add worldaxis
    %     for ii=1:length(im)
    %         im(ii).xWorldAxis_m=linspace(0, rfLateralUnitsValue_mmPerPel*(size(im(ii).finalBlock,2)-1),size(im(ii).finalBlock,2));
    %         im(ii).zWorldAxis_m=linspace(0,rfAxialUnitsValue_mmPerPel*size)(im(ii).finalBlock,1),size(im(ii).finalBlock,1));
    %     end
    
    f1=figure;
    truthData=zeros(5,maxFrames);
    for pp=1:maxFrames
        [phantomROISnapshot, averageMotion_m]=phantomGetPosition(objPhantom,pp,'all-scatters'); %replaced only-roiScatters with all-scatters
        truthData(:,pp)=[pp; averageMotion_m(:); trialData.subject.phantom.parameter.ts_sec];
        
        %%%%%%%FOR LOOP START%%%%%
        for ii=1:length(im)
            [im(ii).finalBlock(:,:,pp), im(ii).zWorldAxis_m, im(ii).xWorldAxis_m] = phantomPlot(objPhantom,phantomROISnapshot,im(ii).finalBlockSize_rc(1:2),...
                im(ii).rfAxialUnitsValue_mmPerPel, im(ii).rfLateralUnitsValue_mmPerPel, im(ii).oversampleFactor, trialData.collection.projection.bmode.imOutputFormat(ii).imresize.filter);
        end
        
        %%%%%%%FOR LOOP END%%%%%
        
        figure(f1) %Show all images
        for ii=1:length(im)
            subplot(1, length(im),ii)
            imagesc( im(ii).xWorldAxis_m*1000, im(ii).zWorldAxis_m*1000,sqrt(abs(im(ii).finalBlock(:,:,pp)))); colormap(gray(256))
            %xlabel('lateral (pel)'); ylabel('axial (pel)');
            xlabel('lateral (mm)'); ylabel('axial (mm)');
            if ii==1
                title([imOutputFormatList(ii).type ' frame ' num2str(pp) ' of ' num2str(maxFrames)])
            else
                title(imOutputFormatList(ii).type)
            end
        end
        pause(.3)
        
    end
    
    
    for ii=1:length(imOutputFormatList)
        imPngBlock=im(ii).finalBlock.^0.5;
        
        metadata.image.axis.column.ultrasound = 'lateral';
        metadata.image.axis.column.phantom = 'x';
        
        metadata.image.axis.row.ultrasound = 'axial';
        metadata.image.axis.row.phantom = 'z';
        
        filenameMask='%04d';
        fmt='png';
        filenameMaskPython='{:04d}.png';
        writeImageSequenceYaml(trialData, metadata.image, imPngBlock, [(im(ii).zWorldAxis_m(2)-im(ii).zWorldAxis_m(1)) (im(ii).xWorldAxis_m(2)-im(ii).xWorldAxis_m(1))], matFullFilepath, imOutputFormatList(ii).type, filenameMask, fmt, filenameMaskPython);
        writeRegionInformationYaml(imPngBlock, matFullFilepath, imOutputFormatList(ii).type)
    end
    %%
    
    
    parforSaveData_phantom( matFullFilepath,phantomObjectFilename,objFieldII,objPhantom,trialData)
    
    projectionDataPath=fullfile(trialData.collection.projection.bmode.filepath.pathToRoot, ...
        trialData.collection.projection.bmode.filepath.root, ...
        trialData.collection.projection.bmode.filepath.relative);
    if ~exist(projectionDataPath,'dir')
        mkdir(projectionDataPath);
    else
        %do nothing
    end
    parforSaveData_phantomProjection( projectionDataPath,'projectionImage.mat',im,trialData);
    truthData = [{'frame_number', 'x lateral (m)', 'y width (m)', 'z axial (m)', 'frame_time (sec)'}; arrayfun(@(x) x,truthData','uniformOutput', false)];
    xlswrite(fullfile(matFullFilepath,'truthData'), truthData);
    
end



if useParallelProcessing
    %matlabpool('close')
    delete(matlabpool)
end
