%This function computes a distance metric of a vector or a series of
%vectors.  It is assumed all distance conversions have been applied and the
%values are in the correct units.  Also unless overriden the following keys
%are assumed to have the following properties:
%
%axial - This is assumed to be the first dimension following the row/column
%format.
%
%lateral - This is assumed to be the second dimension following the row/column
%format.
%
%INPUTS
%track = an array of column vectors where each column is assumed to be in a
%row column format.  If there is a third dimension then the values are
%processed in parallel and the return distanceMetric has a third dimension.
%
%distanceMeasure - this specifies the distance metric to use.  It can be a
%struct or a cell array of key value pairs.
%
%OUTPUT
%distanceMetric - returns the distance metric of one dimension (columns).  Here each column cooresponds to one column vector of the track
function distanceMetric=calculateDistance(track, distanceMeasure)

switch(nargin)
    case 2
        %do nothing
    otherwise
        error('Error invalid number ');
end



switch(distanceMeasure.key)
    case 'axial'
        %distanceMetric = sqrt(sum(track(1,:).^2,1));
        if isfield(distanceMeasure,'scaleMatrix')
            error('Please handle');
        end
        distanceMetric = track(1,:);
    case 'lateral'
        %distanceMetric = sqrt(sum(track(2,:).^2,1));
        if isfield(distanceMeasure,'scaleMatrix')
            error('Please handle');
        end
        distanceMetric = track(2,:);
    case 'signedDistance'
        
        %we assume an if stateemnt is faster than a matrix multiple
        if isfield(distanceMeasure,'scaleMatrix')
            
            distanceMetric=zeros([1 size(track,2)  size(track,3)]);
            for dd=1:size(track,3)
                distanceMetric(1,:,dd) = (((track(distanceMeasure.func.args.trackSignedIndex,:,dd)>0)-0.5)*2).*sqrt(sum((distanceMeasure.scaleMatrix*track(:,:,dd)).^2,1));
            end
                        
        else
            distanceMetric = (((track(distanceMeasure.func.args.trackSignedIndex,:)>0)-0.5)*2).*sqrt(sum(track.^2,1));
            
        end
        
    otherwise
        error(['Unsupported distance metric of ' distanceMeasure.key])
end


