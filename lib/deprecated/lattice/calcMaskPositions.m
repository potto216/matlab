%This function will compute the index values for each mask location in a search region.
%The purpose is to 
%INPUT
%imSearchRegionRaw - the area to search for the mask. 
%imMask - The mask itself.
%
%OUTPUT
%indexSet - The output of the index locations for the mask.  Each column is
%a seperate measure.
function indexSet=calcMaskPositions(imSearchRegionRaw,imMask)

%For maximum generality pad the search region with N-1 border that is the
%mask size to take into account when the mask is any arbitrary value.  This
%could be optimized by trying to prreshrink the mask, but I'm not going to
%bother.
imSearchRegion=zeros(size(imSearchRegionRaw)+2*(size(imMask)-1));
imSearchRegion(size(imMask,1):(size(imMask,1)+size(imSearchRegionRaw,1)-1),size(imMask,2):(size(imMask,1)+size(imSearchRegionRaw,2)-1))=imSearchRegionRaw;
[regionRow, regionColumn]=find(imSearchRegion);
maskCount=sum(imMask(:));
isPositionValid=arrayfun(@(irow,icol) sum(sum(and(imSearchRegion(irow:(irow+size(imMask,1)-1),icol:(icol+size(imMask,2)-1)),imMask)))==maskCount,regionRow, regionColumn);

if false
    %%
    figure; imagesc(imMask)
    
    figure;
    imagesc(imSearchRegion); hold on;
    plot(regionColumn(isPositionValid),regionRow(isPositionValid),'g.')
    axis equal
end

%%
regionPt_rc=[regionRow(isPositionValid) regionColumn(isPositionValid)]';
regionPt_rc=regionPt_rc-repmat(size(imMask)'-1,1,size(regionPt_rc,2));
indexSet=zeros(sum(imMask(:)),size(regionPt_rc,2));
idxPos=1;
for pt_rc=regionPt_rc
    [iRow,iColumn]=find(and(imSearchRegionRaw(pt_rc(1):(pt_rc(1)+size(imMask,1)-1),pt_rc(2):(pt_rc(2)+size(imMask,2)-1)),imMask));
    indexSet(:,idxPos)=sub2ind(size(imSearchRegionRaw),(iRow-1)+pt_rc(1),(iColumn-1)+pt_rc(2));
    idxPos=idxPos+1;
end

if (idxPos~=(size(indexSet,2)+1)) || (size(regionPt_rc,2)~=size(indexSet,2))
    error('Not all of the data was processed')
end


if false
    %%
    f1=figure;
    for pt_idx=indexSet;
        im=double(imSearchRegionRaw);
        im(pt_idx)=3;
        
        if ~isempty(get(f1,'Children'))
            axSave=axis;
        else
            axSave=[];
        end
        
        imagesc(im);
        axis equal
        if ~isempty(axSave)
            axis(axSave);
        end
        colorbar
        refresh;
        pause(0.1)
    end
end