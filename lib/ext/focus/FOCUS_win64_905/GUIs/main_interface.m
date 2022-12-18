function varargout = main_interface(varargin)
% MAIN_INTERFACE M-file for main_interface.fig
%      MAIN_INTERFACE, by itself, creates a new MAIN_INTERFACE or raises the existing
%      singleton*.
%
%      H = MAIN_INTERFACE returns the handle to a new MAIN_INTERFACE or the handle to
%      the existing singleton*.
%
%      MAIN_INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_INTERFACE.M with the given input arguments.
%
%      MAIN_INTERFACE('Property','Value',...) creates a new MAIN_INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_interface_OpeningFunction gets
%      called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_interface

% Last Modified by GUIDE v2.5 27-Jul-2011 17:48:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_interface_OpeningFcn, ...
                   'gui_OutputFcn',  @main_interface_OutputFcn, ...
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
path('..',path);

% --- Executes just before main_interface is made visible.
function main_interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_interface (see VARARGIN)

% Choose default command line output for main_interface
handles.output = hObject;

% Set keypress event handler
set(handles.figure1,'KeyPressFcn',@keypress_handler);

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using main_interface.
%if strcmp(get(hObject,'Visible'),'off')
%    plot(rand(5));
%end

% UIWAIT makes main_interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_interface_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Handle key press events and call the appropriate functions
function keypress_handler(hObject, eventdata)
handles = guidata(hObject);

k = eventdata.Key;
mod = eventdata.Modifier;

if strcmp(mod,'control')
    if strcmp(k,'s')
        button_save_plot_Callback(hObject, eventdata, handles);
    elseif strcmp(k,'q')
        button_exit_Callback(hObject, eventdata, handles);
    end
else
    if strcmp(k,'f5')
        button_fnm_Callback(hObject, eventdata, handles);
    end
end

% --- Executes on button press in button_fnm.
function button_fnm_Callback(hObject, eventdata, handles)
% hObject    handle to button_fnm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.sel_3d,'Value')>.5)
    show_error('Cannot plot 3d fields, use the save function to create a script', handles);
    return
end
% Create transducer array
try
    t_array = get_transducer_array(handles);
    f0 = str2double(get(handles.var_f0,'String'));
    medium = get_medium(handles);
    coordinate_grid = get_coordinate_grid(handles);
    tolerance = str2double(get(handles.var_tolerance,'String'));
    try % find_ndiv might not be available
        ndiv = find_ndiv(t_array, coordinate_grid, medium, f0, tolerance);
    catch ndiv_e
        ndiv = 50;
    end
catch e
    show_error(e,handles);
    return;
end

if ~isempty(coordinate_grid)
    watchon;
    show_message('Processing...',handles);
    drawnow;

    press=fnm_call(t_array,coordinate_grid,medium,ndiv,f0,0);
    axes(handles.fig_pfield);
    cla;
    press=my_storage(press);
    if(strcmp(get(handles.logMenu,'Checked'),'on'))
        data = squeeze(20*log(1e-10+abs(press/max(max(max(abs(press)))))));
    end
    % Choose plane to display and how to label axes
    plane_type=(get(get(handles.planes,'SelectedObject'),'Tag'));
    switch(plane_type)
        case 'sel_xy'
            data = rot90(abs(squeeze(press(:,:,1))));
            xscale = coordinate_grid.xmin:coordinate_grid.delta(1):coordinate_grid.xmax;
            yscale = coordinate_grid.ymin:coordinate_grid.delta(2):coordinate_grid.ymax;
            xvar = 'x';
            yvar = 'y';
        case 'sel_xz'
            data = abs(squeeze(press(:,1,:)));
            yscale = coordinate_grid.xmin:coordinate_grid.delta(1):coordinate_grid.xmax;
            xscale = coordinate_grid.zmin:coordinate_grid.delta(3):coordinate_grid.zmax;
            yvar = 'x';
            xvar = 'z';
        case 'sel_yz'
            data = abs(squeeze(press(1,:,:)));
            yscale = coordinate_grid.ymin:coordinate_grid.delta(2):coordinate_grid.ymax;
            xscale = coordinate_grid.zmin:coordinate_grid.delta(3):coordinate_grid.zmax;
            yvar = 'y';
            xvar = 'z';
    end
    pcolor(xscale, yscale, data);
    shading flat;
    xlabel([xvar, ' (m)']);
    ylabel([yvar, ' (m)']);

    show_message('Done.',handles);
    watchoff;
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in drop_medium.
function drop_medium_Callback(hObject, eventdata, handles)
% hObject    handle to drop_medium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns drop_medium contents as cell array
%        contents{get(hObject,'Value')} returns selected item from drop_medium
if ~exist('water','var') == 1
    define_media;
