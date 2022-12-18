%This function will load case data and return a data structure that is the
%caseData.  If caseData is a string then it will load the metadata file and
%return the data structure.  This will also work for an rf file.
%If the argument is not given it will default
%to asking the user to open a file.  In this case it will try to open the
%case files under the
%"%ULTRASPECK_ROOT%\workingFolders\potto\data\caseFiles" directory.  If the
%enviromental variable is not defined or the directory does not exist it
%will just open a file dialog in the current directory.
%
%INPUT
%caseData - Can be a string or a data structure.  If it is a string then it
%is assumed to be the full path and filename of the data structure.  
%
%OUTPUT
%caseData - A data structure of the case data.
%
function caseData=loadCaseData(caseData)

switch nargin
    case 0                
        caseData=askUserFilename;
                
    case 1
        if isempty(caseData)
            caseData=askUserFilename;
        end
        %do nothing
    otherwise
        error('Invalid number of input arguments.')
end

if ischar(caseData)
    [d1,d2,caseFilenameExt]=fileparts(caseData); %#ok<ASGLU>
    switch(caseFilenameExt)
        case '.m'
            [caseData]=loadMetadata(caseData);
        case '.rf'
            caseData=loadRFData(caseData);
        case '.b8'
            caseData=loadRFData(caseData);            
        otherwise
            error(['Unknown way to read ' caseData]);
    end
    
elseif isstruct(caseData)
    %do nothing
elseif isempty(caseData)
    return;
else
    error('caseData is an unsupported data type');    
end

end

function caseData=askUserFilename()
        ultraspeckRoot=getenv('ULTRASPECK_ROOT');
        casefolderPath=fullfile(ultraspeckRoot,'workingFolders\potto\data\caseFiles');
        if exist(casefolderPath,'dir')
            [filename pathname] = uigetfile({'*.m','Case Files (*.m)';'*.rf','RF Files (*.rf)';...
          '*.b8','Bmode Files (*.b8)'; '*.*','All Files (*.*)' },'Pick a case file',casefolderPath);
        else            
            [filename pathname] = uigetfile({'*.m','Case Files (*.m)';'*.rf','RF Files (*.rf)';...
          '*.b8','Bmode Files (*.b8)'; '*.*','All Files (*.*)' },'Pick a case file');
        end
        
        if ~ischar(filename) || ~ischar(pathname)
            disp('Canceling file selection.')
            caseData=[];
            return;
        else
            caseData = fullfile(pathname, filename);    
        end
end