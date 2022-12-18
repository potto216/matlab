%DESCRIPTION
%	This function will add a frame to the movie.  If no arguments are given the
%frame is assumed to be the current figure which is then printed as a graphics file to 
%the working directory.
%
%INPUTS
% 	obj - The object that holds the state information for the movie
%
%OUTPUTS
% 	obj - The object that holds the state information for the movie
%
function [obj]=mpegAddFrame(obj)

totalFrameCopies=24/obj.fps;

if totalFrameCopies<1 || ~isNoFraction(totalFrameCopies)
	error(['totalFrameCopies value of ' num2str(totalFrameCopies) ' cannot be less than 1 or have a fraction part.']);
end

oldDir=pwd;
cd(obj.mpegWorkingPath)

print( sprintf(obj.filenameFormat,obj.imageFileIndex),'-dpng');
obj.imageFileIndex=obj.imageFileIndex+1;

%duplicate extra frames to simulate a slower frame rate
for ii=2:totalFrameCopies
	copyfile(sprintf(obj.filenameFormat,obj.imageFileIndex-1),sprintf(obj.filenameFormat,obj.imageFileIndex));
	obj.imageFileIndex=obj.imageFileIndex+1;
end

cd(oldDir)

return;
