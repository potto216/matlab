%********************start loadTrackDataSettingsManual.m****************************
function trackData=loadTrackDataSettingsManual
trackType='cmm_track_none_30by100';

%AF2Trial2
trackData.AF2Trial2(1).calibrateFilename=['AF2Trial2_trackFile_rf_' trackType '.mat'];
trackData.AF2Trial2(1).scaleMax=1.0856;
trackData.AF2Trial2(1).timeOffsetMotionCaptureToTrack_sec=-4.325;
trackData.AF2Trial2(1).notes='Good track.';
trackData.AF2Trial2(1).inlinerMotionCaptureRFTrack=[];
trackData.AF2Trial2(1).maxSearchLagForOptimum_sample=[];
 
%AF2Trial3
trackData.AF2Trial3(1).calibrateFilename=['AF2Trial3_trackFile_rf_' trackType '.mat'];
trackData.AF2Trial3(1).scaleMax=0.472;
trackData.AF2Trial3(1).timeOffsetMotionCaptureToTrack_sec=-0.125;
trackData.AF2Trial3(1).notes='Good track some outliers.';
trackData.AF2Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.AF2Trial3(1).maxSearchLagForOptimum_sample=[];
 
%AN2Trial50
trackData.AN2Trial50(1).calibrateFilename=['AN2Trial50_trackFile_rf_' trackType '.mat'];
trackData.AN2Trial50(1).scaleMax=-0.472;
trackData.AN2Trial50(1).timeOffsetMotionCaptureToTrack_sec=-1.4762;
trackData.AN2Trial50(1).notes='not very good.';
trackData.AN2Trial50(1).inlinerMotionCaptureRFTrack=[];
trackData.AN2Trial50(1).maxSearchLagForOptimum_sample=[]; %Override 0;
 
% %AN2Trial51
% trackData.AN2Trial51(1).calibrateFilename=['AN2Trial51_trackFile_rf_' trackType '.mat'];
% trackData.AN2Trial51(1).scaleMax=2.832;
% trackData.AN2Trial51(1).timeOffsetMotionCaptureToTrack_sec=-2.4286;
% trackData.AN2Trial51(1).notes='not very good.';
% trackData.AN2Trial51(1).inlinerMotionCaptureRFTrack=[];
% trackData.AN2Trial51(1).maxSearchLagForOptimum_sample=0;

% %AN2Trial51 repaired
trackData.AN2Trial51(1).calibrateFilename=['AN2Trial51_trackFile_rf_' trackType '.mat'];
trackData.AN2Trial51(1).scaleMax=-0.472;
trackData.AN2Trial51(1).timeOffsetMotionCaptureToTrack_sec=-1.873;
trackData.AN2Trial51(1).notes='not very good.';
trackData.AN2Trial51(1).inlinerMotionCaptureRFTrack=[];
trackData.AN2Trial51(1).maxSearchLagForOptimum_sample=[]; %Override 0;
 
%CT2Trial60
trackData.CT2Trial60(1).calibrateFilename=['CT2Trial60_trackFile_rf_' trackType '.mat'];
trackData.CT2Trial60(1).scaleMax=-1.888;
trackData.CT2Trial60(1).timeOffsetMotionCaptureToTrack_sec=-2.1;
trackData.CT2Trial60(1).notes='good track.';
trackData.CT2Trial60(1).inlinerMotionCaptureRFTrack=[];
trackData.CT2Trial60(1).maxSearchLagForOptimum_sample=[];
 
%CT2Trial61
trackData.CT2Trial61(1).calibrateFilename=['CT2Trial61_trackFile_rf_' trackType '.mat'];
trackData.CT2Trial61(1).scaleMax=-0.944;
trackData.CT2Trial61(1).timeOffsetMotionCaptureToTrack_sec=-1.3571;
trackData.CT2Trial61(1).notes='good track.';
trackData.CT2Trial61(1).inlinerMotionCaptureRFTrack=[];
trackData.CT2Trial61(1).maxSearchLagForOptimum_sample=[];
 
%CT2Trial62
trackData.CT2Trial62(1).calibrateFilename=['CT2Trial62_trackFile_rf_' trackType '.mat'];
trackData.CT2Trial62(1).scaleMax=-0.944;
trackData.CT2Trial62(1).timeOffsetMotionCaptureToTrack_sec=-2.3286;
trackData.CT2Trial62(1).notes='track not so good.';
trackData.CT2Trial62(1).inlinerMotionCaptureRFTrack=[];
trackData.CT2Trial62(1).maxSearchLagForOptimum_sample=[];
 
%DP2Trial2
trackData.DP2Trial2(1).calibrateFilename=['DP2Trial2_trackFile_rf_' trackType '.mat'];
trackData.DP2Trial2(1).scaleMax=-0.472;
trackData.DP2Trial2(1).timeOffsetMotionCaptureToTrack_sec=-2.6714;
trackData.DP2Trial2(1).notes='noisy track not very good';
trackData.DP2Trial2(1).inlinerMotionCaptureRFTrack=[];
trackData.DP2Trial2(1).maxSearchLagForOptimum_sample=[];
 
%DP2Trial3
trackData.DP2Trial3(1).calibrateFilename=['DP2Trial3_trackFile_rf_' trackType '.mat'];
trackData.DP2Trial3(1).scaleMax=-0.236;
trackData.DP2Trial3(1).timeOffsetMotionCaptureToTrack_sec=-2.7143;
trackData.DP2Trial3(1).notes='Almost no motion.  noisy track not very good';
trackData.DP2Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.DP2Trial3(1).maxSearchLagForOptimum_sample=[];
 
%DP2Trial4
trackData.DP2Trial4(1).calibrateFilename=['DP2Trial4_trackFile_rf_' trackType '.mat'];
trackData.DP2Trial4(1).scaleMax=-0.236;
trackData.DP2Trial4(1).timeOffsetMotionCaptureToTrack_sec=-2.7143;
trackData.DP2Trial4(1).notes='Almost no motion.  noisy track not very good';
trackData.DP2Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.DP2Trial4(1).maxSearchLagForOptimum_sample=[];
 
%DW2Trial62
trackData.DW2Trial62(1).calibrateFilename=['DW2Trial62_trackFile_rf_' trackType '.mat'];
trackData.DW2Trial62(1).scaleMax=-0.472;
trackData.DW2Trial62(1).timeOffsetMotionCaptureToTrack_sec=0.35;
trackData.DW2Trial62(1).notes='Almost no motion.  noisy track not very good';
trackData.DW2Trial62(1).inlinerMotionCaptureRFTrack=[];
trackData.DW2Trial62(1).maxSearchLagForOptimum_sample=[];
 
%DW2Trial63
trackData.DW2Trial63(1).calibrateFilename=['DW2Trial63_trackFile_rf_' trackType '.mat'];
trackData.DW2Trial63(1).scaleMax=-0.472;
trackData.DW2Trial63(1).timeOffsetMotionCaptureToTrack_sec=-0.375;
trackData.DW2Trial63(1).notes='Almost no motion.  noisy track not very good';
trackData.DW2Trial63(1).inlinerMotionCaptureRFTrack=[];
trackData.DW2Trial63(1).maxSearchLagForOptimum_sample=[];

%ES2Trial50
trackData.ES2Trial50(1).calibrateFilename=[''];
trackData.ES2Trial50(1).scaleMax=[];
trackData.ES2Trial50(1).timeOffsetMotionCaptureToTrack_sec=[];
trackData.ES2Trial50(1).notes='No motion track data';
trackData.ES2Trial50(1).inlinerMotionCaptureRFTrack=[];
trackData.ES2Trial50(1).maxSearchLagForOptimum_sample=[];

