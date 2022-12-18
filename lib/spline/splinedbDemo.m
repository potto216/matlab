%% Load data
casePath='C:\Documents and Settings\Potto\My Documents\data\caseFiles';
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

%% run spline list
for ii=5:length(caseStrList)
md=loadCaseData(fullfile(casePath,[caseStrList{ii} '.m']));
splinedbInsert(md)
end

%% Run one case
ii=strmatch('MJ2Trial3',caseStrList)
md=loadCaseData(fullfile(casePath,[caseStrList{ii} '.m']));
splinedbSelect(md)
splinedbInsert(md)

