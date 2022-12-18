function [ dataForInterp ] = idxReplaceValues( dataForInterp,indexList )
%IDXREPLACEVALUES This function will replace unwanted values through an average of neighbors or adjacent
%assumes dataForInterp is a vector.  Uses pchip for the interp function so
%may have points that are outside the range at the endpoints.  If the
%number of valid samples (non-NaN) is less than the minimum acceptable
%percentage then zero out the entire waveform.

interIndexList=setdiff(1:length(dataForInterp),indexList);

%This will check if all the measurements are bad.  If so 0 will replace
%everything
minimumAcceptableValidValues=0.3;
if length(interIndexList)/length(dataForInterp)<minimumAcceptableValidValues
    dataForInterp=zeros(size(dataForInterp));
else
    dataForInterp(indexList)=interp1(interIndexList,dataForInterp(interIndexList),indexList,'pchip');
end

%check if any are still NaN, if so just use the mean signal value
if any(isnan(dataForInterp))
    error('Some NaN''s got through');
else
    %do nothing
end
    
    
return
indexBounds=[1 length(dataForInterp)];
indexOffset=1;
if indexOffset~=1
    error('Only an index offset of 1 is supported.');
end
    
startIndexList=indexList-indexOffset;
startIndexList=max(startIndexList,indexBounds(1));
endIndexList=indexList+indexOffset;
endIndexList=min(endIndexList,indexBounds(2));
%If both the start and end list are the same as the index in question then
%fail
sameAsStart=(startIndexList==indexList);
sameAsEnd=(endIndexList==indexList);
if sameAsStart & sameAsEnd
    error(['The start and end index are both equal to the index list value. This will cause a failure.']);
end

indexToAverage=~sameAsStart & ~sameAsEnd;

%If the index to fix is the same as the start index then just set it equal
%to the end index
dataForInterp(indexList(sameAsStart))=dataForInterp(endIndexList(sameAsStart));

%If the index to fix is the smae as the end index then just set it to the
%start index.
dataForInterp(indexList(sameAsEnd))=dataForInterp(startIndexList(sameAsEnd));

%else average the two
dataForInterp(indexList(indexToAverage))=(dataForInterp(startIndexList(indexToAverage))+dataForInterp(endIndexList(indexToAverage)))/2;


end

