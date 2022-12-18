classdef MRIDatabase  < handle
    %MRIDatabase  This class provides a common way to access the MRI data and hides the
    %details of loading and formatting it.
    %
    %LOADING
    %There are two methods to load the data.
    %The first method is to generate a data set from a group of
    %excel files.  This can then be saved out as a .mat file. The other method is to point
    %to an existing .mat file and have it automatically load it.
    %
    %ACCESS
    %The data can be accessed by specifying a subject name tag pair.  This
    %can follow two formats: NIH and GMU.  The NIH format uses a subject
    %number with date, and tag name such as a series number while the GMU format
    %uses a subject number/visit with a tag name.  The subject number
    %in the GMU and NIH formats will not match while the series will not
    %match, but the tag name will.  Examples are given below:
    %
    %NIH
    % Subject number with date: "SID5005R_9_26_2014_RF"
    % Tag name "Ser10"
    %
    %GMU
    % Subject and visit number: "MRUS011_V1"
    % Tag name "Ser10"
    %
    %SUBJECT DATASETS
    %Subject datasets can be stored as either a single mat file or a set of
    %data files which normally take the form of m files or Excel
    %spreadsheets.  When a collection of data files is given then the
    %collection configuration can be described by a single m file
    properties  (GetAccess = public, SetAccess = private)
        mriDB=[];
    end
    
    methods (Access=public)
        
        function obj=MRIDatabase()
            
        end
        
        %DESCRIPTION
        %This will load a mat file which contains all of the loaded and
        %parsed data structures for all subjects, or it will load an m
        %file which specifies the location of the data files that can be
        %loaded.  These data files can be in the form of Excel files.  The
        %valid parameters for the m-file can be seen in the example section
        %at the end of this code.  The data files are specified in the
        %sourcedataFilename file and the paths of the data files are given
        %by searchPath.
        %
        %INPUT
        %sourcedata - if a char then it is the fullpath and name of the mat file or the m files
        %   which shows where the Excel data files are located.  Otherwise
        %   it is the actual subject list .  If it is null then the default
        %   subject list is automatically loaded.
        %searchPath - A cell array of strings which contain a seperate path
        %to search for the data files (NOT the sourcedataFilename).  For
        %MAT files this is not used.
        %
        %EXAMPLE Update MRI datafile with default inforamtion
        %>> searchPath=dirPlus(fullfile(getenv('ULTRASPECK_ROOT'),'\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\'),'dirOnly',true);
        %>> mriObj = MRIDatabase();
        %>> mriObj.load([],searchPath);
        %>> mriObj.save(mriMatFilename);
        
        function load(this,sourcedata,searchPath)
            
            if ischar(sourcedata)         
                sourcedataFilename = sourcedata;                
                [~,~,ext] = fileparts(sourcedataFilename);
                subjectList=[];
            elseif isstruct(sourcedata) 
                subjectList=sourcedata;
                ext=[];
                sourcedataFilename=[];
            elseif isempty(sourcedata) 
                subjectList=this.defaultSubjectList;
                ext=[];
                sourcedataFilename=[];                   
            else
                error('Invalid class type for sourcedata');
            end
            
            if ~isempty(subjectList) || strcmpi(ext,'.m')
                this.mriDB=[];
                if isempty(subjectList)
                    run(sourcedataFilename);
                else
                    %do nothing
                end
                for ss=1:length(subjectList)
                    isSubjectFound=false;
                    subject=subjectList(ss);
                    for ii=1:length(searchPath)
                        fulldatafilePath=fullfile(searchPath{ii},subject.series(end).source.excel.filename);
                        if exist(fulldatafilePath,'file')
                            disp(['Loading data from the Excel sheet ' fulldatafilePath]);
                            data=loadMriExcelSheet(fulldatafilePath, ...
                                subject.series(end).source.excel.worksheet, ...
                                subject.series(end).source.excel.velocityMeasurementsPerRegion, ...
                                subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel, ...
                                subject.series(end).source.excel.startRegionLabel);
                            this.mriDB(ss).subject=subject;
                            this.mriDB(ss).data=data;
                            isSubjectFound=true;
                            break;
                        end
                    end
                    if ~isSubjectFound
                        error(['Unable to find ' subject.series(end).source.excel.filename]);
                    else
                        %do nothing
                    end
                end
            elseif strcmpi(ext,'.mat')
                data=load(sourcedataFilename,'mriDB');
                this.mriDB=data.mriDB;
            else
                error(['The extension of the source file ' sourcedataFilename ' must be .mat or .m']);
            end
        end
        
        %DESCRIPTION
        %This function will save the data in the mriDB into a MAT file so
        %it can be reloaded or shared.
        %
        %INPUT
        %matFilename - The matFilename contains the full path along with
        %the filename.  The output MAT file which will contain the data of
        %the mriDB struct.
        function save(this,matFilename)
            mriDB=this.mriDB;
            save(matFilename,'mriDB');
        end
        
        
        %This function will retreive the mri data from the database and add
        %the roi information to it.  The subject id should match either the
        %gmu.id or the nih.id.  If it matches multiple ids an error will be
        %issued.  As a check the function will recompute the projected
        %velocities to make sure everything matches.
        %
        %TODO
        %If there is the possibility that the gmu or nih id will be the
        %same then code needs to be added to support the namespace feature
        %so the string would look like 'nih:subject_id' or 'gmu:subject_id'
        function mri=initializeRoiStruct(this, subjectId,roiNumber)
            
            %first find the correct database entry
            %SID9319R_9_26_2014_RF
            %Extract the data
            subjectIndex=this.findSubjectIndexFromId(subjectId);
            %             gmuIdIndex=arrayfun(@(x) strcmp(x.subject.gmu.id,subjectId),this.mriDB);
            %             nihIdIndex=arrayfun(@(x) strcmp(x.subject.nih.id,subjectId),this.mriDB);
            %             if ~any(gmuIdIndex) && sum(nihIdIndex)==1
            %                 subjectIndex=find(nihIdIndex);
            %             elseif sum(gmuIdIndex)==1 && ~any(nihIdIndex)
            %                 subjectIndex=find(gmuIdIndex);
            %             elseif ~any(gmuIdIndex) && ~any(nihIdIndex)
            %                 error([subjectId ' was not found in the database.']);
            %             else
            %                 error(['Multiple subjects found for ' subjectId ]);
            %             end
            
            data=this.mriDB(subjectIndex).data;
            
            mri=struct([]);
            mri(1).mriReported.data_mmPerSec=[data.projectedAndShifted_mmPerSec];
            
            mri.subject=this.mriDB(subjectIndex).subject;
            
            
            if length(mri.subject.series)~=1
                error('Assumed length of subject.series is one, please fix.');
            end
            
            mri.isFlexion=mri.subject.series(end).source.excel.isFlexion;
            
            mri.ts_sec=mri.subject.series(1).source.excel.ts_sec;
            mri.t_sec=[0:(size(mri.mriReported.data_mmPerSec,1)-1)]*mri.ts_sec;
            mri.mriReported.data_mm=cumsum(mri.mriReported.data_mmPerSec,1)*mri.ts_sec;
            
            %add default
            mri.sync_sec=0;
            mri.syncDisplacement=-17.2234;
            mri.syncCycleShift=0;
            
            %this will be overwritten by the us projection angle
            mri.data_mmPerSec= mri.mriReported.data_mmPerSec;
            mri.data_mm=mri.mriReported.data_mm;
            
            %find the ROIs of interest
            if ndims(roiNumber)~=2 && size(roiNumber,1)==2
                error('The roiNumber should be in the form of a 2xN matrix where row 1 is the roi and row 2 is the corner pt');
            end
            
            mri.roiColumn=zeros(1,size(roiNumber,2));
            for rr=1:size(roiNumber,2)
                if (length(data(1).regionLabelName)==5)  && strcmpi('Rc', data(1).regionLabelName([1 4]))
                    roiName=sprintf('R%d_C%d', roiNumber(1,rr),roiNumber(2,rr));
                elseif (length(data(1).regionLabelName)==8)  && strcmpi('Rc', data(1).regionLabelName([4 7]))
                    roiName=sprintf('RF_R%d_C%d', roiNumber(1,rr),roiNumber(2,rr));
                else
                    error(['regionLabelName ' data(1).regionLabelName ' not support.']);
                end
                
                roiRegionIndex=find(arrayfun(@(x) (length(x.regionLabelName)>=length(roiName)) && strcmpi(roiName,x.regionLabelName(1:length(roiName))), data));
                if length(roiRegionIndex)~=1
                    error('roiRegionIndex must be a scalar')
                end
                mri.roiColumn(rr)=roiRegionIndex;
            end
            
            shiftAmount=[data(mri.roiColumn).shiftAmount];
            if ~all(diff(shiftAmount)==0)
                error('Shifts are different')
            else
                shiftAmount=shiftAmount(1);
            end
            shiftAmount=size(mri.mriReported.data_mmPerSec,1)-shiftAmount+1;  %rotate shift to work with circshift
            
            velocityBlock_mmPerSec=arrayfun(@(x) circshift(x.velocity_mmPerSec,[shiftAmount 0]),data,'UniformOutput',false);
            velocityBlock_mmPerSec=cell2mat(permute(velocityBlock_mmPerSec,[1 3 2]));
            
            %check against the pseudovelocities
            calcPseudoVelocity=sqrt(squeeze(sum(velocityBlock_mmPerSec.^2,2))).*squeeze(sign(velocityBlock_mmPerSec(:,3,:)));
            %
            
            %%
            if sum(abs(reshape(calcPseudoVelocity-mri.data_mmPerSec,[],1)))>1e-6
                error('The error term is too large');
            else
                mri.velocityBlock_mmPerSec=velocityBlock_mmPerSec;
            end
            mri.sourceData=data;
            
            return;
        end
        
        function subjectIndex=findSubjectIndexFromId(this,subjectId)
            
            gmuIdIndex=arrayfun(@(x) strcmp(x.subject.gmu.id,subjectId),this.mriDB);
            nihIdIndex=arrayfun(@(x) strcmp(x.subject.nih.id,subjectId),this.mriDB);
            
            if ~any(gmuIdIndex) && sum(nihIdIndex)==1
                subjectIndex=find(nihIdIndex);
            elseif sum(gmuIdIndex)==1 && ~any(nihIdIndex)
                subjectIndex=find(gmuIdIndex);
            elseif ~any(gmuIdIndex) && ~any(nihIdIndex)
                error([subjectId ' was not found in the database.']);
            else
                error(['Multiple subjects found for ' subjectId ]);
            end
            
        end
        
        
        %This function will return all the subjects region and corner
        %point data.  The cell array is 2 by N where N is the number of subjects.
        %The first row contains the the subject name in gmu or nih format
        %and the second row contains all rois each represented as a two
        %element column vector where the first element is the roi and the
        %second element is the corner point
        %
        %INPUT
        %subjectNumber - This assumes a GMU string ID
        %roiNumber(2 by N) should be in the form of roi;corner
        %
        %OUTPUT
        %isRoiFound - a boolean vector of length N that indicates if the
        %requested roi is available in the database
        function isRoiFound=isRoi(this,subjectId,roiNumber)
            
            subjectIndex=this.findSubjectIndexFromId(subjectId);
            %roiList=cell(2,length(this.mriDB));
            data=this.mriDB(subjectIndex).data;
            
            %             ii=subjectIndex;
            %             roiList{1,ii}=this.mriDB(ii).subject.gmu.id;
            %             roiList{2,ii}=this.mriDB(ii).subject.gmu.id;
            % %
            %             if size(roiNumber,2)~=1
            %                 error('Currently it is assumed that the length of roiNumber is fixed at 1');
            %             else
            %                 rr=1;
            %             end
            %
            isRoiFound=false(1,size(roiNumber,2));
            for rr=1:size(roiNumber,2)
                
                if (length(data(1).regionLabelName)==5)  && strcmpi('Rc', data(1).regionLabelName([1 4]))
                    roiName=sprintf('R%d_C%d', roiNumber(1,rr),roiNumber(2,rr));
                elseif (length(data(1).regionLabelName)==8)  && strcmpi('Rc', data(1).regionLabelName([4 7]))
                    roiName=sprintf('RF_R%d_C%d', roiNumber(1,rr),roiNumber(2,rr));
                else
                    error(['regionLabelName ' data(1).regionLabelName ' not support.']);
                end
                
                roiRegionIndex=find(arrayfun(@(x) (length(x.regionLabelName)>=length(roiName)) && strcmpi(roiName,x.regionLabelName(1:length(roiName))), data));
                if isempty(roiRegionIndex)
                    isRoiFound(rr)=false;
                elseif length(roiRegionIndex)==1
                    isRoiFound(rr)=true;
                else
                    error('roiRegionIndex must be a scalar')
                end
            end
            
        end
        
        
        
        
        %getWaveform gets the MRI waveform loaded and projected
        %appropriatly
        %
        %imagePlane - the plane is given by left, posterior, superior.
        %This is NOT the unit normal vector to the actual plane, but the
        %coordinates of the actual plane.  This allows for the a single
        %dimension to be passed when projecting onto a line or three
        %dimensions to be passed when projecting onto the entire volume.
        %The vectors should be passed in as column vectors.
        %
        %subjectId - can be a character name of the collect or a number.
        %If it is a number it is assumed to have the MRUS%03d_V1
        %
        %showPlot - Show the plots
        function mri=getRoi(this,subjectId,varargin)
            
            p = inputParser;   % Create an instance of the class.
            
            p.addRequired('subjectId',@(x) (isnumeric(x) && isscalar(x)) || ischar(x) || isempty(x));
            p.addParamValue('dataBlockObj',[],@(x) isempty(x) || isa(x,'DataBlockObj'));
            p.addParamValue('imagePlane',[],@(x) (isvector(x) && isnumeric(x)) || isempty(x));
            p.addParamValue('distanceMeasure',[],@(x) isstruct(x) || isempty(x));
            p.addParamValue('showPlot',false,@(x) islogical(x) && isscalar(x));
            p.addParamValue('roi',[5 5 5 5; 1 2 3 4],@(x) isnumeric(x) || iscell(x));
            
            p.parse(subjectId,varargin{:});
            
            dataBlockObj=p.Results.dataBlockObj;
            imagePlane=p.Results.imagePlane;
            distanceMeasure=p.Results.distanceMeasure;
            showPlot=p.Results.showPlot;
            roi=p.Results.roi;
            
            %convert to a GMU string format
            if isnumeric(subjectId)
                subjectId=sprintf('MRUS%03d_V1',subjectId);
            end
            
            %             switch(nargin)
            %                 case 3
            %                     imagePlane=[];
            %                     showPlot=false;
            %                     distanceMeasure=[];
            %                     roiOverride=[];
            %                 case 4
            %                     showPlot=false;
            %                     distanceMeasure=[];
            %                     roiOverride=[];
            %                 case 5
            %                     distanceMeasure=[];
            %                     roiOverride=[];
            %                 case 6
            %                     roiOverride=[];
            %                 case 7
            %                     %do nothing
            %                 otherwise
            %                     error('Incorrect number of inputs.');
            %             end
            %
            %subject.series(end).source.excel.defaultRoi=5;
            
            
            %rootPath=fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data');
            
            %             if strcmp('MRUS',trialData.subject.name(1:4))
            %                 caseChoice=trialData.subject.name(1:7);
            %             else
            %                 caseChoice=trialData.subject.name;
            %             end
            %             switch(caseChoice)
            %                 case {'MRUS003','rectusFemoris_phantom_linearMotion_fascicle','rectusFemoris_phantom_linearMotion_fascicle_short_run'}
            %                     mri=this.valuesMRUS003(fullfile(rootPath,'MRUS003','MRUS003.xlsx'),dataBlockObj.blockSource,roiOverride);
            %                 case {'MRUS004'}
            %                     %  mri=this.valuesMRUS004(fullfile(rootPath,'MRUS004','MRUS004.xlsx'),dataBlockObj.blockSource,roiOverride);
            %                     mri=this.valuesMRUS004(fullfile(rootPath,'MRUS004','SID5888L_11_17_2013_RF_VI_edit.xlsx'),'Ser12 PC',dataBlockObj.blockSource,roiOverride);
            %                 case {'MRUS005'}
            %                     %  mri=this.valuesMRUS005(fullfile(rootPath,'MRUS005','MRUS005.xlsx'),dataBlockObj.blockSource,roiOverride);
            %                     mri=this.valuesMRUS005(fullfile(rootPath,'MRUS005','SID6337L_11_17_2013_RF_VI.xlsx'),'Ser14 PC',dataBlockObj.blockSource,roiOverride);
            %                 case {'MRUS006'}
            %                     %  mri=this.valuesMRUS006(fullfile(rootPath,'MRUS006','MRUS006.xlsx'),dataBlockObj.blockSource,roiOverride);
            %                     mri=this.valuesMRUS006(fullfile(rootPath,'MRUS006','SID8476_11_17_2013_RF_VI_new_edit.xlsx'),'8476_Ser11 PC',dataBlockObj.blockSource,roiOverride);
            %                     % mri=this.valuesMRUS006(fullfile(rootPath,'MRUS006','SID8476_11_17_2013_RF_VI_new_edit.xlsx'),'edit_8476_Ser13 PC',dataBlockObj.blockSource,roiOverride);
            %                 case {'MRUS007'}
            %                     mri=this.valuesMRUS007(fullfile(rootPath,'MRUS007','SID9159R_9_19_2014_RF.xlsx'),'Ser9 PC',dataBlockObj.blockSource,roiOverride);
            %                 case {'MRUS008'}
            %                     mri=this.valuesMRUS008(fullfile(rootPath,'MRUS008','SID4957R_9_19_2014_RF2_edit.xlsx'),'Ser6 PC',dataBlockObj.blockSource,roiOverride);
            %                 case {'MRUS009'}
            %                     roiOverride=1;
            %                     mri=this.valuesMRUS009(fullfile(rootPath,'MRUS009','SID7515R_9_26_2014_RF_v2.xlsx'),'Ser8',dataBlockObj.blockSource,roiOverride);
            %                 case {'MRUS010'}
            %                     mri=this.valuesMRUS010(fullfile(rootPath,'MRUS010','SID9319R_9_26_2014_RF_v2.xlsx'),'Ser9 3rd analysis',dataBlockObj.blockSource,roiOverride);
            %                 case {'MRUS011'}
            %                     mri=this.valuesMRUS011(fullfile(rootPath,'MRUS011','SID5005R_9_26_2014_RF.xlsx'),'Ser8',dataBlockObj.blockSource,roiOverride);
            %                 otherwise
            %                     warning(['Unsupported trial name of ' trialData.subject.name ' so using MRUS007']);
            %                     mri=this.valuesMRUS007(fullfile(rootPath,'MRUS007','SID9159R_9_19_2014_RF.xlsx'),'Ser9 PC',dataBlockObj.blockSource,roiOverride);
            %
            %             end
            
            
            mri=this.initializeRoiStruct(subjectId,roi);
            
            if isempty(dataBlockObj)
                mri.us=this.getUSWaveformSync(subjectId,'');
            elseif ischar(dataBlockObj.blockSource)
                mri.us=this.getUSWaveformSync(subjectId,dataBlockObj.blockSource);
           elseif isempty(dataBlockObj.blockSource)
                mri.us=this.getUSWaveformSync(subjectId,'');
            else
                error('dataBlockObj.blockSource is in error, either the type is not char or the field does not exist');
            end
            
            if ~isempty(imagePlane)
                
                blockingMatrix=eye(3)-imagePlane*imagePlane';
                
                [V, D]=eig(blockingMatrix);
                
                if false
                    %% Plot the image plane
                    figure;
                    plot3([0 V(1,2)],[0 V(2,2)],[0 V(3,2)],'b');
                    hold on
                    plot3([0 V(1,3)],[0 V(2,3)],[0 V(3,3)],'b');
                    plot3([0 imagePlane(1)],[0 imagePlane(2)],[0 imagePlane(3)],'r');
                    xlabel('Left Displacement (mm)');
                    ylabel('Posterior Displacement (mm)');
                    zlabel('Superior Displacement (mm)');
                end
                
                %Perform the projection of the 3D data onto the image plane
                velocityBlockOnUSPlane_mmPerSec=zeros(size(mri.velocityBlock_mmPerSec));
                velocityBlockOrthogonalToUSPlane_mmPerSec=zeros(size(mri.velocityBlock_mmPerSec));
                for ii=1:size(velocityBlockOnUSPlane_mmPerSec,3)
                    tmp=blockingMatrix*mri.velocityBlock_mmPerSec(:,:,ii).';
                    velocityBlockOnUSPlane_mmPerSec(:,:,ii)=tmp.';
                    
                    tmp=imagePlane*imagePlane'*mri.velocityBlock_mmPerSec(:,:,ii).';
                    velocityBlockOrthogonalToUSPlane_mmPerSec(:,:,ii)=tmp.';
                end
                
                
                %compute the pseudo velocity
                if isempty(distanceMeasure)
                    pseudoVelocityBlock_mmPerSec=sqrt(squeeze(sum(velocityBlockOnUSPlane_mmPerSec.^2,2))).*squeeze(sign(mri.velocityBlock_mmPerSec(:,3,:)));
                else
                    
                    switch(distanceMeasure.key)
                        case 'axial'
                            %This is in reference to the ultrasound probe
                            %which is assumed to be in the Posterior
                            %direction which is the seciond mri dimension
                            pseudoVelocityBlock_mmPerSec=squeeze(velocityBlockOnUSPlane_mmPerSec(:,2,:));
                        case 'lateral'
                            %This is in reference to the ultrasound probe
                            %which is assumed to be in the Superior
                            %direction which is the third mri dimension
                            pseudoVelocityBlock_mmPerSec=squeeze(velocityBlockOnUSPlane_mmPerSec(:,3,:));
                        case 'signedDistance'
                            pseudoVelocityBlock_mmPerSec=sqrt(squeeze(sum(velocityBlockOnUSPlane_mmPerSec.^2,2))).*squeeze(sign(mri.velocityBlock_mmPerSec(:,3,:)));
                        otherwise
                            error(['Unsupported distance metric of ' distanceMeasure.key])
                    end
                    
                end
                
                if false
                    %%show what the US plane would see
                    figure;
                    ii=1;
                    plot3(velocityBlockOnUSPlane_mmPerSec(:,1,ii),velocityBlockOnUSPlane_mmPerSec(:,2,ii),velocityBlockOnUSPlane_mmPerSec(:,3,ii),'.')
                end
                ts_sec=mri.ts_sec;
                mri.projectedPseudoVelocityBlock_mmPerSec=pseudoVelocityBlock_mmPerSec;
                mri.velocityBlockOrthogonalToUSPlane_mmPerSec=velocityBlockOrthogonalToUSPlane_mmPerSec;
                mri.imagePlaneUS=imagePlane;
                
                %Override the default settings with the projected info.
                mri.data_mmPerSec=mri.projectedPseudoVelocityBlock_mmPerSec;
                mri.data_mm=cumsum(mri.data_mmPerSec,1)*mri.ts_sec;
                
                if showPlot
                    activeIndex=2;
                    pseudoVelocity_mmPerSec=pseudoVelocityBlock_mmPerSec(:,activeIndex);
                    path_mm=cumsum(squeeze(mri.velocityBlock_mmPerSec(:,:,activeIndex))*ts_sec,1);
                    
                    jetColorMap=jet(256);
                    pseudovelocityToJetColorMap=linspace(min(pseudoVelocity_mmPerSec),max(pseudoVelocity_mmPerSec),size(jetColorMap,1));
                    
                    N=50;
                    oversampleIndex=linspace(1,size(path_mm,1),size(path_mm,1)*N);
                    pathOversample_mm=zeros(N*size(path_mm,1),3);
                    for jj=1:size(path_mm,2)
                        pathOversample_mm(:,jj)=interp1(1:size(path_mm,1),path_mm(:,jj),oversampleIndex);
                    end
                    
                    velocityMappingIndex=round(interp1(pseudovelocityToJetColorMap,1:size(jetColorMap,1),pseudoVelocity_mmPerSec));
                    
                    figure;
                    imagesc(pseudoVelocity_mmPerSec(:,1));colormap(jetColorMap); colorbar;
                    
                    figure;
                    
                    for ii=1:size(pathOversample_mm,1)
                        plot3(pathOversample_mm(ii,1),pathOversample_mm(ii,2),pathOversample_mm(ii,3),'.','Color',jetColorMap(velocityMappingIndex(round(oversampleIndex(ii))),:))
                        hold on;
                    end
                    
                    if false
                        for ii=1:size(path_mm,1)
                            plot3(path_mm(ii,1),path_mm(ii,2),path_mm(ii,3),'Color',jetColorMap(velocityMappingIndex(ii),:))
                            hold on;
                        end
                    end
                    
                    boundingBox_mm=[min(path_mm(:,2)) max(path_mm(:,2)); min(path_mm(:,3)) max(path_mm(:,3))];
                    boundingBoxIndex=[1 1 2 2 1; 1 2 2 1 1];
                    
                    %assume it will mostly be on the posterior superior plane
                    boundingBox3D_mm=V*[0*boundingBoxIndex(1,:); boundingBox_mm(1,boundingBoxIndex(1,:)); boundingBox_mm(2,boundingBoxIndex(2,:))];
                    %rotate the points
                    
                    hold on
                    refPlaneH=plot3(0*boundingBoxIndex(1,:)+mean(path_mm(:,1)),boundingBox_mm(1,boundingBoxIndex(1,:)),boundingBox_mm(2,boundingBoxIndex(2,:)),'Color',[0 0 0 ]);
                    actualPlaneH=plot3(boundingBox3D_mm(1,:)+mean(path_mm(:,1)),boundingBox3D_mm(2,:),boundingBox3D_mm(3,:),'Color',[0 0 1 ]);
                    
                    xlabel('Left Displacement (mm)');
                    ylabel('Posterior Displacement (mm)');
                    zlabel('Superior Displacement (mm)');
                    
                    legend([refPlaneH actualPlaneH],'Sagittal plane','US plane')
                    
                    figure;
                    subplot(1,2,1)
                    for ii=1:size(mri.mriReported.data_mmPerSec,2)
                        plot(mri.t_sec,mri.mriReported.data_mmPerSec(:,ii),'b')
                        hold on
                        plot(mri.t_sec,mri.data_mmPerSec(:,ii),'r')
                    end
                    xlabel('time (sec)');
                    ylabel('velocity (mm/sec)');
                    legend('mri','projected on US plane');
                    
                    subplot(1,2,2)
                    for ii=1:size(mri.mriReported.data_mmPerSec,2)
                        plot(mri.t_sec,mri.mriReported.data_mmPerSec(:,ii),'b')
                        hold on
                        plot(mri.t_sec,mri.velocityBlockOrthogonalToUSPlane_mmPerSec(:,ii),'r')
                    end
                    xlabel('time (sec)');
                    ylabel('velocity (mm/sec)');
                    legend('mri','orthogonal to US plane');
                    
                end
                
                if showPlot && false
                    figure;
                    
                    for activeIndex=1:size(pseudoVelocityBlock_mmPerSec,2)
                        pseudoVelocity_mmPerSec=pseudoVelocityBlock_mmPerSec(:,activeIndex);
                        path_mm=cumsum(squeeze(mri.velocityBlock_mmPerSec(:,:,activeIndex))*ts_sec,1);
                        
                        jetColorMap=jet(256);
                        pseudovelocityToJetColorMap=linspace(min(pseudoVelocity_mmPerSec),max(pseudoVelocity_mmPerSec),size(jetColorMap,1));
                        
                        N=50;
                        oversampleIndex=linspace(1,size(path_mm,1),size(path_mm,1)*N);
                        pathOversample_mm=zeros(N*size(path_mm,1),3);
                        for jj=1:size(path_mm,2)
                            pathOversample_mm(:,jj)=interp1(1:size(path_mm,1),path_mm(:,jj),oversampleIndex);
                        end
                        
                        velocityMappingIndex=round(interp1(pseudovelocityToJetColorMap,1:size(jetColorMap,1),pseudoVelocity_mmPerSec));
                        
                        
                        
                        for ii=1:size(pathOversample_mm,1)
                            plot3(pathOversample_mm(ii,1),pathOversample_mm(ii,2),pathOversample_mm(ii,3),'.','Color',jetColorMap(velocityMappingIndex(round(oversampleIndex(ii))),:))
                            hold on;
                        end
                    end
                    
                    xlabel('Left Displacement (mm)');
                    ylabel('Posterior Displacement (mm)');
                    zlabel('Superior Displacement (mm)');
                    
                end
                
                
            else
                mri.projectedPseudoVelocityBlock_mmPerSec=[];
                mri.velocityBlockOrthogonalToUSPlane_mmPerSec=[];
                mri.imagePlaneUS=[];
                
                %Override the default settings with the projected info.
                
                %                 if isfield(trialData.subject,'phantom')
                %                     mri.data_mmPerSec=mri.mriReported.data_mmPerSec;
                %                     %mri.data_mm=cumsum(mri.mriReported.data_mmPerSec,1)*mri.ts_sec;
                %                     mri.data_mm=mri.mriReported.data_mm;
                %                 else
                %                     mri.data_mmPerSec=mri.mriReported.data_mmPerSec;
                %                     mri.data_mm=mri.mriReported.data_mm;
                %                 end
                
                
            end
            
        end
    end
    
    methods (Access=private)
        
        %         %We want to load the MRI data of both the pseudovelcoty and the
        %         %true velocity which will need a projection plane that represents
        %         %the ultrasound transducer slice angle.
        %         %INPUT
        %         %roiNumber is assumed to be a number in the range
        %         %R<min>_c?-R<max>_c? whihc is given in the spreadsheet names
        %         function mri=setupUpDefaultMriData(this,mriDataFilename,ts_sec,roiNumber)
        %             mri.mriReported.data_mmPerSec=xlsread(mriDataFilename,'SignedSpeed');
        %
        %             mri.ts_sec=ts_sec;
        %             mri.t_sec=[0:(size(mri.mriReported.data_mmPerSec,1)-1)]*mri.ts_sec;
        %             mri.mriReported.data_mm=cumsum(mri.mriReported.data_mmPerSec,1)*mri.ts_sec;
        %             mri.sync_sec=0;
        %             mri.syncDisplacement=-17.2234;
        %             %mri.syncCycleShift=3;
        %             mri.syncCycleShift=0;
        %
        %             mri.data_mmPerSec= mri.mriReported.data_mmPerSec;
        %             mri.data_mm=mri.mriReported.data_mm;
        %
        %             %We need to parse the excel data to form
        %             [numberBlock textBlock]=xlsread(mriDataFilename,'Velocity');
        %             %trim the textblock to make sure it matches with the
        %             %numberblock for index matching
        %             textBlock(1,:)=[];  %remove the header
        %             if ~all(size(textBlock)==size(numberBlock))
        %                 error('text and number are out of sync')
        %             else
        %                 %do nothing
        %             end
        %
        %
        %             startIndex=find(numberBlock(:,2)==1);
        %             endIndex=find(numberBlock(:,2)==24);
        %
        %             arrayIndex=cell2mat(arrayfun(@(s,e) [s:e]',startIndex.',endIndex.','UniformOutput',false));
        %
        %             %The output is count seq, left, posterior, superior
        %             columnBaseIndex=repmat(size(numberBlock,1)*([2 (4:6)]-1),[size(arrayIndex,1),1]);
        %
        %             roiName=['RF_R' num2str(roiNumber)];
        %             roiRegionIndex=find(cellfun(@(testRegion) lif(isempty(testRegion) || length(testRegion)<length(roiName),false,@() strcmpi(roiName,testRegion(1:length(roiName))),true), textBlock(:,3)));
        %
        %             [rowCheck,roiColumn]=ind2sub(size(arrayIndex),arrayfun(@(idx) find(arrayIndex(:)==idx),roiRegionIndex));
        %             roiColumn=unique(roiColumn);
        %
        %             if ~isempty(setdiff(1:24,unique(rowCheck)))
        %                 warning('roi finder failed.');
        %                 mri.roiColumn=[];
        %             else
        %                 mri.roiColumn=roiColumn;
        %                 %do nothing
        %             end
        %
        %             %create for each case
        %             columnBaseIndex=repmat(columnBaseIndex, [1 1 size(arrayIndex,2)]);
        %             velocityBlock_mmPerSec=numberBlock(permute(repmat(arrayIndex, [1 1 4]),[1 3 2])+columnBaseIndex);
        %
        %             if ~all(all(diff(squeeze(velocityBlock_mmPerSec(:,1,:)),2)==0))
        %                 error('Counting sequence is not correct.');
        %             else
        %                 velocityBlock_mmPerSec(:,1,:)=[];
        %             end
        %
        %             %check against the pseudovelocities
        %             calcPseudoVelocity=sqrt(squeeze(sum(velocityBlock_mmPerSec.^2,2))).*squeeze(sign(velocityBlock_mmPerSec(:,3,:)));
        %             if sum(abs(reshape(calcPseudoVelocity-mri.data_mmPerSec,[],1)))>1e-6
        %                 error('The error term is too large');
        %             else
        %                 mri.velocityBlock_mmPerSec=velocityBlock_mmPerSec;
        %             end
        %
        %             return;
        %
        %
        %         end
        %
        %         function mri=setupUpDefaultMriDataUsingDirectXlsAccess(this,mriDataFilename,mriXlsSheetName,ts_sec,roiNumber,colOffsetBetweenVelocityBlockAndRegionLabel,startRegionLabel)
        %
        %
        %             velocityBlock=loadMriExcelSheet(mriDataFilename,mriXlsSheetName,24,colOffsetBetweenVelocityBlockAndRegionLabel,startRegionLabel);
        %             %mri.mriReported.data_mmPerSec=xlsread(mriDataFilename,'SignedSpeed');
        %             mri.mriReported.data_mmPerSec=[velocityBlock.projectedAndShifted_mmPerSec];
        %
        %             mri.ts_sec=ts_sec;
        %             mri.t_sec=[0:(size(mri.mriReported.data_mmPerSec,1)-1)]*mri.ts_sec;
        %             mri.mriReported.data_mm=cumsum(mri.mriReported.data_mmPerSec,1)*mri.ts_sec;
        %             mri.sync_sec=0;
        %             mri.syncDisplacement=-17.2234;
        %             %mri.syncCycleShift=3;
        %             mri.syncCycleShift=0;
        %
        %             mri.data_mmPerSec= mri.mriReported.data_mmPerSec;
        %             mri.data_mm=mri.mriReported.data_mm;
        %
        %             %             %We need to parse the excel data to form
        %             %             [numberBlock textBlock]=xlsread(mriDataFilename,'Velocity');
        %             %             %trim the textblock to make sure it matches with the
        %             %             %numberblock for index matching
        %             %             textBlock(1,:)=[];  %remove the header
        %             %             if ~all(size(textBlock)==size(numberBlock))
        %             %                 error('text and number are out of sync')
        %             %             else
        %             %                 %do nothing
        %             %             end
        %             %
        %             %
        %             %             startIndex=find(numberBlock(:,2)==1);
        %             %             endIndex=find(numberBlock(:,2)==24);
        %             %
        %             %             arrayIndex=cell2mat(arrayfun(@(s,e) [s:e]',startIndex.',endIndex.','UniformOutput',false));
        %
        %             %The output is count seq, left, posterior, superior
        %             %columnBaseIndex=repmat(size(numberBlock,1)*([2 (4:6)]-1),[size(arrayIndex,1),1]);
        %
        %             roiName=['RF_R' num2str(roiNumber)];
        %
        %
        %
        %             roiRegionIndex=find(arrayfun(@(x) strcmpi(roiName,x.regionLabelName(1:length(roiName))), velocityBlock));
        %             mri.roiColumn=roiRegionIndex;
        %
        %
        %             shiftAmount=[velocityBlock(roiRegionIndex).shiftAmount];
        %             if ~all(diff(shiftAmount)==0)
        %                 error('Shifts are different')
        %             else
        %                 shiftAmount=shiftAmount(1);
        %             end
        %             shiftAmount=size(mri.mriReported.data_mmPerSec,1)-shiftAmount+1;  %rotate shift to work with circshift
        %
        %             velocityBlock_mmPerSec=arrayfun(@(x) circshift(x.actual_mmPerSec,[shiftAmount 0]),velocityBlock,'UniformOutput',false);
        %             velocityBlock_mmPerSec=cell2mat(permute(velocityBlock_mmPerSec,[1 3 2]));
        %
        %             %check against the pseudovelocities
        %             calcPseudoVelocity=sqrt(squeeze(sum(velocityBlock_mmPerSec.^2,2))).*squeeze(sign(velocityBlock_mmPerSec(:,3,:)));
        %             %
        %
        %             %%
        %             if sum(abs(reshape(calcPseudoVelocity-mri.data_mmPerSec,[],1)))>1e-6
        %                 error('The error term is too large');
        %             else
        %                 mri.velocityBlock_mmPerSec=velocityBlock_mmPerSec;
        %             end
        %             mri.sourceVelocityBlock=velocityBlock;
        %
        %             return;
        %
        %
        %         end
        %
        
        
        %This function outputs information handy for aligning the cycles in
        %a display.  This should only be useful for alignment purposes
        function us=getUSWaveformSync(this,subjectId,ultrasoundSourceFilename)
            
            [~,fileName,fileExt]=fileparts(ultrasoundSourceFilename);
            
            %set the default values
            us.sync_sec=0;
            us.syncDisplacement=-17.2234;
            us.syncCycleShift=0;
            
            switch(subjectId)
                case {'MRUS003_V1','SID3797_5_02_2013_RF_VI_RF'}
                    switch([fileName,fileExt])
                        case {'18-50-32.rf','18-50-32.b8'}
                            us.sync_sec=3.3801+0.3223; us.syncDisplacement=-17.2234+7.6312;
                        case {'18-53-49.rf','18-53-49.b8'}
                            us.sync_sec=3.3801; us.syncDisplacement=-17.2234+7.6312;
                        case {'19-10-13.rf','19-10-13.b8'}
                            us.sync_sec=2.6357; us.syncDisplacement=-17.2234+7.6312;
                        case 'default'
                            us.syncCycleShift=-2; us.sync_sec=0; us.syncDisplacement=-17.2234+8.9511+6.3026;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                case {'MRUS004_V1','SID5888L_11_17_2013_RF_VI'}
                    switch([fileName,fileExt])
                        case '09-59-11.rf'
                            us.sync_sec=3.3801-0.9045; us.syncDisplacement=-17.2234+7.6312;
                        case '09-59-11.b8'
                            us.sync_sec=3.3801-0.9045; us.syncDisplacement=-17.2234+7.6312;
                        case '10-00-45.rf'
                            us.sync_sec=2.6357;
                        case '10-00-45.b8'
                            us.sync_sec=2.6357;
                        case '10-00-48.b8'
                            us.sync_sec=2.6357;
                        case '10-02-25.b8'
                            us.sync_sec=2.6357;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                case {'MRUS005_V1','SID6337L_11_17_2013_RF_VI'}
                    switch([fileName,fileExt])
                        case {'11-48-19.rf','11-48-19.b8'}
                            us.sync_sec= 1.5784+4.0392;
                        case '11-50-03.rf'
                            us.sync_sec=6.3480+0.2304;    us.syncDisplacement=-17.2234+8.9511;
                        case '11-50-03.b8'
                            us.sync_sec=6.3480+0.2304;   us.syncDisplacement=-17.2234+8.9511+6.3026;
                        case 'default'
                            us.syncCycleShift=0;       us.sync_sec= 0;    us.syncDisplacement=-17.2234+8.9511+6.3026;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                case {'MRUS006_V1','SID8476_11_17_2013_RF_VI'}
                    switch([fileName,fileExt])
                        case '13-12-02.b8'
                            us.sync_sec=0; us.syncDisplacement=-17.2234+16.6324;
                        case '13-12-02.rf'
                            us.sync_sec=2.9438;  us.syncDisplacement=-17.2234+15.8598;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                case {'MRUS007_V1','SID9159R_9_19_2014_RF'}
                    switch([fileName,fileExt])
                        case '13-12-02.b8'
                            us.sync_sec=0; us.syncDisplacement=-17.2234+16.6324;
                        case '13-12-02.rf'
                            us.sync_sec=2.9438; us.syncDisplacement=-17.2234+15.8598;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                case {'MRUS008_V1','SID4957R_9_19_2014_RF'}
                    switch([fileName,fileExt])
                        case '13-12-02.b8'
                            us.sync_sec=0;     us.syncDisplacement=-17.2234+16.6324;
                        case '13-12-02.rf'
                            us.sync_sec=2.9438; us.syncDisplacement=-17.2234+15.8598;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                case {'MRUS009_V1','SID7515R_9_26_2014_RF'}
                    switch([fileName,fileExt])
                        case '09-24-12.b8'
                            us.sync_sec=0.3284; us.syncDisplacement=0;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                case {'MRUS010_V1','SID9319R_9_26_2014_RF'}
                    switch([fileName,fileExt])
                        case '11-12-40.b8'
                            us.sync_sec=1.3627;  us.syncDisplacement=0;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                case {'MRUS011_V1','SID5005R_9_26_2014_RF'}
                    switch([fileName,fileExt])
                        case '14-22-26.b8'
                            us.sync_sec= 0.4706;  us.syncDisplacement=0;
                        otherwise
                            warning(['Unsupported file of ' [fileName fileExt]]);
                    end
                otherwise
                    warning(['Unsupported subject ' subjectId]);
            end
            
            
        end
        
    function subjectList=defaultSubjectList(this)
    %% Subject 003 Tag: ?
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS003_V1';
    subject.nih.id='SID3797_5_02_2013_RF_VI_RF';
    subject.series(1).tag='Ser4 PC';
    subject.series(end).source.excel.filename='SID3797_5_02_2013_RF_VI_RFOverwrite.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList=subject; %MUST ADD the subject to the list
    
    %% Subject: 004 Tag: Ser12 PC
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS004_V1';
    subject.nih.id='SID5888L_11_17_2013_RF_VI';
    subject.series(1).tag='Ser12 PC';
    subject.series(end).source.excel.filename='SID5888L_11_17_2013_RF_VI_edit.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R4_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list
    
    %% Subject: 005 Tag: Ser14 PC
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS005_V1';
    subject.nih.id='SID6337L_11_17_2013_RF_VI';
    subject.series(1).tag='Ser14 PC';
    subject.series(end).source.excel.filename='SID6337L_11_17_2013_RF_VI.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R3_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list
    
    %% Subject: 006 Tag: 8476_Ser11 PC
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS006_V1';
    subject.nih.id='SID8476_11_17_2013_RF_VI';
    subject.series(1).tag='8476_Ser11 PC';
    subject.series(end).source.excel.filename='SID8476_11_17_2013_RF_VI_new_edit.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list
    
    %% Subject 007 Tag: Ser9 PC
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS007_V1';
    subject.nih.id='SID9159R_9_19_2014_RF';
    subject.series(1).tag='Ser9 PC';
    subject.series(end).source.excel.filename='SID9159R_9_19_2014_RF.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list
    
    %% Subject 008 Tag: Ser6 PC
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS008_V1';
    subject.nih.id='SID4957R_9_19_2014_RF';
    subject.series(1).tag='Ser6 PC';
    subject.series(end).source.excel.filename='SID4957R_9_19_2014_RF2_edit.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list
    
    %% Subject 009 Tag: Ser8
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS009_V1';
    subject.nih.id='SID7515R_9_26_2014_RF';
    subject.series(1).tag='Ser8';
    subject.series(end).source.excel.filename='SID7515R_9_26_2014_RF_v2.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list
    
    %% Subject 010 Tag: Ser9 3rd analysis
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS010_V1';
    subject.nih.id='SID9319R_9_26_2014_RF';
    subject.series(1).tag='Ser9 3rd analysis';
    subject.series(end).source.excel.filename='SID9319R_9_26_2014_RF_v2.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list
    
    %% Subject 011 Tag: Ser8
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS011_V1';
    subject.nih.id='SID5005R_9_26_2014_RF';
    subject.series(1).tag='Ser8';
    subject.series(end).source.excel.filename='SID5005R_9_26_2014_RF.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list
    
    %% Subject: 012 Tag: Ser9 PC
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS012_V1';
    subject.nih.id='SID9885R_6_12_2015_RF_VI';
    subject.series(1).tag='Ser9 PC ';
    subject.series(end).source.excel.filename='SID_9885R_Leg_6_12_2015_RF.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list    

    %% Subject: 013 Tag: Ser6 PC
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS013_V1';
    subject.nih.id='SID2098R_6_12_2015_RF_VI';
    subject.series(1).tag='Ser6 PC';
    subject.series(end).source.excel.filename='SID_2098R_Leg_6_12_2015_RF.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list    

    %% Subject: 014 Tag: Ser6 PC
    subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    subject.gmu.id='MRUS014_V1';
    subject.nih.id='SID5888L_6_12_2015_RF_VI';
    subject.series(1).tag='Ser6 PC';
    subject.series(end).source.excel.filename='SID_2175R_Leg_6_12_2015_RF_ser7.xlsx';
    subject.series(end).source.excel.worksheet=subject.series(end).tag;
    subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    subject.series(end).source.excel.ts_sec=1/12;
    subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    subject.series(end).source.excel.isFlexion(1:12)=true;
    subject.series(end).source.excel.defaultRoi=5;
    subjectList(end+1)=subject; %MUST ADD the subject to the list    
    
    %*********************THIS IS THE TEMPLATE FOR A NEW ENTRY**********************
    % %% Subject 00? Tag: ?
    % subject=[]; %clear the structure each time to prevent fields from the previous definition from being added
    % subject.gmu.id='MRUS00?_V1';
    % subject.nih.id='??';
    % subject.series(1).tag='??';
    % subject.series(end).source.excel.filename='??';
    % subject.series(end).source.excel.worksheet=subject.series(end).tag;
    % subject.series(end).source.excel.velocityMeasurementsPerRegion=24;
    % subject.series(end).source.excel.ts_sec=1/12;
    % subject.series(end).source.excel.colOffsetBetweenVelocityBlockAndRegionLabel=4;
    % subject.series(end).source.excel.startRegionLabel='RF_R1_c1';
    % subject.series(end).source.excel.isFlexion=false(subject.series(end).source.excel.velocityMeasurementsPerRegion,1);
    % subject.series(end).source.excel.isFlexion(1:12)=true;
    % subject.series(end).source.excel.defaultRoi=5;
    % subjectList(end+1)=subject; %MUST ADD the subject to the list
    %
    end
  end    
    
end


