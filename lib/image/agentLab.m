%Add config properties
%add metadata feature for dataObject.  Can be very different depending on
%the case
%allow config properties to be passed for called guis.
%use input parser to model

function varargout = agentLab(varargin)
% AGENTLAB MATLAB code for agentLab.fig
%      AGENTLAB, by itself, creates a new AGENTLAB or raises the existing
%      singleton*.
%
%      H = AGENTLAB returns the handle to a new AGENTLAB or the handle to
%      the existing singleton*.
%
%      AGENTLAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AGENTLAB.M with the given input arguments.
%
%      AGENTLAB('Property','Value',...) creates a new AGENTLAB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before agentLab_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to agentLab_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%EXAMPLE:
%===Load a data file===
%addpath(fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\data\subject\mriCompare'));
%varargout = agentLab({'trialName','MRUS008_V1_S1_T1','dataSourceNodeName', 'col_ultrasound_bmode'});

%===Load a matlab array into agentLab===
%dataBlockObj=DataBlockObj(imBlock,'matlabArray');
%dataBlockObj.open('cacheMethod','all');
%processFunction=@(x) x;
%dataBlockObj.newProcessStream('agentLab',processFunction, true);
%varargout = agentLab(dataBlockObj);
%
%===How to mark regions===
%To mark a region mark the points for the spline with "c" key. Then select
%the "Spline Show" button to paste the spline values to the console. This
%can then be copied into the datafile
% See also: GUIDE, GUIDATA, GUIHANDLES
%

% Last Modified by GUIDE v2.5 19-Jun-2014 14:53:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @agentLab_OpeningFcn, ...
    'gui_OutputFcn',  @agentLab_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before agentLab is made visible.
function agentLab_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to agentLab (see VARARGIN)
%INPUT
%inputSource - can be a dataBlockObject or a cell specifiying the input
%class

% Choose default command line output for agentLab
handles.output = hObject;

%Set the config settings to default values
handles.configSettings.createCurveConfigSettings={};
handles.configSettings.defaultSplineFilename=[];

switch(length(varargin))
    case 0
        inputSource=userOpenFile;
    case 1
        inputSource=varargin{1};
    case 2
        handles.dataBlockObj=varargin{1};
        p = inputParser;   % Create an instance of the class.
        p.addParamValue('createCurveConfigSettings', @iscell);
        p.addParamValue('defaultSplineFilename', @(x) ischar);
        p.parse(varargin{2}{:});
        handles.configSettings.createCurveConfigSettings=p.Results.createCurveConfigSettings;
        handles.configSettings.defaultSplineFilename=p.Results.defaultSplineFilename;
    otherwise
        error('Invalid number of input argumetns.');
end

%This switch block will output a valid data source
switch(class(inputSource))
    case 'DataBlockObj'
        handles.dataBlockObj=inputSource;
    case 'TrackingAnalysis'
        handles.trackingAnalysis=inputSource;
        handles.dataBlockObj=handles.trackingAnalysis.dataBlockObj;        
    case 'cell'
        p = inputParser;   % Create an instance of the class.
        p.addParamValue('trialName', [],@ischar);
        p.addParamValue('dataSourceNodeName',[], @ischar);
        p.parse(inputSource{:});        
        trialData=loadMetadata([p.Results.trialName '.m']);
        handles.dataBlockObj=getCollection(trialData,p.Results.dataSourceNodeName);
    otherwise
        error(['Unsupport class of ' class(inputSource) ' for inputSource.']);
end



if ~isempty(handles.dataBlockObj.blockSource)
    set(handles.figAgentLab,'name',handles.dataBlockObj.blockSource);
else
    set(handles.figAgentLab,'name','No block source provided.');
end
    

handles.case.frames=[1:(handles.dataBlockObj.size(3))];
handles.case.activePoint.id=[];
handles.case.activeProcessStreamName='agentLab';
handles.case.activeFrameIdx=1;

im=handles.dataBlockObj.getSlice([0 1]+1,[],handles.case.activeProcessStreamName);


%The index of the frame and not the frame itself are the slices for the
%agents
handles.agents.grid2AgentObj=grid2Agent(handles.case.activeFrameIdx);
handles.agents.grid2AgentObj.addAxes(handles.axesMain);
handles.agents.grid2AgentObj.regionType='spline';
handles.agents.grid2AgentObj.color='r';
handles.agents.grid2AgentObj.dataBlockObj=handles.dataBlockObj;

handles.agents.manualTrackObj=grid2Agent(handles.case.activeFrameIdx);
handles.agents.manualTrackObj.addAxes(handles.axesMain);
handles.agents.manualTrackObj.regionType='point';
handles.agents.manualTrackObj.color='g';
handles.agents.manualTrackObj.dataBlockObj=handles.dataBlockObj;

handles.case.imblock=zeros(size(im,1),size(im,2),3);
handles.case.imblock(:,:,2:3)=im;

set(handles.editZoom,'String',['[' num2str([1 size(im,2) 1 size(im,1) ]) ']' ])

handles=paintFrames(handles);

set(handles.chkTrackletName,'Value',1);
set(handles.edtTrackletName,'String','t1');


set(handles.figAgentLab,'KeyPressFcn',{@saveTrackPoint});

set(handles.edtAgentFunction,'String','agentRun')

handles.agentManager=agentManager(handles.figAgentLab,handles.configSettings);

addlistener(handles.dataBlockObj,'NewProcessStreamEvent',@(src,eventData) handleEventDataChanged(src,eventData,handles.figAgentLab));

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes agentLab wait for user response (see UIRESUME)
% uiwait(handles.figAgentLab);
end

function handleEventDataChanged(dataBlockObj,eventKeyValuePayload,figureHandle)

handles=guidata(figureHandle);

if strcmp(eventKeyValuePayload.keyValuePayload{1},'processStream.name')
    processStream.name=eventKeyValuePayload.keyValuePayload{2};
else
    return;
end


frameList=[(handles.case.activeFrameIdx-1) handles.case.activeFrameIdx (handles.case.activeFrameIdx+1)];

validFrameIndex=(frameList>=min(handles.case.frames)) & (frameList<=max(handles.case.frames));

handles.case.imblock(:,:,validFrameIndex)=dataBlockObj.getSlice(frameList(validFrameIndex),1,processStream.name);
handles.case.imblock(: ,:,~validFrameIndex)=0;


handles=paintFrames(handles);

guidata(figureHandle, handles);
end



function saveTrackPoint(src,evnt) %#ok<INUSL>
moveManualPoint=false;
switch(evnt.Key)
    case 'rightarrow' %move the active manual point to the right
   moveManualPoint=true;
   moveDirection=[0;1];
    case 'leftarrow' %move the active manual point to the left
   moveManualPoint=true;
   moveDirection=[0;-1];
        
    case 'uparrow' %move the active manual point up
   moveManualPoint=true;
   moveDirection=[-1;0];
        
    case 'downarrow' %move the active manual point down
   moveManualPoint=true;
   moveDirection=[1;0];
        
    otherwise
end

if moveManualPoint
         handles=guidata(src);
        [pointPosition_rc, pointPositionValid,idList] = handles.agents.manualTrackObj.getTrackletPosition_rc(handles.case.activePoint.id,[handles.case.activeFrameIdx] ,[-1;-1]);
        if ~pointPositionValid(1)
            error('Active point must be valid before using');
        else
            handles.agents.manualTrackObj.replaceVertexPoints(idList(1),pointPosition_rc(:,1)+moveDirection)
        end
        handles.agents.manualTrackObj.refreshImpointsFromActiveSkeletonVertexList;
        handles=paintFrames(handles);
        
        guidata(src, handles);
        return;
end

switch(lower(evnt.Character))
%     case 'o'
%         handles=guidata(src);
%         newPosition_cr=handles.case.roi(handles.case.activeRoi).hImPoint.getPosition;
%         
%         handles.case.roi(handles.case.activeRoi).track_rc(:,handles.case.activeFrameIdx)=flipud(newPosition_cr(:));
%         handles.case.roi(handles.case.activeRoi).trackValid(handles.case.activeFrameIdx)=true;
%         handles=paintFrames(handles);
%         guidata(src, handles);
%         return;
        
    case ' ' %This validates the position of a track by turning the circle green
        handles=guidata(src);
        [pointPosition_rc, pointPositionValid] = handles.agents.manualTrackObj.getTrackletPosition_rc(handles.case.activePoint.id,[handles.case.activeFrameIdx (handles.case.activeFrameIdx+1)] ,[-1;-1]);
        if ~pointPositionValid(1)
            error('Active point must be valid before using');
        elseif pointPositionValid(2)
            %skip and don't create again
        else
            newId=handles.agents.manualTrackObj.addSkeletonPoint(pointPosition_rc(:,1),[],handles.case.activeFrameIdx+1);
            if get(handles.chkTrackletName,'Value')==1
                trackletName=get(handles.edtTrackletName,'String');
                handles.agents.manualTrackObj.assignSkeletonPointToTracklet(newId,trackletName);
            else
                %do nothing
            end
            
            %do nothing
        end
        
        handles=paintFrames(handles);
        guidata(src, handles);
        return;
    case 'a'  %axial view using current point
        handles=guidata(src);
        currentPoint=get(handles.axesMain,'CurrentPoint');
        disp(['The selected point is ' num2str(currentPoint(1,1:2))]);
        imBlock=handles.dataBlockObj.getSlice(handles.case.frames);
        axialPoint=min(max(round(currentPoint(1,2)),1),size(imBlock,1));
        im=squeeze(imBlock(axialPoint,:,:));
        handles.case.file.ureadArgs={};
        warning('This needs to be fixed');
        if isfield(handles.dataBlockObj.metadata.ultrasound, 'rfFilename')
            sourceName = handles.dataBlockObj.metadata.ultrasound.rfFilename;
        else
            sourceName = char(handles.dataBlockObj.openMethod);
        end
        metadata={sourceName,  handles.case.file.ureadArgs,{'axial',axialPoint}};
        createCurve(im,metadata);
        return;
    case 'l'  %lateral view using current point
        handles=guidata(src);
        currentPoint=get(handles.axesMain,'CurrentPoint');
        disp(['The selected point is ' num2str(currentPoint(1,1:2))]);
        
        imBlock=handles.dataBlockObj.getSlice(handles.case.frames);
        lateralPoint=min(max(round(currentPoint(1,1)),1),size(imBlock,1));
        im=squeeze(imBlock(:,lateralPoint,:));
        handles.case.file.ureadArgs={};
        warning('This needs to be fixed');
        metadata={handles.dataBlockObj.metadata.ultrasound.rfFilename,  handles.case.file.ureadArgs,{'lateral',lateralPoint}};
        createCurve(im,metadata);
        
        return;
%     case 'b' 
%         handles=guidata(src);
%         currentPoint=get(handles.axesMain,'CurrentPoint');
%         disp(['The selected point is ' num2str(currentPoint(1,1:2))]);
%         im=squeeze(handles.case.imblockCompleteFile(:,:,handles.case.activeFrameIdx));
%         metadata={handles.case.file.fullfilename,  handles.case.file.ureadArgs,{'bmode', ...
%             handles.case.frames(handles.case.activeFrameIdx), ...
%             handles.case.imblockCompleteFile}};
%         createCurve(im,metadata);
%         return;
        
    case 'c'   %add a spline point
        handles=guidata(src);
        
        handles.agents.grid2AgentObj.addSkeletonPoint;
        
        handles.agents.grid2AgentObj.plotSkeleton;
        guidata(src, handles);
        return;
    case 'm' %add manual track point
        handles=guidata(src);
        handles.case.activePoint.id=handles.agents.manualTrackObj.addSkeletonPoint;
        
        if get(handles.chkTrackletName,'Value')==1
            trackletName=get(handles.edtTrackletName,'String');
            handles.agents.manualTrackObj.assignSkeletonPointToTracklet(handles.case.activePoint.id,trackletName);
        else
            %do nothing
        end
        
        handles.agents.manualTrackObj.plotSkeleton;
        handles=paintFrames(handles);
        
        guidata(src, handles);
        return;
    case ',' %cut the sub window
        %draw window size
        handles=guidata(src);
                
         handles.agents.manualTrackObj.refreshActiveSkeletonVertexListFromImpoints;
        [pointPosition_rc, pointPositionValid,id] = handles.agents.manualTrackObj.getTrackletPosition_rc(handles.case.activePoint.id,handles.case.activeFrameIdx,[-1;-1]);
        if length(id)~=1
            error('It is assumed there is only one track point per frame');
        else
            
        end
        disp(['showSkeletonPointTracklet id = ' num2str(id)])
            
%         idList=handles.agents.manualTrackObj.trackletFindBySkeletonId(id);
%         skeletonGetFullPosition=this.skeletonGetFullPositionById(idList);
%         
        handles.agents.manualTrackObj.showSkeletonPointTracklet([],[],id);
        guidata(src, handles);
        return;
    case '`' %Run the agent tracker
        handles=guidata(src);
                
         handles.agents.manualTrackObj.refreshActiveSkeletonVertexListFromImpoints;
        [pointPosition_rc, pointPositionValid,idList,slicePosition] = handles.agents.manualTrackObj.getTrackletPosition_rc(handles.case.activePoint.id,[],[]);
       
        agentFunc=str2func(get(handles.edtAgentFunction,'String'));
        agentFunc(handles.dataBlockObj,handles.case.activeFrameIdx,pointPosition_rc,slicePosition, pointPositionValid,idList);
        
        guidata(src, handles);
        return;        
    case 's' %sample the grid along a spline trajectory
        handles=guidata(src);
        oldPointer=get(gcf,'pointer');
        set(gcf,'pointer','watch');
        disp('Started sampling the data');
        drawnow;
        imBlock=handles.dataBlockObj.getSlice(handles.case.frames);
        
        [im,xAxis_sec,yAxis_mm,samplingSkeleton]=handles.agents.grid2AgentObj.sample(handles.dataBlockObj.metadata.ultrasound, ...
            handles.dataBlockObj.getUnitsValue('axial','mm'),handles.dataBlockObj.getUnitsValue('lateral','mm'),handles.dataBlockObj.getUnitsValue('frameRate','framePerSec'),...
            handles.dataBlockObj.openArgs,imBlock);
        set(gcf,'pointer',oldPointer);  %Use before launching another GUI because I don't want it to pickup the the hourglass cursor
        
        
        handles.configSettings.createCurveConfigSettings{end+1}='samplingSkeleton';
        handles.configSettings.createCurveConfigSettings{end+1}=samplingSkeleton;
        
        handles.configSettings.createCurveConfigSettings{end+1}='dataBlockObj';
        handles.configSettings.createCurveConfigSettings{end+1}=handles.dataBlockObj;
        
        createCurve(im,{handles.dataBlockObj.metadata.sourceFilename,  {},{'cmm',' frames', xAxis_sec,yAxis_mm}},handles.configSettings.createCurveConfigSettings);
        disp('Finished sampling the data');
        
        return;
    case 't'  %run tongue tracking active contour algorithm
        handles=guidata(src);
        oldPointer=get(gcf,'pointer');
        set(gcf,'pointer','watch');
        drawnow;
        [controlpt_pel]=handles.agents.grid2AgentObj.generateSplineControlPoints;
                
        activeContourVertices_rc=[controlpt_pel.y; controlpt_pel.x];
        trackFrameList=(handles.case.activeFrameIdx:(handles.case.activeFrameIdx+20));
        
        track=activeContourRun(handles.dataBlockObj,trackFrameList,activeContourVertices_rc);
        set(gcf,'pointer',oldPointer);
        return;
    case '1'  %copy the closest spline to the current frame
        handles=guidata(src);
        handles.agents.grid2AgentObj.replaceSkeleton('closest');
        handles.agents.grid2AgentObj.plotSkeleton;
        return;
    case '*' %copy spline to all frames except active one
        handles=guidata(src);
        oldPointer=get(gcf,'pointer');
        set(gcf,'pointer','watch');
        disp('Copying to all frames(this will take a minute).');
        drawnow;
        
        %start at one because you don't want to overwrite the current
        %active frame which is the one you want to copy,
        allframesExceptActive=setdiff(1:length(handles.case.frames),handles.case.activeFrameIdx);
        for ii=allframesExceptActive
            handles.agents.grid2AgentObj.setActiveSlice(ii);
            handles.agents.grid2AgentObj.replaceSkeleton('index',handles.case.activeFrameIdx);
        end
        
        handles.agents.grid2AgentObj.setActiveSlice(handles.case.activeFrameIdx);
        handles.agents.grid2AgentObj.plotSkeleton;
        set(gcf,'pointer',oldPointer);
        disp('Finished copying the spline.');
        return;
        
        
    case '!' %copy spline in the closest frame to all frames current + 1 to the end
        handles=guidata(src);
        oldPointer=get(gcf,'pointer');
        set(gcf,'pointer','watch');
        drawnow;
        
        %start at one because you don't want to overwrite the current
        %active frame which is the one you want to copy,
        for ii=1:(length(handles.case.frames)-handles.case.activeFrameIdx)
            handles.agents.grid2AgentObj.setActiveSlice(handles.case.activeFrameIdx+ii);
            handles.agents.grid2AgentObj.replaceSkeleton('closest');
        end
        handles.agents.grid2AgentObj.setActiveSlice(handles.case.activeFrameIdx);
        handles.agents.grid2AgentObj.plotSkeleton;
        set(gcf,'pointer',oldPointer);
        return;
        
    case '2' %Run the segmentation code
        handles=guidata(src);
        im=abs(handles.case.imblock(:,:,2)).^0.25;
        im=im(400:end,:);
        im=uint8(im/max(im(:))*255);
        imMuscleMask=FasciaSegmentation(im,5);
        figure;
        subplot(1,2,1)
        imagesc(im);
        colormap(gray(256));
        
        subplot(1,2,2)
        imagesc(imMuscleMask);
        
        return;
    case '3' %add code to mark poly regions
        handles=guidata(src);
        if ~isfield(handles,'regionSegment')
            handles.regionSegment(1).impoly=impoly(handles.axesMain);
            handles.regionSegment(1).tag='1';
        else
            handles.regionSegment(end+1).impoly=impoly(handles.axesMain);
            handles.regionSegment(end).tag=num2str(length(handles.regionSegment));
        end
        guidata(src, handles);
        return;
    case '4' %run texture analysis on marked poly regions
        handles=guidata(src);
        im=handles.case.imblock(:,:,2);
        reg1Mask=handles.regionSegment(1).impoly.createMask;
        reg1=im(reg1Mask);
        im1=im;
        im1(~reg1Mask)=0;
        
        
        reg2Mask=handles.regionSegment(2).impoly.createMask;
        reg2=im(reg2Mask);
        im2=im;
        im2(~reg2Mask)=0;
        
        [ kullbackLeibler1To2,kullbackLeibler2To1,pdf1,pdf2] = kullbackLeibler( reg1,reg2 );
        
        figure;
        subplot(2,2,1)
        imagesc(im1); colormap(gray(256));
        axis(reshape([min(handles.regionSegment(1).impoly.getPosition); max(handles.regionSegment(1).impoly.getPosition)],[],1));
        title('reg 1');
        caxis([min(im(:)) max(im(:))]);
        
        subplot(2,2,2)
        imagesc(im2); colormap(gray(256));
        axis(reshape([min(handles.regionSegment(2).impoly.getPosition); max(handles.regionSegment(2).impoly.getPosition)],[],1));
        title('reg 2');
        caxis([min(im(:)) max(im(:))]);
        
        subplot(2,2,[3 4])
        plot(pdf1,'r'); hold on; plot(pdf2,'b');
        legend('roi 1','roi 2');
        title(['kullbackLeibler1To2: ' num2str(kullbackLeibler1To2) '  kullbackLeibler2To1: ' num2str(kullbackLeibler2To1)]);
        return;
        [imOut1,imOut2]=corrMask( im,reg1Mask);
        figure;
        subplot(1,2,1)
        imagesc(imOut1); colorbar
        subplot(1,2,2)
        imagesc(imOut2); colorbar
        
        return;
    case 'j'
        handles=guidata(src);
        newFrame=inputdlg('Enter frame to jump to:','Jump to Frame');
        gotoFrame(src, [], handles,str2num(newFrame{1}));
        return
    case 'f'  %show feature track
        handles=guidata(src);    
        handles.trackingAnalysis.showFeature(handles.case.activeFrameIdx,false)
        handles.trackingAnalysis.showHist(handles.case.activeFrameIdx,false)
    otherwise
        return;
end

end

% --- Outputs from this function are returned to the command line.
function varargout = agentLab_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in btnPreviousFrame.
function gotoFrame(hObject, eventdata, handles,newFrame)
% hObject    handle to btnPreviousFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frameChange=false;
if (newFrame-1) >= 1
    handles.case.activeFrameIdx=newFrame;
    frameChange=true;
    handles.case.imblock(:,:,:)=handles.dataBlockObj.getSlice((handles.case.activeFrameIdx-1):(handles.case.activeFrameIdx+1),[],handles.case.activeProcessStreamName);
    
elseif (handles.case.activeFrameIdx-1) == 1  %handle the case when the current frame will now be the first
    error('need to handle this')
    handles.case.activeFrameIdx=(handles.case.activeFrameIdx-1);
    frameChange=true;
    if handles.case.activeFrameIdx~=1
        error('Invalid active frame');
    end
    
    handles.case.imblock(:,:,2:3)=handles.case.imblock(:,:,1:2);
    handles.case.imblock(:,:,1)=0;
else
    error('need to handle this')
    %Frame should not change since it must be the first frame

end


if frameChange 
    %Find the new active frame id
  [pointPosition_rc, pointPositionValid,id] = handles.agents.manualTrackObj.getTrackletPositionInSlice_rc(get(handles.edtTrackletName,'String'),handles.case.activeFrameIdx,[-1;-1]);
  if pointPositionValid
      if length(id)~=1
          error('id must have a lenght of 1');
      else
        handles.case.activePoint.id=id;
      end
  else
      handles.case.activePoint.id=[];
  end
else
    %do nothing
end


handles=paintFrames(handles);

% Update handles structure
guidata(hObject, handles);
end


% --- Executes on button press in btnPreviousFrame.
function btnPreviousFrame_Callback(hObject, eventdata, handles)
% hObject    handle to btnPreviousFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frameChange=false;
if (handles.case.activeFrameIdx-2) >= 1
    handles.case.activeFrameIdx=(handles.case.activeFrameIdx-1);
    frameChange=true;
        
    handles.case.imblock(:,:,2:3)=handles.case.imblock(:,:,1:2);
    %handles.case.imblock(:,:,1)=uread(handles.case.file.fullfilename,,handles.case.file.ureadArgs{:});
    
    
    %don't load the current frame, but the previous frame to show in the
    %bottom preview
    handles.case.imblock(:,:,1)=handles.dataBlockObj.getSlice(handles.case.activeFrameIdx-1,[],handles.case.activeProcessStreamName);
    
elseif (handles.case.activeFrameIdx-1) == 1  %handle the case when the current frame will now be the first
    handles.case.activeFrameIdx=(handles.case.activeFrameIdx-1);
    frameChange=true;
    if handles.case.activeFrameIdx~=1
        error('Invalid active frame');
    end
    
    handles.case.imblock(:,:,2:3)=handles.case.imblock(:,:,1:2);
    handles.case.imblock(:,:,1)=0;
else
    
    %Frame should not change since it must be the first frame

end


if frameChange 
    %Find the new active frame id
  [pointPosition_rc, pointPositionValid,id] = handles.agents.manualTrackObj.getTrackletPositionInSlice_rc(get(handles.edtTrackletName,'String'),handles.case.activeFrameIdx,[-1;-1]);
  if pointPositionValid
      if length(id)~=1
          error('id must have a lenght of 1');
      else
        handles.case.activePoint.id=id;
      end
  else
      handles.case.activePoint.id=[];
  end
else
    %do nothing
end


handles=paintFrames(handles);

% Update handles structure
guidata(hObject, handles);
end

% --- Executes on button press in btnNextFrame.
function btnNextFrame_Callback(hObject, eventdata, handles)
% hObject    handle to btnNextFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frameChange=false;
if (handles.case.activeFrameIdx+2) <= length(handles.case.frames)
    handles.case.activeFrameIdx=(handles.case.activeFrameIdx+1);
    frameChange=true;
    
    handles.case.imblock(:,:,1:2)=handles.case.imblock(:,:,2:3);
    
    %don't load the current frame, but the next frame to show in the
    %bottom preview
    handles.case.imblock(:,:,3)=handles.dataBlockObj.getSlice(handles.case.activeFrameIdx+1,[],handles.case.activeProcessStreamName);
    
elseif (handles.case.activeFrameIdx+1) == length(handles.case.frames)
    
    handles.case.activeFrameIdx=(handles.case.activeFrameIdx+1);
    frameChange=true;
    if handles.case.activeFrameIdx~=length(handles.case.frames)
        error('Invalid active frame');
    end
    
    handles.case.imblock(:,:,1:2)=handles.case.imblock(:,:,2:3);
    handles.case.imblock(:,:,3)=0;
else
        
    %do nothing
end

if frameChange
    %Find the new active frame id
  [pointPosition_rc, pointPositionValid,id] = handles.agents.manualTrackObj.getTrackletPositionInSlice_rc(get(handles.edtTrackletName,'String'),handles.case.activeFrameIdx,[-1;-1]);
  if pointPositionValid
      if length(id)~=1
          error('id must have a lenght of 1');
      else
        handles.case.activePoint.id=id;
      end
  else
      handles.case.activePoint.id=[];
  end
else
    %do nothing
end


handles=paintFrames(handles);
% Update handles structure
guidata(hObject, handles);

end

% --- Executes on button press in btnSetZoom.
function btnSetZoom_Callback(hObject, eventdata, handles)
% hObject    handle to btnSetZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axis(handles.axesMain,str2num(get(handles.editZoom,'String')));

end


% --- Executes on button press in btnResetZoom.
function btnResetZoom_Callback(hObject, eventdata, handles)
% hObject    handle to btnResetZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.editZoom,'String',['[ 1 ' num2str(size(handles.case.imblock,2)) ' 1 ' num2str(size(handles.case.imblock,1)) ']'])
axis(handles.axesMain,str2num(get(handles.editZoom,'String')));
end

