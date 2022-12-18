%These are the start coordinates of the row/column position
%templateStart_rc - The template is smaller than the target and is what you
%are looking for
%targetImgStart_rc
function mv = computeMotion(template,target_img,templateStart_rc,targetImgStart_rc)
%%


if ~all(size(template)<=size(target_img))
	error('the target_img must be the same size as or larger than the template')
end

interp_factor_x = 1;
interp_factor_y = 1;


search_x = size(target_img,1);
search_y = size(target_img,2);

template_x = size(template,1);
template_y = size(template,2);

corrl = xcorr2((target_img),(template));

if ~isreal(corrl) 
	corrl = abs(corrl(template_x:search_x,template_y:search_y));
else
	corrl = corrl(template_x:search_x,template_y:search_y);
end

%xcorr2 defaults to a full correlation which has partial values on the edges
%So we need to cut out only the part where there is a full correlation of the values
%This starts where the template fully fits in the correlation and ends where its bottom right hits the bottom 
%right edge of the target image.  This occurs at the max dimension of the target image.


if ~all(size(corrl)==(size(target_img)-size(template)+1))
	error('The cut out correlation matrix size is not the correct value')
end

%because Octave clips the images to [0,1] we have to scale the output
%http://octave.1599824.n4.nabble.com/imresize-incorrectly-clips-output-to-0-1-td1672689.html
corrl_interp = imresize(scaleTo1(corrl),[size(corrl,1)*interp_factor_x,size(corrl,2)*interp_factor_y]);


%mv_tmp represents the 
%[mx1,idx1] = max(corrl_interp);
%[mx2, idx2] = max(mx1);
%mv_tmp = [idx2,idx1(idx2)];



[mxCorr,mxCorrIdx]=max(corrl_interp(:));
[rowIdx,colIdx]=ind2sub(size(corrl_interp),mxCorrIdx);
a = ([rowIdx; colIdx]-1) + targetImgStart_rc(:) ;
b = templateStart_rc(:);



%mv(1) = -((mv_tmp(2) - size(corrl_interp,1)/2)/interp_factor_x);
%mv(2) = -((mv_tmp(1) - size(corrl_interp,2)/2)/interp_factor_y);

mv=-(b-a);

%************DEBUG CODE START***************

global g_debug
if ~isempty(g_debug)
	eval(g_debug.scriptName)
end
%************DEBUG CODE END***************
