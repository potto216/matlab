caseName=mfilename;
metadata=[];


%************************************
%*******Subject Information*********
%************************************
% 1.	Subject
% 1.1.	Simulation phantom
% 1.1.1.	Phantom name (<base name>_<sub name>)
% 1.1.1.1.	Motion Model Name
% 1.1.1.1.1.	Motion model data
% 1.2.	Patient
% 1.2.1.	Original data such as RF or Bmode
% 1.2.2.	Patient information
%Only the phantom information is stored here
metadata.subject.rfFilename=[];
metadata.subject.processFunction=@(x) x;

metadata.subject.name=caseName;  
metadata.subject.phantom.parameter.modelName='translationPixelOnly';
metadata.subject.phantom.parameter.motionModel='lineMotion';
metadata.subject.phantom.parameter.sceneModel='rectangle';
metadata.subject.phantom.parameter.motionModelFunction='modelRigid';
%***************************************
%********Collection Information*********
%***************************************
% 2.	Collection (Output from a sensor or simulator)
% 2.1.	MRI/EMG/Motion Capture
% 2.2.	Image Formation Name (Field II, RF)
% 2.2.1.	Data linking
% 2.2.1.1.	Simulation phantom name/patient
% 2.2.1.2.	Motion model name
% 2.2.2.	Field II (Output of the Field II simulator)
% 2.2.3.	B-Mode *magnitude plot of data
% 2.2.3.1.	Data
% 2.2.3.2.	Parameters
% 2.2.3.2.1.	Image formation parameters
% 2.2.4.	Processed data
% 2.2.4.1.	(could be computationally intensive filtering) 
%**First we have the image render information

%**Now have the collections which could be the original or post processed
metadata.collection.projection.name=caseName;

metadata.collection.projection.filepath=[];
metadata.collection.projection.filepath.pathToRoot=getenv('DATA_ULTRASOUND');
metadata.collection.projection.filepath.root=metadata.collection.projection.name;
metadata.collection.projection.filepath.relative='collection\projection';

metadata.collection.projection.bmode.filepath=[];
metadata.collection.projection.bmode.filepath.pathToRoot=getenv('DATA_ULTRASOUND');
metadata.collection.projection.bmode.filepath.root=metadata.collection.projection.name;
metadata.collection.projection.bmode.filepath.relative='collection\projection\bmode';

metadata.collection.projection.bmode.filetype='image_seq';
metadata.collection.projection.bmode.file.format='png';
metadata.collection.projection.bmode.file.nameMask='%04d';
metadata.collection.projection.bmode.file.sequence=[]; %defines a valid sequence. If empty then autofill
metadata.collection.projection.bmode.scale.lateral.value=1;
metadata.collection.projection.bmode.scale.lateral.units='mm';
metadata.collection.projection.bmode.scale.axial.value=1;
metadata.collection.projection.bmode.scale.axial.units='mm';
metadata.collection.projection.bmode.override.ultrasound.rf.header.dr=1;  %will override the frame rate
metadata.collection.projection.bmode.override.ultrasound.rf.header.sf=1;
metadata.collection.projection.bmode.override.ultrasound.rf.header.txf=0;
metadata.collection.projection.bmode.override.ultrasound.rf.header.probeInfo.name='';
metadata.collection.projection.bmode.override.ultrasound.rf.header.probeInfo.elementPitch_mm=0;
metadata.collection.projection.bmode.override.ultrasound.rf.header.probeInfo.elementCount=0;

metadata.collection.projection.bmode.region.name='rectusFemoris';
agent.name='topRFBorder';
agent.frame=1;
agent.type='spline';
agent.subtype='controlpoint';
agent.vptUnits='pel';
%The dimensions are [axial; lateral]
agent.vpt=[9.3530 6.4891 8.3984 8.8757 8.8757;
           12.1591 101.4321 254.0406 352.3615 434.9993];
       
metadata.collection.projection.bmode.region.agent(1)=agent;

agent.name='bottomRFBorder';
agent.frame=1;
agent.type='spline';
agent.subtype='controlpoint';
agent.vptUnits='pel';        
%The dimensions are [axial; lateral]
agent.vpt=[217.9392 221.7577 225.5762 221.7577 222.7123;
           16.9847 162.3549 295.6611 386.7437 431.9834];

metadata.collection.projection.bmode.region.agent(end+1)=agent;

agent.name='activeSpline';
agent.frame=1;
agent.type='spline';
agent.subtype='controlpoint';
agent.vptUnits='pel';        
agent.vpt=[];  %interpolate between the top and bottom
metadata.collection.projection.bmode.region.agent(end+1)=agent;

%the units are (mm/sec)/(mm/pel)=pel/sec
if ~strcmp(metadata.collection.projection.bmode.scale.lateral.units,'mm') || ...
   ~strcmp(metadata.collection.projection.bmode.scale.axial.units,'mm')
error('Units must be in mm');
end
       
% tmp.lateral.maxSpeed_mmPerSec = 40;
% tmp.lateral.maxSpeed_pelPerSec = ;
tmp.lateral.maxSpeed_pelPerFrame = 10;

% tmp.axial.maxSpeed_mmPerSec = 40;
% tmp.axial.maxSpeed_pelPerSec = ;
tmp.axial.maxSpeed_pelPerFrame = 10;


%left(xmin) right(xmax) bottom(ymin) top(ymax)
%crop.border is the amount to remove from each of the sides
badColumn=[];
metadata.collection.projection.bmode.region.crop.border_rc=[];


%% **********************These general libraries can be overridden if need be***********************
libmtrack_method
libmtrack_node
libmtrack_processstream
