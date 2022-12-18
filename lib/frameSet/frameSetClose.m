%This function closes a set of test frames.
%
%maxMovement_rc is the total +- movement in the x/y direction.  It is how far the total set will move.
%
%The units rc means it is in the form of row,column 
function [obj]=frameSetClose(obj)
global g_frameSetMap_rc

if isempty(g_frameSetMap_rc)
	error('The frameSet was not open.');
end

g_frameSetMap_rc=[]; 