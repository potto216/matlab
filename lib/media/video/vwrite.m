%vwrite - writes a frame or sequence of frames to a video file.
%
%This function will write a frame or sequence of frames to disk.
%vid=vwrite(vid,A,format);
%
%vwrite treats the matrix A (m by n by k) as specifed by format.  Format
%must be specified.  The reason is to avoid conflicts where one part of the
%program assumes that it is treated as an indexed image [1,256] where another
%part assumes an intensity image [0,255].  Also because a sequence can be passed in
%format avoids the conflict of m by n by 3 being either a single color frame or
%three intensity images.
%
%Values of format:
%'intensity' - this means if A is m by n by k it will be treated as a sequence of k images.
%further the valid range is [0,1] values outside will be clipped.  If the
%image is complex the absolute value will be taken first.
%
%'frame' - this is the movie frame structure returned by Matlab functions
%such as getframe().
%
%'handle' - this is a graphics handle from Matlab.  You may need a drawnow
%before calling this function to make sure Matlab has rendered it.
%
%Note the calling convention is different than fwrite because the handle
%must be reassigned.
%
%TODO:
%add an autoscale function-however this should be designed by the main program
%because every program will want to handle the scale changes with time
%differently.  Also this should be specified in the vopen function.
%
function vid=vwrite(vid,A,format)

if vid.skipFileCreate
    return;
end

switch(vid.permission)
    case 'write'
        %okay
    otherwise
        error(['permission setting of ' vid.permission ' must be write to call vwrite.'])
end


switch(format)
    case 'intensity'
        %make the values real and clip to [0,255]
        if ~isreal(A)
            A=abs(A);
        end
        A=min(A,255*ones(size(A)));
        A=max(A,zeros(size(A)));
        %A=A*255;
    case 'frame'
        if length(A)~=1
            error('Cannot handle multiple frames yet')
        end
        A=A.cdata;
    case 'handle'
        %do nothing
    otherwise
        error(['format ' format ' is not supported.'])
end


switch(vid.format)
    case {'avi','VideoWriter'}
        
        switch(class(A))
            case 'matlab.ui.Figure'
                if ishandle(A)
                    %writeVideo(vid.obj,getframe(A)); %this only works if the screen is visible
                    writeVideo(vid.obj,getframe(A)); %this only works if the screen is visible
                else
                    error('Class matlab.ui.Figure should be a handle');
                end
            case 'matlab.graphics.axis.Axes'
                if ishandle(A)
                    %writeVideo(vid.obj,getframe(A)); %this only works if the screen is visible
                    writeVideo(vid.obj,getframe(A)); %this only works if the screen is visible
                else
                    error('Class matlab.graphics.axis.Axes should be a handle');
                end                
            case 'double'
                if ishandle(A)
                    %writeVideo(vid.obj,getframe(A)); %this only works if the screen is visible
                    writeVideo(vid.obj,im2frame(zbuffer_cdata(gcf))); %works if screen is not visible
                else
                    for ii=1:size(A,3)
                        imOut=repmat(A(:,:,ii),[1 1 3]); %make the rgb planes
                        writeVideo(vid.obj,imOut);
                        vid.lastFrameNumberWritten=vid.lastFrameNumberWritten+1;
                    end
                end
            case 'uint8'
                if size(A,3)~=3
                    error('Only handles color images');
                end
                writeVideo(vid.obj,A);
                vid.lastFrameNumberWritten=vid.lastFrameNumberWritten+1;
            otherwise
                error('class not handled')
        end
        
    case 'aviOld'
        
        switch(class(A))
            case 'double'
                if ishandle(A)
                    vid.obj = addframe(vid.obj,A);
                else
                    for ii=1:size(A,3)
                        imOut=repmat(A(:,:,ii),[1 1 3]); %make the rgb planes
                        vid.obj = addframe(vid.obj,imOut);
                        vid.lastFrameNumberWritten=vid.lastFrameNumberWritten+1;
                    end
                end
            case 'uint8'
                if size(A,3)~=3
                    error('Only handles color images');
                end
                vid.obj = addframe(vid.obj,A);
                vid.lastFrameNumberWritten=vid.lastFrameNumberWritten+1;
            otherwise
                error('class not handled')
        end
        
    case 'gif'
        switch(class(A))
            
            case 'matlab.ui.Figure'
                if ishandle(A)
                    ims=im2frame(zbuffer_cdata(gcf));
                    [capturedColorIndex,capturedColormap] = rgb2ind(ims.cdata,128);
                    
                    if vid.lastFrameNumberWritten==-1
                        imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','overwrite',vid.obj.gifArgs{:});
                    else
                        imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','append',vid.obj.gifArgs{:});
                    end
                    vid.lastFrameNumberWritten=vid.lastFrameNumberWritten+1;
                else
                    error('matlab.ui.Figure should be a handle');
                end
                
            case 'matlab.graphics.axis.Axes'
                if ishandle(A)
                    ims=im2frame(zbuffer_cdata(gcf));
                    [capturedColorIndex,capturedColormap] = rgb2ind(ims.cdata,128);
                    
                    if vid.lastFrameNumberWritten==-1
                        imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','overwrite',vid.obj.gifArgs{:});
                    else
                        imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','append',vid.obj.gifArgs{:});
                    end
                    vid.lastFrameNumberWritten=vid.lastFrameNumberWritten+1;
                else
                    error('Class matlab.graphics.axis.Axes should be a handle');
                end                    
            case 'double'
                if ishandle(A)
                    ims=im2frame(zbuffer_cdata(gcf));
                    [capturedColorIndex,capturedColormap] = rgb2ind(ims.cdata,128);
                    
                    if vid.lastFrameNumberWritten==-1
                        imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','overwrite',vid.obj.gifArgs{:});
                    else
                        imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','append',vid.obj.gifArgs{:});
                    end
                    vid.lastFrameNumberWritten=vid.lastFrameNumberWritten+1;
                else
                    for ii=1:size(A,3)
                        imOut=repmat(A(:,:,ii),[1 1 3]); %make the rgb planes
                        [capturedColorIndex,capturedColormap] = rgb2ind(imOut.cdata,128);
                        
                        if vid.lastFrameNumberWritten==-1
                            imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','overwrite',vid.obj.gifArgs{:});
                        else
                            imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','append',vid.obj.gifArgs{:});
                        end
                    end
                end
            case 'uint8'
                if size(A,3)~=3
                    error('Only handles color images');
                end
                [capturedColorIndex,capturedColormap] = rgb2ind(A,128);
                
                if vid.lastFrameNumberWritten==-1
                    imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','overwrite',vid.obj.gifArgs{:});
                else
                    imwrite(capturedColorIndex,capturedColormap,vid.filename,'gif','WriteMode','append',vid.obj.gifArgs{:});
                end
            otherwise
                error(['Class ' class(A)  ' not handled'])
        end
        
    otherwise
        error(['Unsupported format of ' vid.format]);
end