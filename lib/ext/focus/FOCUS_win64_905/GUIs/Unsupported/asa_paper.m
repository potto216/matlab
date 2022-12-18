function varargout = asa_paper(varargin)
% ASA_PAPER M-file for asa_paper.fig
%      ASA_PAPER, by itself, creates a new ASA_PAPER or raises the existing
%      singleton*.
%
%      H = ASA_PAPER returns the handle to a new ASA_PAPER or the handle to
%      the existing singleton*.
%
%      ASA_PAPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASA_PAPER.M with the given input arguments.
%
%      ASA_PAPER('Property','Value',...) creates a new ASA_PAPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before asa_paper_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to asa_paper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help asa_paper

% Last Modified by GUIDE v2.5 26-Aug-2008 16:19:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @asa_paper_OpeningFcn, ...
                   'gui_OutputFcn',  @asa_paper_OutputFcn, ...
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


% --- Executes just before asa_paper is made visible.
function asa_paper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to asa_paper (see VARARGIN)

% Choose default command line output for asa_paper
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes asa_paper wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = asa_paper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_start.
function button_start_Callback(hObject, eventdata, handles)
% hObject    handle to button_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_quit.
function button_quit_Callback(hObject, eventdata, handles)
% hObject    handle to button_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider_z_src_Callback(hObject, eventdata, handles)
% hObject    handle to slider_z_src (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.var_z_source,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider_z_src_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_z_src (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function var_z_source_Callback(hObject, eventdata, handles)
% hObject    handle to var_z_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_z_source as text
%        str2double(get(hObject,'String')) returns contents of var_z_source as a double
set(handles.slider_z_src,'Value',str2double(get(hObject,'Value')));

% --- Executes during object creation, after setting all properties.
function var_z_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_z_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_win_size_Callback(hObject, eventdata, handles)
% hObject    handle to slider_win_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.var_win_size,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider_win_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_win_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function var_win_size_Callback(hObject, eventdata, handles)
% hObject    handle to var_win_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_win_size as text
%        str2double(get(hObject,'String')) returns contents of var_win_size as a double
set(handles.slider_win_size,'String',str2double(get(hObject,'Value')));

% --- Executes during object creation, after setting all properties.
function var_win_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_win_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function var_ndiv_Callback(hObject, eventdata, handles)
% hObject    handle to var_ndiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_ndiv as text
%        str2double(get(hObject,'String')) returns contents of var_ndiv as a double
set(handles.slider_ndiv,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function var_ndiv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_ndiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_ndiv_Callback(hObject, eventdata, handles)
% hObject    handle to slider_ndiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.var_ndiv,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider_ndiv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_ndiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function var_zero_pad_Callback(hObject, eventdata, handles)
% hObject    handle to var_zero_pad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_zero_pad as text
%        str2double(get(hObject,'String')) returns contents of var_zero_pad as a double
set(handles.slider_zero_pad,'Value',str2double(get(hObject,'Value')));

% --- Executes during object creation, after setting all properties.
function var_zero_pad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_zero_pad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sel_asa.
function sel_asa_Callback(hObject, eventdata, handles)
% hObject    handle to sel_asa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sel_asa


% --- Executes on button press in sel_power2.
function sel_power2_Callback(hObject, eventdata, handles)
% hObject    handle to sel_power2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sel_power2


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_atten_Callback(hObject, eventdata, handles)
% hObject    handle to slider_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.var_atten,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider_atten_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function var_atten_Callback(hObject, eventdata, handles)
% hObject    handle to var_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_atten as text
%        str2double(get(hObject,'String')) returns contents of var_atten as a double
set(handles.slider_atten,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function var_atten_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_end_loc_Callback(hObject, eventdata, handles)
% hObject    handle to slider_end_loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.var_end_location,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider_end_loc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_end_loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function var_end_location_Callback(hObject, eventdata, handles)
% hObject    handle to var_end_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_end_location as text
%        str2double(get(hObject,'String')) returns contents of var_end_location as a double
set(handles.slider_end_loc,'Value',str2double(get(hObject,'String')));


% --- Executes during object creation, after setting all properties.
function var_end_location_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_end_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_z_plane_Callback(hObject, eventdata, handles)
% hObject    handle to slider_z_plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.var_nz,'String',floor(get(hObject,'Value')));

% --- Executes during object creation, after setting all properties.
function slider_z_plane_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_z_plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function var_nz_Callback(hObject, eventdata, handles)
% hObject    handle to var_nz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_nz as text
%        str2double(get(hObject,'String')) returns contents of var_nz as a double
set(handles.slider_z_plane,'Value',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function var_nz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_nz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function command_phraser(handles)
z_start=str2double(get(handles.var_z_source,'String'))
nz=str2double(get(handles.var_nz,'String'))
win_size=str2double(get(handles.var_win_size,'String'))
ndiv=str2double(get(handles.var_ndiv,'String'))
zero_pad=str2double(get(handles.var_zero_pad,'String'))
atten=str2double(get(handles.var_atten,'String'))
end_loc=str2double(get(handles.var_end_location,'String'))