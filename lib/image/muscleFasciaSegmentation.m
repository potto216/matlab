%The purpose of this function is to segment the muscle of the upper
%trapezius from the rest of the ultrasound image.  
%threshold of 5 is a good default.
function muscle=muscleFasciaSegmentation(Img,threshold,polyfitOrder)
switch(nargin)
    case 2
        polyfitOrder=1;
    case 3
        %do nothing
    otherwise
        error('Invalid number of input arguments.');
end

[dimx,dimy]=size(Img);
seE=getnhood(strel('disk',5)); % neighborhood of entropy filtering
% Horizotal Mask for morphological Dilation
seDilate=zeros(15);
seDilate(8,:)=1;

% declare matrix
ImgEn = entropyfilt(uint8(Img),seE); % Entropy Filterin
threshImg=imdilate(imfill(ImgEn>threshold,'holes'),seDilate); % filling of holes in Thresholded image 
stats1=regionprops(threshImg,'area');
[~,IXarea]=sort(cell2mat(struct2cell(stats1)),'descend');
thresholdArea=cell2mat(struct2cell(stats1(IXarea(3),1)))+2;
filledImg=bwareaopen(threshImg,thresholdArea); % remove area less than threshArea

upX=zeros(1,dimy);
upY=1:dimy;
downX=zeros(1,dimy);
downY=1:dimy;
% get middle point in the muscle
% get middle point in the muscle
stats=regionprops(filledImg,'BoundingBox','area');

if length(stats)==2
    endUpperFascia=stats(1,1).BoundingBox(1,2)+stats(1,1).BoundingBox(1,4);
     midMuscle=endUpperFascia+ (stats(2,1).BoundingBox(1,2)-endUpperFascia)/2;
elseif length(stats)==3
    distY=zeros(size(stats));
    for k=1:length(stats)
        distY(k,1)=stats(k,1).BoundingBox(1,2);
    end 
    [~,IX]=sort(distY,'descend');
    yCor=round(stats(IX(3),1).BoundingBox(1,1));
    xCor=round(stats(IX(3),1).BoundingBox(1,2));
    yWidth=round(stats(IX(3),1).BoundingBox(1,3));
    xWidth=round(stats(IX(3),1).BoundingBox(1,4));
    filledImg(xCor:xCor+xWidth,yCor:yCor+yWidth)=0;
    stats=regionprops(filledImg,'BoundingBox','area');
    endUpperFascia=stats(1,1).BoundingBox(1,2)+stats(1,1).BoundingBox(1,4);
    midMuscle=endUpperFascia+ (stats(2,1).BoundingBox(1,2)-endUpperFascia)/2;
elseif length(stats)==1  %It failed to segment the muscle
    muscle=zeros(size(Img));
    return;
elseif length(stats)>3
    distY=zeros(size(stats));
    for k=1:length(stats)
        distY(k,1)=stats(k,1).BoundingBox(1,2);
    end
    [~,IX]=sort(distY,'descend');
    endUpperFascia=stats(IX(2),1).BoundingBox(1,2)+stats(IX(2),1).BoundingBox(1,4);
    midMuscle=endUpperFascia+ (stats(IX(3),1).BoundingBox(1,2)-endUpperFascia)/2;
else
    error('This should never happen');
end
% Extract border points
for i=1:dimy
    up=find(filledImg(1:round(midMuscle),i)==1,1,'last');
    if ~isempty(up)
        upX(1,i)=up;
    end
    down=find(filledImg(round(midMuscle)+1:end,i)==1,1,'first');  
    if ~isempty(down)     
        downX(1,i)=round(midMuscle)+down;
    end

end
upY=upY(upX>0);upX=upX(upX>0);% remove zeros in the vector
downY=downY(downX>0);downX=downX(downX>0);% remove zeros in the vector
pUp = polyfit(upY,upX,polyfitOrder); % Quadratic Fit
yUp = ceil(abs(polyval(pUp,21:dimy-21))); % find Y for all X values(1:dimy)
pDown = polyfit(downY,downX,polyfitOrder);% Quadratic Fit
yDown = ceil(abs(polyval(pDown,21:dimy-21)));% find Y for all X values(1:dimy)
% find pixel inside the fasical to get the muscle
[X,Y]=meshgrid(1:dimy,1:dimx);
corPolyX(1:2:2*length(21:dimy-21))=yUp;
corPolyX(2:2:2*length(21:dimy-21))= yDown;
corPolyY(1:2:2*length(21:dimy-21))=21:dimy-21;
corPolyY(2:2:2*length(21:dimy-21))=21:dimy-21;
muscleInter=inpolygon(X,Y,corPolyY,corPolyX);
% reduced by 10 pixels from top and bottom
% se=zeros(19);
% se(:,10)=1;
se=zeros(15);
se(:,8)=1;

muscle=imerode(muscleInter,se);
end