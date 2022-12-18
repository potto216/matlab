function [af,Nroi,Nroix,Nroiy,w] = ProcessROI(Im2,af,roi,roix,roiy,fxd,width,height)

roi=double(roi);
% set up and run the affine flow algorithm
af.regionOfInterest = roi;
af.image2 = Im2;% assign the second image
af = af.findFlow;% Create new affine flow object & compute flow
flow = af.flowStruct; %return results of flow calculation
w = affine_flow.warp(flow); %assign warp matrix to w
af = af.advance;% move image 2 to image 1 in prep for next iteration

% if using a fixed ROI keep it the same
if fxd
    Nroi = roi;
    Nroix = roix;
    Nroiy = roiy;
else % for moving ROI, apply warp to vertices
    ROIpos = [roix,roiy,ones(length(roix),1)] * w;
    % If the ROI reaches the edge of the image,
    % revert to previous values
    for k = 1:size(ROIpos,1)
        if ROIpos(k,1)<1 || ROIpos(k,1)>width
            ROIpos(k,1) = roix(k);
        end
        if ROIpos(k,2)<1 || ROIpos(k,2)>height
            ROIpos(k,2) = roiy(k);
        end
    end
    % assign new ROI
    [Nroi,Nroix,Nroiy] = roipoly(Im2,ROIpos(:,1),ROIpos(:,2));
end
