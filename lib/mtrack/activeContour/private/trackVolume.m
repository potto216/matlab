volumeData=load('R:\potto\data\volume\trap\collect001\03_vol\scanConvert_frame5.mat');


%%
f1=figure; 

for ii=-30:30
    figure(f1)
    %imagesc(squeeze(volumeData.FAN(:,101+ii,:))); colormap(gray(256))
    imagesc(squeeze(volumeData.FAN(:,:,101+ii))); colormap(gray(256))
    title(num2str(ii))
    pause(0.3)
end