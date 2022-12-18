%This function will track an active contour segment over a set of frames
%INPUT
%dataBlockObj - The data source with the images
%trackFrameList - The list of frame indexes to track.
%activeContourVertices_rc - the vertices to use when tracking
%brightRegionPosition - of auto will have it choose top or bottom based on
%the overall intensity values
%showGraphics - 
%activeContourMethod - {'trackContourEdgeTrak','trackContourOpenSpline'}
function track=activeContourRun(dataBlockObj,trackFrameList,activeContourVertices_rc,brightRegionPosition,showGraphics,activeContourMethod)

baseFrame=trackFrameList(1);
numberOfActiveContourVertices=35;

selxMaster=activeContourVertices_rc(2,:);
selyMaster=activeContourVertices_rc(1,:);
selx=linspace(min(activeContourVertices_rc(2,:)), max(selxMaster),numberOfActiveContourVertices);
sely=spline(selxMaster,selyMaster,selx);
vBase_rc=fix([sely(:) selx(:)])';

%options that are independent for the active contour method
options.showGraphics=showGraphics;

switch(activeContourMethod)
    case 'trackContourEdgeTrak'
    options.nMagdFract=0.5;
    options.nMagdFract=2;   %a larger number means a smaller box size    
    options.maxIterations=10;
    options.totalSlices=5; %What is used by EdgeTrack

    case 'trackContourOpenSpline'
     
    options.alpha = 0.10;
    options.beta = 0.10;
    options.gamma = 1.00;
    options.kappa = 0.15;
    options.weline = 0.30*2;
    options.weedge = 0.40*2;
    options.weterm = 0.70*2;
    options.inter = 30;
    options.springK=0.9;

    otherwise
        error([activeContourMethod '']);
end


if options.showGraphics
    skipVideo=false;
    rfBaseFilename='';
    options.vidAll=vopen(['snakeAll' rfBaseFilename '.gif'],'w',1,{'gif','DelayTime',1},true);
    options.vidOpt=vopen(['snakeOpt' rfBaseFilename '.gif'],'w',1,{'gif','DelayTime',1},skipVideo);

else
    options.vidAll=[];
    options.vidOpt=[];
    %do nothing
end
    options.fOpt=[];
    options.f1=[];
    
    
track=[];
track(1).pt_rc=[];


for activeFrameIndex=1:length(trackFrameList) %(imHeader.nframes-baseFrame-1)
    activeFrame=trackFrameList(activeFrameIndex);
    disp(['Processing frame ' num2str(activeFrame)]);
    im=dataBlockObj.getSlice(activeFrame,1,'agentLab');
    
    %     if strcmpi('.rf',rfBaseFilename(end-2:end))
    %         im=dataBlockObj.getSlice(baseFrame+offsetFrame);
    %         %[im, imHeader]=uread(rfFilename,baseFrame+offsetFrame,'frameFormatComplex',true);
    %         im=abs(im).^0.5;
    %     elseif strcmpi('.b8',rfBaseFilename(end-2:end))
    %         im=dataBlockObj.getSlice(baseFrame+offsetFrame);
    %         %[im, imHeader]=uread(rfFilename,baseFrame+offsetFrame);
    %     else
    %         error('Unsupport file extension');
    %     end
    h = fspecial('gaussian', 11, 2);
    imf=imfilter(im,h);
    debug.activeFrame=activeFrame;
    switch(activeContourMethod)
        case 'trackContourEdgeTrak'
            [vBase_rc,options]=trackContourEdgeTrak(imf,vBase_rc,brightRegionPosition,options,debug);
        case 'trackContourOpenSpline'
            [vBase_rc,options]=trackContourOpenSpline(imf,vBase_rc,brightRegionPosition,options,debug);
        otherwise
    end
    
    track(activeFrameIndex).pt_rc=vBase_rc;
    
    if options.showGraphics
        close(options.fOpt);
        close(options.f1);
    else
        %do nothing
    end
end


if options.showGraphics
    options.vidAll=vclose(options.vidAll);
    options.vidOpt=vclose(options.vidOpt);
else
    %do nothing
end

end


function [vBase_rc,options]=trackContourEdgeTrak(im,vBase_rc,brightRegionPosition,options,debug)
 activeFrame=debug.activeFrame;
maxIterations=options.maxIterations;
nMagdFract=options.nMagdFract;   %a larger number means a smaller box size    
totalSlices=options.totalSlices;
showGraphics=options.showGraphics;
snakeEnergyCollect=zeros(maxIterations,1);
showGraphics=options.showGraphics;
fOpt=options.fOpt;
f1=options.f1;
vidAll=options.vidAll;
vidOpt=options.vidOpt;

%rfBaseFilename=[''];

zoomAxialAxis=[];
%zoomAxialAxis=[800 1400];

%runNeckAlgorithm
runEdgeTrackAlgorithm

options.fOpt=fOpt;
options.f1=f1;
options.vidAll=vidAll;
options.vidOpt=vidOpt;


end

function [vBase_rc,options]=trackContourOpenSpline(image,vBase_rc,brightRegionPosition,options,debug)
ys=vBase_rc(1,:);
xs=vBase_rc(2,:);
    

[smth,xs,ys,options.f1,options.vidAll,options.vidOpt] = openSplineActiveContour(image, xs, ys, options.alpha, options.beta, options.gamma, options.kappa, options.weline, options.weedge, options.weterm, options.inter,options.springK,options.showGraphics,options.f1,options.vidAll,options.vidOpt);

vBase_rc(1,:)=ys;
vBase_rc(2,:)=xs;

end