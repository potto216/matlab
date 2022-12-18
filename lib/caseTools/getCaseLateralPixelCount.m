%lateralPixelCount=getCaseLateralPixelCount(metadata) Returns the lateral
%pixel count for an image.
%
%DESCRIPTION
%Returns the lateral pixel count for an image.  This may not be the width since
%decimation maybe used
%
%INPUT
%metadata - The casename is the filename without the extension or the raw metadata.
%
%OUTPUT
%lateralPixelCount - the lateral pixel count being used.
%
function lateralPixelCount=getCaseLateralPixelCount(metadata)
metadata=loadCaseData(metadata);

lateralPixelCount=metadata.rf.header.w/metadata.decimateFactor; %default to the header's width
end