end
sel_switch=get(hObject,'Value');
switch sel_switch
    % Water
    case 1
        set(handles.var_rho, 'String', water.density);
        set(handles.var_c, 'String', water.soundspeed);
        set(handles.var_b, 'String', water.powerlawexponent);
        set(handles.var_atten, 'String', water.attenuationdBcmMHz);
        set(handles.var_ct, 'String', water.specificheat);
        set(handles.var_kappa, 'String', water.thermalconductivity);
        set(handles.var_beta, 'String', water.nonlinearityparameter);
    % Lossless
    case 2
        set(handles.var_rho, 'String', lossless.density);
        set(handles.var_c, 'String', lossless.soundspeed);
        set(handles.var_b, 'String', lossless.powerlawexponent);
        set(handles.var_atten, 'String', lossless.attenuationdBcmMHz);
        set(handles.var_ct, 'String', lossless.specificheat);
        set(handles.var_kappa, 'String', lossless.thermalconductivity);
        set(handles.var_beta, 'String', lossless.nonlinearityparameter);
    % Attenuated
    case 3
        set(handles.var_rho, 'String', attenuated.density);
        set(handles.var_c, 'String', attenuated.soundspeed);
        set(handles.var_b, 'String', attenuated.powerlawexponent);
        set(handles.var_atten, 'String', attenuated.attenuationdBcmMHz);
        set(handles.var_ct, 'String', attenuated.specificheat);
        set(handles.var_kappa, 'String', attenuated.thermalconductivity);
        set(handles.var_beta, 'String', attenuated.nonlinearityparameter);
    % Skin
    case 4
        set(handles.var_rho, 'String', skin.density);
        set(handles.var_c, 'String', skin.soundspeed);
        set(handles.var_b, 'String', skin.powerlawexponent);
        set(handles.var_atten, 'String', skin.attenuationdBcmMHz);
        set(handles.var_ct, 'String', skin.specificheat);
        set(handles.var_kappa, 'String', skin.thermalconductivity);
        set(handles.var_beta, 'String', skin.nonlinearityparameter);
    % Fat
    case 5
        set(handles.var_rho, 'String', fat.density);
        set(handles.var_c, 'String', fat.soundspeed);
        set(handles.var_b, 'String', fat.powerlawexponent);
        set(handles.var_atten, 'String', fat.attenuationdBcmMHz);
        set(handles.var_ct, 'String', fat.specificheat);
        set(handles.var_kappa, 'String', fat.thermalconductivity);
        set(handles.var_beta, 'String', fat.nonlinearityparameter);
    % Muscle
    case 6
        set(handles.var_rho, 'String', muscle.density);
        set(handles.var_c, 'String', muscle.soundspeed);
        set(handles.var_b, 'String', muscle.powerlawexponent);
        set(handles.var_atten, 'String', muscle.attenuationdBcmMHz);
        set(handles.var_ct, 'String', muscle.specificheat);
        set(handles.var_kappa, 'String', muscle.thermalconductivity);
        set(handles.var_beta, 'String', muscle.nonlinearityparameter);
    % Liver
    case 7
        set(handles.var_rho, 'String', liver.density);
        set(handles.var_c, 'String', liver.soundspeed);
        set(handles.var_b, 'String', liver.powerlawexponent);
        set(handles.var_atten, 'String', liver.attenuationdBcmMHz);
        set(handles.var_ct, 'String', liver.specificheat);
        set(handles.var_kappa, 'String', liver.thermalconductivity);
        set(handles.var_beta, 'String', liver.nonlinearityparameter);
end


% --- Executes during object creation, after setting all properties.
function drop_medium_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drop_medium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

set(hObject, 'String', {'Water', 'Lossless', 'Attenuated', 'Skin', 'Fat', 'Muscle', 'Liver', 'Custom'});

function var_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to var_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_xmin as text
%        str2double(get(hObject,'String')) returns contents of var_xmin as a double


% --- Executes during object creation, after setting all properties.
function var_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to var_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_ymin as text
%        str2double(get(hObject,'String')) returns contents of var_ymin as a double


% --- Executes during object creation, after setting all properties.
function var_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_zmin_Callback(hObject, eventdata, handles)
% hObject    handle to var_zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_zmin as text
%        str2double(get(hObject,'String')) returns contents of var_zmin as a double


% --- Executes during object creation, after setting all properties.
function var_zmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to var_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_xmax as text
%        str2double(get(hObject,'String')) returns contents of var_xmax as a double


% --- Executes during object creation, after setting all properties.
function var_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_zmax_Callback(hObject, eventdata, handles)
% hObject    handle to var_zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_zmax as text
%        str2double(get(hObject,'String')) returns contents of var_zmax as a double


% --- Executes during object creation, after setting all properties.
function var_zmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_deltax_Callback(hObject, eventdata, handles)
% hObject    handle to var_deltax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_deltax as text
%        str2double(get(hObject,'String')) returns contents of var_deltax as a double


% --- Executes during object creation, after setting all properties.
function var_deltax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_deltax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_deltay_Callback(hObject, eventdata, handles)
% hObject    handle to var_deltay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_deltay as text
%        str2double(get(hObject,'String')) returns contents of var_deltay as a double


% --- Executes during object creation, after setting all properties.
function var_deltay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_deltay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_deltaz_Callback(hObject, eventdata, handles)
% hObject    handle to var_deltaz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_deltaz as text
%        str2double(get(hObject,'String')) returns contents of var_deltaz as a double


% --- Executes during object creation, after setting all properties.
function var_deltaz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_deltaz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to var_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_ymax as text
%        str2double(get(hObject,'String')) returns contents of var_ymax as a double


% --- Executes during object creation, after setting all properties.
function var_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_rho_Callback(hObject, eventdata, handles)
% hObject    handle to var_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_rho as text
%        str2double(get(hObject,'String')) returns contents of var_rho as a double


% --- Executes during object creation, after setting all properties.
function var_rho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_c_Callback(hObject, eventdata, handles)
% hObject    handle to var_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_c as text
%        str2double(get(hObject,'String')) returns contents of var_c as a double


% --- Executes during object creation, after setting all properties.
function var_c_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_b_Callback(hObject, eventdata, handles)
% hObject    handle to var_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_b as text
%        str2double(get(hObject,'String')) returns contents of var_b as a double


% --- Executes during object creation, after setting all properties.
function var_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_atten_Callback(hObject, eventdata, handles)
% hObject    handle to var_atten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_atten as text
%        str2double(get(hObject,'String')) returns contents of var_atten as a double


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



function var_ct_Callback(hObject, eventdata, handles)
% hObject    handle to var_ct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_ct as text
%        str2double(get(hObject,'String')) returns contents of var_ct as a double


% --- Executes during object creation, after setting all properties.
function var_ct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_ct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_kappa_Callback(hObject, eventdata, handles)
% hObject    handle to var_kappa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_kappa as text
%        str2double(get(hObject,'String')) returns contents of var_kappa as a double


% --- Executes during object creation, after setting all properties.
function var_kappa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_kappa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_beta_Callback(hObject, eventdata, handles)
% hObject    handle to var_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_beta as text
%        str2double(get(hObject,'String')) returns contents of var_beta as a double


