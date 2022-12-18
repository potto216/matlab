function showTrack(dataBlockObj, track)
%% Show the image

imBlock=dataBlockObj.blockData;
f1=figure; 
for ii=1:length(track)
    figure(f1); 
    clf
    subplot(2,4,[1 2 5 6])
    imagesc(imBlock(:,:,ii));
    %axis([200 300 200 300])
    colormap(gray(256));
    hold on
    quiver( track(ii).pt_rc(2,:),  track(ii).pt_rc(1,:),track(ii).ptDelta_rc(2,:),  track(ii).ptDelta_rc(1,:), 0.5,'r');    
    title(['Frame ' num2str(ii) ' of ' num2str(length(track))])
    
    motion=complex(track(ii).ptDelta_rc(2,:),track(ii).ptDelta_rc(1,:));
    
    subplot(2,4,3)
    hist(abs(motion));
    title('Hist')
    xlabel('Mag')
    ylabel('Count')
    
    subplot(2,4,4)
    hist(angle(motion));
    title('Hist')
    xlabel('Angle (rad)')
    ylabel('Count')    

     subplot(2,4,[7 8])
    plot([zeros(1,length(motion)); real(motion)],-[zeros(1,length(motion)); imag(motion)]);
    title('Motion Vectors')
    %axLim=reshape(axis,2,2)
    %axis([min(axLim(1,:)) max(axLim(2,:)) min(axLim(1,:)) max(axLim(2,:))])
    axLim=max(abs(axis));
    %axLim=3;
    axis([-axLim axLim -axLim axLim]);
    
    pause(0.1)
       
end




end