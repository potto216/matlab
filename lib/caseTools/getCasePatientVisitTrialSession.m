%getCasePatientVisitTrialSession returns the information about the case
%which is useful in parsing.
%sessionNum is number of months out
function [patientID,visitID,trialID,sessionNum, isNormalPatientFileFormat]=getCasePatientVisitTrialSession(caseData)

caseStr=getCaseName(caseData);
isNormalPatientFileFormat=~isempty(strfind(caseStr,'_'));

%detemine
if isNormalPatientFileFormat
    parsedCaseStr=regexp(caseStr,'(?<patientID>[A-Za-z0-9]+)_(?i)visit(?-i)(?<visitID>\d{1,2})_(?i)trial(?-i)(?<trialID>\d{1,2})','names');
else
    parsedCaseStr=regexp(caseStr,'(?<patientID>[A-Za-z]{1,2})(?<visitID>\d{1,2})(?i)Trial(?-i)(?<trialID>\d{1,2})','names');
end

patientID=parsedCaseStr.patientID;
visitID=str2double(parsedCaseStr.visitID);
trialID=str2double(parsedCaseStr.trialID);


switch(visitID)
    case 1
        if isNormalPatientFileFormat
            sessionNum=1;
        else
            error('There should be no ultrasound collect for this session.')
        end
    case 2
        sessionNum=3;
    case 3
        sessionNum=4;
    case 4
        sessionNum=7;
    case 5
        sessionNum=10; %#ok<NASGU>
        error('There should be no ultrasound collect for this session.')
    otherwise
        error('Invalid visit number')
        
        
end

end