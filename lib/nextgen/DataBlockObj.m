classdef DataBlockObj < handle
    %DATABLOCKOBJ allows a collection of data to be represented as a block.
    %The purpose of the class to provide a consistent interface to access a
    %block of data and provide units of the data.  The blocks can be 3D or 4D.
    %The dimensions of these blocks can have simulatanuous units, such as
    %distance and time.  This class takes care of managing the data of
    %a block when it is spread over multiple files as in the case of volume
    %collects or when the data can only be fully loaded on some machines
    %such as a machine with a lot of memory.
    %
    %This class also provides a stream function which allows the data to be
    %processed by a series of filters or algorithms
    %
    %The types of blocks which can be represented by this class are:
    %
    % 1. 2D images (real or complex) which have been collected over time.  Here
    % the block is 3D with the dimensions being axial, lateral and time.
    % It is important to note that the axial and lateral are often refered in
    % the case of ultrasound as fast time and slow time
    % 2. 3D volumes of data which have been collected over time.
    % These volumes can be collected as a single block or a collection of
    % slices which are formed into a block such as when a 2D array is swept
    % throught a volume.
    %
    %The data is either loaded from disk as requested or it is preloaded on
    %memory.  Data can also be passed in as an array using the open
    %command.  However, if passing in data with an array then metadata
    %(pixel size, etc)needs to still be associatied with the file.
    %
    %The object is designed to be given an open method at initialization
    %and use that throughout the processing
    %
    %All slices and dimensions are in reference to base 1.  This means
    %functions like uread have one subtracted from the slice since it is
    %base 0
    %DEFINITONS
    %a slice is defined as the third dimension
    %
    %===Examples of loading a matrixb===
    %dataBlockObj=DataBlockObj(imBlock,'matlabArray');
    %dataBlockObj.open('cacheMethod','all');
    %processFunction=@(x) x;
    %dataBlockObj.newProcessStream('agentLab',processFunction, true);
    %dataBlockObj.agentLab(dataBlockObj);
    %
    %===Example of loading a bmode file from ultrasonix
    %fullfilename='full filename path'
    %dataBlockObj=DataBlockObj(fullfilename,@uread,'openArgs');
    %dataBlockObj.open('cacheMethod','all');
    %
    %===Example using higher level functions===
    %addpath('E:\Users\potto\ultraspeck\workingFolders\potto\data\subject\mriCompare');
    %trialData=loadMetadata('MRUS007_V1_S1_T2.m');

    %dataBlockObj=getCollection(trialData,'col_ultrasound_bmode');
    
    
    properties (GetAccess = private, SetAccess = private)
        getDataSliceFromDataSource=[];  %This is the built up to read a data slice;
        processStream=struct([])
        activeProcessStreamIndex=[];
        dataBlockDimensions=[];
        metadataMaster=[];  %These values are always applied to any new data set and override the metadata in the dataset
    end
    
    properties (GetAccess = public, SetAccess = private)
        blockSource=[];
        openMethod=[];
        openArgs=[];
        blockSourceDimensions=[];
        blockData=[];  %This holds the cache data.  normally only loaded at startup
        cacheMethod=[];
        activeProcessStreamName=[];  %This is the process stream handle
        activeProcessStreamHandle=[];  %This is the process stream handle
        activeProcessStream=[];  %This is the process stream handle
        activeCaseName=[]; %This is the name of the active case that was loaded
        metadata=[];       %The current metadata
        caseFilenameDeprecated=[];
        
    end
    
    properties (GetAccess = public, SetAccess = public)
        activeVolumeIndex=[];
        regionInformation=[];
    end
    
    events
        NewProcessStreamEvent
    end
    
    methods
        
        function blockSource=get.blockSource(this)
            blockSource=this.blockSource;
        end
        
        function openMethod=get.openMethod(this)
            openMethod=this.openMethod;
        end
        
        function openArgs=get.openArgs(this)
            openArgs=this.openArgs;
        end
        
        function blockSourceDimensions=get.blockSourceDimensions(this)
            blockSourceDimensions=this.blockSourceDimensions;
        end
        
        function blockData=get.blockData(this)
            blockData=this.blockData;
        end
        
        function cacheMethod=get.cacheMethod(this)
            cacheMethod=this.cacheMethod;
        end
        
        function activeVolumeIndex=get.activeVolumeIndex(this)
            activeVolumeIndex=this.activeVolumeIndex;
        end
        
        function set.activeVolumeIndex(this,activeVolumeIndex)
            this.activeVolumeIndex=activeVolumeIndex;
        end
        
        
        function regionInformation=get.regionInformation(this)
            regionInformation=this.regionInformation;
        end
        
        function set.regionInformation(this,regionInformation)
            this.regionInformation=regionInformation;
        end
        
        function activeProcessStreamName=get.activeProcessStreamName(this)
            activeProcessStreamName=this.processStream(this.activeProcessStreamIndex).name;
        end
        
        function activeProcessStreamHandle=get.activeProcessStreamHandle(this)
            activeProcessStreamHandle=this.activeProcessStreamIndex;
        end
        
        function activeProcessStream=get.activeProcessStream(this)
            activeProcessStream=this.processStream(this.activeProcessStreamIndex).func;
        end
        
        function activeCaseName=get.activeCaseName(this)
            %This hadnles the case if the property is accessed without
            %metadata being created
            if isfield(this,'metadata')
                activeCaseName=getCaseName(this.metadata.ultrasound);
            else
                activeCaseName=[];
            end
        end
        
        
    end
    
    methods (Access=public)
        %The constructor will assign a block source and method used to open
        %the block.  Currently blockSource should be a filename with
        %complete path or a 2D or 3D data matrix.  DataBockObj is meant to open files because there
        %needs to be meta information associated with the data.  However in
        %the open command Data
        %
        %blockSource - the filename of the source file or a 2D or 3D data
        %matrix.  If the data is a matrix then it is important to specify a
        %metadataMaster or caseFilenameDeprecated so that the metadata can be
        %loaded.  If this is a data matrix and the property is read back it will be returned as
        %a empty which signals the data cannot be found on disk.
        %
        %blockSource     |  metadataMaster     | Action
        %filename/matrix | data          | apply metadataMaster information over blockSource
        %filename/matrix | none          | use only the meta pulled by
        %                                  blockcSource, or default to ones
        %none            | data          | use the info given by metadataMaster which needs to have the block source
        %none            | none          | prompt user for input
        %The meta information is not applied until the file open is called.
        %
        %openMethod - the method used to open the data, this can be a
        %function handle or a character string.  Valid values are currently
        %{'uread', 'matlabArray'}.  Will default to uread.  Any strings
        % will be converted to the approriate function handle.
        %
        %The valid pair values are:
        %
        %blockSourceDimensions - Limits what data can be loaded. This is
        %valuable when wanting to specify runs through time/volume
        %blocks.
        %This is a cell array where each element
        %corresponds to the valid dimensions in the block.  An integer list
        %coorresponds to the valid source dimensions.  For example: to load
        %30 frames in a set of b-mode images using uread the blockSourceDimensions =
        %{[],[],[1:30],[]}.
        %
        %openArgs - Additional arguments that are passed to the open
        %method. default of empty.  If empty the code tries to figure out
        %the args based on blockSource which should be a character string.  If .rf or .b8 it will
        %use uread to get default parameters.
        %
        %metadataMaster - This can be a filename of the meta data or a cell
        %array which will override settings in the file or data source.
        %
        %caseFilenameDeprecated - The Walkaide data case files.  These
        %should not normally be used
        %
        %EXAMPLES
        %Load an array: d1=DataBlockObj(imSourceReduce,'matlabArray');
        %Default values for metadataMaster will be used
        function dataBlockObj=DataBlockObj(blockSource,openMethod,varargin)
            p = inputParser;   % Create an instance of the class.
            p.addOptional('blockSource',[],@(x) ischar(x) || isnumeric(x));
            p.addOptional('openMethod','uread',@(x) any(strcmp(x,{'uread', 'matlabArray'})) || isa(x,'function_handle'));
            
            p.addParamValue('blockSourceDimensions',{},@(x) iscell(x) && isvector(x));
            p.addParamValue('openArgs',[],@(x) iscell(x) || isempty(x));
            p.addParamValue('caseFilenameDeprecated',[],@ischar);
            p.addParamValue('metadataMaster',[],@(x) isempty(x) | ischar(x) |  isstruct(x));
            
            p.parse(blockSource,openMethod,varargin{:});
            
            %convert to a function handle
            if isa(p.Results.openMethod,'char')
                dataBlockObj.openMethod=str2func(p.Results.openMethod);
            elseif isa(p.Results.openMethod,'function_handle')
                dataBlockObj.openMethod=p.Results.openMethod;
            else
                %do nothing
            end
            
            
            
            if ischar(p.Results.blockSource)
                dataBlockObj.blockSource=p.Results.blockSource;
            elseif isnumeric(p.Results.blockSource)
                dataBlockObj.blockData=blockSource;
                dataBlockObj.blockSource=[];
                if ~strcmp('matlabArray',func2str(dataBlockObj.openMethod))
                    error('When blockSource is numeric then openMethod must be matlabArray');
                else
                    
                    %do nothing
                end
            end
            
            dataBlockObj.blockSourceDimensions=p.Results.blockSourceDimensions;
            dataBlockObj.openArgs=p.Results.openArgs;
            dataBlockObj.caseFilenameDeprecated=p.Results.caseFilenameDeprecated;
            dataBlockObj.metadataMaster=p.Results.metadataMaster;
            
            dataBlockObj.activeProcessStreamIndex=1;
            dataBlockObj.processStream(dataBlockObj.activeProcessStreamIndex).name='none';
            dataBlockObj.processStream(dataBlockObj.activeProcessStreamIndex).func=@(x) x;
            dataBlockObj.processStream(dataBlockObj.activeProcessStreamIndex).type='4d';
            
            dataBlockObj.activeVolumeIndex=1;
            
            %if a block source then read the meta data
            if ~isempty(blockSource)
                if isempty(dataBlockObj.openArgs) && ischar(blockSource)
                    
                    [~,~,filenameExt] = fileparts(blockSource);
                    switch(lower(filenameExt))
                        case {'.rf','.b8'}
                            [~, ~,dataBlockObj.openArgs]=uread(blockSource,-1,'parametersMode','auto');
                        otherwise
                            %do nothing and just skip
                    end
                end
            else
                %do nothing
            end
            
        end
        %This function will open the data and make a decision to preload
        %the data or load single frames depending on the actual free
        %memory.  The metadataMaster fields are also overlaid on the
        %metadata struct here.  The valid pair values are:
        %
        %cacheMethod - 'none', none of the data is cached in memory.
        %'all' all the data is cached in memory. 'auto' based on the
        %largest free segment determines if the data is cached or not.
        %TODO: Caculate the amount of memory to load all of the data.
        
        function open(this,varargin)
            p = inputParser;   % Create an instance of the class.
            p.addParamValue('cacheMethod','auto',@(x) any(strcmp(x,{'auto','all','none'})));
            
            p.parse(varargin{:});
            
            switch(p.Results.cacheMethod)
                case {'all','none'}
                    this.cacheMethod=p.Results.cacheMethod;
                case 'auto'
                    [userview, systemview] = memory;
                    if userview.MaxPossibleArrayBytes<1e9
                        this.cacheMethod='none';
                    else
                        this.cacheMethod='all';
                    end
                otherwise
                    error(['Invalid cache setting of ' p.Results.cacheMethod]);
            end
            
            switch(char(this.openMethod))
                case 'uread'
                    this.metadata.sourceFilename=this.blockSource;
                    this.metadata.sourceLoadFunction=@loadCaseData;
                    this.metadata.ultrasound=this.metadata.sourceLoadFunction(this.metadata.sourceFilename);
                    
                    if isempty(this.caseFilenameDeprecated)
                        this.metadata.deprecated.metadata=loadRFData(this.metadata.sourceFilename);
                    else
                        this.metadata.deprecated.metadata=loadCaseData(this.caseFilenameDeprecated);
                    end
                    
                    this.getDataSliceFromDataSource=@(slice_base1) this.openMethod(this.blockSource,slice_base1-1,this.openArgs{:});
                    testSlice=this.getDataSliceFromDataSource(1);
                    
                    if isempty(this.blockSourceDimensions)
                        this.blockSourceDimensions=[ size(testSlice,1) size(testSlice,2) this.metadata.ultrasound.rf.header.nframes 1];
                    else
                        error('Not currently handling this code');
                    end
                    
                    
                    
                case 'matlabArray'
                    if isempty(this.caseFilenameDeprecated)
                        this.metadata.deprecated.metadata=[];
                        %assign default values when not given
                        if isempty(this.metadataMaster)
                            this.metadataMaster.scale.axial.units='mm';
                            this.metadataMaster.scale.axial.value=1;
                            this.metadataMaster.scale.lateral.units='mm';
                            this.metadataMaster.scale.lateral.value=1;
                            this.metadataMaster.ultrasound.rf.header.dr=1;
                            this.metadataMaster.ultrasound.rf.header.sf=1;
                        else
                            %just use the metadataMaster
                        end
                    else
                        this.metadata.deprecated.metadata=loadCaseData(this.caseFilenameDeprecated);
                    end
                    
                    if isempty(this.blockSourceDimensions)
                        this.blockSourceDimensions=size(this.blockData);
                    else
                        error('Not currently handling this code');
                    end
                    
                    
                otherwise
                    error(['Unsupported openMethod of ' char(this.openMethod)]);
            end
            
            
            
            if strcmp('all',this.cacheMethod) && ~strcmp('matlabArray',char(this.openMethod))
                this.blockData=this.getDataSliceFromDataSource([]);
            elseif strcmp('all',this.cacheMethod) && strcmp('matlabArray',char(this.openMethod))
                %do nothing since should already be loaded
                if isempty(this.blockData)
                    error('this.blockData should not be empty if it is a matlabArray');
                end
            end
                       
            
            if ~isempty(this.metadataMaster)
                %These values are always applied to any new data set and override the metadata in the dataset
                fieldNamesToOverwrite=fieldnames(this.metadataMaster);
                for ii=1:length(fieldNamesToOverwrite);
                    this.metadata.(fieldNamesToOverwrite{ii})=this.metadataMaster.(fieldNamesToOverwrite{ii});
                end
            end
            
        end
        
        
        %This function extracts a slice or set of slices from the data
        %block for a specified volume.  The index it uses is base 1.  The volume index can be
        %specified or it can default to the active volume index.
        %A slice by definition is along the third dimension.
        %The processStreamId can be the name or the handle number, empty or
        %a user specified function.  When it is empty then no processing is
        %done.
        %
        %The slices are treated as independent units so all functions
        %applied will only process them independently.
        function [sliceBlock]=getSlice(this,slice_base1,volumeIndex,processStreamId)
            
            switch(nargin)
                case 2
                    volumeIndex=this.activeVolumeIndex;
                    processStreamId=this.activeProcessStreamIndex;
                case 3
                    processStreamId=this.activeProcessStreamIndex;
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.')
            end
            
            %If no volume index was given then use the active one
            if isempty(volumeIndex)
                volumeIndex=this.activeVolumeIndex;
            end
            
            %Select processing function for the data
            if isempty(processStreamId)
                processStreamFunction=[];
            elseif isa(processStreamId,'function_handle')
                processStreamFunction=processStreamId;
            elseif ischar(processStreamId) %assume it is a name of the process stream
                selectedStream=arrayfun(@(x) strcmp(x.name,processStreamId),this.processStream);
                if ~any(selectedStream)
                    error(['Unable to find the stream name ' processStreamId]);
                else
                    processStreamFunction= this.processStream(arrayfun(@(x) strcmp(x.name,processStreamId),this.processStream)).func;
                end
                
            else  %assume a function handle
                processStreamFunction=this.processStream(processStreamId).func;
            end
            
            %%This determines if the slices are already loaded.  The second
            %%part hadnles the case when blockData=[] because size([],3)==1
            loadedSlices=slice_base1<=(size(this.blockData,3))*(size(this.blockData,1)~=0);
            
            if any(~loadedSlices)
                newSlices=this.getDataSliceFromDataSource(slice_base1(~loadedSlices));
            else
                newSlices=[];
            end
            
            %The objective here is to create the slice block to return.
            %This is done by finding the x and y dimensions by determining
            %the max row and max col values since either the new slices or
            %cahced slices maybe empty.
            sliceBlock=zeros([max([arrayfun(@(x) size(newSlices,x),[1 2]); arrayfun(@(x) size(this.blockData,x),[1 2])],[],1) length(slice_base1)]);
            
            %The any prevents an error of "Subscripted assignment dimension
            %mismatch." when the loaded block is empty or there is nothing
            %to load.
            if any(loadedSlices)
                sliceBlock(:,:,loadedSlices)=this.blockData(:,:,slice_base1(loadedSlices),volumeIndex);
            else
                %do nothing
            end
            
            if ~all(loadedSlices)
                sliceBlock(:,:,~loadedSlices)=newSlices;
            else
                %skip processing
            end
            
            if ~isempty(processStreamFunction)
                for ii=1:size(sliceBlock,3)
                    sliceBlock(:,:,ii)=processStreamFunction(sliceBlock(:,:,ii));
                end
            else
                %skip processing
            end
            
        end
        
        %This function allows you to create new streams or overwrite
        %existing ones.  If you are adding a new stream and want it to be
        %active then you must set setActive=true.
        function newProcessStream(this,stackName,processStreamFunction,setActive)
            indexOfStreamWithSameName=arrayfun(@(x) strcmpi(stackName,x.name),this.processStream);
            
            if sum(indexOfStreamWithSameName)~=0 && sum(indexOfStreamWithSameName)~=1
                error('There can only be zero or or one streams that match the name.  The stream name must be unique.');
            end
            
            
            this.processStream(indexOfStreamWithSameName)=[];
            
            this.processStream(end+1).name=stackName;
            this.processStream(end).func=processStreamFunction;
            this.processStream(end).type='4d';
            
            %If the deleted name was the active stream then you must set
            %the new stream to be the active index because it replaces the
            %orignal stream
            if indexOfStreamWithSameName(this.activeProcessStreamIndex)
                this.activeProcessStreamIndex=length(this.processStream);
            elseif setActive
                this.activeProcessStreamIndex=length(this.processStream);
            else
                %do nothing
            end
            
            notify(this,'NewProcessStreamEvent',EventKeyValuePayload('processStream.name',this.processStream(end).name));
            
        end
        
        %This function closes a stream.
        function close(this)
            switch(char(this.openMethod))
                case 'uread'
                    %do nothing
                otherwise
                    error(['Unsupported openMethod of ' char(this.openMethod)]);
            end
            
        end
        
        function unitValue=getUnitsValue(this,unitsName,unitsType)
            switch nargin
                case {1,2}
                    disp('The valid inputs are:')
                    disp('==unitsName==|==unitsType==')
                    disp('   lateral   |    mm')
                    disp('   axial     |    mm')
                    disp('  frameRate  |  framePerSec');
                    disp('  axialSampleRate  |  samplePerSec');
                    warning('Please adjust function input argument list');
                    unitValue=[];
                    return;
                case 3
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            switch(unitsName)
                case 'lateral'
                    if ~strcmp(unitsType,'mm')
                        error('Only mm is currently handled.');
                    else
                        %do nothing
                    end
                    
                    if isfield(this.metadataMaster,'scale')
                        if ~strcmp(this.metadataMaster.scale.lateral.units,'mm')
                            error('Unsupported scale value');
                        else
                            unitValue=this.metadataMaster.scale.lateral.value;
                        end
                    elseif isfield(this.metadata,'scale')
                        if ~strcmp(this.metadata.scale.lateral.units,'mm')
                            error('Unsupported scale value');
                        else
                            unitValue=this.metadata.scale.lateral.value;
                        end
                    elseif tIsBranch(this.metadata.ultrasound,'rf.header.pixel.scale.lateral')                      
                        if ~strcmp(this.metadata.ultrasound.rf.header.pixel.scale.lateral.units,'mm')
                            error('Unsupported scale value');
                        else
                            unitValue=this.metadata.ultrasound.rf.header.pixel.scale.lateral.value;
                        end
                    else
                        unitValue=getCaseRFUnits(this.metadata.ultrasound,'lateral','mm');
                    end
                    
                case 'axial'
                    if ~strcmp(unitsType,'mm')
                        error('Only mm is currently handled.');
                    else
                        %do nothing
                    end
                    
                    if isfield(this.metadataMaster,'scale')
                        if ~strcmp(this.metadataMaster.scale.axial.units,'mm')
                            error('Unsupported scale value');
                        else
                            unitValue=this.metadataMaster.scale.axial.value;
                        end
                    elseif isfield(this.metadata,'scale')
                        if ~strcmp(this.metadata.scale.axial.units,'mm')
                            error('Unsupported scale value');
                        else
                            unitValue=this.metadata.scale.axial.value;
                        end                        
                    elseif tIsBranch(this.metadata.ultrasound,'rf.header.pixel.scale.axial')                      
                        if ~strcmp(this.metadata.ultrasound.rf.header.pixel.scale.axial.units,'mm')
                            error('Unsupported scale value');
                        else
                            unitValue=this.metadata.ultrasound.rf.header.pixel.scale.axial.value;
                        end                        
                    else
                        unitValue=getCaseRFUnits(this.metadata.ultrasound,'axial','mm');
                    end
                    
                case 'frameRate'
                    if ~strcmp(unitsType,'framePerSec')
                        error('Only  framePerSec is currently handled.');
                    else
                        %do nothing
                    end
                    
                    if isfield(this.metadataMaster,'ultrasound')
                        unitValue=this.metadataMaster.ultrasound.rf.header.dr;
                    elseif isfield(this.metadata,'ultrasound')
                        unitValue=this.metadata.ultrasound.rf.header.dr;
                    else
                        error('Unable to find the framerate');
                    end
                    
                    
                case 'axialSampleRate'
                    if ~strcmp(unitsType,'samplePerSec')
                        error('Only  samplePerSec is currently handled.');
                    else
                        %do nothing
                    end
                    
                    if isfield(this.metadataMaster,'ultrasound')
                        unitValue=this.metadataMaster.ultrasound.rf.header.sf;
                    elseif isfield(this.metadata,'ultrasound')
                        unitValue=this.metadata.ultrasound.rf.header.sf;
                    else
                        error('Unable to find the axialSampleRate');
                    end
                    
                otherwise
                    error(['The units name ' unitsName ' has not been implemented.']);
                    
            end
            
        end
        
        %returns the size of the datablock which can be accessed
        function [dimSize]=size(this,dim)
            dimSize=this.blockSourceDimensions(dim);
        end
        
        %Play a movie of the data block
        %
        %INPUT
        %range - if two values is the start and stop ranges for the movie.
        %If only one value is given then it is assumed that it is a single
        %frame      
        %
        %fileCreationSettings - The file creation settings are the settings for vopen ('w' needs
        %to be included)
        %
        %EXAMPLE
        %Write uncompressed movie:
        %dataBlockObj.movie([],{[dataBlockObj.activeCaseName '.avi'],'w',5,{'avi', 'Uncompressed AVI'},false})
        %dataBlockObj.movie([],{[dataBlockObj.activeCaseName '.mp4'],'w',30,{'VideoWriter', 'MPEG-4'},false})
        %Overlay: dataBlockObj.movie([],{},'overlayImageBlock',totalSpeedBlock);
        %
        %Add delay
        %dataBlockObj.movie([],{},'delay_sec',1)
        %KNOWN ISSUES
        %method will crash if the overlay is shorter than the original data
        function movie(this,varargin)
            
            p = inputParser;   % Create an instance of the class.
            p.addOptional('range',[],@(x) isnumeric(x) || isvector(x) || isscalar(x)); 
            p.addOptional('fileCreationSettings',{},@(x) iscell(x));
            p.addParamValue('openContour',[],@(x) isstruct(x));
            p.addParamValue('lineProperties',{},@(x) iscell(x));
            p.addParamValue('overlayImageBlock',[],@(x) isnumeric(x));
            p.addParamValue('delay_sec',0.1,@(x) isnumeric(x));
            
            p.parse(varargin{:});
        
            range=p.Results.range;            
            fileCreationSettings=p.Results.fileCreationSettings;
            openContour=p.Results.openContour;
            lineProperties=p.Results.lineProperties;
            overlayImageBlock=p.Results.overlayImageBlock;
            delay_sec=p.Results.delay_sec;
