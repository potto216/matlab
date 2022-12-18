%===============BASIC BMODE TRACKER=======================
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
fpt4={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt5={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt6={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt7={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_koseckaTracker',{tmpSrc}};

metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt4,fpt5,fpt6,fpt7,fpt8,fpt9}};

%commenting out because it is a duplicate with an earlier name
% %===============BASIC BMODE TRACKER=======================
% metadata.track.processStream(1).name='standardBModeManyFrames';
% metadata.track.processStream(end).sourceNode='col_ultrasound_bmode';
% metadata.track.processStream(end).filepath=[];
% metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
% metadata.track.processStream(end).filepath.root=metadata.track.name;
% metadata.track.processStream(end).filepath.relative='track\processStream';
% metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;
% 
% tmpSrc=metadata.track.processStream(end).sourceNode;
% fpt1={'fpt_correlationCorrespondenceFast',{tmpSrc}};
% fpt2={'fpt_correlationCorrespondenceSlow',{tmpSrc}};
% fpt3={'fpt_crosscorrOversampleFast',{tmpSrc}};
% fpt4={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
% fpt5={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
% fpt6={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
% fpt7={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
% fpt8={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
% fpt9={'fpt_koseckaTracker',{tmpSrc}};
% 
% metadata.track.processStream(end).stack={'tks_empty',{'tkl_frameMerge',fpt1,fpt2,fpt3,fpt4,fpt5,fpt6,fpt7,fpt8,fpt9}};

%===============BASIC FIELDII BMODE TRACKER=======================
metadata.track.processStream(end+1).name='standardFieldIIBMode';
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
fpt4={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt5={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt6={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt7={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_opencvFeatureDetectMultitrack_All',{tmpSrc}};
fpt10={'fpt_koseckaTracker',{tmpSrc}};
metadata.track.processStream(end).stack={'tks_empty',{'tkl_frameMerge',fpt1,fpt2,fpt3,fpt4,fpt5,fpt6,fpt7,fpt8,fpt9,fpt10}};


%===============BASIC PROJECTION TRACKER=======================
metadata.track.processStream(end+1).name='standardProjection';
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
fpt4={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt5={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt6={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt7={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_koseckaTracker',{tmpSrc}};
metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt4,fpt5,fpt6,fpt7,fpt8,fpt9}};


%===============BASIC RF TRACKER=======================
metadata.track.processStream(end+1).name='standardRF';
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
fpt4={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt5={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt6={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt7={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_koseckaTracker',{tmpSrc}};

metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt4,fpt5,fpt6,fpt7,fpt8,fpt9}};


%===============EXPERIMENTAL ACTIVE CONTOUR TRACKER=======================
metadata.track.processStream(end+1).name='standardBmodeWithOnlyActiveContour';
metadata.track.processStream(end).sourceNode='col_ultrasound_bmode';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;

tmpSrc=metadata.track.processStream(end).sourceNode;  %needed for the feature tracking methods below.

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

fpta1={'fpt_activeContourEdgeTrack_bottomRFBorder',{tmpSrc}};
fpta2={'fpt_activeContourEdgeTrack_topRFBorder',{tmpSrc}};
fpta3={'fpt_activeContourOpenSpline_bottomRFBorder',{tmpSrc}};
fpta4={'fpt_activeContourOpenSpline_topRFBorder',{tmpSrc}};

metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpta1,fpta2,fpta3,fpta4}};

%===============BASIC BMODE TRACKER=======================
metadata.track.processStream(end+1).name='standardBModeCrossCorrelation';
metadata.track.processStream(end).sourceNode='col_ultrasound_bmode';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;

tmpSrc=metadata.track.processStream(end).sourceNode;


fpt1={'fpt_crosscorrOversampleFast',{tmpSrc}};
fpt2={'fpt_crosscorrOversample_search13_template5',{tmpSrc}};
fpt3={'fpt_crosscorrOversample_search13_template11',{tmpSrc}};
fpt4={'fpt_crosscorrOversample_search19_template5',{tmpSrc}};
fpt5={'fpt_crosscorrOversample_search19_template11',{tmpSrc}};


metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2,fpt3,fpt4,fpt5}};

%===============Experimental BMODE TRACKER With New Tracklet Aggragator=======================
metadata.track.processStream(end+1).name='standardBMode_tkl_regionAll';
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
fpt4={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt5={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt6={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt7={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_koseckaTracker',{tmpSrc}};

metadata.track.processStream(end).stack={'tks_empty',{'tkl_regionAll',fpt1,fpt2,fpt3,fpt4,fpt5,fpt6,fpt7,fpt8,fpt9}};

%===============BMODE TRACKER=======================
metadata.track.processStream(end+1).name='standardBModeManyFrames';
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
fpt4={'fpt_correlationCorrespondencePyramidFast',{tmpSrc}};
fpt5={'fpt_opencvKeypointTrackOrb_opticalFlowPyrLK',{tmpSrc}};
fpt6={'fpt_opencvKeypointTrackHarris_opticalFlowPyrLK',{tmpSrc}};
fpt7={'fpt_opencvKeypointTrackGftt_opticalFlowPyrLK',{tmpSrc}};
fpt8={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
fpt9={'fpt_koseckaTracker',{tmpSrc}};

metadata.track.processStream(end).stack={'tks_empty',{'tkl_frameMerge',fpt1,fpt2,fpt3,fpt4,fpt5,fpt6,fpt7,fpt8,fpt9}};

%===============BMODE VERASONICS TRACKER=======================
metadata.track.processStream(end+1).name='standardVerasonics_v1';
metadata.track.processStream(end).sourceNode='col_ultrasound_bmode';
metadata.track.processStream(end).filepath=[];
metadata.track.processStream(end).filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.track.processStream(end).filepath.root=metadata.track.name;
metadata.track.processStream(end).filepath.relative='track\processStream';
metadata.track.processStream(end).filepath.relativeBranch=metadata.track.processStream(end).name;
tmpSrc=metadata.track.processStream(end).sourceNode;
fpt1={'fpt_correlationCorrespondenceFast',{tmpSrc}};
fpt2={'fpt_opencvKeypointTrackSift_opticalFlowPyrLK',{tmpSrc}};
metadata.track.processStream(end).stack={'tks_empty',{'tkl_empty',fpt1,fpt2}};