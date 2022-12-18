% List of updates and changes with each version, starting from v4_2
%--------------------------------------------------------------------------
%
% 13/06/2016 - Version 4.2.2
% UPDATES
% 1) Bug fix - U correction button was causing incorrect display of
% corrected fascicle on the image. This has been fixed


% 07/04/2016 - Version 4.2
% 
% UPDATES
% 1) Saving and loading tracking data now does not save the ROI (to prevent
% excessive file sizes and recomputes it upon "load all tracked frames"
% 2) Method for loading video updated to speed up loading of AVI files -
% this only applies when using R2010b or later
% 3)Updated rbline.m and rbline2.m to fix bug with drawing line 
% 4)Output data in previous versions approximated the variable frame rate of the
% ultrasound data to a constant average frame rate based on the number of
% frames and the finsal TVD time stamp. This has been changed to use the 
% original time stamps, so the output data will have the same variable
% frame rate as the input data.
% 5) Default value for Fixed ROI check box set to checked
% 6) It now tracks forward and backward through the sequence if the first
% digitised frame is not the first frame
