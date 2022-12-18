if numel(getenv('DATA_PROCESS'))==0
    error('define the path DATA_PROCESS');
end

if numel(getenv('DATA_ULTRASOUND'))==0
    error('define the path DATA_ULTRASOUND');
end

caseName=mfilename;

metadata=[];

% This is the file which is being used as reference

%This is used as reference values for the projective and Field II collects 
metadata.collection.ultrasound.rf.header.filetype=16;
metadata.collection.ultrasound.rf.header.nframes=421;
metadata.collection.ultrasound.rf.header.w=128;
metadata.collection.ultrasound.rf.header.h=1824;
metadata.collection.ultrasound.rf.header.ss=16;
metadata.collection.ultrasound.rf.header.ul=[0 0];
metadata.collection.ultrasound.rf.header.ur=[0 0];
metadata.collection.ultrasound.rf.header.br=[0 0];
metadata.collection.ultrasound.rf.header.bl=[0 0];
metadata.collection.ultrasound.rf.header.probe=7;
metadata.collection.ultrasound.rf.header.txf=10000000;
metadata.collection.ultrasound.rf.header.sf=40000000;
metadata.collection.ultrasound.rf.header.dr=56;
metadata.collection.ultrasound.rf.header.ld=128;
metadata.collection.ultrasound.rf.header.extra=0;

metadata.collection.ultrasound.rf.header.file.version='2.0';
metadata.collection.ultrasound.rf.header.fileheaderSizeBytes=76;
metadata.collection.ultrasound.rf.header.fileframeSizeBytes=466944;

metadata.collection.ultrasound.rf.header.probeInfo.name='L14-5W/60';
metadata.collection.ultrasound.rf.header.probeInfo.elementPitch_mm=0.4720;
metadata.collection.ultrasound.rf.header.probeInfo.elementCount=128;

metadata.collection.ultrasound.rf.header.pixel.scale.axial.value=0.0192;
metadata.collection.ultrasound.rf.header.pixel.scale.axial.units='mm';

metadata.collection.ultrasound.rf.header.pixel.scale.lateral.value=0.4720;
metadata.collection.ultrasound.rf.header.pixel.scale.lateral.units='mm';

metadata.subject.rfFilename=[];
metadata.subject.processFunction=@(x) x;

metadata.subject.name=caseName;  


metadata.subject.phantom.name=caseName;  

metadata.subject.phantom.filepath=[];
metadata.subject.phantom.filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.subject.phantom.filepath.root=metadata.subject.phantom.name;
metadata.subject.phantom.filepath.relative='phantom';
metadata.subject.phantom.filename='phantomMasterDataFile.mat'; 

%  Create a computer model of a cyst phantom. The phantom contains
%  fiven point targets and 6, 5, 4, 3, 2 mm diameter waterfilled cysts, 
%  and 6, 5, 4, 3, 2 mm diameter high scattering regions. All scatterers 
%  are situated in a box of (x,y,z)=(50,10,60) mm and the box starts 
%  30 mm from the transducer surface.

metadata.subject.phantom.parameter.modelName='cyst';
metadata.subject.phantom.parameter.motionModel='lineMotion';
%What are the dimensions of the scatter field which is normally larger than
%the phantom. Both the scatter field and phantom map to the world

%  Width of scatterfield [X],Transverse width of scatterfield [Y], Height of scatterfield [Z]
metadata.subject.phantom.parameter.scatterField.size_m = [50/1000; 20/1000; 120/1000]; 
%Map the origin (0,0,0) point in the scatter field to a point in world
%space. For example originToWorld_m =[1 2 3] means that [0,0,0] in scatter
%space maps to [1,2,3] in world space.
metadata.subject.phantom.parameter.scatterField.originToWorld_m = [0; 0; 6/1000]; 

%random scatters will be placed in here
metadata.subject.phantom.parameter.scatterField.clipZ_m=[0/1000; 60/1000];

%These are created over the scatterfield in the +/- size/2 for X and Y, and
%0 size in the Z.
metadata.subject.phantom.parameter.backgroundScatter.amplitude=1; %This is the std of a normal
metadata.subject.phantom.parameter.backgroundScatter.total=1000000;


