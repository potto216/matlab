error('This needs to be turned into a function')
%clear all
clear
clear global
close all

%% setup data and case information
caseStrList={};
caseStrList{end+1}='ZH2Trial33';
caseStrList{end+1}='ZH2Trial34';
caseStrList{end+1}='ZH2Trial35';
caseStrList{end+1}='ZH3Trial2';
caseStrList{end+1}='DW2Trial62';
caseStrList{end+1}='DW2Trial63';
caseStrList{end+1}='DW3Trial3';
caseStrList{end+1}='DW3Trial4';
caseStrList{end+1}='MJ2Trial1';
caseStrList{end+1}='MJ2Trial2';
caseStrList{end+1}='MJ2Trial3';
caseStrList{end+1}='MJ3Trial2';
caseStrList{end+1}='MJ3Trial3';
caseStrList{end+1}='MJ3Trial4';


outputPath='C:\Documents and Settings\potto\My Documents\data\SpeckleTrack1D\ZH2Trial35';



%% process a block
for ii=1:length(caseStrList);
caseStr=caseStrList{ii}
%caseStr='ZH2Trial35';
%caseStr='ZH2Trial33';


caseFile=fullfile('C:\Documents and Settings\potto\My Documents\data\caseFiles\', [caseStr '.m']);

[metadata]=loadCaseData(caseFile);
delete(fullfile(metadata.Speckle1DTrackPath,['ROITrack_*' '.mat']));


end

