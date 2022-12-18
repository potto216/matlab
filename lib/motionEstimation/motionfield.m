%This function will generate a motion field for a set of points over a
%sequence of frames if requested.  The coordiantes are in row column for a
%common screen setup. Because the function is geared towards ultrasound
%work where x is the lateral distance and z is the axial distance the row
%would correspond to z and the column to x.
%For the displacment the z direction is stored in the imagainary and the x is stored in the real.
%
%This function will temporally add paths and then restore the original path
%setup.
%
%INPUT
%imSource - This can be an image sequence where the third dimension is the
%image index, a case structure for tendon tracking or for shearwave data
%It can also be a cell, where the first element describes the source such
%as uread and the other elements have the data
%
%roiPoints_rc - the coordinates in (row,column) (axial/z,lateral/x) of the points to
%evaluate in the image.  The image coordinates are in terms of row/column.
%They define the upper left corner of the search window.  If this is empty
%then the feature point tracking algroithm is free to define the roi which
%is normally the entire region
%
%searchzsize - <40> the total row length of the search window.  the first
%row is at roiPoints_rc(1)
%searchxsize - <10> the total column length of the search window.  The first
%column is at roiPoints_rc(2)
%templatezsize - <26> the size of the template used in the search (number of rows)
%templatexsize - <4> the size of the template used in the search.  (number of columns)
%
%verbose <{false},true> - If true will display processing information such
%as current frame
%
%correlationCorrespondence - For 'correlationCorrespondence' the algorithm uses the boundary for the
%region.
%
%crosscorrOversample-
%
%opticalFlow -
%
%affineOpticalFlow -
%
%frameDirection - The direction the frames will be processed.  Can be
%forward or backward
%OUTPUT
%track - Track index of N is the match of image N with N+1
%%
% Author: Paul Otto using correlation code written by Mike Baraniecki
%TODO Must fix peak search!!!!
function [track] = motionfield(imSource,roiPoints_rc,varargin)
%
% step variables control the pixel increment between correlations.
% default is 1.
%!@TEMPLATE!@
p = inputParser;   % Create an instance of the class.
p.KeepUnmatched=true;
p.addRequired('imSource', @(x) (isnumeric(x) && length(size(x))==3) || iscell(x) || isa(x,'DataBlockObj'));
p.addRequired('roiPoints_rc', @(x) isempty(x) || (isnumeric(x) && (size(x,1)==2)));
p.addParamValue('algorithm','crosscorrOversample',  @(x) any(strcmpi(x,{'crosscorrOversample','opticalFlow','affineOpticalFlow','correlationCorrespondence'})));
p.addParamValue('frameDirection','forward', @(x) any(strcmpi(x,{'forward','backward'})));
p.parse(imSource,roiPoints_rc,varargin{:});

if isa(imSource,'DataBlockObj')
    %imSource=imSource.blockData;
    imSource=imSource.getSlice(1:imSource.size(3));
else
    %do nothing
end

switch(p.Results.frameDirection)
    case 'forward'
        %do nothing
    case 'backward'
        imSource=imSource(:,:,end:-1:1);
    otherwise
        error(['Unsupported frameDirection of ' p.Results.frameDirection]);
end

switch(p.Results.algorithm)
    case 'crosscorrOversample'
        [track] = crosscorrOversample(imSource,roiPoints_rc,varargin{:});
    case 'correlationCorrespondence'
        [track] = correlationCorrespondence(imSource,roiPoints_rc,varargin{:});
    case 'opticalFlow'
        [track] = opticalFlow(imSource,roiPoints_rc,varargin{:});
    case 'affineOpticalFlow'
        [track] = affineOpticalFlow(imSource,roiPoints_rc,varargin{:});
    otherwise
        error(['Unsupport motionfield algorithm of ' p.Results.algorithm]);
end

end

%roiPoints_rc are the minimum and maximum values that define the region of
%interest box
function [track] = correlationCorrespondence(imBlock,roiPoints_rc,varargin)
addpath(fullfile(getenv('ULTRASPECK_ROOT'),'common\matlab\ext\correlCorresp'))
cc = correlCorresp('image1', imBlock(:,:,1), 'image2', imBlock(:,:,2), 'printProgress', 100);