% --- Executes on button press in btnSaveTrack.
function btnSaveTrack_Callback(hObject, eventdata, handles)
% hObject    handle to btnSaveTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[~,baseName]=fileparts(handles.case.file.fullfilename);
matFilename=[baseName '.mat'];
save(matFilename,'handles');
disp([matFilename ' was saved.' ] )
end

% --- Executes on button press in btnSetTrack.
function btnSetTrack_Callback(hObject, eventdata, handles)
% hObject    handle to btnSetTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newPosition_cr=handles.case.roi(handles.case.activeRoi).hImPoint.getPosition;
handles.case.roi(handles.case.activeRoi).track_rc=repmat(flipud(newPosition_cr(:)),1,length(handles.case.roi(handles.case.activeRoi).track_rc));
handles=paintFrames(handles);
guidata(hObject, handles);

%handles.case.roi(handles.case.activeRoi).track_rc=zeros(2,length(handles.case.frames));
end

%Paint frames assumes all of the data loaded is correct
function handles=paintFrames(handles)


frameList=[(handles.case.activeFrameIdx-1) handles.case.activeFrameIdx (handles.case.activeFrameIdx+1)];

imDisplay=handles.case.imblock;
handles.agents.grid2AgentObj.setActiveSlice(handles.case.activeFrameIdx);
handles.agents.manualTrackObj.setActiveSlice(handles.case.activeFrameIdx);

