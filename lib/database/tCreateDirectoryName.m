function [directoryName]=tCreateDirectoryName(filepath,varargin)
%tCreateDirectoryName function creates a directory name based on input
%data.
%
%INPUT
%filepath - the input structure which provides the data to build the
%directory name.
%
%'createDirectory' [true,{false}] - will create the directory if it does
%not exist.
%'ifEmpty_filepath_relativeBranch' - provides a default value for the
%relativeBranch if it is empty.  Often this is a collection name, such as
%when used in tracking.
%
p = inputParser;   % Create an instance of the class.
p.addRequired('filepath', @(x) isstruct(x));
p.addParamValue('createDirectory',false,  @(x) islogical(x));
p.addParamValue('ifEmpty_filepath_relativeBranch',[], @(x) isempty(x) || ischar(x));
p.parse(filepath,varargin{:});

createDirectory=p.Results.createDirectory;
ifEmpty_filepath_relativeBranch=p.Results.ifEmpty_filepath_relativeBranch;

if isfield(filepath,'relativeBranch')
    if isempty(filepath.relativeBranch)  && ~isempty(ifEmpty_filepath_relativeBranch)
        filepath.relativeBranch=ifEmpty_filepath_relativeBranch;
    else
        %do nothing
    end
    directoryName=fullfile(filepath.pathToRoot,filepath.root,filepath.relative,filepath.relativeBranch);
else
    directoryName=fullfile(filepath.pathToRoot,filepath.root,filepath.relative);
end

if createDirectory && ~exist(directoryName,'dir')
    mkdir(directoryName)
end
end