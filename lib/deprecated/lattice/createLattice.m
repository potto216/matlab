%[lattice, dataFilename]=createLattice(caseFile,samplePoints_rc,...) - creates
%a sampled lattice from a case and will return the sampled data and save
%the data and metadata in dataFilename.  The data can be post processed
%multiple ways from the raw RF.
%
%This function creates a sampled lattice from a set of sample points.  The
%lattice will be a set of interpolated values whose shape will match the
%2,3 dimensions of samplePoints
%
%INPUTS
%caseFile - The name of the input file to process.
%
%samplePoints_rc - will be a 2 by M by N matrix where the first element of the
%row corresponds to the row of the image and the second element corresponds
%to the column of the image.  The "_rc" means that it is using row,column
%notation with the 1,1 point being in the upper left instead of the
%traditional image processing method of a (column,row) notation. M is the
%length of the hypothesis set and N is the number of hypothesis sets.  Note
%the start index is 1,1 not 0,0.
%
%showGraphics - displays the graphics while processing.
%showSamplePoints - displays the sample points if showGraphics is selected.
%
%interpolationMode - the interpolation method used with the interpolation
%routine to determine the sample points.  This can be any of the valid
%methods which were given for interp2.  Setting the interp mode to nearest
%is useful when using an integer lattice.
%
%imageProcess - What processing steps to apply to the image before sampling
%on the lattice.  Right now the selection is: {'none','mag'} where:
%'none' - default, Do not apply any processing to the image
%'abs' - take the absolute value of the image
%
%dataReader  - This is the type of data reader.  This is a cell array.
% Below are the following valid values:
%  'ultrasonixGetFrame' - default and uses the ultrasonixGetFrame function to
%    read the data.  Parameters are given by: ultrasonixGetFrameParms
%  {'uread', {parms}} - uses the uread function and the parms cell array
%  {'mat','filename'} - loads the image block from a mat file.
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
%stored in the Lattice area defined by caseFile

function [lattice,dataFilename]=createLattice(caseFile,samplePoints_rc,varargin)
%% Load the data and setup the default regions

p = inputParser;   % Create an instance of the class.
p.addRequired('caseFile', @(x) ischar(x) || isstruct(x));
p.addRequired('samplePoints_rc', @(x) (size(x,1)==2) && any(length(size(x)) == [2 3]) && isnumeric(x));
p.addParamValue('interpolationMode', 'cubic', @ischar);
p.addParamValue('commentTag', [], @(x) true);
p.addParamValue('dataReader',{'ultrasonixGetFrame'},@iscell);
p.addParamValue('showGraphics', false, @(x) islogical(x) && isscalar(x) );
p.addParamValue('showSamplePoints', false, @(x) islogical(x) && isscalar(x) );
p.addParamValue('imageProcess','none',@(x) any(strcmpi(x,{'none','abs'})));
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);
p.addParamValue('displayFcn',@(x) abs(x).^0.5,@(x) isa(x,'function_handle'));


p.parse(caseFile,samplePoints_rc, varargin{:});

interpolationMode=p.Results.interpolationMode;
commentTag=p.Results.commentTag; %#ok<NASGU>
showGraphics=p.Results.showGraphics;
showSamplePoints=p.Results.showSamplePoints;
imageProcess=p.Results.imageProcess;
ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;
dataReader=p.Results.dataReader;
displayFcn = p.Results.displayFcn;

[metadata]=loadCaseData(caseFile);

framesToProcess=getCaseFramesToProcess(metadata);

%load and pre information
switch(dataReader{1})
    case 'ultrasonixGetFrame'
        % do nothing
    case 'uread'
        %do thing
    case 'mat'
        dataMat=load(dataReader{2});
        framesToProcess=(0:(size(dataMat.imBlock,3)-1));
    otherwise
        error(['Unsupported datatype of ' dataReader{1}]);
end

if showGraphics
    figH = figure();
    caseStr=getCaseName(metadata);
    axisRange=metadata.axisRange;
    set(figH,'Name',caseStr);
end


%% Sample the image with the spline points and
[d1, hypothSetSize, totalHypothSets]=size(samplePoints_rc);
lattice = zeros(hypothSetSize,length(framesToProcess),totalHypothSets);

%these are being reshaped as [(row 1 hyp 1), (row 1 hyp 2) ... (row 1 hyp N)]
samplePointsColumn=reshape(samplePoints_rc(2,:,:),[],1);
samplePointsRow=reshape(samplePoints_rc(1,:,:),[],1);



for ii=1:length(framesToProcess)
    frameNumber=framesToProcess(ii);
    
    switch(dataReader{1})
        case 'ultrasonixGetFrame'
            [img] = ultrasonixGetFrame(metadata.rfFilename,frameNumber,ultrasonixGetFrameParms{:});  %load image first so you know how big the frames are
        case 'uread'
            [img] = uread(metadata.rfFilename,frameNumber,dataReader{2}{:});  %load image first so you know how big the frames are
        case 'mat'
            img=dataMat.imBlock(:,:,frameNumber+1);
        otherwise
            error(['Unsupported datatype of ' dataReader{1}]);
    end
    
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
        error('Interp is outside the boundaries');
    end
    
    %we need to reshape the sampled data into a new lattice where a column is
    %the sample points row
    lattice(:,ii,:)=reshape(latticeImg,size(lattice,1),1,[]);
    
    if showGraphics
        %         figure(figH);
        %         subplot(8,1,1:4); imagesc(displayFcn(imgPostProcess(400:end,:))); colormap(gray); set(gca,'XTickLabel',''); ylabel('Depth');
        %         colorbar;
        %         hold on;
        %         plot(samplePointsColumn,samplePointsRow-400,'r.')
        %         hold off
        %         subplot(8,1,5:8); imagesc(displayFcn(reshape((permute(lattice,[1 3,2])),size(lattice,1)*size(lattice,3),size(lattice,2))).'); xlabel('Lateral distance'); ylabel('Frames');
        %         colorbar;
        
        figure(figH);
        subplot(8,1,1:4); imagesc(displayFcn(imgPostProcess(400:end,:))); colormap(gray); set(gca,'XTickLabel',''); ylabel('Depth');
        colorbar;
        title(['Frame ' num2str(frameNumber) ' of ' num2str(max(framesToProcess))]);        
        hold on;
        plot(samplePointsColumn,samplePointsRow-400,'r.')
        hold off
        subplot(8,1,5:8); imagesc(displayFcn(permute(lattice(:,ii,:),[3 1,2]))); xlabel('Lateral distance'); ylabel('axial distance');
        colorbar;
        
    end
end



%% Save the results

% if ~exist(getCasePathField(metadata,'latticePath'),'dir')
%     mkdir(getCasePathField(metadata,'latticePath'))
% end
%
% dataFilename=fullfile(getCasePathField(metadata,'latticePath'),['lattice_' datestr(now,'yyyymmddHHMMSS') '.mat']);
% save(dataFilename,'lattice','interpolationMode','commentTag','samplePoints_rc','caseFile');


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
        
        
        dataFilename=fullfile(getCasePathField(metadata,'latticePath'),['lattice_' datetimeStamp '.mat']);
        
        save(dataFilename,'lattice','interpolationMode','commentTag','samplePoints_rc','caseFile','latticeGenerationFunction','dataReader','ultrasonixGetFrameParms','imageProcess');
        
    otherwise
        error('Invalid number of output arguments.')
end


end

