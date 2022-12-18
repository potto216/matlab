%This function loads the colors to plot unique traces
%INPUT
%totalSources - are the total number of plots needed
%
%OUTPUT
%sourceLinePlotFormatList - is double wrapped as a cell in case it
%holds additional arguments such as line properties
function  [sourcePlotFormatList,sourceLinePlotFormatList]= getPlotMarkers(frameIndex)

colorList={'r','g','c','b','m','y'};
shapeList={'.','o','x','+','*','s','>','v'};
[idxC,idxS]=ndgrid([1:length(colorList)],[1:length(shapeList)]);

%rotate each row by one more than the one above it
idxSRotate=mod((idxS-1)+(idxC-1),8)+1;

sourcePlotFormatList=cellfun(@(c,s) [c s],colorList(idxC),shapeList(idxSRotate),'UniformOutput',false);
sourcePlotFormatList=sourcePlotFormatList(:);

sourceLinePlotFormatList=colorList(idxC);
sourceLinePlotFormatList = arrayfun(@(x) {x}, sourceLinePlotFormatList(:));


% if length(frameIndex)==1
%     %sourcePlotFormatList=[{'r.','go','cx','b+','m*','ys','g>','rv'}'] ;
%     %sourceLinePlotFormatList=[{{'r','linewidth',2},{'g'},{'c'},{'b'},{'m'},{'y'},{'g'},{'r'}}'];
% elseif length(frameIndex)<=length(colorList)
%     error('Needs to be fixed.');
%     %if more than one frame use colors between frames and the
%     %marker type otherwise
%     shapelist={'.','o','x','+','*','s','>','v','p','h'}';
%     sourceLinePlotFormatList=repmat(colorList(1:length(frameIndex)),size(shapelist,1),1);
%     sourcePlotFormatList=cellfun(@(x,y) [x y], sourceLinePlotFormatList, repmat(shapelist,1,size(colorList,2)),'UniformOutput',false);
% else
%     sourceLinePlotFormatList=[];
%     sourcePlotFormatList=[];
% end

end