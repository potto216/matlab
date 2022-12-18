%DESCRIPTION
%	This function opens a set of test frames.  The image returned is a grayscale
%image, however its amplitude value range depends on the model used. Right now 
%everything is measured in row,column units although it could be x,y.
%
%
%INPUTS
%	frameSize_rc - the maximum frame size in row/column format.  
%
%	maxFrames - the maximum number of frames that will be requested.  If translation is a matrix then
%maxFrames must be a row vector that is the same number of columns that the translation matrix is.  Each
%column corresponds to the number of columns in setParameters.
%
%	setName - {'translation','backforth'} A string that is the valid set name. 
%	'translation' - This model translateds frames a fixed amount relative to each other. 
%Additional required variables to specify:
% 	setParameters - a column vector or matrix that is the number of element movement per frame.
%Each column is the translation per frame for maxFrames at that column index.  If this is a cell array then
%it is {translationPerFrame_rc, startPosition_rc}.  startpos_rc is useful when using iamgefiles where the
%user would like to focus on a specific part of the image.
%
%	imageModel - {'randn','imagefile'}  The image model sets the image that is used.  'randn' will
%will use IDD Gaussian random variables.  'imagefile' will use a file as image and it must be as large as the 
%maximum translation.
%	imageParameters - The values depend on the image model.  These are like keyvalue pairs because they must
%be specified.
%		'randn'  must be empty([]).  If the argument is missing it will complain.
%		'imagefile' the parameter is a filename string and the extension of the file will decide how it is loaded.
%The supported formats are {'.hdf5'}
%
%OUTPUTS
%	obj - the structure that holds the state of the "object"
%
%EXAMPLE
%This examples retrieves one frame from a test set
%>>[obj]=frameSetOpen([512 512],60,'translation',[1 -1],'randn',[]);
%>>[obj, img1]=frameSetGet(obj, frameNumber);
%>>[obj]=frameSetClose(obj);
%
%<todo>
%Make sure that the maxMove will be exact with the max frame get
%</todo>
%The units rc means it is in the form of row,column 
function [obj]=frameSetOpen(frameSize_rc,maxFrames,setName,setParameters,imageModel,imageParameters)

%The global values are needed to store the data image and the path through the image.  
%Because Matlab is pass by value we don't want to send these back...Yes optimizations in Matlab
%mean that it should treat a read only pass by value as a pass by reference and we could use the
%handle class however we want this to work in Octave also.
global g_frameSetMap_rc
global g_frameSetPath

if ~isempty(g_frameSetMap_rc)
	error('The frameSet was already open.  Please close first.');
end

%Validate the input data
if ~isvector(frameSize_rc) || length(frameSize_rc)~=2 || ~isnumeric(frameSize_rc) || any(frameSize_rc<=0) || ~isNoFraction(frameSize_rc)
 error(['frameSize_rc must be a vector of length 2 and an integer and its values must be greater than 0'])
end
frameSize_rc=frameSize_rc(:);  %make sure it is a column vector

if ~isnumeric(maxFrames) || all(maxFrames<=0) || any(~isNoFraction(maxFrames))
 error(['maxFrames must be a scalar integer greater than 0'])
end


%decode the setname and any parameters for the particular model
switch(setName)
case 'translation'
	if isempty(setParameters) 
		error([ setName ' model takes one input argument.'])
	end
	
	if iscell(setParameters)
		if length(setParameters)~=2
			error('setParameters must be only two elements')
		end
		translationPerFrame_rc=setParameters{1};
		startPosition_rc=setParameters{2};
	elseif isnumeric(setParameters)
		translationPerFrame_rc=setParameters;
		startPosition_rc=[1;1];
	end

	if size(translationPerFrame_rc,1)~=2 || ~isnumeric(translationPerFrame_rc)
		error(['translationPerFrame_rc must be a vector or matrix of length 2 '])
	end

	if size(translationPerFrame_rc,2)~=size(maxFrames,2)
		error(['translationPerFrame_rc must have the same number of columns as maxFrames'])
	end	
	
	
	
	%we need to find the maximum movement so we know how large to make the master frame.  This is done by finding the max
	%translation for each maxFrames and then 	
	x=cumsum([[0;0] translationPerFrame_rc.*repmat(maxFrames,2,1)],2)
	maxMovement_rc=[floor(min(x,[],2))  ceil( max(x,[],2))];
	
	%we need to expand the movement out into a frame by frame translation.
	
	
	if ~all(size(maxMovement_rc)==[2 2]) || ~isnumeric(maxMovement_rc) || ~isNoFraction(maxMovement_rc(:))
		error(['maxMovement_rc must be a 2 by 2 matrix without a fraction part'])
	end
	
	
otherwise
	error(['Invalid set name of ' of setName]);
end



%now decode the model
switch(imageModel)
case 'randn'

	if ~isempty(imageParameters) 
		error([ imageModel ' model takes an empty argument.'])
	end
	%we want to find the dimensions of the surface of the final grid.
	%This is the full movement size with half the frame width added everywhere
	frameMapCoordinates=repmat(ceil(frameSize_rc/2),1,2).*repmat([-1 1],2,1)+maxMovement_rc;
	g_frameSetMap_rc=randn(diff(frameMapCoordinates,[],2)+[1;1]);
	
	g_frameSetPath=cumsum([[0;0] [ones(1,10); zeros(1,10)] [zeros(1,10); ones(1,10)] [-ones(1,10); ones(1,10)]],2)
	g_frameSetMap_rc=randn(frameSize_rc + max(g_frameSetPath,[],2));
case 'imagefile'

	if isempty(imageParameters) || ~ischar(imageParameters)
		error([ imageModel ' model takes a string that is the filename argument.'])
	end
	
	imageFullFilename=imageParameters;
	if ~exist(imageFullFilename,'file')
		error([imageFullFilename ' was not found'])
	else
		data=load('-v6',imageFullFilename,'frame');
		g_frameSetMap_rc=data.frame;
	end
	
	%we need to load the file and then generate the absoulte movement vector	
	g_frameSetPath=cumsum([[0;0] [ones(1,10); zeros(1,10)] [zeros(1,10); ones(1,10)] [-ones(1,10); ones(1,10)]],2)
	g_frameSetPath=g_frameSetPath + repmat(startPosition_rc,1,size(g_frameSetPath,2));	
	
otherwise
	error(['Invalid set name of ' of setName]);
end

%save the state (this is more for debugging info then needed by the other API
obj.startPosition_rc=startPosition_rc; 
obj.translationPerFrame_rc=translationPerFrame_rc;
obj.maxFrames=maxFrames;
obj.maxMovement_rc=maxMovement_rc;
%obj.frameMapCoordinates=frameMapCoordinates;
obj.frameSize_rc=frameSize_rc;



return;