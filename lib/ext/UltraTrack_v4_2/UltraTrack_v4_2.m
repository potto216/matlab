function varargout = UltraTrack_v4_2(varargin)
% ULTRATRACK_V4_2 M-file for UltraTrack_v4_2.fig
%      ULTRATRACK_V4_2, by itself, creates a new ULTRATRACK_V4_2 or raises the existing
%      singleton*.
%      H = ULTRATRACK_V4_2 returns the handle to a new ULTRATRACK_V4_2 or the handle to
%      the existing singleton*.
%
%      ULTRATRACK_V4_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULTRATRACK_V4_2.M with the given input arguments.
%
%      ULTRATRACK_V4_2('Property','Value',...) creates a new ULTRATRACK_V4_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UltraTrack_v4_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UltraTrack_v4_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UltraTrack_v4_2

% Last Modified by GUIDE v2.5 02-Mar-2016 10:16:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UltraTrack_v4_2_OpeningFcn, ...
                   'gui_OutputFcn',  @UltraTrack_v4_2_OutputFcn, ...
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


% --- Executes just before UltraTrack_v4_2 is made visible.
function UltraTrack_v4_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UltraTrack_v4_2 (see VARARGIN)

% Choose default command line output for UltraTrack_v4_2
handles.output = hObject;

% check to make sure there is a settings mat-file present, if not then make
% one in the directory where the m-file sits.
[program_directory, ~, ~] = fileparts(mfilename('fullpath'));

if ismac || isunix
    if isempty(dir([program_directory '/ultrasound_tracking_settings.mat']))
        ImageDepth = 65;
        Sigma = 3;
        S_Step = 3;
        Position = get(gcf,'Position');
        Default_Directory = cd;
        save([program_directory '/ultrasound_tracking_settings.mat'], 'ImageDepth', 'Sigma',...
            'S_Step', 'Position', 'Default_Directory');
    else
        load ultrasound_tracking_settings.mat
    end
end

if ispc
    if isempty(dir([program_directory '\ultrasound_tracking_settings.mat']))
        ImageDepth = 65;
        Sigma = 3;
        S_Step = 3;
        Position = get(gcf,'Position');
        Default_Directory = cd;
        save([program_directory '\ultrasound_tracking_settings.mat'], 'ImageDepth', 'Sigma',...
            'S_Step', 'Position', 'Default_Directory');
        
        else
            load ultrasound_tracking_settings.mat
    end
    
end

% load the settings mat-file and set default settings
handles.ID = ImageDepth;
set(handles.ImDepthEdit,'String',num2str(ImageDepth));
handles.SIGMA = Sigma;
handles.S_STEP = S_Step;
set(0,'RecursionLimit',3000)
set(gcf,'DoubleBuffer','on','Position',Position);
%cd(Default_Directory)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UltraTrack_v4_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function menu_load_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% First clean up some variables from any previously loaded files
if isfield(handles,'movObj')
    handles = rmfield(handles,'movObj');
end
if isfield(handles,'BIm')
    handles=rmfield(handles,'BIm');
    handles=rmfield(handles,'Bheader');
end

if isfield(handles,'ImStack')
    handles=rmfield(handles,'ImStack');
end

if isfield(handles,'Region')
    handles = rmfield(handles,'Region');
end

if ~isempty(get(handles.keyframe_list,'String'))
    set(handles.keyframe_list,'String',[])
end

if isfield(handles,'crop_rect')
    handles.crop_rect = [];
end
    

version = ver;
% do some checking to make sure the image processing toolbox is available
if isempty(strfind([version.Name],'Image Processing Toolbox'))
   error('This application requires the Matlab Image Processing Toolbox to be installed') 
end

% determine the release date and use the appropriate file loading function 
% newer versions > 2010b use VideoReader, older versions use mmreader
if datenum(version(1).Date) >= 734353
    reader = 'VideoReader';
else reader = 'mmreader';
end

% if post 2010a version of Matlab then look at the available video formats
% for the list
if datenum(version(1).Date) >= 734202 
    %determine the available video formats 
    file_formats = eval([reader '.getFileFormats']);
    format_list{1,1} = [];
    format_list{1,2} = 'All Video Files (';
    for i = 1:length(file_formats)
        format_list{1,1} = [format_list{1,1} '*.' file_formats(i).get.Extension ';'];
        format_list{1,2} = [format_list{1,2} file_formats(i).get.Description ', '];
        format_list{i+1,1} = ['*.' file_formats(i).get.Extension];
        format_list{i+1,2} = ['*.' file_formats(i).get.Extension ' - ' file_formats(i).get.Description];
    end

    format_list{1,2} = [format_list{1,2}(1:end-2) ')'];
    
    newlist = strcat(format_list{1,1},'*.b32;*.b8;*.mat');% add some options that we can use

    %load the avi file
    [handles.fname, handles.pname] = uigetfile(newlist, 'Pick a movie file');

else % pre 2010a mmreader function cannot use the getFileFormats method so only allow AVI files to be selected
    [handles.fname, handles.pname] = uigetfile('*.avi', 'Pick a movie file');
end

if isequal(handles.fname,0) || isequal(handles.pname,0)
       return;
end

mb = waitbar(0,'Loading Video....');
cd (handles.pname)    
[~,~,Ext]=fileparts([handles.pname handles.fname]);

if strcmp(Ext,'.b32')||strcmp(Ext,'.b8')
    
    [BIm,Bheader] = RPread([handles.pname handles.fname]); %read in the .b32 file
    
    handles.ImStack = BIm / max(max(max(BIm)));
    handles.NumFrames = size(BIm,3); % get the number of image frames
    handles.vidHeight = (Bheader.bl(2)-1)-(Bheader.ul(2)+1); % get the height in pixels of the images
    handles.vidWidth = (Bheader.br(1)-1)-(Bheader.bl(1)+1); % get the width in pixels
    handles.FrameRate = Bheader.dr;
    
    waitbar(0.5,mb)
    
elseif strcmp(Ext,'.mat')
    
    load([handles.pname handles.fname])
    handles.ImStack = TVDdata.Im;
    handles.vidHeight = double(TVDdata.Height);
    handles.vidWidth = double(TVDdata.Width);
    handles.NumFrames = double(TVDdata.Fnum);
    handles.TimeStamps = double(TVDdata.Time)/1000;
    handles.FrameRate = round(1/(handles.TimeStamps(end)/handles.NumFrames));
     
    
else
    
    switch reader
        case 'VideoReader'
            handles.movObj = VideoReader([handles.pname handles.fname]);
            
            handles.vidHeight = handles.movObj.Height;
            handles.vidWidth = handles.movObj.Width;
            
            i=1;
            while hasFrame(handles.movObj)
                waitbar(handles.movObj.CurrentTime/handles.movObj.Duration,mb)
                if regexp(handles.movObj.VideoFormat,'RGB')
                    handles.ImStack(:,:,i) = rgb2gray(readFrame(handles.movObj));
                else
                    handles.ImStack = readFrame(handles.movObj);
                end
                i=i+1;
            end
            handles.NumFrames = size(handles.ImStack,3);
            handles.FrameRate = handles.NumFrames/handles.movObj.Duration;
            
        case 'mmreader' % pre R2010b uses mmreader
            handles.movObj = eval([reader '([handles.pname handles.fname])']);
            handles.NumFrames = handles.movObj.NumberOfFrames;
            handles.vidHeight = handles.movObj.Height;
            handles.vidWidth = handles.movObj.Width;
            handles.FrameRate = handles.movObj.NumberOfFrames/handles.movObj.Duration;
            
            for i = 1:handles.NumFrames
                cdata = read(handles.movObj,i);
                waitbar(i/handles.NumFrames,mb)
                % create image from movie frame
                if regexp(handles.movObj.VideoFormat,'RGB')
                    handles.ImStack(:,:,i) = rgb2gray(cdata);
                else
                    handles.ImStack(:,:,i) = cdata;
                end
                clear cdata
            end
            
    end
    
 
end

% display the path and name of the file in the filename text box
set(handles.filename,'String',[handles.pname handles.fname])

% set the string in the frame_number box to the current frame value (1)
set(handles.frame_number,'String',num2str(1))

handles.start_frame = 1;

% set the limits on the slider - use number of frames to set maximum (min =
% 1)
set(handles.frame_slider,'Min',1);
set(handles.frame_slider,'Max',handles.NumFrames);
set(handles.frame_slider,'Value',1);
set(handles.frame_slider,'SliderStep',[1/handles.NumFrames 10/handles.NumFrames]);


% set the image croppable area to the maximum area
if ~isfield(handles,'crop_rect')||isempty(handles.crop_rect)
    
    if strcmp(Ext,'.b32')||strcmp(Ext,'.b8')
        
        handles.crop_rect = [Bheader.ul(1),Bheader.ul(2),...
            handles.vidWidth handles.vidHeight];
        
    else
        
        handles.crop_rect = [1 1 handles.vidWidth handles.vidHeight];
        
    end
end

handles.Xmin = 0;
% handles.Xmax = handles.vidWidth;

cd(handles.pname)

% make a timeline which corresponds to the ultrasound frame data
% make a timeline which corresponds to the ultrasound frame data
if strcmp(Ext,'.mat')
    handles.Time = handles.TimeStamps;
else
    handles.Time = (double(1/handles.FrameRate):double(1/handles.FrameRate):double(handles.NumFrames/handles.FrameRate))';
end
handles.KeyframeInd = logical(0.0);

if exist('TrackingData','var')
    chkload = questdlg('Do you want to load previous tracking?','Tracking data detected','Yes');
    if strcmp(chkload,'Yes')
        
        handles.Region = TrackingData.Region;
        handles.start_frame = TrackingData.start_frame;
        handles.NumFrames = TrackingData.NumFrames;
        set(handles.frame_slider,'Min',1);
        set(handles.frame_slider,'Max',handles.NumFrames);
        set(handles.frame_slider,'Value',1);
        set(handles.frame_slider,'SliderStep',[1/handles.NumFrames 5/handles.NumFrames]);
        % set the string in the frame_number to 1
        set(handles.frame_number,'String',1);
    end
end
% update the image axes using show_image function (bottom)
set(handles.StopButton,'Value',0.0)
show_image(hObject,handles)
waitbar(1,mb)
close(mb)

