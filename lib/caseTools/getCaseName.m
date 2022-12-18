%getCaseName returns the case name from the metadata structure.
%The casename is the filename without the extension.
%If the file is just a raw datafile with no metafile attached then the raw
%data file name is returned
function caseStr=getCaseName(caseData)
metadata=loadCaseData(caseData);
if ~isfield(metadata,'sourceMetaFilename')
    error('sourceMetaFilename needs to exist.');
else
    if ~isempty(metadata.sourceMetaFilename)
        [filePath,caseStr,fileExt]=fileparts(metadata.sourceMetaFilename);    
    else
        [filePath,caseStr,fileExt]=fileparts(metadata.rfFilename);
    end
end


end