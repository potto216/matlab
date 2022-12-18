function [ meanValue ] = meanGeometricValid( data,validIndexes )
%MEANVALID Mean value of data
indexToKeep=intersect(1:length(data),validIndexes);
meanValue=geomean(data(indexToKeep));


end

