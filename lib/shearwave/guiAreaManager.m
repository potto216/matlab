
function varargout = guiAreaManager(varargin)
% GUIAREAMANAGER MATLAB code for guiAreaManager.fig
%      GUIAREAMANAGER, by itself, creates a new GUIAREAMANAGER or raises the existing
%      singleton*.
%
%      H = GUIAREAMANAGER returns the handle to a new GUIAREAMANAGER or the handle to
%      the existing singleton*.
%
%      GUIAREAMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIAREAMANAGER.M with the given input arguments.
%
%      GUIAREAMANAGER('Property','Value',...) creates a new GUIAREAMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiAreaManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiAreaManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiAreaManager

% Last Modified by GUIDE v2.5 11-Nov-2011 15:35:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiAreaManager_OpeningFcn, ...
    'gui_OutputFcn',  @guiAreaManager_OutputFcn, ...
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

% --- Executes just before guiAreaManager is made visible.
function guiAreaManager_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiAreaManager (see VARARGIN)

% Choose default command line output for guiAreaManager
handles.output = hObject;

handles.area=struct([]);
handles=roiSetup(handles);


handles.areaTypes.background='Background';
handles.areaTypes.triggerPoint='Trigger Point';
set(handles.lstAreaObjectList,'String','')
set(handles.popAreaObjectType,'String',{handles.areaTypes.background,handles.areaTypes.triggerPoint})
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiAreaManager wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = guiAreaManager_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on selection change in lstAreaObjectList.  Does not need to
% update the handles struct
function lstAreaObjectList_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to lstAreaObjectList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstAreaObjectList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstAreaObjectList

newIndex=find(strcmp(get(handles.popAreaObjectType,'String'),handles.area(get(handles.lstAreaObjectList,'Value')).type));
if length(newIndex)~=1
    error('Only one index should be there')
end
set(handles.popAreaObjectType,'Value',newIndex);
end


% --- Executes on selection change in popAreaObjectType.
function popAreaObjectType_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to popAreaObjectType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popAreaObjectType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popAreaObjectType

activeIndex=get(hObject,'Value');
activeObjIndex=get(handles.lstAreaObjectList,'Value');
contents = cellstr(get(hObject,'String'));
handles.area(activeObjIndex).type=contents{activeIndex};

setObjectColor(handles,activeObjIndex);

guidata(hObject,handles);
end


% --- Executes on selection change in lstAreaObjectList.
function addAreaObject_Callback(hObject, eventdata, handles, areaObjList,dataFigureHandle) %#ok<DEFNU,INUSL>
% hObject    handle to lstAreaObjectList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstAreaObjectList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstAreaObjectList

%add a new imroi object with clones across open figures
if isa(areaObjList,'imroi')
    handles.area(end+1).obj(1)=areaObjList;
elseif isa(areaObjList,'cell')
    idxArea=length(handles.area)+1;
    for ii=1:length(areaObjList)
        handles.area(idxArea).obj(ii)=areaObjList{ii};
    end
else
    error(['Unsupported object list class of ' class(areaObjList)]);
end

if length(handles.area)==1
    handles.area(end).type=handles.areaTypes.background;
else
    handles.area(end).type=handles.areaTypes.triggerPoint;
end

handles.area(end).dataFigureHandle=dataFigureHandle;

setObjectColor(handles,length(handles.area));

addListboxString(handles.lstAreaObjectList,['[' num2str(round(handles.area(end).obj(1).getPosition)) ']'],length(handles.area));

set(handles.lstAreaObjectList,'Value',length(handles.area));
guidata(handles.figure1,handles);

lstAreaObjectList_Callback(handles.lstAreaObjectList, [], handles);

for ii=1:length(handles.area(end).obj)
    handles.area(end).obj(ii).addNewPositionCallback(@(roi) updateAreaObjectData(handles.lstAreaObjectList,length(handles.area),ii,roi));
end
end



% --- Executes on button press in btnDeleteAreaObject.
function btnDeleteAreaObject_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to btnDeleteAreaObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
activeObjIndex=get(handles.lstAreaObjectList,'Value');

