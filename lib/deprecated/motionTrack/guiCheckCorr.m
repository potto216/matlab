function varargout = guiCheckCorr(varargin)
% GUICHECKCORR M-file for guiCheckCorr.fig
%      GUICHECKCORR, by itself, creates a new GUICHECKCORR or raises the existing
%      singleton*.
%
%       The purpose of this function is to evaluate the 1D speckle tracking code.
%       The argument that is passed in is as follows:
%       [{'function name'},mmodeImg,frame,roiTemplate,roiSearch,corrMatch, corrMaxVal, corr]
%       These are the variables that are returned from the function which
%       right now has only one option 'compute1DSpeckleTrack'.  The
%       function name MUST be a cell otherwise the GUI will get confused
%       and think that it is a callback or value pair.
%
%
%      H = GUICHECKCORR returns the handle to a new GUICHECKCORR or the handle to
%      the existing singleton*.
%
%      GUICHECKCORR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUICHECKCORR.M with the given input arguments.
%
%      GUICHECKCORR('Property','Value',...) creates a new GUICHECKCORR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiCheckCorr_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiCheckCorr_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiCheckCorr

% Last Modified by GUIDE v2.5 30-Aug-2010 18:45:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiCheckCorr_OpeningFcn, ...
    'gui_OutputFcn',  @guiCheckCorr_OutputFcn, ...
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

% --- Executes just before guiCheckCorr is made visible.
function guiCheckCorr_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiCheckCorr (see VARARGIN)

% Choose default command line output for guiCheckCorr
handles.output = hObject;

%we need to save the input data

handles.functionName=varargin{1}{1};
switch(handles.functionName)
    case 'compute1DSpeckleTrack'
        if length(varargin{2})~=7
            error('Invalid number of arguments.')
        end
        handles.argin.mmodeImg=varargin{2}{1};
        handles.argin.frame=varargin{2}{2};
        handles.argin.roiTemplate=varargin{2}{3};
        handles.argin.roiSearch=varargin{2}{4};
        handles.argout.corrMatch=varargin{2}{5};
        handles.argout.corrMaxVal=varargin{2}{6};
        handles.argout.corr=varargin{2}{7};
    otherwise
        error(['Invalid function of ' handles.functionName])
end

%       [{'function name'},mmodeImg,frame,roiTemplate,roiSearch,corrMatch, corrMaxVal, corr]
%       These are the variables that are returned from the function which
%       right now has only one option 'compute1DSpeckleTrack'.  The
set(handles.figure1,'Name',varargin{3}{1});

set(handles.edtTemplate,'String',num2str(handles.argin.roiTemplate));
set(handles.edtSearchRegion,'String',num2str(handles.argin.roiSearch));
set(handles.edtFrame,'String',num2str(handles.argin.frame));

set(handles.edtCorrMfile,'String','');
set(handles.edtShowMfile,'String','');

