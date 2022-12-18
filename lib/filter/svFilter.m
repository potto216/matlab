%This method applies an SV filter to the image block. An SVD is taken over
%the iamge slide and a single pixel value is computed. This is repeated for
%all pixels.
%
%INPUT
%blk  - The image block to process. Its units are [row (axial), column (lateral), frame index]
%
%filterRegion - Where the filter should be applied. Empty is everywhere. It is defined in terms of:
%[xmin_lateral ymin_axial width_lateral height_axial frameStart
%frameStop]. If the frames are not specified then it is assumed all the
%frames will be processed.
%
%observationLength_axial - This is the number of fast time (axial samples)
%observations to use for the processing. This is generally the length of 2
%or 3 trnasmit pulses and the signal should be stationary over this length.
%The number must be odd.
%
%ensembleLength_frame - The number of slow time (frames) to use for the ensemble. This
%should be the length of the period of the artifact so it can be removed.
%It must be an odd number greater than 1.
%
% weightAlpha
%
% weightTau
%
% invalidProcessingRegion - how to handle invalid processing regions. These
% regions may occur when the processing region is close to a border and
% there is not proper ensemble or observation length support. In this case
% the pixel under evaluation can either be:
% 'original' -  (default) left as the original value
% <number> - replaced with a number such as 0 or NaN
%
%REFERENCE
%Mauldin, F. W., D. Lin, and J. A. Hossack. “The Singular Value Filter: A General Filter Design Strategy for PCA-Based Signal Separation in Medical Ultrasound Imaging.” IEEE Transactions on Medical Imaging 30, no. 11 (November 2011): 1951–64. https://doi.org/10.1109/TMI.2011.2160075.
function [processedBlk] = svFilter(blk, filterRegion, observationLength_axial, ensembleLength_frame, weightAlpha, weightTau, varargin)
p = inputParser;
p.addRequired('blk', @(x) isnumeric(x) && numel(size(blk))==3);
p.addRequired('filterRegion', @(x) isnumeric(x) && isvector(x) && any(numel(x)==[4 6]) && all(x>0));
p.addRequired('observationLength_axial', @(x) isnumeric(x) && isscalar(x) && mod(x,2)==1 && (x>0));
p.addRequired('ensembleLength_frame', @(x) isnumeric(x) && isscalar(x) && mod(x,2)==1 && (x>0));
p.addRequired('weightAlpha', @(x) isnumeric(x) && isscalar(x));
p.addRequired('weightTau', @(x) isnumeric(x) && isscalar(x));
p.addParameter('invalidProcessingRegion','original',@(x) any(strcmp(x,{'original'})) || (isscalar(x) && isnumeric(x)));
p.addParameter('skipWeights',false,@(x) islogical(x));

p.parse(blk, filterRegion, observationLength_axial, ensembleLength_frame, weightAlpha, weightTau, varargin{:});

invalidProcessingRegion = p.Results.invalidProcessingRegion;
skipWeights = p.Results.skipWeights;
debug = true;
showFrameTime=true;

%% Check and set the constraints
%columns
lateralStart=filterRegion(1);
lateralEnd=filterRegion(1)+filterRegion(3);
%There are no lateral constraints

%rows
axialStart=filterRegion(2);
axialEnd=filterRegion(2)+filterRegion(4);

observationLengthBorder_axial = ((observationLength_axial-1)/2);
minAxialStart = 1 + observationLengthBorder_axial;
if axialStart < minAxialStart
    warning(['Processing axial (row) truncated to ' num2str(minAxialStart)]);
    axialStart = minAxialStart ;
end

%if the block has 10 rows and the observation length is three then the
%processing needs to end at 10 - (3-1)/2 = 9 so that it will not extend
%beyond the border
maxAxialEnd = size(blk,1) - observationLengthBorder_axial;
if axialEnd > maxAxialEnd
    warning(['Processing axial (row) truncated to ' num2str(maxAxialEnd)]);
    axialEnd = maxAxialEnd ;
end