for ii=1:length(handles.area(activeObjIndex).obj)
    handles.area(activeObjIndex).obj(ii).delete;
end

handles.area(activeObjIndex)=[];

areaObjectList=get(handles.lstAreaObjectList,'String');
areaObjectList(activeObjIndex)=[];
set(handles.lstAreaObjectList,'Value',max(activeObjIndex-1,1));
set(handles.lstAreaObjectList,'String',areaObjectList);
guidata(hObject,handles)
end



function setObjectColor(handles,activeObjIndex)

switch(handles.area(activeObjIndex).type)
    case handles.areaTypes.background
        objectColor='k';
    case handles.areaTypes.triggerPoint
        objectColor='r';
    otherwise
        error(['Unsupported area of ' handles.area(activeObjIndex).type])
end

for ii=1:length(handles.area(activeObjIndex).obj)
    handles.area(activeObjIndex).obj(ii).setColor(objectColor);
end
end


function updateAreaObjectData(lstAreaObjectList,objectIndex,objectListIndex,newRoi)
handles=guidata(lstAreaObjectList);
addListboxString(handles.lstAreaObjectList,['[' num2str(round(newRoi)) ']'],objectIndex);
%update all of the other rois to the same size
for ii=1:length(handles.area(end).obj)
    if ii~=objectListIndex
        handles.area(objectIndex).obj(ii).setPosition(newRoi);
    end
end
end

function handles=roiSetup(handles)
handles.roi.array=struct([]);
handles.roi.axesHandleList=[];
handles.roi.arrayRoiIdx=1;  %the row
handles.roi.arrayAxesHandleIdx=2; %the column
end

%This function adds an roi object and copies it to all windows.
%It also sets the callback function to make sure all other windows will be
%updated when one moves.
function addImroi(handles,imRoi,axesHandle,type) %#ok<DEFNU>
if handles.roi.arrayRoiIdx~=1 && handles.roi.arrayAxesHandleIdx~=2
    error('Indexes not set correctly.');
end

if length(handles.axesHandleList)<1
    error('You cannot call this function unless an axes has been added first.')
else
    %do nothing
end

if length(find(axesHandle~=handles.roi.axesHandleList))~=1
    error('The axes with the new object must have first been registered with addAxes.');
else
    %do nothing
end

axesHandleListToAddImroiIndex=find(handles.roi.axesHandleList~=axesHandle);
axesHandleIndex=find(handles.roi.axesHandleList==axesHandle);
if length(axesHandleIndex)~=1
    error('multiple axes found.');
else
    %do nothing
end

newRoiIndex=size(handles.roi.array,handles.roi.arrayRoiIdx)+1;
%add the new object to all of the axes
for ii=axesHandleListToAddImroiIndex
    switch(class(imRoi))
        case 'imrect'
            handles.roi.array(newRoiIndex,ii).imroi=imrect(axesHandle,handles.roi.array(newRoiIndex,newRoiIndex).imroi.getPosition);
        case 'imellipse'
            handles.roi.array(newRoiIndex,ii).imroi=imellipse(axesHandle,handles.roi.array(newRoiIndex,newRoiIndex).imroi.getPosition);
        otherwise
            error(['Unsupported class of ' class(handles.roi.array(ii,newRoiIndex).imroi)])
    end
    handles.roi.array(newRoiIndex,ii).imroi.setColor(handles.roi.array(newRoiIndex,ii).imroi.getColor);
    handles.roi.array(newRoiIndex,ii).type=type;    
    handles.roi.array(newRoiIndex,ii).imroi.addNewPositionCallback(@(roi) updateRoiArrayNewPosition(handles.lstAreaObjectList,roi));
  
    
end

end

function updateRoiArrayNewPosition(lstAreaObjectList,newRoi)
handles=guidata(lstAreaObjectList);
addListboxString(handles.lstAreaObjectList,['[' num2str(round(newRoi)) ']'],objectIndex);
%update all of the other rois to the same size
for ii=1:length(handles.area(end).obj)
    if ii~=objectListIndex
        handles.area(objectIndex).obj(ii).setPosition(newRoi);
    end
