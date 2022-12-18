% Generates a matrix of uniformly distributed random integers of a given
% size over a given range
%
%Inputs
%range - the min/max of the range of integers to produce
%
%size - the size of the matrix given as a vector
function x=randint(range,size)

if ~isvector(range) || (range(2)<=range(1)) || ~isNoFraction(range) || (length(range)~=2)
    error('The range must be a two element vector in the form [min max] where min and max are integers.')
end

if ~isvector(size) || ~isNoFraction(size) 
    error('The size must be integers specifiy the matrix size for the returned elements.')
end

x=round(diff(range)*rand(size)+range(1));

if any(x<range(1)) || any(x>range(2))
    error('values outside the range were computed')
end
 