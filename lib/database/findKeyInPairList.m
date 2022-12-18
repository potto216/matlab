function [ keyIdx ] = findKeyInPairList( pairList,keyInPairList )
%FINDKEYINPAIRLIST Summary of this function goes here
%   Detailed explanation goes here

keyIdx=find(cellfun(@(x) ischar(x) && strcmp(x,keyInPairList), pairList));

end

