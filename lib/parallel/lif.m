%Lisp like if statement [retVal]=lif(condition, ifVal, elseVal,executeFunction)
%The executeFunction assumes the values are functions which will be
%executed depending on the if condition.  This is useful when the condition
%statement may not be valid.
function [retVal]=lif(condition, ifVal, elseVal,executeFunction)
if condition
    retVal=ifVal;
else
    retVal=elseVal;
end

if nargin==4 && executeFunction
    retVal = retVal();
end
end