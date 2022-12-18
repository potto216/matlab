function M = estProjectiveIter(im1,im2,numIters,M,option)
%
% function M = estAffineIter2(im1,im2,numIters,M,option)
%
% Each iteration warps the images according to the previous
% estimate, and estimates the residual motion.

% Incrementally estimate the correct transform
for iter=1:numIters
   imWarp2=warpProjective2(im2,M);
   deltaM=estProjective(im1,imWarp2,option);
   M=deltaM*M;
   M = M/M(9);
end

return;