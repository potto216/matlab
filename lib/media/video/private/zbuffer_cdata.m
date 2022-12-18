%http://www.mathworks.com/support/solutions/en/data/1-3NMHJ5/?solution-3NMHJ5
%usage: F = im2frame(zbuffer_cdata(gcf));
%
%http://www.mathworks.com/support/solutions/en/data/1-BC7N66/?solution=1-BC7N66
% How can I increase the resolution of a frame produced by HARDCOPY?
% Problem Description:
% 
% I am using the HARDCOPY function to capture the cdata values which is then converted to a frame using the IM2FRAME function. I would like to be able to increase the resolution of the frame captured.
% hfig = figure(1);
% surf(peaks);
% cdata = hardcopy(hfig, '-Dopengl', '-r0');
% frame = im2frame(cdata);
% 
% Solution:
% 
% The default resolution is set to 84dpi as stated by the third input to the HARDCOPY function '-r0'. To increase the resolution to lets say 150 dpi, modify the call to HARDCOPY as follows:
% cdata = hardcopy(hfig, '-Dopengl', '-r150');
function cdata = zbuffer_cdata(hfig)
% Get CDATA from hardcopy using zbuffer

% Need to have PaperPositionMode be auto
orig_mode = get(hfig, 'PaperPositionMode');
set(hfig, 'PaperPositionMode', 'auto');

%cdata = hardcopy(hfig, '-Dzbuffer', '-r0');
%cdata = hardcopy(hfig, '-dOpenGL', '-r0');
%cdata = hardcopy(hfig, '-dopengl', '-r0');  %This seems to be hwo the new opengl is given as all lower case
cdata = print('-RGBImage');

% Restore figure to original state
set(hfig, 'PaperPositionMode', orig_mode); % end


