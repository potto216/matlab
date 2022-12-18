%This returns the type of Mat file so one can determine if they can use
%matfile etc.
%
%INPUT
%filename - the full path and filename of the mat file
%
%OUTPUT
%matFileType - A string with the version of the file which can be:
% '7.3'
% '7.0'
% '6.0'
% '4.0'
%The version numbers match the version given in http://www.mathworks.com/help/matlab/import_export/mat-file-versions.html
function [matFileType]=matfileType(filename)
fid=fopen(filename,'rb');
fileInfo=fread(fid,256,'uchar=>char');
fclose(fid);

matlabFileType=strtok(fileInfo','Platform');
switch(strtrim(matlabFileType))
    case 'MATLAB 5.0 MAT-'
        matFileType='6.0';
    case 'MATLAB 7.3 MAT-'
        matFileType='7.3';
    otherwise
        warning(['The Matlab file version type is not supported ' strtrim(matlabFileType)]);
end
end