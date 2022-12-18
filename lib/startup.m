
%put everything at the end of path to give matlab functions with the same name preference
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'frameSet'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'general'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'general','fileio'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'spline'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'media'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'media','meta'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'media','ultrasonix'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'media','video'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'caseTools'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'model'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'motionEstimation'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'plotting'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'userInterface'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'shearwave'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'fieldII'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'math'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'parallel'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'image'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'database'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'mtrack'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'mtrack','activeContour'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'mtrack','fpt_koseckaTracker'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'filter','oenergy'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'simulate','ultrasound'),'-end')

%setup functions so Matlab will work okay
if ~isOctave()
	addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'octaveFunctions'),'-end')
end


%Add the external tools 
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext','matitk_win'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext','Field_II_PC7'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext','freezeColors'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext','cm_and_cb_utilities'),'-end')
addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext'),'-end')


addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext','RANSAC-Toolbox'),'-end')  %needed to set the model information
 
% addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext','tensor_toolbox_2.5','met'),'-end')
% addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext','tensor_toolbox_2.5'),'-end')

addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'ext','bergenImRegistration'),'-end')

%Add MTRP Access addpath(fullfile(getenv('MATLAB_LIB_ROOT'),'projects','triggerPoint','matlabData','externalView'),'-end')