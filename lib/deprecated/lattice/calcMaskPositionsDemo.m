clear
load(fullfile('E:\Users\dturo\MTrP_Analysis_Images\MTRP002','Case2_visit1_site1_repeat1_mask.mat'))
imSearchRegionRaw=mask.trap;
%imSearchRegion=;
imMask = (fspecial('disk')~=0);

indexSet=calcMaskPositions(imSearchRegionRaw,imMask);

axSave=[];


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
