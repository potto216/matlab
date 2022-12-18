classdef SubjectPlot  < handle
    %SubjectPlot  This class provides a common way to plot subject related
    %data.  The advanatge of a class is that filters can be applied
    %whichcarry over to other plots
    
    properties  (GetAccess = public, SetAccess = private)
        subject=[];
    end
    
    methods (Access=public)
        %The constructor
        function obj=SubjectPlot(subject)
            obj.subject=subject;
        end
        
        
        function [figList]=plotData(this,titleStr)
            markerList={'.','x','o'};
            
            
            fieldNames=fieldnames(this.subject(1).data);
            
            if length(markerList) < length(this.subject(1).data.(fieldNames{1}).value)
                error('Not enough markers to support the total subjects');
            end
            
            
            figList=zeros(length(fieldNames),1);
            for ff=1:length(fieldNames)
                figList(ff)=figure;
                for ss=1:length(this.subject)                    
                    for dd=1:length(this.subject(ss).data.(fieldNames{ff}).value)
                        dataToPlot=this.subject(ss).data.(fieldNames{ff}).value{dd};
                        spacing=0.1;
                        centerOffset=spacing*length(this.subject(ss).data.(fieldNames{ff}).value)/2;
                        plot((spacing*dd-centerOffset)+this.subject(ss).label.value*ones(size(dataToPlot)), ...
                            dataToPlot,markerList{dd});
                        hold on;
                    end
                    %assumes mri is at the end
                    text((spacing*(1+dd)-centerOffset)+this.subject(ss).label.value, ...
                        mean(this.subject(ss).data.(fieldNames{ff}).value{end}), ...
                        ['ROI=' num2str(this.subject(ss).mriRoi)],'Color',[1 0 0]);
                end
                
                legend('Average US displacement velocity','Average US velocity', 'Average MRI');
                title([titleStr ' ' fieldNames{ff}],'interpreter','none');
                
                xlabel('Subject');
                ylabel('velocity (mm/sec)');
            end
            
            
        end
        
        
        
        
        
        %         mean(dataTable( ultrasound.averageVelocityFromVelocity_mmPerSec.row,idxUltrasound)); ...
        %         std(dataTable( ultrasound.averageVelocityFromVelocity_mmPerSec.row,idxUltrasound)); ...
        %         mean(mridataTable( mri.flexion.row,idxMri)); ...
        %         std(mridataTable( mri.flexion.row,idxMri))];
        %
        %
        %     summary.flexion(:,end+1)=[mean(dataTable( ultrasound.averageVelocityFromVelocity_mmPerSec.row,idxUltrasound)); ...
        %         std(dataTable( ultrasound.averageVelocityFromVelocity_mmPerSec.row,idxUltrasound)); ...
        %         mean(mridataTable( mri.flexion.row,idxMri)); ...
        %         std(mridataTable( mri.flexion.row,idxMri))];
        
        %
        %     figure(figFlexion)
        %     hold on
        %     plot(subjectList(ss)*ones(1,sum(idxUltrasound))-0.1,dataTable( ultrasound.averageVelocityFromDisplacement_mmPerSec.row,idxUltrasound),[colorList{ss} '.'])
        %     plot(subjectList(ss)*ones(1,sum(idxUltrasound)),dataTable( ultrasound.averageVelocityFromVelocity_mmPerSec.row,idxUltrasound),[colorList{ss} 'x'])
        %     plot(subjectList(ss)*ones(1, sum(idxMri))+0.1,mridataTable( mri.flexion.row,idxMri),[colorList{ss} 'o'])
        %
        %     %plot extension
        %     idxUltrasound=(dataTable(ultrasound.subject.row,:)==subjectList(ss)) &  (dataTable(ultrasound.isFlexion.row,:)==false);
        %     idxMri=(mridataTable(mri.subject.row,:)==subjectList(ss));
        %
        %     summary.extension(:,end+1)=[mean(dataTable( ultrasound.averageVelocityFromVelocity_mmPerSec.row,idxUltrasound)); ...
        %         std(dataTable( ultrasound.averageVelocityFromVelocity_mmPerSec.row,idxUltrasound)); ...
        %         mean(mridataTable( mri.extension.row,idxMri)); ...
        %         std(mridataTable( mri.extension.row,idxMri))];
        %
        %     figure(figExtension)
        %     hold on
        %     plot(subjectList(ss)*ones(1,sum(idxUltrasound))-0.1,dataTable( ultrasound.averageVelocityFromDisplacement_mmPerSec.row,idxUltrasound),[colorList{ss} '.'])
        %     plot(subjectList(ss)*ones(1,sum(idxUltrasound)),dataTable( ultrasound.averageVelocityFromVelocity_mmPerSec.row,idxUltrasound),[colorList{ss} 'x'])
        %     plot(subjectList(ss)*ones(1, sum(idxMri))+0.1,mridataTable( mri.extension.row,idxMri),[colorList{ss} 'o'])
        %
        
        
        
        
        function plotValueVsValue(this,valueIndexToUse)
            markerList={'.','x','o'};
            
            
            fieldNames=fieldnames(this.subject(1).data);
            
            if length(markerList) < length(this.subject(1).data.(fieldNames{1}).value)
                error('Not enough markers to support the total subjects');
            end
            
            
            figList=figure;
            centerPtList=zeros(2,length(fieldNames)*length(this.subject));
            
            
            for ff=1:length(fieldNames)
                
                for ss=1:length(this.subject)
                    
                    %there maynot be the same number of points
                    dataToPlot=arrayfun(@(ii) reshape(this.subject(ss).data.(fieldNames{ff}).value{ii},1,[]),valueIndexToUse,'UniformOutput',false);
                    
                    centerPt=cellfun(@(x) mean(x), dataToPlot);
                    centerPtList(:,(ff-1)*length(this.subject)+ss)=centerPt(:);
                    stdPt=cellfun(@(x) std(x), dataToPlot)
                    
                    plot([(centerPt(1)-stdPt(1));(centerPt(1)+stdPt(1))], [centerPt(2);centerPt(2)] );
                    hold on;
                    plot([centerPt(1);centerPt(1)], [(centerPt(2)-stdPt(2));(centerPt(2)+stdPt(2))]);
                    plot(dataToPlot{1},centerPt(2)*ones(size(dataToPlot{1})),'r.');
                    plot(centerPt(1)*ones(size(dataToPlot{2})),dataToPlot{2},'r.');
                    
                end
            end
            
            xlabel(this.subject(ss).data.(fieldNames{ff}).label.value{valueIndexToUse(1)});
            ylabel(this.subject(ss).data.(fieldNames{ff}).label.value{valueIndexToUse(2)});
            
            slope=centerPtList(1,:)'\centerPtList(2,:)';
            xLine=[min(centerPtList(1,:)) max(centerPtList(1,:))];
            hFit=plot(xLine,slope*xLine,'g','linewidth',2);
            residuals=slope*centerPtList(1,:)-centerPtList(2,:);
            
            SSE = sum((residuals).^2);              % Error sum of squares.
            
            TSS = sum((centerPtList(2,:)-mean(centerPtList(2,:))).^2);     % Total sum of squares.
            rRsq=1 - SSE./TSS;            % R-square statistic.
            
            text(0,0,['m = ' num2str(slope,'%1.2f') ' R^2=' num2str(rRsq,'%1.2f')]);
        end
    end
    
    
