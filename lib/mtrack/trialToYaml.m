%Converts a trial.m file into a YAML file along with converting any images
%into PNGs. This uses the informationin the col_ultrasound_bmode collection
% and will duplicate the regions in there. This can then be used by the 
% Python tracking system.
%
%rootDirectory - This is the part of the directory string that must be
%replaced when creating the new path. Normally it includes the path to the
%study and the study name. An example is:
% rootDirectory=fullfile(getenv('DATA_ULTRASOUND'),'MyStudyUS');
%
%newRootDirectory - This is the new path where the YAML files and PNG
%images will go. It should be at the same level as rootDirectory. Pathes
%under this directory will be automatically created as files are added. An
%example is:
% newRootDirectory=fullfile(getenv('DATA_ULTRASOUND'),'png','MyStudyUS');
%
%imageBlockProcessingFunc - This function inputs a block and outputs a
%processed block. Any arguments should be first wrapped in an anonymous
%function. It is assumed that the number of frames and the frame dimensions
%will not change between input and output. An example would be simple log
%compression (assuming all values are >= 0) by:
% imageBlockProcessingFunc = @(x) x.^5
%
function trialToYaml(trialName,rootDirectory,newRootDirectory, imageBlockProcessingFunc)

switch(nargin)
    case 3
        imageBlockProcessingFunc = [];
    case 4
        %do nothing
    otherwise
        error('Invalid numbe rof input arguments.');
end

if ~exist(rootDirectory,'dir')
    error([rootDirectory ' is not an existing directory.'])
end

if ~exist(newRootDirectory,'dir')
    disp([newRootDirectory ' is not an existing directory, so creating it.'])
    mkdir(newRootDirectory)
end


[trialData]=loadMetadata([trialName '.m']);

if tIsBranch(trialData.subject,'phantom') && tIsBranch(trialData.subject.phantom,'reference.rfFilename')
    dataBlockObj=DataBlockObj(trialData.subject.phantom.reference.rfFilename,@uread,'openArgs',[]);
    dataBlockObj.open('cacheMethod','auto');
    dataBlockObj.newProcessStream('agentLab',trialData.subject.phantom.reference.processFunction, true);
    
    matFullFilepath=fullfile(trialData.subject.phantom.filepath.pathToRoot, ...
        trialData.subject.phantom.filepath.root, ...
        trialData.subject.phantom.filepath.relative);
    
    imOutputFormatList=trialData.collection.projection.bmode.imOutputFormat;
    imRowColumnUnits_m=[(im(ii).zAxis_m(2)-im(ii).zAxis_m(1)) (im(ii).xAxis_m(2)-im(ii).xAxis_m(1))];
    trialName=imOutputFormatList.type;
    
elseif tIsBranch(trialData.collection.ultrasound.bmode,'fullfilename')
    dataBlockObj=getCollection(trialData,'col_ultrasound_bmode');
    %     dataBlockObj=DataBlockObj(trialData.collection.ultrasound.bmode,@uread,'openArgs',[]);
    %     dataBlockObj.open('cacheMethod','auto');
    %     dataBlockObj.newProcessStream('agentLab',@(x) x, true);
    
    [oldMatFullFilepath, trialName]=fileparts(dataBlockObj.metadata.sourceFilename);
    
    %matFullFilepath = fullfile(replace(oldMatFullFilepath,rootDirectory,newRootDirectory));
    matFullFilepath = fullfile(strrep(oldMatFullFilepath,rootDirectory,newRootDirectory));
 
    imRowColumnUnits_m = [dataBlockObj.getUnitsValue('axial','mm')/1000, dataBlockObj.getUnitsValue('lateral','mm')/1000];
    
    if dataBlockObj.metadata.ultrasound.rf.header.ul(1) ~= dataBlockObj.metadata.ultrasound.rf.header.bl(1)
        error('Upper left and lower left are not equal')
    else
        splineStartLeft=dataBlockObj.metadata.ultrasound.rf.header.ul(1);
    end

    if dataBlockObj.metadata.ultrasound.rf.header.ur(1) ~= dataBlockObj.metadata.ultrasound.rf.header.br(1)
        error('Upper left and lower left are not equal')
    else
        splineStopRight=dataBlockObj.metadata.ultrasound.rf.header.ur(1);
    end

    trialData.collection.ultrasound.rf.header=dataBlockObj.metadata.ultrasound.rf.header;
    
    regions=[];
    for ii=1:length(trialData.collection.ultrasound.bmode.region)
        if isempty(regions)
            regions.name=trialData.collection.ultrasound.bmode.region(ii).name;
        else
            regions(end+1).name=trialData.collection.ultrasound.bmode.region(ii).name;
        end
        regions(end).polygon_xy=createPolygon(trialData.collection.ultrasound.bmode.region(ii),splineStartLeft,splineStopRight);
    end