if numel(filterRegion)==6
    frameStart = filterRegion(5);
    frameEnd = filterRegion(6);
else
    frameStart = 1;
    frameEnd = size(blk,3);
end

ensembleLengthBorder_frame = ((ensembleLength_frame-1)/2);
minFrameStart = 1 + ensembleLengthBorder_frame;
if frameStart < minFrameStart
    warning(['Processing frame truncated to ' num2str(minFrameStart)]);
    frameStart = minFrameStart;
end

maxFrameEnd = size(blk,1) - ensembleLengthBorder_frame;
if frameEnd > maxFrameEnd
    warning(['Processing frame truncated to ' num2str(maxFrameEnd)]);
    frameEnd = maxFrameEnd;
end

%We need to determine the invalid border region if any and the compute region;
if ~strcmp(invalidProcessingRegion,'original')
    error('Only a value of "original" is supported for invalidProcessingRegion.');
    %TODO create processedBlk which is equal to scalar value
else
    processedBlk=blk;
end


if debug
    err=zeros((axialEnd-axialStart+1)*(lateralEnd-lateralStart+1)*(frameEnd-frameStart+1),1);
    ee=1;
end



for ff=frameStart:frameEnd
    if showFrameTime
        startTimerVal=tic;
    end
    for rr=axialStart:axialEnd
        for cc=lateralStart:lateralEnd
            slice = blk((rr-observationLengthBorder_axial):(rr+observationLengthBorder_axial), ...
                (cc):(cc), ...
                (ff-ensembleLengthBorder_frame):(ff+ensembleLengthBorder_frame));
            slice = permute(slice, [1 3 2]);
            [processedPoint, weights, s] = svdFilterSliceV3(slice, weightAlpha, weightTau, skipWeights);
            if debug
                [processedPointV1, weightsV1, sV1] = svdFilterSliceV1(slice, weightAlpha, weightTau, skipWeights);
            end
            if ~isempty(processedPoint)
                if ~isscalar(processedPoint)
                    error('Expected processedPoint to be a scalar');
                end
                processedBlk(rr,cc,ff)=processedPoint;
                if debug                    
                    err(ee)=(processedPoint-processedPointV1);
                end
            end
            if debug
                ee=ee+1;
            end
        end
    end
    if showFrameTime
        elapsedTime=toc(startTimerVal);
        disp(['Frame ' num2str(ff) ' of ' num2str(frameEnd) ' took ' num2str(elapsedTime) ' seconds.'])
    end
end
if debug
    figure; imagesc(processedBlk(:,:,117)); title('SV Filtered'); colormap(gray(256)); colorbar;
    figure; imagesc(abs(processedBlk(:,:,117))); title('SV Filtered'); colormap(gray(256)); colorbar;
    figure; imagesc(blk(:,:,117)); title('Original');  colormap(gray(256)); colorbar;
    figure; imagesc(processedBlk(:,:,117)-blk(:,:,117)); colormap(gray(256)); colorbar
    figure; hist(abs(err),1111); xlabel('error magnitude'); ylabel('count'); title('Error between SV filter methods')
    figure; hist(reshape(blk(:,:,117),[],1),1111); xlabel('pixel value'); ylabel('count'); title('Original image')
    figure; hist(reshape(processedBlk(:,:,117),[],1),1111); xlabel('pixel value'); ylabel('count'); title('SVF image')
    
    im=processedBlk(:,:,117);
    im(im<-10)=0;
    figure; imagesc(im); title('SV Filtered');  colormap(gray(256)); colorbar;
    disp('end');
end
end


function [processedPoint, weights, s] = svdFilterSliceV3(slice, weightAlpha, weightTau, skipWeights)
%In the paper V are slow time motion basis vectors
[U,S,V]=svd(slice);
[M, N]=size(slice);
V = V.'; %paper wants the singular values as row vectors

s=diag(S);
sm=[s; zeros(N-numel(s),1)];
if all(s==0)
    processedPoint=[];
    weights=[];
    s=[];
    return;
