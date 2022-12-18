%pcellfun acts like cellfun, but runs each value using a parallel for loop
%[A, B, ...] = pcellfun(FUN, C, ...), where FUN is a function handle to a
%    function that returns multiple outputs, returns arrays A, B, ...,
%    each corresponding to one of the output arguments of FUN. 
%for pcellfun to work it must have access to the function
%loadComputerSpecificData which defines the capabilities of the machine.
%
function [ varargout ] = pcellfun( fun, varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('verbose',false,  @(x) (isscalar(x) && islogical(x)));
p.addParamValue('useParallelProcessing',true,  @(x) (isscalar(x) && islogical(x)));
p.addParamValue('UniformOutput',false,  @(x) (isscalar(x) && islogical(x)));


%We need to find when the arguments change in size because that signals the
%end of the data input list
checkSize = @(blockReference,blockCheck) all(arrayfun(@(xdim) size(blockReference,xdim)==size(blockCheck,xdim),(1:max(ndims(blockReference),ndims(blockCheck)))));
%if nothing is found that means all the arguments are parameters without any aconfig parms
indexOfFirstConfigParm=find(~cellfun(@(x) checkSize(varargin{1},x),varargin(2:end)),1,'first')+1;  %the +1 is because we don't look at the first value.

if isempty(indexOfFirstConfigParm)
    %if empty then everything is data so point to the last value
    indexOfLastDataValue=length(varargin);
else
    indexOfLastDataValue=indexOfFirstConfigParm-1;
end

p.parse(varargin{(indexOfLastDataValue+1):end});

UniformOutput = p.Results.UniformOutput;
useParallelProcessing = p.Results.useParallelProcessing;
verbose = p.Results.verbose;


if useParallelProcessing
    computerInformation=loadComputerSpecificData();
    localCoresToUse=min(computerInformation.numCores,8); %#ok<UNRCH>    
    disp(['Opening ' num2str(localCoresToUse) ' cores.'])
    matlabpool('open','local',localCoresToUse);
end

varargout=cell(1,nargout);
if ~useParallelProcessing
    [varargout{:}]=cellfun(fun,varargin{1:indexOfLastDataValue},'UniformOutput',UniformOutput);
end

%%ff = the frame slice index
cellOutput=cell(size(imBlock,3),1);
parfor ff=1:size(cellOutput,1)
    tic
    disp(['PARFOR: START loop ' num2str(ff)])
    
    im=uint8(imBlock(:,:,ff));  %for bmode no transform needed
    
    [muscleMask,resultsList,maxIndex]=muscleFasciaSegmentationOptimize(im,thresholdList);
    
    cellOutput{ff}={muscleMask,resultsList,maxIndex};
    disp(['PARFOR: END loop ' num2str(ff) ', time = ' num2str(toc) 'sec'])
end


if useParallelProcessing
    matlabpool('close') %#ok<UNRCH>
end

%COLVECFUN PAsses the column vectors to fun and gets a column vector out
switch(nargin)
    case 2
        A=cell2mat(cellfun(fun,mat2cell(B,size(B,1),ones(1,size(B,2))),'UniformOutput',false));
    case 3
        A=cell2mat(cellfun(fun,mat2cell(B,size(B,1),ones(1,size(B,2))),mat2cell(C,size(C,1),ones(1,size(C,2))),'UniformOutput',false));
    otherwise
        error('Invalid number of arguments');
end

end

