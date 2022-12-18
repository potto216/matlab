function varargout = SingleTransducerCW(varargin)
% SINGLETRANSDUCERCW MATLAB code for SingleTransducerCW.fig
%      SINGLETRANSDUCERCW, by itself, creates a new SINGLETRANSDUCERCW or raises the existing
%      singleton*.
%
%      H = SINGLETRANSDUCERCW returns the handle to a new SINGLETRANSDUCERCW or the handle to
%      the existing singleton*.
%
%      SINGLETRANSDUCERCW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLETRANSDUCERCW.M with the given input arguments.
%
%      SINGLETRANSDUCERCW('Property','Value',...) creates a new SINGLETRANSDUCERCW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SingleTransducerCW_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SingleTransducerCW_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SingleTransducerCW

% Last Modified by GUIDE v2.5 28-Jan-2013 15:55:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SingleTransducerCW_OpeningFcn, ...
                   'gui_OutputFcn',  @SingleTransducerCW_OutputFcn, ...
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


% --- Executes just before SingleTransducerCW is made visible.
function SingleTransducerCW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SingleTransducerCW (see VARARGIN)

% Choose default command line output for SingleTransducerCW
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SingleTransducerCW wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SingleTransducerCW_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_draw_xdcr.
function button_draw_xdcr_Callback(hObject, eventdata, handles)
% hObject    handle to button_draw_xdcr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Set up transducer
dim1 = str2num(get(handles.txt_dim1,'String'));
dim2 = str2num(get(handles.txt_dim2,'String'));
center = str2num(get(handles.txt_center,'String'));
euler = str2num(get(handles.txt_euler,'String'));

if get(handles.menu_xdcr_shape,'Value') == 1
    xdcr = get_circ(dim1,center,euler);
elseif get(handles.menu_xdcr_shape,'Value') == 2
    xdcr = get_ring(dim1,dim2,center,euler);
elseif get(handles.menu_xdcr_shape,'Value') == 3
    xdcr = get_rect(dim1,dim2,center,euler);
elseif get(handles.menu_xdcr_shape,'Value') == 4
    xdcr = get_spherical_shell(dim1,dim2,center,euler);
elseif get(handles.menu_xdcr_shape,'Value') == 5
    xdcr = get_spherically_focused_ring(dim1,dim2,str2num(get(handles.txt_geo_focus,'String')),center,euler);
end
% Draw it
axes(handles.axes_xdcr);
cla(handles.axes_xdcr);
draw_array(xdcr);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_medium.
function menu_medium_Callback(hObject, eventdata, handles)
% hObject    handle to menu_medium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_medium contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_medium
media = cellstr(get(hObject,'String'));
medium = set_medium(lower(media{get(hObject,'Value')}));

set(handles.txt_density,'String',num2str(medium.density));
set(handles.txt_c_sound,'String',num2str(medium.soundspeed));
set(handles.txt_atten,'String',num2str(medium.attenuationdBcmMHz));

% --- Executes during object creation, after setting all properties.
function menu_medium_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_medium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_xdcr_shape.
function menu_xdcr_shape_Callback(hObject, eventdata, handles)
% hObject    handle to menu_xdcr_shape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_xdcr_shape contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_xdcr_shape
switch(get(hObject,'Value'))
    case 1
        set(handles.lbl_dim1,'String','Radius (m)');
        set(handles.lbl_dim2,'Visible','off');
        set(handles.txt_dim2,'Visible','off');
        set(handles.txt_geo_focus,'Visible','off');
        set(handles.lbl_geo_focus,'Visible','off');
    case 2
        set(handles.lbl_dim1,'String','Inner Radius (m)');
        set(handles.lbl_dim2,'String','Outer Radius (m)');
        set(handles.lbl_dim2,'Visible','on');
        set(handles.txt_dim2,'Visible','on');
        set(handles.txt_geo_focus,'Visible','off');
        set(handles.lbl_geo_focus,'Visible','off');
    case 3
        set(handles.lbl_dim1,'String','Width (m)');
        set(handles.lbl_dim2,'String','Height (m)');
        set(handles.lbl_dim2,'Visible','on');
        set(handles.txt_dim2,'Visible','on');
        set(handles.txt_geo_focus,'Visible','off');
        set(handles.lbl_geo_focus,'Visible','off');
    case 4
        set(handles.lbl_dim1,'String','Radius (m)');
        set(handles.lbl_dim2,'String','Radius of Curvature (m)');
        set(handles.lbl_dim2,'Visible','on');
        set(handles.txt_dim2,'Visible','on');
        set(handles.txt_geo_focus,'Visible','off');
        set(handles.lbl_geo_focus,'Visible','off');
    case 5
        set(handles.lbl_dim1,'String','Inner Radius (m)');
        set(handles.lbl_dim2,'String','Outer Radius (m)');
        set(handles.lbl_dim2,'Visible','on');
        set(handles.txt_dim2,'Visible','on');
        set(handles.txt_geo_focus,'Visible','on');
        set(handles.lbl_geo_focus,'Visible','on');