end
end


%This function removes an roi from all open windows
function removeImroi(handles,imRoi) %#ok<DEFNU>
end

%This function adds an axes handle to the list and copies all rois to it
function addAxes(handles,axesHandle) %#ok<DEFNU>

if ~ishandle(axesHandle) || ~strcmp(get(axesHandle,'Type'),'axes')
    error('axesHandle is not an axes object.');
end

if handles.roi.arrayRoiIdx~=1 && handles.roi.arrayAxesHandleIdx~=2
    error('Indexes not set correctly.');
end

if any(axesHandle==handles.roi.axesHandleList)
    if sum(axesHandle==handles.roi.axesHandleList)~=1
        error(['There should only be one axesHandle with the id ' num2str(axesHandle)]);
    else
        warning(['Axes handle ' num2str(axesHandle) ' already exists.']);
        return;
    end
else
    %continue
end
handles.roi.axesHandleList(end+1)=axesHandle;

if ~isempty(handles.roi.array)
    newAxesHandleIdx=size(handles.roi.array,handles.roi.arrayAxesHandleIdx)+1;
    for ii=1:size(handles.roi.array,handles.roi.arrayRoiIdx)
        switch(class(handles.roi.array(ii,1).imroi))
            case 'imrect'
                handles.roi.array(ii,newAxesHandleIdx).imroi=imrect(axesHandle,handles.roi.array(ii,1).imroi.getPosition);
            case 'imellipse'
                handles.roi.array(ii,newAxesHandleIdx).imroi=imellipse(axesHandle,handles.roi.array(ii,1).imroi.getPosition);
            otherwise
                error(['Unsupported class of ' class(handles.roi.array(ii,1).imroi)])
        end
        handles.roi.array(ii,newAxesHandleIdx).imroi.setColor(handles.roi.array(ii,1).imroi.getColor);
        handles.roi.array(ii,newAxesHandleIdx).type=handles.roi.array(ii,1).type;
    end
else
    %don't add until an roi object is available
end
end

%This function removes an axes handle to the list and deletes all rois associated with it
function removeAxes(handles,axesHandle) %#ok<DEFNU>
end

function addListboxString(hListbox,string,index)

stringList=get(hListbox,'String');
stringList{index}=string;
set(hListbox,'String',stringList);
end

% --- Executes on button press in btnUpdateCalculation.
function btnUpdateCalculation_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to btnUpdateCalculation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[imTriggerPositiveVelocity,imTriggerNegativeVelocity,imBackPositiveVelocity,imBackNegativeVelocity]=calcMtrpData(handles);




figure;
subplot(3,2,1); imagesc(imTriggerPositiveVelocity);  caxis([-10 10]);
title('Trigger Point')
colorbar;

subplot(3,2,2); imagesc(imBackPositiveVelocity); caxis([-10 10]);
title('Background')
colorbar;


subplot(3,2,3); hist(imTriggerPositiveVelocity(~isinf(imTriggerPositiveVelocity)),101);
title(['+ Avg speed: ' num2str(mean(imTriggerPositiveVelocity(~isinf(imTriggerPositiveVelocity))),'%3.2f') 'm/s. Std is ' num2str(std(imTriggerPositiveVelocity(~isinf(imTriggerPositiveVelocity))),'%3.2f')])
xlabel('m/s')

subplot(3,2,4); hist(imBackPositiveVelocity(~isinf(imBackPositiveVelocity)),101)
title(['+ Avg speed: ' num2str(mean(imBackPositiveVelocity(~isinf(imBackPositiveVelocity))),'%3.2f') 'm/s. Std is ' num2str(std(imBackPositiveVelocity(~isinf(imBackPositiveVelocity))),'%3.2f')])
xlabel('m/s')