%ES2Trial53
trackData.ES2Trial53(1).calibrateFilename=['ES2Trial53_trackFile_rf_' trackType '.mat'];
trackData.ES2Trial53(1).scaleMax=-0.472;
trackData.ES2Trial53(1).timeOffsetMotionCaptureToTrack_sec=-1.5714;
trackData.ES2Trial53(1).notes='noisy track not very good';
trackData.ES2Trial53(1).inlinerMotionCaptureRFTrack=[];
trackData.ES2Trial53(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%ES2Trial54
trackData.ES2Trial54(1).calibrateFilename=['ES2Trial54_trackFile_rf_' trackType '.mat'];
trackData.ES2Trial54(1).scaleMax=-0.236;
trackData.ES2Trial54(1).timeOffsetMotionCaptureToTrack_sec=-2.5286;
trackData.ES2Trial54(1).notes='noisy, but some clustering';
trackData.ES2Trial54(1).inlinerMotionCaptureRFTrack=[];
trackData.ES2Trial54(1).maxSearchLagForOptimum_sample=[];

%GA2Trial21
trackData.GA2Trial21(1).calibrateFilename=['GA2Trial21_trackFile_rf_' trackType '.mat'];
trackData.GA2Trial21(1).scaleMax=-2.596;
trackData.GA2Trial21(1).timeOffsetMotionCaptureToTrack_sec=-0.375;
trackData.GA2Trial21(1).notes='pretty good';
trackData.GA2Trial21(1).inlinerMotionCaptureRFTrack=[];
trackData.GA2Trial21(1).maxSearchLagForOptimum_sample=[]; 

%GA2Trial22
trackData.GA2Trial22(1).calibrateFilename=['GA2Trial22_trackFile_rf_' trackType '.mat'];
trackData.GA2Trial22(1).scaleMax=-3.54;
trackData.GA2Trial22(1).timeOffsetMotionCaptureToTrack_sec=-2.225;
trackData.GA2Trial22(1).notes='some outliers';
trackData.GA2Trial22(1).inlinerMotionCaptureRFTrack=[];
trackData.GA2Trial22(1).maxSearchLagForOptimum_sample=[];

%GA2Trial23
trackData.GA2Trial23(1).calibrateFilename=['GA2Trial23_trackFile_rf_' trackType '.mat'];
trackData.GA2Trial23(1).scaleMax=-2.832;
trackData.GA2Trial23(1).timeOffsetMotionCaptureToTrack_sec=-0.15;
trackData.GA2Trial23(1).notes='pretty good';
trackData.GA2Trial23(1).inlinerMotionCaptureRFTrack=[];
trackData.GA2Trial23(1).maxSearchLagForOptimum_sample=[];

%JH2Trial66
trackData.JH2Trial66(1).calibrateFilename=['JH2Trial66_trackFile_rf_' trackType '.mat'];
trackData.JH2Trial66(1).scaleMax=-0.236;
trackData.JH2Trial66(1).timeOffsetMotionCaptureToTrack_sec=-1.2;
trackData.JH2Trial66(1).notes='very little motion, spline quantized';
trackData.JH2Trial66(1).inlinerMotionCaptureRFTrack=[];
trackData.JH2Trial66(1).maxSearchLagForOptimum_sample=[];

%JH2Trial67
trackData.JH2Trial67(1).calibrateFilename=['JH2Trial67_trackFile_rf_' trackType '.mat'];
trackData.JH2Trial67(1).scaleMax=-2.832;
trackData.JH2Trial67(1).timeOffsetMotionCaptureToTrack_sec=-0.98571;
trackData.JH2Trial67(1).notes='very little motion, spline quantized';
trackData.JH2Trial67(1).inlinerMotionCaptureRFTrack=[];
trackData.JH2Trial67(1).maxSearchLagForOptimum_sample=[];

%JM2Trial2
trackData.JM2Trial2(1).calibrateFilename=[''];
trackData.JM2Trial2(1).scaleMax=[];
trackData.JM2Trial2(1).timeOffsetMotionCaptureToTrack_sec=[];
trackData.JM2Trial2(1).notes='no motion capture data';
trackData.JM2Trial2(1).inlinerMotionCaptureRFTrack=[];
trackData.JM2Trial2(1).maxSearchLagForOptimum_sample=[];

%JM2Trial3
trackData.JM2Trial3(1).calibrateFilename=[''];
trackData.JM2Trial3(1).scaleMax=[];
trackData.JM2Trial3(1).timeOffsetMotionCaptureToTrack_sec=[];
trackData.JM2Trial3(1).notes='no motion capture data';
trackData.JM2Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.JM2Trial3(1).maxSearchLagForOptimum_sample=[];

%JM2Trial4
trackData.JM2Trial4(1).calibrateFilename=[''];
trackData.JM2Trial4(1).scaleMax=[];
trackData.JM2Trial4(1).timeOffsetMotionCaptureToTrack_sec=[];
trackData.JM2Trial4(1).notes='no motion capture data';
trackData.JM2Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.JM2Trial4(1).maxSearchLagForOptimum_sample=[];

%JW2Trial2
trackData.JW2Trial2(1).calibrateFilename=['JW2Trial2_trackFile_rf_' trackType '.mat'];
trackData.JW2Trial2(1).scaleMax=-0.8968;
trackData.JW2Trial2(1).timeOffsetMotionCaptureToTrack_sec=-0.175;
trackData.JW2Trial2(1).notes='good collect';
trackData.JW2Trial2(1).inlinerMotionCaptureRFTrack=[];
trackData.JW2Trial2(1).maxSearchLagForOptimum_sample=[];

%JW2Trial3
trackData.JW2Trial3(1).calibrateFilename=['JW2Trial3_trackFile_rf_' trackType '.mat'];
trackData.JW2Trial3(1).scaleMax=-1.416;
trackData.JW2Trial3(1).timeOffsetMotionCaptureToTrack_sec=-1.05;
trackData.JW2Trial3(1).notes='good collect';
trackData.JW2Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.JW2Trial3(1).maxSearchLagForOptimum_sample=[];

%MO2Trial29
trackData.MO2Trial29(1).calibrateFilename=['MO2Trial29_trackFile_rf_' trackType '.mat'];
trackData.MO2Trial29(1).scaleMax=-1.416;
trackData.MO2Trial29(1).timeOffsetMotionCaptureToTrack_sec=0.75;
trackData.MO2Trial29(1).notes='looks like the rf started first';
trackData.MO2Trial29(1).inlinerMotionCaptureRFTrack=[];
trackData.MO2Trial29(1).maxSearchLagForOptimum_sample=[];

%MO2Trial30
trackData.MO2Trial30(1).calibrateFilename=['MO2Trial30_trackFile_rf_' trackType '.mat'];
trackData.MO2Trial30(1).scaleMax=-0.01475;
trackData.MO2Trial30(1).timeOffsetMotionCaptureToTrack_sec=0.1;
trackData.MO2Trial30(1).notes='not much signalt';
trackData.MO2Trial30(1).inlinerMotionCaptureRFTrack=[];
trackData.MO2Trial30(1).maxSearchLagForOptimum_sample=[];

%MO2Trial31
trackData.MO2Trial31(1).calibrateFilename=['MO2Trial31_trackFile_rf_' trackType '.mat'];
trackData.MO2Trial31(1).scaleMax=-0.059;
trackData.MO2Trial31(1).timeOffsetMotionCaptureToTrack_sec=-0.425;
trackData.MO2Trial31(1).notes='not much motion';
trackData.MO2Trial31(1).inlinerMotionCaptureRFTrack=[];
trackData.MO2Trial31(1).maxSearchLagForOptimum_sample=[];

%NH2Trial4
trackData.NH2Trial4(1).calibrateFilename=['NH2Trial4_trackFile_rf_' trackType '.mat'];
trackData.NH2Trial4(1).scaleMax=1.888;
trackData.NH2Trial4(1).timeOffsetMotionCaptureToTrack_sec=-1.8857;
trackData.NH2Trial4(1).notes='noisy collect';
trackData.NH2Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.NH2Trial4(1).maxSearchLagForOptimum_sample=[];

%NH2Trial7
trackData.NH2Trial7(1).calibrateFilename=['NH2Trial7_trackFile_rf_' trackType '.mat'];
trackData.NH2Trial7(1).scaleMax=1.888;
trackData.NH2Trial7(1).timeOffsetMotionCaptureToTrack_sec=-2.6571;
trackData.NH2Trial7(1).notes='noisy collect';
trackData.NH2Trial7(1).inlinerMotionCaptureRFTrack=[];
trackData.NH2Trial7(1).maxSearchLagForOptimum_sample=[];

%RR2Trial40
trackData.RR2Trial40(1).calibrateFilename=['RR2Trial40_trackFile_rf_' trackType '.mat'];
trackData.RR2Trial40(1).scaleMax=-1.888;
trackData.RR2Trial40(1).timeOffsetMotionCaptureToTrack_sec=0.82857;
trackData.RR2Trial40(1).notes='start off seems to be before motion collect';
trackData.RR2Trial40(1).inlinerMotionCaptureRFTrack=[];
trackData.RR2Trial40(1).maxSearchLagForOptimum_sample=[];

%RR2Trial41
trackData.RR2Trial41(1).calibrateFilename=['RR2Trial41_trackFile_rf_' trackType '.mat'];
trackData.RR2Trial41(1).scaleMax=-1.888;
trackData.RR2Trial41(1).timeOffsetMotionCaptureToTrack_sec=0.91429;
trackData.RR2Trial41(1).notes='start off seems to be before motion collect';
trackData.RR2Trial41(1).inlinerMotionCaptureRFTrack=[];
trackData.RR2Trial41(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%RR2Trial42
trackData.RR2Trial42(1).calibrateFilename=['RR2Trial42_trackFile_rf_' trackType '.mat'];
trackData.RR2Trial42(1).scaleMax=-1.888;
trackData.RR2Trial42(1).timeOffsetMotionCaptureToTrack_sec=0.54286;
trackData.RR2Trial42(1).notes='start off seems to be before motion collect';
trackData.RR2Trial42(1).inlinerMotionCaptureRFTrack=[];
trackData.RR2Trial42(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%RR2Trial44
trackData.RR2Trial44(1).calibrateFilename=['RR2Trial44_trackFile_rf_' trackType '.mat'];
trackData.RR2Trial44(1).scaleMax=-3.776;
trackData.RR2Trial44(1).timeOffsetMotionCaptureToTrack_sec=-3.1286;
trackData.RR2Trial44(1).notes='only the levels cluster';
trackData.RR2Trial44(1).inlinerMotionCaptureRFTrack=[];
trackData.RR2Trial44(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%SK2Trial64
trackData.SK2Trial64(1).calibrateFilename=['SK2Trial64_trackFile_rf_' trackType '.mat'];
trackData.SK2Trial64(1).scaleMax=-0.472;
trackData.SK2Trial64(1).timeOffsetMotionCaptureToTrack_sec=-1.1;
trackData.SK2Trial64(1).notes='small motion very noisy';
trackData.SK2Trial64(1).inlinerMotionCaptureRFTrack=[];
trackData.SK2Trial64(1).maxSearchLagForOptimum_sample=[];

%SK2Trial65
trackData.SK2Trial65(1).calibrateFilename=['SK2Trial65_trackFile_rf_' trackType '.mat'];
trackData.SK2Trial65(1).scaleMax=-0.472;
trackData.SK2Trial65(1).timeOffsetMotionCaptureToTrack_sec=-1.4429;
trackData.SK2Trial65(1).notes='noisy';
trackData.SK2Trial65(1).inlinerMotionCaptureRFTrack=[];
trackData.SK2Trial65(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%SK2Trial66
trackData.SK2Trial66(1).calibrateFilename=['SK2Trial66_trackFile_rf_' trackType '.mat'];
trackData.SK2Trial66(1).scaleMax=-0.472;
trackData.SK2Trial66(1).timeOffsetMotionCaptureToTrack_sec=-1.4429;
trackData.SK2Trial66(1).notes='noisy';
trackData.SK2Trial66(1).inlinerMotionCaptureRFTrack=[];
trackData.SK2Trial66(1).maxSearchLagForOptimum_sample=[];

%ZH2Trial33
trackData.ZH2Trial33(1).calibrateFilename=['ZH2Trial33_trackFile_rf_' trackType '.mat'];
trackData.ZH2Trial33(1).scaleMax=-0.472;
trackData.ZH2Trial33(1).timeOffsetMotionCaptureToTrack_sec=-0.2;
trackData.ZH2Trial33(1).notes='good++ track.';
trackData.ZH2Trial33(1).inlinerMotionCaptureRFTrack=[];
trackData.ZH2Trial33(1).maxSearchLagForOptimum_sample=[];

%ZH2Trial34
trackData.ZH2Trial34(1).calibrateFilename=['ZH2Trial34_trackFile_rf_' trackType '.mat'];
trackData.ZH2Trial34(1).scaleMax=-0.472;
trackData.ZH2Trial34(1).timeOffsetMotionCaptureToTrack_sec=0.175;
trackData.ZH2Trial34(1).notes='good++ track.';
trackData.ZH2Trial34(1).inlinerMotionCaptureRFTrack=[];
trackData.ZH2Trial34(1).maxSearchLagForOptimum_sample=[]; 
 
%ZH2Trial35
trackData.ZH2Trial35(1).calibrateFilename=['ZH2Trial35_trackFile_rf_' trackType '.mat'];
trackData.ZH2Trial35(1).scaleMax=-0.472;
trackData.ZH2Trial35(1).timeOffsetMotionCaptureToTrack_sec=-1.1;
trackData.ZH2Trial35(1).notes='good++ track.';
trackData.ZH2Trial35(1).inlinerMotionCaptureRFTrack=[];
trackData.ZH2Trial35(1).maxSearchLagForOptimum_sample=[];

%WAHV03_visit1_trial21
trackData.WAHV03_visit1_trial21(1).calibrateFilename=['WAHV03_visit1_trial21_trackFile_rf_' trackType '.mat'];
trackData.WAHV03_visit1_trial21(1).scaleMax=-1;
trackData.WAHV03_visit1_trial21(1).timeOffsetMotionCaptureToTrack_sec=-0.32143;
trackData.WAHV03_visit1_trial21(1).notes='';
trackData.WAHV03_visit1_trial21(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV03_visit1_trial21(1).maxSearchLagForOptimum_sample=[];

%WAHV03_visit1_trial22
trackData.WAHV03_visit1_trial22(1).calibrateFilename=['WAHV03_visit1_trial22_trackFile_rf_' trackType '.mat'];
trackData.WAHV03_visit1_trial22(1).scaleMax=-1;
trackData.WAHV03_visit1_trial22(1).timeOffsetMotionCaptureToTrack_sec=-0.75;
trackData.WAHV03_visit1_trial22(1).notes='';
trackData.WAHV03_visit1_trial22(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV03_visit1_trial22(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%WAHV03_visit1_trial25
trackData.WAHV03_visit1_trial25(1).calibrateFilename=['WAHV03_visit1_trial25_trackFile_rf_' trackType '.mat'];
trackData.WAHV03_visit1_trial25(1).scaleMax=-1;
trackData.WAHV03_visit1_trial25(1).timeOffsetMotionCaptureToTrack_sec=-0.21429;
trackData.WAHV03_visit1_trial25(1).notes='';
trackData.WAHV03_visit1_trial25(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV03_visit1_trial25(1).maxSearchLagForOptimum_sample=[];

%WAHV03_visit1_trial26
trackData.WAHV03_visit1_trial26(1).calibrateFilename=['WAHV03_visit1_trial26_trackFile_rf_' trackType '.mat'];
trackData.WAHV03_visit1_trial26(1).scaleMax=-1;
trackData.WAHV03_visit1_trial26(1).timeOffsetMotionCaptureToTrack_sec=-0.32143;
trackData.WAHV03_visit1_trial26(1).notes='';
trackData.WAHV03_visit1_trial26(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV03_visit1_trial26(1).maxSearchLagForOptimum_sample=[];

%WAHV04_visit1_trial27
trackData.WAHV04_visit1_trial27(1).calibrateFilename=['WAHV04_visit1_trial27_trackFile_rf_' trackType '.mat'];
trackData.WAHV04_visit1_trial27(1).scaleMax=-1;
trackData.WAHV04_visit1_trial27(1).timeOffsetMotionCaptureToTrack_sec=-0.35294;
trackData.WAHV04_visit1_trial27(1).notes='';
trackData.WAHV04_visit1_trial27(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV04_visit1_trial27(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%WAHV04_visit1_trial28
trackData.WAHV04_visit1_trial28(1).calibrateFilename=['WAHV04_visit1_trial28_trackFile_rf_' trackType '.mat'];
trackData.WAHV04_visit1_trial28(1).scaleMax=-1;
trackData.WAHV04_visit1_trial28(1).timeOffsetMotionCaptureToTrack_sec=-0.5098;
trackData.WAHV04_visit1_trial28(1).notes='';
trackData.WAHV04_visit1_trial28(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV04_visit1_trial28(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%WAHV05_visit1_trial20
trackData.WAHV05_visit1_trial20(1).calibrateFilename=['WAHV05_visit1_trial20_trackFile_rf_' trackType '.mat'];
trackData.WAHV05_visit1_trial20(1).scaleMax=-1;
trackData.WAHV05_visit1_trial20(1).timeOffsetMotionCaptureToTrack_sec=-0.098039;
trackData.WAHV05_visit1_trial20(1).notes='';
trackData.WAHV05_visit1_trial20(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV05_visit1_trial20(1).maxSearchLagForOptimum_sample=[];

%WAHV05_visit1_trial21
trackData.WAHV05_visit1_trial21(1).calibrateFilename=['WAHV05_visit1_trial21_trackFile_rf_' trackType '.mat'];
trackData.WAHV05_visit1_trial21(1).scaleMax=-1;
trackData.WAHV05_visit1_trial21(1).timeOffsetMotionCaptureToTrack_sec=-0.23529;
trackData.WAHV05_visit1_trial21(1).notes='';
trackData.WAHV05_visit1_trial21(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV05_visit1_trial21(1).maxSearchLagForOptimum_sample=[];

%WAHV05_visit1_trial26
trackData.WAHV05_visit1_trial26(1).calibrateFilename=['WAHV05_visit1_trial26_trackFile_rf_' trackType '.mat'];
trackData.WAHV05_visit1_trial26(1).scaleMax=-1;
trackData.WAHV05_visit1_trial26(1).timeOffsetMotionCaptureToTrack_sec=-0.098039;
trackData.WAHV05_visit1_trial26(1).notes='';
trackData.WAHV05_visit1_trial26(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV05_visit1_trial26(1).maxSearchLagForOptimum_sample=[];

%WAHV05_visit1_trial27
trackData.WAHV05_visit1_trial27(1).calibrateFilename=['WAHV05_visit1_trial27_trackFile_rf_' trackType '.mat'];
trackData.WAHV05_visit1_trial27(1).scaleMax=-1;
trackData.WAHV05_visit1_trial27(1).timeOffsetMotionCaptureToTrack_sec=-0.27451;
trackData.WAHV05_visit1_trial27(1).notes='';
trackData.WAHV05_visit1_trial27(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV05_visit1_trial27(1).maxSearchLagForOptimum_sample=[];

%WAHV06_visit1_trial24
trackData.WAHV06_visit1_trial24(1).calibrateFilename=['WAHV06_visit1_trial24_trackFile_rf_' trackType '.mat'];
trackData.WAHV06_visit1_trial24(1).scaleMax=-1;
trackData.WAHV06_visit1_trial24(1).timeOffsetMotionCaptureToTrack_sec=-0.16393;
trackData.WAHV06_visit1_trial24(1).notes='';
trackData.WAHV06_visit1_trial24(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV06_visit1_trial24(1).maxSearchLagForOptimum_sample=[]; %Override 0;

%WAHV06_visit1_trial33
trackData.WAHV06_visit1_trial33(1).calibrateFilename=['WAHV06_visit1_trial33_trackFile_rf_' trackType '.mat'];
trackData.WAHV06_visit1_trial33(1).scaleMax=-1;
trackData.WAHV06_visit1_trial33(1).timeOffsetMotionCaptureToTrack_sec=-0.31148;
trackData.WAHV06_visit1_trial33(1).notes='';
trackData.WAHV06_visit1_trial33(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV06_visit1_trial33(1).maxSearchLagForOptimum_sample=[];

%WAHV06_visit1_trial34
trackData.WAHV06_visit1_trial34(1).calibrateFilename=['WAHV06_visit1_trial34_trackFile_rf_' trackType '.mat'];
trackData.WAHV06_visit1_trial34(1).scaleMax=-1;
trackData.WAHV06_visit1_trial34(1).timeOffsetMotionCaptureToTrack_sec=-0.19672;
trackData.WAHV06_visit1_trial34(1).notes='';
trackData.WAHV06_visit1_trial34(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV06_visit1_trial34(1).maxSearchLagForOptimum_sample=[];

%WAHV07_visit1_trial25
trackData.WAHV07_visit1_trial25(1).calibrateFilename=['WAHV07_visit1_trial25_trackFile_rf_' trackType '.mat'];
trackData.WAHV07_visit1_trial25(1).scaleMax=-1;
trackData.WAHV07_visit1_trial25(1).timeOffsetMotionCaptureToTrack_sec=-0.63934;
trackData.WAHV07_visit1_trial25(1).notes='';
trackData.WAHV07_visit1_trial25(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV07_visit1_trial25(1).maxSearchLagForOptimum_sample=[];

%WAHV07_visit1_trial26
trackData.WAHV07_visit1_trial26(1).calibrateFilename=['WAHV07_visit1_trial26_trackFile_rf_' trackType '.mat'];
trackData.WAHV07_visit1_trial26(1).scaleMax=-1;
trackData.WAHV07_visit1_trial26(1).timeOffsetMotionCaptureToTrack_sec=-0.39344;
trackData.WAHV07_visit1_trial26(1).notes='';
trackData.WAHV07_visit1_trial26(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV07_visit1_trial26(1).maxSearchLagForOptimum_sample=[];

%WAHV07_visit1_trial31
trackData.WAHV07_visit1_trial31(1).calibrateFilename=['WAHV07_visit1_trial31_trackFile_rf_' trackType '.mat'];
trackData.WAHV07_visit1_trial31(1).scaleMax=-1;
trackData.WAHV07_visit1_trial31(1).timeOffsetMotionCaptureToTrack_sec=-0.19672;
trackData.WAHV07_visit1_trial31(1).notes='';
trackData.WAHV07_visit1_trial31(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV07_visit1_trial31(1).maxSearchLagForOptimum_sample=[];

%WAHV07_visit1_trial32
trackData.WAHV07_visit1_trial32(1).calibrateFilename=['WAHV07_visit1_trial32_trackFile_rf_' trackType '.mat'];
trackData.WAHV07_visit1_trial32(1).scaleMax=-1;
trackData.WAHV07_visit1_trial32(1).timeOffsetMotionCaptureToTrack_sec=-0.39344;
trackData.WAHV07_visit1_trial32(1).notes='';
trackData.WAHV07_visit1_trial32(1).inlinerMotionCaptureRFTrack=[];
trackData.WAHV07_visit1_trial32(1).maxSearchLagForOptimum_sample=[];

%AB3Trial1 -- no motion capture data


%AB3Trial2
trackData.AB3Trial2(1).calibrateFilename=['AB3Trial2_trackFile_rf_' trackType '.mat'];
trackData.AB3Trial2(1).scaleMax=-0.472;
trackData.AB3Trial2(1).timeOffsetMotionCaptureToTrack_sec=-1.025;
trackData.AB3Trial2(1).notes='';
trackData.AB3Trial2(1).inlinerMotionCaptureRFTrack=[];
trackData.AB3Trial2(1).maxSearchLagForOptimum_sample=[];

%AB3Trial3
trackData.AB3Trial3(1).calibrateFilename=['AB3Trial3_trackFile_rf_' trackType '.mat'];
trackData.AB3Trial3(1).scaleMax=-0.7;
trackData.AB3Trial3(1).timeOffsetMotionCaptureToTrack_sec=-1.55;
trackData.AB3Trial3(1).notes='';
trackData.AB3Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.AB3Trial3(1).maxSearchLagForOptimum_sample=[];

%AB3Trial4
trackData.AB3Trial4(1).calibrateFilename=['AB3Trial4_trackFile_rf_' trackType '.mat'];
trackData.AB3Trial4(1).scaleMax=-0.472;
trackData.AB3Trial4(1).timeOffsetMotionCaptureToTrack_sec=-0.2;
trackData.AB3Trial4(1).notes='';
trackData.AB3Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.AB3Trial4(1).maxSearchLagForOptimum_sample=[];

%AN3Trial54
trackData.AN3Trial54(1).calibrateFilename=['AN3Trial54_trackFile_rf_' trackType '.mat'];
trackData.AN3Trial54(1).scaleMax=-6;
trackData.AN3Trial54(1).timeOffsetMotionCaptureToTrack_sec=-2.6714;
trackData.AN3Trial54(1).notes='';
trackData.AN3Trial54(1).inlinerMotionCaptureRFTrack=[];
trackData.AN3Trial54(1).maxSearchLagForOptimum_sample=[];


%AN3Trial55
trackData.AN3Trial55(1).calibrateFilename=['AN3Trial55_trackFile_rf_' trackType '.mat'];
trackData.AN3Trial55(1).scaleMax=-6;
trackData.AN3Trial55(1).timeOffsetMotionCaptureToTrack_sec=-2.7429;
trackData.AN3Trial55(1).notes='';
trackData.AN3Trial55(1).inlinerMotionCaptureRFTrack=[];
trackData.AN3Trial55(1).maxSearchLagForOptimum_sample=[];

%CT3Trial3
trackData.CT3Trial3(1).calibrateFilename=['CT3Trial3_trackFile_rf_' trackType '.mat'];
trackData.CT3Trial3(1).scaleMax=-0.4;
trackData.CT3Trial3(1).timeOffsetMotionCaptureToTrack_sec=-2;
trackData.CT3Trial3(1).notes='';
trackData.CT3Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.CT3Trial3(1).maxSearchLagForOptimum_sample=[];

%CT3Trial4
trackData.CT3Trial4(1).calibrateFilename=['CT3Trial4_trackFile_rf_' trackType '.mat'];
trackData.CT3Trial4(1).scaleMax=-0.4;
trackData.CT3Trial4(1).timeOffsetMotionCaptureToTrack_sec=-1.7857;
trackData.CT3Trial4(1).notes='';
trackData.CT3Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.CT3Trial4(1).maxSearchLagForOptimum_sample=[];

%DP3Trial3
trackData.DP3Trial3(1).calibrateFilename=['DP3Trial3_trackFile_rf_' trackType '.mat'];
trackData.DP3Trial3(1).scaleMax=-0.9;
trackData.DP3Trial3(1).timeOffsetMotionCaptureToTrack_sec=-2.8571;
trackData.DP3Trial3(1).notes='';
trackData.DP3Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.DP3Trial3(1).maxSearchLagForOptimum_sample=[];

%DP3Trial4
trackData.DP3Trial4(1).calibrateFilename=['DP3Trial4_trackFile_rf_' trackType '.mat'];
trackData.DP3Trial4(1).scaleMax=-2;
trackData.DP3Trial4(1).timeOffsetMotionCaptureToTrack_sec=-1.2;
trackData.DP3Trial4(1).notes='';
trackData.DP3Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.DP3Trial4(1).maxSearchLagForOptimum_sample=[];

%DP3Trial5
trackData.DP3Trial5(1).calibrateFilename=['DP3Trial5_trackFile_rf_' trackType '.mat'];
trackData.DP3Trial5(1).scaleMax=-1.7;
trackData.DP3Trial5(1).timeOffsetMotionCaptureToTrack_sec=-1.7857;
trackData.DP3Trial5(1).notes='';
trackData.DP3Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.DP3Trial5(1).maxSearchLagForOptimum_sample=[];


%DW3Trial3
trackData.DW3Trial3(1).calibrateFilename=['DW3Trial3_trackFile_rf_' trackType '.mat'];
trackData.DW3Trial3(1).scaleMax=-0.4;
trackData.DW3Trial3(1).timeOffsetMotionCaptureToTrack_sec=-0.4;
trackData.DW3Trial3(1).notes='not much motion';
trackData.DW3Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.DW3Trial3(1).maxSearchLagForOptimum_sample=[];

%DW3Trial4
trackData.DW3Trial4(1).calibrateFilename=['DW3Trial4_trackFile_rf_' trackType '.mat'];
trackData.DW3Trial4(1).scaleMax=-0.4;
trackData.DW3Trial4(1).timeOffsetMotionCaptureToTrack_sec=-2.4625;
trackData.DW3Trial4(1).notes='little motion';
trackData.DW3Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.DW3Trial4(1).maxSearchLagForOptimum_sample=[];

%ES3Trial73
trackData.ES3Trial73(1).calibrateFilename=['ES3Trial73_trackFile_rf_' trackType '.mat'];
trackData.ES3Trial73(1).scaleMax=-7;
trackData.ES3Trial73(1).timeOffsetMotionCaptureToTrack_sec=-0.62857;
trackData.ES3Trial73(1).notes='';
trackData.ES3Trial73(1).inlinerMotionCaptureRFTrack=[];
trackData.ES3Trial73(1).maxSearchLagForOptimum_sample=[];

%ES3Trial74
trackData.ES3Trial74(1).calibrateFilename=['ES3Trial74_trackFile_rf_' trackType '.mat'];
trackData.ES3Trial74(1).scaleMax=-1;
trackData.ES3Trial74(1).timeOffsetMotionCaptureToTrack_sec=-0.72857;
trackData.ES3Trial74(1).notes='';
trackData.ES3Trial74(1).inlinerMotionCaptureRFTrack=[];
trackData.ES3Trial74(1).maxSearchLagForOptimum_sample=[];

%ES3Trial75
trackData.ES3Trial75(1).calibrateFilename=['ES3Trial75_trackFile_rf_' trackType '.mat'];
trackData.ES3Trial75(1).scaleMax=-1;
trackData.ES3Trial75(1).timeOffsetMotionCaptureToTrack_sec=-2.1;
trackData.ES3Trial75(1).notes='';
trackData.ES3Trial75(1).inlinerMotionCaptureRFTrack=[];
trackData.ES3Trial75(1).maxSearchLagForOptimum_sample=[];

%JH3Trial56
trackData.JH3Trial56(1).calibrateFilename=['JH3Trial56_trackFile_rf_' trackType '.mat'];
trackData.JH3Trial56(1).scaleMax=-1;
trackData.JH3Trial56(1).timeOffsetMotionCaptureToTrack_sec=-0.38571;
trackData.JH3Trial56(1).notes='';
trackData.JH3Trial56(1).inlinerMotionCaptureRFTrack=[];
trackData.JH3Trial56(1).maxSearchLagForOptimum_sample=[];


%JH3Trial57
trackData.JH3Trial57(1).calibrateFilename=['JH3Trial57_trackFile_rf_' trackType '.mat'];
trackData.JH3Trial57(1).scaleMax=-1;
trackData.JH3Trial57(1).timeOffsetMotionCaptureToTrack_sec=-0.042857;
trackData.JH3Trial57(1).notes='';
trackData.JH3Trial57(1).inlinerMotionCaptureRFTrack=[];
trackData.JH3Trial57(1).maxSearchLagForOptimum_sample=[];

%JH3Trial58
trackData.JH3Trial58(1).calibrateFilename=['JH3Trial58_trackFile_rf_' trackType '.mat'];
trackData.JH3Trial58(1).scaleMax=-1;
trackData.JH3Trial58(1).timeOffsetMotionCaptureToTrack_sec=-0.38571;
trackData.JH3Trial58(1).notes='';
trackData.JH3Trial58(1).inlinerMotionCaptureRFTrack=[];
trackData.JH3Trial58(1).maxSearchLagForOptimum_sample=[];

%JK3Trial4
trackData.JK3Trial4(1).calibrateFilename=['JK3Trial4_trackFile_rf_' trackType '.mat'];
trackData.JK3Trial4(1).scaleMax=-1;
trackData.JK3Trial4(1).timeOffsetMotionCaptureToTrack_sec=-2.2286;
trackData.JK3Trial4(1).notes='';
trackData.JK3Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.JK3Trial4(1).maxSearchLagForOptimum_sample=[];

%JK3Trial5
trackData.JK3Trial5(1).calibrateFilename=['JK3Trial5_trackFile_rf_' trackType '.mat'];
trackData.JK3Trial5(1).scaleMax=-0.3;
trackData.JK3Trial5(1).timeOffsetMotionCaptureToTrack_sec=-2.4857;
trackData.JK3Trial5(1).notes='';
trackData.JK3Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.JK3Trial5(1).maxSearchLagForOptimum_sample=[];

%JK3Trial6
trackData.JK3Trial6(1).calibrateFilename=['JK3Trial6_trackFile_rf_' trackType '.mat'];
trackData.JK3Trial6(1).scaleMax=-0.3;
trackData.JK3Trial6(1).timeOffsetMotionCaptureToTrack_sec=-2.4429;
trackData.JK3Trial6(1).notes='';
trackData.JK3Trial6(1).inlinerMotionCaptureRFTrack=[];
trackData.JK3Trial6(1).maxSearchLagForOptimum_sample=[];

%JM3Trial63 - no motion capture data found
%JM3Trial64 - no motion capture data found
%JM3Trial65 - no motion capture data found

%JW3Trial49
trackData.JW3Trial49(1).calibrateFilename=['JW3Trial49_trackFile_rf_' trackType '.mat'];
trackData.JW3Trial49(1).scaleMax=-1;
trackData.JW3Trial49(1).timeOffsetMotionCaptureToTrack_sec=-2.175;
trackData.JW3Trial49(1).notes='good track';
trackData.JW3Trial49(1).inlinerMotionCaptureRFTrack=[];
trackData.JW3Trial49(1).maxSearchLagForOptimum_sample=[];


%JW3Trial50
trackData.JW3Trial50(1).calibrateFilename=['JW3Trial50_trackFile_rf_' trackType '.mat'];
trackData.JW3Trial50(1).scaleMax=-1;
trackData.JW3Trial50(1).timeOffsetMotionCaptureToTrack_sec=-2.475;
trackData.JW3Trial50(1).notes='';
trackData.JW3Trial50(1).inlinerMotionCaptureRFTrack=[];
trackData.JW3Trial50(1).maxSearchLagForOptimum_sample=[];


%MO3Trial45
trackData.MO3Trial45(1).calibrateFilename=['MO3Trial45_trackFile_rf_' trackType '.mat'];
trackData.MO3Trial45(1).scaleMax=-0.4;
trackData.MO3Trial45(1).timeOffsetMotionCaptureToTrack_sec=-1.6731;
trackData.MO3Trial45(1).notes='';
trackData.MO3Trial45(1).inlinerMotionCaptureRFTrack=[];
trackData.MO3Trial45(1).maxSearchLagForOptimum_sample=[];

%MO3Trial47
trackData.MO3Trial47(1).calibrateFilename=['MO3Trial47_trackFile_rf_' trackType '.mat'];
trackData.MO3Trial47(1).scaleMax=-0.4;
trackData.MO3Trial47(1).timeOffsetMotionCaptureToTrack_sec=-3.75;
trackData.MO3Trial47(1).notes='';
trackData.MO3Trial47(1).inlinerMotionCaptureRFTrack=[];
trackData.MO3Trial47(1).maxSearchLagForOptimum_sample=[];

%NH3Trial5
trackData.NH3Trial5(1).calibrateFilename=['NH3Trial5_trackFile_rf_' trackType '.mat'];
trackData.NH3Trial5(1).scaleMax=-0.4;
trackData.NH3Trial5(1).timeOffsetMotionCaptureToTrack_sec=-2.9571;
trackData.NH3Trial5(1).notes='';
trackData.NH3Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.NH3Trial5(1).maxSearchLagForOptimum_sample=[];

%NH3Trial6
trackData.NH3Trial6(1).calibrateFilename=['NH3Trial6_trackFile_rf_' trackType '.mat'];
trackData.NH3Trial6(1).scaleMax=-0.4;
trackData.NH3Trial6(1).timeOffsetMotionCaptureToTrack_sec=-2.7429;
trackData.NH3Trial6(1).notes='';
trackData.NH3Trial6(1).inlinerMotionCaptureRFTrack=[];
trackData.NH3Trial6(1).maxSearchLagForOptimum_sample=[];

%NH3Trial8
trackData.NH3Trial8(1).calibrateFilename=['NH3Trial8_trackFile_rf_' trackType '.mat'];
trackData.NH3Trial8(1).scaleMax=-0.4;
trackData.NH3Trial8(1).timeOffsetMotionCaptureToTrack_sec=-1.8;
trackData.NH3Trial8(1).notes='';
trackData.NH3Trial8(1).inlinerMotionCaptureRFTrack=[];
trackData.NH3Trial8(1).maxSearchLagForOptimum_sample=[];

%RR3Trial55
trackData.RR3Trial55(1).calibrateFilename=['RR3Trial55_trackFile_rf_' trackType '.mat'];
trackData.RR3Trial55(1).scaleMax=-1;
trackData.RR3Trial55(1).timeOffsetMotionCaptureToTrack_sec=-2.6143;
trackData.RR3Trial55(1).notes='';
trackData.RR3Trial55(1).inlinerMotionCaptureRFTrack=[];
trackData.RR3Trial55(1).maxSearchLagForOptimum_sample=[];

%RR3Trial56
trackData.RR3Trial56(1).calibrateFilename=['RR3Trial56_trackFile_rf_' trackType '.mat'];
trackData.RR3Trial56(1).scaleMax=-0.5;
trackData.RR3Trial56(1).timeOffsetMotionCaptureToTrack_sec=-2.8714;
trackData.RR3Trial56(1).notes='';
trackData.RR3Trial56(1).inlinerMotionCaptureRFTrack=[];
trackData.RR3Trial56(1).maxSearchLagForOptimum_sample=[];

%RR3Trial57
trackData.RR3Trial57(1).calibrateFilename=['RR3Trial57_trackFile_rf_' trackType '.mat'];
trackData.RR3Trial57(1).scaleMax=-0.5;
trackData.RR3Trial57(1).timeOffsetMotionCaptureToTrack_sec=-2.9571;
trackData.RR3Trial57(1).notes='';
trackData.RR3Trial57(1).inlinerMotionCaptureRFTrack=[];
trackData.RR3Trial57(1).maxSearchLagForOptimum_sample=[];

%SK3Trial69
trackData.SK3Trial69(1).calibrateFilename=['SK3Trial69_trackFile_rf_' trackType '.mat'];
trackData.SK3Trial69(1).scaleMax=-0.5;
trackData.SK3Trial69(1).timeOffsetMotionCaptureToTrack_sec=-2.1746;
trackData.SK3Trial69(1).notes='';
trackData.SK3Trial69(1).inlinerMotionCaptureRFTrack=[];
trackData.SK3Trial69(1).maxSearchLagForOptimum_sample=[];

%SK3Trial70
trackData.SK3Trial70(1).calibrateFilename=['SK3Trial70_trackFile_rf_' trackType '.mat'];
trackData.SK3Trial70(1).scaleMax=-0.5;
trackData.SK3Trial70(1).timeOffsetMotionCaptureToTrack_sec=-2.8889;
trackData.SK3Trial70(1).notes='';
trackData.SK3Trial70(1).inlinerMotionCaptureRFTrack=[];
trackData.SK3Trial70(1).maxSearchLagForOptimum_sample=[];

%SK3Trial71
trackData.SK3Trial71(1).calibrateFilename=['SK3Trial71_trackFile_rf_' trackType '.mat'];
trackData.SK3Trial71(1).scaleMax=-0.5;
trackData.SK3Trial71(1).timeOffsetMotionCaptureToTrack_sec=-2.5556;
trackData.SK3Trial71(1).notes='';
trackData.SK3Trial71(1).inlinerMotionCaptureRFTrack=[];
trackData.SK3Trial71(1).maxSearchLagForOptimum_sample=[];

%ZH3Trial1-no motion track data

%ZH3Trial2
trackData.ZH3Trial2(1).calibrateFilename=['ZH3Trial2_trackFile_rf_' trackType '.mat'];
trackData.ZH3Trial2(1).scaleMax=-0.2;
trackData.ZH3Trial2(1).timeOffsetMotionCaptureToTrack_sec=0.23077;
trackData.ZH3Trial2(1).notes='';
trackData.ZH3Trial2(1).inlinerMotionCaptureRFTrack=[];
trackData.ZH3Trial2(1).maxSearchLagForOptimum_sample=[];

%ZM3Trial2
trackData.ZM3Trial2(1).calibrateFilename=['ZM3Trial2_trackFile_rf_' trackType '.mat'];
trackData.ZM3Trial2(1).scaleMax=-4;
trackData.ZM3Trial2(1).timeOffsetMotionCaptureToTrack_sec=-0.76923;
trackData.ZM3Trial2(1).notes='poor match';
trackData.ZM3Trial2(1).inlinerMotionCaptureRFTrack=[];
trackData.ZM3Trial2(1).maxSearchLagForOptimum_sample=[];

%ZM3Trial3
trackData.ZM3Trial3(1).calibrateFilename=['ZM3Trial3_trackFile_rf_' trackType '.mat'];
trackData.ZM3Trial3(1).scaleMax=-4;
trackData.ZM3Trial3(1).timeOffsetMotionCaptureToTrack_sec=-0.46154;
trackData.ZM3Trial3(1).notes='poor match';
trackData.ZM3Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.ZM3Trial3(1).maxSearchLagForOptimum_sample=[];

%ZM3Trial4
trackData.ZM3Trial4(1).calibrateFilename=['ZM3Trial4_trackFile_rf_' trackType '.mat'];
trackData.ZM3Trial4(1).scaleMax=-4;
trackData.ZM3Trial4(1).timeOffsetMotionCaptureToTrack_sec=-1;
trackData.ZM3Trial4(1).notes='poor match';
trackData.ZM3Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.ZM3Trial4(1).maxSearchLagForOptimum_sample=[];


%ZM3Trial5
trackData.ZM3Trial5(1).calibrateFilename=['ZM3Trial5_trackFile_rf_' trackType '.mat'];
trackData.ZM3Trial5(1).scaleMax=-4;
trackData.ZM3Trial5(1).timeOffsetMotionCaptureToTrack_sec=-0.49367;
trackData.ZM3Trial5(1).notes='poor match';
trackData.ZM3Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.ZM3Trial5(1).maxSearchLagForOptimum_sample=[];


%AB4Trial54
trackData.AB4Trial54(1).calibrateFilename=['AB4Trial54_trackFile_rf_' trackType '.mat'];
trackData.AB4Trial54(1).scaleMax=-1;
trackData.AB4Trial54(1).timeOffsetMotionCaptureToTrack_sec=-2.5125;
trackData.AB4Trial54(1).notes='';
trackData.AB4Trial54(1).inlinerMotionCaptureRFTrack=[];
trackData.AB4Trial54(1).maxSearchLagForOptimum_sample=[];

%AB4Trial55
trackData.AB4Trial55(1).calibrateFilename=['AB4Trial55_trackFile_rf_' trackType '.mat'];
trackData.AB4Trial55(1).scaleMax=-0.5;
trackData.AB4Trial55(1).timeOffsetMotionCaptureToTrack_sec=-1.5;
trackData.AB4Trial55(1).notes='';
trackData.AB4Trial55(1).inlinerMotionCaptureRFTrack=[];
trackData.AB4Trial55(1).maxSearchLagForOptimum_sample=[];

%AB4Trial56
trackData.AB4Trial56(1).calibrateFilename=['AB4Trial56_trackFile_rf_' trackType '.mat'];
trackData.AB4Trial56(1).scaleMax=-0.5;
trackData.AB4Trial56(1).timeOffsetMotionCaptureToTrack_sec=-2.4375;
trackData.AB4Trial56(1).notes='';
trackData.AB4Trial56(1).inlinerMotionCaptureRFTrack=[];
trackData.AB4Trial56(1).maxSearchLagForOptimum_sample=[];

%AF4Trial47
trackData.AF4Trial47(1).calibrateFilename=['AF4Trial47_trackFile_rf_' trackType '.mat'];
trackData.AF4Trial47(1).scaleMax=-0.75;
trackData.AF4Trial47(1).timeOffsetMotionCaptureToTrack_sec=-2.1429;
trackData.AF4Trial47(1).notes='';
trackData.AF4Trial47(1).inlinerMotionCaptureRFTrack=[];
trackData.AF4Trial47(1).maxSearchLagForOptimum_sample=[];

%AF4Trial48
trackData.AF4Trial48(1).calibrateFilename=['AF4Trial48_trackFile_rf_' trackType '.mat'];
trackData.AF4Trial48(1).scaleMax=-0.75;
trackData.AF4Trial48(1).timeOffsetMotionCaptureToTrack_sec=-2.1;
trackData.AF4Trial48(1).notes='';
trackData.AF4Trial48(1).inlinerMotionCaptureRFTrack=[];
trackData.AF4Trial48(1).maxSearchLagForOptimum_sample=[];

%AF4Trial49
trackData.AF4Trial49(1).calibrateFilename=['AF4Trial49_trackFile_rf_' trackType '.mat'];
trackData.AF4Trial49(1).scaleMax=-3;
trackData.AF4Trial49(1).timeOffsetMotionCaptureToTrack_sec=-1.7143;
trackData.AF4Trial49(1).notes='';
trackData.AF4Trial49(1).inlinerMotionCaptureRFTrack=[];
trackData.AF4Trial49(1).maxSearchLagForOptimum_sample=[];

%AN4Trial3
trackData.AN4Trial3(1).calibrateFilename=['AN4Trial3_trackFile_rf_' trackType '.mat'];
trackData.AN4Trial3(1).scaleMax=-1;
trackData.AN4Trial3(1).timeOffsetMotionCaptureToTrack_sec=-1.7571;
trackData.AN4Trial3(1).notes='';
trackData.AN4Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.AN4Trial3(1).maxSearchLagForOptimum_sample=[];

%AN4Trial5
trackData.AN4Trial5(1).calibrateFilename=['AN4Trial5_trackFile_rf_' trackType '.mat'];
trackData.AN4Trial5(1).scaleMax=-3;
trackData.AN4Trial5(1).timeOffsetMotionCaptureToTrack_sec=-1.0286;
trackData.AN4Trial5(1).notes='';
trackData.AN4Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.AN4Trial5(1).maxSearchLagForOptimum_sample=[];

%ES4Trial67
trackData.ES4Trial67(1).calibrateFilename=['ES4Trial67_trackFile_rf_' trackType '.mat'];
trackData.ES4Trial67(1).scaleMax=-2;
trackData.ES4Trial67(1).timeOffsetMotionCaptureToTrack_sec=-1.9524;
trackData.ES4Trial67(1).notes='';
trackData.ES4Trial67(1).inlinerMotionCaptureRFTrack=[];
trackData.ES4Trial67(1).maxSearchLagForOptimum_sample=[];

%ES4Trial68
trackData.ES4Trial68(1).calibrateFilename=['ES4Trial68_trackFile_rf_' trackType '.mat'];
trackData.ES4Trial68(1).scaleMax=-2;
trackData.ES4Trial68(1).timeOffsetMotionCaptureToTrack_sec=-1.6667;
trackData.ES4Trial68(1).notes='';
trackData.ES4Trial68(1).inlinerMotionCaptureRFTrack=[];
trackData.ES4Trial68(1).maxSearchLagForOptimum_sample=[];

%ES4Trial69
trackData.ES4Trial69(1).calibrateFilename=['ES4Trial69_trackFile_rf_' trackType '.mat'];
trackData.ES4Trial69(1).scaleMax=-2;
trackData.ES4Trial69(1).timeOffsetMotionCaptureToTrack_sec=-1.5714;
trackData.ES4Trial69(1).notes='';
trackData.ES4Trial69(1).inlinerMotionCaptureRFTrack=[];
trackData.ES4Trial69(1).maxSearchLagForOptimum_sample=[];

%ES4Trial70
trackData.ES4Trial70(1).calibrateFilename=['ES4Trial70_trackFile_rf_' trackType '.mat'];
trackData.ES4Trial70(1).scaleMax=-2;
trackData.ES4Trial70(1).timeOffsetMotionCaptureToTrack_sec=-2.1429;
trackData.ES4Trial70(1).notes='';
trackData.ES4Trial70(1).inlinerMotionCaptureRFTrack=[];
trackData.ES4Trial70(1).maxSearchLagForOptimum_sample=[];

%GA4Trial3
trackData.GA4Trial3(1).calibrateFilename=['GA4Trial3_trackFile_rf_' trackType '.mat'];
trackData.GA4Trial3(1).scaleMax=-2;
trackData.GA4Trial3(1).timeOffsetMotionCaptureToTrack_sec=-2.1429;
trackData.GA4Trial3(1).notes='';
trackData.GA4Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.GA4Trial3(1).maxSearchLagForOptimum_sample=[];

%GA4Trial4
trackData.GA4Trial4(1).calibrateFilename=['GA4Trial4_trackFile_rf_' trackType '.mat'];
trackData.GA4Trial4(1).scaleMax=-2;
trackData.GA4Trial4(1).timeOffsetMotionCaptureToTrack_sec=-2.3571;
trackData.GA4Trial4(1).notes='';
trackData.GA4Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.GA4Trial4(1).maxSearchLagForOptimum_sample=[];

%GA4Trial5
trackData.GA4Trial5(1).calibrateFilename=['GA4Trial5_trackFile_rf_' trackType '.mat'];
trackData.GA4Trial5(1).scaleMax=-2;
trackData.GA4Trial5(1).timeOffsetMotionCaptureToTrack_sec=-2.5714;
trackData.GA4Trial5(1).notes='';
trackData.GA4Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.GA4Trial5(1).maxSearchLagForOptimum_sample=[];

%JH4Trial4
trackData.JH4Trial4(1).calibrateFilename=['JH4Trial4_trackFile_rf_' trackType '.mat'];
trackData.JH4Trial4(1).scaleMax=-2;
trackData.JH4Trial4(1).timeOffsetMotionCaptureToTrack_sec=-2.3571;
trackData.JH4Trial4(1).notes='';
trackData.JH4Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.JH4Trial4(1).maxSearchLagForOptimum_sample=[];

%JH4Trial5
trackData.JH4Trial5(1).calibrateFilename=['JH4Trial5_trackFile_rf_' trackType '.mat'];
trackData.JH4Trial5(1).scaleMax=-2;
trackData.JH4Trial5(1).timeOffsetMotionCaptureToTrack_sec=-2.0857;
trackData.JH4Trial5(1).notes='';
trackData.JH4Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.JH4Trial5(1).maxSearchLagForOptimum_sample=[];

%JH4Trial6
trackData.JH4Trial6(1).calibrateFilename=['JH4Trial6_trackFile_rf_' trackType '.mat'];
trackData.JH4Trial6(1).scaleMax=-2;
trackData.JH4Trial6(1).timeOffsetMotionCaptureToTrack_sec=-1.6429;
trackData.JH4Trial6(1).notes='';
trackData.JH4Trial6(1).inlinerMotionCaptureRFTrack=[];
trackData.JH4Trial6(1).maxSearchLagForOptimum_sample=[];

%JM4Trial47
trackData.JM4Trial47(1).calibrateFilename=['JM4Trial47_trackFile_rf_' trackType '.mat'];
trackData.JM4Trial47(1).scaleMax=-2;
trackData.JM4Trial47(1).timeOffsetMotionCaptureToTrack_sec=-2.4571;
trackData.JM4Trial47(1).notes='';
trackData.JM4Trial47(1).inlinerMotionCaptureRFTrack=[];
trackData.JM4Trial47(1).maxSearchLagForOptimum_sample=[];

%JM4Trial48 -- no motion capture


%JM4Trial49
trackData.JM4Trial49(1).calibrateFilename=['JM4Trial49_trackFile_rf_' trackType '.mat'];
trackData.JM4Trial49(1).scaleMax=-2;
trackData.JM4Trial49(1).timeOffsetMotionCaptureToTrack_sec=-2.3375;
trackData.JM4Trial49(1).notes='';
trackData.JM4Trial49(1).inlinerMotionCaptureRFTrack=[];
trackData.JM4Trial49(1).maxSearchLagForOptimum_sample=[];

%JW4Trial60
trackData.JW4Trial60(1).calibrateFilename=['JW4Trial60_trackFile_rf_' trackType '.mat'];
trackData.JW4Trial60(1).scaleMax=-2;
trackData.JW4Trial60(1).timeOffsetMotionCaptureToTrack_sec=-2.0714;
trackData.JW4Trial60(1).notes='';
trackData.JW4Trial60(1).inlinerMotionCaptureRFTrack=[];
trackData.JW4Trial60(1).maxSearchLagForOptimum_sample=[];

%JW4Trial61
trackData.JW4Trial61(1).calibrateFilename=['JW4Trial61_trackFile_rf_' trackType '.mat'];
trackData.JW4Trial61(1).scaleMax=-2;
trackData.JW4Trial61(1).timeOffsetMotionCaptureToTrack_sec=-2.2;
trackData.JW4Trial61(1).notes='';
trackData.JW4Trial61(1).inlinerMotionCaptureRFTrack=[];
trackData.JW4Trial61(1).maxSearchLagForOptimum_sample=[];

%JW4Trial62
trackData.JW4Trial62(1).calibrateFilename=['JW4Trial62_trackFile_rf_' trackType '.mat'];
trackData.JW4Trial62(1).scaleMax=-2;
trackData.JW4Trial62(1).timeOffsetMotionCaptureToTrack_sec=-2.0571;
trackData.JW4Trial62(1).notes='';
trackData.JW4Trial62(1).inlinerMotionCaptureRFTrack=[];
trackData.JW4Trial62(1).maxSearchLagForOptimum_sample=[];

% MO4Trial62 - no motion capture data
% MO4Trial63 - no motion capture data

%MO4Trial64
trackData.MO4Trial64(1).calibrateFilename=['MO4Trial64_trackFile_rf_' trackType '.mat'];
trackData.MO4Trial64(1).scaleMax=-2;
trackData.MO4Trial64(1).timeOffsetMotionCaptureToTrack_sec=-2.3571;
trackData.MO4Trial64(1).notes='';
trackData.MO4Trial64(1).inlinerMotionCaptureRFTrack=[];
trackData.MO4Trial64(1).maxSearchLagForOptimum_sample=[];

%MO4Trial65
trackData.MO4Trial65(1).calibrateFilename=['MO4Trial65_trackFile_rf_' trackType '.mat'];
trackData.MO4Trial65(1).scaleMax=-2;
trackData.MO4Trial65(1).timeOffsetMotionCaptureToTrack_sec=-2.3571;
trackData.MO4Trial65(1).notes='';
trackData.MO4Trial65(1).inlinerMotionCaptureRFTrack=[];
trackData.MO4Trial65(1).maxSearchLagForOptimum_sample=[];

%MO4Trial66
trackData.MO4Trial66(1).calibrateFilename=['MO4Trial66_trackFile_rf_' trackType '.mat'];
trackData.MO4Trial66(1).scaleMax=-2;
trackData.MO4Trial66(1).timeOffsetMotionCaptureToTrack_sec=-1.9714;
trackData.MO4Trial66(1).notes='';
trackData.MO4Trial66(1).inlinerMotionCaptureRFTrack=[];
trackData.MO4Trial66(1).maxSearchLagForOptimum_sample=[];

%NH4Trial4
trackData.NH4Trial4(1).calibrateFilename=['NH4Trial4_trackFile_rf_' trackType '.mat'];
trackData.NH4Trial4(1).scaleMax=-2;
trackData.NH4Trial4(1).timeOffsetMotionCaptureToTrack_sec=-2.5238;
trackData.NH4Trial4(1).notes='';
trackData.NH4Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.NH4Trial4(1).maxSearchLagForOptimum_sample=[];

%NH4Trial5
trackData.NH4Trial5(1).calibrateFilename=['NH4Trial5_trackFile_rf_' trackType '.mat'];
trackData.NH4Trial5(1).scaleMax=-2;
trackData.NH4Trial5(1).timeOffsetMotionCaptureToTrack_sec=-2.7619;
trackData.NH4Trial5(1).notes='';
trackData.NH4Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.NH4Trial5(1).maxSearchLagForOptimum_sample=[];

%NH4Trial6
trackData.NH4Trial6(1).calibrateFilename=['NH4Trial6_trackFile_rf_' trackType '.mat'];
trackData.NH4Trial6(1).scaleMax=-2;
trackData.NH4Trial6(1).timeOffsetMotionCaptureToTrack_sec=-2;
trackData.NH4Trial6(1).notes='';
trackData.NH4Trial6(1).inlinerMotionCaptureRFTrack=[];
trackData.NH4Trial6(1).maxSearchLagForOptimum_sample=[];

%RR4Trial3
trackData.RR4Trial3(1).calibrateFilename=['RR4Trial3_trackFile_rf_' trackType '.mat'];
trackData.RR4Trial3(1).scaleMax=-2;
trackData.RR4Trial3(1).timeOffsetMotionCaptureToTrack_sec=-2.8714;
trackData.RR4Trial3(1).notes='';
trackData.RR4Trial3(1).inlinerMotionCaptureRFTrack=[];
trackData.RR4Trial3(1).maxSearchLagForOptimum_sample=[];


%RR4Trial4
trackData.RR4Trial4(1).calibrateFilename=['RR4Trial4_trackFile_rf_' trackType '.mat'];
trackData.RR4Trial4(1).scaleMax=-2;
trackData.RR4Trial4(1).timeOffsetMotionCaptureToTrack_sec=-2.7714;
trackData.RR4Trial4(1).notes='';
trackData.RR4Trial4(1).inlinerMotionCaptureRFTrack=[];
trackData.RR4Trial4(1).maxSearchLagForOptimum_sample=[];

%RR4Trial5
trackData.RR4Trial5(1).calibrateFilename=['RR4Trial5_trackFile_rf_' trackType '.mat'];
trackData.RR4Trial5(1).scaleMax=-2;
trackData.RR4Trial5(1).timeOffsetMotionCaptureToTrack_sec=-3.1571;
trackData.RR4Trial5(1).notes='';
trackData.RR4Trial5(1).inlinerMotionCaptureRFTrack=[];
trackData.RR4Trial5(1).maxSearchLagForOptimum_sample=[];

%ZH4Trial55
trackData.ZH4Trial55(1).calibrateFilename=['ZH4Trial55_trackFile_rf_' trackType '.mat'];
trackData.ZH4Trial55(1).scaleMax=-0.75;
trackData.ZH4Trial55(1).timeOffsetMotionCaptureToTrack_sec=-2.5079;
trackData.ZH4Trial55(1).notes='';
trackData.ZH4Trial55(1).inlinerMotionCaptureRFTrack=[];
trackData.ZH4Trial55(1).maxSearchLagForOptimum_sample=[];