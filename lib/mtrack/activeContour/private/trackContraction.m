clear all
close all
rfFilename='Z:\Users\potto\PAUL_TRAP_MOTION\03-29-2013-MSK\13-08-41.rf';
rfFilename='Z:\Users\potto\PAUL_TRAP_MOTION\03-29-2013-MSK\13-13-38.rf';
rfFilename='Z:\Users\potto\PAUL_TRAP_MOTION\03-29-2013-MSK\13-14-53.rf';



[~, imHeader]=uread(rfFilename,-1,'frameFormatComplex',true);

%%
skipVideo=false
vidAll=vopen('neckMotion_13-14-53.gif','w',1,{'gif','DelayTime',1},skipVideo);

f1=figure; 

for ii=1:5:imHeader.nframes
    figure(f1)
    [im]=uread(rfFilename,ii-1,'frameFormatComplex',true);
    %imagesc(squeeze(volumeData.FAN(:,101+ii,:))); colormap(gray(256))
    imagesc(abs(im).^0.5); colormap(gray(256))
    title(num2str(ii))
    pause(0.3)
    vidAll=vwrite(vidAll,gca,'handle');
end

vidAll=vclose(vidAll);  

    



