%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [img,header] = ultrasonixGetFrame(filename,frameNumber,varargin) - loads
% data from a Sonix RF ultrasound file using a 0 based frame index number.
%
%DESCRIPTION
% Function loads an image or images from ultrasound RF data saved in
% the Sonix software and returns them after the requested post processing.
% This can also load an ECG file (type 65536) but you may need to invert
% the signal.
%
%
%INPUTS
%filename - The fullpath and filename of the data file to open.  It must
%   be a sonix rf file.
%
%frameNumber -  This is the frame number being read.  The valid range is [0,(header.nframes-1)].
%               This value can also be a vector and return a set of
%               frames with the index corresponding to the frame number
%               being the third dimension of img, the returned image
%               frames.
%formIQWithHilbert 	-  A logical which indicates if IQ data should be formed
%from the raw RF using the hilbert transform.  The IQ data is the analytic
%signal.  The default is false.
%
%skipEvenRows - A logical which indicates if the software should skip the
%even rows (laterical columns) to reduce interpolation effects.  The default
%is false.
%
%OUTPUT
%img -         The image data returned into a 3D array (h, w, numframes)
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
%AUTHOR
%Paul Otto (potto@gmu.edu).  The frame read is based on code by Corina Leung,
% corina.leung@ultrasonix.com.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [img,header] = ultrasonixGetFrame(filename,frameNumber,varargin)

p = inputParser;   % Create an instance of the class.
p.addRequired('filename', @ischar);
p.addRequired('frameNumber', @(x) isnumeric(x) && isvector(x));
p.addParamValue('formIQWithHilbert',false,@islogical);
p.addParamValue('skipEvenRows',false,@islogical);
p.addParamValue('magOnly',false,@islogical);

p.parse(filename,frameNumber,varargin{:});

formIQWithHilbert=p.Results.formIQWithHilbert;
skipEvenRows=p.Results.skipEvenRows;
magOnly=p.Results.magOnly;


fid=fopen(filename, 'r');
if( fid == -1)
    error(['Cannot open the file ' filename]);
end


header=ultrasonixReadHeader(fid);

if any(frameNumber<0) || any(frameNumber>=header.nframes)
    error(['Invalid frame number.  Must be in the integer set [0,' num2str(header.nframes-1) ']']);
end


frameCount=length(frameNumber);
if formIQWithHilbert
    img =complex(zeros(header.h,header.w,frameCount),zeros(header.h,header.w,frameCount));
else
    img =zeros(header.h,header.w,frameCount);
end


for ii=1:length(frameNumber)
    
    if formIQWithHilbert
        img(:,:,ii)=hilbert(double(readFrame(fid,header,frameNumber(ii))));
    else
        img(:,:,ii)=double(readFrame(fid,header,frameNumber(ii)));
    end
    
    if magOnly
        
        img(:,:,ii)=abs(img(:,:,ii));
    end
    
end

fclose(fid);



if skipEvenRows
    img=img(:,1:2:end,:);
else
end



end

%reads a frame from the file, but needs to account for the header which is
%19 words that are 4 bytes long so 76 bytes.
%This assumes the frame number starts at 0
function img= readFrame(fid,header,frameNumber)

fPass=fseek(fid,header.file.headerSizeBytes+header.file.frameSizeBytes*frameNumber,SEEK_SET());

if fPass~=0
    error('fseek failed')
end


switch(header.file.version)
    case '1.0';
        img=readFrameVersion1_0(fid,header);
        
    case '2.0'
        img=readFrameVersion2_0(fid,header);
    otherwise
        error(['Unsupported file version of ' header.file.version])
end


end

%Notes on Version 1.  Has a tag with each frame
function img=readFrameVersion1_0(fid,header)
% load the data and save into individual .mat files

if(header.filetype == 2) %.bpr
    %Each frame has 4 byte header for frame number
    tag = fread(fid,1,'int32'); %#ok<NASGU>
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    img = uint8(reshape(v,header.h,header.w));
    
elseif(header.filetype == 4) %postscan B .b8
    tag = fread(fid,1,'int32'); %#ok<NASGU>
    [v,count] = fread(fid,header.w*header.h,'int8'); %#ok<NASGU>
    temp = int16(reshape(v,header.w,header.h));
    img = imrotate(temp, -90);
    
