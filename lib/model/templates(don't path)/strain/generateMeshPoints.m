clear all;
close all;
phantomList={};
phantomList{end+1}='phantomWithNoBall';
phantomList{end+1}='phantomWithBallNotStiff';
phantomList{end+1}='phantomWithStiffBall';
phantomListScaleStep=[20e3; 0.000000004; 0.000002];
for pp=3:length(phantomList)
    %%
    eval(phantomList{pp});
    %show the mesh
    [p,e,t,u,l,c,a,f,d,b,g] = getpetuc;
    figure; pdemesh(p,e,t)
    
    %% what is this
    
    skipMaskVideo=true;
    vid=vopen(['finiteElementSim.gif'],'w',1,{'gif','DelayTime',1},skipMaskVideo);
    
    np=size(p,2);
    scaleStep=phantomListScaleStep(pp);    
    scale=0;
    pmove=[u(1:np) u(np+1:np+np)]';
    f1=figure;
    
    frameSteps=[1:4:50];
    pointArray=zeros(3,size(p,2),length(frameSteps));
    figure(f1);
    frameIndex=1;
    for ii=frameSteps
        pnew=p+scaleStep*(ii-1)*pmove;
        pointArray(1:2,:,frameIndex)=pnew;
        frameIndex=frameIndex+1;
        %subplot(1,4,[1 2]);
        plot(p(1,:), p(2,:),'b.')
        hold on;
        plot(pnew(1,:), pnew(2,:),'ro')
        hold off
        title([phantomList{pp} ' Simulation of pressure on homogenous material.  Step=' num2str(ii)]);
        axis([-0.2 1.2 0 1.2])
        
        
        vid=vwrite(vid,gca,'handle');
        %     subplot(1,4,3);
        %     plot(pmove(1,:), pmove(2,:),'b.')
        pause(.01)
        refresh
    end
    vid=vclose(vid);
    
    
    
    %% Save the data
    %The block is bounded [0,1] for x and y and in z [0 .1]
    objPhantom.pointArray=pointArray;
    objPhantom.pointArray(3,:,:)=repmat(0.1*rand(1,size(pointArray,2)),[1 1 size(pointArray,3)]);
    save([phantomList{pp} 'FiniteElement.mat'],'objPhantom');
    %pdemesh(p+20*[u(1:np) u(np+1:np+np)]',e,t)
end