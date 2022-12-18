%This function computes a signed distance metric of a vector or a series of
%vectors
%INPUTS
%track = an array of column vectors where each column
%trackSignedIndex - the dimension to use for the signed distance.  In is in
%the range of the dimension of the column vectors
%distanceMeasure - is an optional measure which will perform the 
function distanceMetric=signedDistance(track, trackSignedIndex, distanceMeasure)
distanceMetric = (((track(trackSignedIndex,:)>0)-0.5)*2).*sqrt(sum(track.^2,1));