elseif(header.filetype == 8) %postscan B .b32
    %          tag = fread(fid,1,'int32');
    [v,count] = fread(fid,header.w*header.h,'int32'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    img = imrotate(temp, -90);
    
elseif(header.filetype == 16) %rf
    tag = fread(fid,1,'int32'); %#ok<NASGU>
    [v,count] = fread(fid,header.w*header.h,'int16'); %#ok<NASGU>
    img = int16(reshape(v,header.h,header.w));
    
elseif(header.filetype == 32) %.mpr
    tag = fread(fid,1,'int32'); %#ok<NASGU>
    [v,count] = fread(fid,header.w*header.h,'int16'); %#ok<NASGU>
    img = v;%int16(reshape(v,header.h,header.w));
    
elseif(header.filetype == 64) %.m
    [v,count] = fread(fid,'uint8'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    img = imrotate(temp,-90);
    
elseif(header.filetype == 128) %.drf
    tag = fread(fid,1,'int32'); %#ok<NASGU>
    [v,count] = fread(fid,header.h,'int16'); %#ok<NASGU>
    img = int16(reshape(v,header.w,header.h));
    
elseif(header.filetype == 512) %crf
    tag = fread(fid,1,'int32'); %#ok<NASGU>
    [v,count] = fread(fid,header.extra*header.w*header.h,'int16'); %#ok<NASGU>
    img = reshape(v,header.h,header.w*header.extra);
    %to obtain data per packet size use
    % img(:,:,:,frameCount) = reshape(v,header.h,header.w,header.extra);
    
elseif(header.filetype == 256) %.pw
    [v,count] = fread(fid,'uint8'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    img = imrotate(temp,-90);
    
elseif(header.filetype == 1024) %.col
    [v,count] = fread(fid,header.w*header.h,'int'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif(header.filetype == 4096) %color vel
    %Each frame has 4 byte header for frame number
    tag = fread(fid,1,'int32'); %#ok<NASGU>
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif(header.filetype == 8192) %.el
    [v,count] = fread(fid,header.w*header.h,'int32'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif(header.filetype == 16384) %.elo
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    temp = int16(reshape(v,header.w,header.h));
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif(header.filetype == 32768) %.epr
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    img = int16(reshape(v,header.h,header.w));
    
elseif(header.filetype == 65536) %.ecg
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    img = v;
else
    error(['Filetype ' num2str(header.filetype ) ' is not supported']);
end
end


%Notes on Version 2
%http://research.ultrasonix.com/viewtopic.php?f=2&t=656
%The frame tags are removed in all data types including .bpr, .b8..etc in version 5.6.x.
%So if you are using RP 5.6, ensure not to read for the frame tag or else the images read will be "shifted".
function img=readFrameVersion2_0(fid,header)
% load the data and save into individual .mat files

if(header.filetype == 2) %.bpr
    %Each frame has 4 byte header for frame number
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    img = uint8(reshape(v,header.h,header.w));
    
elseif(header.filetype == 4) %postscan B .b8
    
    [v,count] = fread(fid,header.w*header.h,'int8'); %#ok<NASGU>
    temp = int16(reshape(v,header.w,header.h));
    img = imrotate(temp, -90);
    
elseif(header.filetype == 8) %postscan B .b32
    
    [v,count] = fread(fid,header.w*header.h,'int32'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    img = imrotate(temp, -90);
    
elseif(header.filetype == 16) %rf
    
    [v,count] = fread(fid,header.w*header.h,'int16'); %#ok<NASGU>
    img = int16(reshape(v,header.h,header.w));
    
elseif(header.filetype == 32) %.mpr
    
    [v,count] = fread(fid,header.w*header.h,'int16'); %#ok<NASGU>
    img = v;%int16(reshape(v,header.h,header.w));
    
elseif(header.filetype == 64) %.m
    [v,count] = fread(fid,'uint8'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    img = imrotate(temp,-90);
    
elseif(header.filetype == 128) %.drf
    
    [v,count] = fread(fid,header.h,'int16'); %#ok<NASGU>
    img = int16(reshape(v,header.w,header.h));
    
elseif(header.filetype == 512) %crf
    
    [v,count] = fread(fid,header.extra*header.w*header.h,'int16'); %#ok<NASGU>
    img = reshape(v,header.h,header.w*header.extra);
    %to obtain data per packet size use
    % img(:,:,:,frameCount) = reshape(v,header.h,header.w,header.extra);
    
elseif(header.filetype == 256) %.pw
    [v,count] = fread(fid,'uint8'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    img = imrotate(temp,-90);
    
elseif(header.filetype == 1024) %.col
    [v,count] = fread(fid,header.w*header.h,'int'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif(header.filetype == 4096) %color vel
    %Each frame has 4 byte header for frame number
    
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif(header.filetype == 8192) %.el
    [v,count] = fread(fid,header.w*header.h,'int32'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif(header.filetype == 16384) %.elo
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    temp = int16(reshape(v,header.w,header.h));
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif(header.filetype == 32768) %.epr
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    img = int16(reshape(v,header.h,header.w));
    
elseif(header.filetype == 65536) %.ecg
    [v,count] = fread(fid,header.w*header.h,'uchar=>uchar'); %#ok<NASGU>
    img = v;
else
    error(['Filetype ' num2str(header.filetype ) ' is not supported']);
end
end