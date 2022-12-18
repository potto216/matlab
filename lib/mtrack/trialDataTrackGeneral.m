warning ('This is outdated. using the lib* instead');
libmtrack_method
libmtrack_node
libmtrack_processstream
return
%************************************
%*******Tracking Information*********
%************************************
%Normally for tracking collection results will fall under a relativeBranch
%that has the name of the collection such as fieldII or rf.  Under this
%collection name the methods for tracking are applied.  One branching
%option is to have 
%1. <methodName>/<subType> such as ./featurePoint/klt_Harris
%2. <methodName>/<subType> such as ./trackletStitching/largeregion
% 4.	Track
% 4.1.	Tracking output name
% 4.1.1.	Data linking
% 4.1.1.1.	Simulation phantom name or Subject name
% 4.1.1.2.	Motion model name
% 4.1.1.3.	Image formation name
% 4.1.2.	Tracking Technique 1
% 4.1.3.	Tracking Technique 2
%
%RULES for 'fpt_opencvKeypointTrack','fpt_opencvFeatureDetectMultitrack'
%are that the track package name must be in the form
%[<featureDetectName>_<correspondenceTrack>] where the '_' is only used as
%a token seperator
metadata.track.name=caseName;
metadata.track.method.col_ultrasound_bmode.source=@(x) x.collection.ultrasound.bmode;
metadata.track.method.col_ultrasound_rf.source=@(x) x.collection.ultrasound.rf;

metadata.track.method.col_ultrasound_fieldii_bmode.source=@(x) x.collection.fieldii.bmode;

metadata.track.method.col_projection.source=@(x) x.collection.projection;

%**************INCLUDE VOODOO TRACKING*******************
trialDataTrackGeneralVoodoo
%**************INCLUDE VOODOO TRACKING*******************

detection.name='sift';
detection.parameters.type='SIFT';  %must be upper case for opencv
correspondenceAnalysis.name='opticalFlowPyrLK';
correspondenceAnalysis.parameters=[];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;

detection.name='gftt';
detection.parameters.type='GFTT';  %must be upper case for opencv
correspondenceAnalysis.name='opticalFlowPyrLK';
correspondenceAnalysis.parameters=[];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end+1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;

detection.name='harris';
detection.parameters.type='HARRIS';  %must be upper case for opencv
correspondenceAnalysis.name='opticalFlowPyrLK';
correspondenceAnalysis.parameters=[];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end+1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;


detection.name='orb';
detection.parameters.type='ORB';  %must be upper case for opencv
correspondenceAnalysis.name='opticalFlowPyrLK';
correspondenceAnalysis.parameters=[];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end+1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;
metadata.track.method.fpt_opencvKeypointTrack.trackForward=true;
metadata.track.method.fpt_opencvKeypointTrack.trackBackward=true;


correlationCorrespondence=[];
        % The size of the patches on which the variance is computed when
        % automatic feature finding is used. Must be set to an odd integer.
correlationCorrespondence.featurePatchSize=5;

        % Search patch size
        % The size of the patch from IMAGE1 which is correlated with
        % IMAGE2. Must be set to an odd integer.

correlationCorrespondence.searchPatchSize=11;

        % Defines the search region of IMAGE2 within which the patch from IMAGE1
        % is correlated. Must be set to a vector of the form [XDMIN XDMAX
        % YDMIN YDMAX]. The elements represent the limits to the offset
        % between a feature in IMAGE1 and its match in IMAGE2.
        %The correlation correspondence requires integers only so you need
        %round.
correlationCorrespondence.searchBox = round([ ...
    -tmp.lateral.maxSpeed_pelPerFrame tmp.lateral.maxSpeed_pelPerFrame ...
    -tmp.axial.maxSpeed_pelPerFrame tmp.axial.maxSpeed_pelPerFrame]);
detection.name='sift';
detection.parameters.type='SIFT';  %must be upper case for opencv
correspondenceAnalysis.name='correlationCorrespondence';
correspondenceAnalysis.parameters=correlationCorrespondence;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end+1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;

detection.name='gftt';
detection.parameters.type='GFTT';  %must be upper case for opencv
correspondenceAnalysis.name='correlationCorrespondence';
correspondenceAnalysis.parameters=correlationCorrespondence;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end+1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;

