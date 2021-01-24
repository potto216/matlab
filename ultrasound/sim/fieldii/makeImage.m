%  Compress the data to show 60 dB of
%  dynamic range for the cyst phantom image
%
%  version 1.3 by Joergen Arendt Jensen, April 1, 1998.
%  version 1.4 by Joergen Arendt Jensen, August 13, 2007.
%          Clibrated 60 dB display made

f0= objFieldII.probe.centerFrequency_Hz;                 %  Transducer center frequency [Hz]
fs=objFieldII.sampleRate_Hz;                 %  Sampling frequency [Hz]
c=objFieldII.speedOfSound_mPerSec;                   %  Speed of sound [m/s]

objFieldII.collect.numberOfLines=50;         %  Number of lines in image
objFieldII.collect.imageWidth_m=30/1000;     %  Size of image sector
numberOfLines=objFieldII.collect.numberOfLines;              %  Number of lines in image
imageWidth_m=objFieldII.collect.imageWidth_m;      %  Size of image sector
dx_m=imageWidth_m/numberOfLines; %  Increment for image

%  Read the data and adjust it in time
f1=figure;
writeImage=false;

tStepList=1;
for ww=1:length(tStepList)
    
    min_sample=0;
    env=[];
    
    for ss=1:numberOfLines
        [rfData, tstart_sec]=objFieldIIPackageLoadScanLine(objFieldII,tStepList(ww),ss);
        %  Find the envelope        
        rf_env=abs(hilbert([zeros(round(tstart_sec*fs-min_sample),1); rfData]));
        env(1:max(size(rf_env)),ss)=rf_env;
    end
    
    %  Do logarithmic compression
    
    D=10;   %  Sampling frequency decimation factor
    %TODO: add warning if decimation factor will alias the signal
    
    disp('Finding the envelope')
    log_env=env(1:D:max(size(env)),:)/max(max(env));
    log_env=20*log10(log_env);
    log_env=127/60*(log_env+60);
    
    %  Make an interpolated image
    
    disp('Doing interpolation')
    ID=20;
    [n,m]=size(log_env);
    new_env=zeros(n,m*ID);
    for ss=1:n
        new_env(ss,:)=abs(interp(log_env(ss,:),ID));
    end
    [n,m]=size(new_env);
    
    fn=fs/D;
    %%
    figure(f1)
    clf
    subplot(1,2,1)
    lDistance_mm=((1:(numberOfLines-1))*dx_m-numberOfLines*dx_m/2)*1000;
    aDistance_mm=(((1:n)-1)/fn)*c/2*1000;
    %aDistance_mm=(((1:n)-1)/fn+min_sample/fn)*c/2*1000;
    imagesc(lDistance_mm,aDistance_mm,log_env)
    xlabel('Lateral distance [mm]')
    ylabel('Axial distance [mm]')
    colormap(gray(127))
    axis([-imageWidth_m*1000/2 imageWidth_m*1000/2 0 max(aDistance_mm)])

    title(['Frame = ' num2str(ww)]);
    
    
    subplot(1,2,2)
    image(lDistance_mm,aDistance_mm,new_env)
    xlabel('Lateral distance [mm]')
    ylabel('Axial distance [mm]')
    colormap(gray(127))
    axis([-imageWidth_m*1000/2 imageWidth_m*1000/2 0 max(aDistance_mm)])
    title(['Frame = ' num2str(ww)]);
    
    %%
    if writeImage
        set(f1,'Position',[628 455 972 594])
%    axis('image')        
        ims=getframe(gcf);
        [capturedColorIndex,capturedColormap] = rgb2ind(ims.cdata,128);
        if ww==1
            imwrite(capturedColorIndex,capturedColormap,'phantomTendon.gif','gif','WriteMode','overwrite','DelayTime',1);
        else
            imwrite(capturedColorIndex,capturedColormap,'phantomTendon.gif','gif','WriteMode','append','DelayTime',1);
        end
        
        pause(.5)
    end
    
end