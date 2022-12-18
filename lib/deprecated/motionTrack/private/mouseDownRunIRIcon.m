function mouseDownIcon(src,eventdata,caseFile,trackFilename)
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

analyzeIRvsRF(caseFile,[],roiIndex);

end