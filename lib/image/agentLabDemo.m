clear all
close all

%% Load a data file without case information
addpath(fullfile(getenv('ULTRASPECK_ROOT'),'\common\matlab\image'))
%Z:\data_01\MR_US_Data\rectusFemoris\MRUS003_V1\05-02-2013-MSK
inputPath=fullfile('Z:\data_01\MR_US_Data\rectusFemoris\MRUS003_V1\05-02-2013-MSK'); %conterlaterial motion
rfBasefilename='18-50-32.rf';
metaData.scale.lateral.value=141.000000e-3;
metaData.scale.lateral.units='mm';
metaData.scale.axial.value=141.000000e-3;
metaData.scale.axial.units='mm';
outputMovieFilename='rectusFemoris.avi';

fullfilename=fullfile(inputPath,rfBasefilename);

dataBlockObj=DataBlockObj(fullfilename,@uread,'openArgs',[],'metadataMaster',metaData);
dataBlockObj.open('cacheMethod','auto');
dataBlockObj.newProcessStream('agentLab',@(x) abs(x).^0.5, true);

varargout = agentLab(dataBlockObj);

fileCreationSettings ={outputMovieFilename,'w',fix(dataBlockObj.getUnitsValue('frameRate','framesPerSec')/2),{'avi', 'Uncompressed AVI'},false};
dataBlockObj.movie([],fileCreationSettings);

%% Load a data file using a case file
addpath(fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\data\subject\mriCompare'));
varargout = agentLab({'trialName','MRUS008_V1_S1_T1','dataSourceNodeName', 'col_ultrasound_bmode'});

%% Load a matlab array into agentLab
%dataBlockObj=DataBlockObj(imBlock,'matlabArray');
%dataBlockObj.open('cacheMethod','all');
%processFunction=@(x) x;
%dataBlockObj.newProcessStream('agentLab',processFunction, true);
%varargout = agentLab(dataBlockObj);

%% Tendon Show video without saving a movie
addpath(fullfile(getenv('ULTRASPECK_ROOT'),'\common\matlab\image'))
%Z:\data_01\MR_US_Data\rectusFemoris\MRUS003_V1\05-02-2013-MSK
inputPath=fullfile('D:\dataUltrasound\invivo_tendon\WalkAid Ultrasound\AB2\02-02-2010-MSK'); %conterlaterial motion
rfBasefilename='10-00-59_27.rf';

%slow 5
inputPath=fullfile('D:\dataUltrasound\invivo_tendon\WalkAid Ultrasound\AB3\03-05-2010-MSK');
rfBasefilename='09-41-16_trial2.rf';

%fast 9
inputPath='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV04\04-09-2012-MSK';
rfBasefilename='SD1.rf';

%fast tendon movement
inputPath='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV05';
rfBasefilename='SDF60MM2.rf';

inputPath='D:\dataUltrasound\invivo_tendon\Normal Patients\WA9 (JW)';
rfBasefilename='09-47-14 WA9_4month.rf';  %wrong muscle view
rfBasefilename='11-27-59 WA9_10month.rf'; %wrong muscle view
fullfilename=fullfile(inputPath,rfBasefilename);

%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV03\WA-HV-03-SDF\09-02-2011-MSK\WA-HV_03_38MM_SDF_TEST1.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV03\WA-HV-03-SDF\09-02-2011-MSK\WWA_HV_03_TEST2_SDF_38MM.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV03\WA-HV-03-SDF-60MM\09-02-2011-MSK\WA_HV_03_60MM_SDF_TEST1.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV03\WA-HV-03-SDF-60MM\09-02-2011-MSK\WA_HV_03_SDF_TEST2_60MM.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV04\04-09-2012-MSK\SD1.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV04\04-09-2012-MSK\SD2.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV05\SDF1.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV05\SDF2.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV05\SDFMM1.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV05\SDF60MM2.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV06\WAHV06_SDF1_38mm.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV06\WAHV06_SDF1_60mm.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV06\WAHV06_SDF2_60mm.rf' %extreme fast 9
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV07\SDF1_38mm.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV07\SDF2_38mm.rf'
%good fast
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV07\SDF1_60mm.rf'
%rfBasefilename='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV07\SDF2_60mm.rf' %too fast up/down
fullfilename=rfBasefilename;

dataBlockObj=DataBlockObj(fullfilename,@uread,'openArgs',[]);
dataBlockObj.open('cacheMethod','auto');
dataBlockObj.newProcessStream('agentLab',@(x) abs(x).^0.5, true);

%varargout = agentLab(dataBlockObj);
dataBlockObj.movie([]);

%% Make a movie example for tendon data
inputPath='D:\dataUltrasound\invivo_tendon\WalkAid Ultrasound\AF2\AF2\03-30-2010-MSKCV';
rfBasefilename='AF2_trail2.rf';
outputMovieFilename='tendon-slow.avi';
playbackFrameRate = 20;

inputPath='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV06';
rfBasefilename='WAHV06_SDF2_60mm.rf';
outputMovieFilename='tendon-fast.avi';
playbackFrameRate = 15;

inputPath='D:\dataUltrasound\invivo_tendon\Normal Patients\WAHV04\04-09-2012-MSK';
rfBasefilename='SD2.rf';
outputMovieFilename='tendon-fast-2.avi';
playbackFrameRate = 13;
%dataBlockObj.getUnitsValue('frameRate','framePerSec')

fullfilename=fullfile(inputPath,rfBasefilename);

dataBlockObj=DataBlockObj(fullfilename,@uread,'openArgs',[]);
dataBlockObj.open('cacheMethod','auto');
dataBlockObj.newProcessStream('agentLab',@(x) abs(x).^0.5, true);

fileCreationSettings ={outputMovieFilename,'w',playbackFrameRate,{'avi', 'Uncompressed AVI'},false};
dataBlockObj.movie([],fileCreationSettings);