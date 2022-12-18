function varargout = agentManager(varargin)
% AGENTMANAGER MATLAB code for agentManager.fig
%      AGENTMANAGER, by itself, creates a new AGENTMANAGER or raises the existing
%      singleton*.
%
%      H = AGENTMANAGER returns the handle to a new AGENTMANAGER or the handle to
%      the existing singleton*.
%
%      AGENTMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AGENTMANAGER.M with the given input arguments.
%
%      AGENTMANAGER('Property','Value',...) creates a new AGENTMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before agentManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to agentManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help agentManager

% Last Modified by GUIDE v2.5 19-Jun-2014 14:54:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @agentManager_OpeningFcn, ...
    'gui_OutputFcn',  @agentManager_OutputFcn, ...
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

% --- Executes just before agentManager is made visible.
function agentManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to agentManager (see VARARGIN)

% Choose default command line output for agentManager
handles.output = hObject;

if ~any(length(varargin)==[1 2])
    error('error only one or two input arguments are supported now.  The argument must be the parent handle that contains the agent data.');
end

handles.parentHandle=varargin{1};
handles.configSettings=varargin{2};

if ~ishandle(handles.parentHandle)
    error('The parent handle must be a valid graphics handle that has access to the agent data structure.');
end

set(handles.editStepSize,'String',num2str(10));

set(handles.figAgentManager,'KeyPressFcn',{@moveTrack});
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes agentManager wait for user response (see UIRESUME)
% uiwait(handles.figAgentManager);
end

% --- Outputs from this function are returned to the command line.
function varargout = agentManager_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in btnLoadAgent.
function btnLoadAgent_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoadAgent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[filename pathname] = uigetfile({'*.mat','matlab data file (*.mat)'; ...
    '*.*','All Files (*.*)' },'Load an agent file',pwd);

if filename==0  %user selected cancel
    return;
end


parentData=guidata(handles.parentHandle);
parentData.case.activeFrameIdx;
load(fullfile(pathname,filename),'data');

parentData.agents.grid2AgentObj.load([],'dataSet',data.grid2AgentObj,'activeSlice',parentData.case.activeFrameIdx);
parentData.agents.grid2AgentObj.addAllSkeletonPointsByIndex;
parentData.agents.grid2AgentObj.plotSkeleton;

parentData.agents.manualTrackObj.load([],'dataSet',data.manualTrackObj,'activeSlice',parentData.case.activeFrameIdx);
parentData.agents.manualTrackObj.addAllSkeletonPointsByIndex;
parentData.agents.manualTrackObj.plotSkeleton;


end

% --- Executes on button press in btnSaveAgent.
function btnSaveAgent_Callback(hObject, eventdata, handles)
% hObject    handle to btnSaveAgent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.configSettings.defaultSplineFilename)
    defaultFilename=pwd;
else
    defaultFilename=handles.configSettings.defaultSplineFilename;
end

[filename, pathname] = uiputfile({'*.mat','matlab data file (*.mat)'; ...
    '*.*','All Files (*.*)' },'Save an agent file',defaultFilename);

if filename==0  %user selected cancel
    return;
end

parentData=guidata(handles.parentHandle);
data.main.configSettings=parentData.configSettings;
data.main.dataBlockObj=parentData.dataBlockObj.save([]);

data.main.case=parentData.case;
data.manualTrackObj=parentData.agents.manualTrackObj.save([],'saveDataBlockObj',true);
data.grid2AgentObj=parentData.agents.grid2AgentObj.save([],'saveDataBlockObj',true);
save(fullfile(pathname,filename),'data');
end


function moveTrack(src,evnt) %#ok<INUSL>

switch(evnt.Key)
    case 'downarrow'
        
        handles=guidata(src);
        stepSize=str2num(get(handles.editStepSize,'String'));
        parentData=guidata(handles.parentHandle);
        T=diag([1 1 0 0]);
        T(1,4)=stepSize;
        parentData.agents.grid2AgentObj.transformSkeletonPoints(T);
        parentData.agents.grid2AgentObj.plotSkeleton;
        
        guidata(src, handles);
        return;
        
    case 'uparrow'
        handles=guidata(src);
        stepSize=str2num(get(handles.editStepSize,'String'));
        parentData=guidata(handles.parentHandle);
        T=diag([1 1 0 0]);
        T(1,4)=-stepSize;
        parentData.agents.grid2AgentObj.transformSkeletonPoints(T);
        parentData.agents.grid2AgentObj.plotSkeleton;
        guidata(src, handles);
        return;
        
    otherwise
        return;
end
end
