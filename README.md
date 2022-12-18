# Matlab Stuff
## Overview 
This repository is Matlab code that I have written for my own consumption, but available for any use. The only licenses are those that are already in the code from files I got from others. Most of this third party code can be found in  `lib\ext` which also makes up the majority of the repository's size. WARNING there is executable code such as DLLs in `lib\ext` so make sure to do whatever scanning you feel is appropriate. Use this code at your own risk.

## Setup
The code is setup to run under Windows. Using Matlab 2018. The

1. To setup add the environmental variable MATLAB_LIB_ROOT = %MY_ROOT%\matlab\lib

2. As an example create a startup.m in the directory you want to work in and add
`run(fullfile(getenv('MATLAB_LIB_ROOT'),'startup.m'))`

3. Create a Windows Matlab shortcut icon, select properties and change the startup directory to the directory where `startup.m` is. For example: `matlab\prj\us_sim`

## Running 
Open `matlab\prj\us_sim\runExample.m` and change the below code in the file to point to your path:
```
setenv('DATA_PROCESS','D:\data\ultrasound\sim')
setenv('DATA_ULTRASOUND','D:\data\ultrasound\sim')
```
Running the code will take several hours, but will generate the following B-mode image simulating with Field II what an ultrasound scanner generates when scanning a moving phantom.

![Rendered images of what Field II simulation produces](prj/us_sim/outputphantomFieldII_mono_translationTrackCyst.gif)


