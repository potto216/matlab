
%Creates a bmode image based on phantom data. Uses dynamic range
%compression and is based on original code by Joergen Arendt Jensen.

%The below holds a mapping between what could be in the file and what it
%should be changed to. This handles the case when drive pathes change
%directoryMappings.processing{1} -> directoryMappings.processing{2}
function fieldIIMakeBMode(trialNameList, skipImageCreate, dualImage, directoryMappings)
%  Read the data and adjust it in time
f1=figure;
switch(nargin)
    case 3
        directoryMappings=[];
    case 4
        %do nothing
    otherwise
        error('Invalid number of input arguments');
end

if dualImage
    filenamePrefix='dual_'; %#ok<UNRCH>
else
    filenamePrefix='mono_';
end



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
    
    fieldIIPackageNameList=dirPlus(fieldIIRFDataFullFilepath,'relativePath',true);
    if length(fieldIIPackageNameList)~=1
        error('right now the code only supports one type of package.');
    else
        matFullPhantomPath=fullfile(fieldIIRFDataFullFilepath,fieldIIPackageNameList{1});
    end
    
    
    
    fieldIBModeDataFullFilepath=fullfile(trialData.collection.fieldii.bmode.filepath.pathToRoot, ...
        trialData.collection.fieldii.bmode.filepath.root, ...
        trialData.collection.fieldii.bmode.filepath.relative);
    if exist(fieldIBModeDataFullFilepath,'dir')
        %do nothing
    else
        mkdir(fieldIBModeDataFullFilepath)
    end
    
    
    
    load(fullfile(matFullPhantomPath,'objFieldII.mat'),'objFieldII');
    load(fullfile(matFullPhantomPath,'objPhantom.mat'),'objPhantom');
    
    if ~isempty(directoryMappings)
        indexFound=strfind(objFieldII.package.filePath,directoryMappings.processing{1});
        
        if ~exist(objFieldII.package.filePath,'dir') && ~isempty(indexFound) && indexFound == 1
            objFieldII.package.filePath = fullfile(directoryMappings.processing{2}, objFieldII.package.filePath((length(directoryMappings.processing{1})+1):end));
        end
    else
        %use whatever is in objFieldII.package.filePath
    end

    [ keyIdx ] = findKeyInPairList( objPhantom.phantomArguments,'DataBlockObj' );
    if length(keyIdx)==0
        dataBlockObj=[];
        caseName=trialData.subject.name;
    elseif length(keyIdx)==1
        [fp1,caseFilenameBase,caseFilenameExt]=fileparts(objPhantom.phantomArguments{keyIdx+1}.blockSource);
        
        caseName=caseFilenameBase;
        
        dataBlockObj=DataBlockObj(objPhantom.phantomArguments{keyIdx+1}.blockSource,@uread,'openArgs',[]);
        dataBlockObj.open;
    else
        error('There should only be one keyIdx');
    end
    
    
    
    
    
    %% This is a tempary override until the next sim is done
    if false
        
        objFieldII.collect.numberOfLines=objFieldII.probe.elementTotalPhysical; %#ok<UNRCH>
        objFieldII.collect.imageWidth_m=objFieldII.collect.numberOfLines*(objFieldII.probe.element.width_m+objFieldII.probe.element.kerf_m);
        objFieldII.collect.phantomOffsetZ_m=6/1000;
    end
    
    
    tStepList=1:phantomGetTotalFrames(objPhantom);
    
    f0= objFieldII.probe.centerFrequency_Hz;                 %  Transducer center frequency [Hz]
    fs=objFieldII.sampleRate_Hz;                 %  Sampling frequency [Hz]
    c=objFieldII.speedOfSound_mPerSec;                   %  Speed of sound [m/s]
    
    numberOfLines=objFieldII.collect.numberOfLines;              %  Number of lines in image
    imageWidth_m=objFieldII.collect.imageWidth_m;      %  Size of image sector
    dx_m=objFieldII.probe.element.width_m+objFieldII.probe.element.kerf_m;
    
    rX=[]; rY=[];
    
    
    
    %%%%%%%FOR LOOP START%%%%%
    imOutputFormatList=trialData.collection.projection.bmode.imOutputFormat;
    
    if isempty(dataBlockObj)
        
        caseLateralPixelCount=trialData.collection.ultrasound.rf.header.w;
        caseLateralPixelWidth_mm=trialData.collection.ultrasound.rf.header.pixel.scale.lateral.value;
        
        caseAxialPixelCount=trialData.collection.ultrasound.rf.header.h;
        caseAxialPixelDepth_mm=trialData.collection.ultrasound.rf.header.pixel.scale.axial.value;
        
        caseAxialSampleRate=trialData.collection.ultrasound.rf.header.sf;
        
    else
        caseLateralPixelCount=dataBlockObj.size(2);
        caseLateralPixelWidth_mm=dataBlockObj.getUnitsValue('lateral','mm');
        
        caseAxialPixelCount=dataBlockObj.size(1);
        caseAxialPixelDepth_mm=dataBlockObj.getUnitsValue('axial','mm');
        
        caseAxialSampleRate=dataBlockObj.getUnitsValue( 'axialSampleRate','samplePerSec');
    end
    
    
    im=[];
    for ii=1:length(imOutputFormatList)
        switch(imOutputFormatList(ii).type)
            case 'matchrf'
                imList(ii).finalLateral_mm=(0:(caseLateralPixelCount-1))*caseLateralPixelWidth_mm; %#ok<*AGROW>
                imList(ii).finalAxial_mm=((0:(caseAxialPixelCount-1))/caseAxialSampleRate)*(c/2)*1000;
                
                imList(ii).finalHeight_pel=length(imList(ii).finalAxial_mm);
                imList(ii).finalWidth_pel=length(imList(ii).finalLateral_mm);
                
                %compute the final coordinates once, but the raw coordinates every
                %frame
                [imList(ii).finalX_mm,imList(ii).finalY_mm]=meshgrid(imList(ii).finalLateral_mm,imList(ii).finalAxial_mm);
                
            case 'squarePixel'
                if ~strcmp(imOutputFormatList(ii).dim.type,'axial')
                    error(['Only the axial axis is supported not the ' imOutputFormatList(ii).dim.type]);
                end
                
                totalAxialPixels=round(imOutputFormatList(ii).dim.size);
                %For square pixels we need to find the size factor.  If the
                %lateral dimension is larger then we need more pixels in
                %the lateral dimension so to find the ratio of lateral to
                %axial we use the following formula which takes the ratio
                %of the lateral total view length to the axial total view
                %length
                ratioLateralToAxial=(caseLateralPixelWidth_mm*caseLateralPixelCount)/(caseAxialPixelCount*caseAxialPixelDepth_mm);
                
                %So this ration means that if the lateral dimension is
                %twice as large the ratio would be two since there should
                %be twice as many pixels in the lateral dimension
                totalLateralPixels=round(totalAxialPixels*ratioLateralToAxial);
                
                imList(ii).finalLateral_mm=((0:(totalLateralPixels-1))/(totalLateralPixels))*(caseLateralPixelCount*caseLateralPixelWidth_mm);
                imList(ii).finalAxial_mm=(0:(totalAxialPixels-1))/(totalAxialPixels)*((caseAxialPixelCount)/caseAxialSampleRate)*(c/2)*1000;
                
                imList(ii).finalHeight_pel=totalAxialPixels;
                imList(ii).finalWidth_pel=totalLateralPixels;
                
                %                 imList(ii).oversample_rc=[imList(ii).finalHeight_pel*4 imList(ii).finalWidth_pel*4];  %This will be downsampled later
                %                 imList(ii).background.imFinalGain=imOutputFormatList(ii).background.imFinalGain;
                %                 imList(ii).imresize.filter=imOutputFormatList(ii).imresize.filter;
                
                [imList(ii).finalX_mm,imList(ii).finalY_mm]=meshgrid(imList(ii).finalLateral_mm,imList(ii).finalAxial_mm);
                
            otherwise
                error(['The output format ' imOutputFormatList(ii).type ' is not defined.']);
        end
        
        
        if false
            %% show the background plot (fix for new code)
            %figure; imagesc(linspace(objPhantom.xLim_m(1),objPhantom.xLim_m(2),imList(ii).oversample_rc(2)),linspace(objPhantom.zLim_m(1),objPhantom.zLim_m(2),imList(ii).oversample_rc(1)),abs(imList(ii).background_rc)); colormap(gray(256)); %#ok<UNRCH>
        end
        
        %%
        imList(ii).finalBlockSize=[imList(ii).finalHeight_pel imList(ii).finalWidth_pel length(tStepList)];
        imList(ii).finalBlock=zeros(imList(ii).finalBlockSize);
        
    end
    %%%%%%%FOR LOOP END%%%%%%%
    
    
    
    
    vid=vopen(fullfile(fieldIBModeDataFullFilepath,['phantomFieldII_' filenamePrefix objFieldII.package.name '.gif']),'w',1,{'gif','DelayTime',1},skipImageCreate);
    
    for ww=1:length(tStepList)
        disp(['Processing step ' num2str(ww) ' of ' num2str(length(tStepList))]);
        min_sample=0;
        env=[];
        tstartArray_sec=[];
        for ss=1:numberOfLines
            [rfData, tstart_sec]=objFieldIIPackageLoadScanLine(objFieldII,tStepList(ww),ss);
            tstartArray_sec(end+1)=tstart_sec;
            %  Find the envelope
            if tstart_sec >= 0
                 rf_env=abs(hilbert([zeros(round(tstart_sec*fs-min_sample),1); rfData]));
            elseif tstart_sec < 0
                 samplesToTrim=round(abs(tstart_sec*fs));
                 rf_env=abs(hilbert(rfData(samplesToTrim:end)));                 
            end
                
            env(1:size(rf_env,1),ss)=rf_env; %#ok<SAGROW>
        end
        %%
