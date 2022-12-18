%% This function generates a curved M-mode line from an image based on a set of control points
function mmode = computeCurvedMMode(Im, samplePoints)

if isvector(samplePoints)
    mmode=interpVector(Im,samplePoints);
else
    mmode=interpMatrix(Im,samplePoints);
end
    

end


function mmode=interpVector(Im,yy)
% mmode = zeros(size(Im,2),size(Im,3));
for k =1: size(Im,2)
    frac = yy(k) - floor(yy(k));
    mmode(k)= squeeze(Im(floor(yy(k)),k)*(1-frac)+Im(ceil(yy(k)),k)*frac);
end
end

function mmode=interpMatrix(Im,samplePoints_rc)
mmode = interp2(1:size(Im,2),1:size(Im,1),Im,samplePoints_rc(2,:),samplePoints_rc(1,:));
end
