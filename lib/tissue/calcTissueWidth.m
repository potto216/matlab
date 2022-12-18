%Calculate the mean upper and lower tissue depths along with the tissue width along with the standard deviation.
%The results are in pels or mm.
%Note:The 50 columns on the side are zeroed out.
%INPUT
%mask - is the boolean muscle mask image
%pel2mm - is the scaling to output the image in mm.  If not specified it
%will be in pels
%OUTPUT
%All values are in pels unless pel2mm is given then in mm
%upperTissueDepthMean_mm - the mean distance of the top of the mask
%lowerTissueDepthMean_mm - the mean distance of the bottom of the mask
%tissueThicknessMean_mm - mean thickness of the mask
function [ upperTissueDepthMean_mm,lowerTissueDepthMean_mm,tissueThicknessMean_mm,upperTissueDepthStd_mm,lowerTissueDepthStd_mm,tissueThicknessStd_mm,tissueArea_mm2] = calcTissueWidth( mask,pel2mm )



switch nargin
    case 1
        pel2mm=1;
    case 2
        %do nothing
    otherwise
        error('Invalid number of input arguments.');
end

%trim the mask at the edges
mask(:,1:50)=0;
mask(:,end:(end-(50-1)))=0;

 
    columnMark=any(mask,1);
    %columnBounds=regionMark(columnMark);
    columnValid=find(columnMark);
    columnStartEnd_idx=colvecfun(@(x) regionMark(x),mask(:,columnValid));
    columnWidth=diff(columnStartEnd_idx,1,1);
    if false
        %% debug code
        figure;
        subplot(3,1,[1 2])
        imagesc(mask)
        hold on
        plot(columnValid,columnStartEnd_idx(1,:),'go');
        hold on
        plot(columnValid,columnStartEnd_idx(2,:),'go');
        
        subplot(3,1,3)
        plot(columnWidth)
    end
    
    upperTissueDepthMean_mm=mean(columnStartEnd_idx(1,:),2)*pel2mm;
    lowerTissueDepthMean_mm=mean(columnStartEnd_idx(2,:),2)*pel2mm;
    tissueThicknessMean_mm=mean(diff(columnStartEnd_idx),2)*pel2mm;
    
    upperTissueDepthStd_mm=std(columnStartEnd_idx(1,:),0,2)*pel2mm;
    lowerTissueDepthStd_mm=std(columnStartEnd_idx(2,:),0,2)*pel2mm;
    tissueThicknessStd_mm=std(diff(columnStartEnd_idx),0,2)*pel2mm;

    tissueArea_mm2=sum(mask(:))*pel2mm^2;

end

function oldVersion(mask)
upperLowerMask=diff(mask);
upperIndex=find(upperLowerMask>0);
lowerIndex=find(upperLowerMask<0);
[upperIndexRow,upperIndexCol]=ind2sub(size(upperLowerMask),upperIndex); %#ok<NASGU>
[lowerIndexRow,lowerIndexCol]=ind2sub(size(upperLowerMask),lowerIndex); %#ok<NASGU>

upperTissueDepthMean_pel=mean(upperIndexRow);
lowerTissueDepthMean_pel=mean(lowerIndexRow);
muscleThicknessMean_pel=mean(lowerIndexRow-upperIndexRow);

upperTissueDepthStd_pel=std(upperIndexRow);
lowerTissueDepthStd_pel=std(lowerIndexRow);
muscleThicknessStd_pel=std(lowerIndexRow-upperIndexRow);
end

function regionIdx=regionMark(x)
regionIdx=[find(x,1,'first') find(x,1,'last')]';
end