% --- Outputs from this function are returned to the command line.
function varargout = UltraTrack_v4_2_OutputFcn(~, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cut_frames_before.
function cut_frames_before_Callback(hObject, eventdata, handles)
% hObject    handle to cut_frames_before (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'movObj')||isfield(handles,'BIm')||isfield(handles,'ImStack')
    
    frame_no = round(get(handles.frame_slider,'Value'));
    
    handles.start_frame = frame_no + handles.start_frame;
       
    handles.NumFrames = handles.NumFrames-handles.start_frame+1;
    
    set(handles.frame_slider,'Min',1);
    set(handles.frame_slider,'Max',handles.NumFrames);
    set(handles.frame_slider,'Value',1);
    set(handles.frame_slider,'SliderStep',[1/handles.NumFrames 5/handles.NumFrames]);
    
    % set the string in the frame_number to 1
    set(handles.frame_number,'String',1);

    % update the image axes using show_image function (bottom)
    show_image(hObject,handles)
end

% --- Executes on button press in cut_frames_after.
function cut_frames_after_Callback(hObject, eventdata, handles)
% hObject    handle to cut_frames_after (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'movObj')||isfield(handles,'BIm')||isfield(handles,'ImStack')
    frame_no = round(get(handles.frame_slider,'Value'));
    
    handles.NumFrames = frame_no;   
    
    set(handles.frame_slider,'Min',1);
    set(handles.frame_slider,'Max',handles.NumFrames);
    set(handles.frame_slider,'Value',handles.NumFrames);
    set(handles.frame_slider,'SliderStep',[1/handles.NumFrames 5/handles.NumFrames]);
    
    % set the string in the frame_number to 1
    set(handles.frame_number,'String',frame_no);

    % update the image axes using show_image function (bottom)
    show_image(hObject,handles)
end

% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% get the current value from the slider (round to ensure it is integer)
frame_no = round(get(handles.frame_slider,'Value'));

% set the string in the frame_number box to the current frame value
set(handles.frame_number,'String',num2str(frame_no));

% update the image axes using show_image function (bottom)
show_image(hObject,handles)

% --- Executes during object creation, after setting all properties.
function frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.


if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function frame_number_Callback(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_number as text
%        str2double(get(hObject,'String')) returns contents of frame_number as a double


frame_no = str2num(get(handles.frame_number,'String'));
set(handles.frame_slider,'Value',round(frame_no));

% update the image axes using show_image function (bottom)
show_image(hObject,handles)

% --- Executes during object creation, after setting all properties.
function frame_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -----------------------------------------------
% -----------------------------------------------
function goto_next_frame(hObject, handles)

if get(handles.autorun_but,'BackgroundColor') == [0 1 0]

% get the current value from the slider (round to ensure it is integer)
frame_no = round(get(handles.frame_slider,'Value'))+1;

if frame_no < get(handles.frame_slider,'Max')
    % set the slider
    set(handles.frame_slider,'Value',frame_no);
    % set the string in the frame_number box to the current frame value
    set(handles.frame_number,'String',num2str(frame_no));
else  handles.run = 0;
    set(handles.autorun_but,'BackgroundColor',[1 0 0]);
end

% update the image axes using show_image function (bottom)
show_image(hObject,handles)

end


% --- Executes on button press in define_roi.
function define_roi_Callback(hObject, eventdata, handles)
% hObject    handle to define_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    
    axes(handles.axes1)
    
    frame_no = round(get(handles.frame_slider,'Value'));
    
    i = get(handles.no_tracked_regions,'Value');
    [handles.Region(i).ROI{frame_no},handles.Region(i).ROIx{frame_no},...
        handles.Region(i).ROIy{frame_no}] = roipoly;
    handles.CIm = handles.Im;
    
    show_image(hObject,handles)
    
end

% --- Executes on button press in FixedROI_on.
function FixedROI_on_Callback(hObject, eventdata, handles)
% hObject    handle to FixedROI_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FixedROI_on

% --- Executes on button press in define_fascicle.
function define_fascicle_Callback(hObject, eventdata, handles)
% hObject    handle to define_fascicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    
    % find current frame number from slider
    frame_no = round(get(handles.frame_slider,'Value'));
    
    i = get(handles.no_tracked_regions,'Value');
    j = get(handles.no_tracked_fascicles,'Value');
 
    % select the two points that define the fascicle line of action
    %set(handles.axes1,'XLimMode','auto')
    [p1,p2]=rbline(handles.axes1);
    handles.Region(i).Fascicle(j).fas_x{frame_no}(1) = p1(1); 
    handles.Region(i).Fascicle(j).fas_x{frame_no}(2) = p2(1);
    handles.Region(i).Fascicle(j).fas_y{frame_no}(1) = p1(2); 
    handles.Region(i).Fascicle(j).fas_y{frame_no}(2) = p2(2);

    if handles.Region(i).Fascicle(j).fas_y{frame_no}(1) > handles.Region(i).Fascicle(j).fas_y{frame_no}(2)
        handles.Region(i).Fascicle(j).fas_y{frame_no} = fliplr(handles.Region(i).Fascicle(j).fas_y{frame_no});
        handles.Region(i).Fascicle(j).fas_x{frame_no} = fliplr(handles.Region(i).Fascicle(j).fas_x{frame_no});
    end
    
    handles.Region(i).Fascicle(j).current_xy = [handles.Region(i).Fascicle(j).fas_x{frame_no};handles.Region(i).Fascicle(j).fas_y{frame_no}]';
    
    % calculate the length and pennation for the current frame
    handles.Region(i).fas_pen(frame_no,j) = atan2(abs(diff(handles.Region(i).Fascicle(j).fas_y{frame_no})),abs(diff(handles.Region(i).Fascicle(j).fas_x{frame_no})));
    scalar = handles.ID/handles.vidHeight;
    handles.Region(i).fas_length(frame_no,j) = scalar*sqrt(diff(handles.Region(i).Fascicle(j).fas_y{frame_no}).^2 + diff(handles.Region(i).Fascicle(j).fas_x{frame_no}).^2);
    
    handles.CIm = handles.Im;
    
    if ~isfield(handles.Region(i).Fascicle(j),'analysed_frames')
        handles.Region(i).Fascicle(j).analysed_frames = frame_no;
    else handles.Region(i).Fascicle(j).analysed_frames = sort([handles.Region(i).Fascicle(j).analysed_frames frame_no]);
    end
    
    show_image(hObject,handles)
    
end

% --------------------------------------------------------------------
function menu_define_fascicle_Callback(hObject, eventdata, handles)
% hObject    handle to menu_define_fascicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

define_fascicle_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_define_roi_Callback(hObject, eventdata, handles)
% hObject    handle to menu_define_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

define_roi_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_edit_current_Callback(hObject, eventdata, handles)
% hObject    handle to menu_process_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in process_all.
function process_all_Callback(hObject, eventdata, handles)
% hObject    handle to process_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    % find current frame number from slider
    frame_no = round(get(handles.frame_slider,'Value'));
    % fixed ROI?
    fx = get(handles.FixedROI_on,'Value');
    
    if ~isfield(handles.Region(1).Fascicle(1),'current_xy')
        warndlg('First frame must have fascicle and ROI defined', 'Warning');
    else
        
        h = waitbar(0,'Please wait while processing forward...');
        
        
        for i = 1:length(handles.Region)
            
            % create image from movie frame
            Im = imcrop(handles.ImStack(:,:,frame_no+handles.start_frame-1),handles.crop_rect);
            handles.CIm = Im/256;
            Im1 = double(handles.CIm); 
            
            % set some of the properties of the affine flow object
            sigmaXY = handles.SIGMA;
            sampleStep = handles.S_STEP;
            af = affine_flow('image1', Im1,'sigmaXY',sigmaXY,'sampleStep',sampleStep,...
                'regionOfInterest',handles.Region(i).ROI{frame_no});
            
            for f = frame_no+1:get(handles.frame_slider,'Max')
                % Get the current image
                Im = imcrop(handles.ImStack(:,:,handles.start_frame+f-1),handles.crop_rect);
                handles.NIm = double(Im/256);
                Im2 = double(handles.NIm);
                
                %Compute the flow and new roi for the pair of images
                [af,Nroi,Nroix,Nroiy,w] = ProcessROI(Im2,af,handles.Region(i).ROI{f-1},...
                    handles.Region(i).ROIx{f-1},handles.Region(i).ROIy{f-1},fx,...
                    handles.vidWidth,handles.vidHeight);
                %Assign variables
                handles.Region(i).warp(:,:,f) = w;
                handles.Region(i).ROI{f} = Nroi;
                handles.Region(i).ROIx{f} = Nroix;
                handles.Region(i).ROIy{f} = Nroiy;
                
                % Now process each fascicle
                image_scale = handles.ID/handles.vidHeight;
                for j = 1:length(handles.Region(i).Fascicle)
                    
                    if isfield(handles.Region(i).Fascicle(j),'fas_y_corr') && ~isempty(handles.Region(i).Fascicle(j).fas_y_corr)
                        handles.Region(i).Fascicle(j).fas_x = handles.Region(i).Fascicle(j).fas_x_corr;
                        handles.Region(i).Fascicle(j).fas_y = handles.Region(i).Fascicle(j).fas_y_corr;
                        handles.Region(i).Fascicle(j).fas_y_corr = [];
                        handles.Region(i).Fascicle(j).fas_x_corr = [];
                        handles.Region(i).fas_length_corr = [];
                        handles.Region(i).fas_pen_corr = [];
                    end
                    
                    % Compute coords, pennation and fas length in Im2
                    [Nfasx,Nfasy,fl,pen] = ProcessFascicle(handles.Region(i).Fascicle(j).fas_x{f-1},...
                        handles.Region(i).Fascicle(j).fas_y{f-1}, w, image_scale);
                    % Assign variables
                    handles.Region(i).Fascicle(j).fas_x{f} = Nfasx';
                    handles.Region(i).Fascicle(j).fas_y{f} = Nfasy';
                    handles.Region(i).fas_pen(f,j) = pen;
                    handles.Region(i).fas_length(f,j) = fl;
                    % Mark that frame as having been analysed
                    handles.Region(i).Fascicle(j).analysed_frames = ...
                        sort([handles.Region(i).Fascicle(j).analysed_frames f]);
                end

                waitbar((f+(get(handles.frame_slider,'Max')*(i-1)))/...
                    (get(handles.frame_slider,'Max')*length(handles.Region)),h)
            end
        end
        close(h)
        
        
        if frame_no > 1 % if the original digitised frame is not the first - work backwards too
            h = waitbar(0,'Please wait while processing backward...');
            for i = 1:length(handles.Region)
                
                % create image from movie frame
                Im = imcrop(handles.ImStack(:,:,frame_no+handles.start_frame-1),handles.crop_rect);
                handles.CIm = Im/256;
                Im1 = double(handles.CIm);
                
                % set some of the properties of the affine flow object
                sigmaXY = handles.SIGMA;
                sampleStep = handles.S_STEP;
                af = affine_flow('image1', Im1,'sigmaXY',sigmaXY,'sampleStep',sampleStep,...
                    'regionOfInterest',handles.Region(i).ROI{frame_no});
                
                for f = fliplr(get(handles.frame_slider,'Min'):frame_no-1)
                    % Get the current image
                    Im = imcrop(handles.ImStack(:,:,handles.start_frame+f-1),handles.crop_rect);
                    handles.NIm = double(Im/256);
                    Im2 = double(handles.NIm);
                    
                    %Compute the flow and new roi for the pair of images
                    [af,Nroi,Nroix,Nroiy,w] = ProcessROI(Im2,af,handles.Region(i).ROI{f+1},...
                        handles.Region(i).ROIx{f+1},handles.Region(i).ROIy{f+1},fx,...
                        handles.vidWidth,handles.vidHeight);
                    %Assign variables
                    handles.Region(i).warp(:,:,f) = w;
                    handles.Region(i).ROI{f} = Nroi;
                    handles.Region(i).ROIx{f} = Nroix;
                    handles.Region(i).ROIy{f} = Nroiy;
                    
                    % Now process each fascicle
                    image_scale = handles.ID/handles.vidHeight;
                    for j = 1:length(handles.Region(i).Fascicle)
                        
                        if isfield(handles.Region(i).Fascicle(j),'fas_y_corr') && ~isempty(handles.Region(i).Fascicle(j).fas_y_corr)
                            handles.Region(i).Fascicle(j).fas_x = handles.Region(i).Fascicle(j).fas_x_corr;
                            handles.Region(i).Fascicle(j).fas_y = handles.Region(i).Fascicle(j).fas_y_corr;
                            handles.Region(i).Fascicle(j).fas_y_corr = [];
                            handles.Region(i).Fascicle(j).fas_x_corr = [];
                            handles.Region(i).fas_length_corr = [];
                            handles.Region(i).fas_pen_corr = [];
                        end
                        
                        % Compute coords, pennation and fas length in Im2
                        [Nfasx,Nfasy,fl,pen] = ProcessFascicle(handles.Region(i).Fascicle(j).fas_x{f+1},...
                            handles.Region(i).Fascicle(j).fas_y{f+1}, w, image_scale);
                        % Assign variables
                        handles.Region(i).Fascicle(j).fas_x{f} = Nfasx';
                        handles.Region(i).Fascicle(j).fas_y{f} = Nfasy';
                        handles.Region(i).fas_pen(f,j) = pen;
                        handles.Region(i).fas_length(f,j) = fl;
                        % Mark that frame as having been analysed
                        handles.Region(i).Fascicle(j).analysed_frames = ...
                            sort([handles.Region(i).Fascicle(j).analysed_frames f]);
                    end
                    
                    waitbar((f+(frame_no*(length(handles.Region)-i)))/...
                        (frame_no*length(handles.Region)),h)
                end
            end
            close(h)
        end
        
    end
    
    
    
    set(handles.frame_slider,'Value',frame_no);
    set(handles.frame_number,'String',num2str(frame_no));
    
    % update the image axes using show_image function (bottom)
    show_image(hObject,handles)
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in clear_fascicle.
function clear_fascicle_Callback(hObject, eventdata, handles)
% hObject    handle to clear_fascicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    if isfield(handles,'Region')
        handles = rmfield(handles,'Region');
    end
            
    if ~isempty(get(handles.keyframe_list,'String'))
        set(handles.keyframe_list,'String',[])
    end
    
    set(handles.no_tracked_regions,'Value',1,'String','1')
    set(handles.no_tracked_fascicles,'Value',1,'String','1')
    set(handles.RegionsToCorrect,'String',{'all','1'},'Value',1);
    set(handles.FasciclesToCorrect,'String',{'all','1'},'Value',1);

             
    % set current frame to 1
    set(handles.frame_slider,'Value',1);
    set(handles.frame_number,'String',1);
    
    axes(handles.length_plot)
    cla
    
    show_image(hObject,handles)
end

% --- Executes on button press in add_keyframe.
function add_keyframe_Callback(hObject, eventdata, handles)
% hObject    handle to add_keyframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    
    % find current frame number from slilder
    frame_no = num2str(round(get(handles.frame_slider,'Value')));
    
    contents = get(handles.keyframe_list,'String');
    
    if isempty(contents)
        set(handles.keyframe_list,'String',{frame_no})        
    else
        c = cellfun(@str2double,contents);
        c = sort([c;str2double(frame_no)]);
        for i = 1:length(c)
            newcontents{i} = num2str(c(i));
        end
        set(handles.keyframe_list,'String',newcontents)
    end
    
    set(handles.keyframe_list,'Value',length(get(handles.keyframe_list,'String')))
    
end


% --- Executes on selection change in keyframe_list.
function keyframe_list_Callback(hObject, eventdata, handles)
% hObject    handle to keyframe_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns keyframe_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from keyframe_list

if isfield(handles,'ImStack')
    
    contents = cellstr(get(hObject,'String'));
    
    if ~isempty(contents)

        frame_no = str2double(contents{get(hObject,'Value')});

        % set the frame slider to the new frame value
        set(handles.frame_slider,'Value',frame_no);

        % set the string in the frame_number box to the current frame value
        set(handles.frame_number,'String',num2str(frame_no));
        
        show_image(hObject,handles)
        
    end

end

% --- Executes during object creation, after setting all properties.
function keyframe_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to keyframe_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in delete_keyframes.
function delete_keyframes_Callback(hObject, eventdata, handles)
% hObject    handle to delete_keyframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    
    contents = get(handles.keyframe_list,'String');
    
    if ~isempty(contents)
        contents(get(handles.keyframe_list,'Value'))=[];
        set(handles.keyframe_list,'Value',1);
        set(handles.keyframe_list,'String',contents);
    end
end

% --- Executes on button press in correct_keyframes.
function correct_keyframes_Callback(hObject, eventdata, handles)
% hObject    handle to correct_keyframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack') && length(get(handles.keyframe_list,'String'))>1;
    
    %First check which regions the user wishes to apply the correction to
    %and create a variable to manage the iterations of the for loop later
    SelectedRegions = get(handles.RegionsToCorrect,'Value');
    RegionList = get(handles.RegionsToCorrect,'String');
    ApplyToRegions = RegionList{SelectedRegions};
    if strcmp(ApplyToRegions,'all');
        allregions = get(handles.no_tracked_regions,'String');
        Rloop = 1:length(allregions);
        Rloop(isnan(Rloop))=[];
    else
        Rloop = str2double(ApplyToRegions);
        Rloop(isnan(Rloop))=[];
    end
    %Then check which fascicles the user wishes to apply the correction to
    %and create a variable to manage the iterations of the for loop later
    SelectedFascicles = get(handles.FasciclesToCorrect,'Value');
    FasList = get(handles.FasciclesToCorrect,'String');
    ApplyToFascicles = FasList{SelectedFascicles};
    
    if strcmp(ApplyToFascicles,'all');
        for k = 1:length(RegionList)-1
            Floop{k} = 1:length(handles.Region(k).Fascicle);
        end
    else
        for k = 1:length(RegionList)-1
            Floop{k} = str2double(ApplyToFascicles);
        end
    end
    
    
    if length(find(handles.Region(Rloop(1)).fas_length(:,Floop{1}(1)) ~= 0)) == handles.NumFrames
        
        contents = get(handles.keyframe_list,'String');% Get the keyframes
        image_depth = handles.ID;% get the image depth
        
        for i = 1:length(get(handles.keyframe_list,'String')) %loop through each keyframe
            
            set(handles.keyframe_list,'Value',i)% set the selected keyframe
            
            frame_no = str2double(contents{i});% set frame # to current keyframe
            
            % set the frame slider to the new frame value
            set(handles.frame_slider,'Value',frame_no);
            
            % set the string in the frame_number box to the current frame value
            set(handles.frame_number,'String',num2str(frame_no));
            
            % Load the image for the current keyframe
            Im = imcrop(handles.ImStack(:,:,frame_no+handles.start_frame-1),handles.crop_rect);
            % make the image axes the current axes
            axes(handles.axes1)
            cla
            % show the image
            imshow(Im)
            hold on
            handles.Im = Im;
            % this image is the new image
            handles.NIm = handles.Im;
            
            %Loop through each selected region and fascicle, checking if
            %that fascicle has already had a correction done on it. If it
            %has, make the corrected value the 'uncorrected value'
            for k = Rloop(1):Rloop(end)
                for j = Floop{k}(1):Floop{k}(end)
                    if isfield(handles.Region(k).Fascicle(j),'fas_x_corr') && ~isempty(handles.Region(k).Fascicle(j).fas_x_corr)
                        handles.Region(k).Fascicle(j).fas_x = handles.Region(k).Fascicle(j).fas_x_corr;
                        handles.Region(k).Fascicle(j).fas_y = handles.Region(k).Fascicle(j).fas_y_corr;
                        handles.Region(k).Fascicle(j).fas_pen = handles.Region(k).fas_pen_corr;
                        handles.Region(k).Fascicle(j).fas_length = handles.Region(k).fas_length_corr;
                    end
                end
            end
            
            % If this is the first keyframe, this is our reference value
            % and is not required to be adjusted for drift. Thus, we do not
            % adjust it and move on to the next iteration
            if i == 1
                
                for k = Rloop(1):Rloop(end)
                    for j = Floop{k}(1):Floop{k}(end)
                        handles.Region(k).Fascicle(j).fas_x_keyframe{frame_no} = handles.Region(k).Fascicle(j).fas_x{frame_no};
                        handles.Region(k).Fascicle(j).fas_y_keyframe{frame_no} = handles.Region(k).Fascicle(j).fas_y{frame_no};
                        handles.Region(k).Fascicle(j).current_xy_keyframe(1,1) = handles.Region(k).Fascicle(j).fas_x{frame_no}(1);
                        handles.Region(k).Fascicle(j).current_xy_keyframe(1,2) = handles.Region(k).Fascicle(j).fas_y{frame_no}(1);
                        handles.Region(k).Fascicle(j).current_xy_keyframe(2,1) = handles.Region(k).Fascicle(j).fas_x{frame_no}(2);
                        handles.Region(k).Fascicle(j).current_xy_keyframe(2,2) = handles.Region(k).Fascicle(j).fas_y{frame_no}(2);
                        handles.Region(k).fas_pen_keyframe(frame_no,j) = atan2(abs(diff(handles.Region(k).Fascicle(j).fas_y_keyframe{frame_no})),...
                            abs(diff(handles.Region(k).Fascicle(j).fas_x_keyframe{frame_no})));
                        scalar = image_depth/handles.vidHeight;
                        handles.Region(k).fas_length_keyframe(frame_no,j) = scalar*sqrt(diff(handles.Region(k).Fascicle(j).fas_y_keyframe{frame_no})...
                            .^2 + diff(handles.Region(k).Fascicle(j).fas_x_keyframe{frame_no}).^2);
                    end
                end
                
                % make new image the current image for next iteration
                handles.CIm = handles.NIm;
                
            else %if it's not the first keyframe then we must compute the warp between the current keyframe and the previous one
                %setup the images and the affine flow parameters
                Im1 = double(handles.CIm)/256;
                Im2 = double(handles.NIm)/256;
                fx = get(handles.FixedROI_on,'Value');
                sigmaXY = handles.SIGMA;
                sampleStep = handles.S_STEP;
                af = affine_flow('image1', Im1, 'image2', Im2, 'sigmaXY',sigmaXY,...
                        'sampleStep',sampleStep,'regionOfInterest',handles.Region(k).ROI{last_frame});
                    
                for k = Rloop(1):Rloop(end)
                    
                    %Compute the flow and new roi for the pair of images
                    [af,Nroi,Nroix,Nroiy,w] = ProcessROI(Im2,af,handles.Region(k).ROI{last_frame},...
                        handles.Region(k).ROIx{last_frame},handles.Region(k).ROIy{last_frame},fx,...
                        handles.vidWidth,handles.vidHeight);
                    %Assign variables
                    %handles.Region(k).warp(:,:,f) = w;
                    handles.Region(k).ROI{frame_no} = Nroi;
                    handles.Region(k).ROIx{frame_no} = Nroix;
                    handles.Region(k).ROIy{frame_no} = Nroiy;
                    
                    % Now process each fascicle
                    image_scale = handles.ID/handles.vidHeight;
                    for j = Floop{k}(1):Floop{k}(end)
                        % Compute coords, pennation and fas length in Im2
                        [Nfasx,Nfasy,fl,pen] = ProcessFascicle(handles.Region(k).Fascicle(j).current_xy_keyframe(:,1),...
                            handles.Region(k).Fascicle(j).current_xy_keyframe(:,2), w, image_scale);
                        % Assign variables
                        handles.Region(k).Fascicle(j).current_xy_keyframe = [Nfasx,Nfasy];
                        handles.Region(k).Fascicle(j).fas_x_keyframe{frame_no} = Nfasx';
                        handles.Region(k).Fascicle(j).fas_y_keyframe{frame_no} = Nfasy';
                        handles.Region(k).fas_pen_keyframe(frame_no,j) = pen;
                        handles.Region(k).fas_length_keyframe(frame_no,j) = fl;
                    end
                
                end
            end
            
            % calculate the difference between the keyframe x & y coordinates
            % and the tracked x & y coordinates
            for k = Rloop(1):Rloop(end)
                for j = Floop{k}(1):Floop{k}(end)
                    
                    Region(k).Fascicle(j).DT(i) = frame_no/handles.FrameRate;
                    Region(k).Fascicle(j).Dfas_x(i,:) = handles.Region(k).Fascicle(j).fas_x_keyframe{frame_no} - handles.Region(k).Fascicle(j).fas_x{frame_no};
                    Region(k).Fascicle(j).Dfas_y(i,:) = handles.Region(k).Fascicle(j).fas_y_keyframe{frame_no} - handles.Region(k).Fascicle(j).fas_y{frame_no};
                    
                end
            end
            
            last_frame = frame_no;
        end
        
        % Create variables representing drift over time
        for k = Rloop(1):Rloop(end)
            for j = Floop{k}(1):Floop{k}(end)
                Region(k).Fascicle(j).DT = [0 Region(k).Fascicle(j).DT get(handles.frame_slider,'Max')/handles.FrameRate];
                Region(k).Fascicle(j).Dfas_x = [0 0; Region(k).Fascicle(j).Dfas_x; Region(k).Fascicle(j).Dfas_x(end,:)];
                Region(k).Fascicle(j).Dfas_y = [0 0; Region(k).Fascicle(j).Dfas_y; Region(k).Fascicle(j).Dfas_y(end,:)];
                
                % if the last keyframe is the last frame, then this frame
                % will have been duplicated and we need to remove the last
                % value from the above variables or it will cause an error
                % in the interpolation.
                if Region(k).Fascicle(j).DT(end)<=Region(k).Fascicle(j).DT(end-1)
                    Region(k).Fascicle(j).DT(end)=[];
                    Region(k).Fascicle(j).Dfas_x(size(Region(k).Fascicle(j).Dfas_x,1),:)=[];
                    Region(k).Fascicle(j).Dfas_y(size(Region(k).Fascicle(j).Dfas_y,1),:)=[];
                end
            end
        end
        
        % Now we can make the correction. Drift is assumed to be linear
        % over time and is subtracted from the x,y coordinates of the
        % fascicle in each frame
        for k = Rloop(1):Rloop(end)
            for j = Floop{k}(1):Floop{k}(end)
                
                Time = (1:length(handles.Region(k).Fascicle(j).fas_x))/handles.FrameRate;
                
                for i = 1:length(handles.Region(k).Fascicle(j).fas_x)
                    
                    handles.Region(k).Fascicle(j).fas_x_corr{i} = handles.Region(k).Fascicle(j).fas_x{i} +...
                        interp1(Region(k).Fascicle(j).DT', Region(k).Fascicle(j).Dfas_x, Time(i),'linear');
                    handles.Region(k).Fascicle(j).fas_y_corr{i} = handles.Region(k).Fascicle(j).fas_y{i} +...
                        interp1(Region(k).Fascicle(j).DT', Region(k).Fascicle(j).Dfas_y, Time(i),'linear');
                    
                    % calculate the length and pennation for the current frame
                    handles.Region(k).fas_pen_corr(i,j) = atan2(abs(diff(handles.Region(k).Fascicle(j).fas_y_corr{i})),...
                        abs(diff(handles.Region(k).Fascicle(j).fas_x_corr{i})));
                    scalar = image_depth/handles.vidHeight;
                    handles.Region(k).fas_length_corr(i,j) = scalar*sqrt(diff(handles.Region(k).Fascicle(j).fas_y_corr{i}).^2 +...
                        diff(handles.Region(k).Fascicle(j).fas_x_corr{i}).^2);
                    
                end
                clear Time
            end
        end
        
        
    end
    
    handles.KeyframeInd = logical(1.0);
    show_image(hObject, handles)
        
end

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Image_Callback(hObject, eventdata, handles)
% hObject    handle to Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Tracking_Callback(hObject, eventdata, handles)
% hObject    handle to Tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Fascicle_Callback(hObject, eventdata, handles)
% hObject    handle to Fascicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


ImageDepth = handles.ID;
Sigma = handles.SIGMA;
S_Step = handles.S_STEP;
Position = get(gcf,'Position');
Default_Directory = cd;

[directory, ~, ~] = fileparts(mfilename('fullpath'));

if ismac || isunix
    save([directory '/ultrasound_tracking_settings.mat'], 'ImageDepth', 'Sigma',...
        'S_Step', 'Position', 'Default_Directory');
end

if ispc
    save([directory '\ultrasound_tracking_settings.mat'], 'ImageDepth', 'Sigma',...
        'S_Step', 'Position', 'Default_Directory');
end

msgbox('Settings Saved')

% --------------------------------------------------------------------
function menu_affine_settings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_affine_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if ~isfield(handles, 'SIGMA')
        handles.SIGMA = 3;
    end
    
    if ~isfield(handles, 'S_STEP')
        handles.SIGMA = 3;
    end
    
    A = inputdlg({'Sigma','Sample Step'}, 'Affine Flow Settings', 1,...
        {num2str(handles.SIGMA),num2str(handles.S_STEP)});
    handles.SIGMA = str2double(A{1});
    handles.S_STEP = str2double(A{2});
    
    % Update handles structure
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_clear_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to menu_clear_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    
    if isfield(handles,'Region')
        handles = rmfield(handles,'Region');
    end

    
    if ~isempty(get(handles.keyframe_list,'String'))
        set(handles.keyframe_list,'String',[])
    end
             
    % set current frame to 1
    set(handles.frame_slider,'Value',1);
    set(handles.frame_number,'String',1);
    
    axes(handles.length_plot)
    cla
    
    show_image(hObject,handles)
    
    % Correct the drop down lists for regions and fascicles to match
    % imported data
    
    ROIlistString = {'1'};
    ROItoCorrString = {'all','1'};
    set(handles.no_tracked_regions,'String',ROIlistString);
    set(handles.RegionsToCorrect,'String',ROItoCorrString);
    
    FASlistString = {'1'};
    FAStoCorrString = {'all','1'};
    set(handles.no_tracked_fascicles,'String',FASlistString);
    set(handles.FasciclesToCorrect,'String',FAStoCorrString);
end

% --------------------------------------------------------------------
function AutoCrop_Callback(hObject, eventdata, handles)
% hObject    handle to AutoCrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Im = handles.ImStack(:,:,1);
 % work out how to trim the edges of the ultrasound (edges are intensity value of
 % 56]
 m = find(Im(:,1) == 56); % find where the image starts vertically - at top of image the gray changes from 66 to 56.
 n = find(mean((Im(end-50:end,:) == 56))<0.4); % use the averaage value of the bottom 50 rows to determine whether this is a high value (i.e. gray) or low (i.e. real image)
 
 if isempty(m)
     return;
 end
 if isempty(n)
     return;
 end
 
 handles.crop_rect = [n(find(diff(n)>1)+1) m(1) n(end)-n(find(diff(n)>1)+1) length(m)-1]; % define the new rectangle for autocroping
 handles.vidHeight = handles.crop_rect(4);
 handles.vidWidth = handles.crop_rect(3);
 % Update handles structure
 guidata(hObject, handles);
% update the image axes using show_image function (bottom)
show_image(hObject,handles)

% --------------------------------------------------------------------
function menu_crop_image_Callback(hObject, eventdata, handles)
% hObject    handle to menu_crop_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    
    % define current axes
    axes(handles.axes1)

    % use imcrop tool to determine croppable area
    [~,handles.crop_rect] = imcrop;
    
    handles.crop_rect = round(handles.crop_rect);
    handles.vidHeight = handles.crop_rect(4);
    handles.vidWidth = handles.crop_rect(3);
       
    % update the image axes using show_image function (bottom)
    show_image(hObject,handles)
    
end

% --------------------------------------------------------------------
function menu_reset_image_Callback(hObject, eventdata, handles)
% hObject    handle to menu_reset_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'movObj')||isfield(handles,'BIm')||isfield(handles,'ImStack')
    
    % set the image croppable area to the maximum area
    handles.crop_rect = [1 1 handles.vidWidth handles.vidHeight];
    
    % update the image axes using show_image function (bottom)
    show_image(hObject,handles)
    
end


% --------------------------------------------------------------------
function menu_set_depth_Callback(hObject, eventdata, handles)
% hObject    handle to menu_set_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    
    if ~isfield(handles, 'ID')
        handles.ID = 60.4;
    end
    
    A = inputdlg('Enter image depth', 'Image Depth', 1, {num2str(handles.ID)});
    handles.ID = str2double(A{1});
    
    set(handles.ImDepthEdit, 'String',A{1})
    
    % Update handles structure
    guidata(hObject, handles);
    
end



% --------------------------------------------------------------------
function menu_save_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'Region')
    
    Save_As_Txt_Callback(hObject,eventdata,handles);
end


% --------------------------------------------------------------------
function menu_load_fascicle_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_fascicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
            
    % find current frame number from slider
    frame_no = round(get(handles.frame_slider,'Value'));
    [fname, pname] = uigetfile('*.mat','Load tracking MAT file');
    load([pname fname]);
    
    if exist('Fdat','var') && isfield(Fdat,'Region') && isfield(Fdat.Region,'Fascicle')
            
        for i = 1:length(Fdat.Region)
            
            for k = 1:length(Fdat.Region(i).Fascicle)
                
                handles.Region(i).Fascicle(k).fas_x{frame_no} = Fdat.Region(i).Fascicle(k).fas_x;
                handles.Region(i).Fascicle(k).fas_y{frame_no} = Fdat.Region(i).Fascicle(k).fas_y;
                
                handles.Region(i).Fascicle(k).current_xy(1,1) = handles.Region(i).Fascicle(k).fas_x{frame_no}(1);
                handles.Region(i).Fascicle(k).current_xy(1,2) = handles.Region(i).Fascicle(k).fas_y{frame_no}(1);
                handles.Region(i).Fascicle(k).current_xy(2,1) = handles.Region(i).Fascicle(k).fas_x{frame_no}(2);
                handles.Region(i).Fascicle(k).current_xy(2,2) = handles.Region(i).Fascicle(k).fas_y{frame_no}(2);
                
                handles.Region(i).fas_pen(frame_no,k) = atan2(abs(diff(handles.Region(i).Fascicle(k).fas_y{frame_no})),abs(diff(handles.Region(i).Fascicle(k).fas_x{frame_no})));
                scalar = handles.ID/handles.vidHeight;
                handles.Region(i).fas_length(frame_no,k) = scalar*sqrt(diff(handles.Region(i).Fascicle(k).fas_y{frame_no}).^2 + diff(handles.Region(i).Fascicle(k).fas_x{frame_no}).^2);
                
                
                
                
                if ~isfield(handles.Region(i).Fascicle(k),'analysed_frames')
                    handles.Region(i).Fascicle(k).analysed_frames = frame_no;
                else
                    handles.Region(i).Fascicle(k).analysed_frames = sort([handles.Region(i).Fascicle(k).analysed_frames frame_no]);
                end
            end
            
            Nfascicle(i) = length(handles.Region(i).Fascicle);
            
            handles.Region(i).ROIx{frame_no} = Fdat.Region(i).ROIx;
            handles.Region(i).ROIy{frame_no} = Fdat.Region(i).ROIy;
            handles.Region(i).ROI{frame_no} = Fdat.Region(i).ROI;
            
            
        end
        Nregions = length(handles.Region);
        Nfas = max(Nfascicle);
        
        % Correct the drop down lists for regions and fascicles to match
        % imported data
        ROItoCorrString{1} = 'all';
        for i = 1:Nregions
            ROIlistString{i} = num2str(i);
            ROItoCorrString{i+1} = num2str(i);
        end
        set(handles.no_tracked_regions,'String',ROIlistString);
        set(handles.RegionsToCorrect,'String',ROItoCorrString);
        
        FAStoCorrString{1} = 'all';
        for i = 1:Nfas
            FASlistString{i} = num2str(i);
            FAStoCorrString{i+1} = num2str(i);
        end
        set(handles.no_tracked_fascicles,'String',FASlistString);
        set(handles.FasciclesToCorrect,'String',FAStoCorrString);
    else
        
        warndlg('Fascicle data not found','ERROR')
        
    end
    
    
    show_image(hObject,handles)
   
end

% --------------------------------------------------------------------
function menu_save_fascicle_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_fascicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    
    % find current frame number from slilder
    frame_no = round(get(handles.frame_slider,'Value'));
    
    for i = 1:length(handles.Region)
        for k = 1:length(handles.Region(i).Fascicle)
            
            % if fascicles have been corrected for drift then save this value
            % rather than original tracking
            if isfield(handles.Region(i).Fascicle(k),'fas_x_corr')

                Fdat.Region(i).Fascicle(k).fas_x = handles.Region(i).Fascicle(k).fas_x_corr{frame_no};
                Fdat.Region(i).Fascicle(k).fas_y = handles.Region(i).Fascicle(k).fas_y_corr{frame_no};       

            elseif isfield(handles.Region(i).Fascicle(k),'fas_x')

                Fdat.Region(i).Fascicle(k).fas_x = handles.Region(i).Fascicle(k).fas_x{frame_no};
                Fdat.Region(i).Fascicle(k).fas_y = handles.Region(i).Fascicle(k).fas_y{frame_no};

            end
            
            
        end
        % also save the ROI data
        Fdat.Region(i).ROIx = handles.Region(i).ROIx{frame_no};
        Fdat.Region(i).ROIy = handles.Region(i).ROIy{frame_no};
        Fdat.Region(i).ROI = handles.Region(i).ROI{frame_no};
    end
    
    % save to file
    [fname, pname] = uiputfile('*.mat', 'Save fascicle to MAT file');
    save([pname fname],'Fdat');
    
end


% --------------------------------------------------------------------
function menu_save_image_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    [fileout, pathout, FI] = uiputfile('*.tif', 'Save video as');
    
    if FI > 0
    IM_out = getframe(handles.axes1);
    imwrite(IM_out.cdata,[pathout fileout], 'TIFF');
    end
    
end

% --------------------------------------------------------------------
function save_video_Callback(hObject, eventdata, handles)
% hObject    handle to save_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'ImStack')
    [fileout, pathout, FI] = uiputfile('*.avi', 'Save video as');
    
    vidObj = VideoWriter([pathout fileout],'Motion JPEG AVI');
    vidObj.FrameRate = handles.FrameRate;
    open(vidObj);
    
    if FI > 0
        for i = 1:1:get(handles.frame_slider,'Max')
            set(handles.frame_slider,'Value',i)
            show_image(hObject, handles)
            F = getframe(handles.axes1);
            writeVideo(vidObj,F)
        end
    end
    close(vidObj)
    
end

% --- Executes on selection change in variable_list.
function variable_list_Callback(hObject, eventdata, handles)
% hObject    handle to variable_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns variable_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variable_list
if isfield(handles,'D')
    show_image(hObject,handles)
end

% --- Executes during object creation, after setting all properties.
function variable_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variable_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in legend_check.
function legend_check_Callback(hObject, eventdata, handles)
% hObject    handle to legend_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of legend_check
if isfield(handles,'D')
    show_image(hObject,handles)
end


% --------------------------------------------------------------------
function menu_process_all_Callback(hObject, eventdata, handles)
% hObject    handle to menu_process_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

process_all_Callback(hObject, eventdata, handles)


% --- Executes on selection change in no_tracked_fascicles.
function no_tracked_fascicles_Callback(hObject, eventdata, handles)
% hObject    handle to no_tracked_fascicles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns no_tracked_fascicles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from no_tracked_fascicles


% --- Executes during object creation, after setting all properties.
function no_tracked_fascicles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to no_tracked_fascicles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in no_tracked_regions.
function no_tracked_regions_Callback(hObject, eventdata, handles)
% hObject    handle to no_tracked_regions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns no_tracked_regions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from no_tracked_regions


% --- Executes during object creation, after setting all properties.
function no_tracked_regions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to no_tracked_regions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddRegionButton.
function AddRegionButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddRegionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Curr_ROI_list = get(handles.no_tracked_regions,'String');
if length(Curr_ROI_list)==1
    no_ROI = str2num(Curr_ROI_list);
else
    no_ROI = str2num(Curr_ROI_list{end});
end

add_ROI = [Curr_ROI_list; {num2str(no_ROI + 1)}];
set(handles.no_tracked_regions,'String',add_ROI);

Curr_ROIcorrect_list = get(handles.RegionsToCorrect,'String');
add_ROIcorr = [Curr_ROIcorrect_list; {num2str(no_ROI + 1)}];
set(handles.RegionsToCorrect,'String',add_ROIcorr)


% --- Executes on button press in AddFasButton.
function AddFasButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddFasButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Curr_FAS_list = get(handles.no_tracked_fascicles,'String');
if length(Curr_FAS_list) == 1
    no_FAS = str2num(Curr_FAS_list);
else
    no_FAS = str2num(Curr_FAS_list{end});
end
add_FAS = [Curr_FAS_list; {num2str(no_FAS + 1)}];
set(handles.no_tracked_fascicles,'String',add_FAS);

Curr_FAScorrect_list = get(handles.FasciclesToCorrect,'String');
add_FAScorr = [Curr_FAScorrect_list; {num2str(no_FAS + 1)}];
set(handles.FasciclesToCorrect,'String',add_FAScorr)


% --- Executes on selection change in RegionsToCorrect.
function RegionsToCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to RegionsToCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RegionsToCorrect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RegionsToCorrect


% --- Executes during object creation, after setting all properties.
function RegionsToCorrect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RegionsToCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FasciclesToCorrect.
function FasciclesToCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to FasciclesToCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FasciclesToCorrect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FasciclesToCorrect


% --- Executes during object creation, after setting all properties.
function FasciclesToCorrect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FasciclesToCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Save_Tracking_As_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Tracking_As (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Save_As_Txt_Callback(hObject, eventdata, handles)
% hObject    handle to Save_As_Txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'Region')
    
    for i = 1:length(handles.Region)
        
        
        if isfield(handles,'movObj')||isfield(handles,'BIm')||isfield(handles,'ImStack') && isfield(handles.Region(i),'fas_length')
            
            dt = 1/handles.FrameRate;
            time = handles.Time(handles.start_frame:handles.start_frame + length(handles.Region(i).fas_length)-1);
            
            %determine any non-zero entries in fascicle length array
            nz = logical(handles.Region(i).fas_length(:,1) ~= 0);
            
            T = time(nz)';
                
            if isfield(handles.Region(i),'fas_length_corr') && ~isempty(handles.Region(i).fas_length_corr)
                R(i).FL = handles.Region(i).fas_length_corr(nz,:)';
                R(i).PEN = handles.Region(i).fas_pen_corr(nz,:)';
                
                for j = 1:size(handles.Region(i).fas_length_corr,2)
                    if sum(handles.Region(i).fas_length_corr(nz,j)) == 0
                        
                        R(i).FL(j,:) = handles.Region(i).fas_length(nz,j)';
                        R(i).PEN(j,:) = handles.Region(i).fas_pen(nz,j)';
                        
                    end
                end
            else R(i).FL = handles.Region(i).fas_length(nz,:)';
                R(i).PEN = handles.Region(i).fas_pen(nz,:)';
            end
            
            col_head{i} = ['Time\tFascicle Length R' num2str(i) '_F1\tPennation Angle R' num2str(i) '_F1\t'];
            col_type{i} = '%3.4f\t%3.6f\t%3.6f';
            
            data_out{i} = [T R(i).FL(1,:)' R(i).PEN(1,:)'];
            
            if size(R(i).FL',2) > 1
                for k = 2:size(R(i).FL',2)

                    data_out{i} = [data_out{i} R(i).FL(k,:)' R(i).PEN(k,:)'];
                    regionlabel = num2str(i);
                    faslabel = num2str(k);
                    col_head{i} = [col_head{i} 'Fascicle Length R' regionlabel '_F' faslabel '\tPennation Angle R' regionlabel '_F' faslabel '\t'];
                    col_type{i} = [col_type{i} '\t%3.6f\t%3.6f'];
                end
            end
        end
    end
    
    header = [];
    type = [];
    dout = [];
    for i = 1:length(handles.Region)
        header = [header col_head{i}];
        type = [type col_type{i}];
        dout = [dout data_out{i}];
    end

    
    header = [header '\n'];
%     type = [type '\n'];
   
    fileout_suggest = [handles.pname handles.fname(1:end-3) 'txt'];
    [fileout, pathout] = uiputfile(fileout_suggest,'Save fascicle data as...');
    cd(pathout);           
    % open a new text file for writing
    fid = fopen(fileout,'w');
    fprintf(fid,header);
    dlmwrite(fileout,dout,'-append','delimiter','\t')
%     fprintf(fid,type,dout);

    fclose(fid);
end


% --------------------------------------------------------------------
function Save_As_Mat_Callback(hObject, eventdata, handles)
% hObject    handle to Save_As_Mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'Region')
    
    for i = 1:length(handles.Region)
        
        
        if isfield(handles,'ImStack') && isfield(handles.Region(i),'fas_length')
            
            dt = 1/handles.FrameRate;
            time = handles.Time(handles.start_frame:handles.start_frame + length(handles.Region(i).fas_length)-1);
            
            %determine any non-zero entries in fascicle length array
            nz = logical(handles.Region(i).fas_length(:,1) ~= 0);
            
            T = time(nz)';
                
            TrackingData.Region = rmfield(handles.Region,'ROI');% remove the ROI to reduce file size
            TrackingData.start_frame = handles.start_frame;
            TrackingData.NumFrames = handles.NumFrames;
            
            if isfield(handles.Region(i),'fas_length_corr') && ~isempty(handles.Region(i).fas_length_corr)
                Fdat.Region(i).FL = handles.Region(i).fas_length_corr(nz,:)';
                Fdat.Region(i).PEN = handles.Region(i).fas_pen_corr(nz,:)';
                Fdat.Region(i).Time = T';
                
                for j = 1:size(handles.Region(i).fas_length_corr,2)
                    if sum(handles.Region(i).fas_length_corr(nz,j)) == 0
                        
                        Fdat.Region(i).FL(j,:) = handles.Region(i).fas_length(nz,j)';
                        Fdat.Region(i).PEN(j,:) = handles.Region(i).fas_pen(nz,j)';
                        
                    end
                end
            else
                Fdat.Region(i).FL = handles.Region(i).fas_length(nz,:)';
                Fdat.Region(i).PEN = handles.Region(i).fas_pen(nz,:)';
                Fdat.Region(i).Time = time(nz);
            end
        end
    end
end

[~,handles.file,handles.ext] = fileparts(handles.fname);
fileout_suggest = [handles.pname handles.file '.mat'];
[fileout, pathout] = uiputfile(fileout_suggest,'Save fascicle data as...');
cd(pathout);

if exist([pathout fileout], 'file') == 2

    if exist('Data','var') && exist('Fdat','var')
        save(fileout,'-append','Fdat','Data','TrackingData')
    elseif exist('Fdat','var')
        save(fileout,'-append','Fdat','TrackingData')
    elseif exist('Data','var')
        save(fileout,'-append','Data')
    else
        warndlg('There was no data to save', 'WARNING!')
    end

else
    
    if exist('Data','var') && exist('Fdat','var')
        save(fileout,'Fdat','Data','TrackingData')
    elseif exist('Fdat','var')
        save(fileout,'Fdat','TrackingData')
    elseif exist('Data','var')
        save(fileout,'Data')
    else
        warndlg('There was no data to save', 'WARNING!')
    end
    
end



% --- Executes on button press in U_fix.
function U_fix_Callback(hObject, eventdata, handles)
% hObject    handle to U_fix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = get(handles.no_tracked_regions,'Value');
j = get(handles.no_tracked_fascicles,'Value');


if isfield(handles.Region(k).Fascicle(j),'fas_y')
    
    if isfield(handles.Region(k).Fascicle(j),'fas_y_corr') && ~isempty(handles.Region(k).Fascicle(j).fas_y_corr)
        handles.Region(k).Fascicle(j).fas_x = handles.Region(k).Fascicle(j).fas_x_corr;
        handles.Region(k).Fascicle(j).fas_y = handles.Region(k).Fascicle(j).fas_y_corr;
    else
        handles.Region(k).Fascicle(j).fas_x_corr = handles.Region(k).Fascicle(j).fas_x;
        handles.Region(k).Fascicle(j).fas_y_corr = handles.Region(k).Fascicle(j).fas_y;
        handles.Region(k).fas_length_corr(:,j) = handles.Region(k).fas_length(:,j);
        handles.Region(k).fas_pen_corr(:,j) = handles.Region(k).fas_pen(:,j);
    end
    
    % find current frame number from slilder
    frame_no = round(get(handles.frame_slider,'Value'));
    
    gcf;
    axes(handles.axes1);
    ax=gca;
    
    p = [handles.Region(k).Fascicle(j).fas_x{frame_no}(2),...
        handles.Region(k).Fascicle(j).fas_y{frame_no}(2)];
    
    Cx = handles.Region(k).Fascicle(j).fas_x{frame_no};
    Cy = handles.Region(k).Fascicle(j).fas_y{frame_no};
    
    [p1,p2]=rbline2(ax,p);
    
    handles.Region(k).Fascicle(j).fas_x_corr{frame_no}(1)=p2(1);
    handles.Region(k).Fascicle(j).fas_y_corr{frame_no}(1)=p2(2);
    
    handles.Region(k).fas_pen_corr(frame_no,j) = atan2(abs(diff(handles.Region(k).Fascicle(j).fas_y_corr{frame_no})),abs(diff(handles.Region(k).Fascicle(j).fas_x_corr{frame_no})));
    scalar = handles.ID/handles.vidHeight;
    handles.Region(k).fas_length_corr(frame_no,j) = scalar*sqrt(diff(handles.Region(k).Fascicle(j).fas_y_corr{frame_no}).^2 + diff(handles.Region(k).Fascicle(j).fas_x_corr{frame_no}).^2);
    
    
    % check if the ROI needs adjusting too
    if ~get(handles.FixedROI_on,'Value')
        answr = questdlg('Redefine Region of Interest?');
        switch answr
            case 'Yes'
                axes(handles.axes1)
                [handles.Region(k).ROI{frame_no},handles.Region(k).ROIx{frame_no},...
                    handles.Region(k).ROIy{frame_no}] = roipoly;
                
                show_image(hObject,handles)
                
            case 'No'
                
            case 'Cancel'
        end
    else
        answr = 'No';
    end
    
    wb = waitbar(0,'Recalculating ...');
    
    % create image from movie frame
    Im1 = handles.ImStack(:,:,frame_no+handles.start_frame-1);
    % crop image with current cropping value
    Im1 = double(imcrop(Im1,handles.crop_rect)/256);
    handles.CIm = Im1;
    
    sigmaXY = handles.SIGMA;
    sampleStep = handles.S_STEP;
    af = affine_flow('image1', double(Im1),'sigmaXY',...
        sigmaXY,'sampleStep',sampleStep,'regionOfInterest',handles.Region(k).ROI{frame_no});

    
    EF = get(handles.frame_slider,'Max');

        
        for i = frame_no+1:EF;
            
            if ~isempty(find(handles.Region(k).Fascicle(j).analysed_frames == i,1))
                
                Im2 = double(imcrop(handles.ImStack(:,:,i+handles.start_frame-1),handles.crop_rect)/256);
                
                fx = get(handles.FixedROI_on,'Value');
                if strcmp(answr,'Yes') && ~fx
                    %Compute the flow and new roi for the pair of images
                    [af,Nroi,Nroix,Nroiy,w] = ProcessROI(Im2,af,handles.Region(k).ROI{i-1},...
                        handles.Region(k).ROIx{i-1},handles.Region(k).ROIy{i-1},fx,...
                        handles.vidWidth,handles.vidHeight);
                    %Assign variables
                    handles.Region(k).warp(:,:,i) = w;
                    handles.Region(k).ROI{i} = Nroi;
                    handles.Region(k).ROIx{i} = Nroix;
                    handles.Region(k).ROIy{i} = Nroiy;
                end
                
                % Now process each fascicle
                image_scale = handles.ID/handles.vidHeight;
                % Compute coords, pennation and fas length in Im2
                [Nfasx,Nfasy,fl,pen] = ProcessFascicle(handles.Region(k).Fascicle(j).fas_x_corr{i-1},...
                    handles.Region(k).Fascicle(j).fas_y_corr{i-1}, handles.Region(k).warp(:,:,i), image_scale);
                % Assign variables
                handles.Region(k).Fascicle(j).fas_x_corr{i}= Nfasx';
                handles.Region(k).Fascicle(j).fas_y_corr{i} = Nfasy';
                handles.Region(k).fas_pen_corr(i,j) = pen;
                handles.Region(k).fas_length_corr(i,j) = fl;
                
            else
                
                waitbar(1,wb);
                break
                
            end
            waitbar((i-frame_no)/(EF-frame_no),wb);
        end
    
    
    close(wb)
    show_image(hObject,handles)
    
else
    warndlg('Selected Fascicle Data Not Found','WARNING')
end



% --- Executes on button press in L_fix.
function L_fix_Callback(hObject, eventdata, handles)
% hObject    handle to L_fix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = get(handles.no_tracked_regions,'Value');
j = get(handles.no_tracked_fascicles,'Value');

if isfield(handles.Region(k).Fascicle(j),'fas_y')
    
    if isfield(handles.Region(k).Fascicle(j),'fas_y_corr') && ~isempty(handles.Region(k).Fascicle(j).fas_y_corr)
        handles.Region(k).Fascicle(j).fas_x = handles.Region(k).Fascicle(j).fas_x_corr;
        handles.Region(k).Fascicle(j).fas_y = handles.Region(k).Fascicle(j).fas_y_corr;
    else
        handles.Region(k).Fascicle(j).fas_x_corr = handles.Region(k).Fascicle(j).fas_x;
        handles.Region(k).Fascicle(j).fas_y_corr = handles.Region(k).Fascicle(j).fas_y;
        handles.Region(k).fas_length_corr(:,j) = handles.Region(k).fas_length(:,j);
        handles.Region(k).fas_pen_corr(:,j) = handles.Region(k).fas_pen(:,j);
    end
    
    % find current frame number from slilder
    frame_no = round(get(handles.frame_slider,'Value'));
    
    gcf;
    axes(handles.axes1);
    ax=gca;
    
    p = [handles.Region(k).Fascicle(j).fas_x{frame_no}(1),...
        handles.Region(k).Fascicle(j).fas_y{frame_no}(1)];
    
    Cx = handles.Region(k).Fascicle(j).fas_x{frame_no};
    Cy = handles.Region(k).Fascicle(j).fas_y{frame_no};
    
    [p1,p2]=rbline2(ax,p);
    
    handles.Region(k).Fascicle(j).fas_x_corr{frame_no}(2)=p2(1);
    handles.Region(k).Fascicle(j).fas_y_corr{frame_no}(2)=p2(2);

    handles.Region(k).fas_pen_corr(frame_no,j) = atan2(abs(diff(handles.Region(k).Fascicle(j).fas_y_corr{frame_no})),abs(diff(handles.Region(k).Fascicle(j).fas_x_corr{frame_no})));
    scalar = handles.ID/handles.vidHeight;
    handles.Region(k).fas_length_corr(frame_no,j) = scalar*sqrt(diff(handles.Region(k).Fascicle(j).fas_y_corr{frame_no}).^2 + diff(handles.Region(k).Fascicle(j).fas_x_corr{frame_no}).^2);
    

    
    % check if the ROI needs adjusting too
    if ~get(handles.FixedROI_on,'Value')
        answr = questdlg('Redefine Region of Interest?');
        switch answr
            case 'Yes'
                axes(handles.axes1)
                [handles.Region(k).ROI{frame_no},handles.Region(k).ROIx{frame_no},...
                    handles.Region(k).ROIy{frame_no}] = roipoly;
                
                show_image(hObject,handles)
                
            case 'No'
                
            case 'Cancel'
        end
    else
        answr ='No';
    end
    
   wb = waitbar(0,'Recalculating ...');
   
   % create image from movie frame
    Im1 = handles.ImStack(:,:,frame_no+handles.start_frame-1);
    % crop image with current cropping value
    Im1 = double(imcrop(Im1,handles.crop_rect)/256);
    handles.CIm = Im1;
    
    sigmaXY = handles.SIGMA;
    sampleStep = handles.S_STEP;
    af = affine_flow('image1', double(Im1),'sigmaXY',...
        sigmaXY,'sampleStep',sampleStep,'regionOfInterest',handles.Region(k).ROI{frame_no});

    
    EF = get(handles.frame_slider,'Max');

        
        for i = frame_no+1:EF;
            
            if ~isempty(find(handles.Region(k).Fascicle(j).analysed_frames == i,1))
                
                Im2 = double(imcrop(handles.ImStack(:,:,i+handles.start_frame-1),handles.crop_rect)/256);
                
                fx = get(handles.FixedROI_on,'Value');
                if strcmp(answr,'Yes') && ~fx
                    %Compute the flow and new roi for the pair of images
                    [af,Nroi,Nroix,Nroiy,w] = ProcessROI(Im2,af,handles.Region(k).ROI{i-1},...
                        handles.Region(k).ROIx{i-1},handles.Region(k).ROIy{i-1},fx,...
                        handles.vidWidth,handles.vidHeight);
                    %Assign variables
                    handles.Region(k).warp(:,:,i) = w;
                    handles.Region(k).ROI{i} = Nroi;
                    handles.Region(k).ROIx{i} = Nroix;
                    handles.Region(k).ROIy{i} = Nroiy;
                end
                
                % Now process each fascicle
                image_scale = handles.ID/handles.vidHeight;
                % Compute coords, pennation and fas length in Im2
                [Nfasx,Nfasy,fl,pen] = ProcessFascicle(handles.Region(k).Fascicle(j).fas_x_corr{i-1},...
                    handles.Region(k).Fascicle(j).fas_y_corr{i-1}, handles.Region(k).warp(:,:,i), image_scale);
                % Assign variables
                handles.Region(k).Fascicle(j).fas_x_corr{i}= Nfasx';
                handles.Region(k).Fascicle(j).fas_y_corr{i} = Nfasy';
                handles.Region(k).fas_pen_corr(i,j) = pen;
                handles.Region(k).fas_length_corr(i,j) = fl;
                
            else
                
                waitbar(1,wb);
                break
                
            end
            waitbar((i-frame_no)/(EF-frame_no),wb);
        end
    
    
    close(wb)
    show_image(hObject,handles)
    
else
    warndlg('Selected Fascicle Data Not Found','WARNING')
end


% --- Executes on button press in Undo_Correction.
function Undo_Correction_Callback(hObject, eventdata, handles)
% hObject    handle to Undo_Correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i = 1:length(handles.Region)
        
        if isfield(handles.Region(i).Fascicle,'fas_x_corr')
            
            handles.Region(i).Fascicle = rmfield(handles.Region(i).Fascicle,'fas_x_corr');
            handles.Region(i).Fascicle = rmfield(handles.Region(i).Fascicle,'fas_y_corr');
            
        end
        
        if isfield(handles.Region(i).Fascicle,'fas_x_keyframe')
           handles.Region(i).Fascicle = rmfield(handles.Region(i).Fascicle,'fas_x_keyframe');
           handles.Region(i).Fascicle = rmfield(handles.Region(i).Fascicle,'fas_y_keyframe');
           handles.Region(i).Fascicle = rmfield(handles.Region(i).Fascicle,'current_xy_keyframe');
        end
end

if isfield(handles.Region, 'fas_length_corr')
    handles.Region = rmfield(handles.Region,'fas_length_corr');
    handles.Region = rmfield(handles.Region,'fas_pen_corr');
    handles.Region = rmfield(handles.Region,'fas_pen_keyframe');
    handles.Region = rmfield(handles.Region,'fas_length_keyframe');
    
end

handles.KeyframeInd = logical(0.0);
show_image(hObject,handles)
            


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key,'rightarrow')
    % get the current value from the slider (round to ensure it is integer)
    % and add one to make the new frame number
    frame_no = round(get(handles.frame_slider,'Value'))+1;

    if frame_no < get(handles.frame_slider,'Max')
        % set the slider
        set(handles.frame_slider,'Value',frame_no);
        % set the string in the frame_number box to the current frame value
        set(handles.frame_number,'String',num2str(frame_no));
        
        show_image(hObject,handles)
    end
end

if strcmp(eventdata.Key,'leftarrow')
    % get the current value from the slider (round to ensure it is integer)
    % and subtract 1 to make the new frame number
    frame_no = round(get(handles.frame_slider,'Value'))-1;

    if frame_no > 1
        % set the slider
        set(handles.frame_slider,'Value',frame_no);
        % set the string in the frame_number box to the current frame value
        set(handles.frame_number,'String',num2str(frame_no));
        
        show_image(hObject,handles)
    end    
end


% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Interruptible','on');

frame_no = round(get(handles.frame_slider,'Value'));
end_frame= get(handles.frame_slider,'Max');
handles.stop = 0;
guidata(hObject,handles);

%set(gcf,'DoubleBuffer','on')

for f = frame_no:end_frame;
    stop = get(handles.StopButton,'Value');
    if stop
        set(handles.StopButton,'Value',0.0);
        return
    else
        set(handles.frame_slider,'Value',f);
        % set the string in the frame_number box to the current frame value
        set(handles.frame_number,'String',num2str(f));
        show_image(hObject,handles)
        drawnow
    end
    
end

% --- Executes on button press in zoomvideo.
function zoomvideo_Callback(hObject, eventdata, handles)
% hObject    handle to zoomvideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% function too zoom the image by adjusting the axes' limits
axes(handles.axes1)
cx = get(gca,'XLim');
cy = get(gca,'YLim');

xrange = cx(2)-cx(1);
yrange = cy(2)-cy(1);
px = xrange/10;
py = yrange/10;

nx = [cx(1)+(0.5*px),cx(2)-(0.5*px)];
ny = [cy(1)+(0.5*py),cy(2)-(0.5*py)];


set(gca,'XLim',nx,'YLim',ny);
handles.Vidax_X = nx;
handles.Vidax_Y = ny;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in zoomoutvideo.
function zoomoutvideo_Callback(hObject, eventdata, handles)
% hObject    handle to zoomoutvideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
cx = get(gca,'XLim');
cy = get(gca,'YLim');

xrange = cx(2)-cx(1);
yrange = cy(2)-cy(1);
px = xrange/10;
py = yrange/10;

nx = [cx(1)-(0.5*px),cx(2)+(0.5*px)];
ny = [cy(1)-(0.5*py),cy(2)+(0.5*py)];

set(gca,'XLim',nx,'YLim',ny);
handles.Vidax_X = nx;
handles.Vidax_Y = ny;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.StopButton,'Value',1.0)