detection.name='harris';
detection.parameters.type='HARRIS';  %must be upper case for opencv
correspondenceAnalysis.name='correlationCorrespondence';
correspondenceAnalysis.parameters=correlationCorrespondence;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end+1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;


detection.name='orb';
detection.parameters.type='ORB';  %must be upper case for opencv
correspondenceAnalysis.name='correlationCorrespondence';
correspondenceAnalysis.parameters=correlationCorrespondence;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end+1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;
metadata.track.method.fpt_opencvKeypointTrack.trackForward=true;
metadata.track.method.fpt_opencvKeypointTrack.trackBackward=true;

%***********************SETTINGS FOR THE OPENCV MULTILIST ALGORITHM***************
metadata.track.method.fpt_opencvFeatureDetectMultitrack.trackPackage=metadata.track.method.fpt_opencvKeypointTrack.trackPackage;
metadata.track.method.fpt_opencvFeatureDetectMultitrack.trackForward=true;
metadata.track.method.fpt_opencvFeatureDetectMultitrack.trackBackward=true;

%***********************SETTINGS FOR CORRELATION ALGORITHM***************
        % The size of the patches on which the variance is computed when
        % automatic feature finding is used. Must be set to an odd integer.
metadata.track.method.fpt_correlationCorrespondence.featurePatchSize=5;

        % Search patch size
        % The size of the patch from IMAGE1 which is correlated with
        % IMAGE2. Must be set to an odd integer.

metadata.track.method.fpt_correlationCorrespondence.searchPatchSize=11;

        % Defines the search region of IMAGE2 within which the patch from IMAGE1
        % is correlated. Must be set to a vector of the form [XDMIN XDMAX
        % YDMIN YDMAX]. The elements represent the limits to the offset
        % between a feature in IMAGE1 and its match in IMAGE2.
        %The correlation correspondence requires integers only so you need
        %round.
metadata.track.method.fpt_correlationCorrespondence.searchBox = round([ ...
    -tmp.lateral.maxSpeed_pelPerFrame tmp.lateral.maxSpeed_pelPerFrame ...
    -tmp.axial.maxSpeed_pelPerFrame tmp.axial.maxSpeed_pelPerFrame]);


metadata.track.method.fpt_correlationCorrespondence.trackForward=true;
metadata.track.method.fpt_correlationCorrespondence.trackBackward=true;

%***********************SETTINGS FOR CORRELATION PYRAMID ALGORITHM***************
        % The size of the patches on which the variance is computed when
        % automatic feature finding is used. Must be set to an odd integer.
metadata.track.method.fpt_correlationCorrespondencePyramid.featurePatchSize=5;

        % Search patch size
        % The size of the patch from IMAGE1 which is correlated with
        % IMAGE2. Must be set to an odd integer.

metadata.track.method.fpt_correlationCorrespondencePyramid.searchPatchSize=11;

        % Defines the search region of IMAGE2 within which the patch from IMAGE1
        % is correlated. Must be set to a vector of the form [XDMIN XDMAX
        % YDMIN YDMAX]. The elements represent the limits to the offset
        % between a feature in IMAGE1 and its match in IMAGE2.
        %The correlation correspondence requires integers only so you need
        %round.
metadata.track.method.fpt_correlationCorrespondencePyramid.searchBox = round([ ...
    -tmp.lateral.maxSpeed_pelPerFrame*2 tmp.lateral.maxSpeed_pelPerFrame*2 ...
    -tmp.axial.maxSpeed_pelPerFrame*2 tmp.axial.maxSpeed_pelPerFrame*2]);


metadata.track.method.fpt_correlationCorrespondencePyramid.trackForward=true;
metadata.track.method.fpt_correlationCorrespondencePyramid.trackBackward=true;

metadata.track.method.fpt_correlationCorrespondencePyramid.reductionFactor=2;


%*************************************************************************
%********SETTINGS FOR OVERSAMPLED MOTION FIELD CORRELATION ALGORITHM******
metadata.track.method.fpt_crosscorrOversample.searchzsize_pel=21;
metadata.track.method.fpt_crosscorrOversample.searchxsize_pel=21;

