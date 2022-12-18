%This function will assume the data is in column vectors and in a series
%that can be inerpolated.
%INPUT
%vec - the data as a set of column vectors
function vec=vecInterpNan(vec)

for ii=1:size(vec,2)
    
    indexList=find(isnan(vec(:,ii)));
    if ~isempty(indexList)
        [ vec(:,ii) ] = idxReplaceValues( vec(:,ii),indexList );
    else
        %do nothing
    end
    
    
end

end