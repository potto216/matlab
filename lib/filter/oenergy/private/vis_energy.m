% vis_data

close all; clear; 

% dataDir = 'P1/1 Grasp/';
% dataDir = 'P1/3 GraspWR/';
dataDir = 'P1/4 Rotation180/';


% type = '1_Grasp'; fname = '17-02-19.b8';
% type = '3_GraspWR'; fname = '17-03-42.b8';
type = '4_Rotation180'; fname = '17-04-03.b8';

[frames, header] = uread([dataDir fname],[]);

[xdim, ydim, nframes] = size(frames);

f1 = figure; 
f2 = figure; 
for i=1:nframes  
    im = frames(:,:,i); 
    i
    % imagesc(im); 
    [oe2D,zcrs,par,FIo,FIe,FBo,FBe] = orientEnergy2D(im);
    oe = sum(oe2D,3);
    [oem,max_id] = max(FIo.^2+FIe.^2,[],3);
    oe = oe / max(oe(:));
    oe = oe*254;
    % oe_eq = histeq(oe); 
    
    figure(f1);
    imagesc(oe); axis image; 
    oe_eq = oe; 
    
    imname = ['im_' num2str(i) '_' type '.jpg'];
    oename = ['oe_' num2str(i) '_' type '.jpg'];
    imwrite(im,imname,'jpg');
    oe_im(:,:,1) = oe_eq; 
    oe_im(:,:,2) = oe_eq; 
    oe_im(:,:,3) = oe_eq; 
    % imagesc(oe_im); 
    map = colormap; 
    imwrite(oe_eq,map,oename,'jpg');
    
    figure(f2);
    imagesc(im); axis image;
    map = colormap; 
    imwrite(im,map,imname,'jpg');
    
    pause(0.2);
    clf(f1); clf(f2); 
end;