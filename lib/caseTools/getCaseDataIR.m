%[data_deg,fps,t_sec]=getCaseData - returns IR motion capture information
%This can either be from a text file given by caseData.irFilename or it is
%loaded directly from the spreadsheet given in the masterlist
%INPUT
%caseData - The data_deg in the case.
%
%OUTPUT
%data_deg - the ir motion capture data in degrees as a vector.
%fps - the data rates frame per second.
%t_sec - the time in seconds for the ir vector.
%
function [data_deg, fps,t_sec]=getCaseDataIR(caseData)
caseData=loadCaseData(caseData);
fps=caseData.irFPS;

if exist(caseData.irFilename,'file')
    data_deg=dlmread(caseData.irFilename);
else %load from the master list
    [patient,visitNum,trialNum,sessionNum,isNormalPatientFileFormat]=getCasePatientVisitTrialSession(caseData);
    [masterlist.numeric,masterlist.txt,masterlist.raw]=xlsread(caseData.masterlistFilename);
    masterIndexRow=[];
    for ii=1:size(masterlist.raw,1)
         %for .xlsx %if strcmp(masterlist.raw{ii,2},patient) && (masterlist.raw{ii,3}==visitNum) && (masterlist.raw{ii,4}==trialNum)
        %for .xls
         if strcmp(masterlist.raw{ii,1},patient) && (masterlist.raw{ii,2}==visitNum) && (masterlist.raw{ii,3}==trialNum)
            masterIndexRow=ii;
            break;
        end
    end
    
    
    if isempty(masterIndexRow)
        error('Unable to find the visit/trial inforation in the master list.')
    else
        motionCaptureSpreadsheet=fullfile(caseData.motionCaptureSpreadsheetPath,masterlist.raw{masterIndexRow,5}); %6 for .xlsx
    end
    
    
    if isNormalPatientFileFormat
        [d,t,r]=xlsread(motionCaptureSpreadsheet); %#ok<ASGLU>
        trialColumnIdx=[];
        for ii=1:size(r,2)
            searchTrial=['Trial' num2str(trialNum)];
            if strcmp(searchTrial,r{3,ii})
                
                     trialColumnIdx=ii;
                        break;
            end
        end
        dataStartRow=4;
        
    else
        [d,t,r]=xlsread(motionCaptureSpreadsheet); %#ok<ASGLU>
        trialColumnIdx=[];
        for ii=1:size(r,2)
            searchSession=['Session ' num2str(sessionNum)];
            if (length(r{1,ii})>= length(searchSession)) && strcmp(searchSession,r{1,ii}(1:length(searchSession)))
                
                for tt=ii:size(r,2)
                    searchTrial=['Trial' num2str(trialNum,'%02d')];
                    if strcmp(searchTrial,r{2,tt})
                        trialColumnIdx=tt;
                        break;
                    end
                end
            end
        end
        dataStartRow=3;
    end
    
    
    if isempty(trialColumnIdx)
        warning('getCaseDataIR:NoData',['The ir motion capture data_deg for session/trial [' num2str([sessionNum trialNum]) '] was not found'])
        data_deg=[];
    else
        data_deg=cell2mat(r(dataStartRow:end,trialColumnIdx));
        data_deg(isnan(data_deg))=[];        
    end
    
end


t_sec=(0:(length(data_deg)-1)).'/fps;

end