%!@TEMPLATE!@
[ keyIdx ] = findKeyInPairList( varargin,'correlationCorrespondenceSettings' );
correlationCorrespondenceSettings=varargin{keyIdx+1};
keyList=correlationCorrespondenceSettings{1};
values=correlationCorrespondenceSettings{2};
for ii=1:length(keyList)
    
    switch(keyList{ii})
        case 'featurePatchSize'
            cc.featurePatchSize=values.(keyList{ii});
        case 'relThresh'
            cc.relThresh=values.(keyList{ii});
        case 'searchPatchSize'
            cc.searchPatchSize=values.(keyList{ii});
        case 'searchBox'
            cc.searchBox=values.(keyList{ii});
        otherwise
            error(['Unsupported correlationCorrespondenceSettings of ' keyList{ii}]);
    end
end

for ii = 1:(size(imBlock,3)-1)
    disp(['===================FRAME ' num2str(ii) '================'])
    cc.image2 = imBlock(:,:,ii+1);  % set image2 - image1 is set in previous cycle
    cc = cc.findCorresps;   % computation for this pair of images
    DD=cc.corresps;
    if ~isempty(roiPoints_rc)
        
        validCols=colvecfun(@(x_cr) all(x_cr([2 1])>=roiPoints_rc(:,1) & x_cr([2 1])<=roiPoints_rc(:,2)),DD);
        track(ii).pt_rc=DD([2 1],validCols);
        track(ii).ptDelta_rc=[diff(DD([2 4],validCols),1,1); diff(DD([1 3],validCols),1,1)];
    else
        track(ii).pt_rc=DD([2 1],:);
        track(ii).ptDelta_rc=[diff(DD([2 4],:),1,1); diff(DD([1 3],:),1,1)];
        
    end
    cc = cc.advance;        % advance to the next frame: image2 -> image1
end

end

function [track] = opticalFlow(imSource,roiPoints_rc,varargin)
oldPath=addpath(fullfile(getenv('ULTRASPECK_ROOT'),'common\matlab\ext\HS'));

validIndex=reshape(sub2ind(size(imSource(:,:,1)),roiPoints_rc(1,:),roiPoints_rc(2,:)),[],1);

%walk around the block 123
%                      4X5
%                      678
%                     1     2      3     4    5    6     7    8
neighborOffset_rc=[-1 -1; -1  0; -1  1; 0 -1;0  1;1 -1;1 0;1 1]';
neighbor_rc=repmat(roiPoints_rc,[1 1 8]) + repmat(permute(neighborOffset_rc,[1 3 2]),[1 size(roiPoints_rc,2) 1]);
validNeighbors=(neighbor_rc(1,:,:)>=1) & (neighbor_rc(1,:,:)<=size(imSource,1)) & (neighbor_rc(2,:,:)>=1) & (neighbor_rc(2,:,:)<=size(imSource,2));
if ~all(validNeighbors(:))
    error('Please adjust the sample points so they are not on the border');
end

neighbor_index=permute(sub2ind(size(imSource(:,:,1)),neighbor_rc(1,:,:),neighbor_rc(2,:,:)),[3 2 1]);
track=struct([]);
for ii=1:(size(imSource,3)-1)
    disp(num2str(ii))
    [u, v] = HS(imSource(:,:,ii),imSource(:,:,ii+1), 1, 100, zeros(size(imSource,1),size(imSource,2)),zeros(size(imSource,1),size(imSource,2)),0,0);
    track(ii).ptDelta_rc=[v(validIndex) u(validIndex)]';
    track(ii).pt_rc = roiPoints_rc + track(ii).ptDelta_rc;
    
    track(ii).confidence.neighborVar=abs(var(u(neighbor_index),[],1))+abs(var(v(neighbor_index),[],1));
end

