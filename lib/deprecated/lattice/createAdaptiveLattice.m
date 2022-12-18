%[lattice, dataFilename]=createAdaptiveLattice(caseFile,samplePoints_rc,...) - creates
%a sampled lattice from a case and will return the sampled data and save
%the data and metadata in dataFilename.  The data can be post processed
%multiple ways from the raw RF.  This uses a seperate set of sample points
%for each frame
%
%This function creates a sampled lattice from a set of sample points.  The
%lattice will be a set of interpolated values whose shape will match the
%dimensions of samplePoints.
%
%Data is only saved if the dataFilename output is specified.
%
%INPUTS
%caseFile - The name of the input file to process.
%
%samplePoints_rc - will be a 2 by M by N matrix where the first element of the
%row corresponds to the row of the image and the second element corresponds
%to the column of the image.  The "_rc" means that it is using row,column
%notation with the 1,1 point being in the upper left instead of the
%traditional image processing method of a (column,row) notation. M is the
%length of the hypothesis set and N is the number of frames being processed.  Note
%the start index is 1,1 not 0,0.  The number of frames N must be the same
%length as samplePointsFrameIndex which same which frame to process.
%
%samplePointsFrameIndex - This is the sync which matches the frame number to the
%samplePoints_rc N index.  Remeber that frames are 0 based.
%
%showGraphics - displays the graphics while processing.
%showSamplePoints - displays the sample points if showGraphics is selected.
%
%interpolationMode - the interpolation method used with the interpolation
%routine to determine the sample points.  This can be any of the valid
%methods which were given for interp2.
%
%imageProcess - What processing steps to apply to the image before sampling
%on the lattice.  Right now the selection is: {'none','mag'} where:
%'none' - default, Do not apply any processing to the image
%'abs' - take the absolute value of the image
%
%ultrasonixGetFrameParms - The parameters to configure the ultrasonix get
%frame function.
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
%OUTPUT
%lattice - The lattice is the interpolated values at samplePoints_rc.  This
%matrix will have the dimensions of M by numberOfFrames by N, where M and N are the same as
%the samplePoints_rc and the numberOfFrames are the valid number of frames in the case.
%
%dataFilename - This is the data file created by the function and it is
%stored in the Lattice area defined by caseFile.  This must be specified to
%save the results
%
%datetimeStamp - this is the date time stamp that was appended on the data
%files and can be used to save other adaptive lattice info.
%
function [lattice,dataFilename,datetimeStamp]=createAdaptiveLattice(caseFile,samplePoints_rc,samplePointsFrameIndex,varargin)
%% Load the data and setup the default regions

p = inputParser;   % Create an instance of the class.
p.addRequired('caseFile', @ischar);
p.addRequired('samplePoints_rc', @(x) (size(x,1)==2) && any(length(size(x)) == [2 3]) && isnumeric(x));
p.addRequired('samplePointsFrameIndex', @(x) isvector(x) && isnumeric(x));
p.addParamValue('interpolationMode', 'cubic', @ischar);
p.addParamValue('commentTag', [], @(x) true);
p.addParamValue('showGraphics', false, @(x) islogical(x) && isscalar(x) );
p.addParamValue('showSamplePoints', false, @(x) islogical(x) && isscalar(x) );
p.addParamValue('imageProcess','none',@(x) any(strcmpi(x,{'none','abs'})));
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);
p.addParamValue('displayFcn',@(x) abs(x).^0.5,@(x) isa(x,'function_handle'));


p.parse(caseFile,samplePoints_rc,samplePointsFrameIndex, varargin{:});

interpolationMode=p.Results.interpolationMode;
commentTag=p.Results.commentTag; %#ok<NASGU>
showGraphics=p.Results.showGraphics;
showSamplePoints=p.Results.showSamplePoints;
imageProcess=p.Results.imageProcess;
ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;
displayFcn = p.Results.displayFcn;

[metadata]=loadCaseData(caseFile);

framesToProcess=getCaseFramesToProcess(metadata);

if showGraphics
    figH = figure();
    caseStr=getCaseName(metadata);
    axisRange=metadata.axisRange;
    set(figH,'Name',caseStr);
end


%% Sample the image with the spline points and
[d1, hypothSetSize, totalHypothSets]=size(samplePoints_rc);

if length(samplePointsFrameIndex)~=totalHypothSets
    error(['The total number of frames ' num2str(length(samplePointsFrameIndex))])
end

lattice = zeros(hypothSetSize,totalHypothSets,1);

%these are being reshaped as [(row 1 hyp 1), (row 1 hyp 2) ... (row 1 hyp N)]

for ii=1:length(samplePointsFrameIndex)
    
    frameNumber=samplePointsFrameIndex(ii);
    
    samplePointsColumn=reshape(samplePoints_rc(2,:,ii),[],1);
    samplePointsRow=reshape(samplePoints_rc(1,:,ii),[],1);
    
    
    [img] = ultrasonixGetFrame(metadata.rfFilename,frameNumber,ultrasonixGetFrameParms{:});
    switch(imageProcess)
        case 'abs'
            imgPostProcess=abs(img);
        case 'none'
            imgPostProcess=img;
        otherwise
            error(['The image processing function of ' imageProcess ' is not a valid type.'])
    end
    latticeImg = interp2(1:size(imgPostProcess,2),1:size(imgPostProcess,1),imgPostProcess,samplePointsColumn,samplePointsRow,interpolationMode);
    if any(isnan(latticeImg(:)))
        warning('Interp is outside the boundaries');
        latticeImg(isnan(latticeImg(:)))=0;
    end
    
    %we need to reshape the sampled data into a new lattice where a column is
    %the sample points row
    lattice(:,ii,:)=reshape(latticeImg,size(imgPostProcess,2),1,[]);
    
    if showGraphics
        figure(figH);
        subplot(8,1,1:4); imagesc(displayFcn(imgPostProcess(400:end,:))); colormap(gray); set(gca,'XTickLabel',''); ylabel('Depth');
        colorbar;
        hold on;
        plot(samplePointsColumn,samplePointsRow-400,'r.')
        hold off
        subplot(8,1,5:8); imagesc(displayFcn(reshape((permute(lattice,[1 3,2])),size(lattice,1)*size(lattice,3),size(lattice,2))).'); xlabel('Lateral distance'); ylabel('Frames');
        colorbar;
    end
end

stackInfo=dbstack('-completenames');
latticeGenerationFunction=stackInfo(1);

datetimeStamp=datestr(now,'yyyymmddHHMMSS');

%% Save the results
switch(nargout)
    case 1
    case {2,3}
        % Save the results
        if ~exist(getCasePathField(metadata,'latticePath'),'dir')
            mkdir(getCasePathField(metadata,'latticePath'))
        end
        
        
        dataFilename=fullfile(getCasePathField(metadata,'latticePath'),['lattice_adaptive_' datetimeStamp '.mat']);
        
        save(dataFilename,'lattice','interpolationMode','commentTag','samplePoints_rc','caseFile','latticeGenerationFunction');
        
    otherwise
        error('Invalid number of output arguments.')
end
end

