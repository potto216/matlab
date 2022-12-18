function objFieldII=objFieldIIPackageGetFilenameScanLine(objFieldII,timeStep,scanLineNumber)
%This function will return the scan line filename number for for a
%particular time step and scanline
%type of data will be written.  In this function the old directory will be removed 
%and recreated.
%WARNING: If running the code in parallel mode make sure this function is being called outside of 
%the parfor command.
%
%Currently the default values are:
%
%overwritePackage - <true>.  This allows the package directory to be
%overwritten if it exists.  All previous files will be removed.
%
%saveObj - The object data will  be saved in the root package directory.
%The object is saved at setup.
%


objFieldII.package.filePath=packageFilePath;
objFieldII.package.name=packageName;
objFieldII.package.overwritePackage=true;
objFieldII.package.saveObj=true;
objFieldII.package.timeStepBaseDirname='timeStep_';
objFieldII.package.scanLineBaseFilename='rfScanLine_';

fullPackagePath=fullfile(objFieldII.package.filePath,objFieldII.package.name);

objFieldII.package.filePath=packageFilePath;
objFieldII.package.name=packageName;
objFieldII.package.overwritePackage=true;
objFieldII.package.saveObj=true;

fullPackagePath=fullfile(objFieldII.package.filePath,objFieldII.package.name);

if objFieldII.package.overwritePackage && exist(fullPackagePath,'dir')
    rmdir(fullPackagePath,'s')
else
    %do nothing
end

mkdir(fullPackagePath);

if objFieldII.package.saveObj
    save(fullfile(fullPackagePath,'objFieldII'),'objFieldII');
else
    %do nothing    
end


end