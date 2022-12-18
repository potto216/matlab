%This function loads metadata associated with a data file.  The metadata files right
%now are matlab scripts that setup a data structure metadata.  The file can be
%any valid filename with any extension type.  To be returned from the
%function they need to assign the variables to the metadata structure.
%The only variable that cannot be assigned to metadata is
%sourceMetaFilename which is assigned after the file is successfully loaded.
function [metadata]=loadMetadata(filename)
[filePath,fileBasename,fileExt]=fileparts(filename);

switch(fileExt)
    case {'.m','.M'}
        %use the run command because it is faster
        run(filename);

    otherwise %use eval since run must have a .m file

        %the script file must setup a data structure called metadata.
        fid=fopen(filename,'r');
        scriptText=fread(fid,inf,'char=>char');
        fclose(fid);

        scriptText=reshape(scriptText,1,[]);
        tmp=eval(scriptText);
        %HISTORY NOTES
        %  Tried using run(filename), but if the filename starts with numbers or has '-' or other chars that cannot be
        %used in a valid script name it will not run.  Also the extension must have a .m
end

if isfield(metadata,'sourceMetaFilename')
    error('sourceMetaFilename cannot already exist.');
else
    metadata.sourceMetaFilename=filename;
end

end