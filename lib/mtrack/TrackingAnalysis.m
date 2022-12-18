classdef TrackingAnalysis  < handle
    %TrackingAnalysis This class will provide a set of methods to analyze
    %tracking results from a process stream
    %The class will internaly support two types of data representation.
    %the first type is document based normally broken into a frame for each
    %doc.  The second type is a relational type where everything is stored in a
    %block.
    %EXAMPLES:
    %===Loading the data===
    %mtrack: [mstitchData,trackingAnalysis,dataBlockObj]=mstitch('translationTrackRectangle','standardProjectionRectangle');
    %
    %===Filtering the data===
    %exclude crosscorr feature track and tracks whose delta speeds are above 0.5
    %prb1={{'srcNot',{'fpt_crosscorrOversampleFast'}},{'deltaKeep',@(x) sum(x.^2)>0.5}};
    %
    %Use only the crosscorr and tracks with speeds in mm/sec between 1 and
    %50. Note the & and not && sicne it is an array compare
    %prb1={{'src',{'fpt_correlationCorrespondencePyramidFast'}},{'velocityMagKeep_mmPerSec',@(x) x>1 & x<50}};
    %
    % show features for the two frames 150 and 151 along with the
    % constraint
    % trackingAnalysis.showFeature([150 151],false,prb1);
    %
    %===Displaying a video===
    %trackingAnalysis.showFeatureVideo([],false,[]);
    %trackingAnalysis.showFeatureVideo([],false,dMod.vSmooth_mmPerSec);
    
    %     frameOfInterest=36;  %slow
    %     borderTrim_rc = dataBlockObj.findBorder;
    %     borderTrim_rc=borderTrim_rc+10; %pad inwards more;
    %     {{'borderTrim_rc',@(x) borderTrim_rc}}
    %     trackingAnalysis.showFeature([frameOfInterest],false,{{'borderTrim_rc',@(x) borderTrim_rc}});
    %
    %     trackingAnalysis.showFeature([frameOfInterest],false,{{'trackletListLength',@(x) x>2}});
    %
    %     trackingAnalysis.showFeature([frameOfInterest],false);
    %     trackingAnalysis.showFeatureDirection([frameOfInterest],false);
    %     trackingAnalysis.showFeatureLength([frameOfInterest],false);
    %     trackingAnalysis.showFeatureSpeed([frameOfInterest],false);
    %     trackingAnalysis.showHist([frameOfInterest],false)
    %     %trackingAnalysis.showTrackletVideo([18:24],false,{{'trackletListLength',@(x) x>3}});
    %     trackingAnalysis.showTrackletVideo([18:24],false,{{'trackletListLength',@(x) x>2}});
    %     trackingAnalysis.showTrackletVideo([18:24],false)
    %     trackingAnalysis.showHistAngle([frameOfInterest],false)
    %
    %     frameOfInterest=20
    %     trackingAnalysis.showFeatureColorPlot([frameOfInterest],true);
    % runAdaptive=runSetting.featureTrack.useAdaptive;
    % runCluster=runSetting.featureTrack.useCluster;
    % prb1=runSetting.featureTrack.filter.setting;
    %
    % [d]=trackingAnalysis.genTrack([],false,prb1,runCluster,runAdaptive);
    %
    
    
    
    properties  (GetAccess = public, SetAccess = private)
        trialData=[];
        dataBlockObj=[];
        directoryRootName=[];
        nodeDB=[];
        activeProcessStreamIndex=1;
        defaultNameIndex=[];
        filterDebug=[];
    end
    
    methods (Access=public)
        %The constructor requires the trialData as a struct or a file name
        %with full path.  It also would like the dataBlockObj to already be
        %loaded for only performance reasons to prevent having to reload
        %the data block each time which can be very large, but will load it
        %if not given.
        %
        %INPUT
        %trialInformation - this is a required parameter that contains the
        %data for the trial or experiment.
        %
        %dataBlockObj - This is optional, but if not specified it will load
        %the data object using the activeProcessStreamIndex or whichever is
        %the first active process stream entry.
        %
        %activeProcessStreamIndex - the index to use when loading the data.
        %
        %TODO
        %mergeData - If is true then all of the data will be merged into a
        %single vector matrix database.
        function [obj]=TrackingAnalysis(trialInformation,dataBlockObj,activeProcessStreamIndex)
            switch(nargin)
                case 1
                    activeProcessStreamIndex=1;
                case 2
                    activeProcessStreamIndex=1;
                case 3
                    %do nothing
                otherwise
                    error('Invalid number of inputs.');
            end
            obj.activeProcessStreamIndex=activeProcessStreamIndex;
            
            if ischar(trialInformation)
                [obj.trialData]=loadMetadata(trialInformation);
                
            elseif isstruct(trialInformation)
                obj.trialData=trialInformation;
            else
                error(['trialInformation is a unsupported class type of ' class(trialInformation)]);
            end
            
            [obj.directoryRootName]=tCreateDirectoryName(obj.trialData.track.processStream(1).filepath,'createDirectory',false);
            
            if (nargin==1 || (nargin==2 && isempty(dataBlockObj)) || (nargin==3 && isempty(dataBlockObj)))
                
                dataBlockObj=getCollection(obj.trialData,obj.trialData.track.processStream(activeProcessStreamIndex).sourceNode);
                obj.dataBlockObj=dataBlockObj;
            else
                obj.dataBlockObj=dataBlockObj;
            end
            
            
        end
        
        %This function will load a nodes data into the class for analysis
        %override any saved region inforamtion with the region
        %information in the datablock.  This is important to see
        %the effect of changing the region location
        function newDBIndex=loadDataset(this,nodeName)
            findList=find(structFieldStringIsEqual(this.nodeDB,@(x) x.name,nodeName));
            %=find(arrayfun(@(x) strcmp(x.name,nodeName),this.nodeDB));
            
            %first see if the node has been loaded
            if isempty(findList)
                [dataDirectory, dataFiles]=tGetNodeNameDirectory(this.trialData,nodeName,this.activeProcessStreamIndex);
                
                if length(dataFiles)~=1
                    error('Data file list needs to be fixed.')
                end
                if isempty(this.nodeDB)
                    this.nodeDB.name=nodeName;
                    this.nodeDB.dataFileList=dataFiles(1);
                    this.nodeDB.data=load(this.nodeDB.dataFileList{1});
                else
                    this.nodeDB(end+1).name=nodeName;
                    this.nodeDB(end).dataFileList=dataFiles(1);
                    this.nodeDB(end).data=load(this.nodeDB(end).dataFileList{1});
                end
                
                %override any saved region inforamtion with the region
                %information in the datablock.  This is important to see
                %the effect of changing the region location
                this.nodeDB(end).data.region=this.dataBlockObj.regionInformation.region;
                this.nodeDB(end).data.regionMod=this.dataBlockObj.regionInformation.region;
                
                %regionIm=regionprops(this.nodeDB(end).data.regionMod.mask,'ConvexHull');
                %this.nodeDB(end).data.regionMod.prPolygon_rc=flipud(regionIm.ConvexHull');
                %this.nodeDB(end).data.regionMod.prPolygon_rc=flipud(regionIm{1}');
                regionIm=bwboundaries(this.nodeDB(end).data.regionMod.mask);
                this.nodeDB(end).data.regionMod.prPolygon_rc=regionIm{1}';
                if false
                    %%
                    figure; imagesc(this.nodeDB(end).data.regionMod.mask)
                    hold on
                    plot(this.nodeDB(end).data.regionMod.prPolygon_rc(2,:),this.nodeDB(end).data.regionMod.prPolygon_rc(1,:),'g.')
                end
                
                newDBIndex=length(this.nodeDB);
            else
                if length(findList)~=1
                    error('nodeNames need to be unique');
                else
                    newDBIndex=findList(1);
                end
            end
            
        end
        
        %This will set the default node for analysis to the name and load
        %the data associated with the file.
        function setDefaultNodeName(this,defaultName)
            
            defaultNameIndex=find(structFieldStringIsEqual(this.nodeDB,@(x) x.name,defaultName));
            
            if isempty(defaultNameIndex)
                %load the dataset
                this.defaultNameIndex=this.loadDataset(defaultName);
            elseif length(defaultNameIndex)==1
                this.defaultNameIndex=defaultNameIndex;
            else
                error('There should only be 1 default value.  The data might be corrupt.');
            end
        end
        
        %This method will print a text report of the information
        function showReport(this)
            fprintf(1,'Object %s includes the data files: \n',this.nodeDB.name);
            for ii=1:length(this.nodeDB.dataFileList)
                fprintf(1,'%d. %s\n',ii,this.nodeDB.dataFileList{ii});
            end
            fprintf(1,'There are %d frames of size (%d,%d)\n',this.dataBlockObj.size(3),this.dataBlockObj.size(1),this.dataBlockObj.size(2));
            
            length(this.nodeDB.data.sourceTrackList(1).pt_rc)
            
        end
        
        function showFeature(this,frameIndex,useAllArea,filterConditions)
            switch(nargin)
                case 2
                    useAllArea=true;
                    filterConditions=[];
                case 3
                    filterConditions=[];
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]= getPlotMarkers(length(sourceNameList));
            
            if ~useAllArea
                regionInfo=d.regionMod;
            else
                regionInfo=[];
            end
            [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,regionInfo,filterConditions,sourceNameList,d.metainformationTrackList);
            for ii=1:length(sourceFrameTrackList)
                sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
            end
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            
            %% Display the results
            figure; imagesc(im(:,:,1)); colormap(gray(256));
            hold on
            plot(d.regionMod.prPolygon_rc(2,:),d.regionMod.prPolygon_rc(1,:),'y')
            legendEntry=cell(length(sourceList),1);
            for ii=1:length(frameIndex)
                for ss=1:length(sourceList)
                    sourceIndexes=(sourceList(ss)==sourceFrameTrackList(ii).pt_rc(1,:));
                    sourcePt_rc=trackFrameList(ii).pt_rc(:,sourceIndexes);
                    sourcePtDelta_rc=trackFrameList(ii).ptDelta_rc(:,sourceIndexes);
                    phs=quiver(sourcePt_rc(2,:),sourcePt_rc(1,:),sourcePtDelta_rc(2,:),sourcePtDelta_rc(1,:),0,sourcePlotFormatList{ss,ii});
                    if isempty(legendEntry{ss}) &&  ~isempty(phs)
                        legendEntry{ss}=phs;
                    end
                end
            end
            legend([{'region'},sourceNameList(sourceList)],'interpreter','none')
            title([this.trialData.sourceMetaFilename '. Feature points for frames ' num2str(reshape(frameIndex,1,[]))],'interpreter','none');
            
            
        end
        
        %This method will get all of the features for a set of frames and
        %return them as column arrays
        %OUTPUT
        %featurePtList_rc - a column vector list of the location of feature points
        %featurePtDeltaList_rc - a column vector list of the displacements
        %for the featurePtList_rc going from the current frame  to the next
        %frame.
        function [featurePtList_rc, featurePtDeltaList_rc] = getFeature(this,frameIndex,useAllArea,filterConditions)
            switch(nargin)
                case 2
                    useAllArea=true;
                    filterConditions=[];
                case 3
                    filterConditions=[];
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]= getPlotMarkers(length(sourceNameList));
            
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            
            %% Display the results
            featurePtList_rc = zeros(2,0);
            featurePtDeltaList_rc = zeros(2,0);
            for ii=1:length(frameIndex)
                for ss=1:length(sourceList)
                    sourceIndexes=(sourceList(ss)==sourceFrameTrackList(ii).pt_rc(1,:));
                    featurePtList_rc =[featurePtList_rc trackFrameList(ii).pt_rc(:,sourceIndexes)];
                    featurePtDeltaList_rc = [featurePtDeltaList_rc trackFrameList(ii).ptDelta_rc(:,sourceIndexes)];
                end
            end
            
        end
        
        %By default this function will overload the region information in
        %the node file (region and regionMod) with the region information
        %in the dataObject.  this allows for updates and experiments with the region information
        %INPUT
        %'rowDisplayWidth' It is the width of the row which is useful when
        %displaying rf data.  It has a default of 1.  If specified it
        %should be odd.
        %meanPt_rc - a vector for each frame that shows the mean value
        function showFeatureColorPlot(this,frameIndex,useAllArea,filterConditions,varargin)
            %             switch(nargin)
            %                 case 2
            %                     useAllArea=true;
            %                     filterConditions=[];
            %                 case 3
            %                     filterConditions=[];
            %                 case 4
            %                     %do nothing
            %                 otherwise
            %                     error('Invalid number of input arguments.');
            %             end
            
            p = inputParser;   % Create an instance of the class.
            p.addRequired('frameIndex',@(x) isnumeric(x) || isempty(x));
            p.addOptional('useAllArea',true,@(x) islogical(x) || isempty(x));
            p.addOptional('filterConditions',[],@(x) iscell(x) || isempty(x));
            p.addParamValue('rowDisplayWidth',1,@(x) x>=1);
            p.addParamValue('figureHandle',[],@(x) ishandle(x));
            p.addParamValue('meanPt_rc',[] ,@(x) isnumeric(x) || isempty(x));
            p.addParamValue('stdPtDelta_rc',[] ,@(x) isnumeric(x) && (size(x,1)==2) || isempty(x));
            
            p.parse(frameIndex,useAllArea,filterConditions,varargin{:});
            
            frameIndex=p.Results.frameIndex;
            useAllArea=p.Results.useAllArea;
            filterConditions=p.Results.filterConditions;
            rowDisplayWidth=p.Results.rowDisplayWidth;
            figureHandle=p.Results.figureHandle;
            meanPt_rc=p.Results.meanPt_rc;
            stdPtDelta_rc=p.Results.stdPtDelta_rc;
            
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            d=this.nodeDB(this.defaultNameIndex).data;
            
            if isfield(d,'regionMod')
                d.regionMod=this.dataBlockObj.regionInformation.region;
            else
                %do nothing
            end
            
            if isfield(d,'region')
                d.region=this.dataBlockObj.regionInformation.region;
            else
                %do nothing
            end
            
            
            
            
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]=  getPlotMarkers(length(sourceNameList));
            
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            ii=1;
            %use round to map to closest point
            cleanPt_rc=clipVector(round(trackFrameList(ii).pt_rc),[1;1],size(im)');
            
            indexMap=sub2ind([size(im,1) size(im,2)],cleanPt_rc(1,:),cleanPt_rc(2,:));
            %This will be a direction mask and will get the index for each
            %point to look for duplicates
            %This is based on the the metric measure for angle
            binranges=unique(indexMap);
            %binIndex is what we care about it because it maps the bin
            %number each of the indexes sorted into.
            [bincounts,binIndex ] = histc(indexMap,binranges );
            
            if false
                %%
                figure;
                bar(binranges,bincounts,'histc')
                %bar(
            end
            
            multipleIndex = (bincounts > 1); %This maps to the bins that have duplicates
            singleIndex=~multipleIndex; %this is reference to the
            indexOfMultipleMatches = find(ismember(binIndex, find(multipleIndex)));
            
            %What we have here are the index values of the .pt_rc column
            %number and we can
            singleHitIndex=indexMap(binIndex(singleIndex));
            
            
            directionMask_deg=nan(size(im,1),size(im,2));
            speedMask_mmPerSec=nan(size(im,1),size(im,2));
            
            scale_mm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            ptDelta_rc_mm=scale_mm*trackFrameList(ii).ptDelta_rc;
            ptDeltaDirection_rc_deg=180/pi*atan2(ptDelta_rc_mm(1,:),ptDelta_rc_mm(2,:));
            fps=this.dataBlockObj.getUnitsValue('frameRate','framePerSec');
            ptDeltaSpeed_rc_mmPerSec= sign(ptDelta_rc_mm(2,:)).*sqrt(sum(ptDelta_rc_mm.^2,1))*fps;
            
            
            
            %First map the single hits
            directionMask_deg(singleHitIndex) = ...
                ptDeltaDirection_rc_deg(binIndex(singleIndex));
            
            
            %First map the single hits
            speedMask_mmPerSec(singleHitIndex) = ...
                ptDeltaSpeed_rc_mmPerSec(binIndex(singleIndex));
            
            
            %now average the multiple bins
            binsWithCountLargerThanOne=unique(binIndex(indexOfMultipleMatches));
            dupIndexList=arrayfun(@(bin) find((binIndex==bin)), binsWithCountLargerThanOne,'UniformOutput',false);
            averagedDupValue_deg=cellfun(@(dupIndex) mean(ptDeltaDirection_rc_deg(dupIndex)), dupIndexList);
            averagedDupValue_mmPerSec=cellfun(@(dupIndex) mean(ptDeltaSpeed_rc_mmPerSec(dupIndex)), dupIndexList);
            
            directionMask_deg(binranges(binsWithCountLargerThanOne)    ) = ...
                averagedDupValue_deg;
            
            speedMask_mmPerSec(binranges(binsWithCountLargerThanOne)    ) = ...
                averagedDupValue_mmPerSec;
            
            
            imG=mat2gray(im(:,:,1),[min(min(im(:,:,1))) max(max(im(:,:,1)))]);
            [imGI, map] = gray2ind(imG,256);
            imRGB = ind2rgb(imGI, map);
            
            
            directionMaskShow_deg=directionMask_deg;
            speedMaskShow_mmPerSec=speedMask_mmPerSec;
            directionMaskSize=size(directionMask_deg);
            [replaceRow,replaceColumn]=ind2sub(directionMaskSize, find(~isnan(directionMask_deg)));
            
            if rowDisplayWidth==1
                %Skip the
            else
                rowDisplayHalfWidth=(rowDisplayWidth-1)/2;
                directionMaskShowSnapShot_deg=directionMaskShow_deg;
                speedMaskShowSnapShot_mmPerSec=speedMaskShow_mmPerSec;
                for ii=1:length(replaceRow)
                    for rowPositionForMark=max(1,replaceRow(ii)-rowDisplayHalfWidth):min(directionMaskSize(1),replaceRow(ii)+rowDisplayHalfWidth)
                        directionMaskShow_deg(rowPositionForMark,replaceColumn(ii))=directionMaskShowSnapShot_deg(replaceRow(ii),replaceColumn(ii));
                        speedMaskShow_mmPerSec(rowPositionForMark,replaceColumn(ii))=speedMaskShowSnapShot_mmPerSec(replaceRow(ii),replaceColumn(ii));
                    end
                end
            end
            
            if ~all(size(directionMaskShow_deg)==size(directionMask_deg))
                error('directionMaskShow_deg changed size during the creation.  This should be the same size as directionMask_deg');
            else
                if ~all(size(speedMaskShow_mmPerSec)==size(speedMask_mmPerSec))
                    error('speedMaskShow_mmPerSec changed size during the creation.  This should be the same size as speedMask_mmPerSec');
                else
                    %do nothing
                end
            end
            
            
            imAlphaData=zeros(size(directionMaskShow_deg));
            imAlphaData(~isnan(directionMaskShow_deg))=1;
            
            %             jetColorMap=jet(128);
            %             angleColorMap=[flipud(jetColorMap); jetColorMap(1,:); jetColorMap];
            angleColorMap=hsv(256);
            
            axisImRow_mm=(0:(size(im,1)-1))*scale_mm(1,1);
            axisImCol_mm=(0:(size(im,2)-1))*scale_mm(2,2);
            
            if isempty(figureHandle)
                figure;
            else
                figure(figureHandle);
            end
            subplot(3,2,[1 3])
            him2=imagesc(axisImCol_mm,axisImRow_mm,directionMaskShow_deg,[-180 180]);
            caxis(get(him2,'Parent'),[-180 180]);
            colormap(angleColorMap);
            hold on;
            him=image(axisImCol_mm,axisImRow_mm,imRGB);
            %this will cover any points, but the order is important to get
            %the color map to map to the point range
            this.dataBlockObj.regionInformation.plot();
            set(him,'AlphaData',~imAlphaData);
            ch=colorbar('peer',get(him,'Parent'),'YTick',[-180:45:180]);
            ylabel(ch,'$\theta\,^{\circ}$','Interpreter','LaTex','Rotation',0,'FontSize',20);
            xlabel('mm');
            ylabel('mm');
            
            if ~isempty(meanPt_rc)
                plot(squeeze(meanPt_rc(2,frameIndex,:))*scale_mm(2,2),squeeze(meanPt_rc(1,frameIndex,:))*scale_mm(1,1),'yx','LineWidth',4);
            end
            
            hold off;
            
            
            subplot(3,2,[2 4])
            maxSpeedToShow_mmPerSec=60;
            speedMaskShow_mmPerSec(speedMaskShow_mmPerSec>maxSpeedToShow_mmPerSec)=maxSpeedToShow_mmPerSec;
            him2=imagesc(axisImCol_mm,axisImRow_mm,speedMaskShow_mmPerSec,[-maxSpeedToShow_mmPerSec maxSpeedToShow_mmPerSec]);
            caxis(get(him2,'Parent'),[-maxSpeedToShow_mmPerSec maxSpeedToShow_mmPerSec]);
            %colormap('jet');
            hold on;
            this.dataBlockObj.regionInformation.plot();
            
            him=image(axisImCol_mm,axisImRow_mm,imRGB);
            %this will cover any points, but the order is important to get
            %the color map to map to the point range
            this.dataBlockObj.regionInformation.plot();
            set(him,'AlphaData',~imAlphaData);
            ch=colorbar('peer',get(him,'Parent'));
            ylabel(ch,'$\frac{mm}{sec}$','Interpreter','LaTex','Rotation',0,'FontSize',20);
            xlabel('mm');
            ylabel('mm');
            hold off;
            
            
        end
        
        function [featureCountPerSource,sourceNameList]=countFeatures(this)
            d=this.nodeDB(this.defaultNameIndex).data;
            
            sourceMasterList=(1:max(arrayfun(@(s) max(s.pt_rc(1,:)), d.sourceTrackList)));
            sourceMasterEdgeList=(1:(max(sourceMasterList)+1));
            featureCountPerSource=zeros(numel(sourceMasterList),numel(d.sourceTrackList));
            for ff=1:size(featureCountPerSource,2)
                featureCountPerSource(:,ff)=reshape(histcounts(d.sourceTrackList(ff).pt_rc(1,:),sourceMasterEdgeList),[],1);
            end
            
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            
        end
        
        
        function showFeatureLength(this,frameIndex,useAllArea,filterConditions)
            switch(nargin)
                case 2
                    useAllArea=true;
                    filterConditions=[];
                case 3
                    filterConditions=[];
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            %[sourcePlotFormatList,sourceLinePlotFormatList]= this.loadSourceList(frameIndex);
            
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            
            if isfield(d,'regionMod')
                d.regionMod=this.dataBlockObj.regionInformation.region;
            else
                %do nothing
            end
            
            if isfield(d,'region')
                d.region=this.dataBlockObj.regionInformation.region;
            else
                %do nothing
            end
            
            
            
            
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]=  getPlotMarkers(length(sourceNameList));
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            ii=1;
            indexMap=sub2ind([size(im,1) size(im,2)],fix(trackFrameList(ii).pt_rc(1,:)),fix(trackFrameList(ii).pt_rc(2,:)));
            %This will be a direction mask and will get the index for each
            %point to look for duplicates
            %This is based on the the metric measure for angle
            binranges=unique(indexMap);
            %binIndex is what we care about it because it maps the bin
            %number each of the indexes sorted into.
            [bincounts,binIndex ] = histc(indexMap,binranges );
            
            if false
                %%
                figure;
                bar(binranges,bincounts,'histc')
                %bar(
            end
            
            multipleIndex = (bincounts > 1); %This maps to the bins that have duplicates
            singleIndex=~multipleIndex; %this is reference to the
            indexOfMultipleMatches = find(ismember(binIndex, find(multipleIndex)));
            
            %What we have here are the index values of the .pt_rc column
            %number and we can
            singleHitIndex=indexMap(binIndex(singleIndex));
            
            
            lengthMask_mm=nan(size(im,1),size(im,2));
            
            scale_mm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            ptDelta_rc_mm=scale_mm*trackFrameList(ii).ptDelta_rc;
            ptDeltaLength_rc= sqrt(sum(ptDelta_rc_mm.^2,1));
            
            %First map the single hits
            lengthMask_mm(singleHitIndex) = ...
                ptDeltaLength_rc(binIndex(singleIndex));
            
            
            %now average the multiple bins
            binsWithCountLargerThanOne=unique(binIndex(indexOfMultipleMatches));
            dupIndexList=arrayfun(@(bin) find((binIndex==bin)), binsWithCountLargerThanOne,'UniformOutput',false);
            averagedDupValue=cellfun(@(dupIndex) mean(ptDeltaLength_rc(dupIndex)), dupIndexList);
            
            lengthMask_mm(binranges(binsWithCountLargerThanOne)    ) = ...
                averagedDupValue;
            
            
            imG=mat2gray(im(:,:,1),[min(min(im(:,:,1))) max(max(im(:,:,1)))]);
            [imGI, map] = gray2ind(imG,256);
            imRGB = ind2rgb(imGI, map);
            
            %figure('renderer','opengl');
            figure; image(imRGB);
            
            lengthMaskShow_mm=lengthMask_mm;
            [replaceRow,replaceColumn]=ind2sub(size(lengthMask_mm), find(~isnan(lengthMask_mm)));
            for ii=1:length(replaceRow)
                for offsetBox=-5:5
                    lengthMaskShow_mm(replaceRow(ii)+offsetBox,replaceColumn(ii))=lengthMaskShow_mm(replaceRow(ii),replaceColumn(ii));
                end
            end
            
            hold on; him=imagesc(lengthMaskShow_mm);
            
            imAlphaData=zeros(size(lengthMaskShow_mm));
            imAlphaData(~isnan(lengthMaskShow_mm))=1;
            
            set(him,'AlphaData',imAlphaData);
            
            
            figure;
            imagesc(lengthMaskShow_mm)
            ch=colorbar();
            ylabel(ch,'mm','Rotation',0);
            %caxis([-180 180]);
            
        end
        
        
        
        function showFeatureSpeed(this,frameIndex,useAllArea,filterConditions)
            switch(nargin)
                case 2
                    useAllArea=true;
                    filterConditions=[];
                case 3
                    filterConditions=[];
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            %[sourcePlotFormatList,sourceLinePlotFormatList]= this.loadSourceList(frameIndex);
            
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            
            if isfield(d,'regionMod')
                d.regionMod=this.dataBlockObj.regionInformation.region;
            else
                %do nothing
            end
            
            if isfield(d,'region')
                d.region=this.dataBlockObj.regionInformation.region;
            else
                %do nothing
            end
            
            
            
            
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]=  getPlotMarkers(length(sourceNameList));
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            ii=1;
            indexMap=sub2ind([size(im,1) size(im,2)],fix(trackFrameList(ii).pt_rc(1,:)),fix(trackFrameList(ii).pt_rc(2,:)));
            %This will be a direction mask and will get the index for each
            %point to look for duplicates
            %This is based on the the metric measure for angle
            binranges=unique(indexMap);
            %binIndex is what we care about it because it maps the bin
            %number each of the indexes sorted into.
            [bincounts,binIndex ] = histc(indexMap,binranges );
            
            if false
                %%
                figure;
                bar(binranges,bincounts,'histc')
                %bar(
            end
            
            multipleIndex = (bincounts > 1); %This maps to the bins that have duplicates
            singleIndex=~multipleIndex; %this is reference to the
            indexOfMultipleMatches = find(ismember(binIndex, find(multipleIndex)));
            
            %What we have here are the index values of the .pt_rc column
            %number and we can
            singleHitIndex=indexMap(binIndex(singleIndex));
            
            
            lengthMask_mm=nan(size(im,1),size(im,2));
            
            scale_mm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            ptDelta_rc_mm=scale_mm*trackFrameList(ii).ptDelta_rc;
            ptDeltaLength_rc= sqrt(sum(ptDelta_rc_mm.^2,1));
            
            %First map the single hits
            lengthMask_mm(singleHitIndex) = ...
                ptDeltaLength_rc(binIndex(singleIndex));
            
            
            %now average the multiple bins
            binsWithCountLargerThanOne=unique(binIndex(indexOfMultipleMatches));
            dupIndexList=arrayfun(@(bin) find((binIndex==bin)), binsWithCountLargerThanOne,'UniformOutput',false);
            averagedDupValue=cellfun(@(dupIndex) mean(ptDeltaLength_rc(dupIndex)), dupIndexList);
            
            lengthMask_mm(binranges(binsWithCountLargerThanOne)    ) = ...
                averagedDupValue;
            
            
            imG=mat2gray(im(:,:,1),[min(min(im(:,:,1))) max(max(im(:,:,1)))]);
            [imGI, map] = gray2ind(imG,256);
            imRGB = ind2rgb(imGI, map);
            
            %figure('renderer','opengl');
            figure; image(imRGB);
            
            lengthMaskShow_mm=lengthMask_mm;
            [replaceRow,replaceColumn]=ind2sub(size(lengthMask_mm), find(~isnan(lengthMask_mm)));
            for ii=1:length(replaceRow)
                for offsetBox=-5:5
                    lengthMaskShow_mm(replaceRow(ii)+offsetBox,replaceColumn(ii))=lengthMaskShow_mm(replaceRow(ii),replaceColumn(ii));
                end
            end
            
            fps=this.dataBlockObj.getUnitsValue('frameRate','framePerSec');
            lengthMaskShow_mmPerSec=lengthMaskShow_mm*fps;
            lengthMaskShow_mmPerSec(lengthMaskShow_mmPerSec>60)=60;
            hold on; him=imagesc(lengthMaskShow_mmPerSec);
            
            
            imAlphaData=zeros(size(lengthMaskShow_mmPerSec));
            imAlphaData(~isnan(lengthMaskShow_mmPerSec))=1;
            
            set(him,'AlphaData',imAlphaData);
            
            
            figure;
            imagesc(lengthMaskShow_mmPerSec)
            ch=colorbar();
            ylabel(ch,'  mm/sec','Rotation',0);
            %caxis([-180 180]);
            
        end
        function [featureBlock, featureBlockLabels,  multifeatureBlockCollection, multifeatureBlockCollectionLabels]=createFeatureBlock(this,frameIndex,useAllArea,filterConditions)
            switch(nargin)
                case 2
                    useAllArea=true;
                    filterConditions=[];
                case 3
                    filterConditions=[];
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            % [sourcePlotFormatList,sourceLinePlotFormatList]= this.loadSourceList(frameIndex);
            
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]=  getPlotMarkers(length(sourceNameList));
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            %% Display the results
            featureBlock=[];
            for ii=1:length(frameIndex)
                featureSubBlock=[trackFrameList(ii).pt_rc; trackFrameList(ii).ptDelta_rc; frameIndex(ii)*ones(size( sourceFrameTrackList(ii).pt_rc,2)); sourceFrameTrackList(ii).pt_rc(1,:) ];
                featureBlock=[featureBlock featureSubBlock];
            end
            featureBlockLabels={'pt_rc','ptDelta_rc','frameNumber','sourceId'};
            
            
            if isfield(d,'multitrackCollection')
                [ multifeatureBlockCollection, multifeatureBlockCollectionLabels] = createMultitrackFeatureBlock( d.multitrackCollection );
                
            end
            
            
        end
        
        
        function showFeatureVideo(this,frameIndex,useAllArea,filterConditions)
            switch(nargin)
                case 1
                    frameIndex=[];
                    useAllArea=true;
                    filterConditions=[];
                case 2
                    useAllArea=true;
                    filterConditions=[];
                case 3
                    filterConditions=[];
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            if isempty(frameIndex)
                frameIndex=(1:(this.dataBlockObj.size(3)-2));
            else
                %do nothing
            end
            
            %if length(frameIndex)==1
            %[sourcePlotFormatList,sourceLinePlotFormatList]= this.loadSourceList(frameIndex);
            
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]=  getPlotMarkers(length(sourceNameList));
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            %% Display the results
            f1=figure;
            for ii=1:length(frameIndex)
                figure(f1);
                imagesc(im(:,:,ii)); colormap(gray(256));
                hold on
                plot(d.regionMod.prPolygon_rc(2,:),d.regionMod.prPolygon_rc(1,:),'y')
                legendEntry=[];
                
                for ss=1:length(sourceList)
                    sourceIndexes=(sourceList(ss)==sourceFrameTrackList(ii).pt_rc(1,:));
                    sourcePt_rc=trackFrameList(ii).pt_rc(:,sourceIndexes);
                    sourcePtDelta_rc=trackFrameList(ii).ptDelta_rc(:,sourceIndexes);
                    phs=plot(sourcePt_rc(2,:),sourcePt_rc(1,:),sourcePlotFormatList{ss});
                    
                    displayArgs=sourceLinePlotFormatList{ss};
                    ph=colvecfun(@(ps,pd) plot([ps(2) (ps(2)+ pd(2))],[ps(1) (ps(1)+ pd(1))],displayArgs{:}), ...
                        sourcePt_rc,sourcePtDelta_rc);
                end
                hold off
                title([this.trialData.sourceMetaFilename '. Feature points for frame ' num2str(ii)],'interpreter','none');
                pause(.1);
            end
            % legend(legendEntry,sourceNameList,'interpreter','none')
            
            
        end
        
        
        function showTrackletVideo(this,frameIndex,useAllArea,filterConditions,showMovie)
            switch(nargin)
                case 1
                    frameIndex=[];
                    useAllArea=true;
                    filterConditions=[];
                    showMovie=false;
                case 2
                    useAllArea=true;
                    filterConditions=[];
                    showMovie=false;
                case 3
                    filterConditions=[];
                    showMovie=false;
                case 4
                    showMovie=false;
                case 5
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            if isempty(frameIndex)
                frameIndex=(1:(this.dataBlockObj.size(3)-2));
            else
                %do nothing
            end
            
            %if length(frameIndex)==1
            %[sourcePlotFormatList,sourceLinePlotFormatList]= this.loadSourceList(frameIndex);
            
            
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]=  getPlotMarkers(length(sourceNameList));
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                    sourceFrameTrackList(ii).ptDelta_rc(~filterInfo(ii).validIndexesFromOriginal)=[];
                    sourceFrameTrackList(ii).ptMetric(~filterInfo(ii).validIndexesFromOriginal)=[];
                    
                    sourceFrameTrackList(ii).trackletListId(~filterInfo(ii).validIndexesFromOriginal)=[];
                    sourceFrameTrackList(ii).trackletListPosition(~filterInfo(ii).validIndexesFromOriginal)=[];
                    sourceFrameTrackList(ii).trackletListLength(~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            %% Display the results
            trackletDb=trackletExtract(trackFrameList,sourceFrameTrackList);
            f1=figure;
            trackletColorList=['rgyb'];
            for ss=1:length(sourceNameList)
                disp([sourceNameList{ss} '=' trackletColorList(ss)]);
            end
            
            
            if showMovie
                iiStart=1;
            else
                iiStart=length(frameIndex);
            end
            
            for ii=iiStart:length(frameIndex)
                figure(f1);
                imagesc(im(:,:,ii)); colormap(gray(256));
                hold on
                plot(d.regionMod.prPolygon_rc(2,:),d.regionMod.prPolygon_rc(1,:),'y')
                legendEntry=[];
                
                
                for ss=1:length(trackletDb)
                    if ii~=length(frameIndex)
                        plot(trackletDb{ss}(4,:),trackletDb{ss}(3,:),['-' trackletColorList(trackletDb{ss}(5,1))])
                    else
                        plot(trackletDb{ss}(4,:),trackletDb{ss}(3,:),['-o' trackletColorList(trackletDb{ss}(5,1))])
                    end
                    if ii<=size(trackletDb{ss},2)
                        %   plot(trackletDb{ss}(4,ii),trackletDb{ss}(3,ii),['gx'])
                    else
                        %do nothing
                    end
                end
                hold off
                title([this.trialData.sourceMetaFilename '. Feature points for frame ' num2str(ii)],'interpreter','none');
                pause(.1);
            end
            % legend(legendEntry,sourceNameList,'interpreter','none')
            
            
        end
        
        %If multiple frames are passed in then the legend is just the
        %colors for each frame, if a single frame then the legend is the
        %types of tracking algorithms
        function showHist(this,frameIndex,useAllArea,filterConditions)
            switch(nargin)
                case 2
                    useAllArea=true;
                    filterConditions=[];
                case 3
                    filterConditions=[];
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            % [sourcePlotFormatList,sourceLinePlotFormatList]= this.loadSourceList(frameIndex);
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]=  getPlotMarkers(length(sourceNameList));
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            %% Display the results
            figure;
            legendEntry=cell(length(sourceList),length(frameIndex));
            for ii=1:length(frameIndex)
                for ss=1:length(sourceList)
                    sourceIndexes=(sourceList(ss)==sourceFrameTrackList(ii).pt_rc(1,:));
                    sourcePtDelta_rc=trackFrameList(ii).ptDelta_rc(:,sourceIndexes);
                    phs=plot(this.dataBlockObj.getUnitsValue('lateral','mm')*sourcePtDelta_rc(2,:),this.dataBlockObj.getUnitsValue('axial','mm')*sourcePtDelta_rc(1,:),sourcePlotFormatList{ss,ii});
                    hold on
                    %if nothing was plotted then don't create a legend
                    %entry
                    if isempty(legendEntry{ss,ii}) &&  ~isempty(phs)
                        legendEntry{ss,ii}=double(phs);
                    end
                    displayArgs=sourceLinePlotFormatList{ss,ii};
                end
            end
            xlabel('lateral(mm)');
            ylabel('axial(mm)');
            if length(frameIndex)==1
                
                legend(cellfun(@(x) double(x),legendEntry(:,1)),sourceNameList,'interpreter','none')
            elseif length(frameIndex)>1
                legend(cellfun(@(x) double(x),legendEntry(:,1)),arrayfun(@(frameNum) ['Frame ' num2str(frameNum)],frameIndex,'UniformOutput',false),'interpreter','none')
            else
                error('This should never occur');
            end
            title([this.trialData.sourceMetaFilename '. Feature points for frames ' num2str(reshape(frameIndex,1,[]))],'interpreter','none');
            
        end
        
        %When displaying the angle/magnitude it is using the mm measurement
        %not pixel
        function showHistAngle(this,frameIndex,useAllArea,filterConditions)
            switch(nargin)
                case 2
                    useAllArea=true;
                    filterConditions=[];
                case 3
                    filterConditions=[];
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            %            [sourcePlotFormatList,sourceLinePlotFormatList]= this.loadSourceList(frameIndex);
            
            im=this.dataBlockObj.getSlice(frameIndex);
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            
            trackFrameList=d.trackList(frameIndex);
            sourceFrameTrackList=d.sourceTrackList(frameIndex);
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            [sourcePlotFormatList,sourceLinePlotFormatList]=  getPlotMarkers(length(sourceNameList));
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,d.regionMod,filterConditions,sourceNameList,d.metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                end
            else
                %do nothing
            end
            
            
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList; sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            %% Display the results
            
            scale_mm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            
            figure;
            legendEntry=[];
            for ii=1:length(frameIndex)
                for ss=1:length(sourceList)
                    sourceIndexes=(sourceList(ss)==sourceFrameTrackList(ii).pt_rc(1,:));
                    sourcePtDelta_rc=scale_mm*trackFrameList(ii).ptDelta_rc(:,sourceIndexes);
                    sourcePtDeltaComplex_xy=complex(sourcePtDelta_rc(2,:),sourcePtDelta_rc(1,:));
                    phs=plot(180/pi*angle(sourcePtDeltaComplex_xy),abs(sourcePtDeltaComplex_xy),sourcePlotFormatList{ss,ii});
                    xlabel('angle(deg)')
                    ylabel('magnitude (mm)')
                    hold on
                    if ii==1
                        legendEntry(ss)=phs;
                    end
                    displayArgs=sourceLinePlotFormatList{ss,ii};
                end
            end
            legend(legendEntry,sourceNameList,'interpreter','none')
            title([this.trialData.sourceMetaFilename '. Feature points for frames ' num2str(reshape(frameIndex,1,[]))],'interpreter','none');
            
            
            ptDelta_rc=trackFrameList(ii).ptDelta_rc;
            ptDelta_mm=scale_mm*ptDelta_rc;
            angleMeasure_deg=180/pi*atan2(ptDelta_mm(1,:),ptDelta_mm(2,:));
            
            angleBinranges_deg=linspace(-180,180,361);
            angleBincounts = histc(angleMeasure_deg,angleBinranges_deg);
            
            magMeasure_mm=sqrt(sum(ptDelta_mm.^2,1));
            magBinranges_mm=linspace(0,5,400);
            magBincounts = histc(magMeasure_mm,magBinranges_mm);
            
            
            
            figure;
            subplot(2,2,1)
            bar(angleBinranges_deg,angleBincounts,'histc')
            xlabel('angle(deg)')
            ylabel('count')
            title('Histogram');
            
            subplot(2,2,2)
            plot(angleBinranges_deg,cumsum(angleBincounts)/sum(angleBincounts));
            xlabel('angle(deg)')
            ylabel('probability')
            title('CDF');
            
            
            subplot(2,2,3)
            bar(magBinranges_mm,magBincounts,'histc')
            xlabel('magnitude (mm)')
            ylabel('count')
            
            subplot(2,2,4)
            plot(magBinranges_mm,cumsum(magBincounts)/sum(magBincounts));
            xlabel('magnitude (mm)')
            ylabel('probability')
            
            %             mean(scale_mm*ptDelta_rc,2)
            %             ptDeltaFilter_rc=ptDelta_rc(:,angleMeasure_deg>90 | angleMeasure_deg<-90);
            %
            %             mean(scale_mm*ptDeltaFilter_rc,2)
            
        end
        
        %%
        %This function will generate a track for a region of interest
        %assuming rigid motion.  This is done using the following steps
        %1. Perform filtered track on the forward track
        %2. Cluster the output of the forward track if desired if desired
        %3. Perform adaptive filtering on result.
        %The clustering is only done on the forward track
        %distanceMeasure -
        function [d]=genTrack(this,frameIndex,useAllArea,filterConditions,clusterResults,runAdaptive,varargin)
            d=struct([]);
            
            d(1).trialData=this.trialData;
            
            d.scale_mm(1)=this.dataBlockObj.getUnitsValue('axial','mm');
            d.scale_mm(2)=this.dataBlockObj.getUnitsValue('lateral','mm');
            scaleMatrix_mm=diag([d.scale_mm(1) d.scale_mm(2)]);
            
            
            
            %             p = inputParser;   % Create an instance of the class.
            %             %If this is not required then the parser gets confused if just
            %             %name value pairs are given
            %             p.addParamValue('distanceMeasure',struct([]) ,@(x) isstruct(x));
            %             p.parse(varargin{:});
            %             distanceMeasure=p.Results.distanceMeasure;
            distanceMeasure=[];
            if isempty(distanceMeasure)
                distanceMeasure(1).key='signedDistance';
                distanceMeasure(end).description='Compare the signed distance';
                distanceMeasure(end).scaleMatrix=scaleMatrix_mm;
                distanceMeasure(end).func.name='signedDistance';
                distanceMeasure(end).func.args.trackSignedIndex=2;
            end
            
            % if ~isempty(d.dataInfo)
            %     d.trackChange_frameNumber=[d.dataInfo.frameIndex];
            %     d.trackChangeBackward_frameNumber=[d.dataInfoBackward.frameIndex];
            % else
            %     d.trackChange_frameNumber=[];
            %     d.trackChangeBackward_frameNumber=[];
            % end
            
            d.fs=this.dataBlockObj.getUnitsValue('frameRate','framePerSec');
            
            [d.fullTrackPathDelta_rc, sourceTrackPathDelta_rc,badIndexList,d.totalPtDeltaSpeed_mm,trackFrameList,sourceFrameTrackList,d.statistics]=this.genTrackDocDB(frameIndex,useAllArea,'forward',filterConditions);
            [ d.fullTrackPathDelta_rc(1,:) ] = idxReplaceValues( d.fullTrackPathDelta_rc(1,:),badIndexList );
            [ d.fullTrackPathDelta_rc(2,:) ] = idxReplaceValues( d.fullTrackPathDelta_rc(2,:),badIndexList );
            [ d.totalPtDeltaSpeed_mm ] = idxReplaceValues( d.totalPtDeltaSpeed_mm,badIndexList );
            
            [d.fullTrackPathDeltaBackward_rc,sourceTrackPathDeltaBackward_rc,badIndexList,d.totalPtDeltaSpeedBackward_mm,trackFrameListBackward,d.sourceFrameTrackListBackward,d.statisticsBackward ]=this.genTrackDocDB([],useAllArea,'backward',filterConditions);
            [ d.fullTrackPathDeltaBackward_rc(1,:) ] = idxReplaceValues( d.fullTrackPathDeltaBackward_rc(1,:),badIndexList );
            [ d.fullTrackPathDeltaBackward_rc(2,:) ] = idxReplaceValues( d.fullTrackPathDeltaBackward_rc(2,:),badIndexList );
            [ d.totalPtDeltaSpeedBackward_mm ] = idxReplaceValues( d.totalPtDeltaSpeedBackward_mm,badIndexList );
            
            
            if clusterResults
                [ sourceTrackersToUseIndex ] = clusterTracks(sourceTrackPathDelta_rc, sourceTrackPathDeltaBackward_rc, distanceMeasure );
                %reestimate
                data=this.nodeDB(this.defaultNameIndex).data;
                sourceNameList=cellfun(@(x) x.name,regexp(data.sourceFilenameList(sourceTrackersToUseIndex),'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
                clusterFilter={'src',sourceNameList};
                
                [d.fullTrackPathDelta_rc, sourceTrackPathDelta_rc,badIndexList,d.totalPtDeltaSpeed_mm,trackFrameList,sourceFrameTrackList]=this.genTrackDocDB(frameIndex,useAllArea,'forward',[{clusterFilter} filterConditions]);
                [ d.fullTrackPathDelta_rc(1,:) ] = idxReplaceValues( d.fullTrackPathDelta_rc(1,:),badIndexList );
                [ d.fullTrackPathDelta_rc(2,:) ] = idxReplaceValues( d.fullTrackPathDelta_rc(2,:),badIndexList );
                [ d.totalPtDeltaSpeed_mm ] = idxReplaceValues( d.totalPtDeltaSpeed_mm,badIndexList );
                
                [d.fullTrackPathDeltaBackward_rc,sourceTrackPathDeltaBackward_rc,badIndexList,d.totalPtDeltaSpeedBackward_mm,trackFrameListBackward,sourceFrameTrackListBackward ]=this.genTrackDocDB([],useAllArea,'backward',[{clusterFilter} filterConditions]);
                [ d.fullTrackPathDeltaBackward_rc(1,:) ] = idxReplaceValues( d.fullTrackPathDeltaBackward_rc(1,:),badIndexList );
                [ d.fullTrackPathDeltaBackward_rc(2,:) ] = idxReplaceValues( d.fullTrackPathDeltaBackward_rc(2,:),badIndexList );
                [ d.totalPtDeltaSpeedBackward_mm ] = idxReplaceValues( d.totalPtDeltaSpeedBackward_mm,badIndexList );
            end
            
            
            
            
            
            if runAdaptive
                
                %% Adaptive filtering
                averageSpeed_mmPerSec=sqrt(sum(d.fs*scaleMatrix_mm*d.fullTrackPathDeltaBackward_rc.^2,1));
                minAverageSpeed_mmPerSec=averageSpeed_mmPerSec-0.3*averageSpeed_mmPerSec;
                maxAverageSpeed_mmPerSec=70*ones(size(averageSpeed_mmPerSec+5*averageSpeed_mmPerSec));
                
                if clusterResults
                    data=this.nodeDB(this.defaultNameIndex).data;
                    sourceNameList=cellfun(@(x) x.name,regexp(data.sourceFilenameList(sourceTrackersToUseIndex),'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
                    %clusterFilter=cellfun(@(srcName) {'src',srcName},sourceNameList,'UniformOutput',false);
                    clusterFilter={'src',sourceNameList};
                else
                    clusterFilter={};
                end
                
                
                
                
                %Put the src's first
                prb1AdaptiveForward={clusterFilter {'velocityMagAdaptiveKeepBound_mmPerSec',@(x) [minAverageSpeed_mmPerSec(x); maxAverageSpeed_mmPerSec(x)]} };
                prb1AdaptiveBackward={clusterFilter {'velocityMagAdaptiveKeepBound_mmPerSec',@(x) [minAverageSpeed_mmPerSec(x); maxAverageSpeed_mmPerSec(x)]} };
                
                [d.fullTrackPathDelta_rc, ~,badIndexList,d.totalPtDeltaSpeed_mm ]=this.genTrackDocDB(frameIndex,useAllArea,'forward',prb1AdaptiveForward,trackFrameList,sourceFrameTrackList);
                [ d.fullTrackPathDelta_rc(1,:) ] = idxReplaceValues( d.fullTrackPathDelta_rc(1,:),badIndexList );
                [ d.fullTrackPathDelta_rc(2,:) ] = idxReplaceValues( d.fullTrackPathDelta_rc(2,:),badIndexList );
                [ d.totalPtDeltaSpeed_mm ] = idxReplaceValues( d.totalPtDeltaSpeed_mm,badIndexList );
                
                [d.fullTrackPathDeltaBackward_rc,~,badIndexList,d.totalPtDeltaSpeedBackward_mm ]=this.genTrackDocDB([],useAllArea,'backward',prb1AdaptiveBackward,trackFrameListBackward,sourceFrameTrackListBackward);
                [ d.fullTrackPathDeltaBackward_rc(1,:) ] = idxReplaceValues( d.fullTrackPathDeltaBackward_rc(1,:),badIndexList );
                [ d.fullTrackPathDeltaBackward_rc(2,:) ] = idxReplaceValues( d.fullTrackPathDeltaBackward_rc(2,:),badIndexList );
                [ d.totalPtDeltaSpeedBackward_mm ] = idxReplaceValues( d.totalPtDeltaSpeedBackward_mm,badIndexList );
                
            end
            
            
        end
        
        %%
        %This function will generate a track for a region of interest
        %assuming a rigid motion.  This information will be agrigrated to
        %form a single vector or scalar value per frame for that region.
        %The regionToUse is a cell array defined by the view name and
        %region name strings. so to use:
        %this.trialData.collection.ultrasound.bmode.region.name =
        %'rectusFemoris'
        %Then regionToUse would be a cell array with
        %{'collection.ultrasound.bmode','rectusFemoris'}
        function [d]=calcRegionVelocity(this,filterConditions,regionToUse)
            d=struct([]);
            frameIndex=[];
            useAllArea=false;
            clusterResults=false;
            runAdaptive=false;
            
            switch(nargin)
                case 1
                    filterConditions=[];
                    regionToUse=[];
                case 2
                    regionToUse=[];
            end
         
            
            d(1).trialData=this.trialData;
            
            d.scale_mm(1)=this.dataBlockObj.getUnitsValue('axial','mm');
            d.scale_mm(2)=this.dataBlockObj.getUnitsValue('lateral','mm');
            scaleMatrix_mm=diag([d.scale_mm(1) d.scale_mm(2)]);
            
            
            
            %             p = inputParser;   % Create an instance of the class.
            %             %If this is not required then the parser gets confused if just
            %             %name value pairs are given
            %             p.addParamValue('distanceMeasure',struct([]) ,@(x) isstruct(x));
            %             p.parse(varargin{:});
            %             distanceMeasure=p.Results.distanceMeasure;
            distanceMeasure=[];
            if isempty(distanceMeasure)
                distanceMeasure(1).key='signedDistance';
                distanceMeasure(end).description='Compare the signed distance';
                distanceMeasure(end).scaleMatrix=scaleMatrix_mm;
                distanceMeasure(end).func.name='signedDistance';
                distanceMeasure(end).func.args.trackSignedIndex=2;
            end
            
            % if ~isempty(d.dataInfo)
            %     d.trackChange_frameNumber=[d.dataInfo.frameIndex];
            %     d.trackChangeBackward_frameNumber=[d.dataInfoBackward.frameIndex];
            % else
            %     d.trackChange_frameNumber=[];
            %     d.trackChangeBackward_frameNumber=[];
            % end
            
            d.fs=this.dataBlockObj.getUnitsValue('frameRate','framePerSec');
            
            
            [d.fullTrackPathDelta_rc, d.sourceTrackPathDelta_rc,badIndexList,d.totalPtDeltaSpeed_mm,d.trackFrameList,d.sourceFrameTrackList,~,d.sourcePtDelta_mm,d.sourceList,d.sourceNameList]=this.genTrackDocDB(frameIndex,useAllArea,'forward',filterConditions,[],[],[],regionToUse);
            [ d.fullTrackPathDelta_rc(1,:) ] = idxReplaceValues( d.fullTrackPathDelta_rc(1,:),badIndexList );
            [ d.fullTrackPathDelta_rc(2,:) ] = idxReplaceValues( d.fullTrackPathDelta_rc(2,:),badIndexList );
            [ d.totalPtDeltaSpeed_mm ] = idxReplaceValues( d.totalPtDeltaSpeed_mm,badIndexList );
            
            [d.fullTrackPathDeltaBackward_rc,d.sourceTrackPathDeltaBackward_rc,badIndexList,d.totalPtDeltaSpeedBackward_mm,d.trackFrameListBackward,~,d.sourceFrameTrackListBackward,d.sourcePtDeltaBackward_mm,d.sourceListBackward,d.sourceNameListBackward]=this.genTrackDocDB([],useAllArea,'backward',filterConditions,[],[],[],regionToUse);
            [ d.fullTrackPathDeltaBackward_rc(1,:) ] = idxReplaceValues( d.fullTrackPathDeltaBackward_rc(1,:),badIndexList );
            [ d.fullTrackPathDeltaBackward_rc(2,:) ] = idxReplaceValues( d.fullTrackPathDeltaBackward_rc(2,:),badIndexList );
            [ d.totalPtDeltaSpeedBackward_mm ] = idxReplaceValues( d.totalPtDeltaSpeedBackward_mm,badIndexList );
            
            
            
            if clusterResults
                error('cluster results is not implemented.');
            end
            
            
            
            if runAdaptive
                error('run adaptive is not implemented.');
            end
            
            
        end
        
        %%
        %This function will track data stored as a document as opposed to
        %as column vectors
        %This also returns the trackFrameList and sourceFrameTrackList which are the choosen elements
        function [totalPtDelta_rc, sourcePtDelta_rc,badIndexList,totalPtDeltaSpeed_mm,trackFrameList,sourceFrameTrackList,statistics,sourcePtDelta_mm,sourceList,sourceNameList]=genTrackDocDB(this,frameIndex,useAllArea,trackDirection,filterConditions,trackFrameList,sourceFrameTrackList,normType,regionToUse)
            badIndexList=[];
            statistics=[];
            %         p = inputParser;   % Create an instance of the class.
            %             %If this is not required then the parser gets confused if just
            %             %name value pairs are given
            %             p.addParamValue('normType',struct([]) ,@(x) isstruct(x));
            %             p.parse(varargin{:});
            %             normType=p.Results.normType;
            switch(nargin)
                case 2
                    useAllArea=true;
                    trackDirection='forward';
                    filterConditions=[];
                    trackFrameList=[];
                    sourceFrameTrackList=[];
                    normType=[];
                    regionToUse=[];
                case 3
                    trackDirection='forward';
                    filterConditions=[];
                    trackFrameList=[];
                    sourceFrameTrackList=[];
                    normType=[];
                    regionToUse=[];
                case 4
                    filterConditions=[];
                    trackFrameList=[];
                    sourceFrameTrackList=[];
                    normType=[];
                    regionToUse=[];
                case 5
                    trackFrameList=[];
                    sourceFrameTrackList=[];
                    normType=[];
                    regionToUse=[];
                case 6
                    sourceFrameTrackList=[];
                    normType=[];
                    regionToUse=[];
                case 7
                    normType=[];
                    regionToUse=[];
                case 8
                    regionToUse=[];
                case 9
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            
            
            if isempty(frameIndex)
                frameIndex=(1:(this.dataBlockObj.size(3)-2));
            else
                %do nothing
            end
            
            
            
            d=this.nodeDB(this.defaultNameIndex).data;
            switch(trackDirection)
                case 'forward'
                    if isempty(trackFrameList) && isempty(sourceFrameTrackList)
                        trackFrameList=d.trackList(frameIndex);
                        sourceFrameTrackList=d.sourceTrackList(frameIndex);
                        if isfield(d ,'metainformationTrackList')
                            metainformationTrackList=d.metainformationTrackList;
                        else
                            metainformationTrackList=[];
                        end
                    elseif ~isempty(trackFrameList) && ~isempty(sourceFrameTrackList)
                        
                    else
                        error('Either trackFrameList and sourceFrameTrackList should be both empty or both not empty.');
                    end
                    sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
                    
                case 'backward'
                    if isempty(trackFrameList) && isempty(sourceFrameTrackList)
                        trackFrameList=d.trackListBackward(frameIndex);
                        sourceFrameTrackList=d.sourceTrackListBackward(frameIndex);
                        if isfield(d ,'metainformationTrackListBackward')
                            
                            metainformationTrackList=struct('trackList',[]);
                            for ii=1:length(d.metainformationTrackListBackward)
                                metainformationTrackList(ii).trackList=d.metainformationTrackListBackward(ii).trackListBackward;
                            end
                            
                        else
                            metainformationTrackList=[];
                        end
                    elseif ~isempty(trackFrameList) && ~isempty(sourceFrameTrackList)
                        
                    else
                        error('Either trackFrameList and sourceFrameTrackList should be both empty or both not empty.');
                    end
                    sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
                    
                otherwise
                    error(['Unsupported track direction of ' trackDirection]);
            end
            
                       
            [sourcePlotFormatList,sourceLinePlotFormatList]= getPlotMarkers(length(sourceNameList));
            
            if isempty(regionToUse)
                activeRegion=d.regionMod;
            else
                activeRegionObj=RegionInformation;
                activeRegionObj.addRegionFromTrialData(regionToUse{1},this.dataBlockObj,this.trialData,regionToUse{2})
                activeRegion=activeRegionObj.region;
                
            end
            %constrainFeatureframePoints
            if ~useAllArea
                [trackFrameList, filterInfo]=filterTrackListAdaptive(this,trackFrameList,sourceFrameTrackList,activeRegion,filterConditions,sourceNameList,metainformationTrackList);
                for ii=1:length(sourceFrameTrackList)
                    sourceFrameTrackList(ii).pt_rc(:,~filterInfo(ii).validIndexesFromOriginal)=[];
                    %sourceFrameTrackList(ii).ptDelta_rc(~filterInfo(ii).validIndexesFromOriginal)=[];
                    %This staement should be killed since the pt_rc and
                    %ptDelta_rc are linked
                end
            else
                error('Needs to only filter, but not select an ROI');
                %do nothing
            end
            
            
            %this code extracts all the source types which are being used
            if isfield(d,'sourceTrackList')
                sourceList=[];
                for ii=1:length(frameIndex)
                    sourceList=unique([sourceList sourceFrameTrackList(ii).pt_rc(1,:)]);
                end
            else
                error('Please finish');
                sourceTrackList=sourceTrackList(frameIndex);
                sourceList=unique(sourceTrackList.pt_rc(:));
                sourcePlotFormatList={'r.'};
                sourceLinePlotFormatList={{'r','linewidth',2}};
            end
            
            %             bwlabel
            %              CH = bwconvhull(d.regionMod.mask)
            %              http://blogs.mathworks.com/steve/2011/10/04/binary-image-convex-hull-algorithm-notes/
            
            %% Sort and compute the tracks for each method.  We also compute the statistics such as the mean position for each source tracker and the std of the velocity measure
            sourcePtDelta_rc=zeros(2,length(frameIndex),length(sourceList));
            sourcePtDelta_mm=zeros(1,length(frameIndex),length(sourceList));
            
            totalPtDelta_rc=zeros(2,length(frameIndex));
            totalPtDeltaSpeed_mm=zeros(1,length(frameIndex));
            scaleToMm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            for ii=1:length(frameIndex)
                for ss=1:length(sourceList)
                    sourceIndexes=(sourceList(ss)==sourceFrameTrackList(ii).pt_rc(1,:));
                    
                    %This is the mean value of the displacement vector in a
                    %region
                    sourcePtDelta_rc(:,ii,ss)=mean(trackFrameList(ii).ptDelta_rc(:,sourceIndexes),2);
                    
                    %This is the mean length of the displacement for each source.  The length of each displacement is computed seperately and then
                    %averaged together
                    sourcePtDelta_mm(:,ii,ss)=mean(sqrt(sum((scaleToMm*trackFrameList(ii).ptDelta_rc(:,sourceIndexes)).^2,1)));
                end
                totalPtDelta_rc(:,ii)=mean(trackFrameList(ii).ptDelta_rc,2);
                totalPtDeltaSpeed_mm(:,ii)=mean(sqrt(sum((scaleToMm*trackFrameList(ii).ptDelta_rc).^2,1)));
                if any(isnan(totalPtDelta_rc(:,ii)))
                    warning(['NaN detected in frame ' num2str(frameIndex(ii)) '. This normally results when no feature points match the search criteria.']);
                    badIndexList=[badIndexList ii];
                else
                    %do nothing
                end
                
            end
            
            %            %% This code will plot the averaged velocity as a speed
            %             figure;
            %             legendEntry=matlab.graphics.chart.primitive.Line.empty(0);
            %             sourcePlotFormatList=[{'r','g','c','b','m','y','k','r:','g:'}'] ;
            %             scaleToMm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            %             fps=this.dataBlockObj.getUnitsValue('frameRate','framePerSec');
            %
            %             t_sec=(0:(length(frameIndex)-1))/fps;
            %             %t_sec=(1:(length(frameIndex)));
            %
            %             subplot(2,1,1)
            %             hold on
            %             for ss=1:length(sourceList)
            %                 switch trackDirection
            %                     case 'forward'
            %                         phs=plot(t_sec,sourcePtDelta_mm(:,:,ss)*fps,sourcePlotFormatList{ss});
            %                     case 'backward'
            %                         phs=plot(t_sec,-fliplr(sourcePtDelta_mm(:,:,ss)*fps),sourcePlotFormatList{ss});
            %                     otherwise
            %                         error(['Bad track direction of ' trackDirection])
            %                 end
            %
            %                 legendEntry(ss)=phs;
            %             end
            %             totalPlotFormatList={'r','lineWidth',2};
            %             switch trackDirection
            %                 case 'forward'
            %                     phs=plot(t_sec,totalPtDeltaSpeed_mm*fps,totalPlotFormatList{:});
            %                 case 'backward'
            %                     phs=plot(t_sec,-fliplr(totalPtDeltaSpeed_mm)*fps,totalPlotFormatList{:});
            %                 otherwise
            %                     error(['Bad track direction of ' trackDirection])
            %             end
            %
            %             legendEntry(end+1)=phs;
            %             legend(legendEntry,{sourceNameList{sourceList},'avg using all'},'interpreter','none')
            %             title([this.trialData.sourceMetaFilename '. Motion track. Direction = ' trackDirection],'interpreter','none');
            %             xlabel('time (sample)')
            %             ylabel('velocity mm/sec')
            %
            %
            %             %---------------------
            %             subplot(2,1,2)
            %             hold on
            %             for ss=1:length(sourceList)
            %
            %                 switch trackDirection
            %                     case 'forward'
            %                         phs=plot(t_sec,sqrt(sum((scaleToMm*sourcePtDelta_rc(:,:,ss)).^2,1))*fps,sourcePlotFormatList{ss});
            %                     case 'backward'
            %                         phs=plot(t_sec,-fliplr(sqrt(sum((scaleToMm*sourcePtDelta_rc(:,:,ss)).^2,1))*fps),sourcePlotFormatList{ss});
            %                     otherwise
            %                         error(['Bad track direction of ' trackDirection])
            %                 end
            %
            %                 legendEntry(ss)=phs;
            %             end
            %             totalPlotFormatList={'r','lineWidth',2};
            %             switch trackDirection
            %                 case 'forward'
            %                     phs=plot(t_sec,sqrt(sum((scaleToMm*totalPtDelta_rc(:,:)).^2,1))*fps,totalPlotFormatList{:});
            %                 case 'backward'
            %                     phs=plot(t_sec,-fliplr(sqrt(sum((scaleToMm*totalPtDelta_rc(:,:)).^2,1))*fps),totalPlotFormatList{:});
            %                 otherwise
            %                     error(['Bad track direction of ' trackDirection])
            %             end
            %             title([this.trialData.sourceMetaFilename '. Motion track. Direction = ' trackDirection],'interpreter','none');
            %             xlabel('time (sample)')
            %             ylabel('velocity mm/sec')
            %
            %             %---------------------
            %             figure
            %             legendEntry=matlab.graphics.chart.primitive.Line.empty(0);
            %             hold on
            %             for ss=1:length(sourceList)
            %                 X=(scaleToMm*sourcePtDelta_rc(:,:,ss))*fps;
            %                 switch trackDirection
            %                     case 'forward'
            %                         phs=plot3(t_sec,X(1,:),X(2,:),sourcePlotFormatList{ss});
            %                     case 'backward'
            %                         phs=plot3(t_sec,-fliplr(X(1,:)),-fliplr(X(2,:)),sourcePlotFormatList{ss});
            %                     otherwise
            %                         error(['Bad track direction of ' trackDirection])
            %                 end
            %
            %                 legendEntry(ss)=phs;
            %             end
            %             totalPlotFormatList={'r','lineWidth',2};
            %             X=(scaleToMm*totalPtDelta_rc(:,:))*fps;
            %             switch trackDirection
            %                 case 'forward'
            %                     phs=plot3(t_sec,X(1,:),X(2,:),totalPlotFormatList{:});
            %                 case 'backward'
            %                     phs=plot3(t_sec,-fliplr(X(1,:)),-fliplr(X(2,:)),totalPlotFormatList{:});
            %                 otherwise
            %                     error(['Bad track direction of ' trackDirection])
            %             end
            %
            %             legendEntry(end+1)=phs;
            %             legend(legendEntry,{sourceNameList{sourceList},'avg using all'},'interpreter','none')
            %             title([this.trialData.sourceMetaFilename '. Motion track. Direction = ' trackDirection],'interpreter','none');
            %             xlabel('time (sample)')
            %             ylabel('velocity mm/sec')
            % %             ylim([-20 20])
            % %             zlim([-60 60])
            %
            %
            
            
        end
        
        function plotVelocity(this,trackResults, varargin)
            d=this.nodeDB(this.defaultNameIndex).data;
            p = inputParser;   % Create an instance of the class.
            p.addParamValue('trackDirection','forward',@(x) any(strcmp(x,{'forward','backward'})));
            p.addParamValue('xAxisUnit','sec',@(x) any(strcmp(x,{'sec','frame'})));
            
            p.parse(varargin{:});
            trackDirection = p.Results.trackDirection;
            xAxisUnit = p.Results.xAxisUnit;
            
            legendEntry=matlab.graphics.chart.primitive.Line.empty(0);
            sourcePlotFormatList=[{'r','g','c','b','m','y','k','r:','g:'}'] ;
            sourceNameList=cellfun(@(x) x.name,regexp(d.sourceFilenameList,'\\(?<name>\w+)\\results.mat$','names'),'UniformOutput',false);
            
            scaleToMm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            fps=this.dataBlockObj.getUnitsValue('frameRate','framePerSec');
            
            totalFrames=min(length(trackResults.totalPtDeltaSpeed_mm),length(this.nodeDB.data.trackList));
            switch(xAxisUnit)
                case 'sec'
                    t_sec=(0:(totalFrames-1))/fps;
                case 'frame'
                    t_sec=(0:(totalFrames-1));
                otherwise
                    error(['Invalid value of t '  num2str(t_sec)]);
            end
            
            figure;
            subplot(2,1,1)
            hold on
            for ss=1:size(trackResults.sourceList,2)
                switch trackDirection
                    case 'forward'
                        phs=plot(t_sec,trackResults.sourcePtDelta_mm(:,:,ss)*fps,sourcePlotFormatList{trackResults.sourceList(ss)});
                    case 'backward'
                        phs=plot(t_sec,-fliplr(trackResults.sourcePtDelta_mm(:,:,ss)*fps),sourcePlotFormatList{trackResults.sourceList(ss)});
                    otherwise
                        error(['Bad track direction of ' trackDirection])
                end
                
                legendEntry(ss)=phs;
            end
            totalPlotFormatList={'r','lineWidth',2};
            switch trackDirection
                case 'forward'
                    phs=plot(t_sec,trackResults.totalPtDeltaSpeed_mm*fps,totalPlotFormatList{:});
                case 'backward'
                    phs=plot(t_sec,-fliplr(trackResults.totalPtDeltaSpeed_mm)*fps,totalPlotFormatList{:});
                otherwise
                    error(['Bad track direction of ' trackDirection])
            end
            
            legendEntry(end+1)=phs;
            legend(legendEntry,{trackResults.sourceNameList{trackResults.sourceList},'avg using all'},'interpreter','none')
            title([this.trialData.sourceMetaFilename '. Motion track. Direction = ' trackDirection],'interpreter','none');
            switch(xAxisUnit)
                case 'sec'
                    xlabel('time (sec)')
                case 'frame'
                    xlabel('time (frame)')
                otherwise
                    error(['Invalid value of t '  num2str(t_sec)]);
            end
            
            ylabel('speed (mm/sec)')
            %---------------------
            subplot(2,1,2)
            hold on
            for ss=1:length(trackResults.sourceList)
                
                switch trackDirection
                    case 'forward'
                        phs=plot(t_sec,sqrt(sum((scaleToMm*trackResults.sourceTrackPathDelta_rc(:,:,ss)).^2,1))*fps,sourcePlotFormatList{trackResults.sourceList(ss)});
                    case 'backward'
                        phs=plot(t_sec,-fliplr(sqrt(sum((scaleToMm*trackResults.sourceTrackPathDeltaBackward_rc(:,:,ss)).^2,1))*fps),sourcePlotFormatList{trackResults.sourceList(ss)});
                    otherwise
                        error(['Bad track direction of ' trackDirection])
                end
                
                legendEntry(ss)=phs;
            end
            totalPlotFormatList={'r','lineWidth',2};
            switch trackDirection
                case 'forward'
                    phs=plot(t_sec,sqrt(sum((scaleToMm*trackResults.fullTrackPathDelta_rc(:,:)).^2,1))*fps,totalPlotFormatList{:});
                case 'backward'
                    phs=plot(t_sec,-fliplr(sqrt(sum((scaleToMm*trackResults.fullTrackPathDeltaBackward_rc(:,:)).^2,1))*fps),totalPlotFormatList{:});
                otherwise
                    error(['Bad track direction of ' trackDirection])
            end
            title([this.trialData.sourceMetaFilename '. Motion track. Direction = ' trackDirection],'interpreter','none');
            switch(xAxisUnit)
                case 'sec'
                    xlabel('time (sec)')
                case 'frame'
                    xlabel('time (frame)')
                otherwise
                    error(['Invalid value of t '  num2str(t_sec)]);
            end
            
            ylabel('speed (mm/sec)')
            
            %---------------------
            figure
            subplot(1,2,1);
            legendEntry=matlab.graphics.chart.primitive.Line.empty(0);
            hold on
            for ss=1:length(trackResults.sourceList)
                
                switch trackDirection
                    case 'forward'
                        X=(scaleToMm*trackResults.sourceTrackPathDelta_rc(:,:,ss))*fps;
                        phs=plot3(t_sec,X(1,:),X(2,:),sourcePlotFormatList{trackResults.sourceList(ss)});
                    case 'backward'
                        X=(scaleToMm*trackResults.sourceTrackPathDeltaBackward_rc(:,:,ss))*fps;
                        phs=plot3(t_sec,-fliplr(X(1,:)),-fliplr(X(2,:)),sourcePlotFormatList{trackResults.sourceList(ss)});
                    otherwise
                        error(['Bad track direction of ' trackDirection])
                end
                
                legendEntry(ss)=phs;
            end
            totalPlotFormatList={'r','lineWidth',2};
            
            switch trackDirection
                case 'forward'
                    X=(scaleToMm*trackResults.fullTrackPathDelta_rc(:,:))*fps;
                    phs=plot3(t_sec,X(1,:),X(2,:),totalPlotFormatList{:});
                case 'backward'
                    X=(scaleToMm*trackResults.fullTrackPathDeltaBackward_rc(:,:))*fps;
                    phs=plot3(t_sec,-fliplr(X(1,:)),-fliplr(X(2,:)),totalPlotFormatList{:});
                otherwise
                    error(['Bad track direction of ' trackDirection])
            end
            legendEntry(end+1)=phs;
            legend(legendEntry,{trackResults.sourceNameList{trackResults.sourceList},'avg using all'},'interpreter','none')
            title([this.trialData.sourceMetaFilename '. Motion track. Direction = ' trackDirection],'interpreter','none');
            switch(xAxisUnit)
                case 'sec'
                    xlabel('time (sec)')
                case 'frame'
                    xlabel('time (frame)')
                otherwise
                    error(['Invalid value of t '  num2str(t_sec)]);
            end
            
            ylabel('axial velocity (mm/sec)')
            zlabel('lateral velocity (mm/sec)')
            view([0 0]);
            
            subplot(1,2,2);
            switch trackDirection
                case 'forward'
                    X=(scaleToMm*trackResults.fullTrackPathDelta_rc(:,:));
                    phs=plot3(t_sec,cumsum(X(1,:)),cumsum(X(2,:)),totalPlotFormatList{:});
                case 'backward'
                    X=(scaleToMm*trackResults.fullTrackPathDeltaBackward_rc(:,:));
                    phs=plot3(t_sec,-fliplr(cumsum(X(1,:))),-fliplr(cumsum(X(2,:))),totalPlotFormatList{:});
                otherwise
                    error(['Bad track direction of ' trackDirection])
            end
            
            title('Total displacement')
            switch(xAxisUnit)
                case 'sec'
                    xlabel('time (sec)')
                case 'frame'
                    xlabel('time (frame)')
                otherwise
                    error(['Invalid value of t '  num2str(t_sec)]);
            end
            
            ylabel('axial displacement (mm)')
            zlabel('lateral displacement (mm)')
            view([90 0])
            
        end
        %This function will filter thedetected points based on a set of constraints
        %rounding of point locations is done using the fix function
        %if the region is empty then all of the image area is used
        function [trackList filterInfo]=filterTrackListAdaptive(this,trackList,sourceFrameTrackList,region,filterConditions,sourceNameList,metainformationTrackList)
            filterInfo=struct('validIndexesFromOriginal',[]);
            
            scaleToMm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            fps=this.dataBlockObj.getUnitsValue('frameRate','framePerSec');
            
            this.filterDebug=zeros(length(trackList),1);
            %ii is the frame count
            for ii=1:length(trackList)
                % fprintf(1,'%d,',ii);
                pt_rc=fix(trackList(ii).pt_rc);
                ptNext_rc=fix(pt_rc+trackList(ii).ptDelta_rc);
                
                if ~isempty(region)
                    imSize=size(region.mask);
                    %form a clip window, with the rectangular region mask and
                    %any border
                    isPtInBounds=pt_rc(1,:)>=1 & pt_rc(2,:)>=1 & ptNext_rc(1,:)>=1 & ptNext_rc(2,:)>=1 ...
                        & pt_rc(1,:)<=imSize(1) & pt_rc(2,:)<=imSize(2) & ptNext_rc(1,:)<=imSize(1) & ptNext_rc(2,:)<=imSize(2);
                    
                    isPtInBoundsIdx=find(isPtInBounds);
                    isPtInBoundAndValid=region.mask(sub2ind(size(region.mask),pt_rc(1,isPtInBoundsIdx),pt_rc(2,isPtInBoundsIdx))) ...
                        & region.mask(sub2ind(size(region.mask),ptNext_rc(1,isPtInBoundsIdx),ptNext_rc(2,isPtInBoundsIdx)));
                    
                    
                    isPtInBounds(isPtInBoundsIdx(~isPtInBoundAndValid))=false;
                else
                    %all points are in bounds because ther is no mask
                    isPtInBounds = true(1,size(pt_rc,2));
                end
                
                filterIdxPass=true(1,size(sourceFrameTrackList(ii).pt_rc,2));
                for fff=1:length(filterConditions)
                    processPackage=filterConditions{fff};
                    processName=processPackage{1};
                    processBody=processPackage{2};
                    
                    switch(processName)
                        case 'srcNot'
                            
                            for processIdx=1:length(processBody)
                                
                                srcIdx = strmatch(processBody{processIdx}, sourceNameList, 'exact');
                                if ~isempty(srcIdx)
                                    filterIdxPass = and(filterIdxPass,(sourceFrameTrackList(ii).pt_rc(1,:)~=srcIdx));
                                else
                                    %do nothing
                                end
                                
                                
                            end
                        case 'src'  %This only includes the feature detectors that are listed
                            
                            srcIdxPass=false(size(filterIdxPass));
                            %loop through all the feature detectors
                            for processIdx=1:length(processBody)
                                %See if that feature detector was in the
                                %list of tracked features
                                srcIdx = strmatch(processBody{processIdx}, sourceNameList, 'exact');
                                
                                if ~isempty(srcIdx)
                                    %if the source was found than or those
                                    %features in with the rest of the
                                    %features.
                                    srcIdxPass = or(srcIdxPass,(sourceFrameTrackList(ii).pt_rc(1,:)==srcIdx));
                                else
                                    %if that source was not found then just skip
                                end
                                
                            end
                            filterIdxPass=and(filterIdxPass,srcIdxPass);
                            
                        case 'deltaKeep'
                            keepPass=false(size(filterIdxPass));
                            %too slow so create as for loop
                            %filterIdxPass=and(filterIdxPass,colvecfun(processBody,trackList(ii).ptDelta_rc));
                            for ppp=1:size(trackList(ii).ptDelta_rc,2)
                                keepPass(ppp)=processBody(trackList(ii).ptDelta_rc(:,ppp));
                            end
                            filterIdxPass=and(filterIdxPass,keepPass);
                            
                        case 'velocityMagKeep_mmPerSec'
                            %too slow so create as for loop
                            %filterIdxPass=and(filterIdxPass,colvecfun(processBody,trackList(ii).ptDelta_rc));
                            keepPass=processBody(sqrt(sum((scaleToMm*trackList(ii).ptDelta_rc).^2,1))*fps);
                            filterIdxPass=and(filterIdxPass,keepPass);
                        case 'trackletListLength'
                            if isempty(metainformationTrackList)
                                continue;
                            end
                            %find which tracks have the 'trackletListLength'
                            %as a field. below is what we want to implement,
                            %but it is 10 times slower than a for loop
                            %validtrackletIdx=find(arrayfun(@(idx) ~isempty(this.nodeDB(this.defaultNameIndex).data.metainformationTrackList(idx).trackList(1)) && isfield(this.nodeDB(this.defaultNameIndex).data.metainformationTrackList(idx).trackList(1),'trackletListLength'),1:length(this.nodeDB(this.defaultNameIndex).data.metainformationTrackList)));
                            isTrackletLength=false(1,length(metainformationTrackList));
                            ln1=length(metainformationTrackList);
                            for idx=1:ln1
                                isTrackletLength(idx)=(~isempty(metainformationTrackList(idx).trackList(1)) && isfield(metainformationTrackList(idx).trackList(1),'trackletListLength'));
                            end
                            sourcesWithTrackletIdx=find(isTrackletLength);
                            
                            
                            %sourceFrameTrackList(ii).pt_rc contains the
                            %source number of the tracker and the index
                            %number of where it is in the pt_rc which
                            %contains the actual track info
                            isTrackWithTrackletLength=ismember(sourceFrameTrackList(ii).pt_rc(1,:),sourcesWithTrackletIdx);
                            idxTrackWithTrackletLength=sourceFrameTrackList(ii).pt_rc(:,isTrackWithTrackletLength);
                            %
                            %any(bsxfun(@eq, sourceFrameTrackList(ii).pt_rc(1,:)',validtrackletIdx ),2)
                            
                            %made this a for loop instead of arrayfun
                            %because it will create a copy of nodeDB for
                            %the annonomous function which will be very
                            %slow.
                            keepPass=zeros(size(idxTrackWithTrackletLength,2),1);
                            for tt=1:size(idxTrackWithTrackletLength,2)
                                %metainformationTrackList(trackletInfo(1,tt)).trackList(ii).trackletListId==trackletInfo(2,tt)
                                %trackletInfo is a series of column vectors
                                %which contain the source as the first row
                                %and the index into that source which is
                                %the specific point as the second row
                                try
                                    keepPass(tt)=metainformationTrackList(idxTrackWithTrackletLength(1,tt)).trackList(ii).trackletListLength(idxTrackWithTrackletLength(2,tt));
                                catch me
                                    warning(['Tried to address src,track (' num2str(idxTrackWithTrackletLength(1,tt)) ',' num2str(idxTrackWithTrackletLength(2,tt)) '),' ...
                                        ' but max track index is ' num2str(length(metainformationTrackList(idxTrackWithTrackletLength(1,tt)).trackList(ii).trackletListLength))]);
                                    keepPass(tt)=0;
                                end
                            end
                            keepPass=processBody(keepPass);
                            keepPassFull=false(size(filterIdxPass));
                            keepPassFull(isTrackWithTrackletLength)=keepPass;
                            
                            filterIdxPass=and(filterIdxPass,keepPassFull);
                        case 'trackletListPosition'
                            error('Please finish');
                        case 'velocityMagAdaptiveKeepBound_mmPerSec'
                            velocityBound=processBody(ii);
                            velocity_mmPerSec=(sqrt(sum((scaleToMm*trackList(ii).ptDelta_rc).^2,1))*fps);
                            keepPass=(velocity_mmPerSec>=velocityBound(1)) & (velocity_mmPerSec<=velocityBound(2));
                            filterIdxPass=and(filterIdxPass,keepPass);
                        case 'borderTrim_rc'
                            borderTrim_rc=processBody(ii);
                            %clip the points to the border
                            keepPass=~(trackList(ii).pt_rc(1,:)<borderTrim_rc(1) | ...
                                trackList(ii).pt_rc(1,:)>(imSize(1)-borderTrim_rc(2)) | ...
                                trackList(ii).pt_rc(2,:)<borderTrim_rc(3) | ...
                                trackList(ii).pt_rc(2,:)>(imSize(2)-borderTrim_rc(4)));
                            filterIdxPass=and(filterIdxPass,keepPass);
                        case 'angleFilter'
                            velocity_mmPerSec=scaleToMm*trackList(ii).ptDelta_rc*fps;
                            
                            speed_mmPerSec=sqrt(sum(velocity_mmPerSec.^2,1));
                            
                            angleMeasure_deg = 180/pi*atan2(velocity_mmPerSec(1,:),velocity_mmPerSec(2,:));
                            angleBinranges_deg=linspace(-180,180,361);
                            angleBincounts = histc(angleMeasure_deg,angleBinranges_deg);
                            leftMotion=angleBinranges_deg>90 | angleBinranges_deg<-90;
                            rightMotion=~leftMotion;
                            
                            %                             speedBinranges_mm=linspace(0,5,400);
                            %                             speedBincounts = histc(speed_mmPerSec,speedBinranges_mm);
                            medianSpeed_mmPerSec=median(speed_mmPerSec);
                            %We want
                            if medianSpeed_mmPerSec>20
                                angleOffset=0;
                            elseif medianSpeed_mmPerSec<=20 && medianSpeed_mmPerSec>10
                                %we want it to go from 0 to 90 in 10
                                %degrees, so the slope is
                                %90/10*(medianSpeed_mmPerSec-10)
                                
                                angleOffset=90/10*(medianSpeed_mmPerSec-10);
                            else
                                angleOffset=90;
                            end
                            
                            
                            this.filterDebug(ii)=medianSpeed_mmPerSec;
                            if false
                                %%
                                figure; bar(speedBinranges_mm,speedBincounts,'histc');
                            end
                            
                            
                            if sum(angleBincounts(leftMotion))< sum(angleBincounts(rightMotion))
                                %going right [-90 to 90]
                                keepPass= angleMeasure_deg>=(-90-angleOffset) & angleMeasure_deg<=(90+angleOffset);
                            else
                                %going left [90 to 180] and [-180 to -90]
                                keepPass=(angleMeasure_deg>=(90-angleOffset) | angleMeasure_deg<=(-90+angleOffset));
                            end
                            
                            filterIdxPass=and(filterIdxPass, keepPass & (speed_mmPerSec<70));
                        otherwise
                            
                            if ~isempty(filterConditions) && (length(filterConditions)>=ii)
                                error('Fix');
                                isPtValid=isPtValid & (sign(trackList(ii).ptDelta_rc(2,:))==sign(filterConditions(ii)));
                            end
                            
                            error(['processName=' processName]);
                    end
                    
                    
                end
                
                pointsToKeep= isPtInBounds &  filterIdxPass;
                trackList(ii).pt_rc(:,~pointsToKeep)=[];
                trackList(ii).ptDelta_rc(:,~pointsToKeep)=[];
                if isfield(trackList,'ptMetric')
                    trackList(ii).ptMetric(:,~pointsToKeep)=[];
                    trackList(ii).trackletListId(:,~pointsToKeep)=[];
                    trackList(ii).trackletListPosition(:,~pointsToKeep)=[];
                    trackList(ii).trackletListLength(:,~pointsToKeep)=[];
                else
                end
                
                filterInfo(ii).validIndexesFromOriginal=pointsToKeep;
                
            end
        end
        
        function  createTrackMovie(this, varargin )
            %CREATETRACKMOVIE This function will create a movie showing the
            %track results.  If the filename is empty then it will be given
            %the current date time stamp accurate to the nearest second.
            %meanPt_rc is the area where the majority of the tracks
            %originated
            
            p = inputParser;   % Create an instance of the class.
            %If this is not required then the parser gets confused if just
            %name value pairs are given
            p.addRequired('baseDatafilename',@(x) ischar(x) || isempty(x));
            p.addOptional('skipMaskVideo',true,@(x) islogical(x) || isempty(x));
            p.addParamValue('trackResults',[] ,@(x) isstruct(x) || isempty(x));
            p.addParamValue('meanPt_rc',[] ,@(x) isnumeric(x) && (size(x,1)==2) || isempty(x));
            p.addParamValue('stdPtDelta_rc',[] ,@(x) isnumeric(x) && (size(x,1)==2) || isempty(x));
            
            p.parse(varargin{:});
            baseDatafilename=p.Results.baseDatafilename;
            skipMaskVideo=p.Results.skipMaskVideo;
            trackResults=p.Results.trackResults;
            meanPt_rc=p.Results.meanPt_rc;
            stdPtDelta_rc=p.Results.stdPtDelta_rc;
            
            if isempty(baseDatafilename)
                baseDatafilename=datestr(now,'yyyy_mm_dd_HH_MM_SS');
            end
            
            vid=vopen(baseDatafilename,'w',1,{'VideoWriter', 'MPEG-4'},skipMaskVideo);
            
            figureHandle=figure;
            
            
            if ~isempty(trackResults)
                totalFrames=min(length(trackResults.ultrasound.vSmoothWeightedAverage_mmPerSec),length(this.nodeDB.data.trackList));
            else
                totalFrames=length(this.nodeDB.data.trackList);
            end
            
            scale_mm=diag([this.dataBlockObj.getUnitsValue('axial','mm') this.dataBlockObj.getUnitsValue('lateral','mm')]);
            fps=this.dataBlockObj.getUnitsValue('frameRate','framePerSec');
            
            if ~isempty(stdPtDelta_rc)
                stdPtDelta_mmPerSec=sqrt(sum(scale_mm*stdPtDelta_rc.^2,1))*fps;
                
            end
            velocityAxisBound_mmPerSec=zeros(2,1);
            %don't use max for the std velocity because of outliers
            velocityAxisBound_mmPerSec(1)=min(trackResults.ultrasound.vSmoothWeightedAverage_mmPerSec)-mean(stdPtDelta_mmPerSec);
            velocityAxisBound_mmPerSec(2)=max(trackResults.ultrasound.vSmoothWeightedAverage_mmPerSec)+mean(stdPtDelta_mmPerSec);
            
            for ff=1:totalFrames
                
                this.showFeatureColorPlot([ff],true,[],'rowDisplayWidth',5,'figureHandle',figureHandle,'meanPt_rc',meanPt_rc,'stdPtDelta_rc',stdPtDelta_rc);
                set(gcf,'Position',[38         198        1235         724]);
                
                if ~isempty(trackResults)
                    subplot(3,2,[5 6])
                    plot(trackResults.ultrasound.t_sec,trackResults.ultrasound.vSmoothWeightedAverage_mmPerSec,'linewidth',2);
                    ylim(velocityAxisBound_mmPerSec);
                    hold on;
                    plot(trackResults.ultrasound.t_sec(ff),trackResults.ultrasound.vSmoothWeightedAverage_mmPerSec(ff),'or','linewidth',1);
                    
                    if ~isempty(stdPtDelta_rc)
                        stdBound_mmPerSec=(stdPtDelta_mmPerSec(ff)/2*[-1 1]);
                        plot(trackResults.ultrasound.t_sec(ff)*[1 1],stdBound_mmPerSec+trackResults.ultrasound.vSmoothWeightedAverage_mmPerSec(ff),'g','linewidth',2);
                    end
                    xlabel('time (sec)');
                    ylabel('velocity (mm/sec)');
                    title([' Frame ' num2str(ff) ' of ' num2str(this.dataBlockObj.size(3)) ]);
                    hold off;
                else
                    subplot(3,2,[5 6])
                    title([' Frame ' num2str(ff) ' of ' num2str(this.dataBlockObj.size(3)) ]);
                end
                drawnow;
                vid=vwrite(vid,gcf,'handle');
                pause(0.1)
                %close(gcf);
                %clf(gcf);
                
            end
            
            vclose(vid);
            
            
        end
        
        function agent(this)
            agentLab(this);
        end
    end
    
end



