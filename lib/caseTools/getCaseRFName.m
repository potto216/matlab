%[rfFilename]=getCaseRFName - returns RF filename to load the data
%INPUT
%caseData - The data in the case.
%
%OUTPUT
%rfFilename - the filename of the rf ultrasound data
%
function [rfFilename]=getCaseRFName(caseData)
caseData=loadCaseData(caseData);
rfFilename=caseData.rfFilename;

end