% --- Executes during object creation, after setting all properties.
function var_beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_draw_array.
function button_draw_array_Callback(hObject, eventdata, handles)
% hObject    handle to button_draw_array (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
show_message('Processing...', handles);
axes(handles.fig_tarray);
cla;
try
    t_array = get_transducer_array(handles);
    draw_array(t_array);
    show_message('Done.', handles);
catch error
    % In the event of element overlap, the transducer generation functions
    % will suggest using the override function. This message is multiple
    % lines and doesn't make it into the status field.
    if findstr(error.message, 'override')
        show_error('Array not created; elements will overlap. Check "allow overlap" to override this warning.', handles);
    else
        show_error(error, handles);
    end
end
    
function dvar_1_Callback(hObject, eventdata, handles)
% hObject    handle to dvar_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dvar_1 as text
%        str2double(get(hObject,'String')) returns contents of dvar_1 as a double


% --- Executes during object creation, after setting all properties.
function dvar_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dvar_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dvar_2_Callback(hObject, eventdata, handles)
% hObject    handle to dvar_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dvar_2 as text
%        str2double(get(hObject,'String')) returns contents of dvar_2 as a double


% --- Executes during object creation, after setting all properties.
function dvar_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dvar_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_yspac_Callback(hObject, eventdata, handles)
% hObject    handle to var_yspac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_yspac as text
%        str2double(get(hObject,'String')) returns contents of var_yspac as a double


% --- Executes during object creation, after setting all properties.
function var_yspac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_yspac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_xspac_Callback(hObject, eventdata, handles)
% hObject    handle to var_xspac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_xspac as text
%        str2double(get(hObject,'String')) returns contents of var_xspac as a double


% --- Executes during object creation, after setting all properties.
function var_xspac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_xspac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_neley_Callback(hObject, eventdata, handles)
% hObject    handle to var_neley (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_neley as text
%        str2double(get(hObject,'String')) returns contents of var_neley as a double


% --- Executes during object creation, after setting all properties.
function var_neley_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_neley (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_nelex_Callback(hObject, eventdata, handles)
% hObject    handle to var_nelex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of var_nelex as text
%        str2double(get(hObject,'String')) returns contents of var_nelex as a double


% --- Executes during object creation, after setting all properties.
function var_nelex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_nelex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_center_Callback(hObject, eventdata, handles)
% hObject    handle to var_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_center as text
%        str2double(get(hObject,'String')) returns contents of var_center as a double


% --- Executes during object creation, after setting all properties.
function var_center_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_euler_Callback(hObject, eventdata, handles)
% hObject    handle to var_euler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_euler as text
%        str2double(get(hObject,'String')) returns contents of var_euler as a double


% --- Executes during object creation, after setting all properties.
function var_euler_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_euler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_fname_Callback(hObject, eventdata, handles)
% hObject    handle to var_fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_fname as text
%        str2double(get(hObject,'String')) returns contents of var_fname as a double


% --- Executes during object creation, after setting all properties.
function var_fname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_save_fnm.
function button_save_fnm_Callback(hObject, eventdata, handles)
% hObject    handle to button_save_fnm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
my_commands=process_args(hObject,eventdata,handles);
t_array = get_transducer_array(handles);

cb = 3480;
wb = 2*pi;
rho = str2double(get(handles.var_rho,'String'));
c_sound = str2double(get(handles.var_c,'String'));
b = str2double(get(handles.var_b,'String'));
atten = str2double(get(handles.var_atten,'String'));
ct = str2double(get(handles.var_ct,'String'));
kappa = str2double(get(handles.var_kappa,'String'));
beta = str2double(get(handles.var_beta,'String'));

f0 = str2double(get(handles.var_f0,'String'));
fs = str2double(get(handles.var_fs,'String'));

medium = get_medium(handles);
coordinate_grid = get_coordinate_grid(handles);
% Write to file
f_name=(get(handles.var_fname,'String'));
% Check if file exists and warn user that it will be overwritten
if(fopen(f_name,'r') ~= -1)
    if strcmp(questdlg('This file already exists. Overwrite?','Overwrite Saved Simulation?','Yes','No','No'), 'No')
        return;
    end
end
fid=fopen(f_name,'w');
fprintf(fid,'%%Saving commands to %s\n',f_name);
fprintf(fid,'%%Simulation parameters\n');
fprintf(fid,'f0 = %f;\n\n',f0);
fprintf(fid,'delta = [ %f %f %f ];\n', coordinate_grid.delta(1),coordinate_grid.delta(2),coordinate_grid.delta(3));
fprintf(fid,'xmin = %f;\n',coordinate_grid.xmin);
fprintf(fid,'xmax = %f;\n',coordinate_grid.xmax);
fprintf(fid,'ymin = %f;\n',coordinate_grid.ymin);
fprintf(fid,'ymax = %f;\n',coordinate_grid.ymax);
fprintf(fid,'zmin = %f;\n',coordinate_grid.zmin);
fprintf(fid,'zmax = %f;\n\n',coordinate_grid.zmax);
fprintf(fid,'%%Creating Transducer array\n');
fprintf(fid,'t_array=%s\n',my_commands{2});
fprintf(fid,'%%Not drawing the array, uncomment the next line to draw\n');
fprintf(fid,'%%draw_array(T_array)\n');
fprintf(fid,'%%Setting coordinate grid\n');
fprintf(fid,'coordinate_grid = set_coordinate_grid(delta,xmin,xmax,ymin,ymax,zmin,zmax);\n');
fprintf(fid,'%%creating medium structure\n');
fprintf(fid,'medium=struct(''wb'',%f,''rho'',%f,''c_sound'',%f,''b'',%f,''atten_coeff'',%f,''ct'',%f,''kappa'',%f,''beta'',%f'');\n',medium.wb,medium.rho,medium.c_sound,medium.b,medium.atten_coeff,medium.ct,medium.kappa,medium.beta);
fprintf(fid,'%%Using default properties for calculation:\n');
fprintf(fid,'Pressure=fnm_run(''transducer'',t_array,''cg'',coordinate_grid,''medium'',medium,''f0'',f0);\n');
fclose(fid);

% --- Executes on button press in button_imp_res.
function button_imp_res_Callback(hObject, eventdata, handles)
% hObject    handle to button_imp_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_exit.
function button_exit_Callback(hObject, eventdata, handles)
% hObject    handle to button_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1)


% --- Executes on button press in button_reset.
function button_reset_Callback(hObject, eventdata, handles)
% hObject    handle to button_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function var_f0_Callback(hObject, eventdata, handles)
% hObject    handle to var_f0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_f0 as text
%        str2double(get(hObject,'String')) returns contents of var_f0 as a double


% --- Executes during object creation, after setting all properties.
function var_f0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_f0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_fs_Callback(hObject, eventdata, handles)
% hObject    handle to var_fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_fs as text
%        str2double(get(hObject,'String')) returns contents of var_fs as a double


% --- Executes during object creation, after setting all properties.
function var_fs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in planes.
function planes_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in planes 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Tag')   % Get Tag of selected object

    case 'sel_xy'
        set(handles.var_zmin,'Visible','off');
        set(handles.txt_zmin,'Visible','off');
        set(handles.var_xmin,'Visible','on');
        set(handles.txt_xmin,'Visible','on');
        set(handles.var_ymin,'Visible','on');
        set(handles.txt_ymin,'Visible','on');
    case 'sel_xz'
        set(handles.var_zmin,'Visible','on');
        set(handles.txt_zmin,'Visible','on');
        set(handles.var_xmin,'Visible','on');
        set(handles.txt_xmin,'Visible','on');
        set(handles.var_ymin,'Visible','off');
        set(handles.txt_ymin,'Visible','off');
    case 'sel_yz'
        set(handles.var_zmin,'Visible','on');
        set(handles.txt_zmin,'Visible','on');
        set(handles.var_xmin,'Visible','off');
        set(handles.txt_xmin,'Visible','off');
        set(handles.var_ymin,'Visible','on');
        set(handles.txt_ymin,'Visible','on');
    case 'sel_3d'
        set(handles.var_zmin,'Visible','on');
        set(handles.txt_zmin,'Visible','on');
        set(handles.var_xmin,'Visible','on');
        set(handles.txt_xmin,'Visible','on');
        set(handles.var_ymin,'Visible','on');
        set(handles.txt_ymin,'Visible','on');
    otherwise
        return;
end

function std_edit_callback(hObject, eventdata, handles)
set(hObject,'Value',str2double(get(hObject,'String')));


% --- Executes when selected object is changed in t_type.
function t_type_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in t_type 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Tag')   % Get Tag of selected object
    case 'sel_CSA'
        set(handles.xspacing,'String','xspacing');
        set(handles.yspacing,'String','yspacing');
        set(handles.xspacing,'Visible','on');
        set(handles.yspacing,'Visible','on');     
        set(handles.nelex,'Visible','on');
        set(handles.neley,'Visible','on');
        set(handles.RadCurv,'Visible','on');
        set(handles.ang_open,'Visible','off');
        set(handles.var_array_rad_curv,'Visible','on');
        set(handles.var_nelex,'Visible','on');
        set(handles.var_neley,'Visible','on');
        set(handles.var_xspac,'Visible','on');
        set(handles.var_yspac,'Visible','on');
        set(handles.var_ang_open,'Visible','off');
        set(handles.allow_overlap,'Visible','on');
    case 'sel_planar'
        set(handles.xspacing,'String','xspacing');
        set(handles.yspacing,'String','yspacing');
        set(handles.xspacing,'Visible','on');
        set(handles.yspacing,'Visible','on');
        set(handles.nelex,'Visible','on');
        set(handles.neley,'Visible','on');
        set(handles.RadCurv,'Visible','off');
        set(handles.ang_open,'Visible','off');
        set(handles.var_array_rad_curv,'Visible','off');
        set(handles.var_nelex,'Visible','on');
        set(handles.var_neley,'Visible','on');
        set(handles.var_xspac,'Visible','on');
        set(handles.var_yspac,'Visible','on');
        set(handles.var_ang_open,'Visible','off');
        set(handles.allow_overlap,'Visible','on');
    case 'sel_singular'
        set(handles.xspacing,'Visible','off');
        set(handles.yspacing,'Visible','off');
        set(handles.nelex,'Visible','off');
        set(handles.neley,'Visible','off');
        set(handles.RadCurv,'Visible','off');
        set(handles.ang_open,'Visible','off');
        set(handles.var_array_rad_curv,'Visible','off');
        set(handles.var_nelex,'Visible','off');
        set(handles.var_neley,'Visible','off');
        set(handles.var_xspac,'Visible','off');
        set(handles.var_yspac,'Visible','off');
        set(handles.var_ang_open,'Visible','off');
        set(handles.allow_overlap,'Visible','off');
    case 'sel_SSA'
        set(handles.xspacing,'Visible','off');
        set(handles.yspacing,'Visible','off');
        set(handles.xspacing,'Visible','off');
        set(handles.yspacing,'Visible','off') ;       
        set(handles.nelex,'Visible','on');
        set(handles.neley,'Visible','off');
        set(handles.RadCurv,'Visible','on');
        set(handles.ang_open,'Visible','on');
        set(handles.var_array_rad_curv,'Visible','on')
        set(handles.var_nelex,'Visible','on');
        set(handles.var_neley,'Visible','off');
        set(handles.var_xspac,'Visible','off');
        set(handles.var_yspac,'Visible','off');
        set(handles.var_ang_open,'Visible','on');
        set(handles.allow_overlap,'Visible','off');
    otherwise
        return;
end


% --- Executes when selected object is changed in t_geo.
function t_geo_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in t_geo 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch (get(hObject,'Tag'))
    case 'sel_circ'
        set(handles.dyn_txt1,'String','Radius');
        set(handles.dyn_txt2,'Visible','off');
        set(handles.dvar_2,'Visible','off');
    case 'sel_tri'
        warndlg('Does not work right now')
    case 'sel_shel'
        set(handles.dyn_txt1,'String','Radius');
        set(handles.dyn_txt2,'Visible','on');
        set(handles.dyn_txt2,'String','R. Curv');
        set(handles.dvar_2,'Visible','on');
        
    case 'sel_rect'
        set(handles.dyn_txt1,'String','Width');
        set(handles.dyn_txt2,'Visible','on');
        set(handles.dyn_txt2,'String','Height');
        set(handles.dvar_2,'Visible','on');  
    otherwise
        return;
end

        


% --- Executes on button press in button_save_IR.
function button_save_IR_Callback(hObject, eventdata, handles)
% hObject    handle to button_save_IR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in drop_demos.
function drop_demos_Callback(hObject, eventdata, handles)
% hObject    handle to drop_demos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns drop_demos contents as cell array
%        contents{get(hObject,'Value')} returns selected item from drop_demos
popup_sel_index = get(hObject, 'Value');

set(handles.var_deltax,'String','.001');
set(handles.var_deltay,'String','.001');
set(handles.var_deltaz,'String','.001');
set(handles.var_f0,'String','1e6');
switch popup_sel_index
    case 2
        disp('Running single circle element in the xz plane')
        set(handles.sel_xz,'Value',1);
        planes_SelectionChangeFcn(handles.sel_xz, eventdata, handles)
        set(handles.sel_singular,'Value',1);
        t_type_SelectionChangeFcn(handles.sel_singular, eventdata, handles)
        set(handles.sel_circ,'Value',1);
        t_geo_SelectionChangeFcn(handles.sel_circ, eventdata, handles)
        
        set(handles.var_xmin,'String','-.1');
        set(handles.var_ymin,'String','0');
        set(handles.var_zmin,'String','0');
        set(handles.var_xmax,'String','.1');
        set(handles.var_ymax,'String','0');
        set(handles.var_zmax,'String','.2');
        set(handles.dvar_1,'String','.005');
        set(handles.var_center,'String','0 0 0');
        set(handles.var_euler,'String','0 0 0');
        
    case 3
        disp('Running CSA circles in the xy plane in lossless media')
        set(handles.sel_xy,'Value',1);
        planes_SelectionChangeFcn(handles.sel_xy, eventdata, handles)
        set(handles.sel_CSA,'Value',1);
        t_type_SelectionChangeFcn(handles.sel_CSA, eventdata, handles)
        set(handles.sel_circ,'Value',1);
        t_geo_SelectionChangeFcn(handles.sel_circ, eventdata, handles)
        set(handles.drop_medium,'Value',2);
        drop_medium_Callback(handles.drop_medium, eventdata, handles)
        
        set(handles.var_xmin,'String','-.1');
        set(handles.var_ymin,'String','-.1');
        set(handles.var_zmin,'String','.1');
        set(handles.var_xmax,'String','.1');        
        set(handles.var_ymax,'String','.1');        
        set(handles.var_zmax,'String','.1');        
        set(handles.dvar_1,'String','.005');        
        set(handles.var_center,'String','0 0 0');
        set(handles.var_euler,'String','0 0 0');
        set(handles.var_nelex,'String','5');        
        set(handles.var_neley,'String','5');        
        set(handles.var_xspac,'String','.01');        
        set(handles.var_yspac,'String','.01');        
        set(handles.var_array_rad_curv,'String','.15');        
        
    case 4
        disp('Running Planar Array Rectangles in the yz plane') 
        set(handles.sel_yz,'Value',1);
        planes_SelectionChangeFcn(handles.sel_yz, eventdata, handles)
        set(handles.sel_planar,'Value',1);
        t_type_SelectionChangeFcn(handles.sel_planar, eventdata, handles)
        set(handles.sel_rect,'Value',1);
        t_geo_SelectionChangeFcn(handles.sel_rect, eventdata, handles)
        set(handles.drop_medium,'Value',2);
        drop_medium_Callback(handles.drop_medium, eventdata, handles)
        
        set(handles.var_xmin,'String','0');
        set(handles.var_ymin,'String','-.1');
        set(handles.var_zmin,'String','0');
        set(handles.var_xmax,'String','0');        
        set(handles.var_ymax,'String','.1');        
        set(handles.var_zmax,'String','.2');        
        set(handles.dvar_1,'String','.005');        
        set(handles.dvar_2,'String','.01');        
        set(handles.var_center,'String','0 0 0');
        set(handles.var_euler,'String','0 0 0');
        set(handles.var_nelex,'String','5');        
        set(handles.var_neley,'String','5');        
        set(handles.var_xspac,'String','.01');        
        set(handles.var_yspac,'String','.02');        
    case 5
        disp('Spherical Shell in xz plane in water')
        set(handles.sel_xz,'Value',1);
        planes_SelectionChangeFcn(handles.sel_xz, eventdata, handles)
        set(handles.sel_singular,'Value',1);
        t_type_SelectionChangeFcn(handles.sel_singular, eventdata, handles)
        set(handles.sel_shel,'Value',1);
        t_geo_SelectionChangeFcn(handles.sel_shel, eventdata, handles)
        
        set(handles.var_xmin,'String','-.2');
        set(handles.var_ymin,'String','0');
        set(handles.var_zmin,'String','-.2');
        set(handles.var_xmax,'String','.2');        
        set(handles.var_ymax,'String','0');        
        set(handles.var_zmax,'String','.2');        
        set(handles.dvar_1,'String','.1');        
        set(handles.dvar_2,'String','.25');
    otherwise
        disp('Other demos have not been loaded yet')
end

% --- Executes during object creation, after setting all properties.
function drop_demos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drop_demos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_demo.
function button_demo_Callback(hObject, eventdata, handles)
% hObject    handle to button_demo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

popup_sel_index = get(handles.drop_demos, 'Value');
switch popup_sel_index
    case 2
        button_draw_array_Callback(handles.button_draw_array, eventdata, handles)
        button_fnm_Callback(handles.button_fnm,eventdata,handles);
    case 3
        button_draw_array_Callback(handles.button_draw_array, eventdata, handles)
        button_fnm_Callback(handles.button_fnm,eventdata,handles);
    case 4
        button_draw_array_Callback(handles.button_draw_array, eventdata, handles)
        button_fnm_Callback(handles.button_fnm,eventdata,handles);
    case 5
        button_fnm_Callback(handles.button_fnm,eventdata,handles);
    otherwise
        disp('Other demos have not been loaded yet')
end



function var_array_rad_curv_Callback(hObject, eventdata, handles)
% hObject    handle to var_array_rad_curv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_array_rad_curv as text
%        str2double(get(hObject,'String')) returns contents of var_array_rad_curv as a double


% --- Executes during object creation, after setting all properties.
function var_array_rad_curv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_array_rad_curv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function command_array=process_args(hObject, eventdata, handles)
warning('This function is deprecated.');
% Radio buttons
plane_type=(get(get(handles.planes,'SelectedObject'),'Tag'));
xdc_type=(get(get(handles.t_type,'SelectedObject'),'Tag'));
xdc_geo=(get(get(handles.t_geo,'SelectedObject'),'Tag'));

% Pressure data
xmin=str2double(get(handles.var_xmin,'String'));
ymin=str2double(get(handles.var_ymin,'String'));
zmin=str2double(get(handles.var_zmin,'String'));
xmax=str2double(get(handles.var_xmax,'String'));
ymax=str2double(get(handles.var_ymax,'String'));
zmax=str2double(get(handles.var_zmax,'String'));
dx=str2double(get(handles.var_deltax,'String'));
dy=str2double(get(handles.var_deltay,'String'));
dz=str2double(get(handles.var_deltaz,'String'));
f0=str2double(get(handles.var_f0,'String'));
fs=str2double(get(handles.var_fs,'String'));

% XDC Data
dvar1 = str2double(get(handles.dvar_1,'String'));
dvar2 = str2double(get(handles.dvar_2,'String'));
center = get(handles.var_center,'String');
euler = get(handles.var_euler,'String');
nelex = str2double(get(handles.var_nelex,'String'));
neley = str2double(get(handles.var_neley,'String'));
xspac = str2double(get(handles.var_xspac,'String'));
yspac = str2double(get(handles.var_yspac,'String'));
rcurv = str2double(get(handles.var_array_rad_curv,'String'));
ang_open = str2double(get(handles.var_ang_open,'String'));
override = get(handles.allow_overlap, 'Value');

% Medium data
medium=(get(handles.drop_medium,'Value'));

switch plane_type
    case 'sel_xy'
        zmin=zmax;
        dz=1;
    case 'sel_xz'
        ymin=ymax;
        dy=1;
    case 'sel_yz'
        xmin=xmax;
        dx=1;
    otherwise
end
        
ps_delta=sprintf('[%f %f %f]',dx,dy,dz);
ps_args=[xmin,xmax,ymin,ymax,zmin,zmax];
ps_args=num2str(ps_args,',%f');
ps_args=strcat(ps_delta,ps_args);
ps_string=strcat('set_problem_space(',ps_args,')');
command_array{1}=ps_string;
%ps=set_problemspace([dx dy dz],xmin,xmax,ymin,ymax,zmin,zmax);
if(f0<1)
    f0=1e6;
end

eval_str=[];
ele_info=[];
switch xdc_geo
    case 'sel_circ'
        eval_str='circ';
        ele_info=dvar1;
    case 'sel_rect'
        eval_str='rect';
        ele_info=[dvar1 dvar2];
    case 'sel_tri'
        eval_str='tri';
        show_message('Triangles do not work.', handles);
    case 'sel_shel'
        ele_info=[dvar1 dvar2];
        ele_info=num2str(ele_info,',%f');
        ele_info(1)=[];
        eval_str=strcat('get_spherical_shell(',ele_info,')');
        xdc_type='NULL';
end

switch xdc_type
    case 'sel_CSA'
        if override
            args=[ nelex neley ele_info xspac yspac rcurv override ];
        else
            args=[ nelex neley ele_info xspac yspac rcurv ];
        end
        args=num2str(args,',%f');
        args(1)=[];
        eval_str=strcat('create_', eval_str ,'_csa(',args,')');
    case 'sel_planar'
        if override
            args=[ nelex neley ele_info xspac yspac rcurv override ];
        else
            args=[ nelex neley ele_info xspac yspac rcurv ];
        end
        args=num2str(args,',%f');
        args(1)=[];
        eval_str=strcat('create_', eval_str ,'_planar_array(',args,')');
    case 'sel_SSA'
        args=[ ele_info rcurv nelex ang_open ];
        args=num2str(args,',%f');
        args(1)=[];
        eval_str=strcat('create_',eval_str,'_ssa(',args,')');
    case 'sel_singular'
        args=strcat(num2str(ele_info,'%f,'), center,',', euler);
        eval_str=strcat('get_',eval_str,'(',args,')');
    otherwise
        show_error('Feature not implemented.', handles);
end
command_array{2}=eval_str;

switch medium
    case 1
        tissue='water';
    case 2
        tissue='lossless';
    otherwise
        rho=str2double(get(handles.var_rho,'String'));
        c=str2double(get(handles.var_c,'String'));
        b=str2double(get(handles.var_b,'String'));
        ac=str2double(get(handles.var_atten,'String'));
        kappa=str2double(get(handles.var_kappa,'String'));
        beta=str2double(get(handles.var_beta,'String'));     
        ct=str2double(get(handles.var_ct,'String'));
        tissue=struct('wb',0,'rho',rho,'c',c,'b',b,...
            'wavelen',c/f0,'atten',ac/0.1151*100*(f0/1e6)^2,...
            'ct',ct,'kappa',kappa,'beta',beta,'atten_coeff',ac);
end                
command_array{3}=tissue;

function x=my_storage(y)
persistent my_var
if (y=='l')
    x=my_var;
    return
end
my_var=y;
x=y;


% --------------------------------------------------------------------
function ViewMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ViewMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function linMenu_Callback(hObject, eventdata, handles)
% hObject    handle to linMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.logMenu,'Checked','off')
set(hObject,'Checked','on')
axes(handles.fig_pfield);
pcolor(abs(squeeze(my_storage('l'))));
shading flat;
% figure;
% pcolor(abs(squeeze(my_storage('l'))));
% shading flat;

% --------------------------------------------------------------------
function Scalemenu_Callback(hObject, eventdata, handles)
% hObject    handle to Scalemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function logMenu_Callback(hObject, eventdata, handles)
% hObject    handle to logMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%press=20*log(abs(Pressure/max(max(max(Pressure)))));
set(handles.linMenu,'Checked','off')
set(hObject,'Checked','on')
press=my_storage('l');
press=20*log(1e-10+abs(press/max(max(max(abs(press))))));
pcolor(squeeze(press))
shading flat;
% figure
% pcolor(abs(squeeze(press)));
% shading flat;


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the GUI's status field to display a message
function show_message(msg, handles)
    set(handles.status, 'ForegroundColor', [0,0,0]);
    set(handles.status, 'String', msg);

% Update the GUI's status field to display an error
function show_error(error, handles)
    set(handles.status, 'ForegroundColor', [1,0.1,0.1]);
    if strcmp(class(error), class('String'))
        set(handles.status, 'String', error);
    else
        set(handles.status, 'String', error.message);
    end
    
% Return a transducer array created from the user's values
function xdc = get_transducer_array(h)
    % Get values
    is_csa = get(h.sel_CSA,'Value');
    is_planar = get(h.sel_planar,'Value');
    is_singular = get(h.sel_singular,'Value');
    is_ssa = get(h.sel_SSA,'Value');
    
    is_circ = get(h.sel_circ,'Value');
    is_tri = get(h.sel_tri,'Value');
    is_rect = get(h.sel_rect,'Value');
    is_shel = get(h.sel_shel,'Value');
    
    nelex = str2double(get(h.var_nelex,'String'));
    neley = str2double(get(h.var_neley,'String'));
    xspacing = str2double(get(h.var_xspac,'String'));
    yspacing = str2double(get(h.var_yspac,'String'));
    r_curv = str2double(get(h.var_array_rad_curv,'String'));
    dvar1 = str2double(get(h.dvar_1,'String'));
    dvar2 = str2double(get(h.dvar_2,'String'));
    % Try a few formats to read in center and euler
    g_center = get(h.var_center,'String');
    g_euler = get(h.var_euler,'String');
    
    center = sscanf(g_center,'%f %f %f',3);
    if strcmp(center, '')
        center = sscanf(g_center,'[%f %f %f]',3);
    end
    if strcmp(center, '')
        center = sscanf(g_center,'(%f %f %f)',3);
    end
    if strcmp(center, '')
        center = sscanf(g_center,'(%f, %f, %f)',3);
    end
    if strcmp(center, '')
        center = sscanf(g_center,'(%f,%f,%f)',3);
    end
    if strcmp(center, '')
        center = [0 0 0];
    end
        
    euler = sscanf(g_euler,'%f %f %f',3);
    if strcmp(euler, '')
        euler = sscanf(g_euler,'[%f %f %f]',3);
    end
    if strcmp(euler, '')
        euler = sscanf(g_euler,'(%f %f %f)',3);
    end
    if strcmp(euler, '')
        euler = sscanf(g_euler,'(%f, %f, %f)',3);
    end
    if strcmp(euler, '')
        euler = sscanf(g_euler,'(%f,%f,%f)',3);
    end
    if strcmp(euler, '')
        euler = [0 0 0];
    end
    
    ang_open = str2double(get(h.var_ang_open,'String'));
    overlap = get(h.allow_overlap,'Value');
    
    % Check values
    if (nelex == 0 || neley == 0) && ~is_singular && ~(nelex ~= 0 && is_ssa)
        error('Number of elements must be greater than zero.');        
    end
    
    % CSA
    if is_csa
        if is_circ
            if overlap
                xdc = create_circ_csa(nelex,neley,dvar1,xspacing,yspacing,r_curv,1);
            else
                xdc = create_circ_csa(nelex,neley,dvar1,xspacing,yspacing,r_curv);
            end
            return;
        elseif is_tri
            % xdc = create_tri_csa();
            error('Triangular transducers not implemented.');
        elseif is_rect
            if overlap
                xdc = create_rect_csa(nelex,neley,dvar1,dvar2,xspacing,yspacing,r_curv,1);
            else
                xdc = create_rect_csa(nelex,neley,dvar1,dvar2,xspacing,yspacing,r_curv);
            end
            return;
        elseif is_shel
            error('Cannot create array.');
        end
    % Planar
    elseif is_planar
        if is_circ
            if overlap
                xdc = create_circ_planar_array(nelex,neley,dvar1,xspacing,yspacing,center,1);
            else
                xdc = create_circ_planar_array(nelex,neley,dvar1,xspacing,yspacing,center);
            end
            return;
        elseif is_tri
            % xdc = create_tri_planar_array();
            error('Triangular transducers not implemented.');
        elseif is_rect
            if overlap
                xdc = create_rect_planar_array(nelex,neley,dvar1,dvar2,xspacing,yspacing,center,1);
            else
                xdc = create_rect_planar_array(nelex,neley,dvar1,dvar2,xspacing,yspacing,center);
            end
            return;
        elseif is_shel
            if overlap
                xdc = create_spherical_shell_planar_array(nelex,neley,1,dvar1,xspacing,yspacing,center,1);
            else
                xdc = create_spherical_shell_planar_array(nelex,neley,1,dvar1,xspacing,yspacing,center);
            end
            return;
        end
    % Singular
    elseif is_singular
        if is_circ
            xdc = get_circ(dvar1,center,euler,0);
            return;
        elseif is_tri
            % xdc = get_tri();
            error('Triangular transducers not implemented.');
        elseif is_rect
            xdc = get_rect(dvar1,dvar2,center,euler);
            return;
        elseif is_shel
            xdc = get_spherical_shell(dvar1,r_curv,center,euler);
            return;
        end
    % SSA
    elseif is_ssa
        if is_circ
            xdc = create_circ_ssa(dvar1,r_curv,nelex,ang_open);
            return;
        elseif is_tri
            % xdc = create_tri_ssa();
            error('Triangular transducers not implemented.');
        elseif is_rect
            xdc = create_rect_ssa(dvar1,dvar2,r_curv,nelex,ang_open);
        elseif is_shel
            error('Cannot create array.');
        end
    end
 
% Return a medium object based on values entered
function m = get_medium(h)
    cb = 3480;
    wb = 2*pi;
    rho = str2double(get(h.var_rho,'String'));
    c_sound = str2double(get(h.var_c,'String'));
    b = str2double(get(h.var_b,'String'));
    atten = str2double(get(h.var_atten,'String'));
    ct = str2double(get(h.var_ct,'String'));
    kappa = str2double(get(h.var_kappa,'String'));
    beta = str2double(get(h.var_beta,'String'));
    
    m = set_medium(cb,wb,rho,c_sound,b,atten,ct,kappa,beta);
    
% Return a coordinate grid based on the values entered by the user
% On error, return an empty array
function cg = get_coordinate_grid(h)
    xs = str2double(get(h.var_xmin,'String'));
    ys = str2double(get(h.var_ymin,'String'));
    zs = str2double(get(h.var_zmin,'String'));
    xe = str2double(get(h.var_xmax,'String'));
    ye = str2double(get(h.var_ymax,'String'));
    ze = str2double(get(h.var_zmax,'String'));

    dx = str2double(get(h.var_deltax,'String'));
    dy = str2double(get(h.var_deltay,'String'));
    dz = str2double(get(h.var_deltaz,'String'));
    
    plane_type=(get(get(h.planes,'SelectedObject'),'Tag'));
    
    % Check values
    if xs == xe || ys == ye || zs == ze
        if ~((strcmp(plane_type, 'sel_xy') && zs == ze) || (strcmp(plane_type, 'sel_xz') && ys == ye) || (strcmp(plane_type, 'sel_yz') && xs == xe))
            show_error('Bad coordinate plane; please ensure that all dimensions have a length greater than zero.', h);
            cg = [];
            return;
        end
    end
    
    if (dx == 0 && ~strcmp(plane_type, 'sel_yz')) || (dy == 0 && ~strcmp(plane_type, 'sel_xz')) || (dz == 0 && ~strcmp(plane_type, 'sel_xy'))
        show_error('dx, dy, and dz must be greater than zero.', h);
        cg = [];
        return;
    end
    
    % Modify deltas based on selected plane
    switch(plane_type)
        case 'sel_xy'
            zs = ze;
            dz = ze + 1;
        case 'sel_xz'
            ys = ye;
            dy = ye + 1;
        case 'sel_yz'
            xs = xe;
            dx = xe + 1;
    end
        
    cg = set_coordinate_grid([ dx dy dz ], xs, xe, ys, ye, zs, ze);

% --- Executes on button press in allow_overlap.
function allow_overlap_Callback(hObject, eventdata, handles)
% hObject    handle to allow_overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allow_overlap



function var_ang_open_Callback(hObject, eventdata, handles)
% hObject    handle to var_ang_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_ang_open as text
%        str2double(get(hObject,'String')) returns contents of var_ang_open
%        as a double


% --- Executes during object creation, after setting all properties.
function var_ang_open_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_ang_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_browse.
function button_browse_Callback(hObject, eventdata, handles)
% hObject    handle to button_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname,fpath,filterindex] = uiputfile('.m','Create File');
if fname ~= 0
    set(handles.var_fname,'String',strcat(fpath,fname));
