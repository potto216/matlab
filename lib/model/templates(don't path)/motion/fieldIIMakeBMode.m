%  Compress the data to show 60 dB of
%  dynamic range for the cyst phantom image
%
%  version 1.3 by Joergen Arendt Jensen, April 1, 1998.
%  version 1.4 by Joergen Arendt Jensen, August 13, 2007.
%          Clibrated 60 dB display made

%[ objFieldII ] = objFieldIISetup('ultrasonix');
clear
%  Read the data and adjust it in time
f1=figure;
skipImageCreate=false;
dualImage=false;

if dualImage
    filenamePrefix='dual_'; %#ok<UNRCH>
else
    filenamePrefix='mono_';
end


activeTrialCaseList


for tt=1:length(trialNameList)
    
    
    trialName=trialNameList{tt};
    
    % filePath='R:\potto\ultraspeck\workingFolders\potto\MATLAB\simulations\fieldII';
    % filePath='R:\potto\ultraspeck\workingFolders\potto\MATLAB\Walkaid\rfTrackSamples';
    
    matFullPhantomPath=fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\data\phantom',trialName);
    
    objFieldII.package.timeStepBaseDirname='timeStep_';
    objFieldII.package.scanLineBaseFilename='rfScanLine_';
    
    load(fullfile(matFullPhantomPath,['tendonMotion_' trialName],'objFieldII.mat'),'objFieldII');
    load(fullfile(matFullPhantomPath,['tendonMotion_' trialName],'objPhantom.mat'),'objPhantom');
    
    [fp1,caseFilenameBase,caseFilenameExt]=fileparts(objPhantom.phantomArguments{6});
    [metadata]=loadCaseData(fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\data\caseFiles',[caseFilenameBase caseFilenameExt]) );
    caseName=getCaseName(metadata);
    %[~,header]=uread(metadata.rfFilename,-1);
    
    
    %% This is a tempary override until the next sim is done
    if false
        
        objFieldII.collect.numberOfLines=objFieldII.probe.elementTotalPhysical; %#ok<UNRCH>
        objFieldII.collect.imageWidth_m=objFieldII.collect.numberOfLines*(objFieldII.probe.element.width_m+objFieldII.probe.element.kerf_m);
        objFieldII.collect.phantomOffsetZ_m=6/1000;
    end
    
    objFieldII.package.filePath=matFullPhantomPath;
    
    tStepList=1:length(objPhantom.tendon.model.tendonMotion);
    
    f0= objFieldII.probe.centerFrequency_Hz;                 %  Transducer center frequency [Hz]
    fs=objFieldII.sampleRate_Hz;                 %  Sampling frequency [Hz]
    c=objFieldII.speedOfSound_mPerSec;                   %  Speed of sound [m/s]
    
    numberOfLines=objFieldII.collect.numberOfLines;              %  Number of lines in image
    imageWidth_m=objFieldII.collect.imageWidth_m;      %  Size of image sector
    dx_m=objFieldII.probe.element.width_m+objFieldII.probe.element.kerf_m;
    
    rX=[]; rY=[]; fX=[]; fY=[];
    imBlock=[];
    

    vid=vopen(['phantomTendon_' filenamePrefix objFieldII.package.name '.gif'],'w',1,{'gif','DelayTime',1},skipImageCreate);
    
    for ww=1:length(tStepList)
        disp(['Processing step ' num2str(ww) ' of ' num2str(length(tStepList))]);
        min_sample=0;
        env=[];
        
        for ss=1:numberOfLines
            [rfData, tstart_sec]=objFieldIIPackageLoadScanLine(objFieldII,tStepList(ww),ss);
            %  Find the envelope
            rf_env=abs(hilbert([zeros(round(tstart_sec*fs-min_sample),1); rfData]));
            env(1:max(size(rf_env)),ss)=rf_env; %#ok<SAGROW>
        end
        %%
        offset_m=objFieldII.collect.phantomOffsetZ_m;
        offset_pel=round((offset_m/(c/2))*fs);
        imFrameRaw=env(offset_pel:end,:);
        
        rawLateral_mm=((1:(numberOfLines))*dx_m-numberOfLines*dx_m/2)*1000;
        rawAxial_mm=((0:(size(imFrameRaw,1)-1))/fs)*(c/2)*1000;
        
        
        finalLateral_mm=rawLateral_mm;
        finalAxial_mm=((0:(getCaseAxialPixelCount(metadata)-1))/getCaseAxialSampleRate(metadata))*(c/2)*1000;
        if isempty(rX)
            [rX,rY]=meshgrid(rawLateral_mm,rawAxial_mm);
            [fX,fY]=meshgrid(finalLateral_mm,finalAxial_mm);
        end
        imFrameFinal=interp2(rX,rY,imFrameRaw,fX,fY,'spline');
        if isempty(imBlock)
            imBlock=zeros(size(imFrameFinal,1),size(imFrameFinal,2),length(tStepList));
        else
            %do nothing
        end
        imBlock(:,:,ww)=imFrameFinal; %#ok<SAGROW>
        %axial_mm=(((offset_pel:(size(env,1)-1))-offset_pel)/fs)*(c/2)*1000;
        
        if false
            figure; %#ok<UNRCH>
            subplot(1,2,1)
            imagesc(rawLateral_mm,rawAxial_mm,imFrameRaw.^0.5); colormap(gray(256));
            
            subplot(1,2,2)
            imagesc(finalLateral_mm,finalAxial_mm,imFrameFinal.^0.5); colormap(gray(256));
        end
        
        figure(f1);
        imagesc(finalLateral_mm,finalAxial_mm,imFrameFinal.^0.5); colormap(gray(256));
        xlabel('Lateral distance [mm]')
        ylabel('Axial distance [mm]')
        colormap(gray(127))
        title(['Frame = ' num2str(ww)]);
        
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
    vid=vclose(vid);
    
    save(fullfile(matFullPhantomPath,['phantom_' caseName '_fieldII.mat' ]),'imBlock');
end