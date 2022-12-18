%The purpose of this function is to segment the muscle of the upper
%trapezius from the rest of the ultrasound image.  
%threshold of 5 is a good default.
function [muscleMask,resultsList,maxIndex]=muscleFasciaSegmentationOptimize(Img,thresholdList,polyfitOrder)
switch(nargin)
    case 2
        polyfitOrder=1;
    case 3
        %do nothing
    otherwise
        error('Invalid number of input arguments.');
end

resultsList=struct([]);
for thresholdIndex=1:length(thresholdList)
    resultsList(thresholdIndex).threshold=thresholdList(thresholdIndex);
    resultsList(thresholdIndex).muscleMask=muscleFasciaSegmentation(Img,resultsList(thresholdIndex).threshold,polyfitOrder);
    resultsList(thresholdIndex).muscleHeight=sum(resultsList(thresholdIndex).muscleMask);    
    
    %-1 means no muscle and should be ignored
    resultsList(thresholdIndex).muscleStart=colvecfun(@(x) lif(~any(x),-1,find(x,1,'first')),resultsList(thresholdIndex).muscleMask);
    resultsList(thresholdIndex).muscleNotValid=any(resultsList(thresholdIndex).muscleStart>130);
end

%[~,maxIndex]=max(arrayfun(@(x) (~x.muscleNotValid)*median(x.muscleHeight),resultsList,'UniformOutput',true));

muscleBounds=cell2mat(arrayfun(@(x) lif(~any(x.muscleMask),[-1; -1], [find(any(x.muscleMask,2),1,'first'); find(any(x.muscleMask,2),1,'last')]),resultsList,'UniformOutput',false));
[~,maxIndex]=max(diff(muscleBounds));



muscleMask=resultsList(maxIndex).muscleMask;
end