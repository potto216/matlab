%For imwrite only nonzero values are handled. All formats are
%written as 16 bit. All images are
%written as grayscale even though formats such as JPG coverts them
%to color. This technically saturates the value 1.
%
%Filename is created using the sprintf format to accept a %d
%integer file number index which starts at 1.  The mask MUST have
%been escaped so all \ replaced with \\.  Also if you want zero
%padding then make sure the mask is %03d where 3 is the number of
%zeros
%
%INPUT
%sliceSequence - is an array of the order to write the slices with
%a default of [1:size(imblk,3)].  The sequence will be
%written out using the index of sliceSequence
%Example: dataBlockObj.imwrite('C:\','%04d','tif',[100:110]);
%
%OUTPUT
%Data is scaled by the largest value to fit in one byte.

function  imwriteblk(imblk,filepath,filenameMask,fmt,metadata)
switch nargin
    case 4
        metadata=[];
    case 5
        %do nothing
    otherwise
        error('Invalid number of input arguments.');
end
sliceSequence=(1:size(imblk,3));
metadataFilename='metadata.json';

switch(lower(fmt))
    case {'png','gif','tif'}
        %do nothing
    case {'.png','.gif','.tif'}
        fmt=fmt(2:end);
    otherwise
        error(['Need to add the format ' fmt ' to the case statement. ']);
end

if any(imblk(:)<0)
    error('Cannot handle negative numbers');
end

maxValue=max(imblk(:));

for ii=1:length(sliceSequence)
    [~,~,fileExt]=fileparts(filenameMask);
    if isempty(fileExt)
        fullFilename=fullfile(filepath,sprintf([filenameMask '.%s'],ii,fmt));
    else
        fullFilename=fullfile(filepath,sprintf(filenameMask,ii));
    end
    disp(['Writing relative frame ' num2str(ii) ' of ' num2str(length(sliceSequence)) '. Using absolute image block slice number ' num2str(sliceSequence(ii)) '. ' fullFilename]);
    im=uint16(floor(imblk(:,:,sliceSequence(ii))/maxValue*(2^16-1)));
    imwrite(im,fullFilename,fmt);
end

if ~isempty(metadata)
    metadataText = jsonencode(metadata);
    
    fid=fopen(fullfile(filepath,metadataFilename),'wt');
    fwrite(fid,metadataText);
    fclose(fid);
end
end


