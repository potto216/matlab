%Lisp like.Extracts one output parameter from a function.  This is useful when you
%want to chain functions together and the output of interest is not the
%first arguement.  The first argument must be the output parameter to
%extract.
%
%EXAMPLE
%>>[retVal]=lout(2,@() fileparts('C:\test\name.txt'))
%gets the name
function [retVal]=lout(outputIndexOfInterest,fun)
varargout=cell(outputIndexOfInterest,1);
[varargout{:}]=fun();
retVal=varargout{end};
end