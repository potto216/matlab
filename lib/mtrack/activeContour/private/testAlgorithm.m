clear all
close all

%% The image filtering can be done first because this will not change with
%the image
skipVideo=false;
vidAll=vopen('snakeAll.gif','w',1,{'gif','DelayTime',1},skipVideo);
vidOpt=vopen('snakeOpt.gif','w',1,{'gif','DelayTime',1},skipVideo);

im=mean(double(imread('testImage1.png')),3);
[im hd]=uread('W:\MTrP_Ultrasonix_Data_GMU\MTRP069_V3\02-21-2013-Generic\12-16-19.b8',4);

if false
    %%get user input
    [selx, sely, buttonChoice]=ginput(5);
    vBase_rc=fix([sely(:) selx(:)])';
else
    %testImage1.png
    selx = [  94.2880   156.8134   238.2143  297.2005  393.9378];
    sely = [ 204.8509   177.9035   204.8509  234.7924  252.7573]+15;
    nMagdFract=4;
    
%     %12-16-19.b8
     selx = [ 23.0174  116.0401  237.1172  340.4758  463.7678];
     sely = [ 72.8503   71.6395   74.0612   72.2449   72.2449]+7;
      nMagdFract=10;
    
    vBase_rc=fix([sely(:) selx(:)])';
end



imFiltered=imfilter(im,fspecial('gaussian', 5,0.5));
figure;
imagesc(imFiltered); colormap(gray(256));
[imDx,imDy] = gradient(imFiltered);
imGradientMag=sqrt(imDx.^2+imDy.^2);


%Now for the selected vertices compute the the derivative, distance and
% all at once
vDeltaBase_rc=(diff(vBase_rc,1,2));
vDeltaAbsBase_rc=abs(vDeltaBase_rc);
d=mean(sqrt(sum(vDeltaAbsBase_rc.^2,1)));

M=mean(imGradientMag(:));


%break out each pair.  For each pair then compute the normal direction to
%the tangent.  This will be fixed between iteration
t_rc=vBase_rc(:,3:end)-vBase_rc(:,1:end-2);
n_rc=[0 -1; 1 0]*t_rc;
nNorm_rc=n_rc./([1;1]*sqrt(sum(n_rc.^2,1)));
nMag=d/nMagdFract;  %the height of the normal


hold on;
plot(vBase_rc(2,:),vBase_rc(1,:),'r.');
plot([1;1]*vBase_rc(2,1:end-2)+[0;1]*t_rc(2,:) ,[1;1]*vBase_rc(1,1:end-2)+[0;1]*t_rc(1,:),'g');
plot([1;1]*vBase_rc(2,2:end-1)+[0;nMag]* nNorm_rc(2,:) ,[1;1]*vBase_rc(1,2:end-1)+[0;nMag]* nNorm_rc(1,:),'b');

f1=figure;





totalSlices=7;
%% In parallel we will run all the test cases


nScale=linspace(-nMag/4,nMag/4,totalSlices);  %this should be odd so zero is evaluated
nHyp_rc=cell2mat(reshape(arrayfun(@(s) s*nNorm_rc,nScale,'UniformOutput',false),1,1,length(nScale)));



optimization.inSum=zeros(length(vBase_rc)-2,length(nHyp_rc));
optimization.outSum=zeros(length(vBase_rc)-2,length(nHyp_rc));
optimization.totalMaskElements=zeros(length(vBase_rc)-2,length(nHyp_rc));
optimization.maxIntensity=zeros(length(vBase_rc)-2,length(nHyp_rc));
optimization.dif=zeros(length(vBase_rc)-2,length(nHyp_rc));
optimization.energyBand=zeros(length(vBase_rc)-2,length(nHyp_rc));
optimization.energySum=zeros(1,length(nHyp_rc));