subplot(3,2,5); hist(imTriggerNegativeVelocity(~isinf(imTriggerNegativeVelocity)),101);
title(['- Avg speed: ' num2str(mean(imTriggerNegativeVelocity(~isinf(imTriggerNegativeVelocity))),'%3.2f') 'm/s. Std is ' num2str(std(imTriggerNegativeVelocity(~isinf(imTriggerNegativeVelocity))),'%3.2f')])
xlabel('m/s')

subplot(3,2,6); hist(imBackNegativeVelocity(~isinf(imBackNegativeVelocity)),101)
title(['- Avg speed: ' num2str(mean(imBackNegativeVelocity(~isinf(imBackNegativeVelocity))),'%3.2f') 'm/s. Std is ' num2str(std(imBackNegativeVelocity(~isinf(imBackNegativeVelocity))),'%3.2f')])
xlabel('m/s')

% tdata=imTrigger(~isinf(imTrigger));
% hdata=hist(tdata,101);

% hdata=hdata/sum(hdata);
% xax=linspace(min(tdata),max(tdata),length(hdata));
% figure; subplot(1,2,1)
% plot(xax,hdata); title(['pdf'])
% hold on;
% xr=xlim;
% xd=linspace(xr(1),xr(2),100);
% gs=std(tdata);
% gm=mean(tdata);
%
% plot(xd,normpdf(xd,gm,gs),'g');
% %plot(xd,1/(sqrt(2*pi)*gs)*exp(-(xd-gm).^2/(2*gs^2)),'g');
% legend('data pdf','gaussian')
% subplot(1,2,2)
% plot(xax,cumsum(hdata)); title(['cdf'])


%subplot(2,2,3); imagesc(imTriggerRsq);   subplot(2,2,4); imagesc(imBackRsq);
end

% --- Executes on button press in btnSaveMeasurements.
function btnSaveMeasurements_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to btnSaveMeasurements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[imTriggerPositiveVelocity,imTriggerNegativeVelocity,imBackPositiveVelocity,imBackNegativeVelocity,measurements,dataStore]=calcMtrpData(handles); %#ok<ASGLU>



f1=figure;
subplot(3,2,1); imagesc(imTriggerPositiveVelocity);  caxis([-10 10]);
title('Trigger Point')
colorbar;

subplot(3,2,2); imagesc(imBackPositiveVelocity); caxis([-10 10]);
title('Background')
colorbar;


subplot(3,2,3); hist(imTriggerPositiveVelocity(~isinf(imTriggerPositiveVelocity)),101);
title(['+ Avg speed: ' num2str(mean(imTriggerPositiveVelocity(~isinf(imTriggerPositiveVelocity))),'%3.2f') 'm/s. Std is ' num2str(std(imTriggerPositiveVelocity(~isinf(imTriggerPositiveVelocity))),'%3.2f')])
xlabel('m/s')

subplot(3,2,4); hist(imBackPositiveVelocity(~isinf(imBackPositiveVelocity)),101)
title(['+ Avg speed: ' num2str(mean(imBackPositiveVelocity(~isinf(imBackPositiveVelocity))),'%3.2f') 'm/s. Std is ' num2str(std(imBackPositiveVelocity(~isinf(imBackPositiveVelocity))),'%3.2f')])
xlabel('m/s')


subplot(3,2,5); hist(imTriggerNegativeVelocity(~isinf(imTriggerNegativeVelocity)),101);
title(['- Avg speed: ' num2str(mean(imTriggerNegativeVelocity(~isinf(imTriggerNegativeVelocity))),'%3.2f') 'm/s. Std is ' num2str(std(imTriggerNegativeVelocity(~isinf(imTriggerNegativeVelocity))),'%3.2f')])
xlabel('m/s')

subplot(3,2,6); hist(imBackNegativeVelocity(~isinf(imBackNegativeVelocity)),101)
title(['- Avg speed: ' num2str(mean(imBackNegativeVelocity(~isinf(imBackNegativeVelocity))),'%3.2f') 'm/s. Std is ' num2str(std(imBackNegativeVelocity(~isinf(imBackNegativeVelocity))),'%3.2f')])
xlabel('m/s')

