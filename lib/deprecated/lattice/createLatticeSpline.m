%[lattice,latticeSamplePoints_rc, dataFilename]=createLatticeSpline(caseFile,activeSplineIndex,...) - creates
%a sampled lattice from a case and will return the sampled data and save
%the data and metadata in dataFilename.  This function tracks the spline
%over time so the sample points will vary in the lattice.
%
%This function creates a sampled lattice from a spline.  The function then tracks the
%movement of the splines control points per frame.  Then in the next frame 
%a new spline is generated on the control points and the process is repeated.
%But it is important to make sure the splines data is evenly spaced so that 
%it can be compared between frames.
%
%INPUTS
%caseFile - The name of the input file to process.
%
%activeSplineIndex - The index into the spline database of the spline to
%use.
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
%latticeSamplePoints_rc - will be a 2 by M by N matrix where the first element of the
%row corresponds to the row of the image and the second element corresponds
%to the column of the image.  The "_rc" means that it is using row,column
%notation with the 1,1 point being in the upper left instead of the
%traditional image processing method of a (column,row) notation. M is the
%length of the hypothesis set and N is the number of hypothesis sets.  Note
%the start index is 1,1 not 0,0.
%
%dataFilename - This is the data file created by the function and it is
%stored in the Lattice area defined by caseFile
function [lattice,latticeSamplePoints_rc,dataFilename]=createLatticeSpline(caseFile,activeSplineIndex,varargin)
%% Load the data and setup the default regions

p = inputParser;   % Create an instance of the class.
p.addRequired('caseFile', @ischar);
p.addRequired('activeSplineIndex', @(x) isscalar(x) && isnumeric(x));
p.addParamValue('interpolationMode', 'cubic', @ischar);
p.addParamValue('commentTag', [], @(x) true);
p.addParamValue('showGraphics', false, @(x) islogical(x) && isscalar(x) );
p.addParamValue('showSamplePoints', false, @(x) islogical(x) && isscalar(x) );
p.addParamValue('imageProcess','none',@(x) any(strcmpi(x,{'none','abs'})));
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);

p.parse(caseFile,activeSplineIndex, varargin{:});

interpolationMode=p.Results.interpolationMode;
commentTag=p.Results.commentTag; %#ok<NASGU>
showGraphics=p.Results.showGraphics;
showSamplePoints=p.Results.showSamplePoints;
imageProcess=p.Results.imageProcess;
ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;

[metadata]=loadCaseData(caseFile);

framesToProcess=getCaseFramesToProcess(metadata);

if showGraphics
    figH = figure();
    caseStr=getCaseName(metadata);
    axisRange=metadata.axisRange;
    set(figH,'Name',caseStr);
end


%% Sample the image with the spline control points and track them
% [d1, hypothSetSize, totalHypothSets]=size(samplePoints_rc);
% lattice = zeros(hypothSetSize,length(framesToProcess),totalHypothSets);
%% spline 
load(metadata.splineFilename,'splineData');

baseControlptX=round(splineData(activeSplineIndex).controlpt.x);
baseControlptY=round(splineData(activeSplineIndex).controlpt.y);



%samplePointsBase_rc=splineSample(splineData(activeSplineIndex).controlpt.x,splineData(activeSplineIndex).controlpt.y,size(img,2));

%okay we will build up the the sample point matrix  The keys here to get
%the correct dimensions are that the needed for the matrix
%samplePoints_rc=repmat(reshape((kron(translationVector_rc,reshape(spacingVector,1,[]))),2,1,[]),[1 size(samplePointsBase_rc,2) 1]);
%samplePoints_rc=samplePoints_rc+repmat(samplePointsBase_rc,[1,1,size(samplePoints_rc,3)]);

%these are being reshaped as [(row 1 hyp 1), (row 1 hyp 2) ... (row 1 hyp N)]
% samplePointsColumn=reshape(samplePoints_rc(2,:,:),[],1);
% samplePointsRow=reshape(samplePoints_rc(1,:,:),[],1);
for ii=1:length(framesToProcess)
    frameNumber=framesToProcess(ii);
    [img] = ultrasonixGetFrame(metadata.rfFilename,frameNumber,ultrasonixGetFrameParms{:});
    switch(imageProcess)
        case 'abs'
            imgPostProcess=abs(img);
        case 'none'
            imgPostProcess=img;
        otherwise
            error(['The image processing function of ' imageProcess ' is not a valid type.'])
    end
    
    
%     latticeImg = interp2(1:size(imgPostProcess,2),1:size(imgPostProcess,1),imgPostProcess,samplePointsColumn,samplePointsRow,interpolationMode);
%     if any(isnan(latticeImg(:)))
%         error('Interp is outside the boundaries');
%     end
%     
%     %we need to reshape the sampled data into a new lattice where a column is
%     %the sample points row
%     lattice(:,ii,:)=reshape(latticeImg,size(imgPostProcess,2),1,[]);
    
%     if showGraphics
%         figure(figH);
%         subplot(8,1,1:4); imagesc(absIfIm(imgPostProcess(400:end,:))); colormap(gray); set(gca,'XTickLabel',''); ylabel('Depth');    
%         colorbar;
%         hold on;
%         plot(samplePointsColumn,samplePointsRow-400,'r.')
%         hold off
%         subplot(8,1,5:8); imagesc(absIfIm(reshape((permute(lattice,[1 3,2])),size(lattice,1)*size(lattice,3),size(lattice,2))).'); xlabel('Lateral distance'); ylabel('Frames');
%         colorbar;
%     end
end



%% Save the results

dataFilename=fullfile(getCasePathField(metadata,'latticePath'),['lattice_' datestr(now,'yyyymmddHHMMSS') '.mat']);
save(dataFilename,'lattice','interpolationMode','commentTag','samplePoints_rc','caseFile');

end

