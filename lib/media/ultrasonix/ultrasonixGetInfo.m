%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loads the ultrasound header info RF data saved from the Sonix software
%
% Inputs:  
%     filename - The path of the data to open. The actual reading from the 
%    file is based on code by Corina Leung, corina.leung@ultrasonix.com. 
%
% Return:
%header -     The file header information.  The values for the header are:
% header.filetype - data type (can be determined by file extensions)
% header.nframes - number of frames in file
% header.w - width (number of vectors for raw, image width for processed data)
% header.h - height (number of samples for raw, image height for processed data)
% header.ss - data sample size in bits
% header.ul - region of interest (roi) {upper left x, upper left y}
% header.ur - roi {upper right x, upper right y}
% header.br - roi {bottom right x, bottom right y}
% header.bl - roi {bottom left x, bottom left y}
% header.probe - probe identifier - additional probe information can be found using this id  
% header.txf - transmit frequency in Hz
% header.sf - sampling frequency in Hz
% header.dr - data rate (fps or prp in Doppler modes)
% header.ld - line density (can be used to calculate element spacing if pitch and native # elements is known)
% header.extra - extra information (ensemble for color RF)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [header] = ultrasonixGetInfo(filename)


fid=fopen(filename, 'r');
if( fid == -1)
    error(['Cannot open the file ' filename]);
end

switch(nargin)
	case 1
		%do nothing
	otherwise
	error('Invalid number of input arguments.');
end
		

header=ultrasonixReadHeader(fid);


fclose(fid);
   
return