end


% --- Executes on button press in button_save_plot.
function button_save_plot_Callback(hObject, eventdata, handles)
% hObject    handle to button_save_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname,fpath,filterindex] = uiputfile({'.jpeg','JPEG (*.jpeg)';'.png','Portable Network Graphics (*.png)';'.tiff','Tagged Image File Format (*.tiff)'},'Save Plot','pressure-field');
if fname ~= 0
    % Create an invisible figure containing just the pressure plot and save that
    h = figure(2);
    set(h,'Visible','Off');
    s = subplot(1,1,1);
    copyobj(allchild(handles.fig_pfield), s);
    switch(filterindex)
        case 1
            saveas(s,fullfile(fpath,fname),'jpeg');
        case 2
            saveas(s,fullfile(fpath,fname),'png');
        case 3
            saveas(s,fullfile(fpath,fname),'tiffn');
    end
    delete(h);
end


% --- Executes on button press in button_load_params.
function button_load_params_Callback(hObject, eventdata, handles)
% hObject    handle to button_load_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Set up XML DOM object
[fname,fpath,filterindex] = uigetfile('.xml','Load Parameters');
if fname ~= 0
    [xdc_array, medium, coordinate_grid, params] = load_simulation_parameters(strcat(fpath, fname));
    % Write data to form
    % Transducers
    % First, determine the shape (assume all transducers are the same)
    xdc_shape = xdc_array(1).shape;
    % Not sure how to do this one yet
    % Medium
    set(handles.var_rho, 'String', medium.rho);
    set(handles.var_c, 'String', medium.c_sound);
    set(handles.var_b, 'String', medium.b);
    set(handles.var_atten, 'String', medium.atten_coeff);
    set(handles.var_ct, 'String', medium.ct);
    set(handles.var_kappa, 'String', medium.kappa);
    set(handles.var_beta, 'String', medium.beta);
    % Coordinate grid
    set(handles.var_deltax, 'String', coordinate_grid.delta(1));
    set(handles.var_deltay, 'String', coordinate_grid.delta(2));
    set(handles.var_deltaz, 'String', coordinate_grid.delta(3));
    
    set(handles.var_xmin, 'String', coordinate_grid.xmin);
    set(handles.var_xmax, 'String', coordinate_grid.xmax);
    set(handles.var_ymin, 'String', coordinate_grid.ymin);
    set(handles.var_ymax, 'String', coordinate_grid.ymax);
    set(handles.var_zmin, 'String', coordinate_grid.zmin);
    set(handles.var_zmax, 'String', coordinate_grid.zmax);
    
    set(handles.var_f0, 'String', params.f0);
    set(handles.var_fs, 'String', params.fs);