imMain=imDisplay(:,:,2);

set(handles.figAgentLab,'currentAxes',handles.axesMain);
%The objective is to 
isImageHandle=(arrayfun(@(x) strcmp(get(x,'Type'),'image'),get(handles.axesMain,'Children')));
if ~any(isImageHandle)
    imagesc(imMain,'Parent',handles.axesMain);
    colormap(gray(256));
else
    if sum(isImageHandle)~=1
        error('Only one image object supported')
    end
    childrenList=get(handles.axesMain,'Children');
    set(childrenList(isImageHandle),'CData',imMain)
end

axis(handles.axesMain,str2num(get(handles.editZoom,'String')));
set(handles.textMain,'String',[handles.dataBlockObj.activeCaseName]);

framesToUseForPlot=min(max(frameList,1),length(handles.case.frames));
markerLookup='rg'; %if false then yellow if true then red
%get tracklet list  
[pointPosition_rc, pointPositionValid,idList,slicePosition] = handles.agents.manualTrackObj.getTrackletPosition_rc(handles.case.activePoint.id,framesToUseForPlot,[size(imMain,1)/2; size(imMain,2)/2]);
if ~all(slicePosition==framesToUseForPlot)
    error('Slice numbers should match')
end

markerColor=markerLookup(pointPositionValid+1);
if pointPositionValid(2)==true
    pointPosition_rc(:,~pointPositionValid)=repmat(pointPosition_rc(:,2),1,sum(~pointPositionValid));
