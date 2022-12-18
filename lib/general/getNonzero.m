function [ xOut ] = getNonzero( x )
%GETNONZERO Returns the nonzero elements of a vector
xOut=x(x~=0);
end

