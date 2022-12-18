function mriData=loadMriExcelSheet(xlsFilename,xlsSheetName,velocityMeasurementsPerRegion, colOffsetBetweenVelocityBlockAndRegionLabel, startRegionLabel)

switch(nargin)
    case 0
        xlsFilename='E:\Users\potto\ultraspeck\workingFolders\potto\doc\Thesis\Experiments\Collecting MRI Ultrasound Data\MRUS007\SID9159R_9_19_2014_RF.xlsx';
        xlsSheetName='Ser9 PC';
        velocityMeasurementsPerRegion=24;
        colOffsetBetweenVelocityBlockAndRegionLabel=4;
        startRegionLabel='RF_R1_c1';
        
    case 1
        xlsSheetName='';
        velocityMeasurementsPerRegion=24;
        colOffsetBetweenVelocityBlockAndRegionLabel=4;
        startRegionLabel='RF_R1_c1';
        
    case 2
        velocityMeasurementsPerRegion=24;
        colOffsetBetweenVelocityBlockAndRegionLabel=4;
        startRegionLabel='RF_R1_c1';
        
    case 3
        colOffsetBetweenVelocityBlockAndRegionLabel=4;
        startRegionLabel='RF_R1_c1';
        
    case 4
        startRegionLabel='RF_R1_c1';
        
    case 5
        %do nothing
        
    otherwise
        error('');
end


if isempty(xlsSheetName)
    [xls.num,xls.text,xls.cell]=xlsread(xlsFilename);
else
    [xls.num,xls.text,xls.cell]=xlsread(xlsFilename,xlsSheetName);
end


%% Find where the measurements start
[regionStartRow,regionStartCol]=find(cellfun(@(x) strcmpi(startRegionLabel,x),xls.cell));

if length(regionStartRow)~=1 
    if isempty(regionStartRow)
        error(['No instance of ' startRegionLabel ' was found, but 1 should have been found.']);
    else
        error(['Only one instance of ' startRegionLabel ' should be found']);
    end
    
end


%% Find where the mesurements end.  We know the run is horizontal
regionLabels=xls.cell(regionStartRow,regionStartCol:end);
isRegionLabel=cellfun(@(x) ischar(x), regionLabels);
isRegionLabelIdx=find(isRegionLabel);

isRegionLabelIdx(find(diff(isRegionLabelIdx)~=1,1,'first')+1:end)=[];


if ~all(diff(isRegionLabelIdx)==1) || isRegionLabelIdx(1)~=1
    error('Region label either doesn''t start at one or is not consecutive');
else
    %do nothing
end

isRegionLabel=regionLabels(isRegionLabelIdx);
mriData=[];
%% We need to loop through one label at a time and match the block
for ii=1:length(isRegionLabel)
    if ii==1
        mriData=loadMriData(xls,regionStartRow,regionStartCol,velocityMeasurementsPerRegion,regionLabels{ii},ii,colOffsetBetweenVelocityBlockAndRegionLabel);      
        mriData.series=xlsSheetName;
        mriData.xls.regionStartCol=regionStartCol;
    else
        mriDataEntry=loadMriData(xls,regionStartRow,regionStartCol,velocityMeasurementsPerRegion,regionLabels{ii},ii,colOffsetBetweenVelocityBlockAndRegionLabel);
        mriDataEntry.series=xlsSheetName;
        mriDataEntry.xls.regionStartCol=regionStartCol;        
        mriData(ii)=mriDataEntry;
    end
end

if ~all(diff([mriData.shiftAmount])==0)
    error('The shift amounts changed.');
end



end

function mriData=loadMriData(xls,regionStartRow,regionStartCol,velocityMeasurementsPerRegion,regionLabelName,regionLabelIdx,colOffsetBetweenVelocityBlockAndRegionLabel)
colOffset=colOffsetBetweenVelocityBlockAndRegionLabel;
%regionStartRow=regionBaseStartRow+(regionLabelIdx-1)*velocityMeasurementsPerRegion;
N=velocityMeasurementsPerRegion;