% --------------------------------------------------------------------
function Load_All_Tracked_Frames_Callback(hObject, eventdata, handles)
% hObject    handle to Load_All_Tracked_Frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%load the avi file

menu_clear_tracking_Callback(hObject, eventdata, handles)% clear any current tracking

%select file
[fname, pname] = uigetfile('*.mat', 'Pick a .MAT file');
    
load([pname fname],'TrackingData');

for i = 1:length(TrackingData.Region)
    
    % Recompute the ROI using roipoly and the vertices that were saved
    sf = TrackingData.start_frame;% find the start frame and end frame of previous tracking
    ef = (length(TrackingData.Region(i).ROIx)-1)+TrackingData.start_frame;
    s = size(handles.ImStack(:,:,sf:ef));% reorganise the image stack into a temporary cell array
    I = shiftdim(mat2cell(handles.ImStack(:,:,sf:ef),...
        s(1),s(2),ones(1,s(3))),1);
    x = TrackingData.Region(i).ROIx; % get the coordinates of the vertices
    y = TrackingData.Region(i).ROIy;
    TrackingData.Region(i).ROI = cellfun(@roipoly,I,x,y,'UniformOutput',false);%compute ROI
    
    for j = 1:length(TrackingData.Region(i).Fascicle)
    
        if isfield(TrackingData.Region(i).Fascicle(j),'fas_x_corr')
            
            TrackingData.Region(i).Fascicle(j).fas_x = TrackingData.Region(i).Fascicle(j).fas_x_corr;
            TrackingData.Region(i).Fascicle(j).fas_y = TrackingData.Region(i).Fascicle(j).fas_y_corr;
            TrackingData.Region(i).fas_length =  TrackingData.Region(i).fas_length_corr;
            TrackingData.Region(i).fas_pen =  TrackingData.Region(i).fas_pen_corr;
             
        end
        
    end
    if isfield(TrackingData.Region(i).Fascicle(j),'fas_x_corr')
        TrackingData.Region(i).Fascicle = rmfield(TrackingData.Region(i).Fascicle,{'fas_x_corr','fas_y_corr'});
    end
