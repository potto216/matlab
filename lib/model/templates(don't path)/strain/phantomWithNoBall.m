% DT = DelaunayTri(rand(100,1),rand(100,1))
% figure; triplot(DT)

%function pdemodel
[pde_fig,ax]=pdeinit;
pdetool('appl_cb',4);
pdetool('snapon','on');
set(ax,'DataAspectRatio',[1 1.0158200980967065 6.2862880886426584]);
set(ax,'PlotBoxAspectRatio',[1 1 1]);
set(ax,'XLim',[-2 2]);
set(ax,'YLim',[-2 2]);
set(ax,'XTick',linspace(-2,2,5));
set(ax,'YTick',linspace(-2,2,5));
pdetool('gridon','on');

% Geometry description:
pdepoly([0 0 1 1], ...
    [0 1 1 0],'P1');
set(findobj(get(pde_fig,'Children'),'Tag','PDEEval'),'String','P1')

% Boundary conditions:
pdetool('changemode',0)

pdesetbd(4,...
    'dir',...
    2,...
    char('1','0','0','1'),...
    char('0','0'))
pdesetbd(3,...
    'neu',...
    2,...
    char('0','0','0','0'),...
    char('0','0'))

pdesetbd(2,...
    'neu',...
    2,...
    char('0','0','0','0'),...
    char('0','-4e4'))
pdesetbd(1,...
    'neu',...
    2,...
    char('0','0','0','0'),...    
    char('0','0'))
%char('0','-1e6*x-4e5'))

% Mesh generation:
setappdata(pde_fig,'Hgrad',1.3);
setappdata(pde_fig,'refinemethod','regular');
setappdata(pde_fig,'jiggle',char('on','mean',''));
pdetool('initmesh')
pdetool('refine')

% PDE coefficients:
pdeseteq(1,...
    char('2*((1.96e11)./(2*(1+(0.3))))+(2*((1.96e11)./(2*(1+(0.3)))).*(0.3)./(1-2*(0.3)))','0','(1.96e11)./(2*(1+(0.3)))','0','(1.96e11)./(2*(1+(0.3)))','2*((1.96e11)./(2*(1+(0.3)))).*(0.3)./(1-2*(0.3))','0','(1.96e11)./(2*(1+(0.3)))','0','2*((1.96e11)./(2*(1+(0.3))))+(2*((1.96e11)./(2*(1+(0.3)))).*(0.3)./(1-2*(0.3)))'),...
    char('0.0','0.0','0.0','0.0'),...
    char('0.0','0.0'),...
    char('1.0','0','0','1.0'),...
    '0:10',...
    '0.0',...
    '0.0',...
    '[0 100]')
setappdata(pde_fig,'currparam',...
    ['1E3';...
    '0.3';...
    '0.0';...
    '0.0';...
    '1.0'])

% Solve parameters:
setappdata(pde_fig,'solveparam',...
    char('0','1098','10','pdeadworst',...
    '0.5','longest','0','1E-4','','fixed','Inf'))

% Plotflags and user data strings:
setappdata(pde_fig,'plotflags',[1 1 1 1 1 1 1 1 0 0 0 1 1 1 0 0 1 1]);
setappdata(pde_fig,'colstring','');
setappdata(pde_fig,'arrowstring','');
setappdata(pde_fig,'deformstring','');
setappdata(pde_fig,'heightstring','');

% Solve PDE:
pdetool('solve')

%u = get(findobj(pde_fig,'Tag','PDEPlotMenu'),'UserData');





return
%%
skipMaskVideo=true;
vid=vopen(['finiteElementSim.gif'],'w',1,{'gif','DelayTime',1},skipMaskVideo);

np=size(p,2);
scaleStep=20e3;
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
    title(['Finite Element Simulation of pressure on homogenous material.  Step=' num2str(ii)]);
    axis([-0.2 1.2 0 1.2])
    
    
    vid=vwrite(vid,gca,'handle');
%     subplot(1,4,3);
%     plot(pmove(1,:), pmove(2,:),'b.')
    pause(1)
    refresh
end
vid=vclose(vid);



%% Save the data
%The block is bounded [0,1] for x and y and in z [0 .1]
objPhantom.pointArray=pointArray;
objPhantom.pointArray(3,:,:)=repmat(0.1*rand(1,size(pointArray,2)),[1 1 size(pointArray,3)])
save('phantomFiniteElement.mat','objPhantom');
%pdemesh(p+20*[u(1:np) u(np+1:np+np)]',e,t)