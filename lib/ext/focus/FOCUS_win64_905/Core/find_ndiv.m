function ndiv=find_ndiv(xdcr,ps,medium,f0,tol)
% Function to caculate ndiv based on tolerance
% x,y,z should be the point with the greatest angle from the norm.
% function call:
% ndiv=find_ndiv(xdcr,x,y,z,param,{tol})
% tol is optional, and will be set to 1e-10 if omitted.
if nargin()==0
	disp('The propper usage of this function is:')
	disp('ndiv=find_ndiv(xdcr,x,y,z,param,{tol}')
	error('tol is options, param is created by set_parameters')
end
if nargin()==5
	tol=1e-10;
end
if tol<0
	error('tol cannot be negative');
end
nps=set_coordinate_grid(1,max([ps.xmin ps.xmax]),max([ps.xmin ps.xmax]),max([ps.ymin ps.ymax]),max([ps.ymin ps.ymax]),ps.zmax,ps.zmax);
ndiv=2;
old_value=inf;
new_value=0;
while ndiv <100
	new_value=fnm_cw(xdcr,nps,medium,ndiv,f0,0);
	if isempty(new_value)
		warning('Something went wrong, cannot continue')
		warning('assuming ndiv=20')
		ndiv=20;
	end
	if abs(abs(new_value)-abs(old_value)) < tol
		return
	end
	ndiv=ndiv+1;
	old_value=new_value;
end
warning('Unable to reach tol value, ndiv is set to 20');
ndiv=20;
