function error=npsr(target,ref)
if (size(target) ~= size(ref))
disp('target and reference must have the same dimensions')
error=[]
return
end
temp1=abs(target)-abs(ref);
temp1=temp1.^2;
temp1=temp1./max(max(max(abs(ref))));
temp2=sum(sum(sum(temp1)));
error=(1/prod(size(ref))) *temp2;
