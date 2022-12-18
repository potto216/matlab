function tableIndexes=findInTable(entriesToFind,tableToSearch,indexAsIntegerVector)
%FINDINTABLE Finds the indexes of the table that matches the entries.  If
%empties or multiple table indexes for an entry are a possiblity then
%indexAsCell should be 

switch(nargin)
    case 2
        indexAsIntegerVector=true;
    case 3
        %do nothing
    otherwise 
        error('Invalid number of arguments.');
end

tableIndexes=arrayfun(@(entry) strmatch(entry,tableToSearch),entriesToFind,'UniformOutput',false);

if indexAsIntegerVector
    tableIndexes=cell2mat(tableIndexes);
else
    %do nothing
end


end