nHypIndexBaseLine=find(abs(nScale-0)<1e-5);
for tt=1:10
    disp(['Iteration ' num2str(tt) ' using v = ']);
    disp(num2str(vBase_rc));
    
    optimization(tt).inSum=zeros(length(vBase_rc)-2,length(nHyp_rc)); %#ok<*SAGROW>
    optimization(tt).outSum=zeros(length(vBase_rc)-2,length(nHyp_rc));
    optimization(tt).totalMaskElements=zeros(length(vBase_rc)-2,length(nHyp_rc));
    optimization(tt).maxIntensity=zeros(length(vBase_rc)-2,length(nHyp_rc));
    optimization(tt).dif=zeros(length(vBase_rc)-2,length(nHyp_rc));
    optimization(tt).energyBand=zeros(length(vBase_rc)-2,length(nHyp_rc));
    optimization(tt).energySum=zeros(1,length(nHyp_rc));
    
    
    vDeltaBase_rc=(diff(vBase_rc,1,2));
    vDeltaAbsBase_rc=abs(vDeltaBase_rc);
    d=mean(sqrt(sum(vDeltaAbsBase_rc.^2,1)));
    
    M=mean(imGradientMag(:));
    
    
    %break out each pair.  For each pair then compute the normal direction to
    %the tangent.  This will be fixed between iteration
    t_rc=vBase_rc(:,3:end)-vBase_rc(:,1:end-2);
    n_rc=[0 -1; 1 0]*t_rc;
    nNorm_rc=n_rc./([1;1]*sqrt(sum(n_rc.^2,1)));
    nMag=d/nMagdFract;  %the height of the normal
    
    
    vertexList=[2:(size(vBase_rc,2)-1); 3:(size(vBase_rc,2))];
    nScale=linspace(-nMag/4,nMag/4,totalSlices);  %this should be odd so zero is evaluated
    nHyp_rc=cell2mat(reshape(arrayfun(@(s) s*nNorm_rc,nScale,'UniformOutput',false),1,1,length(nScale)));
    
    for nHypIndex=1:length(nHyp_rc)
        
        v_rc=[vBase_rc(:,1) (vBase_rc(:,2:(end-1))+nHyp_rc(:,:,nHypIndex)) vBase_rc(:,end)];
        
        
        
        polyInRegion_rc=zeros(2,size(v_rc(:,2:end-1),2),4);
        
        %bottom,left
        polyInRegion_rc(:,:,1)=[v_rc(:,2:end-1)];
        
        %top,left
        polyInRegion_rc(:,:,2)=v_rc(:,2:end-1)+nMag*nNorm_rc;
        
        %top,right
        polyInRegion_rc(:,:,3)=v_rc(:,3:end)+nMag*nNorm_rc;
        
        
        %bottom,right
        polyInRegion_rc(:,:,4)=v_rc(:,3:end);
        polyInRegion_rc=permute(polyInRegion_rc,[1 3 2]);
        
        
        polyOutRegion_rc=zeros(2,size(v_rc(:,2:end-1),2),4);
        %top,left
        polyOutRegion_rc(:,:,1)=[v_rc(:,2:end-1)];
        
        %bottom,left
        polyOutRegion_rc(:,:,2)=v_rc(:,2:end-1)-nMag*nNorm_rc;
        
        %bottom,right
        polyOutRegion_rc(:,:,3)=v_rc(:,3:end)-nMag*nNorm_rc;
        
        
        %top,right
        polyOutRegion_rc(:,:,4)=v_rc(:,3:end);
        
        
        polyOutRegion_rc=permute(polyOutRegion_rc,[1 3 2]);
        
        [meshColumn,meshRow]=meshgrid(1:size(imFiltered,2),1:size(imFiltered,1));
        
        %% build the masks
        activeContour=[];
        for ii=1:size(polyInRegion_rc,3)
            activeContour(ii).vertexList=vertexList(:,ii);
            activeContour(ii).nNorm_rc=nNorm_rc(ii);
            activeContour(ii).nMag=nMag;
            activeContour(ii).inRegion.mask = reshape(inpolygon(meshColumn(:),meshRow(:),polyInRegion_rc(2,:,ii),polyInRegion_rc(1,:,ii)),size(imFiltered,1),size(imFiltered,2));
            activeContour(ii).inRegion.rectangle_rc=squeeze(polyInRegion_rc(:,:,ii));
            
            activeContour(ii).outRegion.mask = reshape(inpolygon(meshColumn(:),meshRow(:),polyOutRegion_rc(2,:,ii),polyOutRegion_rc(1,:,ii)),size(imFiltered,1),size(imFiltered,2));
            activeContour(ii).outRegion.rectangle_rc=squeeze(polyOutRegion_rc(:,:,ii));
            
            
        end
        
        %% Perform the region evaluation
        
        for ii=1:length(activeContour)
            activeContour(ii).nNorm_rc=nNorm_rc(ii);
            linspace(activeContour(ii).nMag,activeContour(ii).nMag,11)
            
            
            totalMaskElements=sum(activeContour(ii).inRegion.mask(:));
            maxIntensity=max(imFiltered(:));
            inSum=sum(imFiltered(activeContour(ii).inRegion.mask));
            outSum=sum(imFiltered(activeContour(ii).outRegion.mask));
            penaltyValue=2;
            dif = 1/(totalMaskElements*maxIntensity)*(inSum-outSum);
            
            activeContour(ii).result.inSum=inSum;
            activeContour(ii).result.outSum=outSum;
            activeContour(ii).result.totalMaskElements=totalMaskElements;
            activeContour(ii).result.maxIntensity=maxIntensity;
            activeContour(ii).result.dif=dif;
            if dif<0
                activeContour(ii).result.energyBand=penaltyValue;
            else
                activeContour(ii).result.energyBand=1-dif;
            end
            
            
            optimization(tt).inSum(ii,nHypIndex)=activeContour(ii).result.inSum;
            optimization(tt).outSum(ii,nHypIndex)=activeContour(ii).result.outSum;
            optimization(tt).totalMaskElements(ii,nHypIndex)=activeContour(ii).result.totalMaskElements;
            optimization(tt).maxIntensity(ii,nHypIndex)=activeContour(ii).result.maxIntensity;
            optimization(tt).dif(ii,nHypIndex)=activeContour(ii).result.dif;
            optimization(tt).energyBand(ii,nHypIndex)=activeContour(ii).result.energyBand;
        end
        
        
        
        
        
        %% Perform the energy calculations
        [ energyInternal, energyExternal, energyExternalAdjusted ] = optFun(  v_rc, imGradientMag,arrayfun(@(d) d.result.energyBand,activeContour),d,M );
        energyTotal=energyExternalAdjusted+energyInternal;
        optimization(tt).energySum(nHypIndex)=sum(energyTotal);
        
        
        %%
        figure(f1);
        set(f1,'Position',[12 195 1226 755])
        subplot(2,2,[1 2])
        imagesc(repmat(uint8(imFiltered),[1 1 3]));
        hold on;
        plot(v_rc(2,:),v_rc(1,:),'y.','MarkerSize',20);
        
        
        for ii=1:length(activeContour)
            subplot(2,2,[1 2])
            polyIn=activeContour(ii).inRegion.rectangle_rc;
            polyOut=activeContour(ii).outRegion.rectangle_rc;
            
            plot([polyIn(2,:) polyIn(2,1)],[polyIn(1,:) polyIn(1,1)],'g','LineWidth',2);
            plot([polyOut(2,:) polyOut(2,1)],[polyOut(1,:) polyOut(1,1)],'r:','LineWidth',2);
             plot(v_rc(2,:),v_rc(1,:),'y.','MarkerSize',20);
            title(['Iteration ' num2str(tt) ' hyp = ' num2str(nHypIndex) ' scale = ' num2str(nScale(nHypIndex)) ]);
            %
            %         subplot(2,2,3)
            %         imagesc(activeContour(ii).inRegion.mask)
            %         title(['In region.  Sum = ' num2str(activeContour(ii).result.inSum)]);
            %
            %         subplot(2,2,4)
            %         imagesc(activeContour(ii).outRegion.mask)
            %         title(['Out region.  Sum = ' num2str(activeContour(ii).result.outSum)]);
            %
            %
        end
        subplot(2,2,3)
        imagesc(optimization(tt).energyBand)
        colormap(jet(256)); colorbar;
        title('Energy Band')
        xlabel('Hypothesis #')
        ylabel('Region #')
        
        subplot(2,2,4)
        plot(energyInternal,'bo-');
        hold on
        plot(energyExternal,'ro-');
        plot(energyExternalAdjusted,'go-');
        plot(energyTotal,'kx-');
        hold off
        xlabel('vertex #');
        ylabel('Energy')
        legend('Internal','External','External Adjusted','Total','Location','SouthWest');
        title('Snake Energies');
        
    
        if nHypIndex~=length(nHyp_rc)
            vidAll=vwrite(vidAll,gca,'handle');
        else
            %Don't write otherwise get a dup frame
        end
        
        if nHypIndexBaseLine==nHypIndex
                vidOpt=vwrite(vidOpt,gca,'handle');
        else
            %do nothing
        end
        
    end
    
    [minValue,minIndex]=min(optimization(tt).energyBand,[],2);
    
    vBase_rc=[vBase_rc(:,1) (vBase_rc(:,2:(end-1))+[nHyp_rc(:,1,minIndex(1)) nHyp_rc(:,2,minIndex(2)) nHyp_rc(:,3,minIndex(3))]) vBase_rc(:,end)];
    figure(f1);
    subplot(2,2,3)
    hold on
    gg=plot(minIndex,[1:3],'rx','LineWidth',3,'MarkerSize',20);
    hold off
    
    vidAll=vwrite(vidAll,gca,'handle');

    
end


vidAll=vclose(vidAll);
vidOpt=vclose(vidOpt);




% %bottom
% plot([1;1]*v_rc(2,2:end-1)+[0;1]* vDelta_rc(2,2:end) ,[1;1]*v_rc(1,2:end-1)+[0;1]* vDelta_rc(1,2:end),'g');
%
% %left
% plot([1;1]*v_rc(2,2:end-1)+[0;nMag]* nNorm_rc(2,:) ,[1;1]*v_rc(1,2:end-1)+[0;nMag]* nNorm_rc(1,:),'b');
%
% %top
% plot([1;1]*v_rc(2,2:end-1)+[0;1]* vDelta_rc(2,2:end)+[nMag;nMag]* nNorm_rc(2,:) ,[1;1]*v_rc(1,2:end-1)+[0;1]* vDelta_rc(1,2:end)+[nMag;nMag]* nNorm_rc(1,:),'g');
%
% %right
% plot([1;1]*v_rc(2,3:end)+[0;nMag]* nNorm_rc(2,:) ,[1;1]*v_rc(1,3:end)+[0;nMag]* nNorm_rc(1,:),'b');