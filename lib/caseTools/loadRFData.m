%This function will file and RF file and return the caseData structure for
%use with other programs.
%
function caseData=loadRFData(fname)

switch(nargin)
    case 0
        [filename pathname] =uigetfile('*.*','Pick a data file');
        fname = strcat(pathname, filename);
    case 1
        if  ~ischar(fname)
            error('fname must be a string of the full filename')
        end
    otherwise
        error('Invalid number of input arguments.')
end

caseData.sourceMetaFilename=[];
caseData.validFramesToProcess=[];
%*********Set new values here*************
caseData.rfFilename=fname;

[~, caseData.rf.header]=uread(caseData.rfFilename,-1);

caseData.rf.probeModel=caseData.rf.header.probeInfo.name;

if strcmp(caseData.rf.probeModel,'L14-5W/60') && caseData.rf.header.ld==256
	caseData.decimateFactor=2;
else
	caseData.decimateFactor=1;
end

end