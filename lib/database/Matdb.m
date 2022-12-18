classdef Matdb < handle
    %MATDB The purpose of the class is to manage a database as a document oriented
    %database in a mode similar to MongoDB
    %Assumptions
    %1.  The filename field seperator will be the underline and cannot be
    %changed
    
    properties (GetAccess=public, SetAccess=private)
        collectionFilePath=[];
        docFilenamePrefix='doc';
    end
    
    methods (Access=public)
        %This fucntion will except the main path or empty if you will just
        %be loading a set of files
        function this=Matdb(collectionFilePath)
            this.collectionFilePath=collectionFilePath;
            if  ~isempty(this.collectionFilePath) && ~exist(this.collectionFilePath,'dir')
                mkdir(this.collectionFilePath)
            else
                %Assume everything is okay
            end
        end
        
        %When inserting variables just pass the text names and it will
        %insert from the workspace.  This function cannot be nested.
        function writeResult=insertFromWorkspace(this,varargin)
            writeResult=false;
            
            freeFilename=fullfile(this.collectionFilePath, this.getFreeFilename());
            cellArray=[repmat({''''},length(varargin),1) varargin(:) [repmat({''','},length(varargin)-1,1); {''''}]]';
            strOut=cell2str(cellArray(:));                        
            
            try
                evalin('caller',['save(''' freeFilename ''',' strOut ');']);
                writeResult=true;
            catch err
                writeResult=false;
            end
        end
        
        %This function will find all of the documents in the database and
        %load and return them as a structure array.  Since when structs are
        %appended together if they are missing fields from the other
        %structs they will be given empty fields therefore the call for
        %returning as cells should be used.  The default sort order are the
        %indexes asscending.
        function docCollection=find(this)
            idList=sort(this.findAllIds);
            totalDocSize_byte=0;
            docCollection=[]; % We want this a struct not a cell(length(idList),1);
            for ii=1:length(idList)
                [doc,docSize_byte]=this.getDocById(idList(ii));
                totalDocSize_byte=totalDocSize_byte + docSize_byte;

                disp(['Loaded ' num2str(idList(ii)) ' size = ' num2str(docSize_byte) ', total size = ' num2str(totalDocSize_byte)]); 
                %Setup a struct not a celldocCollection{ii}=doc;
                if isempty(docCollection)
                    docCollection=doc;
                else
                    docCollection(end+1)=doc; %#ok<AGROW>
                end
            end
            
        end

        %This will load a file list and return the collection in order
        function docCollection=loadFileList(this,fileList)
            totalDocSize_byte=0;
            docCollection=[]; % We want this a struct not a cell(length(idList),1);
            for ii=1:length(fileList)
                [doc,docSize_byte]=this.getDocByFilename(fileList{ii});
                totalDocSize_byte=totalDocSize_byte + docSize_byte;

                disp(['Loaded ' fileList{ii} ' size = ' num2str(docSize_byte) ', total size = ' num2str(totalDocSize_byte)]); 
                %Setup a struct not a celldocCollection{ii}=doc;
                if isempty(docCollection)
                    docCollection=doc;
                else
                    if length(fieldnames(docCollection(end)))==length(fieldnames(doc)) && all(strcmp(fieldnames(docCollection(end)),fieldnames(doc)))
                    docCollection(end+1)=doc; %#ok<AGROW>
                    else
                        warning(['The fields in file ' fileList{ii} ' do not match docCollection fields']);
                    end
                end
            end
            
        end
        
    end
    
    methods (Access=private)

        %This will load a document by id and if the file does not exist in
        %the collection will return an empty
        function [doc, docSize_byte]=getDocById(this,id)
            docFilename=fullfile(this.collectionFilePath,[this.docFilenamePrefix '_' num2str(id) '.mat']);
            if exist(docFilename,'file')
               doc=load(docFilename);
            else
              doc=[];
            end
            %Filter out field
            doc.dMod=rmfield(doc.dMod,'sourceFrameTrackListBackward');
            
            %
            docInfo=whos('doc');
            docSize_byte=docInfo.bytes;
        end

        %This will load a document by id and if the file does not exist in
        %the collection will return an empty
        function [doc, docSize_byte]=getDocByFilename(this,docFilename)            
            if exist(docFilename,'file')
               doc=load(docFilename);
            else
              doc=[];
            end
            %Filter out field
            if isfield(doc,'dMod')
                doc.dMod=rmfield(doc.dMod,'sourceFrameTrackListBackward');
            end
            
            %
            docInfo=whos('doc');
            docSize_byte=docInfo.bytes;
        end
        
        
        %This function returns all of the id numbers in a collection
        function idList=findAllIds(this)            
            fileList=this.findAllIdFilenames;
            idList=cellfun(@(x) str2double(x((length(this.docFilenamePrefix)+1+1):(end-length('.mat')))),fileList,'UniformOutput',true);

        end
        
        
        %This function returns all of the id files in the collection directory
        function idFilenameList=findAllIdFilenames(this)
            idFilenameList=dirPlus(fullfile(this.collectionFilePath,[this.docFilenamePrefix '_*.mat']),'fileOnly',true,'relativePath',true);            
        end
        
        %This function returns the filename for a free file
        function freeFilenameList=getFreeFilename(this)
            freeFilenameList=[this.docFilenamePrefix '_' num2str(this.getFreeId()) '.mat'];            
        end
        
        %This function returns the next id number available for storage.
        %Id numbers are not reused and always increamented from the max
        function freeid=getFreeId(this)
            %base name and the underline
            idList=this.findAllIds;
            freeid=max(idList)+1;
            
            %If empty it means that the directory is not set
            if isempty(freeid)
                freeid=1;
            else
                %do nothing
            end
        end
    end
    
end