metadata.track.method.fpt_crosscorrOversample.templatezsize_pel=11;
metadata.track.method.fpt_crosscorrOversample.templatexsize_pel=11;

metadata.track.method.fpt_crosscorrOversample.trackForward=true;
metadata.track.method.fpt_crosscorrOversample.trackBackward=true;


%*************************************************************************
%********SETTINGS FOR DENSE OPTICAL FLOW FIELD USING FARNEBACK************

metadata.track.method.fpt_opencvOpticalFlowFarneback.trackForward=true;
metadata.track.method.fpt_opencvOpticalFlowFarneback.trackBackward=true;

%***************************************************************************************************
%********SETTINGS FOR FEATURE POINT TRACKER USED BY DR. KOSECKA THAT HAS QUALITY MEASURES************
metadata.track.method.fpt_koseckaTracker.trackForward=true;
metadata.track.method.fpt_koseckaTracker.trackBackward=true;

%***************************************************************************************************
%********SETTINGS FOR THE ACTIVe CONTOUR METHODS************
metadata.track.method.fpt_activeContourEdgeTrack.trackForward=true;
metadata.track.method.fpt_activeContourEdgeTrack.trackBackward=true;

metadata.track.method.fpt_activeContourOpenSpline.trackForward=true;
metadata.track.method.fpt_activeContourOpenSpline.trackBackward=true;

%***********************************************
%********SETTINGS FOR TRACKLET ALGORITHMS*******
%***********************************************
metadata.track.method.tkl_empty=[];

metadata.track.method.tkl_regionAll=[];
metadata.track.method.tkl_regionAll.minBorderDistance_pel=2;
metadata.track.method.tkl_regionAll.badColumns=badColumn;
metadata.track.method.tkl_regionAll.imErodeStrel=@() strel('square',7);


%***********************************************
%********SETTINGS FOR TRACKLET STITCHING*******
%***********************************************
metadata.track.method.tks_empty=[];
metadata.track.method.tks_basic=[];

%*******************************************************
featurePointTrackSkip=false; %****THE SKIP***************
%*******************************************************

metadata.track.node(1).name='col_ultrasound_bmode';
metadata.track.node(end).object=@(x) x.track.method.col_ultrasound_bmode;

metadata.track.node(end+1).name='col_ultrasound_rf';
metadata.track.node(end).object=@(x) x.track.method.col_ultrasound_rf;

metadata.track.node(end+1).name='col_ultrasound_fieldii_bmode';
metadata.track.node(end).object=@(x) x.track.method.col_ultrasound_fieldii_bmode;

metadata.track.node(end+1).name='col_projection';
metadata.track.node(end).object=@(x) x.track.method.col_projection;

metadata.track.node(end+1).name='fpt_correlationCorrespondenceFast';
metadata.track.node(end).object=@(x) x.track.method.fpt_correlationCorrespondence;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.method.forward=@(x) true;
metadata.track.node(end).settings.trim.border_rc=[];

metadata.track.node(end+1).name='fpt_correlationCorrespondenceSlow';
metadata.track.node(end).object=@(x) x.track.method.fpt_correlationCorrespondence;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.method.searchBox=@(x) [-15 15 -15 15];
metadata.track.node(end).settings.trim.border_rc=[];

metadata.track.node(end+1).name='fpt_correlationCorrespondencePyramidFast';
metadata.track.node(end).object=@(x) x.track.method.fpt_correlationCorrespondencePyramid;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc=[];


metadata.track.node(end+1).name='fpt_crosscorrOversampleFast';
metadata.track.node(end).object=@(x) x.track.method.fpt_crosscorrOversample;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc=[];


