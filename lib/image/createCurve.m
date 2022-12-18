function varargout = createCurve(varargin)
% CREATECURVE MATLAB code for createCurve.fig
%      CREATECURVE, by itself, creates a new CREATECURVE or raises the existing
%      singleton*.
%
%      H = CREATECURVE returns the handle to a new CREATECURVE or the handle to
%      the existing singleton*.
%
%      CREATECURVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATECURVE.M with the given input arguments.
%
%      CREATECURVE('Property','Value',...) creates a new CREATECURVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createCurve_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createCurve_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createCurve

% Last Modified by GUIDE v2.5 19-Apr-2013 12:07:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @createCurve_OpeningFcn, ...
    'gui_OutputFcn',  @createCurve_OutputFcn, ...
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

% --- Executes just before createCurve is made visible.
function createCurve_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createCurve (see VARARGIN)

% Choose default command line output for createCurve
handles.configSettings.defaultDataFilename=[];

switch(length(varargin))
    case 0
        inputPath=fullfile(getenv('DATA_INPUT'),'MRUS002\02-23-2012-MSK');
        rfBasefilename='TRIAL2_rf.rf';
        handles.case.file.fullfilename=fullfile(inputPath,rfBasefilename);
        
        handles.case.file.ureadArgs={'decimateLaterial',true,'frameFormatComplex',true};
        
        handles.case.displayMode={'axial',1800};
        
        
        [imblockCompleteFile ]=uread(handles.case.file.fullfilename,handles.case.frames,handles.case.file.ureadArgs{:});
        handles.case.im=squeeze(imblockCompleteFile(1800,:,:));
        error('need to fix')
    case 2
        
        handles.case.im = varargin{1};
        metadata = varargin{2};
        handles.case.file.fullfilename=metadata{1};
        handles.case.file.ureadArgs=metadata{2};
        handles.case.displayMode=metadata{3};
    case 3
        handles.case.im = varargin{1};
        metadata = varargin{2};
        handles.case.file.fullfilename=metadata{1};
        handles.case.file.ureadArgs=metadata{2};
        handles.case.displayMode=metadata{3};
        
        p = inputParser;   % Create an instance of the class.
        p.addParamValue('defaultDataFilename', [],@(x) ischar(x));
        p.addParamValue('samplingSkeleton',struct([]), @(x) isstruct(x));
        p.addParamValue('dataBlockObj',[], @(x) isa(x,'DataBlockObj'));
        
        p.parse(varargin{3}{:});
        
        handles.configSettings.defaultDataFilename=p.Results.defaultDataFilename;
        handles.configSettings.samplingSkeleton=p.Results.samplingSkeleton;
        handles.configSettings.dataBlockObj=p.Results.dataBlockObj;
    otherwise
        error('Invalid number of input argumetns.');
end

handles.referencePlot.cartesian=[];%load('ZH2Trial33_cartesian.mat');
handles.referencePlot.cmm=[]; %load('AF2Trial3_cmm');

handles.output = hObject;

[~, handles.case.file.header ]=uread(handles.case.file.fullfilename,-1,handles.case.file.ureadArgs{:});
handles.case.frames=[0:(handles.case.file.header.nframes-1)];

handles.case.metadata=loadCaseData(handles.case.file.fullfilename);
handles.case.lateral_mm=getCaseRFUnits(handles.case.metadata,'lateral','mm');
handles.case.axial_mm=getCaseRFUnits(handles.case.metadata,'axial','mm');
handles.case.frameRate_fps=handles.case.file.header.dr;

handles.case.activeRoi=1;
handles.case.roi(handles.case.activeRoi).activeFrameIdx=1;

handles.curve.impointDB=struct([]);
handles.curve.impointNextUniqueId=0;
handles.curve.splineCurve=[];
%The idea for the curve is that you place the points and it reforms a
%spline fit and redraws each time

%assume that is a function along x so we can sort
%%

