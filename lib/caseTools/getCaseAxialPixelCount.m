%axialPixelCount=getCaseAxialPixelCount(metadata) Returns the axial
%pixel count for an image.
%
%DESCRIPTION
%Returns the axial pixel count for an image.  This should always be the height.
%
%INPUT
%metadata - The casename is the filename without the extension or the raw metadata.
%
%OUTPUT
%lateralPixelCount - the lateral pixel count being used.
%
function axialPixelCount=getCaseAxialPixelCount(metadata)
metadata=loadCaseData(metadata);

axialPixelCount=metadata.rf.header.h;
end