% metadata.track.node(end+1).name='fpt_cameraTrackerVoodooHarrisCrosscorr';
% metadata.track.node(end).object=@(x) x.track.method.fpt_cameraTrackerVoodoo;
% metadata.track.node(end).trackPackageName='harrisCrosscorr';
% metadata.track.node(end).skip=true;
% 
% metadata.track.node(end+1).name='fpt_cameraTrackerVoodooHarrisKlt';
% metadata.track.node(end).object=@(x) x.track.method.fpt_cameraTrackerVoodoo;
% metadata.track.node(end).trackPackageName='harrisKlt';
% metadata.track.node(end).skip=true;
% 
% metadata.track.node(end+1).name='fpt_cameraTrackerVoodooSiftSift';
% metadata.track.node(end).object=@(x) x.track.method.fpt_cameraTrackerVoodoo;
% metadata.track.node(end).trackPackageName='siftSift';
% metadata.track.node(end).skip=true;
% metadata.track.node(end).settings.method.skipImageCreate=@(x) [false false];
% 
%************************************************
metadata.track.node(end+1).name='fpt_opencvKeypointTrackSift_opticalFlowPyrLK';
metadata.track.node(end).object=@(x) x.track.method.fpt_opencvKeypointTrack;
metadata.track.node(end).trackPackageName='sift_opticalFlowPyrLK';
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc={'trimBlack'};

metadata.track.node(end+1).name='fpt_opencvKeypointTrackGftt_opticalFlowPyrLK';
metadata.track.node(end).object=@(x) x.track.method.fpt_opencvKeypointTrack;
metadata.track.node(end).trackPackageName='gftt_opticalFlowPyrLK';
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc={'trimBlack'};

metadata.track.node(end+1).name='fpt_opencvKeypointTrackHarris_opticalFlowPyrLK';
metadata.track.node(end).object=@(x) x.track.method.fpt_opencvKeypointTrack;
metadata.track.node(end).trackPackageName='harris_opticalFlowPyrLK';
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc={'trimBlack'};

metadata.track.node(end+1).name='fpt_opencvKeypointTrackOrb_opticalFlowPyrLK';
metadata.track.node(end).object=@(x) x.track.method.fpt_opencvKeypointTrack;
metadata.track.node(end).trackPackageName='orb_opticalFlowPyrLK';
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc={'trimBlack'};
%************************************************

activeTrackPackageNameList={'sift_correlationCorrespondence', 'sift_opticalFlowPyrLK', 'gftt_opticalFlowPyrLK', 'harris_opticalFlowPyrLK', 'orb_opticalFlowPyrLK', ...
 'gftt_correlationCorrespondence', 'harris_correlationCorrespondence', 'orb_correlationCorrespondence'};

metadata.track.node(end+1).name='fpt_opencvFeatureDetectMultitrack_All';
metadata.track.node(end).object=@(x) x.track.method.fpt_opencvFeatureDetectMultitrack;
metadata.track.node(end).activeTrackPackageNameList=activeTrackPackageNameList;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc=[];

metadata.track.node(end+1).name='fpt_opencvOpticalFlowFarneback';
metadata.track.node(end).object=@(x) x.track.method.fpt_opencvOpticalFlowFarneback;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.trim.border_rc=[];

metadata.track.node(end+1).name='fpt_koseckaTracker';
metadata.track.node(end).object=@(x) x.track.method.fpt_koseckaTracker;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.trim.border_rc=[];

metadata.track.node(end+1).name='fpt_activeContourEdgeTrack';
metadata.track.node(end).object=@(x) x.track.method.fpt_activeContourEdgeTrack;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.trackLimit=[-inf inf];
metadata.track.node(end).settings.trackLimitMethod={};
metadata.track.node(end).settings.agentToTrack='bottomRFBorder';

metadata.track.node(end+1).name='fpt_activeContourOpenSpline';
metadata.track.node(end).object=@(x) x.track.method.fpt_activeContourOpenSpline;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.trackLimit=[-inf inf];
metadata.track.node(end).settings.trackLimitMethod={};
metadata.track.node(end).settings.agentToTrack='bottomRFBorder';

metadata.track.node(end+1).name='tkl_empty';
metadata.track.node(end).object=@(x) x.track.method.tkl_empty;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings=[];


metadata.track.node(end+1).name='tkl_regionAll';
metadata.track.node(end).object=@(x) x.track.method.tkl_regionAll;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings=[];


