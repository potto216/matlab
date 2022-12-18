function [ meanValue ] = meanValid( data,validIndexes )
%MEANVALID Mean value of data
indexToKeep=intersect(1:length(data),validIndexes);
meanValue=mean(data(indexToKeep));


end

