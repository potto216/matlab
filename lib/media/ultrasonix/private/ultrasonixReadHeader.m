
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
if fileSizeInBytes==(headerSizeBytes+frameSizeBytesWithTag*header.nframes)
    header.file.version='1.0';
    header.file.headerSizeBytes=headerSizeBytes;
    header.file.frameSizeBytes=frameSizeBytesWithTag;
elseif fileSizeInBytes==(headerSizeBytes+frameSizeBytesWithoutTag*header.nframes)
    header.file.version='2.0';
    header.file.headerSizeBytes=headerSizeBytes;
    header.file.frameSizeBytes=frameSizeBytesWithoutTag;    
else
    warning(['Unsupported file type. Defaulting to version 1.  There are ' num2str(fileSizeInBytes-(headerSizeBytes+frameSizeBytesWithTag*header.nframes)) ' unexpected bytes.']);    
    header.file.version='1.0';
    header.file.headerSizeBytes=headerSizeBytes;
    header.file.frameSizeBytes=frameSizeBytesWithTag;

end

end