else
    %leave it with the default because there is no valid track in the
    %center
end

winAdjust=kron(flipud(pointPosition_rc),[1 1]');
smallWindow=str2num(get(handles.editSmallWindow,'String'));


set(handles.figAgentLab,'currentAxes',handles.axesPrevious);
set(handles.textPrevious,'String',['Frame Idx=' num2str(frameList(1))]);
imagesc(imDisplay(:,:,1),'Parent',handles.axesPrevious);
set(handles.axesPrevious,'NextPlot','add');
axis(handles.axesPrevious,smallWindow+winAdjust(:,1)');
plot(handles.axesPrevious,pointPosition_rc(2,1),pointPosition_rc(1,1),[ markerColor(1) 'o'],'MarkerSize',12,'LineWidth',2);
set(handles.axesPrevious,'NextPlot','replace');

set(handles.figAgentLab,'currentAxes',handles.axesCurrent);
set(handles.textCurrent,'String',['Frame Idx=' num2str(frameList(2))]);
imagesc(imDisplay(:,:,2),'Parent',handles.axesCurrent);
set(handles.axesCurrent,'NextPlot','add');
axis(handles.axesCurrent,smallWindow+winAdjust(:,2)');
plot(handles.axesCurrent,pointPosition_rc(2,2),pointPosition_rc(1,2),[ markerColor(2) 'o'],'MarkerSize',12,'LineWidth',2);
set(handles.axesCurrent,'NextPlot','replace');

set(handles.figAgentLab,'currentAxes',handles.axesNext);
set(handles.textNext,'String',['Frame Idx=' num2str(frameList(3))]);
imagesc(imDisplay(:,:,3),'Parent',handles.axesNext);
set(handles.axesNext,'NextPlot','add');
axis(handles.axesNext,smallWindow+winAdjust(:,3)');
plot(handles.axesNext,pointPosition_rc(2,3),pointPosition_rc(1,3),[ markerColor(3) 'o'],'MarkerSize',12,'LineWidth',2);
set(handles.axesNext,'NextPlot','replace');


handles.agents.grid2AgentObj.plotSkeleton;
handles.agents.manualTrackObj.plotSkeleton;

end


% --- Executes on button press in btnHelp.
function btnHelp_Callback(hObject, eventdata, handles)
% hObject    handle to btnHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mfilePath]=fileparts(mfilename('fullpath'));
web(['file://' strrep(fullfile(mfilePath,'private','agentLab.htm'),'\','/')],'-new','-notoolbar')
end


%This function will allow the user to open an, rf, b8 file, or case data
%and then package all the information for the GUI
function dataBlockObj=userOpenFile()        
        
casefolderPath=pwd;  %this could be a saved directory
        
        if exist(casefolderPath,'dir')
            [filename pathname] = uigetfile({'*.*','Case Files (*.m)';'*.rf','RF Files (*.rf)';...
          '*.b8','Bmode Files (*.b8)'; '*.*','All Files (*.*)' },'Pick a case file',casefolderPath);
        else            
            [filename pathname] = uigetfile({'*.*','Case Files (*.m)';'*.rf','RF Files (*.rf)';...
          '*.b8','Bmode Files (*.b8)'; '*.*','All Files (*.*)' },'Pick a case file');
        end
        
        if ~ischar(filename) || ~ischar(pathname)
            disp('Canceling file selection.')
            caseData=[];
            return;
        else
            caseData = fullfile(pathname, filename);    
        end
        
         [~,~,filenameExt] = fileparts(filename);
         switch(lower(filenameExt))
             case '.b8'
                 
                 xmlFiles=dirPlus(fullfile(pathname,'*.xml'));
                 
                 
                 % Import the XPath classes
                 import javax.xml.xpath.*
                 
                 % Construct the DOM.
                 for ii=1:length(xmlFiles)
                 doc = xmlread(xmlFiles{ii});
                 
                 % Create an XPath expression.
                 factory = XPathFactory.newInstance;
                 xpath = factory.newXPath;
                 expression = xpath.compile('/object/regions/region[@name="B"]/DeltaPerPixelX');
                 
                 % Apply the expression to the DOM.
                 nodeList = expression.evaluate(doc,XPathConstants.NODESET);
                 
                 if nodeList.getLength==1
                     node = nodeList.item(1-1);
                     disp(char(node.getFirstChild.getNodeValue))
                     scale_mm=str2num(char(node.getFirstChild.getNodeValue))*1e-3;
                     warning('Fix for y scale');
                     break;
                 elseif nodeList.getLength==0
                     continue;
                 else
                     for i = 1:nodeList.getLength
                     end
                     error('should not happen.');
                 end
                 end
      
                
%  <DeltaPerPixelX unit="µm">108.000000</DeltaPerPixelX>
%       <DeltaPerPixelY unit="µm">108.000000</DeltaPerPixelY>                
                dataBlockObjMetadata.scale.lateral.value=scale_mm;
                dataBlockObjMetadata.scale.lateral.units='mm';
                dataBlockObjMetadata.scale.axial.value=scale_mm;
                dataBlockObjMetadata.scale.axial.units='mm';
                
                openArgs={'frameFormatComplex',false};
                dataBlockObj=DataBlockObj(caseData,@uread,'openArgs',openArgs);
                dataBlockObj.open('cacheMethod','all');
                processFunction=@(x) x;
                dataBlockObj.newProcessStream('agentLab',processFunction, true);                    
             case '.rf'
                 openArgs={'frameFormatComplex',true};
                 dataBlockObj=DataBlockObj(caseData,@uread,'openArgs',openArgs);
                 dataBlockObj.open('cacheMethod','all');
                processFunction=@(x) abs(x).^0.5;
                dataBlockObj.newProcessStream('agentLab',processFunction, true);   
             case '.m'
                 
             otherwise
                 error(['Unsupport ext of ' filenameExt]);
         end        

end


% --- Executes on button press in btnSplineShow.
function btnSplineShow_Callback(hObject, eventdata, handles)
% hObject    handle to btnSplineShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('The spline control points are:');
%this is the form we want them in:
% agent.vpt=[331.7795 356.9900 375.2459 388.2858;
%            10.7850 232.0100 472.8049 603.8382];
%            10.7850 232.0100 472.8049 603.8382];
strOut=['agent.vpt=[' num2str(handles.agents.grid2AgentObj.generateSplineControlPoints.y) ';' 10 ...
'             ' num2str(handles.agents.grid2AgentObj.generateSplineControlPoints.x)  '];'];
disp(strOut);
%handles.agents.grid2AgentObj.generateSplineControlPoints

end


% --- Executes during object deletion, before destroying properties.
function figAgentLab_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figAgentLab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.agentManager);
end
