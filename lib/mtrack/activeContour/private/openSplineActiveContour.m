%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% interate.m implements the core of the snakes (active contours) algorithm.
% It is called by the snk.m file which is the GUI frontend. If you do not
% want to deal with GUI, look at this file and the included comments which
% explain how active contours work.
%
% To run this code with GUI
%   1. Type guide on the matlab prompt.
%   2. Click on "Go to Existing GUI"
%   3. Select the snk.fig file in the same directory as this file
%   4. Click the green arrow at the top to launch the GUI
%
%   Once the GUI has been launched, you can use snakes by
%   1. Click on "New Image" and load an input image. Samples image are
%   provided.
%   2. Set the smoothing parameter "sigma" or leave it at its default value
%   and click "Filter". This will smooth the image.
%   3. As soon as you click "Filter", cross hairs would appear and using
%   them and left click of you mouse you can pick initial contour location
%   on the image. A red circle would appead everywhere you click and in
%   most cases you should click all the way around the object you want to
%   segement. The last point must be picked using a right-click in order to
%   stop matlab for asking for more points.
%   4. Set the various snake parameters (relative weights of energy terms
%   in the snake objective function) or leave them with their default value
%   and click "Iterate" button. The snake would appear and move as it
%   converges to its low energy state.
%
% Copyright (c) Ritwik Kumar, Harvard University 2010
%               www.seas.harvard.edu/~rkkumar
%
% This code implements “Snakes: Active Contour Models” by Kass, Witkin and
% Terzopolous incorporating Eline, Eedge and Eterm energy factors. See the
% included report and the paper to learn more.
%
% If you find this useful, also look at Radon-Like Features based
% segmentation in  the following paper:
% Ritwik Kumar, Amelio V. Reina & Hanspeter Pfister, “Radon-Like Features
% and their Application to Connectomics”, IEEE Computer Society Workshop %
% on Mathematical Methods in Biomedical Image Analysis (MMBIA) 2010
% http://seas.harvard.edu/~rkkumar
% Its code is also available on MATLAB Central
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INPUT
%f1 - is empty it will be created
%vidAll - capture all frames during the optimization process
%vidOpt - capture only the optimized frame output.
function [smth,xs,ys,f1,vidAll,vidOpt] = openSplineActiveContour(image, xs, ys, alpha, beta, gamma, kappa, wl, we, wt, iterations,springK,showGraphics,f1,vidAll,vidOpt)
% image: This is the image data
% xs, ys: The initial snake coordinates.  the input is expected as a column
% vector;
% alpha: Controls tension
% beta: Controls rigidity
% gamma: Step size
% kappa: Controls enegry term
% wl, we, wt: Weights for line, edge and terminal enegy components
% iterations: No. of iteration for which snake is to be moved
xs=xs(:);
ys=ys(:);

if false
    save('fileparms','image', 'xs', 'ys', 'alpha', 'beta', 'gamma', 'kappa', 'wl', 'we', 'wt', 'iterations')
end


%parameters
N = iterations;
smth = image;

useSprings=true;
useLongSnake=true;



% Calculating size of image
[row col] = size(image);


%Computing external forces

eline = smth; %eline is simply the image intensities

[grady,gradx] = gradient(smth);
eedge = -1 * sqrt ((gradx .* gradx + grady .* grady)); %eedge is measured by gradient in the image

%masks for taking various derivatives
m1 = [-1 1];
m2 = [-1;1];
m3 = [1 -2 1];
m4 = [1;-2;1];
m5 = [1 -1;-1 1];

cx = conv2(smth,m1,'same');
cy = conv2(smth,m2,'same');
cxx = conv2(smth,m3,'same');
cyy = conv2(smth,m4,'same');
cxy = conv2(smth,m5,'same');

for ii = 1:row
    for j= 1:col
        % eterm as defined in Kass et al Snakes paper
        eterm(ii,j) = (cyy(ii,j)*cx(ii,j)*cx(ii,j) -2 *cxy(ii,j)*cx(ii,j)*cy(ii,j) + cxx(ii,j)*cy(ii,j)*cy(ii,j))/((1+cx(ii,j)*cx(ii,j) + cy(ii,j)*cy(ii,j))^1.5);
    end
end

%imtool(eterm);
%figure; imagesc(eterm);
% imview(abs(eedge));
eext = (wl*eline + we*eedge -wt * eterm); %eext as a weighted sum of eline, eedge and eterm

[fx, fy] = gradient(eext); %computing the gradient


%initializing the snake
[m n] = size(xs);
[mm nn] = size(fx);