%         offset_m=objFieldII.collect.phantomOffsetZ_m;
%         offset_pel=round((offset_m/(c/2))*fs);
        offset_pel=1;
        imFrameRaw=env(offset_pel:end,:);
        
        figure;
        bar(tstartArray_sec);
        xlabel('Line number')
        ylabel('start time (sec)');
        title(['Frame ' num2str(ww) ' line start time assuming an offset shift (pel) of ' num2str(offset_pel)])
        
        %rawLateral_mm=((1:(numberOfLines))*dx_m-numberOfLines*dx_m/2)*1000;
        rawLateral_mm=((0:(numberOfLines-1))*dx_m)*1000;  %start at zero to match with final image
        rawAxial_mm=((0:(size(imFrameRaw,1)-1))/fs)*(c/2)*1000;
        
        [rX,rY]=meshgrid(rawLateral_mm,rawAxial_mm);
        
        %%%%%%%%%%%%%%%%FOR--START%%%%%%%%%%%
        for ii=1:length(imOutputFormatList)
            imFrameFinal=interp2(rX,rY,imFrameRaw,imList(ii).finalX_mm,imList(ii).finalY_mm,'cubic',0);
            imFrameFinal(imFrameFinal(:)<0)=0;
            imList(ii).finalBlock(:,:,ww)=imFrameFinal;
            figure(f1);
            subplot(1,length(imOutputFormatList),ii);
            imagesc(imList(ii).finalLateral_mm,imList(ii).finalAxial_mm,imFrameFinal.^0.5); colormap(gray(256));
            xlabel('Lateral distance [mm]')
            ylabel('Axial distance [mm]')
            colormap(gray(256))
            title(['Frame = ' num2str(ww)]);
            
        end
        %%%%%%%%%%%%%%%%FOR--END%%%%%%%%%%%
        
        if true
            %%
            figure; %#ok<UNRCH>
            subplot(1,2,1)
            imagesc(rawLateral_mm,rawAxial_mm,imFrameRaw.^0.5); colormap(gray(256));
            title(['Raw frame ' num2str(ww)]);
            
            subplot(1,2,2)
            imagesc(imList(end).finalLateral_mm,imList(end).finalAxial_mm,imFrameFinal.^0.5); colormap(gray(256));
        end
        
        
        %%
        
        %set(f1,'Position',[628 455 972 594])
        if dualImage
            set(f1,'Position',[116   327   972   594]); %#ok<UNRCH>
        else
            %set(f1,'Position',[116   327   615   594]);
            set(f1,'Position',[170 148 615 594]);
        end
        
        
        drawnow
        vid=vwrite(vid,gca,'handle');
        
    end
    vclose(vid);
    
    %     for ii=1:length(imOutputFormatList)
    %         imOutputFormat=imOutputFormatList(ii);
    %         im=imList(ii);
    %
    %         outputPngPath=fullfile(fieldIBModeDataFullFilepath,['phantom_' caseName '_fieldII_' imOutputFormat.type ]);
    %         mkdir(outputPngPath)
    %         imPngBlock=im.finalBlock.^0.5;
    %         maxValue=max(imPngBlock(:));
    %         sliceSequence=[1:size(imPngBlock,3)];
    %         fmt='png';
    %         filenameMask='%04d';
    %         for iii=1:length(sliceSequence)
    %             fullFilename=fullfile(outputPngPath,sprintf([filenameMask '.%s'],iii,fmt));
    %             imPng=uint16(floor(imPngBlock(:,:,sliceSequence(iii))/maxValue*2^16));
    %             imwrite(imPng,fullFilename,fmt);
    %         end
    %
    %         finalAxial_mm=im.finalAxial_mm;
    %         save(fullfile(outputPngPath,'finalAxial_mm.txt'),'finalAxial_mm','-ascii');
    %
    %         finalLateral_mm=im.finalLateral_mm;
    %         save(fullfile(outputPngPath,'finalLateral_mm.txt'),'finalLateral_mm','-ascii');
    %         save(fullfile(fieldIBModeDataFullFilepath,['phantom_' caseName '_fieldII_' imOutputFormat.type '.mat' ]),'im','imOutputFormat');
    %     end
    
    for ii=1:length(imOutputFormatList)
       
        imPngBlock=imList(ii).finalBlock.^0.5;
        
        metadata.image.axis.column.ultrasound = 'lateral';
        metadata.image.axis.column.phantom = 'x';
        
        metadata.image.axis.row.ultrasound = 'axial';
        metadata.image.axis.row.phantom = 'z';
        
        filenameMask='%04d';
        fmt='png';
        filenameMaskPython='{:04d}.png';
        
        writeImageSequenceYaml(trialData, metadata.image, imPngBlock, ...
            [(imList(ii).finalAxial_mm(2)-imList(ii).finalAxial_mm(1)) (imList(ii).finalLateral_mm(2)-imList(ii).finalLateral_mm(1))], ...
            fieldIBModeDataFullFilepath, imOutputFormatList(ii).type, filenameMask, fmt, filenameMaskPython);
        
        writeRegionInformationYaml(imPngBlock, fieldIBModeDataFullFilepath, imOutputFormatList(ii).type)
    end
end