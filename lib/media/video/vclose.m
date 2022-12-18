%vclose - closes a video file after reading or writing is finished.
%
%vid = vclose(vid)
%
%vid - the handle to the video object.
%
%see also: vopen, vread, vwrite
%
function vid = vclose(vid)

if vid.skipFileCreate
    return;
end

switch(vid.format)
    case {'avi','VideoWriter'}
        switch(vid.permission)
            case 'write'
                close(vid.obj);
            otherwise
                error(['permission setting of ' vid.permission ' is not supported.'])
        end
    case 'aviOld'
        switch(vid.permission)
            case 'write'
                vid.obj=close(vid.obj);
            otherwise
                error(['permission setting of ' vid.permission ' is not supported.'])
        end
    case 'gif'
        switch(vid.permission)
            case 'write'
                %do nothing
            otherwise
                error(['permission setting of ' vid.permission ' is not supported.'])
        end

    otherwise
        error(['Unsupported format of ' vid.format])
end