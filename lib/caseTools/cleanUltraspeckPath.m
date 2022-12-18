%This function checks to see if this is a valid file path.  If so it
%returns the file.  If not it tries to map the file to the correct computer
%and mapping.  So if files were generated on the server, but the code is
%running local then the base name needs to be changed to the local system
%duplicateOption={'useLocal','useRemote','error'}
function [ outputFilename ] = cleanUltraspeckPath( inputFilename,duplicateOption )

switch(nargin)
    case 1
        duplicateOption='error';
    case 2
        %do nothing
    otherwise
        error('Invalid number of input arguments');
end
        

if exist(inputFilename,'file')
    outputFilename=inputFilename;
    return;
else
    %keep processing
end

inputFilePath=fileparts(inputFilename);

windowsServerLocal='E:\Users\potto\ultraspeck';
windowsServerRemote='R:\potto\ultraspeck';

%at this point the file has to be on the server because otherwise it would
%have shown up local

if strncmp(inputFilePath, windowsServerLocal,length(windowsServerLocal))
    inputFileLocation='windowsServer';
else
    error('Unsupported file location');
end

if ~strcmp(getenv('COMPUTERNAME'),'POTTODESK')
    error('only my local machine is supported.')
else
    %my machine so do nothing
end

if strcmp(inputFileLocation,'windowsServer') && strcmp(getenv('COMPUTERNAME'),'POTTODESK')
    
    inputFileRelativeName=inputFilename((length(windowsServerLocal)+1):end);
    if exist(fullfile(windowsServerRemote,inputFileRelativeName),'file')
        if exist(fullfile(getenv('ULTRASPECK_ROOT'),inputFileRelativeName),'file')
            switch(duplicateOption)
                case 'useLocal'
                    outputFilename=fullfile(getenv('ULTRASPECK_ROOT'),inputFileRelativeName);
                case 'useRemote'
                    outputFilename=fullfile(windowsServerRemote,inputFileRelativeName);
                case 'error'
                    error('duplicate file exists on local machine')
                otherwise
                    error(['Unsupported duplicateOption of ' duplicateOption]);
            end
        else
            outputFilename=fullfile(windowsServerRemote,inputFileRelativeName);
        end
    else
        error('Mapping is bad')
    end
else
    error('unsupported configuration');
end



end

