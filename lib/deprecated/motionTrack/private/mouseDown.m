function mouseDown(src,eventdata,mmodeImg,roiList,roiOut)
activeToolbar=1;
activeComponent=5;
parentAxes=get(src,'Parent');
parentFigure=get(parentAxes,'Parent');

%% this code is needed to find the index of the roi
hToolbar = findall(parentFigure,'tag','FigureToolBar');

jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');

if ~isempty(jToolbar)
   jCombo=jToolbar(activeToolbar).getComponent(activeComponent);
   roiIndex=get(jCombo,'SelectedIndex')+1;  %the index is a + 1 
   roiString=get(jCombo,'SelectedItem');
else
    error('Need to be able to access the toolbar');
end

%% This code is needed to find the frame
pt=get(parentAxes,'CurrentPoint');
disp(num2str(pt(end,:)))
frame=fix(pt(end,1));

%% Pull the data together and call the gui
roiTemplate=roiList(roiIndex).template;
roiSearch=roiList(roiIndex).search;

[corrMatch, corrMaxVal, corr] = compute1DSpeckleTrack(mmodeImg, frame,roiTemplate,roiSearch);
guiCheckCorr({'compute1DSpeckleTrack'},{mmodeImg,frame,roiTemplate,roiSearch,corrMatch, corrMaxVal, corr},{roiString});

end