end
%
% %% Show final Flexion and Extension summary
% figure;
%
% plot([(centerPt(1,:)-stdPt(1,:));(centerPt(1,:)+stdPt(1,:))], [centerPt(2,:);centerPt(2,:)] )
% hold;
% plot([centerPt(1,:);centerPt(1,:)], [(centerPt(2,:)-stdPt(2,:));(centerPt(2,:)+stdPt(2,:))] )
% plot([centerPt(1,:); centerPt(1,:)], [centerPt(2,:); centerPt(2,:)],'o' )
%
% centerPt=[summary.extension(1,:);summary.extension(3,:)];
% stdPt=[summary.extension(2,:); summary.extension(4,:) ];
%
% plot([(centerPt(1,:)-stdPt(1,:));(centerPt(1,:)+stdPt(1,:))], [centerPt(2,:);centerPt(2,:)] )
% plot([centerPt(1,:);centerPt(1,:)], [(centerPt(2,:)-stdPt(2,:));(centerPt(2,:)+stdPt(2,:))] )
% plot([centerPt(1,:); centerPt(1,:)], [centerPt(2,:); centerPt(2,:)],'o' )
% axis equal
% xlabel('Ultrasound (mm/sec)')
% ylabel('MRI (mm/sec)')
% title('Flexion/Extension');
%
% %% Show final Extension summary
% centerPt=[summary.extension(1,:);summary.extension(3,:)];
% stdPt=[summary.extension(2,:); summary.extension(4,:) ];
% figure;
%
% plot([(centerPt(1,:)-stdPt(1,:));(centerPt(1,:)+stdPt(1,:))], [centerPt(2,:);centerPt(2,:)] )
% hold;
% plot([centerPt(1,:);centerPt(1,:)], [(centerPt(2,:)-stdPt(2,:));(centerPt(2,:)+stdPt(2,:))] )
% plot([centerPt(1,:); centerPt(1,:)], [centerPt(2,:); centerPt(2,:)],'o' )
% axis equal
% xlabel('Ultrasound (mm/sec)')
% ylabel('MRI (mm/sec)')
% title('Extension');
%
% end
%
% end
%


