function [template,searchFrame] = showResample( template,templateIdx,searchFrame,searchRoiIdx )
templateSize=length(template);
template=resample(resample(template,1,2),2,1);
template=template(1:templateSize);

searchFrameSize=length(searchFrame);
searchFrame=searchFrame(1:searchFrameSize);

end