set(handles.figCreateCurve,'KeyPressFcn',{@saveTrackPoint});
set(handles.textStatus,'String',[getCaseName(handles.case.metadata) ' ' handles.case.displayMode{1} ' ' num2str(handles.case.displayMode{2})]);


switch(handles.case.displayMode{1})
    case 'axial'
    case 'lateral'
    case 'bmode'
    case 'cmm'
        handles.case.cmmAxis_mm=handles.case.displayMode{4};
    otherwise
        error(['Unsupport mode of ' handles.case.displayMode]);
end




handles=paintFrames(handles);
switch(handles.case.displayMode{1})
    case 'axial'
        xlabel(handles.axesMain,'frame number');
        ylabel(handles.axesMain,'lateral');
    case 'lateral'
        xlabel(handles.axesMain,'frame number');
        ylabel(handles.axesMain,'axial');
    case 'bmode'
        ylabel(handles.axesMain,'axial');
        xlabel(handles.axesMain,'lateral');
    case 'cmm'
        xlabel(handles.axesMain,'frame number');
        ylabel(handles.axesMain,'axial');
    otherwise
        error(['Unsupport mode of ' handles.case.displayMode]);
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createCurve wait for user response (see UIRESUME)
% uiwait(handles.figCreateCurve);
end

% --- Outputs from this function are returned to the command line.
function varargout = createCurve_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

function saveTrackPoint(src,evnt) %#ok<INUSL>