end

if isfield(TrackingData.Region(i).Fascicle(j),'fas_length_corr')    
    TrackingData.Region = rmfield(TrackingData.Region,{'fas_length_corr','fas_pen_corr'});
end

handles.Region=TrackingData.Region;

handles.start_frame = TrackingData.start_frame;
handles.NumFrames = TrackingData.NumFrames;
set(handles.frame_slider,'Min',1);
set(handles.frame_slider,'Max',handles.NumFrames);
set(handles.frame_slider,'Value',1);
set(handles.frame_slider,'SliderStep',[1/handles.NumFrames 5/handles.NumFrames]);
% set the string in the frame_number to 1
set(handles.frame_number,'String',1);

show_image(hObject,handles);


%---------------------------------------------------------
% Function to show image with appropriate image processing
%---------------------------------------------------------
function show_image(hObject, handles)

set(gcf,'DoubleBuffer','on');

if isfield(handles,'ImStack')
    
    axes(handles.length_plot)
    cla
    hold on  
    % find current frame number from slider
    frame_no = round(get(handles.frame_slider,'Value'));
    % get the image depth
    image_depth = handles.ID;
    
    % show the image
    if isfield(handles,'ImStack')
        Im = handles.ImStack(:,:,frame_no+handles.start_frame-1);
        % make the image axes the current axes
        axes(handles.axes1)
        %cla(handles.axes1)
         % crop image with current cropping value
        Im = imcrop(Im,handles.crop_rect);
        hold off
        % show the image
        imshow(Im,'Border','loose')
        colormap(gray(256)); axis off;
        if isfield(handles,'Vidax_X')
            set(handles.axes1,'XLimMode','manual','XLim',handles.Vidax_X,'YLim',handles.Vidax_Y');
        else
           set(handles.axes1,'XLimMode','manual','XLim',[0-(0.1*handles.crop_rect(3)) handles.crop_rect(3)+(0.1*handles.crop_rect(3))],'YLimMode','manual','YLim',[0 handles.vidHeight])
        end
        
        hold on
    end
    
    % Update Im and NIm 
    handles.Im = Im;    
    handles.NIm = handles.Im;
    
    if isfield(handles,'Region')
        % go through each defined muscle region, check if the frame has been processed
        % and, if not, perform the affine flow calculation and apply to any defined fascicles
        if isfield(handles.Region,'ROI')

            % define the parameters of the affine flow algorithm
            sigmaXY = handles.SIGMA;
            sampleStep = handles.S_STEP;

            for i = 1:length(handles.Region)                  
                                
                if isfield(handles.Region(i),'Fascicle')
                    
                    if ~isempty(handles.Region(i).Fascicle)

                        for j = 1:length(handles.Region(i).Fascicle)
                             
                            if isempty(find(handles.Region(i).Fascicle(j).analysed_frames==frame_no, 1))
                                % setup current and new image
                                im1 = double(handles.CIm)/256;
                                im2 = double(handles.NIm)/256;
                                
                                af = affine_flow('image1', im1, 'image2', im2, 'sigmaXY',sigmaXY,'sampleStep',sampleStep,'regionOfInterest',handles.Region(i).ROI{frame_no-1});
                                af = af.findFlow;
                                flow = af.flowStruct;
                                
                                % determine the warp to apply to the fasicles
                                w = affine_flow.warp(flow);
                                handles.Region(i).warp(:,:,frame_no) = w;
                                
                                handles.CIm = handles.NIm;
                                
                                % loop through all fasicles defined for the region and apply
                                % the warp and calculate new fascicle length
                                if isfield(handles.Region(i).Fascicle(j),'fas_x_corr') && ~isempty(handles.Region(i).Fascicle(j).fas_x_corr{frame_no-1})
                                    handles.Region(i).Fascicle(j).current_xy(1,1) = handles.Region(i).Fascicle(j).fas_x_corr{frame_no-1}(1);
                                    handles.Region(i).Fascicle(j).current_xy(1,2) = handles.Region(i).Fascicle(j).fas_y_corr{frame_no-1}(1);
                                    handles.Region(i).Fascicle(j).current_xy(2,1) = handles.Region(i).Fascicle(j).fas_x_corr{frame_no-1}(2);
                                    handles.Region(i).Fascicle(j).current_xy(2,2) = handles.Region(i).Fascicle(j).fas_y_corr{frame_no-1}(2);
                                    handles.Region(i).Fascicle(j).current_xy = [handles.Region(i).Fascicle(j).current_xy(:,1) handles.Region(i).Fascicle(j).current_xy(:,2) ones(length(handles.Region(i).Fascicle(j).current_xy),1)] * w;
                                    handles.Region(i).Fascicle(j).fas_x_corr{frame_no}(1) = handles.Region(i).Fascicle(j).current_xy(1,1);
                                    handles.Region(i).Fascicle(j).fas_y_corr{frame_no}(1) = handles.Region(i).Fascicle(j).current_xy(1,2);
                                    handles.Region(i).Fascicle(j).fas_x_corr{frame_no}(2) = handles.Region(i).Fascicle(j).current_xy(2,1);
                                    handles.Region(i).Fascicle(j).fas_y_corr{frame_no}(2) = handles.Region(i).Fascicle(j).current_xy(2,2);
                                else
                                    handles.Region(i).Fascicle(j).current_xy = [handles.Region(i).Fascicle(j).current_xy(:,1) handles.Region(i).Fascicle(j).current_xy(:,2) ones(length(handles.Region(i).Fascicle(j).current_xy),1)] * w;
                                    handles.Region(i).Fascicle(j).fas_x{frame_no}(1) = handles.Region(i).Fascicle(j).current_xy(1,1);
                                    handles.Region(i).Fascicle(j).fas_y{frame_no}(1) = handles.Region(i).Fascicle(j).current_xy(1,2);
                                    handles.Region(i).Fascicle(j).fas_x{frame_no}(2) = handles.Region(i).Fascicle(j).current_xy(2,1);
                                    handles.Region(i).Fascicle(j).fas_y{frame_no}(2) = handles.Region(i).Fascicle(j).current_xy(2,2);
                                end
                                
                               
                                if get(handles.FixedROI_on,'Value')
                                    handles.Region(i).ROI{frame_no} = handles.Region(i).ROI{frame_no-1};
                                    handles.Region(i).ROIx{frame_no} = handles.Region(i).ROIx{frame_no-1};
                                    handles.Region(i).ROIy{frame_no} = handles.Region(i).ROIy{frame_no-1};
                                else
                                    ROIpos = [handles.Region(i).ROIx{frame_no-1},handles.Region(i).ROIy{frame_no-1},...
                                        ones(length(handles.Region(i).ROIx{frame_no-1}),1)] * w;
                                    [handles.Region(i).ROI{frame_no},handles.Region(i).ROIx{frame_no},...
                                        handles.Region(i).ROIy{frame_no}] = roipoly(im2,ROIpos(:,1),ROIpos(:,2));
                                end
                                
                                % Adjust the ROI if it goes outside the
                                % image
                                handles.Region(i).ROIx{frame_no}(handles.Region(i).ROIx{frame_no} > handles.vidWidth) = handles.vidWidth;
                                handles.Region(i).ROIy{frame_no}(handles.Region(i).ROIy{frame_no} > handles.vidHeight) = handles.vidHeight;
                                handles.Region(i).ROIx{frame_no}(handles.Region(i).ROIx{frame_no} < 1) = 1;
                                handles.Region(i).ROIy{frame_no}(handles.Region(i).ROIy{frame_no} < 1) = 1;
                                
                                % calculate the length and pennation for the current frame
                                if isfield(handles.Region(i).Fascicle(j),'fas_x_corr') && ~isempty(handles.Region(i).Fascicle(j).fas_x_corr{frame_no})
                                    handles.Region(i).fas_pen_corr(frame_no,j) = atan2(abs(diff(handles.Region(i).Fascicle(j).fas_y_corr{frame_no})),abs(diff(handles.Region(i).Fascicle(j).fas_x_corr{frame_no})));
                                    scalar = image_depth/handles.vidHeight;
                                    handles.Region(i).fas_length_corr(frame_no,j) = scalar*sqrt(diff(handles.Region(i).Fascicle(j).fas_y_corr{frame_no}).^2 + diff(handles.Region(i).Fascicle(j).fas_x_corr{frame_no}).^2);
                                else
                                    handles.Region(i).fas_pen(frame_no,j) = atan2(abs(diff(handles.Region(i).Fascicle(j).fas_y{frame_no})),abs(diff(handles.Region(i).Fascicle(j).fas_x{frame_no})));
                                    scalar = image_depth/handles.vidHeight;
                                    handles.Region(i).fas_length(frame_no,j) = scalar*sqrt(diff(handles.Region(i).Fascicle(j).fas_y{frame_no}).^2 + diff(handles.Region(i).Fascicle(j).fas_x{frame_no}).^2);
                                end
                                handles.Region(i).Fascicle(j).analysed_frames = sort([handles.Region(i).Fascicle(j).analysed_frames frame_no]);
                            end
                        end

                    else
                        for j = 1:length(handles.Region(i).Fascicle)
                            if isempty(find(handles.Region(i).Fascicle(j).analysed_frames==frame_no, 1))
                                handles.Region(i).Fascicle(j).current_xy(1,1) = handles.Region(i).Fascicle(j).fas_x{frame_no}(1);
                                handles.Region(i).Fascicle(j).current_xy(1,2) = handles.Region(i).Fascicle(j).fas_y{frame_no}(1);
                                handles.Region(i).Fascicle(j).current_xy(2,1) = handles.Region(i).Fascicle(j).fas_x{frame_no}(2);
                                handles.Region(i).Fascicle(j).current_xy(2,2) = handles.Region(i).Fascicle(j).fas_y{frame_no}(2);
                                % calculate the length and pennation for the current frame
                                handles.Region(i).fas_pen(frame_no,j) = atan2(abs(diff(handles.Region(i).Fascicle(j).fas_y{frame_no})),abs(diff(handles.Region(i).Fascicle(j).fas_x{frame_no})));
                                scalar = image_depth/handles.vidHeight;
                                handles.Region(i).fas_length(frame_no,j) = scalar*sqrt(diff(handles.Region(i).Fascicle(j).fas_y{frame_no}).^2 + diff(handles.Region(i).Fascicle(j).fas_x{frame_no}).^2);        
                            end
                        end

                    end
                    
                    
                    
                    if isfield(handles.Region(i),'fas_length')
                        if ~isempty(handles.Region(i).fas_length)
                            %plot the fascicle length on the graph relative to time
                            % define the line type
                            switch i
                                case 1
                                    c = '-';
                                case 2
                                    c = ':';
                                case 3
                                    c = '-.';
                                otherwise
                                    c = '--';
                            end

                            dt = 1/handles.FrameRate;
                            nz = logical(handles.Region(i).fas_length(:,1) ~= 0);
                            FL = handles.Region(i).fas_length(nz,:);
                            time = (dt:dt:length(handles.Region(i).fas_length(:,1))*dt)+((handles.start_frame-1)*dt);

                            for j = 1:length(handles.Region(i).Fascicle)
                                
                                if isfield(handles.Region(i).Fascicle(j),'fas_x_corr') && ~isempty(handles.Region(i).Fascicle(j).fas_x_corr);
                                    
                                    %plot the fascicle length on the graph relative to time
                                    if isfield(handles.Region(i),'fas_length_keyframe')
                                        dt = 1/handles.FrameRate;
                                        nnz = logical(handles.Region(i).fas_length_keyframe(:,j) ~= 0);
                                        FL_keyframe = handles.Region(i).fas_length_keyframe(nnz,j);
                                        time_keyframe = (dt:dt:length(handles.Region(i).fas_length_keyframe(:,j))*dt)+((handles.start_frame-1)*dt);
                                        %plot(handles.length_plot,time(nz),handles.Region(i).fas_length_corr(nz,j),c,time_keyframe(nnz),FL_keyframe,'ro');
                                        plot(handles.length_plot,time(nz),handles.Region(i).fas_length_corr(nz,j),time_keyframe(nnz),FL_keyframe,'ro');
                                    else
                                        plot(handles.length_plot,time(nz),handles.Region(i).fas_length_corr(nz,j))
                                    end
                                    
                                    
                                    axes(handles.length_plot)
                                    
                                        
                                    if size(handles.Region(i).fas_length_corr,1)>=frame_no
                                        
                                        text(handles.Time(frame_no+handles.start_frame-1)+0.2,handles.Region(i).fas_length_corr(frame_no,j)...
                                            ,num2str(round(handles.Region(i).fas_length_corr(frame_no,j))),...
                                            'FontSize',10,'FontWeight','bold')
                                    end
                                    
                                    %for j = 1:length(handles.Region(i).Fascicle)
                                    %plot the fascicle
                                    plot(handles.axes1,handles.Region(i).Fascicle(j).fas_x_corr{frame_no},handles.Region(i).Fascicle(j).fas_y_corr{frame_no},'yo-','LineWidth',2)
                                    %end
                                else
                                   
                                    plot(handles.length_plot,time(nz),FL)
                                    
                                    if isfield(handles.Region(i),'adjusted_flength')&& size(handles.Region(i).adjusted_flength,1) > 1 
                                        Adj_FL = handles.Region(i).adjusted_flength(nz,:);
                                        plot(handles.length_plot,time(nz),Adj_FL)
                                    end
                                    
                                    axes(handles.length_plot)
                                    
                                        
                                    if size(FL,1)>=frame_no
                                        text(handles.Time(frame_no+handles.start_frame-1)+0.2,FL(frame_no,j)...
                                            ,num2str(round(FL(frame_no,j))),...
                                            'FontSize',10,'FontWeight','bold')
                                    end
                                        
                                    
                                    %for j = 1:length(handles.Region(i).Fascicle)
                                    
                                    %plot the fascicle
                                    plot(handles.axes1,handles.Region(i).Fascicle(j).fas_x{frame_no},handles.Region(i).Fascicle(j).fas_y{frame_no},'ro-','LineWidth',2)
                                    %end
                                end
                            end

                            set(handles.length_plot,'XLim',[0 handles.Time(end)]);
                        end
                    end

                end
                
                % plot the ROI
                plot(handles.axes1,handles.Region(i).ROIx{frame_no},handles.Region(i).ROIy{frame_no},'r:','LineWidth',2)

            end

        end
    end
       
    axes(handles.length_plot)
    set(handles.length_plot,'XLim',[0 handles.Time(end)]);
    L_range = get(handles.length_plot,'YLim');
    plot([handles.Time(frame_no+handles.start_frame-1) handles.Time(frame_no+handles.start_frame-1)],[L_range(1) L_range(2)],'k');
    hold off       

    
    xlabel(handles.length_plot,'Time')
    ylabel(handles.length_plot,'Fascicle Length (mm)')


    % Update handles structure
    guidata(hObject, handles);
           
end



function ImDepthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ImDepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImDepthEdit as text
%        str2double(get(hObject,'String')) returns contents of ImDepthEdit as a double

handles.ID = str2double(get(handles.ImDepthEdit,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ImDepthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImDepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


