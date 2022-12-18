%splinedbView View a spline into the database
%
%This function will display a spline that has already been created.
%If no spline is specified the active one will be shown.
%
%splinedbInsert(metadata, splineIndex,ultrasonixGetFrameParms)
%
%metadata - This is a valid metadata structure that has been loaded and
%it will specify the names and locations of the database.  If the given
%spline database does not exist it will be created.  this can also be a
%chracter string of the full path name of the file that has the metadata.
%
%splineIndex - The index of the spline to show.  If none is given then
%the active spline is displayed
%
%ultrasonixGetFrameParms - The parameters to configure the ultrasonix get
%frame function.
%
%>>splinedbView(caseFile,'ultrasonixGetFrameParms',{'formIQWithHilbert',true,'skipEvenRows',true})
%
%SEE ALSO: splinedbView, splinedbUpdate, splinedbDelete, splinedbSelect

function splinedbView(metadata,varargin)

p = inputParser;   % Create an instance of the class.
p.addRequired('metadata', @(x) ischar(x) || isstruct(x) || isempty(x));
p.addOptional('splineIndex',[],@(x) (isempty(x) || (isnumeric(x) && isscalar(x) && (x>0))));
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);

p.parse(metadata,varargin{:});

splineIndex=p.Results.splineIndex;
ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;

metadata=loadCaseData(metadata);

rowToStartDisplay=400;  %this skips the yuck on the previous rows

if ~isfield(metadata,'splineFilename')
    error('The field splineFilename must be given in the metadata data structure.');
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

if isempty(splineIndex)
    splineDataActive=splinedbSelectActive(metadata);
    x=splineDataActive.controlpt.x;
    y=splineDataActive.controlpt.y;
    splineName= 'active spline';
else
    splineData=splinedbSelect(metadata);
    x=splineData(splineIndex).controlpt.x;
    y=splineData(splineIndex).controlpt.y;
    splineName= ['spline index ' num2str(splineIndex)];
    
end
title(['Frame ' num2str(currentFrame) ' using the ' splineName],'interpreter','none')

yy = spline(x,y,(1:size(img,2)));


hold on; plot(yy,'y'); hold off;

mmodeImg = zeros(size(img,2),length(framesToProcess));
for ii=1:length(framesToProcess)
    frameNumber=framesToProcess(ii);
    [img] = ultrasonixGetFrame(metadata.rfFilename,frameNumber,ultrasonixGetFrameParms{:});
    mmodeLine=computeCurvedMMode(abs(img).^0.5, yy);
    mmodeImg(:,ii) = mmodeLine;
    
    figure(fig);
    
    subplot(2,1,1); imagesc(abs(img(rowToStartDisplay:end,:)).^0.5); colormap(gray);
    hold on; plot(yy-rowToStartDisplay,'y'); plot(x,y-rowToStartDisplay,'yo'); hold off;
    set(gca,'XTickLabel',''); ylabel('Depth')
    title(['Frame ' num2str(frameNumber) ' of ' num2str(framesToProcess(end))  ' using the ' splineName '.  Hit s to stop.'])
    
    subplot(2,1,2); imagesc(mmodeImg'); xlabel('Lateral distance'); ylabel('Frames');
    
    if  strcmp('s',lower(get(fig, 'CurrentKey')))
        break;  %the user wants to stop
    end
end


end
