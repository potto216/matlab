1. To setup add the environmental variable MATLAB_LIB_ROOT = %MY_ROOT%\matlab\lib

2. As an example create a startup.m in the directory you want to work in and add
run(fullfile(getenv('MATLAB_LIB_ROOT'),'startup.m'))


