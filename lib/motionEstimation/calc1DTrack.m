%This function will create a tracking output based on the input
%
%INPUT
%caseFile - The name of the input file to process.
%
%roiList - The input parameters for the search
%
%lattice - The lattice is the interpolated values at samplePoints_rc.  This
%matrix will have the dimensions of M by numberOfFrames by N, where M and N are the same as
%the samplePoints_rc and the numberOfFrames are the valid number of frames
%in the case.   M is the length of the hypothesis set and N is the number of hypothesis sets.
%
%showGraphics - displays the graphics while processing.
%showSamplePoints - displays the sample points if showGraphics is selected.
%
%displayFcn - this is the function used to display the results on the
%screen for the user.  Its default is @(x) = abs(x).^0.5 which reduces the dynamic
%range of the image, but to see the full range of the RF (+-) you could
%pass in a function @(x) absIfIM(x).  The key point is this should be an
%anonymous function.
%
%commentTag - This tag should be a string or cell array of strings, but can
%be anything.  If it is a cell array of strings the vertical dimension
%means a new comment and the columns should have a max of 2 to be a key
%value setup.
%
%compute1DSpeckleTrackOptions - These are the options used for the speckle
%track such as interpolation mode and edge tracking.
%
%framesToProcess - This lists the frames available for processing and will
%override the default of processing all valid frames.  This is useful when
%the lattice is only over a subset of valid frames.
%
%latticeFilename - This is provided to save in the track file to link back to 
%a lattice file to determine if it was an adaptive/fix track and what kind.
%The lattice cannot be loaded from this file because often we wish to only
%track a subset of the lattice.
%
%OUTPUT
%roiOut - the output structure with the results from the tracking
%
%trackFilename - the filename that also holds the data generated.  This
%data will only be saved if the user requests this variable.
function [roiOut,trackFilename]=calc1DTrack(caseFile,roiList,lattice,varargin)
%% Load the data and setup the default regions
p = inputParser;   % Create an instance of the class.
p.addRequired('caseFile', @ischar);
p.addRequired('roiList', @(x) isstruct(x) && isvector(x));
p.addRequired('lattice', @(x) any(repmat(ndims(x),1,2) == [2 3]) && isnumeric(x));
p.addParamValue('compute1DSpeckleTrackOptions',{},  @(x) iscell(x) || isempty(x));
p.addParamValue('commentTag', [], @(x) true);
p.addParamValue('showGraphics', false, @(x) islogical(x) && isscalar(x) );
p.addParamValue('displayFcn',@(x) abs(x).^0.5,@(x) isa(x,'function_handle'));
p.addParamValue('framesToProcess',[],@(x) isvector(x) && isnumeric(x));
p.addParamValue('latticeFilename',[],@(x) ischar(x));


p.parse(caseFile,roiList,lattice, varargin{:});

showGraphics=p.Results.showGraphics;
commentTag=p.Results.commentTag;
compute1DSpeckleTrackOptions=p.Results.compute1DSpeckleTrackOptions;
displayFcn = p.Results.displayFcn;
framesToProcess=p.Results.framesToProcess;
latticeFilename=p.Results.latticeFilename;

[metadata]=loadCaseData(caseFile);
caseStr=getCaseName(metadata);


if isempty(framesToProcess)
    framesToProcess=metadata.validFramesToProcess;
    if isempty(framesToProcess)
        [header] = ultrasonixGetInfo(metadata.rfFilename);
        framesToProcess=(0:(header.nframes-1));
    end
else
    if ~isempty(metadata.validFramesToProcess)
        invalidFrames=setdiff(framesToProcess,metadata.validFramesToProcess);
        error(['The frames ' num2str(invalidFrames) ' are not listed as valid frames by the case file.']);
    else
        %accept anything and go on.
    end
end





%% Perform correlation match
trackcolors={'r','y','g','b','c','m'}; %put red first because it is easier to see if it goes outside the boundaries
if showGraphics
    f1=figure;
end


for jjj=1:size(lattice,3)
    mmodeImg=lattice(:,:,jjj);
    if showGraphics
        figure(f1);
        
        imagesc(displayFcn(mmodeImg)); colormap(gray); hold on;
    end
    
    for jj=1:length(roiList)
        roiOut(jj,jjj).corrMatch = zeros(length(framesToProcess),1); %#ok<AGROW>
        roiOut(jj,jjj).corrMaxVal = zeros(length(framesToProcess),1); %#ok<AGROW>
        roiOut(jj,jjj).corr= zeros(roiList(jj).search(end)-length(roiList(jj).template)-roiList(jj).search(1)+1,length(framesToProcess)); %#ok<AGROW>
        roiOut(jj,jjj).commentTag=commentTag;
        
        for ii=1:length(framesToProcess)
            [roiOut(jj,jjj).corrMatch(ii),roiOut(jj,jjj).corrMaxVal(ii), roiOut(jj,jjj).corr(:,ii), roiOut(jj,jjj).hitRail(ii),roiOut(jj,jjj).validCorr(ii)] = compute1DSpeckleTrack(mmodeImg,ii,roiList(jj).template,roiList(jj).search,compute1DSpeckleTrackOptions{:}); %#ok<AGROW>
        end
        
        roiOut(jj,jjj).rfMotion = cumsum(roiOut(jj,jjj).corrMatch); %#ok<AGROW>
        if showGraphics
            figure(f1);
            %make sure centered at correct point
            plot(roiOut(jj,jjj).rfMotion+mean(roiList(jj).search),trackcolors{jj},'Linewidth',2);
            plot(repmat(jj*2,length(roiList(jj).search),1),roiList(jj).search,trackcolors{jj},'Linewidth',1);
            if any(roiOut(jj,jjj).hitRail)
                plot(find(roiOut(jj,jjj).hitRail),roiOut(jj,jjj).rfMotion(roiOut(jj,jjj).hitRail)+mean(roiList(jj).search),[trackcolors{jj} 'o'],'Linewidth',2);
            end
            
        end
    end
    
    [bestCorrMaxVal bestCorrIndex]=max([roiOut(:,jjj).corrMaxVal],[],2);
    roiOut(length(roiList)+1,jjj).corrMaxVal=bestCorrMaxVal;
    cm=[roiOut.corrMatch];
    %pull out the best correlation lags
    roiOut(length(roiList)+1,jjj).corrMatch=cm(sub2ind(size(cm),reshape(1:size(cm,1),[],1),bestCorrIndex));
    roiOut(length(roiList)+1,jjj).rfMotion = cumsum(roiOut(length(roiList)+1,jjj).corrMatch);
    
    
    if showGraphics
        plot(roiOut(length(roiList)+1).rfMotion,trackcolors{jj+1},'Linewidth',4);
        hold off;
        xlabel('frames')
        ylabel('lateral distance')
        title([caseStr '.  the bold line is using max of the corr values'],'interpreter','none')
        axis tight;
    end
end

%% Save the results
switch(nargout)
    case 1
        %don't save the file
    case 2 %save the data file
        trackFilename=fullfile(getCasePathField(metadata,'motionPath'),['Speckle1DTrack_' datestr(now,'yyyymmddHHMMSS') '.mat']);
        
        if ~exist(getCasePathField(metadata,'motionPath'),'dir')
            mkdir(getCasePathField(metadata,'motionPath'))
        end
        
        stackInfo=dbstack('-completenames');
        trackGenerationFunction=stackInfo(1);
        save(trackFilename,'roiList','roiOut','lattice','compute1DSpeckleTrackOptions','commentTag','trackGenerationFunction','latticeFilename');
        
    otherwise
        error('The wrong number of output arguments were given.')
end
end