switch(lower(evnt.Character))
    case ' '
        handles=guidata(src);
        
        %         if ~isempty(handles.curve.impointDB)
        %             handles.curve.impointDB(end+1).obj=impoint(get(handles.figCreateCurve,'CurrentAxes'));
        %         else
        %             handles.curve.impointDB(1).obj=impoint(get(handles.figCreateCurve,'CurrentAxes'));
        %         end
        handles.curve.impointDB(end+1).obj=impoint(get(handles.figCreateCurve,'CurrentAxes'));
        
        handles.curve.impointDB(end).id=handles.curve.impointNextUniqueId;
        handles.curve.impointNextUniqueId=handles.curve.impointNextUniqueId+1;
        
        
        %         handles.curve.impointList{end+1}=impoint(get(handles.figCreateCurve,'CurrentAxes'));
        %         handles.curve.impointList{end}.setColor('r');
        %         handles.curve.impointList{end}.addNewPositionCallback(@(roi) newSpline(src,roi));
        %         imt=handles.curve.impointList{end};
        handles.curve.impointDB(end).obj.setColor('r');
        handles.curve.impointDB(end).obj.addNewPositionCallback(@(roi) newSpline(src,roi));
        imt=handles.curve.impointDB(end).obj;
        
        uimenu(get(imt,'UIContextMenu'), 'label','Delete','Callback', {@deleteImpoint ,handles.curve.impointDB(end).id});
        
        handles=paintSpline(handles);
        
        %makesure the order is okay
        childrenHandle=get(handles.axesMain,'Children');
        [~,newIndex]=sort(arrayfun(@(x) strcmp(get(x,'Tag'),'impoint'),childrenHandle ),'descend');
        set(handles.axesMain,'Children',childrenHandle(newIndex));
        
        
        
        
        %handles=paintFrames(handles);
        guidata(src, handles);
        return;
    case 'l'
        handles=guidata(src);
        if isfield(handles.case,'videoroi')
            videoroiIndex=length(handles.case.videoroi)+1;
        else
            videoroiIndex=1;
        end
        handles.case.videoroi(videoroiIndex).hImLine = imline(handles.axesMain);
        handles.case.videoroi(videoroiIndex).hImLine.setColor('y');
        
        %add the delete option to the point menu
        myuicontextmenu=uicontextmenu;
        
        lineHandleList=findobj(handles.case.videoroi(videoroiIndex).hImLine, 'Type', 'line');
        ret=arrayfun(@(x) uimenu(get(x,'UIContextMenu'), 'label','Play Video','Callback', {@playVideo ,videoroiIndex}),lineHandleList(1));
        
        %
        guidata(src, handles);
        
        
        return;
    case 's'  %show the sample points
        handles=guidata(src);
        
        if strcmp(handles.case.displayMode{1},'bmode')
            [samplePoints_rc]=createHypothesisSetSpline(handles.case.metadata,{handles.curve.controlpt}, ...
                'totalSamplePoints', getCaseLateralPixelCount(handles.case.metadata)*10, ...
                'datareader',{'uread',handles.case.file.ureadArgs}, ...
                'showGraphics',true);
            return;
        else
            return;
        end
    case 'c'  %Sample the block grid
        handles=guidata(src);
        
        if strcmp(handles.case.displayMode{1},'bmode')
            [samplePoints_rc]=createHypothesisSetSpline(handles.case.metadata,{handles.curve.controlpt}, ...
                'totalSamplePoints', getCaseLateralPixelCount(handles.case.metadata)*10, ...
                'datareader',{'uread',handles.case.file.ureadArgs}, ...
                'showGraphics',false);
            imBlock=handles.case.displayMode{3};
            vi=interpn(1:size(imBlock,1),1:size(imBlock,2),1:size(imBlock,3),imBlock,kron(ones(size(imBlock,3),1),samplePoints_rc(1,:)'),kron(ones(size(imBlock,3),1),samplePoints_rc(2,:)'),kron([1:size(imBlock,3)]', ones(size(samplePoints_rc(2,:)'))));
            
            im=abs(reshape(vi,size(samplePoints_rc,2),size(imBlock,3))).^0.5;
            yAxis_mm=[0 cumsum(sqrt(sum(diff(diag([handles.case.axial_mm handles.case.lateral_mm])*samplePoints_rc,1,2).^2,1)))];
            xAxis_sec=(0:(size(im,2)-1))/handles.case.frameRate_fps;
            
            figure; imagesc(xAxis_sec,yAxis_mm,im); colormap(gray(256))
            xlabel('time (sec)')
            ylabel('cmm line (mm)');
            return
            imDisplay=squeeze(abs(handles.case.im).^0.4);
            yAxis_mm=[0:(size(imDisplay,1)-1)]*handles.case.axial_mm;
            xAxis_mm=(0:(size(imDisplay,2)-1))*handles.case.lateral_mm;
            
            
            
            figure; imagesc(xAxis_mm,yAxis_mm,imDisplay); colormap(gray(256))
            
            xlabel('lateral (mm)');
            ylabel('axial (mm)');
            
            pointList_xy=cell2mat(arrayfun(@(x) handles.curve.impointDB(x).obj.getPosition',(1:length(handles.curve.impointDB)),'UniformOutput',false));
            pointListLim_xy=[min(pointList_xy(1,:)); max(pointList_xy(1,:))];
            
            xx=linspace(pointListLim_xy(1), pointListLim_xy(2),max(round(diff(pointListLim_xy))*5,10));
            %xx(any(repmat(fix(xx(:)),1,size(pointList_xy,2)) == repmat(fix(pointList_xy(1,:)),length(xx),1),2))=[];
            
            
            handles.curve.controlpt.x=pointList_xy(1,:);
            handles.curve.controlpt.y=pointList_xy(2,:);
            yy=spline(handles.curve.controlpt.x,handles.curve.controlpt.y,xx);
            
            hold on;
            rr=plot(xx*handles.case.lateral_mm,yy*handles.case.axial_mm,'r','lineWidth',2)
            
            
        elseif strcmp(handles.case.displayMode{1},'cmm')
            
            %%
            imDisplay=squeeze(abs(handles.case.im).^0.8);
            yAxis_mm=handles.case.displayMode{4};
            xAxis_sec=handles.case.displayMode{3};
            
            fh=figure; imh=imagesc(xAxis_sec,yAxis_mm,imDisplay); colormap(gray(256))
            xlabel('time (sec)')
            ylabel('cmm line (mm)');
            
            
            pointList_xy=cell2mat(arrayfun(@(x) handles.curve.impointDB(x).obj.getPosition',(1:length(handles.curve.impointDB)),'UniformOutput',false));
            
            pointListLim_xy=[min(pointList_xy(1,:)); max(pointList_xy(1,:))];
            
            xx=linspace(pointListLim_xy(1), pointListLim_xy(2),max(round(diff(pointListLim_xy))*5,10));
            %xx(any(repmat(fix(xx(:)),1,size(pointList_xy,2)) == repmat(fix(pointList_xy(1,:)),length(xx),1),2))=[];
            
            
            handles.curve.controlpt.x=pointList_xy(1,:);
            handles.curve.controlpt.y=pointList_xy(2,:);
            yy=spline(handles.curve.controlpt.x,handles.curve.controlpt.y,xx);
            
            hold on;
            rr=plot(xx*mean(diff(xAxis_sec)),yy*mean(diff(yAxis_mm)),'r','lineWidth',2)
            
            %save('imSpline.mat','imDisplay','xAxis_sec','yAxis_mm');
        elseif  strcmp(handles.case.displayMode{1},'lateral')
            imDisplay=squeeze(abs(handles.case.im).^0.5);
            yAxis_mm=[0:(size(imDisplay,1)-1)]*handles.case.axial_mm;
            xAxis_sec=(0:(size(imDisplay,2)-1))/handles.case.frameRate_fps;
            
            
            
            figure; imagesc(xAxis_sec,yAxis_mm,imDisplay); colormap(gray(256))
            xlabel('time (sec)')
            ylabel('cmm line (mm)');
        elseif  strcmp(handles.case.displayMode{1},'axial')
            imDisplay=squeeze(abs(handles.case.im).^0.5);
            yAxis_mm=[0:(size(imDisplay,1)-1)]*handles.case.lateral_mm;
            xAxis_sec=(0:(size(imDisplay,2)-1))/handles.case.frameRate_fps;
            
            
            
            figure; imagesc(xAxis_sec,yAxis_mm,imDisplay); colormap(gray(256))
            xlabel('time (sec)')
            ylabel('lateral (mm)');
            
        else
            
        end
        return;
    case 'f'  %Sample the block grid
        handles=guidata(src);
        
        imDisplay=squeeze(abs(handles.case.im).^0.5);
        imStick=sf(imDisplay,9,3);
        figure;
        imagesc(imStick);
        title('Stick Output');
        keyboard
        
        return;
    case '+'
        handles=guidata(src);
        if isempty(handles.configSettings.defaultDataFilename)
            defaultFilename=pwd;
        else
            defaultFilename=handles.configSettings.defaultDataFilename;
        end
        
        [filename pathname] = uiputfile({'*.mat','matlab data file (*.mat)'; ...
            '*.*','All Files (*.*)' },'Save the curve file',defaultFilename);
        if pathname==0  %then cancel was selected
            %do nothing and exit
        else
            handles=guidata(src);
            handles.curve=rmfield(handles.curve,'impointDB');
            save(fullfile(pathname,filename),'handles');
        end
    otherwise
        return;
end

end
function deleteImpoint(src,evn,id)
handles=guidata(src);
disp(['Deleting impoint with id = ' num2str(id)])
idx=find(arrayfun(@(x) handles.curve.impointDB(x).id==id,1:length(handles.curve.impointDB)));
if length(idx)~=1
    error('Idx must be 1');
end
handles.curve.impointDB(idx).obj.delete;
handles.curve.impointDB(idx)=[];
handles=paintSpline(handles);
guidata(handles.figCreateCurve, handles);
end

function playVideo(src,evn,videoroiIndex)
handles=guidata(src);
% 'ureadParms',{},@iscell);
% p.addParamValue('framesToShow'
imLinePosition=handles.case.videoroi(videoroiIndex).hImLine.getPosition;

showRF(handles.configSettings.dataBlockObj,'framesToShow',(round(imLinePosition(1,1)):round(imLinePosition(2,1))) , ...
    'axisToMarkPositionOn',handles.axesMain,'samplingSkeleton',handles.configSettings.samplingSkeleton ,'showSpline',true);
end

function newSpline(src,roi)
handles=guidata(src);
handles=paintSpline(handles);
guidata(src, handles);
end

function handles=paintSpline(handles)


if length(handles.curve.impointDB)>1
    pointList_xy=cell2mat(arrayfun(@(x) handles.curve.impointDB(x).obj.getPosition',(1:length(handles.curve.impointDB)),'UniformOutput',false));
    
    pointListLim_xy=[min(pointList_xy(1,:)); max(pointList_xy(1,:))];
    
    xx=linspace(pointListLim_xy(1), pointListLim_xy(2),max(round(diff(pointListLim_xy))*5,10));
    %xx(any(repmat(fix(xx(:)),1,size(pointList_xy,2)) == repmat(fix(pointList_xy(1,:)),length(xx),1),2))=[];
    
    
    handles.curve.controlpt.x=pointList_xy(1,:);
    handles.curve.controlpt.y=pointList_xy(2,:);
    yy=interp1(handles.curve.controlpt.x,handles.curve.controlpt.y,xx,'spline');
    
    
    
    if ~isempty(handles.curve.splineCurve)
        delete(handles.curve.splineCurve)
    end
    set(handles.axesMain,'NextPlot','add')
    handles.curve.splineCurve=plot(handles.axesMain,xx,yy,'r');
    set(handles.curve.splineCurve,'HitTest','off');
    set(handles.axesMain,'NextPlot','replace')
    
    switch(handles.case.displayMode{1})
        case 'cmm'
            stepSize_mm=mean(diff(handles.case.cmmAxis_mm));
        case 'axial'
            stepSize_mm=handles.case.lateral_mm;
        case 'lateral'
            stepSize_mm=handles.case.axial_mm;
        case 'bmode'
            stepSize_mm=1;
        otherwise
            error(['Unsupport mode of ' handles.case.displayMode]);
    end
    motion_mmPerSec=(diff(yy)*stepSize_mm)./(diff(xx)*(1/handles.case.frameRate_fps));
    plot(handles.axesMotion,xx(2:end),abs(motion_mmPerSec),'r');
    set(handles.axesMotion,'NextPlot','add');
    hold on;
    if ~isempty(handles.referencePlot.cmm)
        plot(handles.axesMotion,1:length(handles.referencePlot.cmm.ultrasoundTrack_mmPerSec),abs(handles.referencePlot.cmm.ultrasoundTrack_mmPerSec),'b.');
    end
    
    if ~isempty(handles.referencePlot.cartesian)        
        plot(handles.axesMotion,1:length(handles.referencePlot.cartesian.ultrasoundTrack_mmPerSec),abs(handles.referencePlot.cartesian.ultrasoundTrack_mmPerSec),'g.');
    end

    set(handles.axesMotion,'NextPlot','replace');
    
    xlabel(handles.axesMotion,'frame number');
    ylabel(handles.axesMotion,'(abs) mm/sec')
    handles.userSplinePlot.motion_mmPerSec=motion_mmPerSec;
    handles.userSplinePlot.x=xx(2:end);
end

end

%Paint frames assumes all of the data loaded is correct
function handles=paintFrames(handles)


handles.case.lib.displayFunc=@(x) abs(x).^0.5;
% showImage = @(fig,x) lseq(@() figure(fig),@() imagesc(squeeze(displayFunc(x))),  @() colormap(gray(256)));
% showImage(handles.figCreateCurve,imBlock(1800,:,:))


%imDisplay=squeeze(abs(handles.case.im).^0.5);
imDisplay=squeeze(abs(handles.case.im));


set(handles.figCreateCurve,'currentAxes',handles.axesMain);
imagesc(imDisplay)
colormap(gray(256));
%axis(handles.axesMain,str2num(get(handles.editZoom,'String')));

end
