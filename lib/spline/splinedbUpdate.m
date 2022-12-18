%splinedbUpdate Updates an existing spline in the database
%
%This function will update and existing spline that is in the database.
%The user specifies its index number and the file will be opened and
%the spline control points will be available for editing.  The user will
%then have the option to save the spline with a text note.
%
%splinedbUpdate(metadata,index)
%
%metadata - This is a valid metadata structure that has been loaded and
%it will specify the names and locations of the database.  If the given
%spline database does not exist it will be created.  this can also be a
%chracter string of the full path name of the file that has the metadata.
%
%index - the index of the spline to edit in the database.  The indexes
%can be viewed with the splinedbSelect command.
%
%ultrasonixGetFrameParms - The parameters to configure the ultrasonix get
%frame function.
%
%SEE ALSO: splinedbView, splinedbInsert, splinedbDelete, splinedbSelect
function splinedbUpdate(metadata,index,varargin)

p = inputParser;   % Create an instance of the class.
p.addRequired('metadata', @(x) ischar(x) || isstruct(x));
p.addRequired('index',[], @(x) isnumeric(x) && isscalar(x));
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);

p.parse(metadata,index,varargin{:});

ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;



[metadata]=loadCaseData(metadata);


rowToStartDisplay=400;  %this skips the yuck on the previous rows

if ~isfield(metadata,'splineFilename')
    error('The field splineFilename must be given in the metadata data structure.');
end

if exist(metadata.splineFilename,'file')
    load(metadata.splineFilename,'splineData')
    if ~isValidIndex(splineData,index);
        error(['index is not an integer in the valid range of [1,' num2str(length(splineData)) ']']);
    else
        %do nothing
        x=splineData.controlpt.x;
        y=splineData.controlpt.y;
    end
else
    error([metadata.splineFilename ' does not exist.  Unable to insert'])
end

framesToProcess=metadata.validFramesToProcess;

if isempty(framesToProcess)
    [header] = ultrasonixGetInfo(metadata.rfFilename);
    framesToProcess=(1:(header.nframes-1));
end

currentFrame=framesToProcess(1);
[img] = ultrasonixGetFrame(metadata.rfFilename,currentFrame,ultrasonixGetFrameParms{:});
fig = figure();



%% Create spline
imagesc(abs(img).^0.5); colormap(gray);
title(['Frame ' num2str(currentFrame) ' -- select your spline points and hit <return> when done.'],'interpreter','none')


[x,y]=ginput;
yy = spline(x,y,(1:size(img,2)));


quitSpline=false;
while(~quitSpline)
    
    hold on; plot(yy,'y'); hold off;
    
    mmodeImg = zeros(size(img,2),length(framesToProcess));
    for ii=1:length(framesToProcess)
        frameNumber=framesToProcess(ii);
        [img] = ultrasonixGetFrame(metadata.rfFilename,frameNumber,ultrasonixGetFrameParms{:});
        mmodeLine=computeCurvedMMode(abs(img).^0.5, yy);
        mmodeImg(:,ii) = mmodeLine;
        
        figure(fig);
        %         imagesc(abs(img).^0.5); colormap(gray);
        %         hold on; plot(yy,'y');  plot(x,y,'yo'); hold off;
        subplot(2,1,1); imagesc(abs(img(rowToStartDisplay:end,:)).^0.5); colormap(gray);
        hold on; plot(yy-rowToStartDisplay,'y'); plot(x,y-rowToStartDisplay,'yo'); hold off;
        set(gca,'XTickLabel',''); ylabel('Depth')
        title(['Frame ' num2str(frameNumber) ' of ' num2str(framesToProcess(end)) ' hit s to stop.'])
        
        subplot(2,1,2); imagesc(mmodeImg'); xlabel('Lateral distance'); ylabel('Frames');
        
        if  strcmp('s',lower(get(fig, 'CurrentKey')))
            break;  %the user wants to stop
        end
    end
    
    switch(questdlg('What would you like to do?','Run Complete','save','edit','quit','save'))
        case 'quit'
            quitSpline=true;
        case 'save'
            if exist(metadata.splineFilename,'file')
                load(metadata.splineFilename,'splineData')
            else
                splineData=[];
            end
            
            if isempty(name)
                name = inputdlg('Enter a name:','Add name to spline',1,{['Spline ' num2str(length(splineData)+1)]});
                name=name{1};
            end
            
            splineData(end+1).controlpt.x=x; %#ok<AGROW>
            splineData(end).controlpt.y=y; %#ok<AGROW>
            splineData(end).name=name; %#ok<AGROW>
            splineData(end).tag=''; %#ok<AGROW>
            
            save(metadata.splineFilename,'splineData');
            
            hMsg=msgbox(['Spline saved in ' metadata.splineFilename ' as index ' num2str(length(splineData))],'Save Complete','modal');
            uiwait(hMsg);
            
            
            switch(questdlg('What would you like to do?','Save Complete','edit','quit','edit'))
                case 'edit'
                    [x,y]=editSpline(metadata,x,y,fig,rowToStartDisplay);
                    yy = spline(x,y,(1:size(img,2)));
                    name=[];  %let user reenter the name
                    quitSpline=false;
                case 'quit'
                    quitSpline=true;
                otherwise
                    error('Invalid response')
            end
            
        case 'edit'
            [x,y]=editSpline(metadata,x,y,fig,rowToStartDisplay);
            yy = spline(x,y,(1:size(img,2)));
            quitSpline=false;
        otherwise
            error('Invalid response')
    end
    
end
end


function [controlptx,controlpty]=editSpline(metadata,controlptx,controlpty,fig,rowToStartDisplay)
cp=[reshape(controlptx,1,[]); reshape(controlpty,1,[])];
figure(fig);
subplot(2,1,1);
title('Left moves, right deletes, center adds, hit <return> when done')

editMode=true;
hspline=[];

while(editMode)
    [selx, sely, buttonChoice]=ginput(1);
    sely=sely+rowToStartDisplay;
    
    if ~isempty(buttonChoice)
        s=[selx; sely];
        switch(buttonChoice)
            case 1 %left button -- move the closest control point
                %find the closest using the l2 norm (without the square root
                [cv, ci]=min(sum(abs(cp-repmat(s,1,size(cp,2))).^2,1));
                cp(:,ci)=s;
            case 2 %create a control point at the location
                cp(:,end+1)=s;
            case 3 %right button -- delete the closest control point
                [cv, ci]=min(sum(abs(cp-repmat(s,1,size(cp,2))).^2,1));
                cp(:,ci)=[]; %#ok<NASGU>
            otherwise
                error([num2str(buttonChoice) ' was in error.']);
        end
        if ~isempty(hspline)
            delete(hspline)
        end
        
        yy = spline(cp(1,:),cp(2,:),(1:diff(ylim)));
        hold on; hspline(1)=plot(yy-rowToStartDisplay,'r'); hspline(2)=plot(cp(1,:),cp(2,:)-rowToStartDisplay,'ro'); hold off; %#ok<NASGU>
        
    else
        editMode=false;
        %done with processing so exit
    end
end

controlptx=cp(1,:);
controlpty=cp(2,:);
%do we need to create the
end