end

% --- Executes on button press in button_save_params.
% Create simulation-related objects and write to XML file
function button_save_params_Callback(hObject, eventdata, handles)
% hObject    handle to button_save_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Set up XML DOM object
% Get data from form
xdc = get_transducer_array(handles);
medium = get_medium(handles);
cg = get_coordinate_grid(handles);

f0 = get(handles.var_f0, 'String');
fs = get(handles.var_fs, 'String');

[fname,fpath,filterindex] = uiputfile('.xml','Save Parameters','fnm-params.xml');

if fname ~= 0
    if save_simulation_parameters(xdc, medium, cg, f0, fs, strcat(fpath,fname))
        show_message('Simulation parameters saved.',handles);
    else
        show_error('An error ocurred while saving the simulation parameters.',handles);
    end
end

% --------------------------------------------------------------------
function menu_save_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_save_params_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menu_save_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_save_plot_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menu_run_fnm_Callback(hObject, eventdata, handles)
% hObject    handle to menu_run_fnm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_fnm_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menu_quit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_exit_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menu_load_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_load_params_Callback(hObject, eventdata, handles)



function var_tolerance_Callback(hObject, eventdata, handles)
% hObject    handle to var_tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_tolerance as text
%        str2double(get(hObject,'String')) returns contents of var_tolerance as a double


% --- Executes during object creation, after setting all properties.
function var_tolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
