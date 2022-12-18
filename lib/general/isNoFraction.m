%This function says if the number does not have a fraction.  It would have been easier to have the funciton as isInteger
%but this is used to determine if the data type is an integer.
function [returnValue]=isNoFraction(X)
    returnValue = all(X(:)==fix(X(:)));
return
% returnValue=arrayfun(@isNoFractionScalar,X);
% 
% return;
% 
% 
% 
% function [returnValue]=isNoFractionScalar(X)
% 
% if all(X(:)==fix(X(:)))
% 	returnValue=true;
% else
% 	returnValue=false;
% end
% return;