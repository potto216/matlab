%main tracker script
%Written by Hailin Jin and Paolo Favaro
%Copyright (c) Washington University, 2001
%All rights reserved
%Last updated 10/18/2001
%results are saved in result.mat
%the variables are good featx featy featq

%some modification by Jana Kosecka, GMU 2006

clear all;

%rotating board sequence
%* seq_name = 'imd';
%* number_list = 200:5:250;
%* image_type = 'bmp';
spaces = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interlaced = 0;     % Set to 1, if images are interlaced
bPlot = 1;          % Set to 1 to get graphical output
FigureNumber = 1;   % output figure number
bMovieout = 0;      % Can be used only if bPlot activated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num = 120;
[frames, header] = uread('11-48-19.rf',[0:num],'frameFormatComplex',true);
for i=1:num
    imagesc(abs(frames(:,:,i)).^0.5); colormap gray; 
    pause(0.2);
end

[xdim, ydim, nframes] = size(frames);


number_list = 1:nframes;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global resolution winx winy saturation ...
    wintx winty spacing boundary boundary_t ...
    Nmax thresh levelmin levelmax ThreshQ ...
    N_max_feat method;

resolution = 0.03; 			% Required resolution (for the track, in pixel)
winx = 1; winy = 1;  		% Selection window sizes (size =2*winx+1 x 2*winy+1
saturation = 7000; 			% saturation in Q for selection (win=1)
wintx = 10; winty = 10; 	% Tracking window sizes
spacing = 5;				% min spacing between 2 feats (in pixel).
boundary = 5;				% JK rejected pixels around the screen (selection)
boundary_t = 1;				% rejected pixels around the screen (tracking)
Nmax = 1000;                % max. selected features in selection
thresh = 0.05; 				% Threshold of selection
levelmin = 0; 				% lower level in the pyramid
levelmax = 3;				% higher level in the pyramid
ThreshQ = 0.1;				% Thresh of ejection of a point
					        % through the track
N_max_feat = 500;			% Minimum space reserved for the
					        % feature storage
method = 0;                 % Set to 1 to take into consideration
                            % the saturation (used in selection
					        % and tracking)
oe_flag = 1;                % set to 1 if energy image is to be used                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DimX=5;
DimY=5;

disp('New tracking sequence');

if interlaced,
  disp('Input images interlaced');
else
  disp('Input images non interlaced');
end;
if bPlot,
  disp('Graphical output on');
  if bMovieout,
    disp('Movie on');
  else
    disp('Movie off');
  end;
else
  disp('Graphical output off');
end;

if method,
  disp('Saturation on');
else
  disp('Saturation off');
end;

duration = length(number_list);
opt = sprintf('%%0%dd',spaces);

good = zeros(N_max_feat,duration);
featx = zeros(N_max_feat,duration);
featy = zeros(N_max_feat,duration);
featq = zeros(N_max_feat,duration);

%process the first image
% index = number_list(270);
index = number_list(1);

if oe_flag
    [oe2D,zcrs,par,FIo,FIe,FBo,FBe] = orientEnergy2D(frames(:,:,index));
    oe = sum(oe2D,3);
    [oem,max_id] = max(FIo.^2+FIe.^2,[],3);
    oe = oe / max(oe(:));
    oe = oe*254;
    Ipi(:,:,1) = oe;
else
    Ipi(:,:,1) = frames(:,:,1);
end

[nrow,ncol] = size(Ipi(:,:,1));
SampleSize(:,1) = [nrow;ncol];

fprintf(1,'\n');
% disp(['Feature selection on initial image ' first '...']);

%select feature point from Ipi
%only on the grid points
xtt = SelectFeatures_V0(Ipi);

Nini = size(xtt,2); 			% init # of features
if Nini < N_max_feat,
  xtt = [xtt,zeros(2,N_max_feat-Nini)];
  goodfeat = [ones(Nini,1);zeros(N_max_feat-Nini,1)];
else 
  xtt = xtt(:,1:N_max_feat);
  goodfeat = ones(N_max_feat,1);
end;

%%%%%%%%%%%%%%%%%%%%
%save the first
Ifirst = Ipi(:,:,1);
xttfirst = xtt;
%%%%%%%%%%%%%%%%%%%%

%note that SampleSize is only computed once here
%therefore all the images must have the same size
for ii=1:levelmax,
  % compute downsampled images
  [tt,SampleSize(:,ii+1)] ...
      = DownSample(Ipi(:,:,ii),SampleSize(:,ii));
  Ipi(1:SampleSize(1,ii+1),1:SampleSize(2,ii+1),ii+1) = tt;
end;

fprintf(1, 'On initial image: %d features\n', size(find(goodfeat),1));

Qtt = ComputeQuality(Ipi,xtt,goodfeat,wintx,winty);
%quality_computation; 		% computes the quality vector Qtt from xtt and Ipi used to test lost tracks!

good(:,1) = goodfeat;
featx(:,1) = xtt(1,:)';
featy(:,1) = xtt(2,:)';
featq(:,1) = Qtt;

								
if bPlot,
  % PLOT FIRST IMAGE !!!
  figure(FigureNumber);hold off; clf;
  image(Ipi(:,:,1));colormap(gray(256));
  % axis('equal'); axis([1 ncol 1 nrow]);
  hold on;
  xf = xtt(:,find(goodfeat));
  if size(xf,1) > 0,
    plot(xf(2,:),xf(1,:), 'r+');
  end;
  hold off; drawnow;
end;

%goodfeat = zeros(N_max_feat,1);

%%% MAIN TRACKING LOOP - BELOW
for nbri=(index+1):duration;

  seq = number_list(nbri);
  
  for ii = 1:levelmax+1,
    Ii(:,:,ii) = Ipi(:,:,ii);
  end;
  
  Qt = Qtt;
  xt = xtt;
  
  if oe_flag
      [oe2D,zcrs,par,FIo,FIe,FBo,FBe] = orientEnergy2D(frames(:,:,nbri));
      oe = sum(oe2D,3);
      [oem,max_id] = max(FIo.^2+FIe.^2,[],3);
      oe = oe / max(oe(:));
      oe = oe*254;
      Ipi(:,:,1) = oe;
  else
      Ipi(:,:,1) = frames(:,:,nbri);
  end
  
  % Downsampling images
  for ii = 1:levelmax,
    Ipi(1:SampleSize(1,ii+1),1:SampleSize(2,ii+1),ii+1) ...
	= DownSample(Ipi(:,:,ii),SampleSize(:,ii));
  end;
  
  %track between image Ii and Ipi
  %also their downsampled versions
  %results are in xtt Qtt goodfeat
  [xttnew,Qtt,goodfeat] = TKTrack(Ii,Ipi,SampleSize,xtt,goodfeat);

  good(:,nbri) = goodfeat;
  featx(:,nbri) = xttnew(1,:)';
  featy(:,nbri) = xttnew(2,:)';
  featq(:,nbri) = Qtt;

  xtt = xttnew;
  
  %%%%%%%%%%%%%%%%%  
  
  fprintf(1, 'After track #%d: %d features\n',nbri-1, size(find(goodfeat),1));
  
  %visualization
  if bPlot,
    figure(FigureNumber);
    image(Ipi(:,:,1)); colormap(gray(256));
    % axis('equal'); axis([1 ncol 1 nrow]);
    hold on;
    xf = xtt(:,find(goodfeat));
    if size(xf,1) > 0,
      plot(xf(2,:),xf(1,:), 'r+');
      ind_tracked = find(good(:,nbri-1) & good(:,nbri));
      if length(ind_tracked) > 0,
	plot([featy(ind_tracked,nbri-1),featy(ind_tracked,nbri)]',[featx(ind_tracked,nbri-1),featx(ind_tracked,nbri)]', 'y-');
      end;
    end;
    hold off; drawnow;
    
    if bMovieout,
      Mv(:,nbri-1) = getframe;
    end;
  end;
end;
%%% MAIN TRACKING LOOP - ABOVE

return;
save result good featx featy featq;
