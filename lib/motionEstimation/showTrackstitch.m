function showTrackstitch(dataBlockObj, regionBoxCenter_rc,regionBoxOffset_rc,  fullTrackPath_rc,skipVideoWrite,trackFilename,maxFrame)
%% Show it
if isempty(maxFrame)
    maxFrame=dataBlockObj.size(3);
end

%imBlock=dataBlockObj.blockData;  
f1=figure;
vid=vopen([trackFilename '.avi'],'w',10,{'avi', 'Uncompressed AVI'},skipVideoWrite);
%vid=vopen([trackFilename ],'w',10,{'gif', 'DelayTime',1},skipVideoWrite);
    io=1; %-1;
for ii=(1+io):((maxFrame)-3)
    figure(f1);
    im=dataBlockObj.getSlice(ii);
    imagesc(im);
    colormap(gray(256));
    hold on

    if ~isempty(fullTrackPath_rc)
        plot(fullTrackPath_rc(2,ii-io),fullTrackPath_rc(1,ii-io),'ro')
    end
    plot(regionBoxCenter_rc(2)+regionBoxOffset_rc(2,ii-io),regionBoxCenter_rc(1)+regionBoxOffset_rc(1,ii-io),'go')
    hold off
    title([' Frame ' num2str(ii) ' of ' num2str(dataBlockObj.size(3))])
    pause(1)
    drawnow
    vid=vwrite(vid,gca,'handle');
end
vid=vclose(vid);
end



