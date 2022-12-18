%sf=getCaseAxialSampleRate - returns data sample frequency in samples per second.
%
%INPUT
%caseData - The data in the case.
%
%OUPUT
%sf - the data rate in samples per second.
%
function sf=getCaseAxialSampleRate(caseData)
caseData=loadCaseData(caseData);
sf=caseData.rf.header.sf;
