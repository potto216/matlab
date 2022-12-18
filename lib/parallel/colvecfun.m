function [ A ] = colvecfun( fun,varargin)
%COLVECFUN PAsses the column vectors to fun and gets a column vector out.
%The column vectors can be of different lengths, but the total number of
%column vectors must match
%WARNING:  The column variables cannot be of type characters because this will cause the function
%to not be able to determine the start of the key value pairs.

p = inputParser;   % Create an instance of the class.
p.addParamValue('UniformOutput',true,  @(x) (isscalar(x) && islogical(x)));


%We need to find when the arguments change in size because that signals the
%We do NOT check the row size since that can vary
%end of the data input list
checkSize = @(blockReference,blockCheck) all(arrayfun(@(xdim) size(blockReference,xdim)==size(blockCheck,xdim),(2:max(ndims(blockReference),ndims(blockCheck)))));
%if nothing is found that means all the arguments are parameters without any aconfig parms
indexOfFirstConfigParm=find(~cellfun(@(x) checkSize(varargin{1},x) && ~ischar(x),varargin(2:end)),1,'first')+1;  %the +1 is because we don't look at the first value.

if isempty(indexOfFirstConfigParm)
    %if empty then everything is data so point to the last value
    indexOfLastDataValue=length(varargin);
else
    indexOfLastDataValue=indexOfFirstConfigParm-1;
end
totalDataValues=indexOfLastDataValue;

p.parse(varargin{(indexOfLastDataValue+1):end});

UniformOutputOnReturn = p.Results.UniformOutput;
if UniformOutputOnReturn
    cellTransFormOutput=@(x) cell2mat(x);
else
    cellTransFormOutput=@(x) x;
end

switch(totalDataValues)
    case 1
        B=varargin{1};
        switch(nargout)
            case 0
                cellfun(fun,mat2cell(B,size(B,1),ones(1,size(B,2))),'UniformOutput',false);
            case 1
                A=cellTransFormOutput(cellfun(fun,mat2cell(B,size(B,1),ones(1,size(B,2))),'UniformOutput',false));
            otherwise
                error('Unsupported output arguments.');
        end
                
    case 2
        B=varargin{1};
        C=varargin{2};
        A=cellTransFormOutput(cellfun(fun,mat2cell(B,size(B,1),ones(1,size(B,2))),mat2cell(C,size(C,1),ones(1,size(C,2))),'UniformOutput',false));

    case 4
        B=varargin{1};
        C=varargin{2};
        D=varargin{3};
        E=varargin{4};
        A=cellTransFormOutput(cellfun(fun,mat2cell(B,size(B,1),ones(1,size(B,2))),mat2cell(C,size(C,1),ones(1,size(C,2))),mat2cell(D,size(D,1),ones(1,size(D,2))),mat2cell(E,size(E,1),ones(1,size(E,2))),'UniformOutput',false));
    otherwise
        error('Invalid number of arguments');
end

end

