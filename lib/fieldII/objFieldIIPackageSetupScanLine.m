function [scanLineStarted, failReason]=objFieldIIPackageSetupScanLine(objFieldII,timeStep,scanLineNumber)
%This function will attempt to setup a new scanline by resevring the filename.  
%However the call will fail if the scan line is already started.  This
%normally occurs when the code is being run in parallel mode.  This
%function will also create the correct directory structure for where to
%save the scan lines
%INPUT:
%timeStep - This is the time step number to use when saving the data
%
%scanLineNumber - This is the particular scan line which is active.
%
%OUTPUT:
%scanLineStarted - this is true if a scan line placeholder was created, and
%false if it was not
%
%failReason - this is a string that contains the reason for failing.  If there
%was success then the value will be empty.  The valid reasons are:
%'fileExists' - The file already exists.

fullScanLinePath=fullfile(objFieldII.package.filePath,objFieldII.package.name,[objFieldII.package.timeStepBaseDirname num2str(timeStep)],'scanLine');
fullScanLineFilename=fullfile(fullScanLinePath,[objFieldII.package.scanLineBaseFilename num2str(scanLineNumber)]);


    if ~exist(fullScanLinePath,'dir')
        mkdir(fullScanLinePath)
        if ~exist(fullScanLinePath,'dir')
            error(['Could not make the dir: ' fullScanLinePath]);
        end
    else
        
    end
    
    placeHolderFile=true;
    failReason='*';
    
    if ~exist(fullScanLineFilename,'file')
       save(fullScanLineFilename,'fullScanLineFilename','timeStep','scanLineNumber','placeHolderFile');
       scanLineStarted=true;
       failReason=[];
    else        
        scanLineStarted=false;
        failReason='fileExists';
    end
    
end