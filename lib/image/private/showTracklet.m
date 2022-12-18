function showTracklet(dataBlockObj,srcAgent,skeletonGetFullPosition,vertexIdList)
            winAdjust=kron(flipud(skeletonGetFullPosition(1:2,:)),[1 1]');
            smallWindow=[-10 10 -10 10];
            
            f1=figure;
            impointDB=struct([]);
            ax=[];
            if size(skeletonGetFullPosition,2)<=4
                subplotSize=[1 size(skeletonGetFullPosition,2)];
            else
                subplotSize=[ ceil(size(skeletonGetFullPosition,2)/4) 4];
            end
            for ii=1:size(skeletonGetFullPosition,2)
                ax(ii)=subplot(subplotSize(1),subplotSize(2),ii);
                imagesc(dataBlockObj.getSlice(skeletonGetFullPosition(3,ii)));
                colormap(gray(256));
                axis square;
                hold on;
                plot(skeletonGetFullPosition(2,ii),skeletonGetFullPosition(1,ii),[ 'g'],'MarkerSize',1,'LineWidth',1);
                impointDB(end+1).obj=impoint(ax(ii),[skeletonGetFullPosition(2,ii),skeletonGetFullPosition(1,ii)]);                
                impointDB(end).obj.setColor('g');
                impointDB(end).id=vertexIdList(ii);
                axis(smallWindow+winAdjust(:,ii)');
                title(['Slice ' num2str(skeletonGetFullPosition(3,ii))]);
            end
      figPosition=get(f1,'Position');
            uicontrol(f1,'Style', 'pushbutton', 'String', 'Save',...
        'Position', [(20) (20) 50 20],...
        'Callback', {@saveNewVertex ,srcAgent,impointDB});
end

function saveNewVertex(hObj,event,srcAgent,impointDB)
            if isempty(impointDB)
                return;
            else
               pointList_xy=cell2mat(arrayfun(@(x) impointDB(x).obj.getPosition',(1:length(impointDB)),'UniformOutput',false));
               pointList_rc=flipud(pointList_xy);
               vertexIdList=[impointDB(1:length(impointDB)).id];
               srcAgent.replaceVertexPoints(vertexIdList,pointList_rc);
               srcAgent.refreshImpointsFromActiveSkeletonVertexList;
            end
end