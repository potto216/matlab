%This will clip a column vector against a min max vector
%V must be V> vMin and V<vMAx to avoid being clipped to vMin and vMax
function V=clipVector(V,vMin,vMax)

for ii=1:size(V,1)
    V(ii,V(ii,:)<vMin(ii))=vMin(ii);
    V(ii,V(ii,:)>vMax(ii))=vMax(ii);
end

end