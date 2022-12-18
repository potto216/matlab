%dorsiflexion goes from a large angle to a small angle.  The smallest
%angle magnitude would be the max dorsiflexion velocity and the largest
%angle would be the min velocity.  This would look like a slope starting in the
%lower left and going to the upper right. So slope goes from large angle to small
%angle.  The reverse is true for plantarflexion.

function guiMarkMotionTrackDorPlant(src,evnt,caseFile) %#ok<INUSL>
persistent dorsiflexion plantarflexion


switch lower(evnt.Character)
    case 'd'
        [gx gy]=ginput(2);
        plot(gx,gy,'g','lineWidth',2);
        plot(gx,gy,'gx','lineWidth',2);
        text(mean(gx),mean(gy),num2str(diff(gy)/diff(gx)),'Color',[0 0 0]);
        dorsiflexion(1,end+1)=gx(1);
        dorsiflexion(2,end)=gy(1);
        dorsiflexion(1,end+1)=gx(2);
        dorsiflexion(2,end)=gy(2);
    case 'p'
        [gx gy]=ginput(2);
        plot(gx,gy,'y','lineWidth',2);
        plot(gx,gy,'yx','lineWidth',2);
        text(mean(gx),mean(gy),num2str(diff(gy)/diff(gx)),'Color',[0 0 0]);
        plantarflexion(1,end+1)=gx(1);
        plantarflexion(2,end)=gy(1);
        plantarflexion(1,end+1)=gx(2);
        plantarflexion(2,end)=gy(2);
    case 's'
        motionTrackDorsiflexPlantarFlexDB=getCaseMotionTrackDorsiflexPlantarFlexDB(caseFile);
        trialName=getCaseName(caseFile);
        if isempty(dorsiflexion) &&  isempty(plantarflexion)
            error('Nothing is being saved.');
        else
            motionTrackDorsiflexPlantarFlexDB.(trialName).dorsiflexion=dorsiflexion;
            motionTrackDorsiflexPlantarFlexDB.(trialName).plantarflexion=plantarflexion;         %#ok<STRNU>
            setCaseMotionTrackDorsiflexPlantarFlexDB(caseFile,motionTrackDorsiflexPlantarFlexDB);
            
            dorsiflexion=[];
            plantarflexion=[];
            close(src);
        end
    otherwise
        return;
end




end