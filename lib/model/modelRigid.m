%This function will model motion of a scene and return an image block which
%can be used for tracking
function [imBlock, modelParameters]=modelRigid(motionModel,sceneModel, pixelsPerFrame)

switch(nargin)
    case 2
        pixelsPerFrame=2;
    case 3
        %do nothing
    otherwise
        error([num2str(nargin) ' is an invalid number of input arguments.']);
end

switch(motionModel)
    case 'lineMotion'
        [imBlock,modelParameters]=lineMotionModel(sceneModel, pixelsPerFrame);
        modelParameters.modelRigid.motionModel='lineMotion';
    case 'circleMotionSmooth'
        [imBlock,modelParameters]=circleMotionSmoothModel(sceneModel, pixelsPerFrame);
        modelParameters.modelRigid.motionModel='circleMotionSmooth';
    otherwise
        error(['Unsuppported motion model of ' motionModel]);
end

end

function [imBlock, modelParameters]=circleMotionSmoothModel(sceneModel, pixelsPerFrame)

m=pixelsPerFrame*exp(1j*linspace(0,2*pi,24));
motion_rc = [real(m);imag(m)];

blockStartPoint_rc=min(motion_rc,[],2);
maxMotion_rc=ceil(max(motion_rc,[],2)-min(motion_rc,[],2));

frameSize_rc=[512; 512];
imBlock=zeros(frameSize_rc(1),frameSize_rc(2),size(motion_rc,2));

switch(sceneModel)
    case 'randomUniform'
        [s1] = RandStream.create('mt19937ar','seed',0);
        imMasterPre=rand(s1,reshape(maxMotion_rc+frameSize_rc,1,[]));
    otherwise
        error(['Unsupported scene model of ' sceneModel])
end


hsize=[5 5]; sigma=1.5;
h = fspecial('gaussian', hsize, sigma);
imMaster = imfilter(imMasterPre, h);

if false
    figure;
    subplot(1,2,1);
    imagesc(imMasterPre);
    subplot(1,2,2);
    imagesc(imMaster);
    colormap(gray(256));
end

[colMasterGrid,rowMasterGrid] = meshgrid((1:size(imMaster,2)),(1:size(imMaster,1)));
[colGrid,rowGrid] = meshgrid((1:size(imBlock,2)),(1:size(imBlock,1)));

for ii=1:size(motion_rc,2)
    sp_rc=(motion_rc(:,ii)-blockStartPoint_rc);
    imBlock(:,:,ii)=interp2(colMasterGrid,rowMasterGrid,imMaster,colGrid+sp_rc(2),rowGrid+sp_rc(1),'cubic');
    
end

modelParameters.model.functionName='circleMotionSmoothModel';
modelParameters.model.motion_rc=motion_rc;

end


function [imBlock, modelParameters]=lineMotionModel(sceneModel, pixelsPerFrame)


motion_rc=cumsum([[0; 0] repmat([pixelsPerFrame;0],1,11) repmat([0;pixelsPerFrame],1,12)],2);
blockStartPoint_rc=min(motion_rc,[],2);
maxMotion_rc=max(motion_rc,[],2)-min(motion_rc,[],2);



if iscell(sceneModel)
    switch(sceneModel{1})
        case 'imagePng'            
            imMaster=double(imread(sceneModel{2},'png'));
            imMaster=imMaster/max(imMaster(:));
            figure; subplot(1,2,1); imshow(imMaster); subplot(1,2,2);  hist(imMaster(:),111);
            
            masterFrameSize_rc=reshape(size(imMaster),[],1);
            frameSize_rc=masterFrameSize_rc - maxMotion_rc;
            imBlock=zeros(frameSize_rc(1),frameSize_rc(2),size(motion_rc,2));
            modelParameters.model.image=imread(sceneModel{2});
        otherwise
            error(['sceneModel{1} = ' sceneModel{1} ' is not supported']);
    end
elseif ischar(sceneModel)
    frameSize_rc=[512; 512];
imBlock=zeros(frameSize_rc(1),frameSize_rc(2),size(motion_rc,2));
    switch(sceneModel)
        case 'randomUniform'
            [s1] = RandStream.create('mt19937ar','seed',0);
            imMaster=rand(reshape(maxMotion_rc+frameSize_rc,1,[]));
        case 'randomRayleigh'
            modelParameters.model.distribution.b=6;
            rayleighDistribution = makedist('Rayleigh','b',modelParameters.model.distribution.b);
            %ricianDistribution = truncate(ricianDistribution,0,10);
            masterFrameSize_rc=maxMotion_rc+frameSize_rc;
            imMaster = random(rayleighDistribution,masterFrameSize_rc(1),masterFrameSize_rc(2));
            imMaster=imMaster/max(imMaster(:));
            %figure; hist(imMaster(:),111); xlim([0 1])
        case 'randomRician'
            modelParameters.model.distribution.s=6;
            modelParameters.model.distribution.sigma=1;
            ricianDistribution = makedist('Rician','s',modelParameters.model.distribution.s,'sigma',modelParameters.model.distribution.sigma);
            %ricianDistribution = truncate(ricianDistribution,0,10);
            masterFrameSize_rc=maxMotion_rc+frameSize_rc;
            imMaster = random(ricianDistribution,masterFrameSize_rc(1),masterFrameSize_rc(2));
            imMaster=imMaster/max(imMaster(:));
            %figure; hist(imMaster(:),111); xlim([0 1])            
        case 'rectangle'
            %Provide a 100 to 1 contrast
            imMaster=0.1*ones(reshape(maxMotion_rc+frameSize_rc,1,[])); %don't make this exactly zero so speckle simulations can be used
            rectangleLocation_rc=[25;15]*[-1 1]+kron([1 1],floor(size(imMaster)'/2));
            imMaster(rectangleLocation_rc(2,1):rectangleLocation_rc(2,2),rectangleLocation_rc(1,1):rectangleLocation_rc(1,2))=1;
        otherwise
            error(['Unsupported scene model of ' sceneModel])
    end
else
    error(['Unsupported scene model class of ' class(sceneModel)]);
end


for ii=1:size(motion_rc,2)
    sp_rc=(motion_rc(:,ii)-blockStartPoint_rc);
    imBlock(:,:,ii)=imMaster((sp_rc(1)+1):(sp_rc(1)+frameSize_rc(1)),(sp_rc(2)+1):(sp_rc(2)+frameSize_rc(2)));
end

modelParameters.model.functionName='lineMotionModel';
modelParameters.model.motion_rc=motion_rc;

if false
    %% Show the figure
    f1=figure;
    for ii=1:size(imBlock,3)
        figure(f1);
        imagesc(imBlock(:,:,ii));
        colormap(gray(256));
    end
end

end