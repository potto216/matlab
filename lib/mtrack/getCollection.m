%This function configures the processing function to be able to open
%different data types for use by the tracker.
%
%Field II data it assumes that a sqrt function should be applied to the
%magnitude data to account for the attenuatuion through the tissue
%trialData=loadMetadata([p.Results.trialName '.m']);
%dataBlockObj=getCollection(loadMetadata(['MRUS006_V1_S1_T5.m']),'col_ultrasound_rf')
%dataBlockObj=getCollection(loadMetadata(['.m']),'col_ultrasound_bmode')
%dataBlockObj=getCollection(loadMetadata(['.m']),'col_ultrasound_bmode','dataBlockObj_cacheMethod','none');
%Also data processing options can be specified to control how the data is
%loaded and adjust computational requirements.
%
%dataBlockObj_cacheMethod - This is the cached method used by
%DataBlockObj.  It defaults to 'all' if not specifed.  'all' may be too large
%for large data files. so 'none' maybe a better choice to reduce memory
%needs.
function dataBlockObj=getCollection(trialData,nodeName,varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('dataBlockObj_cacheMethod','all',@(x) any(strcmp(x,{'auto','all','none'})))
p.parse(varargin{:});
dataBlockObj_cacheMethod=p.Results.dataBlockObj_cacheMethod;


node=tFindNode(trialData,nodeName);
if isempty(node)
    error(['Unable to find the node: ' nodeName]);
else
    data=node.object(trialData);
end

if strcmp(char(data.source),'@(x)x.collection.fieldii.bmode') ...
        && tIsBranch(trialData,'collection.fieldii.bmode.filepath')
    
    %we need to determine what is available to track
    [directoryName]=tCreateDirectoryName(trialData.collection.fieldii.bmode.filepath,'createDirectory',false);
    
    sourceDataFilename=dirPlus(fullfile(directoryName,'*.mat'),'relativePath',false);
    if length(sourceDataFilename)==0
        error('No data files were found.');
    elseif length(sourceDataFilename)~=1
        error('There can only be one data file per directory for now.');
    end
    
    [phantomInfoDirectoryName]=tCreateDirectoryName(trialData.collection.fieldii.rf.filepath,'createDirectory',false);
    tmp=load(fullfile(phantomInfoDirectoryName,trialData.collection.fieldii.name,'objPhantom.mat'),'objPhantom');
    objPhantom=tmp.objPhantom;
    
    [ dataBlockObjKeyIdx ] = findKeyInPairList( objPhantom.phantomArguments,'DataBlockObj' );
    dataBlockObjValueIdx=dataBlockObjKeyIdx+1;
    
    sourceData=load(sourceDataFilename{1});
    dataBlockObjMetadata.scale.lateral.value=getCaseRFUnits(objPhantom.phantomArguments{dataBlockObjValueIdx}.metadata.ultrasound,'lateral','mm');
    dataBlockObjMetadata.scale.lateral.units='mm';
    dataBlockObjMetadata.scale.axial.value=getCaseRFUnits(objPhantom.phantomArguments{dataBlockObjValueIdx}.metadata.ultrasound,'axial','mm');
    dataBlockObjMetadata.scale.axial.units='mm';
    dataBlockObjMetadata.ultrasound=objPhantom.caseData.metadata.ultrasound;
    
    %cahnged from imBlock to finalBlock
    dataBlockObj=DataBlockObj(sourceData.im.finalBlock,'matlabArray','metadataMaster',dataBlockObjMetadata);
    dataBlockObj.open();
    
    processFunction=@(x) abs(x).^0.5;
    dataBlockObj.newProcessStream('agentLab',processFunction, true);
    
    
    regionInformation=RegionInformation();
    regionInformation.addRegionFromTrialData('collection.fieldii.bmode',dataBlockObj,trialData);
    dataBlockObj.regionInformation=regionInformation;
    
elseif strcmp(char(data.source),'@(x)x.collection.ultrasound.bmode') ...
        && tIsBranch(trialData,'collection.ultrasound.bmode.fullfilename')
    
    obj=data.source(trialData);
    if ~isfield(obj,'filetype')
        filetype='ultrasonics_bmode';
    else
        filetype=obj.filetype;
    end
    
    openArgs={'frameFormatComplex',false};
    
    if isfield(obj,'override')
        dataBlockObjMetadata=obj.override;
    else
        %else do nothing
    end
    
    dataBlockObjMetadata.scale=obj.scale;
    switch(filetype)
        case 'ultrasonics_bmode'
            dataBlockObj=DataBlockObj(obj.fullfilename,@uread,'openArgs',openArgs,'metadataMaster',dataBlockObjMetadata);
            
        case 'matlab_mat'
            d=load(obj.fullfilename);
            dataBlockObj=DataBlockObj(d.imBlock,'matlabArray','metadataMaster',dataBlockObjMetadata);
            
        case 'readImageBlock_usImageFileMethod1'
            [d.imBlock] = readImageBlock(obj.fullfilename,'usImageFileMethod1');
            dataBlockObj=DataBlockObj(d.imBlock,'matlabArray','metadataMaster',dataBlockObjMetadata);
            
        case 'readImageBlock_usImageFileMethod2'
            [d.imBlock] = readImageBlock(obj.fullfilename,'usImageFileMethod2');
            dataBlockObj=DataBlockObj(d.imBlock,'matlabArray','metadataMaster',dataBlockObjMetadata);
        otherwise
            error(['Unsupported file method of ' filetype]);
    end
    
    dataBlockObj.open('cacheMethod',dataBlockObj_cacheMethod);
    processFunction=@(x) x;
    dataBlockObj.newProcessStream('agentLab',processFunction, true);
    
    
    regionInformation=RegionInformation();
    regionInformation.addRegionFromTrialData('collection.ultrasound.bmode',dataBlockObj,trialData);
    dataBlockObj.regionInformation=regionInformation;
    
elseif strcmp(char(data.source),'@(x)x.collection.ultrasound.rf') ...
        && tIsBranch(trialData,'collection.ultrasound.rf.fullfilename')
    
    obj=data.source(trialData);
    openArgs={'frameFormatComplex',true};
    dataBlockObj=DataBlockObj(obj.fullfilename,@uread,'openArgs',openArgs);
    dataBlockObj.open('cacheMethod',dataBlockObj_cacheMethod);
    processFunction=@(x) abs(x).^0.5;
    dataBlockObj.newProcessStream('agentLab',processFunction, true);
    
    
    regionInformation=RegionInformation();
    regionInformation.addRegionFromTrialData('collection.ultrasound.rf',dataBlockObj,trialData);
    dataBlockObj.regionInformation=regionInformation;
    
elseif strcmp(char(data.source),'@(x)x.collection.projection') ...
        && tIsBranch(trialData,'collection.projection.filepath')
    
    
    %% Load the data set
    [directoryName]=tCreateDirectoryName(trialData.collection.projection.bmode.filepath,'createDirectory',false);
    switch(trialData.collection.projection.bmode.filetype)
        case 'image_seq'
            openArgs = {trialData.collection.projection.bmode.file.nameMask, ...
                trialData.collection.projection.bmode.file.format, ...
                trialData.collection.projection.bmode.file.sequence};
            
            dataBlockObjMetadata=[];
            dataBlockObjMetadata.scale=trialData.collection.projection.bmode.scale;
            dataBlockObjMetadata.ultrasound=trialData.collection.projection.bmode.override.ultrasound;
            
            dataBlockObj=DataBlockObj(directoryName,'imread','openArgs',openArgs,'metadataMaster',dataBlockObjMetadata);
            dataBlockObj.open();
        case 'matlab_mat'
            sourceDataFilename=dirPlus(fullfile(directoryName,'*.mat'),'relativePath',false);
            if length(sourceDataFilename)~=1
                error('There can only be one data file per directory for now.');
            end
            sourceData=load(sourceDataFilename{1});
            
            [phantomInfoDirectoryName]=tCreateDirectoryName(trialData.subject.phantom.filepath,'createDirectory',false);
            tmp=load(fullfile(phantomInfoDirectoryName,'phantomMasterDataFile.mat'),'objPhantom');
            objPhantom=tmp.objPhantom;
            
            %% setup the basic imaging parameters
            dataBlockObjMetadata.scale.lateral.value=getCaseRFUnits(objPhantom.caseData.metadata.ultrasound,'lateral','mm');
            dataBlockObjMetadata.scale.lateral.units='mm';
            dataBlockObjMetadata.scale.axial.value=getCaseRFUnits(objPhantom.caseData.metadata.ultrasound,'axial','mm');
            dataBlockObjMetadata.scale.axial.units='mm';
            dataBlockObjMetadata.ultrasound=objPhantom.caseData.metadata.ultrasound;
      
            
            if(isstruct(sourceData.imBlock))
                imBlock=sourceData.imBlock.finalBlock;
            else
                imBlock=sourceData.imBlock;
            end
            dataBlockObj=DataBlockObj(imBlock,'matlabArray','metadataMaster',dataBlockObjMetadata);
            dataBlockObj.open();
        otherwise
            error(['Cannot load images because of the unsupported file type of ' trialData.collection.projection.bmode.filetype]);
    end
    
    
    processFunction=@(x) x;
    dataBlockObj.newProcessStream('agentLab',processFunction, true);
    
    regionInformation=RegionInformation();
    regionInformation.addRegionFromTrialData('collection.projection.bmode',dataBlockObj,trialData);
    dataBlockObj.regionInformation=regionInformation;
    
else
    error(['Please finish for data source ' char(data.source)])
    
end

end