end
weights = (1 - 1./(1+exp(-weightAlpha*(sm/sum(sm)-weightTau))));
if any(isnan(weights))
    error('The weights are NaN which indicates a sum of zero for the singular values');
end

if skipWeights
  %weights = [ones(size(s)); zeros(N-numel(s),1)];
     weights = ones(N,1);
end



x = slice((size(slice,1)-1)/2+1,:);
gamma = x*V';

y = zeros(1,N);
for k=1:N
    y = y + weights(k)*gamma(k)*V(k,:);
end
processedPoint = y((N-1)/2+1);
end

function [processedPoint, weights, s] = svdFilterSliceV1(slice, weightAlpha, weightTau, skipWeights)
%In the paper V are slow time motion basis vectors
[U,S,V]=svd(slice);
V=V.';
s=diag(S);

if all(s==0)
    processedPoint=[];
    weights=[];
    s=[];
    return;
end
weights = (1 - 1./(1+exp(-weightAlpha*(s/sum(s)-weightTau))));
if any(isnan(weights))
    error('The weights are NaN which indicates a sum of zero for the singular values');
end

if ~skipWeights
    Wm=diag([weights; zeros(size(V,1)-numel(s),1)]);
else
    Wm=diag([ones(size(weights)); zeros(size(V,1)-numel(s),1)]);
end

processedSlice = slice*V'*Wm*V;
processedPoint = processedSlice((size(processedSlice,1)-1)/2+1,(size(processedSlice,2)-1)/2+1);
end