basefilename=dataStore.data.caseStr;
fileList=dir([basefilename '*.mat']);
if ~isempty(fileList)
    newFileIndex=max(cellfun(@(x) str2num(x((end-length('.mat')-2):(end-length('.mat')))),{fileList(:).name},'UniformOutput',true))+1; %#ok<ST2NM>
else
    newFileIndex=1;
end

fileTag=inputdlg('Enter file tag.','File tag',1,{num2str(newFileIndex,'%03d')});
%uiwait(

saveFilename=[basefilename '_' fileTag{1} '.mat'];
% dataStore=[];
% dataStore.data=dataHandle.data;
% dataStore.data.displayFcn=[];
%
% dataStore.swObjSnapshot.rsqThreshold=dataHandle.swObj.rsqThreshold;
% dataStore.swObjSnapshot.blockFrameList_base0=dataHandle.swObj.blockFrameList_base0;
% dataStore.swObjSnapshot.temporalFrequency_Hz=dataHandle.swObj.temporalFrequency_Hz;
% dataStore.swObjSnapshot.sampleFs_Hz=dataHandle.swObj.sampleFs_Hz;
% dataStore.swObjSnapshot.frameFs_Hz=dataHandle.swObj.frameFs_Hz;
% dataStore.swObjSnapshot.shearwaveCorrectionMap_rad=dataHandle.swObj.shearwaveCorrectionMap_rad;
% dataStore.swObjSnapshot.useShearwaveCorrection=dataHandle.swObj.useShearwaveCorrection;
% dataStore.swObjSnapshot.shearwaveRunLength=dataHandle.swObj.shearwaveRunLength;
% dataStore.swObjSnapshot.lateralStep_mm=dataHandle.swObj.lateralStep_mm;
% dataStore.swObjSnapshot.axialStep_mm=dataHandle.swObj.axialStep_mm;
% dataStore.svnversion='467';
set(f1,'Name',saveFilename);

save(saveFilename,'imTriggerPositiveVelocity','imTriggerNegativeVelocity','imBackPositiveVelocity','imBackNegativeVelocity','measurements','dataStore')
end


%INPUT
%handles - the handles struct
%
%OUTPUT
%imTrigger - image of the trigger points
%imBack - image of the background
%measurements - variance, mean, and temporal freq
%dataStore - extra data from the run
function [imTriggerPositiveVelocity,imTriggerNegativeVelocity,imBackPositiveVelocity,imBackNegativeVelocity,measurements,dataStore]=calcMtrpData(handles)
isTriggerPoint = arrayfun(@(idx) strcmp(handles.areaTypes.triggerPoint,handles.area(idx).type),(1:length(handles.area)));
triggerPointIdx=find(isTriggerPoint);
backgroundIdx=find(~isTriggerPoint);

if length(backgroundIdx)~=1
    error('There must be only one background roi');
end
backgroundMask=handles.area(backgroundIdx).obj(1).createMask;
triggerPointMask=false(size(backgroundMask));

for ii=triggerPointIdx
    triggerPointMask=or(triggerPointMask,handles.area(ii).obj(1).createMask);
end

length(handles.area)
dataFigureHandle=handles.area(1).dataFigureHandle;
dataHandle=guidata(dataFigureHandle);

ShearwaveSpeed_mPerSec=get(dataHandle.hShearwaveSpeed,'CData');
ShearwaveSpeedPositiveVelocity_mPerSec=ShearwaveSpeed_mPerSec;
ShearwaveSpeedNegativeVelocity_mPerSec=ShearwaveSpeed_mPerSec;

ShearwaveSpeedPositiveVelocity_mPerSec(ShearwaveSpeed_mPerSec<0)=-inf;
ShearwaveSpeedNegativeVelocity_mPerSec(ShearwaveSpeed_mPerSec>0)=-inf;

imTriggerPositiveVelocity=-inf(size(ShearwaveSpeed_mPerSec));
imTriggerPositiveVelocity(triggerPointMask)=ShearwaveSpeedPositiveVelocity_mPerSec(triggerPointMask);

imTriggerNegativeVelocity=-inf(size(ShearwaveSpeed_mPerSec));
imTriggerNegativeVelocity(triggerPointMask)=ShearwaveSpeedNegativeVelocity_mPerSec(triggerPointMask);


imBack=-inf(size(ShearwaveSpeed_mPerSec));
backgroundKeepIdx=setdiff(find(backgroundMask),(intersect(find(backgroundMask),find(triggerPointMask))));


imBackPositiveVelocity=imBack;
imBackNegativeVelocity=imBack;

imBackPositiveVelocity(backgroundKeepIdx)=ShearwaveSpeedPositiveVelocity_mPerSec(backgroundKeepIdx);
imBackNegativeVelocity(backgroundKeepIdx)=ShearwaveSpeedNegativeVelocity_mPerSec(backgroundKeepIdx);

measurements.trigger.positiveVelocity.mean=mean(imTriggerPositiveVelocity(~isinf(imTriggerPositiveVelocity)));
measurements.trigger.positiveVelocity.std=std(imTriggerPositiveVelocity(~isinf(imTriggerPositiveVelocity)));
measurements.background.positiveVelocity.mean=mean(imBackPositiveVelocity(~isinf(imBackPositiveVelocity)));
measurements.background.positiveVelocity.std=std(imBackPositiveVelocity(~isinf(imBackPositiveVelocity)));

measurements.trigger.negativeVelocity.mean=mean(imTriggerNegativeVelocity(~isinf(imTriggerNegativeVelocity)));
measurements.trigger.negativeVelocity.std=std(imTriggerNegativeVelocity(~isinf(imTriggerNegativeVelocity)));
measurements.background.negativeVelocity.mean=mean(imBackNegativeVelocity(~isinf(imBackNegativeVelocity)));
measurements.background.negativeVelocity.std=std(imBackNegativeVelocity(~isinf(imBackNegativeVelocity)));

measurements.temporalFrequency_Hz=dataHandle.swObj.temporalFrequency_Hz;

dataStore=[];
dataStore.data=dataHandle.data;
dataStore.data.displayFcn=[];  %remove this function to keep the data structure from getting too large.

dataStore.swObjSnapshot.rsqThreshold=dataHandle.swObj.rsqThreshold;
dataStore.swObjSnapshot.rsqThreshold=dataHandle.swObj.rsqThreshold;
dataStore.swObjSnapshot.blockFrameList_base0=dataHandle.swObj.blockFrameList_base0;
dataStore.swObjSnapshot.temporalFrequency_Hz=dataHandle.swObj.temporalFrequency_Hz;
dataStore.swObjSnapshot.sampleRate_Hz=dataHandle.swObj.caseObj.sampleRate_Hz;
dataStore.swObjSnapshot.frameRate_Hz=dataHandle.swObj.caseObj.frameRate_Hz;
dataStore.swObjSnapshot.shearwaveCorrectionMap_rad=dataHandle.swObj.shearwaveCorrectionMap_rad;
dataStore.swObjSnapshot.useShearwaveCorrection=dataHandle.swObj.useShearwaveCorrection;
dataStore.swObjSnapshot.shearwaveRunLength=dataHandle.swObj.shearwaveRunLength;
dataStore.swObjSnapshot.lateralStep_mm=dataHandle.swObj.caseObj.lateralStep_mm;
dataStore.swObjSnapshot.axialStep_mm=dataHandle.swObj.caseObj.axialStep_mm;
dataStore.swObjSnapshot.shearwaveGeneratorPosition=dataHandle.swObj.shearwaveGeneratorPosition;
dataStore.swObjSnapshot.caseObj=dataHandle.swObj.caseObj;

dataStore.area=handles.area;

for iii=1:length(dataStore.area)
    dataStore.areaData(iii).position=area(iii).obj(1).getPosition;
    dataStore.areaData(iii).mask=area(iii).obj(1).createMask;
    dataStore.areaData(iii).color=area(iii).obj(1).getColor;
end

dataStore.svnversion='439';
end