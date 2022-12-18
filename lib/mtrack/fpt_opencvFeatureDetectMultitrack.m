%fpt_opencvFeatureDetectMultitrack will perform multiple coorespondence
%tracks for a given set of features.  This allows for the feature track
%goodness to be evaluated.  Because of rounding the pixel positions will
%sometimes not be exact between corresponce methods, but the column
%alignment will be correct.
%This fucntion will temporally add pathes then remove them
%
%INPUT
%correspondenceAnalysisName - if string it will only track a feature once.
%If a cell array of strings of length N it will track a single feature N
%times.
%skipImageCreate = [forward backward]
%OUTPUT
%multitrack is an array of structures which contain the result of feature
%detections.  The indexing structure is that the tracks are in
%multitrack(k).trackList and multitrack(k).trackListBackward
%These are cell arrays of structures that contain multiple tracks
%for a given multitrack(k).featureDetectName and a set of 
%multitrack(k).correspondenceNameList.  The decision to keep this kind of
%document structure instead of creating a 3D array for .trackList was that
%meta data could be easily encoded and the structure is similar to the
%nonmultidetect feature trackers.
%If a feature cannot be tracked with one correspondence detector, but can
%with another then for the index entry of where it cannot be tracked it
%should use a NaN value.
function [multitrack]=fpt_opencvFeatureDetectMultitrack(trialData,dataBlockObj, ...
    trackForward,trackBackward,trackPackage,activeTrackPackageNameList, varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('trialData',struct([]), @(x) (isempty(x) || isstruct(x)));
p.addParamValue('resultsDirectory',[], @(x) (isempty(x) || ischar(x)));
p.addParamValue('resultsFilename','results.mat', @(x) (ischar(x)));

p.parse(varargin{:});
resultsDirectory=p.Results.resultsDirectory;
resultsFilename=p.Results.resultsFilename;
trialData=p.Results.trialData;

imBlockSize=[dataBlockObj.size(1) dataBlockObj.size(2) dataBlockObj.size(3)];

blockData=dataBlockObj.getSlice(1:dataBlockObj.size(3));

if (any(blockData(:)<0) || any(blockData(:)>255)) || (max(blockData(:)-min(blockData(:)))<100)
    disp('--Data values are outside the range, performing a uniform scale');
    %perform a uniform scale
    blockData=uint8(255*((blockData-min(blockData(:)))/max(blockData(:))));
else
    blockData=uint8(blockData);
end



%split the <featureDetect>_<correspondenceTrackType> up so we can find a
%list of all the unique featuredetect methods and then call each of those
%with the set of correspondece methods.  This way the each feature track
%only needs to be done once and we are gaurenteed that the correspondence
%track set is performed on a single set of features.  This way the goodness
%of correspondence can be evaluated.
%
tokenPosition=cell2mat(strfind(activeTrackPackageNameList,'_')');
multitrack=struct('trackList',[],'trackListBackward',[],'featureDetectName','','correspondenceNameList',{});



if size(tokenPosition,2)~=1 || size(tokenPosition,1)~=length(activeTrackPackageNameList)
    error('Multiple tokens found or no token found in the track name list');
else

    
    featureDetectNameFromList=arrayfun(@(trackNameEntry,endPosition) trackNameEntry{1}(1:endPosition),activeTrackPackageNameList(:),tokenPosition-1,'UniformOutput',false);
    correspondenceNameFromList=arrayfun(@(trackNameEntry,startPosition) trackNameEntry{1}(startPosition:end),activeTrackPackageNameList(:),tokenPosition+1,'UniformOutput',false);
    %we need to loop over the unique feature detect list then pass the
    %correspondence with absolute
    uniqueFeatureDetectNameFromList=unique(featureDetectNameFromList);
    %we need to find where the first column entry of interest is located in
    %the rows.  Then we extract those rows
    for uu=1:length(uniqueFeatureDetectNameFromList)
        rowIndexOfInterest=strmatch(uniqueFeatureDetectNameFromList{uu},featureDetectNameFromList);
        
        %What we want to do is to optimize the data being sent to the trackBlock by
        %finding all of the
        if trackForward==true
            [trackList] = trackBlock(blockData,uniqueFeatureDetectNameFromList{uu}, correspondenceNameFromList(rowIndexOfInterest), rowIndexOfInterest,activeTrackPackageNameList,trackPackage);
        else
            trackList=[];
        end
        
        if trackBackward==true
            [trackListBackward] = trackBlock(blockData(:,:,end:-1:1),uniqueFeatureDetectNameFromList{uu}, correspondenceNameFromList(rowIndexOfInterest), rowIndexOfInterest,activeTrackPackageNameList,trackPackage);
        else
            trackListBackward=[];
        end

        multitrack(uu).trackList=trackList;
        multitrack(uu).trackListBackward=trackListBackward;
        multitrack(uu).featureDetectName=uniqueFeatureDetectNameFromList{uu};
        multitrack(uu).correspondenceNameList=correspondenceNameFromList(rowIndexOfInterest);
    end
    
end




%we want interior rectangular boundary
if ~isempty(resultsDirectory)
    region=dataBlockObj.regionInformation.region;
    save(fullfile(resultsDirectory,resultsFilename),'imBlockSize','trackForward','trackBackward','trialData', ...
        'multitrack','correspondenceNameFromList',  'featureDetectNameFromList', 'uniqueFeatureDetectNameFromList',...
        'resultsDirectory','resultsFilename','region','trackPackage','activeTrackPackageNameList','-v7.3');
        
    
else
    %do nothing
end
end



function [trackList] = trackBlock(imBlock,detectorName,correspondenceAnalysisList, activeTrackPackageNameIndexOfInterest,activeTrackPackageNameList,trackPackage)




trackPackageNameList={trackPackage.name};

tableIndexes=findInTable(activeTrackPackageNameList(activeTrackPackageNameIndexOfInterest),trackPackageNameList);
activeTrackPackages=trackPackage(tableIndexes);

%We first setup the detector
%these types should all be equal which ought to be checked
detectorNamesList=cell2mat(reshape(arrayfun(@(x) x.detection.parameters.type,activeTrackPackages,'UniformOutput',false),[],1));
if ~all(diff(detectorNamesList,1,1)==0)
    error('Not all of the detector names are the same');
end

detector = cv.FeatureDetector(activeTrackPackages(1).detection.parameters.type);
correspondenceTrackList={};
trackList={};
%Now we setup the correspondence functions
for aa=1:length(activeTrackPackages)
    correspondenceAnalysis=struct('name',[]);
    correspondenceAnalysis.name=activeTrackPackages(aa).correspondenceAnalysis.name;
    values=activeTrackPackages(aa).correspondenceAnalysis.parameters;
    if ~isempty(values)
        keyList=fieldnames(values);
    else
        keyList=[];
    end
    
    switch(correspondenceAnalysis.name)
        case 'opticalFlowPyrLK'
            %don't need to do anything
        case 'correlationCorrespondence'
            oldPath=addpath(fullfile(getenv('ULTRASPECK_ROOT'),'common\matlab\ext\correlCorresp'));
            correspondenceAnalysis.cc = correlCorresp('image1', double(imBlock(:,:,1)), 'image2', double(imBlock(:,:,2)), 'printProgress', 100);
            
            for ii=1:length(keyList)
                switch(keyList{ii})
                    case 'featurePatchSize'
                        correspondenceAnalysis.cc.featurePatchSize=values.(keyList{ii});
                    case 'relThresh'
                        correspondenceAnalysis.cc.relThresh=values.(keyList{ii});
                    case 'searchPatchSize'
                        correspondenceAnalysis.cc.searchPatchSize=values.(keyList{ii});
                    case 'searchBox'
                        correspondenceAnalysis.cc.searchBox=values.(keyList{ii});
                    otherwise
                        error(['Unsupported correlationCorrespondenceSettings of ' keyList{ii}]);
                end
            end
            path(oldPath)
        otherwise
            error(['Unsupported correspondenceAnalysis type of ' correspondenceAnalysis.name]);
    end
    correspondenceTrackList{aa}=correspondenceAnalysis;
end

for ii = 1:(size(imBlock,3)-1)
    disp(['===================FRAME ' num2str(ii) '================'])
    im1 = imBlock(:,:,ii);
    im2 = imBlock(:,:,ii+1);  % set image2 - image1 is set in previous cycle
    
    keypointsFromIm1_xy = detector.detect(im1);
    if isstruct(keypointsFromIm1_xy)
        keypointsFromIm1_xy={keypointsFromIm1_xy.pt};
        
    else
        %do nothing
    end
    
    for aa=1:length(activeTrackPackages)
        cl=correspondenceTrackList{aa};  %This makes a copy
        %WARNING! to save is up to the cl.name
                disp(['---' cl.name  '---']);
        switch(cl.name)
            case 'opticalFlowPyrLK'
                keypointsMovedToInIm2_xy = cv.calcOpticalFlowPyrLK(im1,im2, keypointsFromIm1_xy,'MaxLevel',3,'WinSize',[11 11]);
                %make sure the output is in row column not default of x,y (column,row)
                trackList{aa}.track(ii).pt_rc=flipud(cell2mat(keypointsFromIm1_xy')');
                trackList{aa}.track(ii).ptDelta_rc=flipud(cell2mat(keypointsMovedToInIm2_xy')'-cell2mat(keypointsFromIm1_xy')');
                disp([' found ' num2str(size(trackList{aa}.track(ii).pt_rc,2)) ' features.']);
                
            case 'correlationCorrespondence'
                cl.cc.image2 = double(im2);  % set image2 - image1 is set in previous cycle
                cl.cc.setFeatures=round(cell2mat(keypointsFromIm1_xy')');
                cl.cc=cl.cc.findCorresps;   % computation for this pair of images
                DD=cl.cc.corresps;
                trackList{aa}.track(ii).pt_rc=DD([2 1],:);
                trackList{aa}.track(ii).ptDelta_rc=[diff(DD([2 4],:),1,1); diff(DD([1 3],:),1,1)];
                cl.cc = cl.cc.advance;        % advance to the next frame: image2 -> image1
                correspondenceTrackList{aa}=cl;  %must save since is not a pass by reference
            otherwise
                error(['Unsupported correspondenceAnalysis type of ' cl.name]);
                
        end
    
    end
    
end
end

