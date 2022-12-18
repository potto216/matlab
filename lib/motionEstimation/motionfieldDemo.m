clear
close all
clear class

modelName='lineMotion';
modelName='circleMotionSmooth';
dataBlockObj=DataBlockObj(modelRigid(modelName),'matlabArray');
imBlock=dataBlockObj.blockData;


%% Show the image
f1=figure; 
for ii=1:size(imBlock,3)
   figure(f1); 
    imagesc(imBlock(:,:,ii));
    colorbar  
    caxis([.2 .8])
    title(['Frame ' num2str(ii) ' of ' num2str(size(imBlock,3))]);
    pause(.1)  
end


%% Run the motion field
%roiPoints_rc=[100:20:200; 100:20:200];
%roiPoints_rc=[roiPoints_rc [300:10:400; 300:10:400]];
%[mx, my]=meshgrid(100:100:400,100:100:400);
[mx, my]=meshgrid(100:1:150,100:1:150);
roiPoints_rc=[mx(:) my(:)].';
 %[track] = motionfield(imBlock,roiPoints_rc,'searchxsize',14,'algorithm','crosscorrOversample');

[track] = motionfield(dataBlockObj,roiPoints_rc,'algorithm','opticalFlow');
 
[regionBox_rc, regionBoxCenter_rc,regionBoxOffset_rc,fullTrackPathDelta_rc]=trackstitch(track,dataBlockObj);

