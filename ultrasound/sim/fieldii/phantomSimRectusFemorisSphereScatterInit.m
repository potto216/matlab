%Create a computer model of a rectusFemoris phantom. The phantom is designed
%by using a user defined spline for the center of the rectusFemoris which is then
%populated with random point scatters.  These scatters can then be applied
%to parallel curves in a different pseudo random pattern.  The model
%removes any background points from the rectusFemoris
%
%The basic rectusFemoris images
%start 6mm/0mm
%min rectusFemoris depth 8mm/2mm
%max rectusFemoris depth 15mm/9mm
%max image depth 20mm/14mm
%width 60mm
%
%INPUTS
%totalBackgroundScatters - the total number of background scatters used
%totalRectusFemorisScattersPerBand - the total number of rectusFemoris scatters used per band.
%DataBlockObj - This file will configure the phantom to model a collect
%geometry.
%totalBandsPerRectusFemoris - The total bands per rectusFemoris

function phantomData = phantomSimRectusFemorisInit(varargin)

fid=1;

p = inputParser;   % Create an instance of the class.
p.addParamValue('totalBackgroundScatters',10000, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('totalRectusFemorisScattersPerBand',300, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('totalBandsPerRectusFemoris',12, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('DataBlockObj',[],  @(x) isa(x,'DataBlockObj'));
p.addParamValue('trialData',[],  @(x) (isempty(x) || isstruct(x)) );
p.addParamValue('verbose',true,  @(x) islogical(x));

p.parse(varargin{:});

totalBackgroundScatters = p.Results.totalBackgroundScatters;
totalRectusFemorisScattersPerBand = p.Results.totalRectusFemorisScattersPerBand;
totalBandsPerRectusFemoris=p.Results.totalBandsPerRectusFemoris;
dataBlockObj=p.Results.DataBlockObj;
trialData=p.Results.trialData;
verbose=p.Results.verbose;

scatterSphereRadius_m=trialData.subject.phantom.parameter.scatterSphereRadius_m;
scatterSphereAmplitude=trialData.subject.phantom.parameter.scatterSphereAmplitude;
scattersPerSphere=trialData.subject.phantom.parameter.scattersPerSphere;
transverseWidthOfPhantom_m=trialData.subject.phantom.parameter.transverseWidthOfPhantom_m;
%% First load the spline info
%
    
    imageWidth_pel=dataBlockObj.size(2);
    totalSplines=totalBandsPerRectusFemoris;

    vpt=trialData.subject.phantom.tissueBorder.agent(strcmp({trialData.subject.phantom.tissueBorder.agent.name},'topSpline')).vpt;
    topSpline.controlpt.x=vpt(2,:);
    topSpline.controlpt.y=vpt(1,:);
    
    vpt=trialData.subject.phantom.tissueBorder.agent(strcmp({trialData.subject.phantom.tissueBorder.agent.name},'bottomSpline')).vpt;
    bottomSpline.controlpt.x=vpt(2,:);
    bottomSpline.controlpt.y=vpt(1,:);

%     vpt=trialData.subject.phantom.tissueBorder.agent(strcmp({trialData.subject.phantom.tissueBorder.agent.name},'activeSpline')).vpt;
%     activeSpline.controlpt.x=vpt(2,:);
%     activeSpline.controlpt.y=vpt(1,:);
           
    
    
   % activeMatchPtY=spline(activeSpline.controlpt.x,activeSpline.controlpt.y,matchPtX);
    %Put the active spline at the top of the image
    %activeSpline.controlpt.y=activeSpline.controlpt.y+(topMatchPtY-activeMatchPtY);
    
   
    lateral_mm=dataBlockObj.getUnitsValue('lateral','mm');
    axial_mm=dataBlockObj.getUnitsValue('axial','mm');
    xSize_m=dataBlockObj.size(2)*lateral_mm/1000;
    ySize_m = transverseWidthOfPhantom_m;   %  Transverse width of phantom [mm]
    zSize_m=dataBlockObj.metadata.ultrasound.rf.header.h*axial_mm/1000;
    phantomData.caseData.caseFilename=dataBlockObj.activeCaseName;
    phantomData.caseData.metadata=dataBlockObj.metadata;
    %axialSpacing_m=((bottomMatchPtY-topMatchPtY)/totalSplines)*(0:(totalSplines-1))*(axial_mm/1000);
    

if verbose
    fprintf(fid,'The phantom x,y,z dimensions are: (%0.2f, %0.2f, %0.2f) mm.\n', xSize_m*1000,ySize_m*1000,zSize_m*1000);
end

%  Create the general scatterers
N=totalBackgroundScatters; %-size(samplePoints_mm,2);
x_m = (rand (N,1)-0.5)*xSize_m;
y_m = (rand (N,1)-0.5)*ySize_m;
z_m = rand (N,1)*zSize_m;

phantomData.xLim_m =[-(xSize_m/2) (xSize_m/2)];   %  Width of phantom
phantomData.yLim_m =[-(ySize_m/2) (ySize_m/2)];   %  Lateral
phantomData.zLim_m =[0  zSize_m];   %   Height of phantom

%



%  Generate the amplitudes with a Gaussian distribution
if true
    
    
%     samplePointsContinuous_rc_mm=splineSample(activeSpline.controlpt.x,activeSpline.controlpt.y, ...
%         dataBlockObj.size(2), ...
%         lateral_mm,axial_mm,'forceEqualSpace',true,'samplePointsOutputFormat','scale');
%     
%     samplePointsContinuous_rc_m=(samplePointsContinuous_rc_mm+repmat([0; phantomData.xLim_m(1)*1000],1,size(samplePointsContinuous_rc_mm,2)))/1000;
    
else
end



amp=randn(totalBackgroundScatters,1);
%  Return the variables
phantomData.background.x_m=x_m;
phantomData.background.y_m=y_m;
phantomData.background.z_m=z_m;
phantomData.background.amplitude=amp(:);

%This must step from closest laterial position to farthest so the removal
%code will work
%     sx_m=activeSpline.controlpt.x*lateral_mm/1000+phantomData.xLim_m(1);
%     sz_m=activeSpline.controlpt.y*axial_mm/1000+phantomData.zLim_m(1);
%     
%     
%     sxx_m = samplePointsContinuous_rc_m(2,:);
%     szz_m = samplePointsContinuous_rc_m(1,:);

    %To do the interpolation between the frames we interp along the x
    %direction evenly. Then we linspace between those points for the top and bottom spline
    %and use that as the spline sample even though it is not great, but can
    %be improved later to model contraction
    pelWidth_mPerPel=lateral_mm/1000;
    %make sure the start is a sphere sized in
    scatterSphereRadius_pel=scatterSphereRadius_m/pelWidth_mPerPel;
    matchPtX=linspace(1+scatterSphereRadius_pel,imageWidth_pel-scatterSphereRadius_pel,imageWidth_pel);
    
    topMatchPtY=spline(topSpline.controlpt.x,topSpline.controlpt.y,matchPtX);
    bottomMatchPtY=spline(bottomSpline.controlpt.x,bottomSpline.controlpt.y,matchPtX);
    
    bandPointsPtY=topMatchPtY.'*ones(1,totalBandsPerRectusFemoris) + (bottomMatchPtY.'-topMatchPtY.')*linspace(0,1,totalBandsPerRectusFemoris);
    sZZ_m = bandPointsPtY*axial_mm/1000+phantomData.zLim_m(1);
    sXX_m = repmat(matchPtX.'*lateral_mm/1000+phantomData.xLim_m(1),1,size(sZZ_m,2));

         
for ii=1:totalBandsPerRectusFemoris
    S_m=repmat(sXX_m(:,ii),1,scattersPerSphere)+scatterSphereRadius_m*(rand(size(sXX_m,1),scattersPerSphere)-0.5);
    if any(S_m(:)<phantomData.xLim_m(1)) || any(S_m(:)>phantomData.xLim_m(2))
        error('Phantom X dimension was violated.');
    end
    phantomData.rectusFemoris.band(ii).x_m=S_m(:);
    
    S_m=repmat((rand(size(sXX_m,1),1)-0.5)*(4/1000-scatterSphereRadius_m),1,scattersPerSphere)+scatterSphereRadius_m*(rand(size(sXX_m,1),scattersPerSphere)-0.5);
    if any(S_m(:)<phantomData.yLim_m(1)) || any(S_m(:)>phantomData.yLim_m(2))
        error('Phantom Y dimension was violated.');
    end
    phantomData.rectusFemoris.band(ii).y_m=S_m(:);
    
    S_m=repmat(sZZ_m(:,ii),1,scattersPerSphere)+scatterSphereRadius_m*(rand(size(sZZ_m,1),scattersPerSphere)-0.5);
    if any(S_m(:)<phantomData.zLim_m(1)) || any(S_m(:)>phantomData.zLim_m(2))
        error('Phantom Z dimension was violated.');
    end    
    phantomData.rectusFemoris.band(ii).z_m=S_m(:);
    
    phantomData.rectusFemoris.band(ii).amplitude=scatterSphereAmplitude*ones(size(sXX_m,1)*scattersPerSphere,1);
    
    phantomData.rectusFemoris.band(ii).spline.controlpt.x_m=sXX_m(:,ii);
    phantomData.rectusFemoris.band(ii).spline.controlpt.z_m=sZZ_m(:,ii);
end




if false
    %%
    figure; %#ok<UNRCH>
    plot(phantomData.background.x_m,phantomData.background.z_m,'b.')
    hold on;
    for ii=1:length(phantomData.rectusFemoris.band)
        plot(phantomData.rectusFemoris.band(ii).x_m,phantomData.rectusFemoris.band(ii).z_m,'r.')
    end
    axis([-(xSize_m/2) (xSize_m/2) 0 (zSize_m)])
    xlabel('m');
    ylabel('m');
    a1=gca;
    set(a1,'YDir','reverse')
    title('Scatter placement.')
    legend('background','rectusFemoris')
end

%% Now we want to remove the background scatters from the rectusFemoris image
%we override the sides so they strech to eliminate any background scatters
%at the edges
chkDistTopx=[sXX_m(1:end-1,1).';sXX_m(2:end,1).'];
chkDistTopx(1,1)=phantomData.xLim_m(1);
chkDistTopx(2,end)=phantomData.xLim_m(2);

chkDistTopz=[sZZ_m(1:end-1,1).';sZZ_m(2:end,1).'];

chkDistBottomx=[sXX_m(1:end-1,end).';sXX_m(2:end,end).'];
chkDistBottomx(1,1)=phantomData.xLim_m(1);
chkDistBottomx(2,end)=phantomData.xLim_m(2);

chkDistBottomz=[sZZ_m(1:end-1,end).';sZZ_m(2:end,end).'];

dprodTop=zeros(length(phantomData.background.x_m),1);
dprodBottom=zeros(length(phantomData.background.x_m),1);

%We remove the points by seeing if they fall in the range of top and bottom
%and then checking to see if dot

if verbose
    fprintf(fid,'Removing background points in the rectusFemoris boundary.  This may take a while.\n');
end
for tt=1:length(phantomData.background.x_m)
    topIndex=find((phantomData.background.x_m(tt)>=chkDistTopx(1,:)) &  (phantomData.background.x_m(tt)<chkDistTopx(2,:)));
    bottomIndex=find((phantomData.background.x_m(tt)>=chkDistBottomx(1,:)) &  (phantomData.background.x_m(tt)<chkDistBottomx(2,:)));
    
    if length(topIndex)~=1 || length(bottomIndex)~=1
        dprodTop(tt)=1;
        dprodBottom(tt)=1;
    else
        vt=diff([-chkDistTopz(:,topIndex) chkDistTopx(:,topIndex)]',1,2);
        vts=diff([chkDistTopx(1,topIndex) phantomData.background.x_m(tt); chkDistTopz(1,topIndex) phantomData.background.z_m(tt)],1,2);
        
        vb=diff([-chkDistBottomz(:,topIndex) chkDistBottomx(:,topIndex)]',1,2);
        vbs=diff([chkDistBottomx(1,topIndex) phantomData.background.x_m(tt); chkDistBottomz(1,topIndex) phantomData.background.z_m(tt)],1,2);
        
        %figure; plot([0 vt(1)],[0,vt(2)],'b'); hold on; plot([0 vts(1)],[0,vts(2)],'r:');
        dprodTop(tt)=vt'*vts/sqrt(vt'*vt*(vts'*vts));
        dprodBottom(tt)=vb'*vbs/sqrt(vb'*vb*(vbs'*vbs));
        %         if ~((dprodTop(tt)>0  & dprodBottom(tt)<0))
        %             disp('fail')
        %         end
        
    end
    
end


ptsInsideRectusFemorisIdx=(dprodTop>0  & dprodBottom<0);


%%
if false
    %%
    f1=figure; %#ok<UNRCH>
    plot3(phantomData.background.x_m(~ptsInsideRectusFemorisIdx),phantomData.background.y_m(~ptsInsideRectusFemorisIdx),phantomData.background.z_m(~ptsInsideRectusFemorisIdx),'r.')
    hold on
    plot3(phantomData.background.x_m(ptsInsideRectusFemorisIdx),phantomData.background.y_m(ptsInsideRectusFemorisIdx),phantomData.background.z_m(ptsInsideRectusFemorisIdx),'b.')
    
    plot3(phantomData.rectusFemoris.band(1).x_m,phantomData.rectusFemoris.band(1).x_m*0,phantomData.rectusFemoris.band(1).z_m,'g.')
    plot3(phantomData.rectusFemoris.band(end).x_m,phantomData.rectusFemoris.band(end).x_m*0,phantomData.rectusFemoris.band(end).z_m,'g.')
    
    xlabel('lateral distance (m)')
    zlabel('axial distance (m)')
end

% remove the background points
phantomData.background.x_m(ptsInsideRectusFemorisIdx)=[];
phantomData.background.y_m(ptsInsideRectusFemorisIdx)=[];
phantomData.background.z_m(ptsInsideRectusFemorisIdx)=[];
phantomData.background.amplitude(ptsInsideRectusFemorisIdx)=[];

if verbose
    fprintf(fid,'Background points removal complete.\n');
end