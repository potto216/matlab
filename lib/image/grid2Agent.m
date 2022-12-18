classdef grid2Agent < hgsetget
    %GRID2AGENT This defines a graphical agent on an image.
    % Skeleton is point container and can be open or closed region.
    % Outlines given can be a rectangular box around region, but could search for exterior points.
    
    properties (Constant)
        validRegionTypes={'spline','point'};
    end
    
    properties
        regionType='spline';
        color='r'; %default to red
        dataBlockObj=[];
    end
    
    properties (Access=private)
        activeSlice=[];
        axesList=[];
        skeleton=struct([]);
        activeSkeleton=[];
        nextImpointDBUniqueId=[];
        %The graphics display need to be decoupled from the skeleton
        %information.
        impointDB=struct([]);
        trackletDB=struct([]);
        showTrackletNameList_trackletIndex=[];
    end
    
    methods
        function this=set.regionType(this,newRegionValue)
            if ~any(strcmp(this.validRegionTypes,newRegionValue))
                error(['Valid region types are: ' this.validRegionTypes{:}])
            end
            this.regionType=newRegionValue;
        end
        
        function this=set.color(this,newColor)
            this.color=newColor;
        end
        
        function this=set.dataBlockObj(this,newDataBlockObj)
            this.dataBlockObj=newDataBlockObj;
        end
    end
    
    methods  (Access=public)
        
        %This function updates the skeleton points from impoints and is
        %needed to make sure the data is stored when the impoints are
        %deleted
        %We assume if the impoints exist then they have valid location
        %information for the active spline.  We also assume that the
        %impoints for the active slice should be the values for the
        %skeleton list.  This means if impoints are deleted they should be
        %removed from the skeleton
        function refreshActiveSkeletonVertexListFromImpoints(this)
            if isempty(this.impointDB)
                return;
            else
                pointList_xy=cell2mat(arrayfun(@(x) this.impointDB(x).obj.getPosition',(1:length(this.impointDB)),'UniformOutput',false));
                this.skeleton(this.activeSkeleton).vertex.pointList_rc=flipud(pointList_xy);
                this.skeleton(this.activeSkeleton).vertex.idList=[this.impointDB(1:length(this.impointDB)).id];
                
            end
        end
        
        %This function is when you update the vertex list and need to
        %change the impoint position.  Assume that the points have not been
        %deleted.
        function refreshImpointsFromActiveSkeletonVertexList(this)
            if isempty(this.impointDB)
                return;
            else
                idxOfImpoint=arrayfun(@(id) find([this.impointDB(1:length(this.impointDB)).id]==id),this.skeleton(this.activeSkeleton).vertex.idList);
                colvecfun(@(pos_rc) this.impointDB(pos_rc(3)).obj.setPosition(pos_rc(2),pos_rc(1)),[this.skeleton(this.activeSkeleton).vertex.pointList_rc; idxOfImpoint]);
            end
        end
        
        function this=grid2Agent(newActiveSlice)
            
            this.showTrackletNameList_trackletIndex=[];
            this.activeSlice=newActiveSlice;
            this.nextImpointDBUniqueId=0;
            
            this.activeSkeleton=1;
            this.skeleton=this.createEmptySkeleton(this.activeSlice);  %no index is used since the struct is empty
            
            this.impointDB=struct([]);
            this.trackletDB=struct([]);
            
            
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
        %saveDataBlockObj - {false} Whether to save the dataObject
        %information
        
        function dataOut=save(this,filename,varargin)
            p = inputParser;   % Create an instance of the class.
            p.addRequired('filename', @(x) isempty(x) || ischar(x) );
            p.addParamValue('saveDataBlockObj',false,@(x) islogical(x));
            p.parse(filename,varargin{:});
            
            filename=p.Results.filename;
            saveDataBlockObj=p.Results.saveDataBlockObj;
            
            data.save.filename=filename;
            data.save.varargin=varargin;
            
            data.activeSlice=this.activeSlice;
            data.skeleton=this.skeleton;
            data.activeSkeleton=this.activeSkeleton;
            
            data.nextImpointDBUniqueId=this.nextImpointDBUniqueId;
            
            %The impointDB needs to be saved out seperately because it serializing the imroi objects
            %never seem to work very well.
            data.impointDBSave=struct([]);
            for ii=1:length(this.impointDB)
                data.impointDBSave(ii).id=this.impointDB(ii).id;
                data.impointDBSave(ii).obj.getColor=this.impointDB(ii).obj.getColor;
                data.impointDBSave(ii).obj.getPosition=this.impointDB(ii).obj.getPosition;
            end
            
            
            data.trackletDB=this.trackletDB;
            data.showTrackletNameList_trackletIndex=this.showTrackletNameList_trackletIndex;
            data.regionType=this.regionType;
            data.color=this.color;
            
            if saveDataBlockObj
                data.dataBlockObj=this.dataBlockObj.save([]);
            else
                data.dataBlockObj=[];
            end
            
            
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
        %saved for size constraint.  The dataObject is just checked to make
        %sure the same file is pointed to.  The datapoints are also
        %displayed
        %
        %INPUTS
        %filename - must be specified or empty
        %('dataSet',data) - This key value pair will load data if necessary
        %
        %('activeSlice',number) - This is the active slice number to use,
        %if empty it will use the activeSlice in the database, otherwise it
        %will over write with the one given
        %
        function load(this,filename,varargin)
            p = inputParser;   % Create an instance of the class.
            p.addRequired('filename', @(x) isempty(x) || ischar(x) );
            p.addParamValue('dataSet',[],@(x) isempty(x) || isstruct(x));
            p.addParamValue('activeSlice',[],@(x) isempty(x) || (isscalar(x) && isnumeric(x)));
            
            p.parse(filename,varargin{:});
            
            filename=p.Results.filename;
            activeSlice=p.Results.activeSlice;
            
            if isempty(this.axesList)
                error('The axesList must be specified.');
            end
            
            if ~isempty(filename) && isempty(p.Results.dataSet)
                data=load(filename,'data');
            elseif ~isempty(filename) && ~isempty(p.Results.dataSet)
                error('Cannot specify both the file and the dataSet');
            elseif  isempty(filename) && ~isempty(p.Results.dataSet)
                data = p.Results.dataSet;
            else  isempty(filename) && isempty(p.Results.dataSet)
                error('please specify the filename or the dataSet');
            end
            
            this.deleteAllGraphics;
            
            this.skeleton=data.skeleton;
            this.activeSkeleton=this.findSkeletonIdxFromSliceIdx(activeSlice);
            
            this.nextImpointDBUniqueId=data.nextImpointDBUniqueId;
            % this.impointDB=data.impointDBSave;
            this.trackletDB=data.trackletDB;
            this.showTrackletNameList_trackletIndex=data.showTrackletNameList_trackletIndex;
            this.regionType=data.regionType;
            this.color=data.color;
            
            if ~isempty(activeSlice)
                this.activeSlice= activeSlice;
            end
            
            this.plotSkeleton;
            
        end
        
        function addAxes(this,newAxes)
            this.axesList(end+1)=newAxes;
        end
        
        
        %When a point is added it is assumed that it is done via the GUI
        %unless a newPosition is given in the form of row,column
        %pointId identifies a preexisting point id which links the
        %impointdb and the skeleton id.
        function id=addSkeletonPoint(this,newPosition_rc,pointId,sliceToAddIn)
            switch(nargin)
                case 1
                    addImpoint=true;
                    newPosition_rc=[];
                    pointId=[];
                    sliceToAddIn=this.activeSlice;
                case 2
                    addImpoint=true;
                    pointId=[];
                    sliceToAddIn=this.activeSlice;
                case 3
                    addImpoint=true;
                    sliceToAddIn=this.activeSlice;
                case 4
                    if this.activeSlice==sliceToAddIn
                        addImpoint=true;
                    else
                        addImpoint=false;
                    end
                otherwise
                    error('Invalid number of arguments.')
            end
            
            if length(this.axesList)~=1
                error('Only axesList of 1 is currently supported')
            end
            
            if addImpoint
                
                if ~isempty(newPosition_rc)
                    this.impointDB(end+1).obj=impoint(this.axesList,[newPosition_rc(2) newPosition_rc(1)]);
                else
                    this.impointDB(end+1).obj=impoint(this.axesList);
                end
                if isempty(pointId)
                    this.impointDB(end).id=this.nextImpointDBUniqueId;
                    this.nextImpointDBUniqueId=this.nextImpointDBUniqueId+1;
                else
                    this.impointDB(end).id=pointId;
                end
                
                this.impointDB(end).obj.setColor(this.color);
                
                switch(this.regionType)
                    case 'spline'
                        this.impointDB(end).obj.addNewPositionCallback(@(roi) this.redrawSpline(roi));
                    case 'point'
                        this.impointDB(end).obj.addNewPositionCallback(@(roi) this.redrawPoint(roi));
                    otherwise
                        error(['Unsupported regionType of ' this.regionType]);
                end
                this.skeleton(this.activeSkeleton).slice=this.activeSlice;
                %add the delete option to the point menu
                uimenu(get(this.impointDB(end).obj,'UIContextMenu'), 'label','Name','Callback', {@this.nameSkeletonPoint ,this.impointDB(end).id});
                uimenu(get(this.impointDB(end).obj,'UIContextMenu'), 'label','Delete','Callback', {@this.deleteSkeletonPoint ,this.impointDB(end).id});
                uimenu(get(this.impointDB(end).obj,'UIContextMenu'), 'label','Show Tracklet','Callback', {@this.showSkeletonPointTracklet ,this.impointDB(end).id});
                uimenu(get(this.impointDB(end).obj,'UIContextMenu'), 'label','Assign Tracklet','Callback', {@this.callbackAsignSkeletonPointToTracklet ,this.impointDB(end).id});
                uimenu(get(this.impointDB(end).obj,'UIContextMenu'), 'label','Show Tracklet Name','Callback', {@this.callbackShowSkeletonPointTrackletName ,this.impointDB(end).id});
                id=this.impointDB(end).id;
                
                trackletIndex=find(arrayfun(@(idx) any(this.trackletDB(idx).idList==id),1:length(this.trackletDB)));
                if  ~isempty(this.showTrackletNameList_trackletIndex) && any(trackletIndex==this.showTrackletNameList_trackletIndex)
                    this.impointDB(end).obj.setString(this.trackletDB(trackletIndex).name);
                end
                
                
            else
                id=this.nextImpointDBUniqueId;
                this.nextImpointDBUniqueId=this.nextImpointDBUniqueId+1;
                
                skeletonIndexToUse=this.findSkeletonIdxFromSliceIdx(sliceToAddIn);
                
                %if the skeleton exists then copy it out and setup impoint.
                if ~isempty(skeletonIndexToUse)
                    
                else
                    skeletonIndexToUse=length(this.skeleton)+1;
                    this.skeleton(skeletonIndexToUse)=this.createEmptySkeleton(skeletonIndexToUse);
                    this.skeleton(skeletonIndexToUse).slice=sliceToAddIn;
                end
                
                this.skeleton(skeletonIndexToUse).vertex.pointList_rc(:,end+1)=newPosition_rc;
                this.skeleton(skeletonIndexToUse).vertex.idList(end+1)=id;
                
                
            end
        end
        
        
        function deleteSkeletonPoint(this,src,evn,id)
            disp(['Deleting impoint with id = ' num2str(id)])
            idx=find(arrayfun(@(x) this.impointDB(x).id==id,1:length(this.impointDB)));
            if length(idx)~=1
                error('Idx must be 1');
            end
            this.impointDB(idx).obj.delete;
            this.impointDB(idx)=[];
        end
        
        %This function will show a tracklet for a track
        function nameSkeletonPoint(this,src,evn,id)
            disp(['Deleting impoint with id = ' num2str(id)])
            idx=find(arrayfun(@(x) this.impointDB(x).id==id,1:length(this.impointDB)));
            if length(idx)~=1
                error('Idx must be 1');
            end
        end
        
        %This function will set a flag to show the track name for a points track.  Then all points in the
        %tracklet will show the names
        function callbackShowSkeletonPointTrackletName(this,src,evn,id)
            %first turn on the tracklet name for any points that are
            %showing
            [idList, trackletIndex]=this.findTrackletBySkeletonId(id);
            
            %!!This could fail is id is not an active impoint
            idx=find(arrayfun(@(x) this.impointDB(x).id==id,1:length(this.impointDB)));
            if length(idx)~=1
                error('Idx must be 1');
            else
                this.impointDB(idx).obj.setString(this.trackletDB(trackletIndex).name);
            end
            
            %if the name already exists then remove it
            if any(this.showTrackletNameList_trackletIndex==trackletIndex)
                this.showTrackletNameList_trackletIndex(this.showTrackletNameList_trackletIndex==trackletIndex)=[];
                this.impointDB(idx).obj.setString('');
            else %add it
                this.showTrackletNameList_trackletIndex=[this.showTrackletNameList_trackletIndex; trackletIndex];
            end
        end
        
        
        
        %This is just a callback wrapper for the assign point to tracklet
        function callbackAsignSkeletonPointToTracklet(this,src,evn,id,trackletName)
            switch(nargin)
                case 4
                    trackletName='default';
                case 5
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            this.assignSkeletonPointToTracklet(id,trackletName);
        end
        %This function will show a tracklet for a track
        function assignSkeletonPointToTracklet(this,id,trackletName)
            disp(['assignSkeletonPointToTracklet impoint with id = ' num2str(id)])
            this.trackletUpdate(trackletName,id);
        end
        
        
        
        %This function will show a tracklet for a track
        function showSkeletonPointTracklet(this,src,evn,id)
            
            if isempty(this.dataBlockObj)
                error('This function requires the dataBlockObj to be set');
            end
            
            this.refreshActiveSkeletonVertexListFromImpoints;
            disp(['showSkeletonPointTracklet id = ' num2str(id)])
            
            
            
            idList=this.findTrackletBySkeletonId(id);
            skeletonGetFullPosition=this.skeletonGetFullPositionById(idList);
            
            startStopFrame = inputdlg({'Enter start frame','Enter stop frame'} ,['Show tracklet frame ' num2str([skeletonGetFullPosition(3,1) skeletonGetFullPosition(3,end)])],1,{num2str([skeletonGetFullPosition(3,1)]),num2str([skeletonGetFullPosition(3,end)])},'on' );
            
            startIndex=find(skeletonGetFullPosition(3,:)==str2num(startStopFrame{1}),1,'first');
            stopIndex=find(skeletonGetFullPosition(3,:)==str2num(startStopFrame{2}),1,'first');
            
            showTracklet(this.dataBlockObj,this,skeletonGetFullPosition(:,startIndex:stopIndex),idList(startIndex:stopIndex));
            
        end
        
        %will add a new tracklet if the name does not exist and will add an
        %id if the name already exists
        function  trackletUpdate(this,trackletName,id)
            
            if ~isempty(this.trackletDB)
                isName=arrayfun(@(idx) strcmp(this.trackletDB(idx).name,trackletName),1:length(this.trackletDB));
                foundIdx=find(isName);
                if ~isempty(foundIdx)
                    if ~any(this.trackletDB(foundIdx).idList==id)
                        this.trackletDB(foundIdx).idList=[this.trackletDB(foundIdx).idList id];
                    else
                        %the id is already in the list so skip it
                    end
                    if length(unique(this.trackletDB(foundIdx).idList))~=length(this.trackletDB(foundIdx).idList)
                        error('id list has a duplicate value');
                    end
                else
                    this.trackletDB(end+1).name=trackletName;
                    this.trackletDB(end).idList=id;
                end
                
            else
                this.trackletDB(1).name=trackletName;
                this.trackletDB(1).idList=id;
            end
            
            
        end
        
        %This will return the tracklet or tracklets based on the skeleton id
        %each tracklet will be a vector in a cell array or just a vector
        %for only 1 tracklet
        function  [idList, trackletIndex]=findTrackletBySkeletonId(this,id)
            
            if ~isempty(this.trackletDB)
                trackletIndex=find(arrayfun(@(idx) any(this.trackletDB(idx).idList==id),1:length(this.trackletDB)));
                
                if isscalar(trackletIndex)
                    idList=this.trackletDB(trackletIndex).idList;
                else
                    idList=arrayfun(@(idx) {this.trackletDB(idx).idList},trackletIndex);
                end
            else
                idList=[];
            end
        end
        
        %This will return the tracklet or tracklets based on the skeleton id
        %each tracklet will be a vector in a cell array or just a vector
        %for only 1 tracklet
        function  [idList, trackletIndex]=findTrackletByName(this,trackletName)
            
            if ~isempty(this.trackletDB)
                trackletIndex=find(arrayfun(@(idx) strcmpi(this.trackletDB(idx).name,trackletName),1:length(this.trackletDB)));
                
                if isscalar(trackletIndex)
                    idList=this.trackletDB(trackletIndex).idList;
                else
                    idList=arrayfun(@(idx) {this.trackletDB(idx).idList},trackletIndex);
                end
            else
                idList=[];
            end
        end
        
        %Give a point id this function will determine all the tracklet it is a part of and return all of the points in that tracklet
        %The tracklet collection is specified by the id of a point in the
        %tracklet.
        %If slicesToSearch is not empty then we want to restrict the
        %results to only those points in slicesToSearch.  Further default values must be given and
        %slicePosition will equal slicesToSearch
        %If slicesToSearch is empty then it will search all frames
        %
        %If the given id is empty and slicesToSearch is empty then the
        %return values will be empty.  Otherwise if the given id is empty
        %and the slices to search is not empty then the position valid is
        %false, but it is given the default values.  idList will be -1's.
        %slicePosition will equal slicesToSearch.
        function [pointPosition_rc, pointPositionValid,idList,slicePosition] = getTrackletPosition_rc(this,id,slicesToSearch,replaceIfNotValid_rc)
            
            
            
            if isempty(id)
                if isempty(slicesToSearch)
                    pointPositionValid=[];
                    idList=[];
                    slicePosition=[];
                    
                else
                    pointPosition_rc = repmat(replaceIfNotValid_rc,1,length(slicesToSearch)); %The initial setup
                    pointPositionValid=false(length(slicesToSearch),1);
                    idList=-1*ones(size(pointPositionValid));
                    slicePosition=slicesToSearch;
                end
            else
                if isempty(slicesToSearch)
                    idList=this.findTrackletBySkeletonId(id);
                    skeletonGetFullPosition=this.skeletonGetFullPositionById(idList);
                    
                    pointPositionValid=true(size(skeletonGetFullPosition,2),1);
                    pointPosition_rc=skeletonGetFullPosition(1:2,:);
                    slicePosition=skeletonGetFullPosition(3,:);
                    
                else
                    
                    idListTmp=this.findTrackletBySkeletonId(id);
                    skeletonGetFullPosition=this.skeletonGetFullPositionById(idListTmp);
                    
                    pointPositionValidTmp=true(size(skeletonGetFullPosition,2),1);
                    pointPositionTmp_rc=skeletonGetFullPosition(1:2,:);
                    slicePositionTmp=skeletonGetFullPosition(3,:);
                    
                    %trim the results to only the slices in slicesToSearch
                    slicesToSearchValid=arrayfun(@(x) any(x ==slicePositionTmp),slicesToSearch);
                    slicesToSearchIndexOfPosition=arrayfun(@(x) find(x ==slicePositionTmp),slicesToSearch(slicesToSearchValid));
                    
                    if length(unique(slicePositionTmp))~=length(slicePositionTmp)
                        error('Must handle case of multiple points in a slice');
                    end
                    
                    
                    pointPosition_rc = repmat(replaceIfNotValid_rc,1,length(slicesToSearch)); %The initial setup
                    pointPosition_rc(:,slicesToSearchValid)=pointPositionTmp_rc(:,slicesToSearchIndexOfPosition);
                    pointPositionValid=false(length(slicesToSearch),1);
                    pointPositionValid(slicesToSearchValid)=true;
                    idList=-1*ones(size(pointPositionValid));
                    idList(slicesToSearchValid)=idListTmp(slicesToSearchIndexOfPosition);
                    slicePosition=slicesToSearch;
                    
                    
                end
                
            end
        end
        
        
        %This function returns the points for a tracklet in a set slice.
        %The tracklet is specifed by name not index or point id
        %If it cannot find the track then replaceIfNotValid_rc are returned.
        function [pointPosition_rc, pointPositionValid,id] = getTrackletPositionInSlice_rc(this,trackletName,sliceToSearch,replaceIfNotValid_rc)
            
            pointPosition_rc = repmat(replaceIfNotValid_rc,1,length(sliceToSearch)); %The initial setup
            
            if isempty(trackletName)
                pointPositionValid=false(length(sliceToSearch),1);
                id=[];
            else
                idList=this.findTrackletByName(trackletName);
                if isempty(idList)
                    pointPosition_rc=[];
                    pointPositionValid=[];
                    id=[];
                else
                    skeletonGetFullPosition=this.skeletonGetFullPositionById(idList);
                    skeletonIndexToUse=arrayfun(@(sliceNum) nvl(find(skeletonGetFullPosition(3,:)==sliceNum),-1),sliceToSearch);
                    pointPositionValid=(skeletonIndexToUse~=-1);
                    pointPosition_rc(:,pointPositionValid)=skeletonGetFullPosition(1:2,skeletonIndexToUse(pointPositionValid));
                    id=idList(skeletonIndexToUse(pointPositionValid));
                    
                end
            end
            
            
        end
        
        
        
        %This function finds where the unique id values are in the skeleton
        %database.  It returns the row, column, slice(frame) position.
        function [skeletonGetFullPosition]=skeletonGetFullPositionById(this, idList)
            
            %This function return the
            findPt = @(id) arrayfun(@(idx) nvl(find(this.skeleton(idx).vertex.idList==id),0), 1:length(this.skeleton),'UniformOutput',true)';
            searchResult=cell2mat(arrayfun(@(x) findPt(x),idList,'UniformOutput',false));
            [idxSkeletonList,idxVertexList]=vec2sub(searchResult);
            skeletonGetFullPosition=cell2mat(arrayfun(@(idxSkeleton,idxVertex) [this.skeleton(idxSkeleton).vertex.pointList_rc(:,idxVertex);this.skeleton(idxSkeleton).slice ],idxSkeletonList,idxVertexList,'UniformOutput',false)');
        end
        
        
        %The plot function is also where the skeleton points get copied
        %from the gui to the db
        function plotSkeleton(this)
            
            
            if  strcmp(this.regionType,'spline')  && (length(this.impointDB)>1)
                
                if length(this.axesList)~=1
                    error('Only axesList of 1 is currently supported')
                end
                
                this.refreshActiveSkeletonVertexListFromImpoints; %update the db from the impoint locations
                pointListLim_x=[min(this.skeleton(this.activeSkeleton).vertex.pointList_rc(2,:)); max(this.skeleton(this.activeSkeleton).vertex.pointList_rc(2,:))];
                
                xx=linspace(pointListLim_x(1), pointListLim_x(2),max(round(diff(pointListLim_x))*5,10));
                
                yy=spline(this.skeleton(this.activeSkeleton).vertex.pointList_rc(2,:),this.skeleton(this.activeSkeleton).vertex.pointList_rc(1,:),xx);
                
                
                
                if ~isempty(this.skeleton(this.activeSkeleton).vertex.splineCurve) && ishandle(this.skeleton(this.activeSkeleton).vertex.splineCurve)
                    delete(this.skeleton(this.activeSkeleton).vertex.splineCurve)
                end
                
                set(this.axesList,'NextPlot','add')
                this.skeleton(this.activeSkeleton).vertex.splineCurve=plot(this.axesList,xx,yy,this.color);
                set(this.skeleton(this.activeSkeleton).vertex.splineCurve,'HitTest','off');
                set(this.axesList,'NextPlot','replace')
            elseif  strcmp(this.regionType,'point')  && (length(this.impointDB)>=1)
                this.refreshActiveSkeletonVertexListFromImpoints; %update the db from the impoint locations
            elseif length(this.impointDB)>1
                error(['Unsupported region type of ' this.regionType]);
            else
                %do nothing
            end
        end
        
        function setActiveSlice(this,newActiveSlice)
            %we don't need to do anything if the new and the current active
            %slices are the same
            if this.activeSlice==newActiveSlice
                return;
            else
                this.activeSlice=newActiveSlice;
            end
            
            
            
            %Determine if the slice already exists in memory.  If so then
            %load it up else create a new slice.  Either way tear down
            %existing impoints
            this.deleteAllGraphics;
            %             deleteAllImpoints(this);
            %
            %             if ~isempty(this.skeleton(this.activeSkeleton).vertex.splineCurve) && ishandle(this.skeleton(this.activeSkeleton).vertex.splineCurve)
            %                 delete(this.skeleton(this.activeSkeleton).vertex.splineCurve)
            %             end
            
            this.activeSkeleton=this.findSkeletonIdxFromSliceIdx(this.activeSlice);
            if ~any(length(this.activeSkeleton)==[0 1])
                error('this.activeSkeleton can only be empty or a scalar');
            else
            end
            
            
            %if the skeleton exists then copy it out and setup impoint.
            if ~isempty(this.activeSkeleton)
                this.addAllSkeletonPointsByIndex(this.activeSkeleton);
            else
                this.activeSkeleton=length(this.skeleton)+1;
                this.skeleton(this.activeSkeleton)=this.createEmptySkeleton(this.activeSlice);
            end
            
            
        end
        
        %This function applies a 4x4 matrix transform T to all of the
        %skeleton points.  Right now the z dimension is assumed to be zero.
        %if no skeleton index is supplied then the active index is assumed.
        %If the active skelton is being transformed the graphics are
        %automatically removed and readded but not redrawn.
        %The form of T is T*x where x = [row column slice 1]'
        function transformSkeletonPoints(this, T, index)
            switch nargin
                case 2
                    index=this.activeSkeleton;
                case 3
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            
            %remove the graphics if the index is the same as the active skelton because they will now
            %be out of sync.
            if index==this.activeSkeleton;
                this.deleteAllGraphics;
            else
                %do nothing
            end
            
            
            for cc=1:size(this.skeleton(index).vertex.pointList_rc,2)
                xMod=T*[this.skeleton(index).vertex.pointList_rc(:,cc); index; 1];
                this.skeleton(index).vertex.pointList_rc(:,cc)=xMod(1:2);
            end
            
            if index==this.activeSkeleton;
                for cc=1:size(this.skeleton(index).vertex.pointList_rc,2)
                    this.addSkeletonPoint(this.skeleton(index).vertex.pointList_rc(:,cc),this.skeleton(index).vertex.idList(cc));
                end
                
            else
                
                %do nothing
            end
            
            
        end
        
        %if no skeleton index is given it is assumed to be the active
        %skeleton
        function addAllSkeletonPointsByIndex(this, index)
            switch nargin
                case 1
                    index=this.activeSkeleton;
                case 2
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            for cc=1:size(this.skeleton(index).vertex.pointList_rc,2)
                this.addSkeletonPoint(this.skeleton(index).vertex.pointList_rc(:,cc),this.skeleton(index).vertex.idList(cc));
            end
        end
        
        %This replaces vertex points with new values using their unique
        %number
        function replaceVertexPoints(this,vertexIdList,pointList_rc)
            findPt = @(id) arrayfun(@(idx) nvl(find(this.skeleton(idx).vertex.idList==id),0), 1:length(this.skeleton),'UniformOutput',true)';
            
            searchResult=cell2mat(arrayfun(@(x) findPt(x),vertexIdList,'UniformOutput',false));
            [idxSkeletonList,idxVertexList]=vec2sub(searchResult);
            for ii=1:size(pointList_rc,2)
                this.skeleton(idxSkeletonList(ii)).vertex.pointList_rc(:,idxVertexList(ii))=pointList_rc(:,ii);
            end
            
            
        end
        
        function replaceSkeleton(this,mode,skeletonIndex)
            switch(mode)
                case 'closest'
                    
                    idxSet=setdiff(1:length(this.skeleton),this.activeSkeleton);
                    if isempty(idxSet)
                        error('There are no valid indexes which means you maybe applying a replace to the case where you only have one skeleton');
                    end
                    sliceDistances=arrayfun(@(x) abs(x.slice-this.activeSlice), this.skeleton(idxSet));
                    [~,minIdx]=min(sliceDistances);
                    skeletonIdxToCopy=idxSet(minIdx);
                    
                    saveSlice=this.skeleton(this.activeSkeleton).slice;
                    
                    this.deleteAllGraphics;
                    
                    this.skeleton(this.activeSkeleton)=this.skeleton(skeletonIdxToCopy);
                    this.skeleton(this.activeSkeleton).slice=saveSlice;
                    this.addAllSkeletonPointsByIndex(this.activeSkeleton);
                    
                case 'index'
                    skeletonIdxToCopy=skeletonIndex;
                    
                    saveSlice=this.skeleton(this.activeSkeleton).slice;
                    
                    this.deleteAllGraphics;
                    
                    this.skeleton(this.activeSkeleton)=this.skeleton(skeletonIdxToCopy);
                    this.skeleton(this.activeSkeleton).slice=saveSlice;
                    this.addAllSkeletonPointsByIndex(this.activeSkeleton);
                    
                otherwise
                    error(['replaceSkeleton Unsupported mode of ' mode]);
            end
            
        end
        
        function [controlpt]=generateSplineControlPoints(this)
            controlpt.x= this.skeleton(this.activeSkeleton).vertex.pointList_rc(2,:);
            controlpt.y=this.skeleton(this.activeSkeleton).vertex.pointList_rc(1,:);
        end
        
        %TODO sort by slice
        function [im,xAxis_sec,yAxis_mm,samplingSkeleton]=sample(this,metadata,axial_mm,lateral_mm,frameRate_fps,ureadArgs,imBlock)
            
            imCell={};
            for ii=1:length(this.skeleton)
                if isempty(this.skeleton(ii)) || isempty(this.skeleton(ii).vertex.pointList_rc)
                    continue;
                end
                
                totalLateralSamplePoints=getCaseLateralPixelCount(metadata)*10;
                samplingSkeleton(ii)=this.skeleton(ii);
                controlpt.x= this.skeleton(ii).vertex.pointList_rc(2,:);
                controlpt.y=this.skeleton(ii).vertex.pointList_rc(1,:);
                [samplePoints_rc]=createHypothesisSetSpline(metadata,{controlpt}, ...
                    'totalSamplePoints',totalLateralSamplePoints, ...
                    'datareader',{'uread',ureadArgs}, ...
                    'showGraphics',false);
                
                
                %vi=interpn(1:size(imBlock,1),1:size(imBlock,2),1:size(imBlock,3),imBlock,kron(ones(size(imBlock,3),1),samplePoints_rc(1,:)'),kron(ones(size(imBlock,3),1),samplePoints_rc(2,:)'),kron([1:size(imBlock,3)]', ones(size(samplePoints_rc(2,:)'))));
                if ~isempty(samplePoints_rc)
                    validSamplePoints_rc=samplePoints_rc;
                    vi=interpn(1:size(imBlock,1),1:size(imBlock,2),squeeze(imBlock(:,:,this.skeleton(ii).slice)),samplePoints_rc(1,:),samplePoints_rc(2,:));
                else
                    vi=zeros(totalLateralSamplePoints,1);
                end
                
                imCell{end+1}=vi(:);
                
            end
            im=abs(cell2mat(imCell)).^0.5;
            yAxis_mm=[0 cumsum(sqrt(sum(diff(diag([axial_mm lateral_mm])*validSamplePoints_rc,1,2).^2,1)))];
            xAxis_sec=(0:(size(im,2)-1))/frameRate_fps;
            
            switch(nargout)
                case 0
                    figure; imagesc(xAxis_sec,yAxis_mm,im); colormap(gray(256))
                    xlabel('time (sec)')
                    ylabel('cmm line (mm)');
                    
                    figure; imagesc(im); colormap(gray(256))
                    xlabel('frame index')
                    ylabel('axial (sample)');
                case 1
                case 2
                case 3
                case 4
                otherwise
                    error('Invalid number of output arguments.');
            end
            
        end
        
    end
    
    methods (Access=private)
        
        function skeletonIdx=findSkeletonIdxFromSliceIdx(this,sliceIdx)
            skeletonIdx=find(arrayfun(@(x) x.slice==sliceIdx,this.skeleton));
        end
        
        function deleteAllGraphics(this)
            this.deleteAllImpoints;
            if ~isempty(this.skeleton(this.activeSkeleton).vertex.splineCurve) && ishandle(this.skeleton(this.activeSkeleton).vertex.splineCurve)
                delete(this.skeleton(this.activeSkeleton).vertex.splineCurve)
            end
        end
        function deleteAllImpoints(this)
            for ii=1:length(this.impointDB)
                this.impointDB(ii).obj.delete;
            end
            this.impointDB=struct([]);
            
        end
        
        function redrawSpline(this, roi)
            this.plotSkeleton;
        end
        
        function redrawPoint(this, roi)
            this.plotSkeleton;
        end
        
        
        
        %The vertex id is a unqiue id that identifies every point
        function skeleton=createEmptySkeleton(this,sliceNumber)
            skeleton.slice=sliceNumber;
            skeleton.vertex.splineCurve=[];
            skeleton.vertex.pointList_rc=[];
            skeleton.vertex.idList=[];
        end
    end
    
    methods(Static)
        function position_rcSlice = idListToVertex(this,idList)
            
            findPt = @(id) arrayfun(@(idx) nvl(find(this.skeleton(idx).vertex.idList==id),0), 1:length(this.skeleton),'UniformOutput',true)';
            searchResult=cell2mat(arrayfun(@(x) findPt(x),idList,'UniformOutput',false));
            [idxSkeletonList,idxVertexList]=vec2sub(searchResult);
            position_rcSlice=cell2mat(arrayfun(@(idxSkeleton,idxVertex) [this.skeleton(idxSkeleton).vertex.pointList_rc(:,idxVertex);this.skeleton(idxSkeleton).slice ],idxSkeletonList,idxVertexList,'UniformOutput',false)');
            
        end
    end
    
    
    
    
    
    
end