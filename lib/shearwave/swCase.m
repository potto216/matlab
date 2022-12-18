classdef swCase < handle
    %SWCASE This class stores the metadata for the shear wave cases
    %The class will not compute shear wave velocities or return ultrasound
    %data, instead it provides other classes the information needed to
    %obtain the data.  A case entry will only have one ultrasound data file
    %associated with it.  The case name is in the form:
    %<Study ID><Patient Number>_V<Visit Number>_<Unique ID>_T<Trial Number>.m
    %where:
    %<Study ID> - The study name: MTRP or NIH
    %<Patient Number> - in the form 000
    %<Visit Number> - The visit number in the form
    %<Unique ID> - This uniquely identifies the ultrasound file.  This can
    %only be made up of any character except "_"  It also should not have
    %characters that are not allowed in Matlab script names such as +,-
    %etc.
    %Normally in the form s<Site Number>-f<Freq Hz>
    %<Trial Number> -
    
    properties (GetAccess = public, SetAccess = public)
        relativeCaseFilePath=[];
        ultraspeckRootFilePath=[];
        caseData=[];
    end
    
    properties (GetAccess = private, SetAccess = private)
        dataFileFullPath=[];
    end
    
    properties (Dependent = true, SetAccess = private)
        probeName;
        probeType;
        lateralStep_mm;
        axialStep_mm;
        sampleRate_Hz;
        frameRate_Hz;
        caseName;
        
    end
    
    
    
    
    methods
        
        %There are three ways to call the object.
        %1. Provide a case filename or no case filename.  In this senerio
        %if a matlab case file (.m) is given the data will be read from it.  If
        %not and no filename is given and the emptyCase parm is not true
        %then it will ask the user to select a case.
        %
        %2. If case name is a filename with the .rf extension then a shell
        %case will be created with many empty values unless set as a
        %command line parm.
        %
        %3. If the emptyCase parm is true then a empty case will be created
        %and certain parms must be specified at the command line.
        %These specified through the override keyword.
        %An empty case is useful when raw data will
        %be linked to the case without specifing a file.
        %
        %overrideSettings {'parm1',<value>,'parm2',<value>,...}
        %
        %if overrideSettings is specified it will override any preset case
        %settings.  This is run after the case is laoded.
        %
        %The settings that can be overridden.  These are:
        %parmProbeName - the name of the probe that was used examples include:
        %       'L14-5/38', 'L14-5W/60'
        %'sampleRate_Hz' - sample rate of the system
        %'frameRate_Hz' - frame rate of the system
        %'lineDensity' - line density for the system.
        %
        %Examples:
        %  Ex: load file rf/m
        %>>swc1=swCase('c:\file.m');
        %
        %  Ex: load a file from file dialog
        %>>swc1=swCase([]);
        %
        %  Ex: create a blank case and pass in settings
        %>>swc1=swCase([],'emptyCase',true,'overrideSettings',{'probeName','L14-5/38', 'sampleRate_Hz',40e6, 'frameRate_Hz',400});
        function sObj=swCase(varargin)
            
            p = inputParser;   % Create an instance of the class.
            p.addOptional('caseName',[],@(x) ischar(x) || isempty(x));
            p.addParamValue('ultraspeckRootFilePath',getenv('ULTRASPECK_ROOT'),@ischar);
            p.addParamValue('relativeCaseFilePath','projects\triggerPoint\dataCollect\Shearwave\cases',@ischar);
            p.addParamValue('emptyCase', false, @islogical);
            p.addParamValue('overrideSettings', {}, @iscell);
            p.addParamValue('dataFileFullPath','',@ischar);
            p.parse(varargin{:});
            
            sObj.ultraspeckRootFilePath=p.Results.ultraspeckRootFilePath;
            sObj.relativeCaseFilePath=p.Results.relativeCaseFilePath;
            
            if isempty(p.Results.dataFileFullPath)
                sObj.dataFileFullPath=fullfile(sObj.ultraspeckRootFilePath,sObj.relativeCaseFilePath);
            else
                sObj.dataFileFullPath=p.Results.dataFileFullPath;
            end
            
            if ~isempty(p.Results.caseName) || (isempty(p.Results.caseName) && ~p.Results.emptyCase)
                sObj.caseData=sObj.loadCaseData(p.Results.caseName);
            elseif isempty(p.Results.caseName) && p.Results.emptyCase
                %The override settings are used to configure the object,
                %but at a minimum the probe name needs to be specified.
                %sObj.caseData=struct([]);
                sObj.caseData.rf.header.probe=[];
                if isempty(p.Results.overrideSettings)
                    error('The overrideSettings needs to be specified.');
                else
                    %do nothing it will be set in the override
                end
            else
                error('This should never occur.');
            end
            
            
            %Override settings
            if ~isempty(p.Results.overrideSettings)
                sObj.overrideSettings(p.Results.overrideSettings{:});
            else
                %do nothing
            end
            
            %Perform data validation
            if isfield(sObj.caseData.rf.header,'probe')
                if ~isempty( sObj.caseData.rf.header.probe)
                    %do nothing, but could validate that it is in a valid
                    %range
                else
                    error('sObj.caseData.rf.header.probe must be assigned.')
                end
            else
                error('sObj.caseData.rf.header.probe field must exist.')
                
            end
            
        end
        
        function overrideSettings(sObj,varargin)
            p = inputParser;   % Create an instance of the class.
            
            p.addParamValue('probeName',[],@(x) ischar(x));
            p.addParamValue('sampleRate_Hz', [], @(x) isnumeric(x) && isscalar(x) && (x>0));
            p.addParamValue('frameRate_Hz', [],  @(x) isnumeric(x) && isscalar(x) && (x>0));
            p.addParamValue('lineDensity', [],  @(x) isnumeric(x) && isscalar(x) && (x>0));
            p.parse(varargin{:});
            
            
            if ~isempty(p.Results.probeName)
                sObj.probeType=sObj.lookupProbeType(p.Results.probeName);
            else
                %do nothing
            end
            
            if ~isempty(p.Results.sampleRate_Hz)
                sObj.caseData.rf.header.sf=p.Results.sampleRate_Hz;
            else
                %do nothing
            end
            
            if ~isempty(p.Results.frameRate_Hz)
                sObj.caseData.rf.header.dr=p.Results.frameRate_Hz;
            else
                %do nothing
            end

            if ~isempty(p.Results.lineDensity)
                sObj.caseData.rf.header.ld=p.Results.lineDensity;
            else
                %do nothing
            end
            
        end
        
    end
    
    
    
    methods
        function probeNameText=get.probeName(obj)
            if isempty(obj.caseData)
                error('caseData must be set');
            end
            switch(obj.caseData.rf.header.probe)
                case 0
                    probeNameText='4DL14-5/38';
                case 1
                    probeNameText='LAP9-4/38';
                case 2
                    probeNameText='L14-5/38';
                case 3
                    probeNameText='HST15-8';
                case 4
                    probeNameText='mTEE8-3/5';
                case 5
                    probeNameText='C5-2/60';
                case 7
                    probeNameText='L14-5W/60';
                case 8
                    probeNameText='EC9-5/10';
                case 9
                    probeNameText='BIPXY';
                case 10
                    probeNameText='C5-2/60';
                case 11
                    probeNameText='L9-4/38';
                case 12
                    probeNameText='BPL9-5/55';
                case 13
                    probeNameText='BPC8-4/10';
                case 15
                    probeNameText='4DC7-3/40';
                case 16
                    probeNameText='m4DC7-3/40';
                case 20
                    probeNameText='PA7-4/12';
                case 21
                    probeNameText='C7-3/50';
                case 22
                    probeNameText='MC9-4/12';
                otherwise
                    error(['Unsupported probe id ' obj.caseData.rf.header.probe]);
            end
        end
        
        function probeType=get.probeType(obj)
            
            if isempty(obj.caseData)
                error('caseData must be set');
            end
            
            probeType=obj.caseData.rf.header.probe;
            
        end
        
        function set.probeType(obj,newProbeType)
            
            
            obj.caseData.rf.header.probe=newProbeType;
            
        end
        
        function result_mm=get.lateralStep_mm(obj)
            
            result_mm=obj.getLateralStep_mm;
            
        end
        
        function result_mm=get.axialStep_mm(obj)
            
            result_mm=obj.getAxialStep_mm;
            
        end
        
        function result_Hz=get.sampleRate_Hz(obj)
            if isempty(obj.caseData)
                error('caseData must be set');
            end
            
            result_Hz=obj.caseData.rf.header.sf;
            
        end
        
        
        function result_Hz=get.frameRate_Hz(obj)
            if isempty(obj.caseData)
                error('caseData must be set');
            end
            
            result_Hz=obj.caseData.rf.header.dr;
            
        end
        
        %getCaseName returns the case name from the metadata structure.
        %The casename is the filename without the extension.
        %If the file is just a raw datafile with no metafile attached then the raw
        %data file name is returned
        function caseStr=get.caseName(obj)
            if isempty(obj.caseData)
                error('caseData must be set');
            end
            
            if ~isfield(obj.caseData,'sourceMetaFilename')
                caseStr=[];                
            else
                if ~isempty(obj.caseData.sourceMetaFilename)
                    [~,caseStr]=fileparts(obj.caseData.sourceMetaFilename);
                else
                    [~,caseStr]=fileparts(obj.caseData.rfFilename);
                end
            end
            
            
        end
        
        
    end
    
    methods (Access=public)
        function showDatasheet(obj)
            datasheetFilename=fullfile(obj.ultraspeckRootFilePath,obj.caseData.userdata.dataSheetFilename);
            
            if ~exist(datasheetFilename,'file')
                error(['Could not find the datasheet ' datasheetFilename]);
            end
            
            [~,~,fileExt]=fileparts(datasheetFilename);
            switch(fileExt)
                case '.pdf'
                    open(datasheetFilename);
                otherwise
                    error(['Unsupported file extension of ' fileExt]);
            end               
            
            
            
        end
    end
            
    
    methods (Access=private)
        %This function will load case data and return a data structure that is the
        %caseData.  If caseData is a string then it will load the metadata file and
        %return the data structure.  If the argument is not given it will default
        %to asking the user to open a file.  In this case it will try to open the
        %case file based on "%ULTRASPECK_ROOT%\<relative case file location>" directory.
        %If theenviromental variable is not defined or the directory does not exist it
        %will just open a file dialog in the current directory.
        %
        %The function can also open rf files directly, but only if the
        %extension is .rf.  Also if the caseData struct is passed in then
        %it will not do any processing on it except simply return the
        %struct.
        %
        %INPUT
        %caseData - Can be a string or a data structure.  If it is a string then it
        %is assumed to be the full path and filename of the data structure.
        %
        %OUTPUT
        %caseData - A data structure of the case data.
        %
        function caseData=loadCaseData(sObj,caseData)
            caseFilename=[];
            if  isempty(caseData)
                
                casefolderPath=sObj.dataFileFullPath;
                if exist(casefolderPath,'dir')
                    [filename pathname] = uigetfile( ...
                        {'*.rf','Ultrasonix file (*.rf)'; ...
                        '*.m','Case file (*.m)' }, ...
                        'Pick a case or data file',casefolderPath);
                else
                    [filename pathname] = uigetfile( ...
                        { '*.m','Case file (*.m)'; ...
                        '*.rf','Ultrasonix file (*.rf)'}, ...
                        'Pick a case or data file');
                end
                
                if ~ischar(filename) || ~ischar(pathname)
                    disp('Canceling file selection.')
                    caseData=struct([]);
                    return;
                else
                    caseFilename = fullfile(pathname, filename);
                end
                
                
            elseif ischar(caseData)
                caseFilename=caseData;
              caseData=[];
                
            elseif isstruct(caseData)
                %do nothing
            else
                error('caseData is an unsupported data type');
            end
            
            
            %we need to decide  based on the file extension if it is an rf
            %file or a matlab case file and open it to laod the data
            %structure.
            if ~isempty(caseFilename) && ischar(caseFilename)
                [~,~,fileExt]=fileparts(caseFilename);
                switch(lower(fileExt))
                    case '.rf'
                        [~,caseData.rf.header]=uread(caseFilename,-1);
                        caseData.rfFilename=caseFilename;
                        caseData.sourceMetaFilename=[];
                    case '.m'
                        [caseData]=sObj.loadMetadata(caseFilename);
                    otherwise
                        error(['Unsupported file extension of ' fileExt]);
                end
                
            end
        end
        
        %This function loads metadata associated with a data file.  The metadata files right
        %now are matlab scripts that setup a data structure metadata.  The file can be
        %any valid filename with any extension type.  To be returned from the
        %function they need to assign the variables to the metadata structure.
        %The only variable that cannot be assigned to metadata is
        %sourceMetaFilename which is assigned after the file is successfully loaded.
        
        %For some reason in run.m if you pass it the name of a script with .m then it will
        %fail to run without the path included
        %
        %The file name must not have a -,+ or other char
        function [metadata]=loadMetadata(sObj,filename) %#ok<MANU>
            [filePath,fileBasename,fileExt]=fileparts(filename); %#ok<ASGLU>
            
            switch(fileExt)
                case {'.m','.M'}
                    %use the run command because it is faster
                    run(filename);
                    
                otherwise %use eval since run must have a .m file
                    
                    %the script file must setup a data structure called metadata.
                    fid=fopen(filename,'r');
                    scriptText=fread(fid,inf,'char=>char');
                    fclose(fid);
                    
                    scriptText=reshape(scriptText,1,[]);
                    tmp=eval(scriptText); %#ok<NASGU>
                    %HISTORY NOTES
                    %  Tried using run(filename), but if the filename starts with numbers or has '-' or other chars that cannot be
                    %used in a valid script name it will not run.  Also the extension must have a .m
            end
            
            if isfield(metadata,'sourceMetaFilename') %#ok<NODEF>
                error('sourceMetaFilename cannot already exist.');
            else
                metadata.sourceMetaFilename=filename;
            end
            
        end
        
        
        function probeType=lookupProbeType(sObj,probeNameText)
            
            
            switch(probeNameText)
                case '4DL14-5/38'
                    probeType=0;
                case 'LAP9-4/38'
                    probeType=1;
                case 'L14-5/38'
                    probeType=2;
                case 'HST15-8'
                    probeType=3;
                case 'mTEE8-3/5'
                    probeType=4;
                case 'C5-2/60'
                    probeType=5;
                case 'L14-5W/60'
                    probeType=7;
                case 'EC9-5/10'
                    probeType=8;
                case 'BIPXY'
                    probeType=9;
                case 'L9-4/38'
                    probeType=11;
                case 'BPL9-5/55'
                    probeType=12;
                case 'BPC8-4/10'
                    probeType=13;
                case '4DC7-3/40'
                    probeType=15;
                case 'm4DC7-3/40'
                    probeType=16;
                case 'PA7-4/12'
                    probeType=20;
                case 'C7-3/50'
                    probeType=21;
                case 'MC9-4/12'
                    probeType=22;
                otherwise
                    error(['Unsupported probe name ' probeNameText]);
            end
            
            
        end
        
        
        %unitAmount_mm=getlateralStep_mm(obj) returns the laterial step for the probe
        %with the current settings.
        %
        %DESCRIPTION
        %Returns the unit amount for the requested dimension and measure.  The facetors that effect
        %The code
        %looks at the line density
        %Measurements come from Transducer Specification Sheet.pdf Ultrasonix Medical Corporation
        %Last Updated: August 2009
        %
        %INPUT
        %
        %OUTPUT
        %unitAmount - the amount of the unit being measured.
        %
        function lateralDistancePerWidthUnit_mm=getLateralStep_mm(obj)
            
            
            [elementPitch_mm,elementCount]=obj.getProbeDetails();
            
            %The lateral size in relation to the header is the total elements times
            %each pitch then divided by the header size listed
            lateralDistancePerWidthUnit_mm=elementPitch_mm*elementCount/obj.caseData.rf.header.ld;
            %unitAmount=lateralDistancePerWidthUnit_mm*metadata.rf.header.w/lateralPixelCount;
            
        end
        
        %unitAmount_mm=getAxialStep_mm(obj) returns the laterial step for the probe
        %with the current settings.
        %
        %DESCRIPTION
        %Returns the unit amount for the requested dimension and measure.  The facetors that effect
        %The code
        %looks at the line density
        %Measurements come from Transducer Specification Sheet.pdf Ultrasonix Medical Corporation
        %Last Updated: August 2009
        %
        %INPUT
        %
        %OUTPUT
        %unitAmount - the amount of the unit being measured.
        %
        function axial_mm=getAxialStep_mm(obj)
            %The axial pixel length can be computed by dividing the speed of sound in
            %tissue by the sample rate and dividing all of that by 2 because of the
            %time needed to hit the target and return.
            %average speed of sound in soft tissue 1540 m/s everywhere in body
            %so 1540*1000mm
            %metadata.rf.header.sf is assumed to be in samples/sec so that final units are
            % m     mm     s             mm
            %---- -----  --------  =  --------
            % s      m     sample      sample
            axial_mm=1540*1000/(obj.caseData.rf.header.sf*2);
            
        end
        
        %Returns probe specific details
        function [elementPitch_mm,elementCount]=getProbeDetails(obj)
            switch(obj.probeName)
                case 'L14-5/38'
                    elementPitch_mm=0.3048;
                    elementCount=128;
                case 'L14-5W/60'
                    elementPitch_mm=0.4720;
                    elementCount=128;
                otherwise
                    error(['Unsupported probe model of ' obj.probeName]);
            end
            
            
        end
    end
end
