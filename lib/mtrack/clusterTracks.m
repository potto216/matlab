function [ sourceTrackersToUseIndex ] = clusterTracks(sourceTrackPathDelta_rc, sourceTrackPathDeltaBackward_rc, distanceMeasure )
%CLUSTERTRACKS Summary of this function goes here
%   Detailed explanation goes here

%% Use clustering
distanceMetric=calculateDistance(sourceTrackPathDelta_rc,distanceMeasure);
distanceMetric=permute(distanceMetric,[2 3 1]);
distanceMetric=vecInterpNan(distanceMetric);

distanceMetricBackward=calculateDistance(sourceTrackPathDeltaBackward_rc,distanceMeasure);
distanceMetricBackward=permute(distanceMetricBackward,[2 3 1]);
distanceMetricBackward=vecInterpNan(distanceMetricBackward);

%pdist(distanceMetric')
%                 Z=linkage(distanceMetric','ward','euclidean')
%                 clusterMap.forward.cluster.idx = cluster(Z,'maxclust',3);
clusterMap.forward.kmeans.idx = kmeans(distanceMetric',3);
clusterMap.backward.kmeans.idx = kmeans(distanceMetricBackward',3);
%                measureMatrix=vecMeasure(distanceMetric,'mse');

for ii=1:max(clusterMap.forward.kmeans.idx)
    clusterMap.forward.kmeans.count(ii)=sum(clusterMap.forward.kmeans.idx==ii);
end

for ii=1:max(clusterMap.backward.kmeans.idx)
    clusterMap.backward.kmeans.count(ii)=sum(clusterMap.backward.kmeans.idx==ii);
end

[~, bestForwardClusterIndex]=max(clusterMap.forward.kmeans.count);
[~, bestBackwardClusterIndex]=max(clusterMap.backward.kmeans.count);
sourceTrackersToUseIndex=intersect(find(clusterMap.forward.kmeans.idx==bestForwardClusterIndex),find(clusterMap.backward.kmeans.idx==bestBackwardClusterIndex));

varianceOfTracks=[var(distanceMetric(:,sourceTrackersToUseIndex),[],1); ...
    var(distanceMetricBackward(:,sourceTrackersToUseIndex),[],1)];
[mv, mi]=max(varianceOfTracks,[],2);
varianceOfTracks=varianceOfTracks./repmat(mv,1,size(varianceOfTracks,2));
s1=sort(varianceOfTracks(1,:));
s2=sort(varianceOfTracks(2,:));
%kill the top value if it is too large
if ~isscalar(s1) && ((s1(end)-s1(end-1))>0.4) && (s2(end)-s2(end-1)>0.4) && (mi(1)==mi(2))
    sourceTrackersToUseIndex(mi(1))=[];
else
    %do nothing
end

%if difference between max and next value is greater than
if false
    %% Show cluster plots
    colorList={'r','b','g','c','y'};
    %legendList=cell(length(unique(clusterMap.forward.cluster.idx)),1);
    legendList=cell(length(unique(clusterMap.backward.kmeans.idx)),1);
    figure;
    
    legendList=cell(length(unique(clusterMap.forward.kmeans.idx)),1);
    subplot(1,2,1)
    hold on
    for ii=1:max(clusterMap.forward.kmeans.idx)
        ph=plot(distanceMetric(:,clusterMap.forward.kmeans.idx==ii)*d.fs,colorList{ii});
        legendList(ii)={{ph(1),['cluster ' num2str(ii) ' track#(' num2str(clusterMap.forward.kmeans.count(ii) ) ')']}};
    end
    legend(cellfun(@(x) x{1},legendList),cellfun(@(x) x{2},legendList,'UniformOutput',false))
    title('Forward track');
    xlabel('Sample #');
    ylabel('velocity (mm/sec)')
    
    
    subplot(1,2,2)
    hold on
    for ii=1:max(clusterMap.backward.kmeans.idx)
        %                     ph=plot(distanceMetric(:,clusterMap.forward.cluster.idx==ii),colorList{ii});
        %                     clusterMap.forward.cluster.count(ii)=sum(clusterMap.forward.cluster.idx==ii);
        %                     legendList(ii)={{ph(1),['#(' num2str(clusterMap.forward.cluster.count(ii) ) ')']}};
        
        ph=plot(-flipud(distanceMetricBackward(:,clusterMap.backward.kmeans.idx==ii)*d.fs),colorList{ii});
        legendList(ii)={{ph(1),['cluster ' num2str(ii) ' track#(' num2str(clusterMap.backward.kmeans.count(ii) ) ')']}};
        
    end
    legend(cellfun(@(x) x{1},legendList),cellfun(@(x) x{2},legendList,'UniformOutput',false))
    title('Backward track');
    xlabel('Sample #');
    ylabel('velocity (mm/sec)')
    
end

if false
    %%
    figure;
    subplot(1,2,1)
    plot(distanceMetric(:,sourceTrackersToUseIndex))
    title('Forward track');
    xlabel('Sample #');
    ylabel('velocity (mm/sec)')
    
    subplot(1,2,2)
    plot(distanceMetricBackward(:,sourceTrackersToUseIndex))
    title('Backward track');
    xlabel('Sample #');
    ylabel('velocity (mm/sec)')
end



end

