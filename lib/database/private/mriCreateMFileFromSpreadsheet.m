%% Subject 003 Tag: ?
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS003_V1';
subject.nih.id='SID3797_5_02_2013_RF_VI_RF';
subject.series(1).tag='Ser4 PC';
subject.series(end).source.excel.filename='SID3797_5_02_2013_RF_VI_RFOverwrite.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='R1_c1';
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList=subject; %MUST ADD the subject to the list

%% Subject: 004 Tag: Ser12 PC
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS004_V1';
subject.nih.id='SID5888L_11_17_2013_RF_VI';
subject.series(1).tag='Ser12 PC';
subject.series(end).source.excel.filename='SID5888L_11_17_2013_RF_VI_edit.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='RF_R4_c1';  
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList(end+1)=subject; %MUST ADD the subject to the list

%% Subject: 005 Tag: Ser14 PC     
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS005_V1';
subject.nih.id='SID6337L_11_17_2013_RF_VI';
subject.series(1).tag='Ser14 PC';
subject.series(end).source.excel.filename='SID6337L_11_17_2013_RF_VI.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='RF_R3_c1';  
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList(end+1)=subject; %MUST ADD the subject to the list

%% Subject: 006 Tag: 8476_Ser11 PC     
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS006_V1';
subject.nih.id='SID8476_11_17_2013_RF_VI';
subject.series(1).tag='8476_Ser11 PC';
subject.series(end).source.excel.filename='SID8476_11_17_2013_RF_VI_new_edit.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList(end+1)=subject; %MUST ADD the subject to the list

%% Subject 007 Tag: Ser9 PC  
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS007_V1';
subject.nih.id='SID9159R_9_19_2014_RF';
subject.series(1).tag='Ser9 PC';
subject.series(end).source.excel.filename='SID9159R_9_19_2014_RF.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList(end+1)=subject; %MUST ADD the subject to the list

%% Subject 008 Tag: Ser6 PC
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS008_V1';
subject.nih.id='SID4957R_9_19_2014_RF';
subject.series(1).tag='Ser6 PC';
subject.series(end).source.excel.filename='SID4957R_9_19_2014_RF2_edit.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList(end+1)=subject; %MUST ADD the subject to the list

%% Subject 009 Tag: Ser8
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS009_V1';
subject.nih.id='SID7515R_9_26_2014_RF';
subject.series(1).tag='Ser8';
subject.series(end).source.excel.filename='SID7515R_9_26_2014_RF_v2.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList(end+1)=subject; %MUST ADD the subject to the list

%% Subject 010 Tag: Ser9 3rd analysis
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS010_V1';
subject.nih.id='SID9319R_9_26_2014_RF';
subject.series(1).tag='Ser9 3rd analysis';
subject.series(end).source.excel.filename='SID9319R_9_26_2014_RF_v2.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList(end+1)=subject; %MUST ADD the subject to the list

%% Subject 011 Tag: Ser8
subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
subject.gmu.id='MRUS011_V1';
subject.nih.id='SID5005R_9_26_2014_RF';
subject.series(1).tag='Ser8';
subject.series(end).source.excel.filename='SID5005R_9_26_2014_RF.xlsx';
subject.series(end).source.excel.worksheet=subject.series(end).tag;
subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
subject.series(end).source.excel.ts_sec=1/12;
subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
subject.series(end).source.excel.isFlexion(1:12)=true; 
subject.series(end).source.excel.defaultRoi=5;
subjectList(end+1)=subject; %MUST ADD the subject to the list

%*********************THIS IS THE TEMPLATE FOR A NEW ENTRY**********************
% %% Subject 00? Tag: ?
% subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
% subject.gmu.id='MRUS00?_V1';
% subject.nih.id='??';
% subject.series(1).tag='??';
% subject.series(end).source.excel.filename='??';
% subject.series(end).source.excel.worksheet=subject.series(end).tag;
% subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
% subject.series(end).source.excel.ts_sec=1/12;
% subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
% subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
% subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
% subject.series(end).source.excel.isFlexion(1:12)=true; 
% subject.series(end).source.excel.defaultRoi=5;
% subjectList(end+1)=subject; %MUST ADD the subject to the list
%