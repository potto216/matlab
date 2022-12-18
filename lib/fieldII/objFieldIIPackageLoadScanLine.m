function [rfData, tstart_sec]=objFieldIIPackageLoadScanLine(objFieldII,timeStep,scanLineNumber,directoryMappings)
%This function will load a scan line and retrieve its data.
%OUTPUT:
%
%rfData - The actual rf data for the scan line.  If empty it did not exist
%
%tstart_sec - The time where the RF data starts.  If empty it did not exist
%
fullScanLinePath=fullfile(objFieldII.package.filePath,objFieldII.package.name,[objFieldII.package.timeStepBaseDirname num2str(timeStep)],'scanLine');
fullScanLineFilename=fullfile(fullScanLinePath,[objFieldII.package.scanLineBaseFilename num2str(scanLineNumber)]);

rfData=[];
tstart_sec=[];

if ~exist(fullScanLineFilename,'file')
    d=load(fullScanLineFilename,'fullScanLineFilename','timeStep','scanLineNumber','placeHolderFile','rfData', 'tstart_sec');
    if d.placeHolderFile
        error('This is a placeholder file.')
    else
        rfData=d.rfData;
        tstart_sec=d.tstart_sec;
    end    
    
else
    %do nothing
end


end