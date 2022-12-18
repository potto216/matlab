%vopen - opens a video file for reading or writing.
%
%The vopen function is designed to provide a wrapper to hide the
%complexities of creating a video file.  The model is the standard fopen
%routines.
%
%vid = vopen(filename,permission, fps, format,skipFileCreate)
%filename - is the full filename path of the video file.
%
%permission - is 'r'ead or 'w'rite to read an existing video file or
%create a video file.
%
%fps - The frames per second to generate a video.
%
%format - the type of video formats.  If this is a string then the
%default compression routine will be used.  If it is a cell array then the
%first element is a string of the format and the remaining elements are the
%parameters needed to implement the format.
%The valid formats currently are:
%
%'avi','VideoWriter' - The Windows AVI standard or override to use the videowriter.
%for write mode: If just the string 'avi' is given then
%the default parameters of VideoWriter are used. Otherwise you can specify 
%a profile for VideoWriter such as 'Motion JPEG AVI' or 'Uncompressed AVI',
%but then it needs to be a cell such as {'avi', 'Uncompressed AVI'}
%
%'aviOld' - Allows deprecated codecs to be used Cinepak, MSVC, etc.  They
%are basically the Codecs called with avifile, but are not supported in
%Windows Server/7 etc
%
%'gif' - creates a gif animation.  The args follow imwrite such as {'DelayTime',1}
%
%'mpeg' - option that is not supported yet, however the underlying
%function support is in place
%
%skipFileCreate - this option is useful when you don't want to create the
%file for a run.  This avoids having to surround all of the video functions
%with if statements.
%
%EXAMPLES
%>>vid=vopen(filename,'w',1,{'gif','DelayTime',1},skipMaskVideo);
%>>vid=vopen(filename,'w',5,{'avi', 'Uncompressed AVI'},skipMaskVideo);
%
%Note:  The functionality of this API will be increased as needed.
%vid.lastFrameNumberWritten is the last frame written where -1 means no
%frames have been written and 0 is the first frame written.
%see also: vread, vwrite, vclose
function vid=vopen(filename,permission,fps,format,skipFileCreate) %#ok<INUSD>

p=inputParser;
p.addRequired('filename', @ischar);
p.addRequired('permission', @(x) ischar(x) && any(strcmpi(x,{'r','w'})));
p.addRequired('fps', @(x) isscalar(x) && isNoFraction(x) && (x>0));
p.addRequired('format', @(x) iscell(x) || (ischar(x) && any(strcmpi(x,{'avi'}))));
p.addOptional('skipFileCreate',false,@(x) islogical(x));

p.parse(filename,permission,fps,format,skipFileCreate);

vid.filename=p.Results.filename;
vid.fps=p.Results.fps;
permission=p.Results.permission;
format=p.Results.format;
vid.skipFileCreate=p.Results.skipFileCreate;

if vid.skipFileCreate
    return;
end


switch(permission)
    case 'r'
        vid.permission='read';
    case 'w'
        vid.permission='write';
    otherwise
        error(['Invalid permission setting of ' permission])
end

if iscell(format)
    if length(format)==1
        vid.format=format{1};
        formatArgs={};
    elseif length(format)>1
        vid.format=format{1};
        formatArgs=format(2:end);
    else
        error('This should never occur')
    end
else
    vid.format=format;
    formatArgs={};
end

switch(vid.format)
    case {'avi','VideoWriter'}
        switch(vid.permission)
            case 'write'                
                vid.obj = VideoWriter(vid.filename,formatArgs{:});
                vid.obj.FrameRate=vid.fps;
                open(vid.obj);
                
            otherwise
                error(['permission setting of ' vid.permission ' is not supported.'])
        end
        
    case 'aviOld'
        switch(vid.permission)
            case 'write'
                vid.obj=avifile(vid.filename,'fps',vid.fps,formatArgs{:});
            otherwise
                error(['permission setting of ' vid.permission ' is not supported.'])
        end
        
    case 'gif'
        switch(vid.permission)
            case 'write'
                vid.obj.gifArgs=formatArgs;
            otherwise
                error(['permission setting of ' vid.permission ' is not supported.'])
        end
                
    otherwise
        error(['Unsupported format of ' vid.format])
end

vid.lastFrameNumberWritten=-1;

end