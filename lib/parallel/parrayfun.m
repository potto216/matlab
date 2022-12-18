%parrayfun acts like cellfun, but runs each value using a parallel for loop
%[A, B, ...] = pcellfun(FUN, C, ...), where FUN is a function handle to a
%    function that returns multiple outputs, returns arrays A, B, ...,
%    each corresponding to one of the output arguments of FUN.
%for pcellfun to work it must have access to the function
%loadComputerSpecificData which defines the capabilities of the machine.
%
function [ varargout ] = parrayfun( fun, varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('verbose',false,  @(x) (isscalar(x) && islogical(x)));
p.addParamValue('useParallelProcessing',true,  @(x) (isscalar(x) && islogical(x)));
p.addParamValue('UniformOutput',false,  @(x) (isscalar(x) && islogical(x)));

%We need to find when the arguments change in size because that signals the
%end of the data input list
checkSize = @(blockReference,blockCheck) all(arrayfun(@(xdim) size(blockReference,xdim)==size(blockCheck,xdim),(1:max(ndims(blockReference),ndims(blockCheck)))));
indexOfFirstConfigParm=find(~cellfun(@(x) checkSize(varargin{1},x),varargin(2:end)),1,'first')+1;  %the +1 is because we don't look at the first value.

if isempty(indexOfFirstConfigParm)
    indexOfLastDataValue=1;
    p.parse();
else
    indexOfLastDataValue=indexOfFirstConfigParm-1;
    p.parse(varargin{indexOfFirstConfigParm:end});
end

UniformOutput = p.Results.UniformOutput;
useParallelProcessing = p.Results.useParallelProcessing;
verbose = p.Results.verbose;

if ~useParallelProcessing
    varargout=cell(1,nargout);
    [varargout{:}]=arrayfun(fun,varargin{1:indexOfLastDataValue},'UniformOutput',UniformOutput);
else
    %The output is all cell arrays The design assumption is that each function call takes a long time to run
    %therefore the
    varargout=cell(1,nargout);
    rowOut=cell(1,nargout);
    rowIn=cell(1,indexOfLastDataValue);
    
    %vv is the variable index
    for vv=1:length(varargout)
        varargout{vv}=cell(size(varargin{1}));
    end
    
    runLength=cumprod(size(varargin{1}));
    runLength=runLength(end);
    
    for ii=1:runLength
        %load the input
        %vv is the variable index
        %the rowIn should surround the actual data with a cell
        for vv=1:indexOfLastDataValue
            rowIn{vv}=varargin{vv}(ii);
        end
        
        [rowOut{:}]=fun(rowIn{:});
        
        for vv=1:nargout
            varargout{vv}(ii)=rowOut(vv);
        end
        
    end
    
    
    if UniformOutput
        for vv=1:nargout
            varargout{vv}=cell2mat(varargout{vv});
        end
    end
    computerInformation=loadComputerSpecificData();
    localCoresToUse=min(computerInformation.numCores,8); %#ok<UNRCH>
    disp(['Opening ' num2str(localCoresToUse) ' cores.'])
    matlabpool('open','local',localCoresToUse);
    
    parfor ff=1:size(cellOutput,1)
        if verbose
            tic
            disp(['PARFOR: START loop ' num2str(ff)])
        end
        
        
        
        if verbose
            disp(['PARFOR: END loop ' num2str(ff) ', time = ' num2str(toc) 'sec'])
        end
    end
    
    
    matlabpool('close') %#ok<UNRCH>
    
end




end

