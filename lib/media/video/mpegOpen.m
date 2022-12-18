%DESCRIPTION
%	This function will write a video file to disk from a sequence of frame data.
%Currently the only video format supported is mpeg1.  Frames are added using
%the mpegAddframe function and the movie is created when the close command is issued.
%ffmpeg must be installed on the system (see the technical note below).  Right now the 
%frame image file names are hardcoded.
%
%INPUTS
% 	mpegFilename is the full path and file name of the video file.
%
%	fps - the video frame rate its range is between [1 24].  It has to be
%divisible by 24 so the possible frame rates are: [1 2 3 4 6 8 12 24] fps.
%
%	mpegWorkingPath - is the path where the temporary frame data is written.
%If no directory is specifed then the path and base filename of the video file
%will be used with "workingDir" appended as a postfix.  If the directory exists
%all files will be deleted without prompting
%
%OUTPUTS
%	obj - the object that holds all of the state information.
%TECHNICAL NOTES
% Limitations.  This class uses ffmpeg to create the video.  ffmpeg can be 
% ffmpeg install: 
% ffmpeg for Windows can be downloaded http://tripp.arrozcru.org/
% Install it in a directory 
% "%FFMPEG_PATH%\ffmpeg"
function [obj]=mpegOpen(mpegFilename,fps,mpegWorkingPath)
validFps=[1 2 3 4 6 8 12 24];

%Validate the input data
if ~ischar(mpegFilename)
	error('mpegFilename must be a string.');
end

if ~isscalar(fps) || ~any(fps==validFps)
 error(['fps must be equal to one of the following frame rates ' num2str(validFps)])
end

if nargin==3
	if isempty(mpegWorkingPath) 
		mpegWorkingPath=''; %make sure the empty type shows up as char
	elseif ischar(mpegWorkingPath)
		%do nothing
	else
		error('mpegWorkingPath must be a string.');
	end
else
	mpegWorkingPath='';
end

%valid the enviroment is setup correctly and setup all of the default information
if isempty(getenv('FFMPEG_PATH'))
	error('FFMPEG_PATH is not set.  Please see the technical note in the help.')
end

%setup the mpegWorkingPath to a valid value
if isempty(mpegWorkingPath)
	[filePath,fileBasename]=fileparts(mpegFilename);
	mpegWorkingPath=fullfile(filePath,[fileBasename 'workingDir']);
else
	%do nothing
end

%remove the working dir is it already exists.
if exist(mpegWorkingPath,'dir')	
	old_value=confirm_recursive_rmdir();
	confirm_recursive_rmdir(1);
	successFlag=rmdir(mpegWorkingPath,'s');
	if ~successFlag
		error(['Unable to remove ' mpegWorkingPath]);
	end
	confirm_recursive_rmdir(old_value);
end

%now create the working directory
system(['mkdir "' mpegWorkingPath '"']); %cannot use successFlag=mkdir(mpegWorkingPath); because we need it to be recursive


%Now everything should be setup.   The working directory is valid and all of the input data has been verified.

obj.fps=fps;
obj.filenameFormat='im%d.png';	%could add %05d for zero padding
obj.imageFileIndex=1;
obj.mpegWorkingPath=mpegWorkingPath;
obj.mpegFilename=mpegFilename;

return;