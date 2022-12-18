%This function finds structs in an array of structs that match the search criteria and will only
%return those structs..  The query is an array of cells that follow the
%mongodb standard
function [validDocuments, validIndexList]=structFind(arrayOfStruct, query)

validIndexList=[];
for ii=1:length(arrayOfStruct)
    addToIndexList=true;
    for qq=1:length(query)
        %Assumed form [{field1,value1},{field2,value2},...,{fieldN,valueN}]
        queryEntry=query{qq};
        if isfield(arrayOfStruct(ii),queryEntry{1})
            switch(class(queryEntry{2}))
                case 'char'
                    if strcmp(arrayOfStruct(ii).(queryEntry{1}),queryEntry{2})
                        %do nothing
                    else
                        addToIndexList=false;
                        break;                        
                    end
                otherwise
                    error(['Value of ' class(queryEntry{2}) ' is not supported.']);
            end
        else
            addToIndexList=false;
            break;
        end
    end
    
    if addToIndexList
        validIndexList(end+1)=ii; %#ok<AGROW>
    else
        %do nothing
    end
    
end

validDocuments=arrayOfStruct(validIndexList);
end