%Written by Hailin Jin and Paolo Favaro
%Copyright (c) Washington University, 2001
%All rights reserved
%Last updated 10/18/2001
%function [xtt,Qtt,goodfeat] = TKTrack(Ii,Ipi,SampleSize,xt,goodfeat)
%xt is a 2xN matrix
%goodfeat is Nx1 vector
%Tomasi-Kanade tracking
%Use Newton-Ralphson
function [xtt,Qtt,goodfeat] = TKTrack(Ii,Ipi,SampleSize,xt,goodfeat)

global resolution winx winy saturation ...
    wintx winty spacing boundary boundary_t ...
    Nmax thresh levelmin levelmax ThreshQ ...
    N_max_feat method;

N = length(find(goodfeat));

wekeep = zeros(N_max_feat,1);		% Initialization
xuu = zeros(2,N_max_feat);		% of the sub-pyramid
Quu = zeros(N_max_feat,1);		%
sub_level = levelmin;			%
maxQ = 0;

SIp = zeros(2*wintx+2-1,2*winty+2-1); %potto, must initialize to prevent not finidng if a point is out of bounds
goodfeatsave = goodfeat; 		% save of all good features

while (sub_level < levelmax + 1) & (N > 0), % The loop on the levels...
	 
  d = zeros(2,N_max_feat); 	        % initial displacement
  div_list = zeros(N_max_feat,1); 	% initialy, no feat diverges
  Residuals = zeros(N_max_feat,1); 	% Resilduals
  ratios = zeros(N_max_feat,1); 	% Resilduals

  for l = sub_level:-1:0,
    %eval(['[nx,ny] = size(',L(l+1,:),');']);
    nx = SampleSize(1,l+1);
    ny = SampleSize(2,l+1);
    v = zeros(2,N_max_feat);
    d = 2*d; 				% scaling of the displacement
    xc  = (xt-1)/(2^l)+1;
    for i=1:N_max_feat,
        
      if goodfeat(i) & (~div_list(i)),  % if it is a good feature...
	
	cIx = xc(1,i); 	                %
	cIy = xc(2,i); 			% Coords. of the point
	crIx = round(cIx); 		% on the initial image
	crIy = round(cIy); 		%
	    
	if (crIx>=3+wintx+boundary_t) & (crIx<=nx-wintx-2-boundary_t) & ...
		  (crIy>=3+winty+boundary_t) & (crIy<=ny-winty-2-boundary_t),
	       
	  itIx = cIx - crIx;
	  itIy = cIy - crIy;
	  if itIx > 0,
	    vIx = [itIx 1-itIx 0]';
	  else
	    vIx = [0 1+itIx -itIx]';
	  end;
	  if itIy > 0,
	    vIy = [itIy 1-itIy 0];
	  else
	    vIy = [0 1+itIy -itIy];
	  end;
	  
	  %       eval(['SI = ',L(l+1,:),...
	  %   ['(crIx-wintx-2:crIx+wintx+2,crIy-winty-2:' ...
	  %	    ' crIy+winty+2);']);
	  SI = Ii(crIx-wintx-2:crIx+wintx+2,crIy-winty-2:crIy+winty+2,l+1);
	  SI = conv2(conv2(SI,vIx,'same'),vIy,'same');
	  SI = SI(2:2*wintx+4,2:2*winty+4);
	  [gy,gx] = gradient(SI);
	  gx = gx(2:2*wintx+2,2:2*winty+2);
	  gy = gy(2:2*wintx+2,2:2*winty+2);
	  a = sum(sum(gx .* gx));
	  b = sum(sum(gx .* gy));
	  c = sum(sum(gy .* gy));
	  SI = SI(2:2*wintx+2,2:2*winty+2);
	  dt = a*c - b^2;
	       
	  v(:,i) = [0;0]; 		% initial flow
	  div = 0; 		% still on the screen
	  compt = 0; 		% no iteration yet
	  v_extra = resolution + 1; % just larger than resolution
	       
	  if l~=0, compt_max = 15; else compt_max = 1; end;
	  
	  while (norm(v_extra) > resolution) & (~div) & (compt<compt_max),
	    
	    cIpx = cIx + d(1,i) + v(1,i); % + extra_m;	% 
	    cIpy = cIy + d(2,i) + v(2,i); % Coords. of the point
	    crIpx = round(cIpx); 	% on the final image
	    crIpy = round(cIpy); 	%
	    
	    if (crIpx>=2+wintx+boundary) & (crIpx<=nx-wintx-1-boundary) & ...
		       (crIpy>=2+winty+boundary) & (crIpy<=ny-winty-1-boundary),
	      
	      itIpx = cIpx - crIpx;
	      itIpy = cIpy - crIpy;
	      
	      if itIpx > 0,
		vIpx = [itIpx 1-itIpx 0]';
	      else
		vIpx = [0 1+itIpx -itIpx]';
	      end;
	      if itIpy > 0,
		vIpy = [itIpy 1-itIpy 0];
	      else
		vIpy = [0 1+itIpy -itIpy];
	      end;
	      
	      %		     eval(['SIp = ',Lp(l+1,:),...
	      %
	      %		 '(crIpx-wintx-1:crIpx+wintx+1,crIpy-winty-1:crIpy+winty+1);']);
	      SIp = Ipi(crIpx-wintx-1:crIpx+wintx+1,crIpy-winty-1:crIpy+winty+1,l+1);
	      SIp = conv2(conv2(SIp,vIpx,'same'),vIpy,'same');
	      SIp = SIp(2:2*wintx+2,2:2*winty+2);
	      
	      gt = SI - SIp;
	      t1 = sum(sum(gt .* gx));
	      t2 = sum(sum(gt .* gy));
	      
	      v_extra = [(c*t1 - b*t2)/dt;(a*t2 - b*t1)/dt];
	      compt = compt + 1;
	      v(:,i) = v(:,i) + v_extra;
	    else
	      div = 1; 		% Feature xtt out of the image
	    end;
	  end;
	  
	  % At that point, if we are at the very last stage, we can
	  % compute the resildual of the feature
	  
	  if (l == 0) 

	    SI = SI - mean(SI(:));
	    SIp = SIp - mean(SIp(:));
	    gt = SI - SIp;
	    
	    Residuals(i) = sqrt(sum(gt(:).^2)/((2*wintx+1)*(2*winty+1)-1));
	    ratios(i) = sum(gt(:).^2)/sum(SI(:).^2);
	    
	  end;
	  
	       
	else
	  div = 1; 		% Feature xt out of the image
	end;
	
	div_list(i) = div_list(i) | div; % Feature out of the image
      end;
    end;
    d = d + v; 			% propagation of the displacement
  end;
  
  xtt = xt + d; 			% induced feature points
	%xtt(:,1) = xtt(:,1); 		% + extra_m;
	% of I(t+1)
   
	%computes the quality vector Qtt from xtt and Ipi
  Qtt = ComputeQuality(Ipi,xtt,goodfeat,wintx,winty);
  % used to test lost tracks!
   
  % on the image I(t+1)
  if 0,
    TF = (Qtt > ThreshQ * Qt) & (~div_list);
    Qttc = Qtt(find(TF));
    Q_max = [Qttc;maxQ];
    if ~method,
      maxQ = max(Q_max);
    else
      maxQ = max(Q_max(find(Q_max<saturation*min(wintx,winty))));
    end;
    TF = TF & (Qtt > thresh*maxQ);
    wekeep = wekeep | TF;
  else % no quality rejection, keep all the features
    TF = (~div_list) & (Qtt > 0) & (Residuals < 18) & (ratios < 2);
    Qttc = Qtt(find(TF));
    Q_max = [Qttc;maxQ];
    if ~method,
      maxQ = max(Q_max);
    else
      maxQ = max(Q_max(find(Q_max<saturation*min(wintx,winty))));
    end;
    TF = TF & (Qtt > thresh*maxQ); 
    wekeep = wekeep | TF;
  end;
   
      
  % We keep the good features
  xuu = xuu + [TF,TF]' .* xtt; % (save them in xuu)
  % We save the qualities
  Quu = Quu + TF .* Qtt; 		% as well (in Quu)
  Nkept = size(find(TF),1);
   
  goodfeat = goodfeatsave & (~wekeep); % For the remaining features,
  N = size(find(goodfeat),1); 	% try the following level.
  
  %if levelmax ~= levelmin,
  %  fprintf(1, 'At level %d, we keep %d features\n',sub_level,Nkept);
  %end;
   
  sub_level = sub_level + 1; 		% Try the folowing depth
   
end; 					% end of the sub_level loop

xtt = xuu;
Qtt = Quu;
goodfeat = wekeep;

% Actualization of goodfeat,
N = size(find(goodfeat)); 		% and N.

