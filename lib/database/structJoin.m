function [ joinedStruct ] = structJoin( joinOnFieldList,primaryStruct, varargin )
%STRUCTJOIN This function will join multiple structs based on the field
%list.  Currently this is an equijoin.  This function assumes that the
%joinOnField list is a primary key in each structure.
%TODO If the field list has multiple columns then those will be used to
%identify the secondary structs to join.
structsToJoin=varargin;

overwriteExistingField=false;
if isvector(joinOnFieldList)
    joinOnFieldList=joinOnFieldList(:);
else
    error('please fix code');
    joinOnFieldList=repmat(joinOnFieldList,1,1+length(structsToJoin));
end


joinFieldIsEqual = @(pStruct,sStruct) all(cellfun(@(f) f(pStruct)==f(sStruct),joinOnFieldList,'UniformOutput',true));

%grab
for ii=1:length(primaryStruct)
    %joinOnFieldListPrimary{};
    
    joinFieldIsEqual(primaryStruct(1),primaryStruct(1))
    
    if ii==1
        joinedStruct=primaryStruct(ii);
    else
        joinedStruct(ii)=primaryStruct(ii);
    end
    warning('Primary keys need to be removed from lists of secondaries')
    %assume the join on field list is a primary key and we can find
    %them in each of the other structs then join those fields
    for ss=1:length(structsToJoin)
        
        secondaryMatchToCurrentPrimary = find(arrayfun(@(sStruct) joinFieldIsEqual(primaryStruct(ii),sStruct),structsToJoin{ss}));
        if ~isempty(secondaryMatchToCurrentPrimary )
            if length(secondaryMatchToCurrentPrimary )~=1
                error('There should be only one match.  The unique assumption was violated.');
            else
    
                secondaryMatchEntry=structsToJoin{ss}(secondaryMatchToCurrentPrimary);
                %joinedFieldnameList=fieldnames(joinedStruct(ii));
                secondaryFieldnameList=fieldnames(secondaryMatchEntry);          
                for ff=1:length(secondaryFieldnameList)
                    if ~isfield(joinedStruct(ii),secondaryFieldnameList{ff}) ...
                            || isempty(joinedStruct(ii).(secondaryFieldnameList{ff})) ...
                         || overwriteExistingField                        
                    joinedStruct(ii).(secondaryFieldnameList{ff})=matchEntry.(secondaryFieldnameList{ff});
                    end
                end
                
            end
        else
            %skip
        end
        
    end
    
    
    
    for ss=1:length(structsToJoin)
        
        
        
    end
    
end
end