%This needs to go into any processing script
% %*****SETUP PATHS for any startup programs************
% voodooCameraTrackerBinaryPath='C:\Program Files (x86)\voodoo camera tracker\bin';
% pathEnv=getenv('PATH');
% 
% if isempty(strfind(lower(pathEnv),lower(voodooCameraTrackerBinaryPath)))
%     pathEnv=[pathEnv ';' voodooCameraTrackerBinaryPath];
%     setenv('PATH',pathEnv);
% else
%     %do nothing
% end
% %*****************************************************

%This feature point generation method can create multiple feature point
%sets
metadata.track.method.fpt_cameraTrackerVoodoo.trackForward=true;
metadata.track.method.fpt_cameraTrackerVoodoo.trackBackward=true;
metadata.track.method.fpt_cameraTrackerVoodoo.skipImageCreate=[false false];
metadata.track.method.fpt_cameraTrackerVoodoo.trackerType='voodoo';

detection.name='harris';
detection.parameters.main.maxCorners=900;
detection.parameters.main.gaumaxCorners=0.70;
detection.parameters.main.relativeMinimum=1e-5;
detection.parameters.main.scaleFactor=0.04;
detection.parameters.additional.windowSizeForLocalMax=9;
detection.parameters.additional.derivativeGaussSigma=1.0;

correspondenceAnalysis.name='crossCorrelation';
correspondenceAnalysis.parameters.crossCorrelation.correlationConvFilterSize_xy=[15; 15];
correspondenceAnalysis.parameters.crossCorrelation.searchWindowsSizeX=[-10 10];
correspondenceAnalysis.parameters.crossCorrelation.searchWindowsSizeY=[-10 10];
correspondenceAnalysis.parameters.crossCorrelation.imageBorderSizeX=[10 10];
correspondenceAnalysis.parameters.crossCorrelation.imageBorderSizeY=[10 10];
correspondenceAnalysis.parameters.crossCorrelation.thresholdCorrValue=0.8;
correspondenceAnalysis.parameters.guidedMatching.type='Max1Repetition';
correspondenceAnalysis.parameters.guidedMatching.searchStri_pel=0.8;

metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(1).name='harrisCrosscorr';
metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(end).detection=detection;
metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;

correspondenceAnalysis=[];
correspondenceAnalysis.name='klt';
correspondenceAnalysis.parameters.klt.maxCorners=1000;
correspondenceAnalysis.parameters.klt.windowSizeForLocalMax=10;
correspondenceAnalysis.parameters.klt.searchRange=6;
correspondenceAnalysis.parameters.klt.minEigenValue=150;
correspondenceAnalysis.parameters.klt.minDeterminant=0.01;
correspondenceAnalysis.parameters.klt.minDisplacement=0.01;
correspondenceAnalysis.parameters.klt.maxIterations=10;
correspondenceAnalysis.parameters.klt.maxResidue=10;
correspondenceAnalysis.parameters.klt.psnr_db=30;
correspondenceAnalysis.parameters.klt.consistencyCheck='similarity mapping';

metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(end+1).name='harrisKlt';
metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(end).detection=detection;
metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;



detection.name='sift';
detection.parameters.scalesPerOctave=3;
detection.parameters.gaussianWindowSize=4;

correspondenceAnalysis=[];
correspondenceAnalysis.name='sift';
correspondenceAnalysis.parameters.siftMatching.nearMatchThreshold=0.6;
correspondenceAnalysis.parameters.siftMatching.windowSizeForLocalMax=10;
correspondenceAnalysis.parameters.guidedMatching.type='Max. 1 Repetition';
correspondenceAnalysis.parameters.guidedMatching.searchStrip_pel=0.8;
correspondenceAnalysis.parameters.guidedMatching.matchingThreshold=0.7;

metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(end+1).name='siftSift';
metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(end).detection=detection;
metadata.track.method.fpt_cameraTrackerVoodoo.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;

