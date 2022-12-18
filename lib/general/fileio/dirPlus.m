function [ outputList ] = dirPlus( name,varargin  )
%DIRPLUS This function performs the directory search with more options
%than dir.  The function automatically strips out the parent and current
%directory ".." and ".".  By default relative paths are returned.
%
%Some of the keyvalue pairs of use.  
%
%INPUT
% name - must be a character sting, or if empty the current directory will be
% used.
%
% Key Value Pairs
%'dirOnly' {[false], true} - only directory paths should be returned.  Default
%is false.
%
%'fileOnly' {[false], true} - only file names should be returned.  Default
%is false.
%
%'recursive' {[false],true} - recursively search subdirectories
%
%'relativePath' {[false],true} - returns only the relative path
%OUTPUT
%outputList - the output is always a cell array or strings, even if it is only 1
%element, unless overriden to be a character array.
%My need to call C = flattenCell(A) if you don't want nesting in your list


p = inputParser;   % Create an instance of the class.
p.addRequired('name',@(x) ischar(x) || isempty(x));
p.addParamValue('dirOnly',false,@(x) islogical(x) && isscalar(x));
p.addParamValue('fileOnly',false,@(x) islogical(x) && isscalar(x));
p.addParamValue('recursive',false,@(x) islogical(x) && isscalar(x));
p.addParamValue('relativePath',false,@(x) islogical(x) && isscalar(x));

p.parse(name,varargin{:});

dirOnly=p.Results.dirOnly;
fileOnly=p.Results.fileOnly;
recursive=p.Results.recursive;
relativePath=p.Results.relativePath;

if exist(name,'dir')
    basePath=name;
    searchString='*';
else
    [basePath,searchBaseString, searchExt]=fileparts(name);
    searchString=[searchBaseString searchExt];
end
itemList=dir(name);

%remove the .. and .
itemList(arrayfun(@(item) any(strcmp(item.name,{'..','.'})),itemList,'UniformOutput',true))=[];
if recursive
    dirList=dir(basePath);
    dirList(arrayfun(@(item) any(strcmp(item.name,{'..','.'})) || ~item.isdir,dirList,'UniformOutput',true))=[];
    outputList=arrayfun(@(subdir) dirPlus( fullfile(basePath,subdir.name,searchString) ,varargin{:}),dirList,'UniformOutput',false);
else
    outputList={};
end

if dirOnly
    itemList(~[itemList.isdir])=[];
end

if fileOnly
    itemList([itemList.isdir])=[];
end

if ~relativePath
    outputList=[outputList; arrayfun(@(item) fullfile(basePath,item.name),itemList,'UniformOutput',false)];
else
    if recursive
        error('relativePath does not work with recursive');
    else
        outputList=[outputList; arrayfun(@(item) fullfile(item.name),itemList,'UniformOutput',false)];    
    end
end
    outputList(cellfun(@isempty,outputList))=[];
end

