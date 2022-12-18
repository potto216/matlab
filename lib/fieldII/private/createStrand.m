
function strand_m=createStrand(maxLength_mm,fasciclePositionAndLength_mm,cylinderRadius_mm,showPlot)

segmentSize_mm=20; % can delete;
%Npts=300;
scale=30;
%The fasicle should be a uniform distribution in angle radius of Gaussian and uniform in z
cylinderInPolar_m=@(radius_m,height_m,N,tx,ty) [diag([2*pi radius_m height_m]) [0 tx ty]'; [0 0 0 1]]* [rand(1,N); abs(randn(1,N)); rand(1,N); ones(1,N)];
polarToRect=@(X) [real(X(2,:).*exp(1i*X(1,:))); imag(X(2,:).*exp(1i*X(1,:))); X(3,:)];

cylinder_m=@(height_m,Npts) polarToRect(cylinderInPolar_m( (cylinderRadius_mm/1000)*0.3561/scale,height_m,Npts,0,0));
%figure; plot3(cylinder_m(1,:),cylinder_m(2,:),cylinder_m(3,:),'.')

%% We need to build the muscle strands  This will be of a fixed length, but vary in number of fasicles and their length
%To make it easy we will sub divide the strand into units where a fascile
%can be and the position and length of the fascile will vary
centerCount=5;
circleShell=circles(centerCount,showPlot);
centerPts=cell2mat(arrayfun(@(x) [x.xCenter; x.yCenter],circleShell,'UniformOutput',false));

centerPts_mm=centerPts-repmat([centerCount;centerCount],1,size(centerPts,2));
%figure; plot(centerPts_mm(1,:),centerPts_mm(2,:),'r.');

totalSegments=maxLength_mm/segmentSize_mm;
if floor(totalSegments)~=totalSegments
    error('totalSegments should be an integer');
end

fascicleCollection={};
%This creates the layer of fascicles
for ii=1:size(centerPts_mm,2)
    %segmentsToFill=randperm(totalSegments,4);
    %startOffsetInSegment=rand(size(segmentsToFill));
    %create the start positions
    %fasciclePositionAndLength_mm
    
    startZ_mm=fasciclePositionAndLength_mm(1,:); %(segmentsToFill-1)/totalSegments*maxLength_mm+startOffsetInSegment*segmentSize_mm;
    fascicleLength_mm=fasciclePositionAndLength_mm(2,:); %(1-startOffsetInSegment).*(segmentSize_mm*(rand(size(startOffsetInSegment))));
    
    x_m=centerPts_mm(1,ii)/1000/scale;
    y_m=centerPts_mm(2,ii)/1000/scale;
    %this creates a single strand
    fascicleCollection=[ fascicleCollection arrayfun(@(h_m,z_m,Npts) cylinder_m(h_m,Npts) + repmat([x_m;y_m;z_m],1,Npts),fascicleLength_mm/1000,startZ_mm/1000,fasciclePositionAndLength_mm(3,:),'UniformOutput',false)];
end

strand_m=cell2mat(fascicleCollection);
if showPlot
    %%
    figure; plot3(strand_m(1,:),strand_m(2,:),strand_m(3,:),'.');
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');
    
    figure; plot(strand_m(1,:),strand_m(3,:),'.');
    xlabel('x (m)');
    ylabel('z (m)');
    
    figure; plot(strand_m(1,:),strand_m(2,:),'.');
    xlabel('x (m)');
    ylabel('y (m)');
end
end

function strand_m=createStrandOld(maxLength_mm,segmentSize_mm,cylinderRadius_mm,showPlot)

Npts=300;
scale=30;
%The fasicle should be a uniform distribution in angle radius of Gaussian and uniform in z
cylinderInPolar_m=@(radius_m,height_m,N,tx,ty) [diag([2*pi radius_m height_m]) [0 tx ty]'; [0 0 0 1]]* [rand(1,N); abs(randn(1,N)); rand(1,N); ones(1,N)];
polarToRect=@(X) [real(X(2,:).*exp(1i*X(1,:))); imag(X(2,:).*exp(1i*X(1,:))); X(3,:)];

cylinder_m=@(height_m) polarToRect(cylinderInPolar_m( (cylinderRadius_mm/1000)*0.3561/scale,height_m,Npts,0,0));
%figure; plot3(cylinder_m(1,:),cylinder_m(2,:),cylinder_m(3,:),'.')

%% We need to build the muscle strands  This will be of a fixed length, but vary in number of fasicles and their length
%To make it easy we will sub divide the strand into units where a fascile
%can be and the position and length of the fascile will vary
centerCount=5;
circleShell=circles(centerCount,showPlot);
centerPts=cell2mat(arrayfun(@(x) [x.xCenter; x.yCenter],circleShell,'UniformOutput',false));

centerPts_mm=centerPts-repmat([centerCount;centerCount],1,size(centerPts,2));
%figure; plot(centerPts_mm(1,:),centerPts_mm(2,:),'r.');

totalSegments=maxLength_mm/segmentSize_mm;
if floor(totalSegments)~=totalSegments
    error('totalSegments should be an integer');
end

fascicleCollection={};
%This creates the layer of fascicles
for ii=1:size(centerPts_mm,2)
    segmentsToFill=randperm(totalSegments,4);
    startOffsetInSegment=rand(size(segmentsToFill));
    %create the start positions
    startZ_mm=(segmentsToFill-1)/totalSegments*maxLength_mm+startOffsetInSegment*segmentSize_mm;
    
    fascicleLength_mm=(1-startOffsetInSegment).*(segmentSize_mm*(rand(size(startOffsetInSegment))));
    x_m=centerPts_mm(1,ii)/1000/scale;
    y_m=centerPts_mm(2,ii)/1000/scale;
    %this creates a single strand
    fascicleCollection=[ fascicleCollection arrayfun(@(h_m,z_m) cylinder_m(h_m) + repmat([x_m;y_m;z_m],1,Npts),fascicleLength_mm/1000,startZ_mm/1000,'UniformOutput',false)];
end
strand_m=cell2mat(fascicleCollection);
if showPlot
    %%
    figure; plot3(strand_m(1,:),strand_m(2,:),strand_m(3,:),'.');
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');
    
    figure; plot(strand_m(1,:),strand_m(3,:),'.');
end
end