metadata.track.node(end+1).name='tkl_regionAll_rf';
metadata.track.node(end).object=@(x) x.track.method.tkl_regionAll;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.method.minBorderDistance_pel=[];
metadata.track.node(end).settings.method.badColumns=[];
metadata.track.node(end).settings.method.imErodeStrel=[];


metadata.track.node(end+1).name='tks_empty';
metadata.track.node(end).object=@(x) x.track.method.tks_empty;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings=[];

metadata.track.node(end+1).name='tks_basic';
metadata.track.node(end).object=@(x) x.track.method.tks_basic;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings=[];

metadata.track.node(end+1).name='fpt_activeContourEdgeTrack_bottomRFBorder';
metadata.track.node(end).object=@(x) x.track.method.fpt_activeContourEdgeTrack;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.trackLimit=[-inf inf];
metadata.track.node(end).settings.trackLimitMethod={};
metadata.track.node(end).settings.brightRegionPosition='auto';
metadata.track.node(end).settings.agentToTrack='bottomRFBorder';

metadata.track.node(end+1).name='fpt_activeContourEdgeTrack_topRFBorder';
metadata.track.node(end).object=@(x) x.track.method.fpt_activeContourEdgeTrack;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.trackLimit=[-inf inf];
metadata.track.node(end).settings.trackLimitMethod={};
metadata.track.node(end).settings.brightRegionPosition='auto';
metadata.track.node(end).settings.agentToTrack='topRFBorder';

metadata.track.node(end+1).name='fpt_activeContourOpenSpline_bottomRFBorder';
metadata.track.node(end).object=@(x) x.track.method.fpt_activeContourOpenSpline;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.trackLimit=[-inf inf];
metadata.track.node(end).settings.trackLimitMethod={};
metadata.track.node(end).settings.brightRegionPosition='auto';
metadata.track.node(end).settings.agentToTrack='bottomRFBorder';

metadata.track.node(end+1).name='fpt_activeContourOpenSpline_topRFBorder';
metadata.track.node(end).object=@(x) x.track.method.fpt_activeContourOpenSpline;
metadata.track.node(end).skip=false;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.trackLimit=[-inf inf];
metadata.track.node(end).settings.trackLimitMethod={};
metadata.track.node(end).settings.brightRegionPosition='auto';
metadata.track.node(end).settings.agentToTrack='topRFBorder';



%------------------------------------standardBMode----------------------------------------------------
metadata.track.processStream(1).name='standardBMode';
metadata.track.processStream(end).sourceNode='col_ultrasound_bmode';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;

