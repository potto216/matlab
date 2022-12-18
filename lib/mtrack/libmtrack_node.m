
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

metadata.track.node(end+1).name='fpt_crosscorrOversample_search13_template5';
metadata.track.node(end).object=@(x) x.track.method.fpt_crosscorrOversample;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.method.searchzsize_pel=13;  %How large the search window is
metadata.track.node(end).settings.method.searchxsize_pel=13;
metadata.track.node(end).settings.method.templatexseperation_pel=11;
metadata.track.node(end).settings.method.templatezseperation_pel=11;
metadata.track.node(end).settings.method.templatezsize_pel=5;
metadata.track.node(end).settings.method.templatexsize_pel=5;

metadata.track.node(end+1).name='fpt_crosscorrOversample_search13_template11';
metadata.track.node(end).object=@(x) x.track.method.fpt_crosscorrOversample;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.method.searchzsize_pel=13;  %method. is needed to 
metadata.track.node(end).settings.method.searchxsize_pel=13;
metadata.track.node(end).settings.method.templatexseperation_pel=11;
metadata.track.node(end).settings.method.templatezseperation_pel=11;
metadata.track.node(end).settings.method.templatezsize_pel=11;
metadata.track.node(end).settings.method.templatexsize_pel=11;

metadata.track.node(end+1).name='fpt_crosscorrOversample_search19_template5';
metadata.track.node(end).object=@(x) x.track.method.fpt_crosscorrOversample;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.method.searchzsize_pel=19;  %method. is needed to 
metadata.track.node(end).settings.method.searchxsize_pel=19;
metadata.track.node(end).settings.method.templatexseperation_pel=11;
metadata.track.node(end).settings.method.templatezseperation_pel=11;
metadata.track.node(end).settings.method.templatezsize_pel=5;
metadata.track.node(end).settings.method.templatexsize_pel=5;

metadata.track.node(end+1).name='fpt_crosscorrOversample_search19_template11';
metadata.track.node(end).object=@(x) x.track.method.fpt_crosscorrOversample;
metadata.track.node(end).skip=featurePointTrackSkip;
metadata.track.node(end).settings.trim.border_rc=[];
metadata.track.node(end).settings.method.searchzsize_pel=19;  %method. is needed to 
metadata.track.node(end).settings.method.searchxsize_pel=19;
metadata.track.node(end).settings.method.templatexseperation_pel=11;
metadata.track.node(end).settings.method.templatezseperation_pel=11;
metadata.track.node(end).settings.method.templatezsize_pel=11;
metadata.track.node(end).settings.method.templatexsize_pel=11;


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


metadata.track.node(end+1).name='tkl_frameMerge';
metadata.track.node(end).object=@(x) x.track.method.tkl_frameMerge;
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

