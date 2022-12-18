%This function loads a track block that was created with createTrackBlock
%
%trackFilename - must be in the path specifed by the caseFile.  Also it
%should be just the filename and not the path.
%if trackFilename is empty it will load the most recent track
%
%trackFilenameFilter - This is the filter to use if the trackfilename will
%match multiple values, and it can take the values:
%'mostRecentAdaptFixed' - show the most recent adapt or fixed to select from.
%'mostRecentAdapt' - uses the most recent adapt file.
%'mostRecentFixed' - uses the most recent fixed file
%'mostRecent' - uses the most recent file (either adapt/fixed).  Default
%OUTPUT
%trackFilename - the trackfile actually loaded.
function [roiList,roiOut,lattice,commentTag,trackFilename]=loadTrackBlock(caseFile,trackFilename,trackFilenameFilter)
[metadata]=loadCaseData(caseFile);

switch(nargin)
    case 1
        trackFilename=[];
        trackFilenameFilter='mostRecent';
    case 2
        trackFilenameFilter='mostRecent';
    case 3
        %do nothing
    otherwise
        error('invalid number of input arguments')
end


baseTrackBlockName='Speckle1DTrack';
currentFileIndex=[];

if ~isempty(trackFilename)
    [pathStr,name,ext] = fileparts(trackFilename);
    if ~isempty(pathStr)
        error(['trackFilename cannot include the file path because that is given by the case info'])
    end
else
    %do nothing
end


currentFile=dir(fullfile(getCasePathField(metadata,'motionPath'),[baseTrackBlockName '_*' '.mat']));

if isempty(currentFile)
    error(['No track files were found in ' metadata.motionPath]);
end

if isempty(trackFilename)  && (length(currentFile)==1)
    %do nothing you are good to go.
    currentFileIndex=1;
elseif isempty(trackFilename) && (length(currentFile)>1)
    
    %The format is ROITrack_20100907095111.mat
    %The idea is to find the most recent file
    timeStampStr=regexp({currentFile.name},[baseTrackBlockName '_(?<stamp>\d{14})\.mat'],'tokens');
    timeStampNum=cellfun(@(x) str2num(x{1}{1}),timeStampStr,'UniformOutput',true);
    [timeStampNumSortVal,timeStampNumSortIdx]=sort(reshape(timeStampNum,[],1),1,'descend');
    
    switch(trackFilenameFilter)
        case 'mostRecentAdaptFixed'
            currentFileLatticeType=cell(length(currentFile),1);
            for ii=1:length(currentFile)
                
                lat=load(fullfile(getCasePathField(metadata,'motionPath'),currentFile(ii).name),'latticeFilename');
                if ~isfield(lat,'latticeFilename')
                    error(['Unable to find the field latticeFilename in ' fullfile(getCasePathField(metadata,'motionPath'),currentFile(ii).name)]);
                end
                [fp,fbn,fe]=fileparts(lat.latticeFilename);
                r=load(fullfile(getCasePathField(metadata,'latticePath'),[fbn fe]),'latticeGenerationFunction');
                if ~isfield(r,'latticeGenerationFunction')
                    error(['Unable to find the field latticeGenerationFunction in ' fullfile(getCasePathField(metadata,'latticePath'),[fbn fe])]);
                end
                switch(r.latticeGenerationFunction.name)
                    case 'createLattice'
                        currentFileLatticeType{ii}='Fixed';
                    case 'createAdaptiveLattice'
                        currentFileLatticeType{ii}='Adapt';
                    otherwise
                        error(['Unsupported lattice type of ' r.latticeGenerationFunction.name]);
                end
            end
            isFixedSorted=strcmp('Fixed',currentFileLatticeType(timeStampNumSortIdx));
            firstFixedIndex=find(isFixedSorted==true,1,'first');
            firstAdaptIndex=find(isFixedSorted==false,1,'first');
            
            adaptButtonText=['Adapt ' currentFile(timeStampNumSortIdx(firstAdaptIndex)).name];
            fixedButtonText=['Fixed ' currentFile(timeStampNumSortIdx(firstFixedIndex)).name];
            % Construct a questdlg with three options
            choice = questdlg('Would you like the most recent Adaptive or Fixed run?', ...
                'Run Select', ...
                adaptButtonText,fixedButtonText,adaptButtonText);
            
            if isempty(choice)
                error('no choice selected')
            end            
            % Handle response
            switch choice
                case adaptButtonText
                    currentFileIndex=timeStampNumSortIdx(firstAdaptIndex);
                case fixedButtonText
                    currentFileIndex=timeStampNumSortIdx(firstFixedIndex);
                otherwise
                    error(['Invalid choice of (this should not be possible)' choice])
            end                                    
            
        case 'mostRecentAdapt'
            error('Not implemented yet');
        case 'mostRecentFixed'
            error('Not implemented yet');
        case 'mostRecent'
            currentFileIndex=timeStampNumSortIdx(1);
        otherwise
            error(['Invalid trackFilenameFilter of ' trackFilenameFilter]);
    end
    
    
    
else
    currentFileIndex=strmatch(trackFilename,{currentFile.name});
    if isempty(currentFileIndex) || length(currentFileIndex)~=1
        error(['Tried to find ' trackFilename ' but found: ' currentFile(currentFileIndex).name])
    end
    
    
end

if isempty(currentFileIndex)
    error('currentFileIndex is empty and not a valid value')
end

%% Load the results
trackFilename=fullfile(getCasePathField(metadata,'motionPath'),currentFile(currentFileIndex).name);
load(trackFilename,'roiList','roiOut','lattice','commentTag','compute1DSpeckleTrackOptions');

end