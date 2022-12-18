%This function opens a set of test frames.
%
%maxMovement_rc is the total +- movement in the x/y direction.  It is how far the total set will move.
%
%The units rc means it is in the form of row,column 
function [obj, frame_rc]=frameSetGet(obj, frameIndexBase0)
global g_frameSetMap_rc
global g_frameSetPath

frameIndex=frameIndexBase0+1;  %have the frames start at 1

frameStartPosition_rc = g_frameSetPath(:,frameIndex);
frameEndPosition_rc = frameStartPosition_rc+(obj.frameSize_rc-1);
frame_rc=g_frameSetMap_rc(frameStartPosition_rc(1):frameEndPosition_rc(1),frameStartPosition_rc(2):frameEndPosition_rc(2));
return

frameIndex=frameIndexBase0+1;  %have the frames start at 1

%To find where the frame falls we will check where in the bounds it is
lowerFrameBound=cumsum([0 obj.maxFrames(1:end-1)])
upperFrameBound=cumsum(obj.maxFrames)
idx=find(and((lowerFrameBound<frameIndex),(frameIndex<=upperFrameBound)));

translationPerFrame_rc=obj.translationPerFrame_rc(:,idx);

if isempty(g_frameSetMap_rc)
	error('The frameSet must first be opened.');
end

if frameIndexBase0<0
	error('frameIndexBase0 cannot be negative')
end

if frameIndexBase0>(max(cumsum(obj.maxFrames))-1)
	error('Exceeded maxframe size')
end

frameStartPosition_rc = frameIndex*obj.translationPerFrame_rc + obj.startPosition_rc;
frameEndPosition_rc = frameStartPosition_rc+(obj.frameSize_rc-1);

frame_rc=g_frameSetMap_rc(frameStartPosition_rc(1):frameEndPosition_rc(1),frameStartPosition_rc(2):frameEndPosition_rc(2));

if any(size(frame_rc)~=obj.frameSize_rc)
	error(['Returned frame was expected to be ' num2str(obj.frameSize_rc) ' but was instead ' num2str(size(frame_rc))])
end

return;