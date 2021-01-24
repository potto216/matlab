%Create a computer model of a rectusFemoris phantom. The phantom is designed
%by using a user defined spline for the center of the rectusFemoris which is then
%populated with random point scatters.  These sctters can then be applied
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
%trialData.subject.phantom.parameter.scatterSphereAmplitude - is the
%scatter amplitude of the rectus femoris band

function phantomData = phantomSimRectusFemorisFascicleInit(varargin)

fid=1;

p = inputParser;   % Create an instance of the class.
p.addParamValue('totalBackgroundScatters',10000, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('totalBandsPerRectusFemoris',12, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('DataBlockObj',[],  @(x) isa(x,'DataBlockObj'));
p.addParamValue('trialData',[],  @(x) (isempty(x) || isstruct(x)) );
p.addParamValue('verbose',true,  @(x) islogical(x));

p.parse(varargin{:});

totalBackgroundScatters = p.Results.totalBackgroundScatters;
totalBandsPerRectusFemoris=p.Results.totalBandsPerRectusFemoris;
dataBlockObj=p.Results.DataBlockObj;
trialData=p.Results.trialData;
verbose=p.Results.verbose;

scatterSphereAmplitude=trialData.subject.phantom.parameter.scatterSphereAmplitude;
transverseWidthOfPhantom_m=trialData.subject.phantom.parameter.transverseWidthOfPhantom_m;

fasciclePositionAndLength_mm=trialData.subject.phantom.parameter.fasciclePositionAndLength_mm;
fascicleBackgroundScattersTotal=trialData.subject.phantom.parameter.fascicleBackgroundScattersTotal;
phantomData.fasciclesEnabled=trialData.subject.phantom.parameter.fasciclesEnabled;
phantomData.fascicleMaxStrandLength_mm=trialData.subject.phantom.parameter.fascicleMaxStrandLength_mm;
phantomData.backgroundScatter.amplitude=trialData.subject.phantom.parameter.backgroundScatter.amplitude;
phantomData.fascicleBackgroundScattersAmplitude=trialData.subject.phantom.parameter.fascicleBackgroundScattersAmplitude;
phantomData.fascicleScatterCylinderRadius_m=trialData.subject.phantom.parameter.fascicleScatterCylinderRadius_m;
%% First load the spline info
%

imageWidth_pel=dataBlockObj.size(2);
%totalSplines=totalBandsPerRectusFemoris;

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


amp=randn(totalBackgroundScatters,1)+phantomData.backgroundScatter.amplitude;
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
matchPtX=linspace(1,imageWidth_pel,imageWidth_pel);

topMatchPtY=spline(topSpline.controlpt.x,topSpline.controlpt.y,matchPtX);
bottomMatchPtY=spline(bottomSpline.controlpt.x,bottomSpline.controlpt.y,matchPtX);

%Interpolate to find the other points
bandPointsPtY=topMatchPtY.'*ones(1,totalBandsPerRectusFemoris) + (bottomMatchPtY.'-topMatchPtY.')*linspace(0,1,totalBandsPerRectusFemoris);
sZZ_m = bandPointsPtY*axial_mm/1000+phantomData.zLim_m(1);
sXX_m = repmat(matchPtX.'*lateral_mm/1000+phantomData.xLim_m(1),1,size(sZZ_m,2));



if (diff(phantomData.xLim_m)+10/1000)>(phantomData.fascicleMaxStrandLength_mm/100)
    error('maxLength is too small');
end




for ii=1:totalBandsPerRectusFemoris
    
    %/17 as an approximate to get
    strand_m=createStrand(phantomData.fascicleMaxStrandLength_mm,fasciclePositionAndLength_mm{ii},phantomData.fascicleScatterCylinderRadius_m*1000,false);
    %strand has to flip x and z because z is the length for strand and that
    %needs to be mapped to the x of the phantom
    phantomData.rectusFemoris.band(ii).x_m=strand_m(3,:).';
    phantomData.rectusFemoris.band(ii).y_m=strand_m(2,:).';
    phantomData.rectusFemoris.band(ii).z_m=strand_m(1,:).';
    
    
    phantomData.rectusFemoris.band(ii).amplitude=scatterSphereAmplitude*ones(size(strand_m,2),1);
    
    phantomData.rectusFemoris.band(ii).spline.controlpt.x_m=sXX_m(:,ii);
    phantomData.rectusFemoris.band(ii).spline.controlpt.z_m=sZZ_m(:,ii);
end


if fascicleBackgroundScattersTotal>0
    %maxZDistance=max(abs(sZZ_m(:,1)-sZZ_m(:,end)));
    
    %sart the scatter grid at the start of the phantom
    phantomData.rectusFemoris.background.x_m=(rand(fascicleBackgroundScattersTotal,1))*phantomData.fascicleMaxStrandLength_mm/1000+phantomData.xLim_m(1);
    phantomData.rectusFemoris.background.y_m=(rand(fascicleBackgroundScattersTotal,1)-0.5)*ySize_m;
    %The lambda decides where in z they should be as they travel through
    %the muscle and the tissue is compressed and expanded. So lambda is a
    %relative z component
    phantomData.rectusFemoris.background.lambda=rand(fascicleBackgroundScattersTotal,1);
        
    phantomData.rectusFemoris.background.amplitude=randn(fascicleBackgroundScattersTotal,1)+phantomData.fascicleBackgroundScattersAmplitude;
    phantomData.rectusFemoris.background.topSpline_m=spline(topSpline.controlpt.x*lateral_mm/1000+phantomData.xLim_m(1),topSpline.controlpt.y*axial_mm/1000+phantomData.zLim_m(1));
    phantomData.rectusFemoris.background.bottomSpline_m=spline(bottomSpline.controlpt.x*lateral_mm/1000+phantomData.xLim_m(1),bottomSpline.controlpt.y*axial_mm/1000+phantomData.zLim_m(1));
    

    
    
%     ftop_m = fnval(phantomData.rectusFemoris.background.topSpline_m,phantomData.rectusFemoris.background.x_m);
%     fbottom_m = fnval(phantomData.rectusFemoris.background.bottomSpline_m,phantomData.rectusFemoris.background.x_m);
%     %fm(x)=ft(x)+(1-m)*fb(x)
%     %(fm(x)-ft(x))/fb(x)=1-m
%     %m=(1-(fm(x)-ft(x))/fb(x))
%     %remember top is a smaller number (closer to the origin than bottom)
%     m=(1-(phantomData.rectusFemoris.background.z_m-ftop_m)./fbottom_m);
%     phantomData.rectusFemoris.background.lambda=m;
    
    if false
        figure;
        plot(phantomData.rectusFemoris.background.x_m,ftop_m,'.');
        hold on;
        plot(phantomData.rectusFemoris.background.x_m,fbottom_m,'.');
        plot(phantomData.rectusFemoris.background.x_m,phantomData.rectusFemoris.background.z_m,'g.');
    end
else
    phantomData.rectusFemoris.background.x_m=[];
    phantomData.rectusFemoris.background.y_m=[];
    phantomData.rectusFemoris.background.z_m=[];
    
    phantomData.rectusFemoris.background.amplitude=[];
    phantomData.rectusFemoris.background.topSpline_m=spline(topSpline.controlpt.x*lateral_mm/1000+phantomData.xLim_m(1),topSpline.controlpt.y*axial_mm/1000+phantomData.zLim_m(1));
    phantomData.rectusFemoris.background.bottomSpline_m=spline(bottomSpline.controlpt.x*lateral_mm/1000+phantomData.xLim_m(1),bottomSpline.controlpt.y*axial_mm/1000+phantomData.zLim_m(1));
    
    
end



topSpline.x_m=sXX_m(:,1);
topSpline.z_m=sZZ_m(:,1);

bottomSpline.x_m=sXX_m(:,end);
bottomSpline.z_m=sZZ_m(:,end);
pointList=phantomData.background;
[ ptsInsideRectusFemorisIdx ] = phantomPointBetweenSplines( topSpline,bottomSpline,phantomData,pointList,verbose,fid);


if false
    %%
    figure; %#ok<UNRCH>
    %  plot(phantomData.background.x_m,phantomData.background.z_m,'b.')
    hold on;
    for ii=1:length(phantomData.rectusFemoris.band)
        plot(phantomData.rectusFemoris.band(ii).x_m,phantomData.rectusFemoris.band(ii).z_m,'r.')
    end
    plot(sXX_m(:,1),sZZ_m(:,1),'g')
    plot(sXX_m(:,end),sZZ_m(:,end),'g')
    axis([-(xSize_m/2) (xSize_m/2) 0 (zSize_m)])
    xlabel('m');
    ylabel('m');
    a1=gca;
    set(a1,'YDir','reverse')
    title('Scatter placement.')
    legend('background','rectusFemoris')
end



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
allBackgroundPtsInsideRectusFemorisIdx=find(ptsInsideRectusFemorisIdx);







% remove the background points
phantomData.background.x_m(ptsInsideRectusFemorisIdx)=[];
phantomData.background.y_m(ptsInsideRectusFemorisIdx)=[];
phantomData.background.z_m(ptsInsideRectusFemorisIdx)=[];
phantomData.background.amplitude(ptsInsideRectusFemorisIdx)=[];

if verbose
    fprintf(fid,'Background points removal complete.\n');
end
end
