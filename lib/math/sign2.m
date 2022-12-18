%This function will return a sign of 1 if x>=0 and a sign of -1 otherwise.
%No 0 is returned unlike MAtlab's sign function
function x=sign2(x)
lookupTable=[-1 1];
x=lookupTable((x>=0)+1);
end