end

% --- Executes during object creation, after setting all properties.
function menu_xdcr_shape_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_xdcr_shape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_center_Callback(hObject, eventdata, handles)
% hObject    handle to txt_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_center as text
%        str2double(get(hObject,'String')) returns contents of txt_center as a double


% --- Executes during object creation, after setting all properties.
function txt_center_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_euler_Callback(hObject, eventdata, handles)
% hObject    handle to txt_euler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_euler as text
%        str2double(get(hObject,'String')) returns contents of txt_euler as a double


% --- Executes during object creation, after setting all properties.
function txt_euler_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_euler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_dim1_Callback(hObject, eventdata, handles)
% hObject    handle to txt_dim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_dim1 as text
%        str2double(get(hObject,'String')) returns contents of txt_dim1 as a double


% --- Executes during object creation, after setting all properties.
function txt_dim1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_dim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_dim2_Callback(hObject, eventdata, handles)
% hObject    handle to txt_dim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_dim2 as text
%        str2double(get(hObject,'String')) returns contents of txt_dim2 as a double


% --- Executes during object creation, after setting all properties.
function txt_dim2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_dim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_density_Callback(hObject, eventdata, handles)
% hObject    handle to txt_density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_density as text
%        str2double(get(hObject,'String')) returns contents of txt_density as a double


% --- Executes during object creation, after setting all properties.
function txt_density_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_c_sound_Callback(hObject, eventdata, handles)
% hObject    handle to txt_c_sound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_c_sound as text
%        str2double(get(hObject,'String')) returns contents of txt_c_sound as a double


% --- Executes during object creation, after setting all properties.
function txt_c_sound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_c_sound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_atten_Callback(hObject, eventdata, handles)
% hObject    handle to txt_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_atten as text
%        str2double(get(hObject,'String')) returns contents of txt_atten as a double


% --- Executes during object creation, after setting all properties.
function txt_atten_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to txt_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_xmin as text
%        str2double(get(hObject,'String')) returns contents of txt_xmin as a double


% --- Executes during object creation, after setting all properties.
function txt_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to txt_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_xmax as text
%        str2double(get(hObject,'String')) returns contents of txt_xmax as a double


% --- Executes during object creation, after setting all properties.
function txt_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to txt_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_ymin as text
%        str2double(get(hObject,'String')) returns contents of txt_ymin as a double


% --- Executes during object creation, after setting all properties.
function txt_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to txt_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_ymax as text
%        str2double(get(hObject,'String')) returns contents of txt_ymax as a double


% --- Executes during object creation, after setting all properties.
function txt_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_zmin_Callback(hObject, eventdata, handles)
% hObject    handle to txt_zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_zmin as text
%        str2double(get(hObject,'String')) returns contents of txt_zmin as a double


% --- Executes during object creation, after setting all properties.
function txt_zmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_zmax_Callback(hObject, eventdata, handles)
% hObject    handle to txt_zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_zmax as text
%        str2double(get(hObject,'String')) returns contents of txt_zmax as a double


% --- Executes during object creation, after setting all properties.
function txt_zmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rdo_xz.
function rdo_xz_Callback(hObject, eventdata, handles)
% hObject    handle to rdo_xz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of rdo_xz


% --- Executes on button press in rdo_xy.
function rdo_xy_Callback(hObject, eventdata, handles)
% hObject    handle to rdo_xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of rdo_xy


% --- Executes on button press in rdo_yz.
function rdo_yz_Callback(hObject, eventdata, handles)
% hObject    handle to rdo_yz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of rdo_yz


% --- Executes on button press in btn_calculate.
function btn_calculate_Callback(hObject, eventdata, handles)
% hObject    handle to btn_calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set up coordinate grid
xmin = str2num(get(handles.txt_xmin,'String'));
xmax = str2num(get(handles.txt_xmax,'String'));
ymin = str2num(get(handles.txt_ymin,'String'));
ymax = str2num(get(handles.txt_ymax,'String'));
zmin = str2num(get(handles.txt_zmin,'String'));
zmax = str2num(get(handles.txt_zmax,'String'));