% function [processedSlice, weights, s] = svdFilterSliceV2(slice, weightAlpha, weightTau)
% %In the paper V are slow time motion basis vectors
% [U,S,V]=svd(slice');
% 
% s=diag(S);
% 
% if all(s==0)
%     processedSlice=[];
%     weights=[];
%     s=[];
%     return;
% end
% weights = (1 - 1./(1+exp(-weightAlpha*(s/sum(s)-weightTau))));
% if any(isnan(weights))
%     error('The weights are NaN which indicates a sum of zero for the singular values');
% end
% 
% Sm=diag(weights.*s);
% processedSlice = permute(slice'*V'*Sm*V,[2 1]);
% end
% 
% 




function [processedBlk, svdSpectrum, svdWeightedSpectrum, weightSpectrum] = svFilterOld(blk, filterRegion, frameIndexes, weightAlpha, weightTau, runLength, accetableCutoffPercentage)
if runLength <= 0
    error('runLength must be greater than zero.');
end

adjustedHeight = ((floor(filterRegion(end)/runLength))*runLength );
if adjustedHeight <= runLength
    error(['The adjustedHeight value of ' num2str(adjustedHeight) ' must be at least equal to runLength.']);
end

if mod(numel(frameIndexes),2)==0
    error(['frameIndexes must have an odd number of elements '  num2str(numel(frameIndexes))]);
end

if numel(frameIndexes)==1 && mod(frameIndexes,2)==0
    error(['The scalara frameIndexes must be an odd number of elements '  num2str(frameIndexes)]);
end

%Cut out a subblock of the correct size
if numel(frameIndexes)>1
    edgeFrames=(frameIndexes-1)/2;
    centerFramesToProcess =  edgeFrames+1;
    
else
    centerFramesToProcess=(1:size(blk,3));
    edgeFrames=(frameIndexes-1)/2;
end

%only modify rrequested frames
processedBlk = blk;
for cf=centerFramesToProcess
    
    
    disp(['Processing center frame ' num2str(cf) ' of ' num2str(centerFramesToProcess(end))]);
    if (cf - edgeFrames) < 1 || (cf + edgeFrames) > size(blk,3)
        disp('Not enough window support for the center frame so setting it equal to zero.');
        processedBlk(:,:,cf)=0;
        continue;
    end
    
    %process a single frame
    frameIndexesSinglePass =1:(2*edgeFrames+1);
    processedSubBlk=blk(:,:,(cf - edgeFrames):(cf + edgeFrames));
    
    %this is the start of each run
    for ir = filterRegion(2) : runLength : (filterRegion(2)+adjustedHeight)
        filterRegionSinglePass=[filterRegion(1), ir, filterRegion(3), runLength];
        % disp(['Processing row ' num2str(ic)]);
        [processedSubBlk, svdSpectrum, svdWeightedSpectrum, weightSpectrum] = svdFilterSinglePass(processedSubBlk, filterRegionSinglePass, frameIndexesSinglePass, weightAlpha, weightTau);
    end
    
    %Insert the center frame back
    processedBlk(:,:,cf) = processedSubBlk(:,:,edgeFrames + 1);
end

sortedProcessedBlk=sort(processedBlk(:));
minValue=sortedProcessedBlk(min(ceil(accetableCutoffPercentage*numel(processedBlk)),numel(processedBlk)));
disp(['The min value for a cutoff percentage of ' num2str(accetableCutoffPercentage*100) '% is ' num2str(minValue) '.']);

if minValue > 0
    %don't adjust min if positive
    disp('Because the min is positive the adjustment step is skipped.');
else
    processedBlk = processedBlk - minValue;
end

processedBlk(processedBlk<0)=0;

if any(processedBlk(:)<0)
    error('processedBlk has negative values');
end
end

function [processedBlk, svdSpectrum, svdWeightedSpectrum, weightSpectrum] = svdFilterSinglePass(blk, filterRegion, frameIndexes, weightAlpha, weightTau)

%lateral is x
scanlines=filterRegion(1):(filterRegion(1)+filterRegion(3)-1);

%axial is y
axialSlice=filterRegion(2):(filterRegion(2)+filterRegion(4)-1);

sBlk=blk(axialSlice,scanlines,frameIndexes);

processedBlk = blk;

svdSpectrum=zeros(min(numel(axialSlice),numel(frameIndexes)),numel(scanlines));
weightSpectrum=zeros(size(svdSpectrum));
svdWeightedSpectrum=zeros(size(svdSpectrum));

%Loop over the scan lines and filter each image seperately
for ii=1:numel(scanlines)
    im=squeeze(sBlk(:,ii,:))';
    [U,S,V]=svd(im);
    
    s=diag(S);
    
    if all(s==0)
        continue;
    end
    weights = (1 - 1./(1+exp(-weightAlpha*(s/sum(s)-weightTau))));
    if any(isnan(weights))
        error('The weights are NaN which indicates a sum of zero for the singular values');
    end
    
    svdSpectrum(:,ii)=s;
    weightSpectrum(:,ii)=weights;
    svdWeightedSpectrum(:,ii)=weights.*s;
    
    
    %     c = size(S, 1);
    %     idx = 1:c+1:numel(S);
    %     Sm = zeros(size(S));
    %     Sm(idx) = svdWeightedSpectrum(:,ii);
    Sm=diag(svdWeightedSpectrum(:,ii));
    %Sm=eye(size(S));
    
    %figure; imagesc(U*Sm*V'); colormap(gray(256));
    
    %processedBlk(axialSlice,scanlines(ii),frameIndexes)=permute(U*Sm*V',[1 3 2]);
    processedBlk(axialSlice,scanlines(ii),frameIndexes)=permute(im*V'*Sm*V,[2 3 1]);
    
end

end



function plotWeightFunction
%%
%weightAlpha=20;
weightTau=0.5;
sigma=linspace(0,1,100);
weights = @(weightAlpha) (1 - 1./(1+exp(-weightAlpha*(sigma-weightTau))));

figure
plot(sigma, weights(0),'LineWidth',2)
hold on;
plot(sigma, weights(20),'--','LineWidth',2)
hold on;

plot(sigma, weights(1000),':','LineWidth',2)
hold on;

legend('\alpha=0','\alpha=20','\alpha=1000')
ylabel('w_k')
xlabel('~sigma_k')
ylim([-0.01 1.01])
title('SV filter weighting function')
end