%             switch(nargin)
%                 case 1
%                     range=[];
%                     fileCreationSettings={};
%                 case 2
%                     fileCreationSettings={};
%                 case 3
%                     %do nothing
%                 otherwise
%                     error('Invalid number of input arguments.');
%             end
            
            if isempty(range)
                range=[1 this.size(3)];
            elseif isscalar(range)
                %assume the single frame case
                range=[range range];
            end
            
            f1=figure;
            %warning('Fix me(scale)!!!!!!')
            axial_mm=this.getUnitsValue('axial','mm');
            lateral_mm=this.getUnitsValue('lateral','mm');
            
            
            if ~isempty(fileCreationSettings)
                vid=vopen(fileCreationSettings{:});
            end
            
            warning('Fix movie by using process read.')
            for ii=range(1):range(2)
                figure(f1);
                
                if false
                    im=this.blockData((this.metadata.ultrasound.rf.header.ul(2)+1):(this.metadata.ultrasound.rf.header.br(2)-1), ...
                        ((this.metadata.ultrasound.rf.header.ul(1)+2):(this.metadata.ultrasound.rf.header.br(1)-1)),ii);
                else
                    im=this.getSlice(ii);
                    %                     im(im>50)=50;
                    %                     im=im.^1.5;
                end
                
                axialAxis_mm=(0:(size(im,1)-1))*axial_mm;
                lateralAxis_mm=(0:(size(im,2)-1))*lateral_mm;
                
               