dx = str2num(get(handles.txt_dx,'String'));
dy = str2num(get(handles.txt_dy,'String'));
dz = str2num(get(handles.txt_dz,'String'));

if get(handles.rdo_xy,'Value') == 1
    zmin = zmax;
    dz = 0;
elseif get(handles.rdo_xz,'Value') == 1
    ymin = ymax;
    dy = 0;
else
    xmin = xmax;
    dx = 0;
end
cg = set_coordinate_grid([dx dy dz], xmin, xmax, ymin, ymax, zmin, zmax);

% Set up transducer
dim1 = str2num(get(handles.txt_dim1,'String'));
dim2 = str2num(get(handles.txt_dim2,'String'));
center = str2num(get(handles.txt_center,'String'));
euler = str2num(get(handles.txt_euler,'String'));

if get(handles.menu_xdcr_shape,'Value') == 1
    xdcr = get_circ(dim1,center,euler);
elseif get(handles.menu_xdcr_shape,'Value') == 2
    xdcr = get_ring(dim1,dim2,center,euler);
elseif get(handles.menu_xdcr_shape,'Value') == 3
    xdcr = get_rect(dim1,dim2,center,euler);
elseif get(handles.menu_xdcr_shape,'Value') == 4
    xdcr = get_spherical_shell(dim1,dim2,center,euler);
elseif get(handles.menu_xdcr_shape,'Value') == 5
    xdcr = get_spherically_focused_ring(dim1,dim2,str2num(get(handles.txt_geo_focus,'String')),center,euler);
end

% Set up medium
rho = str2num(get(handles.txt_density,'String'));
c = str2num(get(handles.txt_c_sound,'String'));
atten = str2num(get(handles.txt_atten,'String'));
f0 = str2num(get(handles.txt_f0,'String'));
ndiv = 40;

medium = set_medium('density',rho,'soundspeed',c,'attenuationdBcmMHz',atten);
% Calculate pressure
pressure = fnm_call(xdcr,cg,medium,ndiv,f0);

if get(handles.rdo_xy,'Value') == 1
    zmin = zmax;
    dz = 0;
    x_axis = xmin:dx:xmax;
    y_axis = ymin:dy:ymax;
    pressure = abs(squeeze(pressure(:,:,1)));
    pressure = rot90(pressure,3);
elseif get(handles.rdo_xz,'Value') == 1
    ymin = ymax;
    dy = 0;
    x_axis = zmin:dz:zmax;
    y_axis = xmin:dx:xmax;
    pressure = abs(squeeze(pressure(:,1,:)));
else
    xmin = xmax;
    dx = 0;
    x_axis = zmin:dz:zmax;
    y_axis = ymin:dy:ymax;
    pressure = abs(squeeze(pressure(1,:,:)));
end

pcolor(handles.axes_pressure,x_axis,y_axis,pressure);
shading(handles.axes_pressure,'flat');

function txt_dx_Callback(hObject, eventdata, handles)
% hObject    handle to txt_dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_dx as text
%        str2double(get(hObject,'String')) returns contents of txt_dx as a double


% --- Executes during object creation, after setting all properties.
function txt_dx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_dy_Callback(hObject, eventdata, handles)
% hObject    handle to txt_dy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_dy as text
%        str2double(get(hObject,'String')) returns contents of txt_dy as a double


% --- Executes during object creation, after setting all properties.
function txt_dy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_dy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_dz_Callback(hObject, eventdata, handles)
% hObject    handle to txt_dz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_dz as text
%        str2double(get(hObject,'String')) returns contents of txt_dz as a double


% --- Executes during object creation, after setting all properties.
function txt_dz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_dz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_f0_Callback(hObject, eventdata, handles)
% hObject    handle to txt_f0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_f0 as text
%        str2double(get(hObject,'String')) returns contents of txt_f0 as a double


% --- Executes during object creation, after setting all properties.
function txt_f0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_f0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_geo_focus_Callback(hObject, eventdata, handles)
% hObject    handle to txt_geo_focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_geo_focus as text
%        str2double(get(hObject,'String')) returns contents of txt_geo_focus as a double


% --- Executes during object creation, after setting all properties.
function txt_geo_focus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_geo_focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
