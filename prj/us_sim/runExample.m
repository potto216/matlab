%%
clear            
close all

% These environment variables must point to a path where the results of the
% generation and processing will be stored.
setenv('DATA_PROCESS','D:\data\ultrasound\sim')
setenv('DATA_ULTRASOUND','D:\data\ultrasound\sim')

forceNewPhantom=false; % Create a new phantom even if a previous one is cached

trialNameList={};
trialNameList{end + 1}='translationTrackCyst';
% These have not been validated recently
% trialNameList{end + 1}='translationTrackRandomUniformPixelOnly';
% trialNameList{end + 1}='translationTrackRandomUniformSpeckleSimPixelOnly';
% trialNameList{end + 1}='translationTrackRectangleAWNPixelOnly';
% trialNameList{end + 1}='translationTrackRectanglePixelOnly';
% trialNameList{end + 1}='translationTrackRectangleSpecklePixelOnly';

useParallelProcessing=false; % this is only true if you have the parallel processing toolbox.

%% Creates the phantom
phantomSimulateMotion(trialNameList,forceNewPhantom,useParallelProcessing)

%% Simulates the ultrasound collect
fieldIISimulateBatch(trialNameList, useParallelProcessing)

%% Create the b mode image
% B-Mode images are in the directory: %DATA_ULTRASOUND%\sim\translationTrackCyst\collection\fieldii\bmode
% RF data from the ultrasound scanner is in the directory: %DATA_ULTRASOUND%\sim\translationTrackCyst\collection\fieldii\rf
% Projected outputed images are in the directory: %DATA_ULTRASOUND%\sim\translationTrackCyst\collection\projection\bmode
% Phantom information such as motion and scatter configuration is at: %DATA_ULTRASOUND%\sim\translationTrackCyst\phantom\matchrf

skipImageCreate=false;
dualImage=false;
fieldIIMakeBMode(trialNameList, skipImageCreate, dualImage);


