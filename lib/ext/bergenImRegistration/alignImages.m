function [M, imOut] = alignImages(im1, im2, iterations, levels, model, option, mask)
% [M, IMOUT] = ALIGNIMAGES(IM1, IM2, ITERATIONS, LEVELS, MODEL, OPTION, MASK)
% IM1, IM2     MxN image arrays
% MODEL        Motion models, 'translation', 'rigid', 'affine',
%              'projective' (Default 'projective')
% ITERATIONS   Number of iterations per pyramid level (Default 4)
% LEVELS       Number of Pyramid Levels (Default 4);
% MASK         MxN binary array. Place zeros for out of segment places,
%              ones for in segment (Default ones(size(im1,1), size(im1,2)))
% OPTION       Robust alignment 1, ordinary alignment 0 (Default 0)
% 
% (NOTE Order of parameter input is important, so you cannot provide number of
% levels while omitting number of iterations)
%
% [1] Bergen et al., 'Hierarchicial Model-Based Motion Estimation', Proceedings
% of the Second European Conference on Computer Vision, pp. 237-252, 1992.
if ~isreal(im1)
    error('im1 must only have real values')
end

if ~isreal(im2)
    error('im2 must only have real values')
end

if(~exist('option'))
    option = 0;
end

if(~exist('mask'))
    mask = ones(size(im1,1), size(im1,2));
end

if(~exist('model'))
    model = 'projective';
end

if(~exist('iterations'))
    iterations = 4;
end

if(~exist('levels'))
    levels = 4;
end

% Prepare mask
Nmask = zeros(size(im1,1)*size(im1,2),1);
Nmask(:) = NaN;
[p] = find(mask(:)==1);
Nmask(p) = 1;
Nmask = reshape(Nmask, size(im1,1), size(im1,2));

% Mask first image
pic2 = Nmask.*im2;
pic1 = im1;

% Create Pyramid
[fig1, fig2] = createPyramid(pic1,pic2, levels);

Minitial = eye(3);
for x = 1:levels
    
    Minitial(1:2,3)=Minitial(1:2,3)*2;
    
    ima1 = fig1(levels-x+1).im;
    ima2 = fig2(levels-x+1).im;
    
    % Choose Affine
    if(model(1) == 'p')
        M = estProjIter2(ima1,ima2,iterations,Minitial,option);
    end
        
    % Choose Affine
    if(model(1) == 'a')
        M = estAffineIter2(ima1,ima2,iterations,Minitial);
    end
    
    % Choose Rigid
    if(model(1) == 'r')
        M = estRigidIter2(ima1,ima2,iterations,Minitial);
    end
    
    % Choose Translation
    if(model(1) == 't')
        M = estTranslationIter2(ima1,ima2,iterations,Minitial);
    end

    Minitial = M;
    
end

imOut = warpProjective2(im2,Minitial);