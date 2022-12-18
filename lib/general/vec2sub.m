%returns the row number of a nonzero value in a column and also returns one
%nonzero value per column.  Each column must only have one nonzero value.
function [varargout]=vec2sub(x)
rowNumber=colvecfun(@(rowFind) find(rowFind~=0),x);
columnValue=x(x~=0);  %This relies on only one nonzero value per row otherwise the col will not correspond to the correct column

rowNumber=rowNumber(:);
columnValue=columnValue(:);

switch(nargout)
    case 1
      varargout{1}={[rowNumber columnValue]};
    case 2
      varargout{1}=rowNumber;
      varargout{2}=columnValue;
    otherwise
        error('Invalid number of output arguments');
end

        
        