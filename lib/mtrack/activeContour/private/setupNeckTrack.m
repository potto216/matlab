clear 
close all
rfBaseFilename='13-08-41.rf';
rfBaseFilename='13-08-41.b8';
rfFilename=fullfile('Z:\Users\potto\PAUL_TRAP_MOTION\03-29-2013-MSK\',rfBaseFilename); %contraction/relaxation with handweight

%create image for spline marking
 

baseFrame=40;
if false
%%    
    [imBase, imHeader]=uread(rfFilename,baseFrame,'frameFormatComplex',true);
    figure; imagesc(abs(imBase).^0.5); colormap(gray(256));
    [gx,gy]=ginput(8);
    figure; imagesc(abs(imBase).^0.5); colormap(gray(256));
    hold on
    plot(gx,gy,'ro-')
else
    [~, imHeader]=uread(rfFilename,-1);
    selx=[ 3.7442   19.6705   53.8825   93.4032  132.3341  173.0346  214.9147  252.0760];
    sely=[ 1.1398    1.1536    1.1719    1.1994    1.2086    1.2269    1.1948    1.1627]*1e3;
    
    
    selx=[44.9147   82.0207  122.5000  205.7074  259.6797  313.6521  363.1267  440.7120];
    sely=[250.8450  256.0497  255.0088  263.3363  267.5000  263.3363  258.1316  253.9678];

    nMagdFract=4;
    
    vBase_rc=fix([sely(:) selx(:)])';
end

maxIterations=10;
totalSlices=7;

snakeEnergyCollect=zeros(maxIterations,1);
skipVideo=false;
vidAll=vopen(['snakeAll' rfBaseFilename '.gif'],'w',1,{'gif','DelayTime',1},true);
vidOpt=vopen(['snakeOpt' rfBaseFilename '.gif']','w',1,{'gif','DelayTime',1},skipVideo);

zoomAxialAxis=[];
%zoomAxialAxis=[800 1400];
brightRegionPosition='bottom';

for offsetFrame=0:3:(imHeader.nframes-baseFrame-1)
    if strcmpi('.rf',rfBaseFilename(end-2:end))
        [im, imHeader]=uread(rfFilename,baseFrame+offsetFrame,'frameFormatComplex',true);
        im=abs(im).^0.5;
    elseif strcmpi('.b8',rfBaseFilename(end-2:end))
        [im, imHeader]=uread(rfFilename,baseFrame+offsetFrame);       
    else
        error('Unsupport file extension');
    end
    runNeckAlgorithm
    close(fOpt);
    close(f1);
    
end

vidAll=vclose(vidAll);
vidOpt=vclose(vidOpt);