%populating the penta diagonal matrix
if useLongSnake
    mA=3*m;
else
    mA=m;
end
Abig = zeros(mA,mA);
b = [(2*alpha + 6 *beta) -(alpha + 4*beta) beta];
brow = zeros(1,mA);
brow(1,1:3) = brow(1,1:3) + b;
brow(1,mA-1:mA) = brow(1,mA-1:mA) + [beta -(alpha + 4*beta)]; % populating a template row
for ii=1:mA
    Abig(ii,:) = brow;
    brow = circshift(brow',1)'; % Template row being rotated to egenrate different rows in pentadiagonal matrix
end

if false
    [at]=Abig(3,1:5);
    
    Abig(1,1)=at(2)+at(3);
    Abig(1,2)=at(1)+at(4);
    Abig(2,2)=at(1)+at(2);
    
    Abig(end-1,end)=at(4)+at(5);
    Abig(end,end-1)=at(2)+at(5);
    Abig(end,end)=at(3)+at(4);
end

[L U] = lu(Abig + gamma .* eye(mA,mA));
Ainvbig = inv(U) * inv(L); % Computing Ainv using LU factorization
if m~=mA
    ainvStart=[m; m];
    Ainv=Ainvbig((ainvStart(1):(ainvStart(1)+m-1)),(ainvStart(2):(ainvStart(2)+m-1)));
    if false
        idxList=[1:5];
        Ainv(idxList,30:end)=0;
        
        fsearch=@(xStart,idx) abs(1-abs(sum(Ainv(idx,:)/xStart)));
        normAmount=arrayfun(@(idx) fminsearch(@(xmin) fsearch(xmin,idx),1),idxList);
        
        Ainv(idxList,:)=diag(1./normAmount)*Ainv(idxList,:);
        
        
        idxList=[(size(Ainv,2)-5):size(Ainv,2)];
        Ainv(idxList,1:29)=0;
        
        fsearch=@(xStart,idx) abs(1-abs(sum(Ainv(idx,:)/xStart)));
        normAmount=arrayfun(@(idx) fminsearch(@(xmin) fsearch(xmin,idx),1),idxList);
        
        Ainv(idxList,:)=diag(1./normAmount)*Ainv(idxList,:);
    else
        
        %     idxList=(1:size(Ainv,2));
        %
        %     fsearch=@(xStart,idx) abs(1-abs(sum(Ainv(idx,:)/xStart)));
        %     normAmount=arrayfun(@(idx) fminsearch(@(xmin) fsearch(xmin,idx),1),idxList);
        %
        %     Ainv(idxList,:)=diag(1./normAmount)*Ainv(idxList,:);
        %
        Ainv=diag(1./sum(Ainv,2))*Ainv;
        
        
        
    end
else
    Ainv=Ainvbig;
end
% Ainv(1,1:end)=0;  Ainv(1,1)=1;
% Ainv(end,1:end)=0;  Ainv(end,end)=1;

% A(1,end)=0;
% A(end,1)=0;
springStart=[xs(1); ys(1)];
springEnd=[xs(end); ys(end)];

springMaskStart=zeros(1,length(xs));
springMaskStart(1)=1;

springMaskEnd=zeros(1,length(xs));
springMaskEnd(end)=1;

%reassign the figure handle if showing graphics and the figure handle is
%empty or it is assigned, but not valid which generally happens when closed 
if (showGraphics && isempty(f1)) || (~isempty(f1) && ~ishandle(f1))
    f1=figure;
end

if showGraphics && ~isempty(vidAll)
    
    % set(f1,'Position',[ 680   441   827   657])
    
    figure(f1);
    imagesc(image); colormap(gray(256));
    
    hold on;
    plot(springStart(1),springStart(2),'bo')
    plot(springEnd(1),springEnd(2),'bo')
    % plot([xs; xs(1)], [ys; ys(1)], 'r-');
    plot([xs], [ys], 'r-');
    text(100,100,num2str(0),'Color',[1 0 0]);
    hold off;
    
    vidAll=vwrite(vidAll,gca,'handle');
end
%moving the snake in each iteration
for ii=1:N;
    %     springForcesStart=springK*([xs'; ys']-repmat(springStart,1,length(xs))).^2;
    %     springForcesEnd=springK*([xs'; ys']-repmat(springEnd,1,length(xs))).^2;
    
    
    springForcesStart=-2*springK*([xs'; ys']-repmat(springStart,1,length(xs)));
    springForcesEnd=-2*springK*([xs'; ys']-repmat(springEnd,1,length(xs)));
    
    
    if ~useSprings
        ssx = gamma*xs - kappa*interp2(fx,xs,ys);
        ssy = gamma*ys - kappa*interp2(fy,xs,ys);
    else
        %     ssx = gamma*xs - kappa*interp2(fx,xs,ys)+(springForcesStart(1,:).*springMaskStart).'-(springForcesEnd(1,:).*springMaskEnd).';
        %     ssy = gamma*ys - kappa*interp2(fy,xs,ys)+(springForcesStart(2,:).*springMaskStart).'-(springForcesEnd(2,:).*springMaskEnd).';
        %     deltassx=- kappa*interp2(fx,xs,ys)+(springForcesStart(1,:).*springMaskStart).';
        %     deltassy=- kappa*interp2(fy,xs,ys)+(springForcesStart(2,:).*springMaskStart).';
        %
        %     deltassx=- kappa*interp2(fx,xs,ys)+(springForcesEnd(1,:).*springMaskEnd).';
        %     deltassy=- kappa*interp2(fy,xs,ys)+(springForcesEnd(2,:).*springMaskEnd).';
        
        deltassx=(springForcesStart(1,:).*springMaskStart).'+(springForcesEnd(1,:).*springMaskEnd).';
        deltassy=(springForcesStart(2,:).*springMaskStart).'+(springForcesEnd(2,:).*springMaskEnd).';
        
        fxS=interp2(fx,xs,ys);
        fyS=interp2(fy,xs,ys);
        
        if any(isnan(fxS))
            xs=xs;
        end
        
        if any(isnan(fyS))
            xs=xs;
        end
        
        ssx = gamma*xs - kappa*fxS + deltassx;
        ssy = gamma*ys - kappa*fyS + deltassy;
        
        %         disp(num2str(deltassx.'))
        %         disp(num2str(deltassy.'))
        %         disp('-------------');
        
    end
    %     ssx([1 length(ssx)])=xs([1 length(ssx)]);
    %     ssy([1 length(ssy)])=ys([1 length(ssy)]);
    %     %calculating the new position of snake
    
    xsOld=xs;
    ysOld=ys;
    xs = Ainv * ssx;
    ys = Ainv * ssy;
    
    %make sure the points stay in the boundary
    xs(((xs<1) | xs>size(image,2)))=xsOld(((xs<1) | xs>size(image,2)));
    ys(((ys<1) | ys>size(image,2)))=ysOld(((ys<1) | ys>size(image,2)));
    
    delta_xy=[(xs-xsOld)';(ys-ysOld)'];
    rad2deg(angle([1 1j]*delta_xy));
    
    
    if any(isnan(xs))
        error('xs is NaN');
        xs(isnan(xs))=xsOld(isnan(xs));
        
    end
    
    if any(isnan(ys))
        error('ys is NaN');
        ys(isnan(ys))=ysOld(isnan(ys));
    end
    
    correctionF=fit(xs(2:(end-1)),ys(2:(end-1)),'poly2');
    ys(1)=correctionF(xs(1));
    ys(end)=correctionF(xs(end));

    
    %Displaying the snake in its new position
    if showGraphics && ~isempty(vidAll)
        figure(f1);
        imagesc(image); colormap(gray(256));
        
        hold on;
        if distanceRatio( delta_xy,1,size(delta_xy,2))>3
            plot(springStart(1),springStart(2),'ro')
        else
            plot(springStart(1),springStart(2),'bo')
        end
        
        if distanceRatio( delta_xy,size(delta_xy,2),1)>3
            plot(springEnd(1),springEnd(2),'ro')
        else
            plot(springEnd(1),springEnd(2),'bo')
        end
        % plot([xs; xs(1)], [ys; ys(1)], 'r-');
        plot([xs], [ys], 'r-');
        text(100,100,num2str(ii),'Color',[1 0 0]);
        hold off;
        vidAll=vwrite(vidAll,gca,'handle');
    end
    
    
end

if showGraphics && ~isempty(vidOpt)
    figure(f1);
    imagesc(image); colormap(gray(256));
    
    hold on;
  %  plot(springStart(1),springStart(2),'bo')
  %  plot(springEnd(1),springEnd(2),'bo')
    % plot([xs; xs(1)], [ys; ys(1)], 'r-');
    plot([xs], [ys], 'r-');
    text(100,100,num2str(ii),'Color',[1 0 0]);
    hold off;
    vidOpt=vwrite(vidOpt,gca,'handle');
end

end


