%isValidIndex tests to make sure index is a valid integer that is in the
%range of the array index
function isValid=isValidIndex(testArray,testIndex)

if ~isNoFraction(testIndex)
    %error(['Index ' num2str(testIndex) ' is not an integer.'])
    isValid=false;
else
    if (testIndex<1) || (testIndex>length(testArray))
        %error(['Index is not in the range of [1,' num2str(length(testArray)) ']'])
        isValid=false;
    else
        isValid=true;
    end
end