%Grab the projected velocity value from the table
a=[xls.cell{regionStartRow+1:regionStartRow+velocityMeasurementsPerRegion,regionStartCol+regionLabelIdx-1}]';
if any(isnan(a))
    error('This should be a complete vector of valid velocities.');
end
%need to find what the shift of the projected velocity is.  Do this by forming all combinations of the data.
A=repmat([xls.cell{regionStartRow+1:regionStartRow+N,regionStartCol+regionLabelIdx-1}]',1,N);
[m,n] = size(A);
[I,J] = ndgrid(0:m-1,0:n-1);
Ashift = A(1+m*J+mod(bsxfun(@minus,I,[0:(n-1)]),m));

if ~strcmp(xls.cell(regionStartRow,regionStartCol-colOffset),'Speed')  || ~strcmp(xls.cell(regionStartRow-1,regionStartCol-4),'mm/sec') || ~strcmp(xls.cell(regionStartRow-2,regionStartCol-colOffset),'RF')
    error('Should be RF mm/sec Speed');
end

isNumber=cellfun(@(x) isnumeric(x) && ~isnan(x),xls.cell(:,regionStartCol-colOffset));
validTable=find(isNumber);
rr=cell2mat(xls.cell(isNumber,regionStartCol-colOffset));

startIdxList=nan(size(Ashift,2),1);
%Now match the shifted version of the projected values with the projected
%values next to the 3D values.  This assumes that all ROI data sets are
%unique
for ii=1:size(Ashift,2)
    tmpShift=arrayfun(@(x) all(rr((1:size(Ashift,1))+x,1)==Ashift(:,ii)),(0:(length(rr)-size(Ashift,1))));
    shiftIndex=find(tmpShift);
    if ~isempty(shiftIndex)
        startIdxList(ii)=shiftIndex;
    else
        %do nothing
    end
end

if sum(isnan(startIdxList))~=(size(Ashift,2)-1)
    error('startIdxList should be length 1');
else
    shiftAmount=find(~isnan(startIdxList));
    startIdx=startIdxList(shiftAmount);
end


%startIdx=startIdx+velocityMeasurementsPerRegion*(regionLabelIdx-1);

positionData_pixel=xls.cell(validTable(startIdx):(validTable(startIdx)+m-1),((regionStartCol-colOffset-4-5-4):(regionStartCol-colOffset-4-5+2-4)));
positionData_mm=xls.cell(validTable(startIdx):(validTable(startIdx)+m-1),((regionStartCol-colOffset-4-5):(regionStartCol-colOffset-4-5+2)));
velocityData_mmPerSec=xls.cell(validTable(startIdx):(validTable(startIdx)+m-1),((regionStartCol-colOffset-4):(regionStartCol-colOffset)));

mriData.xls.positionData_pixel=positionData_pixel;
mriData.xls.positionData_mm=positionData_mm;
mriData.xls.velocityData_mmPerSec=velocityData_mmPerSec;

mriData.projected_mmPerSec=cell2mat(velocityData_mmPerSec(:,end));
mriData.projectedAndShifted_mmPerSec=a;

mriData.velocity_mmPerSec=cell2mat(velocityData_mmPerSec(:,1:3));
mriData.velocity_mmPerSec_units={'Left','Posterior','Superior'};

mriData.position_mm=cell2mat(positionData_mm);
mriData.positionLabel_mm={'Left','Posterior','Superior'};
mriData.position_pixel=cell2mat(positionData_pixel);
mriData.positionLabel_pixel={'X','Y','Z'};
mriData.positionPixelToMmMap={'X->Posterior','Y->-Superior','Z->Left'};

mriData.shiftAmount=shiftAmount;
mriData.regionLabelName=regionLabelName;

end