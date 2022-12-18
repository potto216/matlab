function plotBframes(bimg)
    % By Khalid 2012

    % Create a figure and subplot.
    figure
    hax1 = gca;
    imagesc((abs(squeeze(bimg(:,:,1)))));
    colormap gray
    title(hax1,'Frame 1','fontsize',16)
    ylabel('Depth (samples)','fontsize',16)
    
    % Add a slider uicontrol to control the location to plot in the next
    % subplot
    pos=get(hax1,'position');
    Newpos=[pos(1) pos(2)-0.1 pos(3)+0.4 0.05];
% %     'Position', [75 200 430 20],...
    uicontrol('Style', 'slider',...
        'Min',1,'Max',size(bimg,3),'Value',1,...
        'SliderStep',[1/(size(bimg,3)-1) 20/(size(bimg,3)-1)],...
        'Position', Newpos*400,...
        'Callback', {@framestep,hax1,bimg});   % Slider function handle callback
                                        % Implemented as a subfunction
end


function framestep(hObj,event,ax,bimg)
    val = get(hObj,'Value');
    framenum = floor(val);
    
    imagesc((abs(squeeze(bimg(:,:,framenum)))));
    title(ax,['Frame ',num2str(framenum)],'fontsize',16)
    ylabel(ax,'Depth (samples)','fontsize',16)
end


% %% old working standalone code
% 
% figure
% hax1 = gca;
% imagesc(sqrt(abs(squeeze(img(:,:,1)))));
% colormap gray
% title(hax1,'ttt','fontsize',16)
% 
% pos=get(hax1,'position');
% Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
% 
% S=['imagesc(sqrt(abs(squeeze(img(:,:,floor(get(gcbo,''value'')))))))'];
% 
% uicontrol('Style', 'slider',...
%         'Min',1,'Max',size(img,3),'Value',1,...
%         'Position', [75 200 430 20],...
%         'Callback',S);