%of_rc=arrayfun(@(x) [x.v(validIndex) x.u(validIndex)]', trackOpticalFlow,'UniformOutput',false);
%ofMat_rc=cell2mat(permute(of_rc,[1 3 2]));
path(oldPath);
end

function [track] = affineOpticalFlow(imSource,roiPoints_rc,varargin)
oldPath=addpath(fullfile(getenv('ULTRASPECK_ROOT'),'common\matlab\ext\affine_flow'));
addpath(fullfile(getenv('ULTRASPECK_ROOT'),'common\matlab\ext\High accuracy optical flow\brox_zip'));

validIndex=reshape(sub2ind(size(imSource(:,:,1)),roiPoints_rc(1,:),roiPoints_rc(2,:)),[],1);

%walk around the block 123
%                      4X5
%                      678
%                     1     2      3     4    5    6     7    8
neighborOffset_rc=[-1 -1; -1  0; -1  1; 0 -1;0  1;1 -1;1 0;1 1]';
neighbor_rc=repmat(roiPoints_rc,[1 1 8]) + repmat(permute(neighborOffset_rc,[1 3 2]),[1 size(roiPoints_rc,2) 1]);
validNeighbors=(neighbor_rc(1,:,:)>=1) & (neighbor_rc(1,:,:)<=size(imSource,1)) & (neighbor_rc(2,:,:)>=1) & (neighbor_rc(2,:,:)<=size(imSource,2));
if ~all(validNeighbors(:))
    error('Please adjust the sample points so they are not on the border');
end

neighbor_index=permute(sub2ind(size(imSource(:,:,1)),neighbor_rc(1,:,:),neighbor_rc(2,:,:)),[3 2 1]);
track=struct([]);
for ii=1:(size(imSource,3)-1)
    disp(num2str(ii))
    
    af = affine_flow('image1', imSource(:,:,ii), 'image2', imSource(:,:,ii+1), ...
        'sigmaXY', 25, 'sampleStep', 25);
    af = af.findFlow;
    flow = af.flowStruct;
    error('Need to finish with block split');
    affine_flowdisplay(flow, imSource(:,:,ii), 50);
    
    im1=repmat(uint8((imSource(:,:,ii)/max(max(imSource(:,:,ii))))*255),[1 1 3]);
    im2=repmat(uint8((imSource(:,:,ii+1)/max(max(imSource(:,:,ii+1))))*255),[1 1 3]);
    [u, v] = optic_flow_brox(im1, im2);
    %[u, v] = HS(imSource(:,:,ii),imSource(:,:,ii+1), 1, 100, zeros(size(imSource,1),size(imSource,2)),zeros(size(imSource,1),size(imSource,2)),0,0);
    %     track(ii).ptDelta_rc=[v(validIndex) u(validIndex)]';
    %     track(ii).pt_rc = roiPoints_rc + track(ii).ptDelta_rc;
    %
    %     track(ii).confidence.neighborVar=abs(var(u(neighbor_index),[],1))+abs(var(v(neighbor_index),[],1));
end

%of_rc=arrayfun(@(x) [x.v(validIndex) x.u(validIndex)]', trackOpticalFlow,'UniformOutput',false);
%ofMat_rc=cell2mat(permute(of_rc,[1 3 2]));
path(oldPath);
end

% templatezseperation_pel - the spacing between the center points of the template
% templatexseperation_pel - the spacing between the center points of the template
function [track] = crosscorrOversample(imSource,roiPoints_rc,varargin)

p = inputParser;   % Create an instance of the class.
p.KeepUnmatched=true;
p.addRequired('imSource', @(x) (isnumeric(x) && length(size(x))==3) || iscell(x));
p.addRequired('roiPoints_rc', @(x) (isnumeric(x) && (size(x,1)==2)) || isempty(x));

p.addParamValue('searchzsize',40,  @(x) isscalar(x) && isnumeric(x));
p.addParamValue('searchxsize',10,  @(x) isscalar(x) && isnumeric(x));
p.addParamValue('templatezsize',26,  @(x) isscalar(x) && isnumeric(x));
p.addParamValue('templatexsize',4,  @(x) isscalar(x) && isnumeric(x));
p.addParamValue('templatezseperation_pel',[],  @(x) isscalar(x) && isnumeric(x));
p.addParamValue('templatexseperation_pel',[],  @(x) isscalar(x) && isnumeric(x))
p.addParamValue('minCorrelationThreshold',[],  @(x) (isscalar(x) && isnumeric(x)) || isempty(x));
p.addParamValue('maxFrames',[],  @(x) (isscalar(x) && isnumeric(x)) || isempty(x));
p.addParamValue('verbose',false,  @(x) (isscalar(x) && islogical(x)));
p.addParamValue('showCorrelationPlot',false,  @(x) (isscalar(x) && islogical(x)));
p.addParamValue('correlationInterp_rc',[4 7],  @(x) (isnumeric(x) && isvector(x) && (length(x)==2)) || isempty(x));
p.addParamValue('algorithm','crosscorrOversample',  @(x) any(strcmpi(x,{'crosscorrOversample'})));
p.addParamValue('crosscorrOversampleSettings',{}, @(x) (iscell(x)));

p.parse(imSource,roiPoints_rc,varargin{:});

searchzsize = p.Results.searchzsize;
searchxsize = p.Results.searchxsize;
templatezsize=p.Results.templatezsize;
templatexsize=p.Results.templatexsize;
templatezseperation_pel=p.Results.templatezseperation_pel;
templatexseperation_pel=p.Results.templatexseperation_pel;
maxFrames=p.Results.maxFrames;
verbose=p.Results.verbose;
showCorrelationPlot=p.Results.showCorrelationPlot;
correlationInterp_rc=p.Results.correlationInterp_rc;

zinterp0=correlationInterp_rc(1);
xinterp0=correlationInterp_rc(2);

minCorrelationThreshold=p.Results.minCorrelationThreshold;
crosscorrOversampleSettings=p.Results.crosscorrOversampleSettings;
%override any settings with the packaged settings
%!@TEMPLATE!@
if ~isempty(crosscorrOversampleSettings)
    keyList=crosscorrOversampleSettings{1};
    values=crosscorrOversampleSettings{2};
    for ii=1:length(keyList)
        
        switch(keyList{ii})
            case 'searchzsize_pel'
                searchzsize=values.(keyList{ii});
            case 'searchxsize_pel'
                searchxsize=values.(keyList{ii});
            case 'templatezsize_pel'
                templatezsize=values.(keyList{ii});
            case 'templatexsize_pel'
                templatexsize=values.(keyList{ii});
            case 'templatexseperation_pel'
                templatexseperation_pel=values.(keyList{ii});                
            case 'templatezseperation_pel'
                templatezseperation_pel=values.(keyList{ii});
            otherwise
                error(['Unsupported correlationCorrespondenceSettings of ' keyList{ii}]);
        end
    end
end
%we want a theoretical possible spread of 12 counts per bin.  Twelve was guessed at because it was hoped
%that the combination would approximate a true pdf.  The idea is
%that we want a somewhat accurate pdf however this is not a gaussian pdf
entropyMinCountsPerBin=12;
entropySizeTargetIm=ceil(((templatexsize+searchxsize)*(templatezsize+searchzsize))/entropyMinCountsPerBin);
entropySizeTemplateIm=ceil((templatexsize*templatezsize)/entropyMinCountsPerBin);

if (isnumeric(imSource) && length(size(imSource))==3)
    sourceType='imageBlock';
    
elseif iscell(imSource) && strcmp(imSource{1},'uread')
    sourceType='uread';
else
    error('Unsupported imSource')
end
im1=getImFrame(imSource,sourceType,1);

%since the roi defines the upper left point we can span the image
%we will always.  This also kills the left and right borders to allow for
%max overlap
if isempty(roiPoints_rc) && isempty(templatexseperation_pel) && isempty(templatezseperation_pel)
    imDim_rc=size(im1)';
    blockSize_rc=[searchzsize; searchxsize ]; %this creates nonoverlapping search windows
    totalBlocks=floor(imDim_rc./blockSize_rc);
    if any(totalBlocks<=1)
        error(['Image of dimension (row/col ' num2str(reshape(imDim_rc,[],1)) ') is not big enough for automated search window placement.']);
    else
        %do nothing
    end
    [ptRow,ptColumn]=ndgrid((2:(totalBlocks(1)-1))*blockSize_rc(1),(2:(totalBlocks(2)-1))*blockSize_rc(2));
    roiPoints_rc=[ptRow(:) ptColumn(:)]';
    
elseif isempty(roiPoints_rc) && ~isempty(templatexseperation_pel) && ~isempty(templatezseperation_pel)
    imDim_rc=size(im1)';
    blockSize_rc=[templatezseperation_pel; templatexseperation_pel ];
    totalBlocks=floor(imDim_rc./blockSize_rc);
    if any(totalBlocks<=3)
        error('Image is not big enough for automated search window placement.');
    else
        %do nothing
    end
  %  searchzsize %The row
   % searchxsize %The column
    %start search window at upper left corner    
    blockRowCenter=(2:(totalBlocks(1)-1))*blockSize_rc(1);
    blockRowCenter((blockRowCenter + searchzsize) >= imDim_rc(1))=[];
    blockColCenter=(2:(totalBlocks(2)-1))*blockSize_rc(2);
    blockColCenter((blockColCenter + searchxsize) >= imDim_rc(2))=[];
    [ptRow,ptColumn]=ndgrid(blockRowCenter,blockColCenter);
    roiPoints_rc=[ptRow(:) ptColumn(:)]';
else
    %do nothing
end

roiz=roiPoints_rc(1,:);
roix=roiPoints_rc(2,:);





z=1; x=2;
p=-1:1;  %peak search


% Interpolation grid size is (2^interp0) + 1

%have a valid area that is only where the template is fully contained in
%the search window
corrzarea=(searchzsize+templatezsize)/2-(searchzsize-templatezsize)/2:(searchzsize+templatezsize)/2+(searchzsize-templatezsize)/2;
corrxarea=(searchxsize+templatexsize)/2-(searchxsize-templatexsize)/2:(searchxsize+templatexsize)/2+(searchxsize-templatexsize)/2;


if isempty(maxFrames)
    maxFrames=getImFrameCount(imSource,sourceType);
else
    %use the value
end

if showCorrelationPlot
    fig.showCorrelationPlot=figure;
end







for frameIdx=2:maxFrames
    if verbose
        fprintf('processing frame %d of %d\n',frameIdx,maxFrames);
    end
    
    im2=getImFrame(imSource,sourceType,frameIdx);
    
    track(frameIdx-1).pt_rc=zeros(size(roiPoints_rc)); %#ok<AGROW>
    track(frameIdx-1).ptDelta_rc=zeros(size(roiPoints_rc)); %#ok<AGROW>
    for  ii=1:length(roiz)
        
        zidx = roiz(ii);
        xidx = roix(ii);
        
        %fprintf('processing depth %d\n',zidx);
        %start search window at upper left corner
        searchz = zidx:(zidx + searchzsize-1);
        searchx = xidx:(xidx + searchxsize-1);
        
        %center the template in the search window
        templatez = zidx + round( searchzsize/2 - templatezsize/2 ) : zidx + round(searchzsize/2 + templatezsize/2) - 1;
        templatex = xidx + round( searchxsize/2 - templatexsize/2 ) : xidx + round(searchxsize/2 + templatexsize/2) - 1;
        
        
        template = (im1(templatez,templatex));
        target_img = (im2(searchz,searchx));
        
        if false
            %%
            figure %#ok<UNRCH>
            subplot(1,2,1)
            imagesc(abs(template)); colormap(gray(256));
            cLim=caxis;
            
            title('template')
            subplot(1,2,2)
            imagesc(abs(target_img)); colormap(gray(256));
            caxis(cLim);
            title('target')
        end
        
        
        if ~all(template(:)==template(1)) && ~all(target_img(:)==target_img(1))
            imcorrnorm=normxcorr2(abs(template),abs(target_img));
        else
            %TODO use the 
            imcorrnorm=zeros(size(template)+ size(target_img) - [1 1]);
        end
        
        [maxRow,maxCol]=find(imcorrnorm==max(max(imcorrnorm(corrzarea,corrxarea))));
        
        if (length(maxRow) ~= 1) || (length(maxCol) ~= 1)
            %warning('motionfield:multipleMax','More than one max detected from normxcorr2.  Using the first index.') ;
        end
        cl(z)=maxRow(1);  cl(x)=maxCol(1); %#ok<AGROW>       
        
        if showCorrelationPlot
            %%
            figure(fig.showCorrelationPlot);
            imagesc(imcorrnorm); colorbar;
            title(['Correlation matrix max at:(' num2str(cl(z)) ',' num2str(cl(x)) ')'])
            
        end
        
        if (isempty(minCorrelationThreshold) || (imcorrnorm(cl(z),cl(x)) > minCorrelationThreshold))
            
            %do a centered peak search
            zoomcoordz=cl(z)+p; 
            zoomcoordx=cl(x)+p;
            
            %adjust for is at max row
            zoomcoordz=zoomcoordz + min(size(imcorrnorm,1),max(zoomcoordz))-max(zoomcoordz);
            zoomcoordx=zoomcoordx + min(size(imcorrnorm,2),max(zoomcoordx))-max(zoomcoordx);

            %adjust if at min row
            zoomcoordz=zoomcoordz + max(1,min(zoomcoordz))-min(zoomcoordz);
            zoomcoordx=zoomcoordx + max(1,min(zoomcoordx))-min(zoomcoordx);
            
            
            zinterp=zinterp0;
            xinterp=xinterp0;
            
            zoomdim=[2^zinterp+1 ; 2^xinterp+1 ];
            
            zoomlimitsz=linspace(zoomcoordz(1),zoomcoordz(end),zoomdim(z));
            zoomlimitsx=linspace(zoomcoordx(1),zoomcoordx(end),zoomdim(x));
            
            [zmx, zmz]=meshgrid(zoomcoordx,zoomcoordz);
            [zlx, zlz]=meshgrid(zoomlimitsx,zoomlimitsz);
            
            
            imcorrzoom=interp2(zmx,zmz,(imcorrnorm(zoomcoordz,zoomcoordx)),zlx,zlz,'cubic');
            
            [peakz, peakx]=find(imcorrzoom==max(max(imcorrzoom)));
            peakx=peakx(1);
            peakz=peakz(1);
            
            dl(z)=zoomlimitsz(peakz)-cl(z); %#ok<AGROW>
            dl(x)=zoomlimitsx(peakx)-cl(x); %#ok<AGROW>
            
            l(z)=zoomlimitsz(peakz); %#ok<AGROW>
            l(x)=zoomlimitsx(peakx); %#ok<AGROW>
            
            l(z)=l(z)-(searchzsize+templatezsize)/2; %#ok<AGROW>
            l(x)=l(x)-(searchxsize+templatexsize)/2; %#ok<AGROW>
            
            
        else
            %fprintf('Value less than threshold: %d\n',peakval);
            l(z)=NaN; l(x)=NaN; dl(z)=NaN; dl(x)=NaN;  %#ok<AGROW>
        end;
        
        % motion vector matrix
        
        track(frameIdx-1).pt_rc(:,ii)=[zidx; xidx];  %#ok<AGROW>
        track(frameIdx-1).frameIdx=frameIdx;  %#ok<AGROW>
        track(frameIdx-1).ptDelta_rc(:,ii)=[l(z); l(x)];  %#ok<AGROW>
        %for the entropy calc we want for a uniform distribution 12 samples
        %per bin
        track(frameIdx-1).target(ii).entropy=entropyN(abs(target_img),entropySizeTargetIm); %#ok<AGROW>
        track(frameIdx-1).template(ii).entropy=entropyN(abs(template),entropySizeTemplateIm); %#ok<AGROW>
        track(frameIdx-1).correlation(ii).entropy=entropyN(abs(imcorrnorm),floor(size(imcorrnorm,1)*size(imcorrnorm,2)/entropyMinCountsPerBin)); %#ok<AGROW>
        if showCorrelationPlot
            figure(fig.showCorrelationPlot);
            imagesc(abs(imcorrnorm));
        end
    end;
    im1=im2;
    
end;
end



%This function returns an image frame from the source depending on its
%type.  the index is base 1.
function im=getImFrame(imSource,sourceType,imIndex)
switch(sourceType)
    case 'imageBlock'
        im = imSource(:,:,imIndex);
    case 'uread'
        %1 is subtracted because the base for uread is 0.
        if length(imSource)==2
            im=uread(imSource{2},imIndex-1,imSource{3}{:});
        elseif length(imSource)==3
            im=uread(imSource{2},imIndex-1,imSource{3}{:});
        else
            error('Invalid imSource length for uread');
        end
    otherwise
        error(['Unsuppported sourceType of ' sourceType]);
end

end

%This function returns an image frame from the source depending on its
%type.
function frameCount=getImFrameCount(imSource,sourceType)
switch(sourceType)
    case 'imageBlock'
        frameCount=size(imSource,3);
    case 'uread'
        [~, header]=uread(imSource{2},-1);
        frameCount=header.nframes;
    otherwise
        error(['Unsuppported sourceType of ' sourceType]);
end

end


