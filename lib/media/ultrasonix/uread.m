%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [frame,header,parameterList] = uread(filename,frameNumber,varargin) - loads
% data from a Sonix RF ultrasound file using a 0 based frame index number.
%
%DESCRIPTION
% Function loads an image or images from ultrasound RF data saved in
% the Sonix software and returns them after the requested post processing.
% This can also load an ECG file (type 65536) but you may need to invert
% the signal.  This function will load "version 1" files (files created by
% Sonix RP software versions before 5.6.x), and "version 2" files (files
% created by Sonix RP software versions after 5.6.x).  The difference
% between version 1 and version 2 is that in version 2 the frame tags were
% removed (http://research.ultrasonix.com/viewtopic.php?f=2&t=656).  The
% function will automatically determine which version the file is and
% open it.  If possible the function also determines the scale of the data
% elements and will save them as header.pixel.scale.lateral.value/units and
% header.pixel.scale.axial.value/units.  For some cases determining the
% pixel scale is not possible, such as for b8 files,
% (http://research.ultrasonix.com/viewtopic.php?f=29&t=1386) so a length 
% parameter will need to be given.
%
%EXAMPLES
% 1. To read all the frames in a file:
%        >>[frame,header] = uread(filename,[]);
% 2. To read frames 0:20 in a file:
%       >>[frame,header] = uread(filename,[0:20]);
% 3. To read just the header information in a file:
%       >>[~,header] = uread(filename,-1);
% 4. To read the rf data as complex values:
%       >>[frame,header] = uread(filename,[0:20],'frameFormatComplex',true);
% 5. To read the rf data as complex values with decimation:
%       >>[frame,header] = uread(filename,[0:20],'decimateLaterial',true,'frameFormatComplex',true);
% 5. To read the rf data as magnitude only with decimation:
%       >>[frame,header] = uread(filename,[0:20],'decimateLaterial',true,'frameFormatComplex',true,'magOnly',true);
% 5. To read 21 frames from a b8 file where the scan depth (3.5 cm) is known:
%       >>[frame,header] = uread(filename,[0:20],'axialDepth_mm',35);
%
%INPUTS
%filename - The fullpath and filename of the data file to open.  It must
%  be a sonix rf file.
%
%frameNumber -  This is the frame number being read.  The valid range is [0,(header.nframes-1)].
%  This value can also be a vector and return a set of  frames with the
%  index corresponding to the frame number being the third dimension of
%  img, the returned image frames.  If this is empty then all of the frames
%  are loaded.  This could cause your function to crash if you do not have enough
%  continuous free memory available.  If the frameNumber is -1 then only the
%  header information is read, and frame is returned as an empty.
%
%frameFormatComplex  -  A logical pair value which indicates if IQ data should be formed
%  from the raw RF using the hilbert transform.  The IQ data is the analytic
%  signal.  The default is false.
%
%decimateLaterial - A logical pair value which indicates if the software should skip the
%  even rows (laterical columns) to reduce interpolation effects when the
%  number of lines exceeds the number of elements in the transducer.
%  The default is false. decimate lateral is automatically set if in header only mode
%  and  header.ld==256 && header.w==256
%
%axialDepth_mm - This is the physical depth in millimeters of the image.  Specifying 
%  this parameter is useful for b8 files where the pixel size cannot be 
%  determined from data in the file.  An empty value is default and means
%  it will not be used
%
%parametersMode - ({'manual'},'auto') Determines if the parameters are manually passed in or
%  automatically determined.  If automatically determined then the parameeters
%  will be based on the file header values.  'auto' mode will override any
%  parameters manully passed in.  For information on how it works see the
%  internal function "loadAutoParameters"
%
%OUTPUT
%frame  - The image data returned into a 3D array (h, w, numframes).  The variable
%might be a cell array if multiple images are requested such as from color
%variance.  Then each element in the cell will be a 3D array.
%
%header - The file header information.  The values for the header are:
% header.filetype - data type (can be determined by file extensions)
% header.nframes - number of frames in file
% header.w - width (number of vectors for raw, image width for processed data) [see note for details]
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
% header.extra - extra information (see below)
% header.file - a struct containing details about the file such as the
%        header size and version type.
% header.probeInfo.name - the next name for the probe id given in header.probe.
% header.probeInfo.elementPitch_mm - element pitch in mm
% header.probeInfo.elementCount - number of eleements in the probe
% header.pixel.scale.{lateral,axial}.{value/units} - If the scale field
%        exists it will contain the size of each pixel and the units it is
%        in.
% header.extra description
% ===Color Mode RF===
% It is the ensemble (packet size) of the color RF.  The ensemble/packet size is the number of sound bursts
% transmitted per color sector line. The more RF packets, the greater sensitivity you will have, but slower
% frame rate. So in the Human liver sample data on the Ultrasonix website, there are 29 CRF frames. In the color
% box, there are 432 RF lines. There are 54 lines in each ensemble/packet. The total number of pack is 8. It can
% be found that lines from 8 packets can be assembled into one color box RF line, if one appends one pack data on
% the other packet.  This is because the 54 lines are spread across the color box, and 8 of each line are tx/rx. The PRF determines the rate of packets. For example line 1 of color box has 8 RF packets, and if PRF was 3kHz, then the timing between each of the 8 lines is 333 microseconds. If there is time in between, then other lines are captured as to ensure frame rate is the fastest. These 8 packets for one line are run through wall filtering and autocorrelation, and since the  RF lines are very similar, so it should just filter out low amplitude blood flow.
% Reference: http://research.ultrasonix.com/viewtopic.php?f=2&t=307&p=1791&hilit=header.extra#p1791
% ===Bmode===
%%It is also said to tbe the micron per pixel of the image. So you can use it to convert to actual physical distances from the pixels in the image.
%Ref
%http://research.ultrasonix.com/viewtopic.php?f=5&t=1106&p=4258&hilit=pixel+size#p4258,
%however this is always zero
%===Issues Computing Width===
%The width may not be the same as the line density.  Example width 256/line
%density 128. Fix?
%1.Change the imaging mode to a non-harmonic mode, and the number of RF lines will match the line 
%See
%http://www.ultrasonix.com/wikisonix/index.php/Sequencing#Pulse_Inversion_Harmonics.
%
%parameterList - A list of the currently used parameters.  Can be passed
%back into uread with parameterList{:}.parametersMode is not included
%because it is a method of generating parameters and not a parameter
%itself.   Additionally if the list were
%passed back in having parametersMode could cause the parameters to be
%recalculated.
%And How can I get the width information of the tissue structure from the .rf data?
%
%AUTHOR
%Paul Otto (potto@gmu.edu).
%The code for the frame read is based on code by Corina Leung, corina.leung@ultrasonix.com.
%
%NOTES:
%The .b8 file might need to be read in as uint8 instead of int8.  This has
%not been tested yet.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [frame,header, parameterList] = uread(filename,frameNumber,varargin)

p = inputParser;   % Create an instance of the class.
p.addRequired('filename', @ischar);
p.addRequired('frameNumber', @(x) (isnumeric(x) && isvector(x)) || isempty(x));
p.addParamValue('frameFormatComplex',false,@islogical);
p.addParamValue('decimateLaterial',false,@islogical);
p.addParamValue('magOnly',false,@islogical);
p.addParamValue('axialDepth_mm',[],@(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('parametersMode','manual',@(x) any(strcmp(x,{'manual','auto'})));

p.parse(filename,frameNumber,varargin{:});

frameFormatComplex=p.Results.frameFormatComplex;
decimateLaterial=p.Results.decimateLaterial;
magOnly=p.Results.magOnly;
parametersMode=p.Results.parametersMode;
axialDepth_mm=p.Results.axialDepth_mm;


fid=fopen(filename, 'r');
if( fid == -1)
    error(['Cannot open the file ' filename]);
end

header=ultrasonixReadHeader(fid);


switch(parametersMode)
    case 'auto'
        %this function must come after the header is loaded and before any processing
        [frameFormatComplex,decimateLaterial]=loadAutoParameters(filename,header);
    case 'manual'
        %do nothing
    otherwise
        error(['parametersMode of ' parametersMode ' is not a valid value of auto or manual']);
end

%parametersMode is not included because it is a method of generating
%parameters and not a parameter itself.   Additionally if the list were
%passed back in having parametersMode could cause the parameters to be
%recalculated.
parameterList={'frameFormatComplex',frameFormatComplex,'decimateLaterial',decimateLaterial,'magOnly',magOnly};


if frameFormatComplex
    switch(header.filetype)
        case 2048
            error('colordoppler is not complex data.  Please set frameFormatComplex to false.');
        otherwise
            %do nothing
    end
else
    %do nothing
end
readHeaderOnly=false;
if any(frameNumber<0) || any(frameNumber>=header.nframes)
    %make sure it is not the scalar read header case
    if length(frameNumber)==1 && frameNumber==-1
        readHeaderOnly=true;
        
        %okay value
    else
        error(['Invalid frame number.  Must be in the integer set [0,' num2str(header.nframes-1) '] or a scalar of -1 to just read the header']);
    end
end


if (readHeaderOnly && header.ld==256 && header.w==256)
    decimateLaterial=true;
end

if isempty(frameNumber)
    frameNumber =(0:(header.nframes-1));
else
    %do nothing
end

if readHeaderOnly
    %only load the header and not any frames
    frame = [];
else
    frameCount=length(frameNumber);
    
    %preallocate for speed and to not fragment the memory
    if frameFormatComplex
        frame =complex(zeros(header.h,header.w,frameCount),zeros(header.h,header.w,frameCount));
    else
        switch(header.filetype)
            case 2048
                frame =cell(2,1,frameCount);
            otherwise
                frame =zeros(header.h,header.w,frameCount);
                %do nothing
        end
        
    end
    
    
    for ii=1:length(frameNumber)
        
        if frameFormatComplex
            frame(:,:,ii)=hilbert(double(readFrame(fid,header,frameNumber(ii))));
        else
            switch(header.filetype)
                case 2048
                    frame(:,:,ii)=readFrame(fid,header,frameNumber(ii));
                otherwise
                    frame(:,:,ii)=double(readFrame(fid,header,frameNumber(ii)));
                    %do nothing
            end
            
        end
        
        if magOnly            
            frame(:,:,ii)=abs(frame(:,:,ii)).^0.5;
        end
        
    end
    
    if decimateLaterial
        frame=frame(:,1:2:end,:);
    else
        %do nothing
    end
    
end


if decimateLaterial 
    if header.ld~=256 || header.w~=256
        error('It is assumed both ld and w are 256 when decimate lateral is used');
    else
        header.ld=header.ld/2;
        header.w=header.w/2;
    end
else
    %do nothing
end
%Now see if the units can be determined
[header.pixel.scale]=computePixelScale(header,axialDepth_mm);
fclose(fid);

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
    img = imrotate(temp, -90); %#ok<NASGU>
    error('validate that this is flipped the correct way.');
    
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
    
elseif((header.filetype == 2048)) %color .cvv
    error('color .cvv needs to be added.');
    
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
    
    [v,count] = fread(fid,header.w*header.h,'uint8'); %#ok<NASGU>
    temp = int16(reshape(v,header.w,header.h));
    img = imrotate(temp, -90);
    img=fliplr(img);  %Added because of flipping problem
    
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
elseif(header.filetype == 1024) %.col
    [v,count] = fread(fid,header.w*header.h,'int'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    temp2 = imrotate(temp, -90);
    img = mirror(temp2,header.w);
    
elseif((header.filetype == 2048)) %color .cvv (the new format as of SONIX version 3.1X)
    % velocity data
    %[v,count] = fread(fid,header.w*header.h,'uint8'); %PO
    [v,count] = fread(fid,header.w*header.h,'uint8'); %#ok<NASGU>
    temp = reshape(v,header.w,header.h);
    temp2 = imrotate(temp, -90);
    img{1} = mirror(temp2,header.w);
    
    % sigma
    [v,count] =fread(fid, header.w*header.h,'uint8'); %#ok<NASGU>
    temp = reshape(v,header.w, header.h);
    temp2 = imrotate(temp, -90);
    img{2} = mirror(temp2,header.w);
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


function [header]=ultrasonixReadHeader(fid)

fPass=fseek(fid,0,SEEK_SET());
if fPass~=0
    error('fseek failed')
end

% read the header info
hinfo = fread(fid, 19, 'int32');

% load the header information into a structure and save under a separate file
header = struct('filetype', 0, 'nframes', 0, 'w', 0, 'h', 0, 'ss', 0, 'ul', [0,0], 'ur', [0,0], 'br', [0,0], 'bl', [0,0], 'probe',0, 'txf', 0, 'sf', 0, 'dr', 0, 'ld', 0, 'extra', 0);
header.filetype = hinfo(1);
header.nframes = hinfo(2);
header.w = hinfo(3);
header.h = hinfo(4);
header.ss = hinfo(5);
header.ul = [hinfo(6), hinfo(7)];
header.ur = [hinfo(8), hinfo(9)];
header.br = [hinfo(10), hinfo(11)];
header.bl = [hinfo(12), hinfo(13)];
header.probe = hinfo(14);
header.txf = hinfo(15);
header.sf = hinfo(16);
header.dr = hinfo(17);
header.ld = hinfo(18);
header.extra = hinfo(19);

[header.probeInfo.name, header.probeInfo.elementPitch_mm, header.probeInfo.elementCount ]=getProbeInfo(header.probe);

%frameSizeBytes=(header.w*header.h)*2+(1*4);
if mod(header.ss,8)~=0
    error(['Unsupported sample size of ' num2str(header.ss) ' bits when reading the header.  Sample size must be a multiple of 8 bits.']);
end

fPass=fseek(fid,0,'eof');
if fPass~=0
    error('fseek failed')
end
fileSizeInBytes=ftell(fid);


headerSizeBytes=(19*4);
frameSizeBytesWithoutTag=(header.w*header.h)*(header.ss/8);
frameSizeBytesWithTag=((header.w*header.h)*(header.ss/8)+4); %the tag is 4 bytes

%we need to decide what file version this is.  the table below shows how we
%refer to them.
%Version Name | Description
% 1.0         | This is the "original" version we used with frame tag numbers.
%             | SonixRP 3.2.2 uses it
% 2.0         | This version  which is used with Sonix RP 5.6.5 does not
%             | have frame tag numbers

%To do the check we look at the file size and compare the total size
if fileSizeInBytes == (headerSizeBytes+frameSizeBytesWithTag*header.nframes)
    header.file.version='1.0';
    header.file.headerSizeBytes=headerSizeBytes;
    header.file.frameSizeBytes=frameSizeBytesWithTag;
elseif fileSizeInBytes == (headerSizeBytes+frameSizeBytesWithoutTag*header.nframes)
    header.file.version='2.0';
    header.file.headerSizeBytes=headerSizeBytes;
    header.file.frameSizeBytes=frameSizeBytesWithoutTag;
else
    warning('UREAD:UNSUPPORTED_VERSION',['Unsupported file type. Defaulting to version 2.  There are ' num2str(fileSizeInBytes-(headerSizeBytes+frameSizeBytesWithTag*header.nframes)) ' unexpected bytes.']);
    header.file.version='2.0';
    header.file.headerSizeBytes=headerSizeBytes;
    header.file.frameSizeBytes=frameSizeBytesWithoutTag;
    
end

end

%Position file relative to the beginning. this is -1 in Matlab
function [val]=SEEK_SET()
val=-1;
return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function for viewing the mirror reflection of an image along a Line
% Im - Input image
% pos - Line position where pos is a number between 1 and the number of columns in the image
% newIm - The mirror image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newIm = mirror(Im,pos)

[x, y, z]=size(Im);
newIm = zeros(x,y,z);

newIm(:,pos+1:y,:) = Im(:,1:y-pos,:);
newIm(:,1:pos,:) = Im(:,pos:-1:1,:);
end

%Measurements come from Transducer Specification Sheet.pdf Ultrasonix Medical Corporation
%Last Updated: August 2009
function [probeName, elementPitch_mm, elementCount ]=getProbeInfo(probeId)
elementPitch_mm=[];
elementCount=[];
switch(probeId)
    
    case 0
        probeName='4DL14-5/38';
    case 1
        probeName='LAP9-4/38';
    case 2
        probeName='L14-5/38';
        elementPitch_mm=0.3048;
        elementCount=128;
        
    case 3
        probeName='HST15-8';
    case 4
        probeName='mTEE8-3/5';
    case 5
        probeName='C5-2/60';
    case 7
        probeName='L14-5W/60';
        elementPitch_mm=0.4720;
        elementCount=128;
        
    case 8
        probeName='EC9-5/10';
    case 9
        probeName='BIPXY';
    case 10
        probeName='C5-2/60';
    case 11
        probeName='L9-4/38';
    case 12
        probeName='BPL9-5/55';
    case 13
        probeName='BPC8-4/10';
    case 15
        probeName='4DC7-3/40';
    case 16
        probeName='m4DC7-3/40';
    case 20
        probeName='PA7-4/12';
    case 21
        probeName='C7-3/50';
    case 22
        probeName='MC9-4/12';
    case 29
        probeName='SA4-2/24';
    otherwise
        probeName=num2str(probeId);
        %warning(['Unsupported probe id ' probeName]);
        error(['Unsupported probe id ' probeName]);
        
end
end

%This function will determine the parameters automatically

function [frameFormatComplex,decimateLaterial]=loadAutoParameters(filename,header) %#ok<INUSL>


switch(header.ld)
    case 256
        decimateLaterial=true;
        
    case 128
        decimateLaterial=false;
        
    case 0
        decimateLaterial=false;
    otherwise
        error(['Unsupported line density value of ' num2str(header.ld)]);
end

switch(header.filetype)
    case 16 %.rf
        frameFormatComplex=true;
        
    case 4 %.b8
        frameFormatComplex=false;
    otherwise
        error(['Unsupported line density value of ' num2str(header.filetype)]);
end
end

%This function computes the scales of a pixel based on the information
%in the header and if the information axialDepth_mm is given.
function [scale]=computePixelScale(header,axialDepth_mm)



    %The axial pixel length can be computed by dividing the speed of sound in
    %tissue by the sample rate and dividing all of that by 2 because of the
    %time needed to hit the target and return.
    %average speed of sound in soft tissue 1540 m/s everywhere in body
    %so 1540*1000mm
    %metadata.rf.header.sf is assumed to be in samples/sec so that final units are
    % m     mm     s             mm
    %---- -----  --------  =  --------
    % s      m     sample      sample
axialSpacing_mm=1540*1000/(header.sf*2);


    if header.probeInfo.elementCount<header.ld
        disp(['Line density of ' num2str(header.ld) ' exceeds the element count of ' num2str(header.probeInfo.elementCount) ' so must be synthetic lines.']);
    end


if(header.filetype == 4) %postscan B .b8
    if header.ld~=0
        error('Assumption is that header.ld is zero');
    end
    
    lateralTotalWidth_mm=header.probeInfo.elementPitch_mm*header.probeInfo.elementCount;
    
    % header.ul - region of interest (roi) {upper left x, upper left y}
    % header.ur - roi {upper right x, upper right y}
    % header.br - roi {bottom right x, bottom right y}
    % header.bl - roi {bottom left x, bottom left y}
    if (header.ul(2)~=header.ur(2)) || (header.bl(2)~=header.br(2)) || (header.ul(1)~=header.bl(1)) || (header.ur(1)~=header.br(1))
        warning('Assumption violated.  Region of interest is not square. Proceeding with assumption that it is.  Please check this file.');
    end
    

    %use the axialDepth to compute the pixel size.
    if ~isempty(axialDepth_mm)
        
        scale.axial.value=axialDepth_mm/(header.bl(2)-header.ul(2)+1);
        scale.axial.units='mm';
        
        %the pixels are square
        scale.lateral.value=scale.axial.value;
        scale.lateral.units='mm';
        
    else  %Otherwise assume a full sector size and use the scanner lateral width as the length to determine the pixel size
        %The lateral size in relation to the header is the total elements times
        
        %each pitch then divided by the header size listed
        scale.lateral.value=lateralTotalWidth_mm/(header.ur(1)-header.ul(1)+1);
        scale.lateral.units='mm';
        
        %the pixels are square
        scale.axial.value=scale.lateral.value;
        scale.axial.units='mm';        
    end
    
    
    
elseif(header.filetype == 16) %rf

    scale.axial.value=axialSpacing_mm;
    scale.axial.units='mm';

    %The element pitch is fixed, but the line density can vary
    lateralTotalWidth_mm=header.probeInfo.elementPitch_mm*header.probeInfo.elementCount/header.ld*header.w;
    
    if header.ld~=header.w
        if header.w==64 &&  header.ld==128 && header.probe==7
            scale.lateral.value=lateralTotalWidth_mm/header.ld;
            scale.lateral.units='mm';
        else
            warning('Assumption violated.  Line density and RF file width are not the same.  Scaling the width Please resolve this.');
            scale.lateral.value=lateralTotalWidth_mm/header.w;
            scale.lateral.units='mm';
        end
    else
        %The lateral size in relation to the header is the total elements times
        %each pitch then divided by the header size listed
        scale.lateral.value=lateralTotalWidth_mm/header.w;
        scale.lateral.units='mm';
    end
    
    
else
    error(['Filetype ' num2str(header.filetype ) ' is not supported']);
end




end