%This function normalizes a set of column vectors
function xNorm=colvecNorm(x)

xNorm=x./repmat(sqrt(sum(x.^2,1)),size(x,1),1);

end