set(handles.btnReset,'Enable','off');
set(handles.btnStepRight,'Enable','off');
set(handles.btnStepLeft,'Enable','off');
set(handles.btnRefreshDisplay,'Enable','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiCheckCorr wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = guiCheckCorr_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end




%This function will always show the clean data.  It is only when you hit
%reset does the filter take effect.
function btnNewFigure_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to btnNewFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Setup the data and figure;
[template,templateIdx,searchFrame,searchRoiIdx,corrFromFunction]=loadCleanData(handles);


handles.show.fig=figure;
set(handles.show.fig,'Name',get(handles.figure1,'Name'));

%plot only the previous and current rows. the previous row is plotted
%because that is what the speckle tracker compares to
ax(3)=subplot(5,4,(1:4));
imagesc(handles.argin.mmodeImg(:,(-1:0)+handles.argin.frame).'); colormap(gray);

ax(1)=subplot(5,4,(5:16));
handles.show.hSearchFrame=plot(searchFrame,'b')
hold on
handles.show.hSearchFrameRoi=plot(searchRoiIdx,searchFrame(searchRoiIdx),'bo');
handles.show.hTemplate=plot(templateIdx,template,'go:');

handles.cache.searchFrame=searchFrame;

ax(2)=subplot(5,4,(17:20));
axis([1 length(searchFrame) -1.1 1.1])
hold on

handles.show.hCorr=plot((0:(length(corrFromFunction)-1))+(handles.argin.roiSearch(1)),corrFromFunction,'ro-');

handles.show.ax=ax;
handles.show.animate.offset=[];
linkaxes(handles.show.ax,'x');
xlim([1 length(searchFrame)]);


%define place holders for the variables.  They must first be reset with the
%reset button
handles.corr.Valid=[];
handles.corr.Values=[];
handles.corr.showh=[];
handles.corr.showCurrentPt=[];

set(handles.btnReset,'Enable','on');

guidata(hObject, handles);
end

% --- Executes on button press in btnRefreshDisplay.
function btnRefreshDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to btnRefreshDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.show.animate.offset=0;

handles=refreshDisplay(handles);

guidata(hObject, handles);

end

%Now we transform both the search area and data area if requested
function btnReset_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to btnReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.corr.Valid=[];
handles.corr.Values=[];

handles.show.animate.offset=0;

handles=refreshDisplay(handles);


set(handles.btnStepRight,'Enable','on');
set(handles.btnStepLeft,'Enable','on');
set(handles.btnRefreshDisplay,'Enable','on');

guidata(hObject, handles);

end
% --- Executes on button press in btnStepRight.
function btnStepRight_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to btnStepRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.show.animate.offset=handles.show.animate.offset+1;

handles=refreshDisplay(handles);

guidata(hObject, handles);


end
% --- Executes on button press in btnStepLeft.
function btnStepLeft_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to btnStepLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.show.animate.offset=handles.show.animate.offset-1;

handles=refreshDisplay(handles);

guidata(hObject, handles);
end

function corrVal=defaultCorrelateFunction(template,target)
%template=template-mean(template);
%target=target-mean(target);
corrVal= (template'*target)/sqrt((template'*template)*(target'*target));
end


function [template,templateIdx,searchFrame,searchRoiIdx,corrFromFunction]=loadCleanData(handles)
templateIdx=handles.argin.roiTemplate;

template=handles.argin.mmodeImg(templateIdx,handles.argin.frame-1);

searchFrame=handles.argin.mmodeImg(:,handles.argin.frame);
searchRoiIdx=(handles.argin.roiSearch(1):handles.argin.roiSearch(2));

corrFromFunction=handles.argout.corr;
end


function handles=refreshDisplay(handles)


%% get all of the data setup
[template,templateIdx,searchFrame,searchRoiIdx,corrFromFunction]=loadCleanData(handles);
fCorr=get(handles.edtCorrMfile,'String');
fShow=get(handles.edtShowMfile,'String');


axes(handles.show.ax(1))

if ~isempty(fShow)
    [template,searchFrame]=feval(fShow,template,templateIdx,searchFrame,searchRoiIdx);
end

if ishandle(handles.show.hSearchFrame)
    if(~all(handles.cache.searchFrame==searchFrame))
        delete(handles.show.hSearchFrame);
        delete(handles.show.hSearchFrameRoi);
        handles.show.hSearchFrame=plot(searchFrame,'b');
        handles.show.hSearchFrameRoi=plot(searchRoiIdx,searchFrame(searchRoiIdx),'bo');
        handles.cache.searchFrame=searchFrame;
    else
        %If the same do nothing
    end

else
    error('This must be a handle.');
end




% templateIdx=handles.argin.roiTemplate;
%
% template=handles.argin.mmodeImg(templateIdx,handles.argin.frame-1);
% searchFrame=handles.argin.mmodeImg(:,handles.argin.frame);
% searchRoiIdx=(handles.argin.roiSearch(1):handles.argin.roiSearch(2));



if ~isempty(handles.corr.Valid) && ~isempty(handles.corr.Values)
    %Do the processing
elseif isempty(handles.corr.Valid) && isempty(handles.corr.Values)
    %Reset Values
    handles.corr.Valid=repmat(false,length(searchFrame),1);
    handles.corr.Values=zeros(length(searchFrame),1);
else
    error('either none should be empty or both should be')
end


if ishandle(handles.show.hTemplate)
    delete(handles.show.hTemplate);
else
    error('There should always be a template handle to delete');
end


templateStartOnSearchIdx=(1:(length(handles.argin.roiTemplate)))-1+searchRoiIdx(1)+handles.show.animate.offset;
handles.show.hTemplate=plot(templateStartOnSearchIdx,template,'ro:');

target=searchFrame(templateStartOnSearchIdx);
handles.corr.Valid(templateStartOnSearchIdx(1))=true;

if ~isempty(fCorr)
    handles.corr.Values(templateStartOnSearchIdx(1))=feval(fCorr,template,target);
else
    handles.corr.Values(templateStartOnSearchIdx(1))=defaultCorrelateFunction(template,target);
end

axes(handles.show.ax(2))


if ishandle(handles.corr.showh)
    delete(handles.corr.showh);
end

handles.corr.showh=plot(find(handles.corr.Valid),handles.corr.Values(handles.corr.Valid),'rx');

if ishandle(handles.corr.showCurrentPt)
    delete(handles.corr.showCurrentPt);
end

handles.corr.showCurrentPt=plot(templateStartOnSearchIdx(1),handles.corr.Values(templateStartOnSearchIdx(1)),'rd');


end


