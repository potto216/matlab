function Pressure2d=get_pressure(Pressure3d,plane,index);
% function to extract a plottable pressure field from fnm_cw results
% Usage: Pressure2d=get_fnm_pressure(fnm_result,plane,depth)
% plane must be 'xy',  ' xz', or 'yz'
% index is equal to how far into the array you are going
% for example if we want an xy plane @ z=7 in a 3d pressure grid with z from 5 to 10, 
% and a delta of .1. The index would be (7-5)/delta +1
if nargin()==0
	disp('The propper use of this function is:')
	disp('Pressure2d=get_pressure(Pressure3d,plane,index)')
	error('plane is xy, xz, or yz')
end
if plane=='xy'
	Pressure2d(:,:)=Pressure3d(:,:,index);
	return
elseif plane=='xz'
	Pressure2d(:,:)=Pressure3d(:,index,:);
	return
elseif plane=='yz'
	Pressure2d(:,:)=Pressure3d(index,:,:);
	return
else
    Pressure2d=[];
	disp('plane needs to be xy, xz or yz\n')
	disp('The Pressure3d matrix is in the order X,Y,Z')
	disp('X Y and Z are NOT cordinates, they are indexes')
	error('The cordinate of X Y Z = var_start+delta*var')
end