function showTrackstitchDetails(dataBlockObj, track, matchList, trackLength)

    f1=figure;
    imh=imagesc(trackLength); cbarH=colorbar;
    basicColorMap=colormap;
    zeroColorMap=basicColorMap;
    zeroColorMap(1,:)=0;
    longColorMap=basicColorMap;
    longColorMap(1:30,:)=0;
    
    set(get(cbarH,'YLabel'),'Rotation',0);
    set(get(cbarH,'YLabel'),'String',['Track' 10 'Length']);
    get(imh)
    hcmenu = uicontextmenu;
    item1 = uimenu(hcmenu, 'Label', 'Track Video', 'Callback', {@showTrackCallback,dataBlockObj,trackLength,matchList,track,imh});
    item1 = uimenu(hcmenu, 'Label', 'Colormap Basic', 'Callback', @(scr,evn) colormap(basicColorMap));
    item1 = uimenu(hcmenu, 'Label', 'Colormap 1+', 'Callback', @(scr,evn) colormap(zeroColorMap));
    item1 = uimenu(hcmenu, 'Label', 'Colormap Long Track ', 'Callback', @(scr,evn) colormap(longColorMap));
    
    set(imh,'UIContextMenu',hcmenu);
    
    
    xlabel('Frame #')
    ylabel('Track Number')


