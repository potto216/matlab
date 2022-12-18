function [ featureBlockCollection, featureBlockCollectionLabels] = createMultitrackFeatureBlock( multitrackCollection )
%CREATEMULTITRACKFEATUREBLOCK This function creates a multitrack feature
%set of column vectors with the following properties:
%The vector output is
%pt_rc
%ptDelta_rc
%frame number
%sourceFeatureDetect
%sourceCorrespondence
%
totalRowsInFeatureVector=7;
featureBlockCollectionLabels.row.pt_r=1;
featureBlockCollectionLabels.row.pt_c=2;
featureBlockCollectionLabels.row.ptDelta_r=3;
featureBlockCollectionLabels.row.ptDelta_c=4;
featureBlockCollectionLabels.row.frameNumber=5;
featureBlockCollectionLabels.row.sourceFeatureDetect=6;
featureBlockCollectionLabels.row.sourceCorrespondence=7;

if length(multitrackCollection)~=1
    error('Assuming only one multitrack functionis being run');
else
    multitrackCollection=multitrackCollection{1};
end


totalFeaturesInBlock=0;

%Crawl over data structure to get the count
for dd=1:length(multitrackCollection.multitrack)
    totalCorrespondenceRuns=length(multitrackCollection.multitrack(dd).trackList);
    for cc=1:totalCorrespondenceRuns
        
        totalFrames=length(multitrackCollection.multitrack(dd).trackList{cc}.track);
        for ff=1:totalFrames
            
            totalFeaturesInFrame=size(multitrackCollection.multitrack(dd).trackList{cc}.track(ff).pt_rc,2);
            
            totalFeaturesInBlock=totalFeaturesInBlock+totalFeaturesInFrame;
        end
    end
end

%first compute the size.  Then create the array.  Then copy the array

featureBlockCollection=zeros(totalRowsInFeatureVector,totalFeaturesInBlock);
freeColumnPtr=1;

for dd=1:length(multitrackCollection.multitrack)
    totalCorrespondenceRuns=length(multitrackCollection.multitrack(dd).trackList);
    for cc=1:totalCorrespondenceRuns
        
        totalFrames=length(multitrackCollection.multitrack(dd).trackList{cc}.track);
        for ff=1:totalFrames
            
            totalFeaturesInFrame=size(multitrackCollection.multitrack(dd).trackList{cc}.track(ff).pt_rc,2);
            
            
            featureBlockCollection([featureBlockCollectionLabels.row.pt_r; featureBlockCollectionLabels.row.pt_c], ...
                freeColumnPtr:(freeColumnPtr+totalFeaturesInFrame-1)) = ...
                multitrackCollection.multitrack(dd).trackList{cc}.track(ff).pt_rc;
            
            featureBlockCollection([featureBlockCollectionLabels.row.ptDelta_r; featureBlockCollectionLabels.row.ptDelta_c], ...
                freeColumnPtr:(freeColumnPtr+totalFeaturesInFrame-1)) = ...
                multitrackCollection.multitrack(dd).trackList{cc}.track(ff).ptDelta_rc;
            
            featureBlockCollection([featureBlockCollectionLabels.row.frameNumber], ...
                freeColumnPtr:(freeColumnPtr+totalFeaturesInFrame-1)) = ff;
            
            featureBlockCollection([featureBlockCollectionLabels.row.sourceFeatureDetect], ...
                freeColumnPtr:(freeColumnPtr+totalFeaturesInFrame-1)) = dd;
            
            featureBlockCollection([featureBlockCollectionLabels.row.sourceCorrespondence], ...
                freeColumnPtr:(freeColumnPtr+totalFeaturesInFrame-1)) = cc;
            
            freeColumnPtr=freeColumnPtr+totalFeaturesInFrame;
        end
    end
end

end