%                 if ~isreal(im)
%                     imagesc(lateralAxis_mm,axialAxis_mm,abs(im).^0.5);
%                 else
%                     imagesc(lateralAxis_mm,axialAxis_mm,im); %assume getSlice will properly display it
%                 end
                                
                imG=mat2gray(im(:,:,1),[min(min(im(:,:,1))) max(max(im(:,:,1)))]);
                [imGI, map] = gray2ind(imG,256);
                imRGB = ind2rgb(imGI, map);

                if ~isempty(overlayImageBlock)
                    imAlphaData=zeros(size(overlayImageBlock,1),size(overlayImageBlock,2));
                    imAlphaData(abs(overlayImageBlock(:,:,ii))>1)=0.5;
                    %figure('renderer','opengl');
                end
                
                if ~isempty(overlayImageBlock)
                subplot(1,2,1);
                end
                image(lateralAxis_mm,axialAxis_mm,imRGB);
                
               if ~isempty(overlayImageBlock)
                hold on; him=imagesc(lateralAxis_mm,axialAxis_mm,overlayImageBlock(:,:,ii));
                hold off;
                set(him,'AlphaData',imAlphaData);
               end
                title(['Frame ' num2str(ii) ' of ' num2str(size(this.blockData,3))]);
                xlabel('mm');
                ylabel('mm');
                
                if ~isempty(overlayImageBlock)
                subplot(1,2,2);
                hist(reshape(overlayImageBlock(:,:,ii),[],1),1011)   
                xlabel('displacement');
                %colormap(gray(256));
                end
                
                if ~isempty(openContour)                    
                    hold on                    
                    plot(openContour(ii-range(1)+1).pt_rc(2,:),openContour(ii-range(1)+1).pt_rc(1,:),'r',lineProperties{:})
                    plot(openContour(ii-range(1)+1).pt_rc(2,:),openContour(ii-range(1)+1).pt_rc(1,:),'rx',lineProperties{:})
                else
                    %do nothing
                end
                

        
                if ~isempty(fileCreationSettings)
                    vid=vwrite(vid,gca,'handle');
                end
                
                pause(delay_sec);
            end
            
            if ~isempty(fileCreationSettings)
                vid=vclose(vid);
            end
            
        end
        
        %Filename is created using the sprintf format to accept a %d
        %integer file number index which starts at 1.  The mask MUST have
        %been escaped so all \ replaced with \\.  Also if you want zero
        %padding then make sure the mask is %03d where 3 is the number of
        %zeros
        %
        %INPUT
        %sliceSequence - is an array of the order to write the slices with
        %a default of [1:size(this.blockData,3)].  The sequence will be
        %written out using the index of sliceSequence
        function imwrite(this,fullFilenameMask,fmt,sliceSequence)
            
            switch(nargin)
                
                case 3
                    sliceSequence=[1:size(this.blockData,3)];
                case 4
                    %do nothing
            end
            
            
            switch(lower(fmt))
                case {'png','gif','tif'}
                    %do nothing
                case {'.png','.gif','.tif'}
                    fmt=fmt(2:end);
                otherwise
                    error(['Need to add the format ' fmt ' to the case statement. ']);
            end
            
            for ii=1:length(sliceSequence)
                [~,~,fileExt]=fileparts(fullFilenameMask);
                if isempty(fileExt)
                    fullFilename=sprintf([fullFilenameMask '.%s'],ii,fmt);
                else
                    fullFilename=sprintf([fullFilenameMask ],ii);
                end
                disp(['Writing frame ' num2str(ii) ' of ' num2str(size(this.blockData,3)) '. Using slice number ' num2str(sliceSequence(ii)) '. ' fullFilename]);
                im=repmat(uint8(this.blockData(:,:,sliceSequence(ii))/max(max(this.blockData(:,:,ii)))*255),[1 1 3]);
                imwrite(im,fullFilename,fmt);
            end
        end
        
        %Plots an image of the of the requested frames in the data block.
        %If more than one frame is specified then it will make multiple
        %figures.
        %
        %INPUT
        %framesToPlot - an array of frames to plot.  If empty it will be
        %the entire image sequence
        %
        %EXAMPLE
        %plot frames 10,11, and 13:
        %dataBlockObj.image([10 11 13]
        function image(this,framesToPlot,units)
            switch(nargin)
                case 1
                    framesToPlot=[];
                    units='mm';
                case 2
                    units='mm';
                case 3
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            if isempty(framesToPlot)
                framesToPlot=[1 size(this.blockData,3)];
            end
            
            switch(units)
                case 'mm'
                    axial_unitScale=this.getUnitsValue('axial','mm');
                    lateral_unitScale=this.getUnitsValue('lateral','mm');
                case 'pel'
                    axial_unitScale=1;
                    lateral_unitScale=1;
                otherwise
                    error(['Unsupported units of ' units]);
            end
            
            
            warning('Fix image by using process read.')
            for ii=framesToPlot
                figure;
                
                if false
                    im=this.blockData((this.metadata.ultrasound.rf.header.ul(2)+1):(this.metadata.ultrasound.rf.header.br(2)-1), ...
                        ((this.metadata.ultrasound.rf.header.ul(1)+2):(this.metadata.ultrasound.rf.header.br(1)-1)),ii);
                else
                    im=this.blockData(:,:,ii);
                    %im=this.getSlice(ii);
                    
                end
                
                axialAxis=(0:(size(im,1)-1))*axial_unitScale;
                lateralAxis=(0:(size(im,2)-1))*lateral_unitScale;
                
                %                 if ~isreal(im)
                %                     imagesc(lateralAxis,axialAxis,abs(im).^0.5);
                %                 else
                %                     imagesc(lateralAxis,axialAxis,abs(im).^1);
                %                 end
                imagesc(lateralAxis,axialAxis,im);
                
                colormap(gray(256));
                title(['Frame ' num2str(ii) ' of ' num2str(size(this.blockData,3))]);
                xlabel(units);
                ylabel(units);
                
                pause(0.1);
            end
            
            
        end
        
        
        %This function will save data to file and return the data as a
        %structure which can then be reloaded.  The large datasets are not
        %saved for size constraint.
        %
        %INPUTS
        %filename - must be specified or empty
        %
        %OUTPUTS
        %dataOut - the data structure that will restore the object to its
        %original state
        function dataOut=save(this,filename,varargin)
            p = inputParser;   % Create an instance of the class.
            p.addRequired('filename', @(x) isempty(x) || ischar(x) );
            
            p.parse(filename,varargin{:});
            
            filename=p.Results.filename;
            
            data.save.filename=filename;
            data.save.varargin=varargin;
            
            data.getDataSliceFromDataSource=this.getDataSliceFromDataSource;  %This is the built up to read a data slice;
            
            data.activeProcessStreamIndex=this.activeProcessStreamIndex;
            data.dataBlockDimensions=this.dataBlockDimensions;
            data.metadataMaster=this.metadataMaster;
            data.blockSource=this.blockSource;
            data.openMethod=this.openMethod;
            data.openArgs=this.openArgs;
            data.blockSourceDimensions=this.blockSourceDimensions;
            %DONT SAVE UNLESS ASKED, TOO BIG blockData=[];  %This holds the cache data.  normally only loaded at startup
            data.cacheMethod=this.cacheMethod;
            data.activeProcessStreamName=this.activeProcessStreamName;  %This is the process stream handle
            data.activeProcessStreamHandle=this.activeProcessStreamHandle;  %This is the process stream handle
            data.activeProcessStream=this.activeProcessStream;  %This is the process stream handle
            data.activeCaseName=this.activeCaseName; %This is the name of the active case that was loaded
            data.metadata=this.metadata;       %The current metadata
            data.caseFilenameDeprecated=this.caseFilenameDeprecated;
            data.activeVolumeIndex=this.activeVolumeIndex;
            
            %Remove the function handles because they save enviroment space
            %which makes for large files
            data.getDataSliceFromDataSource=char(this.getDataSliceFromDataSource);
            
            data.processStream=this.processStream;
            for ii=1:length(data.processStream)
                data.processStream(ii).func=char(data.processStream(ii).func);
            end
            
            data.openMethod=char(this.openMethod);
            data.activeProcessStream=char(this.activeProcessStream);
            data.metadata.sourceLoadFunction=char(this.metadata.sourceLoadFunction);
            
            
            if ~isempty(filename)
                save(filename,'data');
            else
                %don't save anything
            end
            
            switch(nargout)
                case 0
                    %do nothing
                case 1
                    dataOut=data;
                otherwise
                    error('Invalid number of output arguments');
            end
            
            
        end
        
        
        %This function will load data from a file and return the data as a
        %structure which can then be reloaded.  The large datasets are not
        %saved for size constraint.
        %
        %INPUTS
        %filename - must be specified or empty
        %('dataSet',data) - This key value pair will load data if necessary
        function load(this,filename,varargin)
            p = inputParser;   % Create an instance of the class.
            p.addRequired('filename', @(x) isempty(x) || ischar(x) );
            p.addParamValue('dataSet',[],@(x) isempty(x) || isstruct(x));
            p.parse(filename,varargin{:});
            
            filename=p.Results.filename;
            dataSet=p.Results.dataSet;
            
            %At the end of the if condition the dataSet varaible needs to
            %be valid
            if ~isempty(filename) && isempty(dataSet)
                load(filename,'dataSet');
            elseif ~isempty(filename) && ~isempty(dataSet)
                error('Only a filename or dataSet can be given.');
            elseif isempty(filename) && isempty(dataSet)
                error('Nothing specified.  Either the filename or dataSet must be given.');
            elseif ~isempty(filename) && isempty(dataSet)
                %this is fine
            end
            error('The function needs to be finished.  Make sure you can''t just reopen the file if youare too lazy to finish this');
            
            
            
            
        end
        
        function border_rc=findBorder(this)
            %This function will return the border in terms of [rowMin,
            %rowMax, columnMin, columnMax].  A border is defined as all
            %black pixels throughout all the image slices
             border_rc=findBlockBoundry(this.blockData);
        end
        
        function plotBframes(this)
            figure
            hax1 = gca;
            imagesc(((squeeze(this.blockData(:,:,1)))));
            colormap gray
            title(hax1,'Frame 1','fontsize',16)
            ylabel('Depth (samples)','fontsize',16)
            
            % Add a slider uicontrol to control the location to plot in the next
            % subplot
            pos=get(hax1,'position');
            Newpos=[pos(1) pos(2)-0.1 pos(3)+0.4 0.05];
            % %     'Position', [75 200 430 20],...
            uicontrol('Style', 'slider',...
                'Min',1,'Max',size(this.blockData,3),'Value',1,...
                'SliderStep',[1/(size(this.blockData,3)-1) 20/(size(this.blockData,3)-1)],...
                'Position', Newpos*400,...
                'Callback', {@this.framestep,hax1});   % Slider function handle callback
            % Implemented as a subfunction
        end
        
        
        function framestep(this,hObj,event,ax)
            val = get(hObj,'Value');
            framenum = floor(val);
            
            imagesc(((squeeze(this.blockData(:,:,framenum)))));colormap gray;
            title(ax,['Frame ',num2str(framenum)],'fontsize',16)
            ylabel(ax,'Depth (samples)','fontsize',16)
        end
        

    end
    
    
    
end

