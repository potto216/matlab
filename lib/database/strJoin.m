%This function will join two cell arrays of strings based on the masks
%given.  Two struct arrays are returned, one of matches and the other of no
%matches.  The function will error on duplications since it assumes the
%strings are unique.
%
%INPUT
%str1List
%str2List
%{'str1Mask',@(x)} - This is a function that returns the mask to use for matching.
%{'str2Mask',@(x)} - This is a function that returns the mask to use for matching.
%
%OUTPUT
%matches - a struct containing the 
%   [original {str1,str2}, masked {str1,str2} index [str1,str2]]
%nomatches
%   [original {str} listNumber(1,2) listIndex ] 

function [matches, nomatches]=strJoin(str1List,str2List,varargin)

p = inputParser;   
p.addRequired('str1List',@(x) iscell(x));
p.addRequired('str2List',@(x) iscell(x));
p.addParamValue('str1Mask',[],@(x) isa( x,'function_handle'));
p.addParamValue('str2Mask',[],@(x) isa( x,'function_handle'));

p.parse(str1List,str2List,varargin{:});
 
str1Mask=p.Results.str1Mask;
str2Mask=p.Results.str2Mask;

str1MaskedList=cellfun(@(x) str1Mask(x), str1List,'UniformOutput',false);
str2MaskedList=cellfun(@(x) str2Mask(x), str2List,'UniformOutput',false);

indexofStr2ListMatchingStr1=cellfun(@(str1) find(strcmp(str1, str2MaskedList)),str1MaskedList,'UniformOutput',false);

matches=struct([]); %'original',[],'masked',[],'index',[]);
nomatches=struct([]); %'original',[],'masked',[],'listNumber',[],'listIndex',[]);
for ii=1:length(indexofStr2ListMatchingStr1)
    %indexofStr2InStr1List{1}
    if length(indexofStr2ListMatchingStr1{ii})==1
        matches(end+1).original={str1List{ii},str2List{indexofStr2ListMatchingStr1{ii}}};
        matches(end).masked={str1MaskedList{ii},str2MaskedList{indexofStr2ListMatchingStr1{ii}}};
        matches(end).index=[ii,indexofStr2ListMatchingStr1{ii}];
    elseif length(indexofStr2ListMatchingStr1{ii})==0
        nomatches(end+1).original=str1List{ii};
        nomatches(end).masked=str1MaskedList{ii};
        nomatches(end).listNumber=1;
        nomatches(end).listIndex=ii;
    else
        error('Invalid number of matches');
    end
    
end

%now pull out list 2 matches
matchedList2Index=arrayfun(@(x) lif(length(x.index)==2, @() x.index(2), @() [], true), matches,'UniformOutput',false);

missingList2Indexes=setdiff(1:length(str2List),cell2mat(matchedList2Index));

for ii=missingList2Indexes    
        nomatches(end+1).original=str2List{ii};
        nomatches(end).masked=str2MaskedList{ii};
        nomatches(end).listNumber=2;
        nomatches(end).listIndex=ii; 
end

end