else
    error(['Unable to load data file in trial ' trialName]);
end

image.axis.column.ultrasound = 'lateral';
image.axis.column.phantom = 'x';

image.axis.row.ultrasound = 'axial';
image.axis.row.phantom = 'z';

if ~exist(matFullFilepath,'dir')
    mkdir(matFullFilepath);
    disp(['Created directory ' matFullFilepath]);
else
    %do nothing
end

if ~isempty(imageBlockProcessingFunc)
    imBlockProcessed=dataBlockObj.blockData;
%     imPngBlock=imPngBlock(:,:,1:50);
%     warning('*********TRUNCATING BLOCK FOR TEST');
    imBlockProcessed=imageBlockProcessingFunc(imBlockProcessed);
    sortedProcessedBlk=sort(imBlockProcessed(:));
    accetableCutoffPercentage=0.0005;
    minValue=sortedProcessedBlk(min(ceil(accetableCutoffPercentage*numel(imBlockProcessed)),numel(imBlockProcessed)));
    disp(['The min value for a cutoff percentage of ' num2str(accetableCutoffPercentage*100) '% is ' num2str(minValue) '.']);   
    if minValue > 0
        %don't adjust min if positive
        disp('Because the min is positive the adjustment step is skipped.');
        imPngBlock=imBlockProcessed;
    else
        imPngBlock = imBlockProcessed - minValue;
    end
    
    imPngBlock(imPngBlock<0)=0;
    
    if any(imPngBlock(:)<0)
        error('imPngBlock has negative values');
    end
    %
    if false
        sum((imPngBlock(:) < 0))/numel(imPngBlock(:,:,117))*100
        [rr,cc,ff]=ind2sub(size(imPngBlock),find(imPngBlock < 0));
        figure;
        imagesc(imPngBlock(:,:,117)); colormap(gray(256)); colorbar;
        hold on
        plot(cc,rr,'r.')
        
        figure; hist(reshape(imPngBlock(:,:,117),[],1),1111)
        figure; hist(reshape(dataBlockObj.blockData(:,:,117),[],1),1111)
    end
else
    imPngBlock=dataBlockObj.blockData;
    imBlockProcessed=[];
    minValue=[];
    accetableCutoffPercentage=[];
end

filenameMask='%04d';
fmt='png';
filenameMaskPython='{:04d}.png';

writeImageSequenceYaml(trialData, image, imPngBlock, imRowColumnUnits_m, matFullFilepath, trialName, filenameMask, fmt, filenameMaskPython);
%save(fullfile(matFullFilepath, trialName,[trialName '_debug.mat']),'imPngBlock','imBlockProcessed','dataBlockObj','minValue','accetableCutoffPercentage');

writeRegionInformationYaml(imPngBlock, matFullFilepath,trialName,regions)

end

function polygon_xy=createPolygon(region,splineStartLeft,splineStopRight)

    if ~strcmp(region.agent(1).name,'topSpline')       
        error('Expected top spline');
    else
        topSpline=region.agent(1).vpt;
    end
    
    if ~strcmp(region.agent(2).name,'bottomSpline')       
        error('Expected bottom spline');
    else
        bottomSpline=region.agent(2).vpt;
    end    
        
    regionX=linspace(splineStartLeft,splineStopRight,10);
    regionTopY = reshape(spline(topSpline(2,:),topSpline(1,:),regionX),1,[]);
    regionBottomY = reshape(spline(bottomSpline(2,:),bottomSpline(1,:),regionX),1,[]);
    
    polygon_xy = [regionX fliplr(regionX) regionX(1); regionTopY fliplr(regionBottomY) regionTopY(1)];
    
    if false
        figure; plot(polygon_xy(1,:), polygon_xy(2, :))
    end
end