%These are in scatter field coordinates not transducer
%Put the larger spheres farther away 
xc=10; yc=0; zc=[50:-10:10];
% 6 mm cyst 
metadata.subject.phantom.parameter.sphere.center_m = [xc; yc; zc(1)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 6/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 0;

%5 mm cyst
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(2)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 5/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 0;

%4 mm cyst
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(3)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 4/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 0;

%3 mm cyst
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(4)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 3/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 0;

%2 mm cyst
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(5)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 2/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 0;

%These are in scatter field coordinates not transducer
%Put the larger spheres farther away
xc = -5; yc = 0; zc = [50:-10:10];
% 6 mm bright cyst 
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(1)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 6/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 3;

%5 mm bright cyst
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(2)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 5/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 3;

%4 mm bright cyst
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(3)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 4/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 3;

%3 mm bright cyst
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(4)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 3/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 3;

%2 mm bright cyst
metadata.subject.phantom.parameter.sphere(end+1).center_m = [xc; yc; zc(5)]/1000;
metadata.subject.phantom.parameter.sphere(end).radius_m = 2/1000;
metadata.subject.phantom.parameter.sphere(end).amplitude = 3;

%These are in scatter field coordinates not transducer
xc = -15; yc = 0; zc = [10:10:50];
metadata.subject.phantom.parameter.point.center_m = [xc; 0; zc(1)]/1000;
metadata.subject.phantom.parameter.point(end).amplitude = 20;

metadata.subject.phantom.parameter.point(end+1).center_m = [xc; 0; zc(2)]/1000;
metadata.subject.phantom.parameter.point(end).amplitude = 20;

metadata.subject.phantom.parameter.point(end+1).center_m = [xc; 0; zc(3)]/1000;
metadata.subject.phantom.parameter.point(end).amplitude = 20;

metadata.subject.phantom.parameter.point(end+1).center_m = [xc; 0; zc(4)]/1000;
metadata.subject.phantom.parameter.point(end).amplitude = 20;

metadata.subject.phantom.parameter.point(end+1).center_m = [xc; 0; zc(5)]/1000;
metadata.subject.phantom.parameter.point(end).amplitude = 20;

%% This is the velocity of motion 
%#TODO This should be sampled based on the frame rate of the collection system. Therefore, we will need to do a interp
motion_mmPerSec=[0 -2 -2 -2 -2];
metadata.subject.phantom.parameter.offset_mPerSec = motion_mmPerSec/1000;
metadata.subject.phantom.parameter.ts_sec=1/56;

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
metadata.collection.projection.bmode.file.sequence=[1:20]; %defines a valid sequence. If empty then autofill
metadata.collection.projection.bmode.scale.lateral.value=108.000000e-3;
metadata.collection.projection.bmode.scale.lateral.units='mm';
metadata.collection.projection.bmode.scale.axial.value=108.000000e-3;
metadata.collection.projection.bmode.scale.axial.units='mm';
metadata.collection.projection.bmode.override.ultrasound.rf.header.dr=1;  %will override the frame rate
metadata.collection.projection.bmode.override.ultrasound.rf.header.sf=1;

%the units are (mm/sec)/(mm/pel)=pel/sec
if ~strcmp(metadata.collection.projection.bmode.scale.lateral.units,'mm') || ...
   ~strcmp(metadata.collection.projection.bmode.scale.axial.units,'mm')
error('Units must be in mm');
end


%Define the output image sizes.  This is an optional field which defines
%the output image size and each cell element contains the specification for
%a single output image
metadata.collection.projection.bmode.imOutputFormat=[];
metadata.collection.projection.bmode.imOutputFormat(1).type='matchrf';
%This defines how must the background gainin the final image should be
%scaled, because it often needs to be adjusted relative to the scatters
metadata.collection.projection.bmode.imOutputFormat(1).background.imFinalGain = 6;
metadata.collection.projection.bmode.imOutputFormat(1).imresize.filter = @() fspecial('gaussian',[9,3],3);

metadata.collection.projection.bmode.imOutputFormat(2).type='squarePixel';
metadata.collection.projection.bmode.imOutputFormat(2).background.imFinalGain = 2;
metadata.collection.projection.bmode.imOutputFormat(2).dim.type='axial';
metadata.collection.projection.bmode.imOutputFormat(2).dim.size=512;
metadata.collection.projection.bmode.imOutputFormat(2).imresize.filter = @() fspecial('gaussian',[4,4],3);


%**Now have the Field II data
metadata.collection.fieldii.name=caseName;
%metadata.collection.fieldii.offsetZ_m=6/1000;
metadata.collection.fieldii.filepath=[];
metadata.collection.fieldii.filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.collection.fieldii.filepath.root=metadata.collection.fieldii.name;
metadata.collection.fieldii.filepath.relative='collection\fieldii';

metadata.collection.fieldii.subject.phantom.name=metadata.subject.phantom.name;

metadata.collection.fieldii.rf.filepath=[];
metadata.collection.fieldii.rf.filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.collection.fieldii.rf.filepath.root=metadata.collection.fieldii.name;
metadata.collection.fieldii.rf.filepath.relative='collection\fieldii\rf';

metadata.collection.fieldii.bmode.filepath=[];
metadata.collection.fieldii.bmode.filepath.pathToRoot=getenv('DATA_PROCESS');
metadata.collection.fieldii.bmode.filepath.root=metadata.collection.fieldii.name;
metadata.collection.fieldii.bmode.filepath.relative='collection\fieldii\bmode';

%Define the output image sizes.  This is an optional field which defines
%the output image size and each cell element contains the specification for
%a single output image
metadata.collection.fieldii.bmode.imOutputFormat=[];
metadata.collection.fieldii.bmode.imOutputFormat(1).type='matchrf';
%This defines how must the background gainin the final image should be
%scaled, because it often needs to be adjusted relative to the scatters
metadata.collection.fieldii.bmode.imOutputFormat(1).background.imFinalGain = 6;
metadata.collection.fieldii.bmode.imOutputFormat(1).imresize.filter = @() fspecial('gaussian',[9,3],3);

metadata.collection.fieldii.bmode.imOutputFormat(2).type='squarePixel';
metadata.collection.fieldii.bmode.imOutputFormat(2).background.imFinalGain = 2;
metadata.collection.fieldii.bmode.imOutputFormat(2).dim.type='axial';
metadata.collection.fieldii.bmode.imOutputFormat(2).dim.size=512;
metadata.collection.fieldii.bmode.imOutputFormat(2).imresize.filter = @() fspecial('gaussian',[4,4],3);

     
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
