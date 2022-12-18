%This function will setup simpleitk to run on the system
%You must have the path to SimpleITKJava.dll.  
%If you modify your PATH variable 
%it will only work on MATLAB 6.5 (R13) and earlier.  However, you can
%or add it to librarypath.txt in <matlabroot>/toolbox/local/librarypath.txt
%or your startup path.  Since matlab is running we use another option of
%preloading the dll with java.lang.System.load
%See http://www.mathworks.com/support/solutions/en/data/1-OVUMA/index.html
%for more details
%But normally this doesn't work for the startupdir.  What does work is
%using the javalibrarypath.txt
%(http://www.mathworks.com/matlabcentral/newsreader/view_thread/323412)
%when using the startup option
function simpleitkSetup
fullpath=fullfile(getenv('ULTRASPECK_ROOT'),'common','java','simpleitk','SimpleITK-0.6.1-Java-win64');
javaaddpath(fullfile(fullpath,'simpleitk-0.6.1.jar'))

%This doesn't seem to work
%java.lang.System.load(fullfile(fullpath,'SimpleITKJava.dll'));	 %Windows
end