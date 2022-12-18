%This function will convert an avi from one CODEC to another.  This is
%espically useful when converting uncompressed AVI to compressed avi's
function vconvert(srcFilename,dstFilename,dstCodec,dstFPS)

fileinfo = aviinfo(srcFilename);


if isempty(dstCodec)
    dstCodec='none';
end

if isempty(dstFPS)
    dstFPS=fileinfo.FramesPerSecond;
end

vid=vopen(dstFilename,'w',dstFPS,{'avi','compression',dstCodec});

for ii=1:fileinfo.NumFrames
    
    mov = aviread(srcFilename, ii);
    vid=vwrite(vid,mov,'frame');
end
vid=vclose(vid); %#ok<NASGU>