tmpSrc=metadata.track.processStream(end).sourceNode;
fpt1={'fpt_correlationCorrespondenceFast',{tmpSrc}};
fpt2={'fpt_correlationCorrespondenceSlow',{tmpSrc}};
fpt3={'fpt_crosscorrOversampleFast',{tmpSrc}};
%fpt4={'fpt_cameraTrackerVoodooHarrisCrosscorr',{tmpSrc}};
%fpt5={'fpt_cameraTrackerVoodooHarrisKlt',{tmpSrc}};
%fpt6={'fpt_cameraTrackerVoodooSiftSift',{tmpSrc}};
fpt7={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt10={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt11={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
%fpt12={'fpt_opencvFeatureDetectMultitrack_All',{tmpSrc}};
fpt13={'fpt_koseckaTracker',{tmpSrc}};

%metadata.track.processStream(end).stack={'tks_basic',{'tkl_regionAll',fpt12,fpt1,fpt2,fpt3,fpt7,fpt8,fpt9,fpt10,fpt11}};
metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt7,fpt8,fpt9,fpt10,fpt11,fpt13}};


%------------------------------------standardFieldIIBMode----------------------------------------------------
metadata.track.processStream(2).name='standardFieldIIBMode';
metadata.track.processStream(end).sourceNode='col_ultrasound_fieldii_bmode';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;
tmpSrc=metadata.track.processStream(end).sourceNode;

fpt1={'fpt_correlationCorrespondenceFast',{tmpSrc}};
fpt2={'fpt_correlationCorrespondenceSlow',{tmpSrc}};
fpt3={'fpt_crosscorrOversampleFast',{tmpSrc}};
%fpt4={'fpt_cameraTrackerVoodooHarrisCrosscorr',{tmpSrc}};
%fpt5={'fpt_cameraTrackerVoodooHarrisKlt',{tmpSrc}};
%fpt6={'fpt_cameraTrackerVoodooSiftSift',{tmpSrc}};
fpt7={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt10={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt11={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
%fpt12={'fpt_opencvFeatureDetectMultitrack_All',{tmpSrc}};
fpt13={'fpt_koseckaTracker',{tmpSrc}};
metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt7,fpt8,fpt9,fpt10,fpt11,fpt13}};


%------------------------------------standardProjection----------------------------------------------------
metadata.track.processStream(3).name='standardProjection';
metadata.track.processStream(end).sourceNode='col_projection';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;
tmpSrc=metadata.track.processStream(end).sourceNode;
fpt1={'fpt_correlationCorrespondenceFast',{tmpSrc}};
fpt2={'fpt_correlationCorrespondenceSlow',{tmpSrc}};
fpt3={'fpt_crosscorrOversampleFast',{tmpSrc}};
% fpt4={'fpt_cameraTrackerVoodooHarrisCrosscorr',{tmpSrc}};
% fpt5={'fpt_cameraTrackerVoodooHarrisKlt',{tmpSrc}};
% fpt6={'fpt_cameraTrackerVoodooSiftSift',{tmpSrc}};
fpt7={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt10={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt11={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
%fpt12={'fpt_opencvFeatureDetectMultitrack_All',{tmpSrc}};
fpt13={'fpt_koseckaTracker',{tmpSrc}};
metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt7,fpt8,fpt9,fpt10,fpt11,fpt13}};


%------------------------------------standardRF----------------------------------------------------
metadata.track.processStream(4).name='standardRF';
metadata.track.processStream(end).sourceNode='col_ultrasound_rf';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;
tmpSrc=metadata.track.processStream(end).sourceNode;
fpt1={'fpt_correlationCorrespondenceFast',{tmpSrc}};
fpt2={'fpt_correlationCorrespondenceSlow',{tmpSrc}};
fpt3={'fpt_crosscorrOversampleFast',{tmpSrc}};
%fpt4={'fpt_cameraTrackerVoodooHarrisCrosscorr',{tmpSrc}};
%fpt5={'fpt_cameraTrackerVoodooHarrisKlt',{tmpSrc}};
%fpt6={'fpt_cameraTrackerVoodooSiftSift',{tmpSrc}};
fpt7={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt10={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt11={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
%fpt12={'fpt_opencvFeatureDetectMultitrack_All',{tmpSrc}};
fpt13={'fpt_koseckaTracker',{tmpSrc}};

metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt7,fpt8,fpt9,fpt10,fpt11,fpt13}};
%metadata.track.processStream(end).stack={'tks_basic',{'tkl_regionAll_rf',fpt1,fpt2,fpt3,fpt7,fpt8,fpt9,fpt10,fpt11,fpt12}};
%metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt7,fpt8,fpt9,fpt10,fpt11,fpt12}};

%------------------------------------standardBmodeWithOnlyActiveContour----------------------------------------------------
metadata.track.processStream(end+1).name='standardBmodeWithOnlyActiveContour';
metadata.track.processStream(end).sourceNode='col_ultrasound_bmode';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;

tmpSrc=metadata.track.processStream(end).sourceNode;  %needed for the feature tracking methods below.

fpta1={'fpt_activeContourEdgeTrack_bottomRFBorder',{tmpSrc}};
fpta2={'fpt_activeContourEdgeTrack_topRFBorder',{tmpSrc}};
fpta3={'fpt_activeContourOpenSpline_bottomRFBorder',{tmpSrc}};
fpta4={'fpt_activeContourOpenSpline_topRFBorder',{tmpSrc}};

metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpta1,fpta2,fpta3,fpta4}};

%------------------------------------standardVerasonics----------------------------------------------------
metadata.track.processStream(end+1).name='standardVerasonics_v1';
metadata.track.processStream(end).sourceNode='col_verasonics_v1';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;
tmpSrc=metadata.track.processStream(end).sourceNode;
fpt1={'fpt_correlationCorrespondenceFast',{tmpSrc}};
fpt2={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2}};
