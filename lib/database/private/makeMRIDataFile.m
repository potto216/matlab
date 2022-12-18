clear
clear class

% subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
% subject.gmu.id='MRUS011_V1';
% subject.nih.id='SID5005R_9_26_2014_RF';
% subject.series(1).tag='Ser8';
% subject.series(end).source.excel.filename='SID5005R_9_26_2014_RF.xlsx';
% subject.series(end).source.excel.worksheet=subject.series(end).tag;
% subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
% subject.series(end).source.excel.ts_sec=1/12;
% subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
% subject.series(end).source.excel.startRegionLabel='RF_R1_c1';

searchPath={};
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS003');
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS004');
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS005');
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS006');
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS007');
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS008');
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS009');
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS010');
searchPath{end+1}=fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS011');

%% Load all the data
mriObj = MRIDatabase();
loadDataFromSpreadsheet=true;
sourcedataFilename='createMFileFromSpreadsheet.m';
mriMatFilename='E:\Users\potto\ultraspeck\workingFolders\potto\MATLAB\muscleTracking\rectusFemoris\mritoolbox\mriData.mat';
if loadDataFromSpreadsheet
    mriObj.load(sourcedataFilename,searchPath);
    mriObj.save(mriMatFilename);
else
    mriObj.load(mriMatFilename);
    
end

mriDataInitial=mriObj.initializeRoiStruct('SID9319R_9_26_2014_RF',5);


mriData=mriObj.getRoi('SID9319R_9_26_2014_RF','dataBlockObj',[], 'imagePlane',[],'distanceMeasure',[],'showPlot',false,'roi',[5]);
    
% mriDB=[];
% for ss=1:length(subjectList)
%     isSubjectFound=false;
%     subject=subjectList(ss);
%     for ii=1:length(searchPath)
%         fulldatafilePath=fullfile(searchPath{ii},subject.series(end).source.excel.filename);
%         if exist(fulldatafilePath,'file')
%             data=loadMriExcelSheet(fulldatafilePath, ...
%                 subject.series(end).source.excel.worksheet, ...
%                 subject.series(end).source.excel.velocityMeasurementsPerRegion, ...
%                 subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel, ...
%                 subject.series(end).source.excel.startRegionLabel);
%             mriDB(ss).subject=subject;
%             mriDB(ss).data=data;
%             isSubjectFound=true;
%             break;
%         end
%     end
%     if ~isSubjectFound
%         error(['Unable to find ' subject.series(end).source.excel.filename]);
%     else
%         %do nothing
%     end
% end