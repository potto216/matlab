%This function will return the vector measures for a set of column vectors.
%Here the measure method is taken and the returned value is a matrix which
%compares the vectors to each other.
%
%INPUT
%vec - a set of column vectors which are being compared.
%measureMethod - {'mse','vote'};
%OUPUT
%measureMatrix - This is the output that results from applying the
%measureMethod to the vec.  Each (row,column) is the result of applying the
%method
function measureMatrix=vecMeasure(vec,measureMethod)

measureMatrix=zeros(size(vec,2),size(vec,2));

switch(measureMethod)
    case 'mse'        
        vecCompare=vec;
        indexCompareBaseLine=1:size(vec,2);
        indexCompare=indexCompareBaseLine;
       
        for ii=1:size(measureMatrix,2)
            measureVector=sqrt(sum((vecCompare-vec).^2,1));
            
            measureMatrix(sub2ind(size(measureMatrix),indexCompareBaseLine,indexCompare))=measureVector;
           % measureMatrix(sub2ind(size(measureMatrix),indexCompare,indexCompareBaseLine))=measureVector;            
                      
            vecCompare=circshift(vecCompare,[0 1]);
            indexCompare=circshift(indexCompare,[0 1]);
        end
        
       
        
    case 'vote'
    otherwise
        error(['Invalid measure method of ' measureMethod]);
end
        


end