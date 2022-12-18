%DESCRIPTION
%	This function closes the video output which actually creates the video.
%
%INPUTS
% 	obj - the object containing the state variables
%
%OUTPUTS
%	obj - the object that holds all of the state information.
function [obj]=mpegClose(obj)
%oldDir=pwd;
%cd(obj.mpegWorkingPath)
system(['"%FFMPEG_PATH%\ffmpeg" -r 24 -y -f mpeg1video -b 100000 -i "' obj.mpegWorkingPath '\im%d.png" "' obj.mpegFilename '"']);
system(['"C:\Program Files\VideoLAN\VLC\vlc.exe" "' obj.mpegFilename '"']);
%cd(oldDir)

% obj.fps=fps;
% obj.filenameFormat='im%05d.png';
% obj.imageFileIndex=1;
% obj.mpegWorkingPath=mpegWorkingPath;
% obj.mpegFilename=mpegFilename;



return;