
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

detection.name='sift';
detection.parameters.type='SIFT';  %must be upper case for opencv
correspondenceAnalysis.name='opticalFlowPyrLK';
correspondenceAnalysis.parameters=[];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;

detection.name='gftt';
detection.parameters.type='GFTTDetector';  %must be upper case for opencv. The old name in OpenCV 2.X was just GFTT
correspondenceAnalysis.name='opticalFlowPyrLK';
correspondenceAnalysis.parameters=[];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end+1).name=[detection.name '_' correspondenceAnalysis.name];
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).detection=detection;
metadata.track.method.fpt_opencvKeypointTrack.trackPackage(end).correspondenceAnalysis=correspondenceAnalysis;

detection.name='harris';
detection.parameters.type='HarrisLaplaceFeatureDetector';  %must be upper case for opencv. The old name in opencv 2.X was just HARRIS
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

metadata.track.method.tkl_frameMerge=[];

metadata.track.method.tkl_regionAll=[];
metadata.track.method.tkl_regionAll.minBorderDistance_pel=2;
metadata.track.method.tkl_regionAll.badColumns=badColumn;
metadata.track.method.tkl_regionAll.imErodeStrel=@() strel('square',7);




%***********************************************
%********SETTINGS FOR TRACKLET STITCHING*******
%***********************************************
metadata.track.method.tks_empty=[];
metadata.track.method.tks_basic=[];

