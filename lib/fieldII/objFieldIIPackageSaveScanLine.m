function [scanLineSaved]=objFieldIIPackageSaveScanLine(objFieldII,timeStep,scanLineNumber,rfData, tstart_sec,extraData)
%This function will save a scan line and by default will not check if
%another file exists and the type of data it contains.  The program will
%simply overwrite it.
%INPUT:
%timeStep - This is the time step number to use when saving the data
%
%scanLineNumber - This is the particular scan line which is active.
%
%rfData - The actual rf data for the scan line
%
%tstart_sec - The time where the RF data starts
%
%extraData - should be a cell array of any extra values used.  Save in pair
%value format.
%
%OUTPUT:
%scanLineSaved - This indicates if the scan line was saved or not.


fullScanLinePath=fullfile(objFieldII.package.filePath,objFieldII.package.name,[objFieldII.package.timeStepBaseDirname num2str(timeStep)],'scanLine');
fullScanLineFilename=fullfile(fullScanLinePath,[objFieldII.package.scanLineBaseFilename num2str(scanLineNumber)]);


if ~exist(fullScanLinePath,'dir')
    scanLineSaved=false;
    error([fullScanLinePath ' should have been already created.']);
else
    placeHolderFile=false;
    save(fullScanLineFilename,'fullScanLineFilename','timeStep','scanLineNumber','placeHolderFile','rfData', 'tstart_sec','objFieldII','extraData');
    scanLineSaved=true;
end


end