%fps=getCaseDataFrameRate - returns data frame rate in frames per second.
%
%INPUT
%caseData - The data in the case.
%dataType - a string which indicates the valid data type.  This can be:
%   'rf' - ultrasound RF data
%   'ir' - IR motion capture data
%
%OUPUT
%fps - the data rates frame per second.
%
function fps=getCaseDataFrameRate(caseData,dataType)
caseData=loadCaseData(caseData);

switch(dataType)
    case 'rf'        
        header=ultrasonixGetInfo( caseData.rfFilename);
        fps=header.dr; % assumed in frames per second
    case 'ir'
        fps=caseData.irFPS;
    otherwise
        error(['Unsupported data type of ' dataType]);
end