%This function will show a track block with different display options.
%if just the first value is passed in it must be the full path to the case
%metafile.  Everything will be loaded from here and the track file will be
%assumed to be the most recent one as defined by the time stamp in the file name,
%not the actual file creation date
%
%legendOption defines how the legend will show up.  The options are:
%  'name' - shows just the name
%  'name_template_search' - shows the name of the region, the template
%     coordinates and the search area
%  'off' - turns off the legend
%
%showMaxCorr - logical shows the maximum correlation value plot from all the
% roi's.  the default value is true
%
%showRailHit - Shows where the correlation values hit the rail. The
%default is false.
function [imH,figH]=showTrackBlock(strName,varargin)
%% Display the correlation match
p = inputParser;   % Create an instance of the class.
p.addRequired('strName', @ischar);
p.addOptional('roiList', [], @isstruct);
p.addOptional('roiOut', [], @isstruct);
p.addOptional('mmodeImg', [], @(x) isnumeric(x) && (length(size(x))==2));
p.addParamValue('legendOption', 'name', @(x) any(strcmp(x,{'name','name_template_search','off'})));
p.addParamValue('showMaxCorr', true, @islogical);
p.addParamValue('showRailHit', false, @islogical);
displayFcn = @(x) abs(x).^0.5; %can use absIfIM

p.parse(strName, varargin{:});

strName=p.Results.strName;
roiList=p.Results.roiList;
roiOut=p.Results.roiOut;
mmodeImg=p.Results.mmodeImg;
legendOption=p.Results.legendOption;
showMaxCorr=p.Results.showMaxCorr;
showRailHit=p.Results.showRailHit;


if isempty(roiList) && isempty(roiOut) && isempty(mmodeImg)
    isDataValid=false;
elseif ~isempty(roiList) && ~isempty(roiOut) && ~isempty(mmodeImg)
    isDataValid=true;
else
    error('Either roiList,roiOut,mmodeImg must all be specified or they must all be empty');
end


if isDataValid==false
    caseFile=strName;
    trackFilename=[];
    [metadata]=loadCaseData(caseFile);
    caseStr=getCaseName(metadata);
    [roiList,roiOut,mmodeImg]=loadTrackBlock(metadata,trackFilename);
else
    caseStr=strName;
end

trackcolors={'y','r','g','b','c','m'};
figH=figure;
set(figH,'Name',caseStr);
imH=imagesc(displayFcn(mmodeImg)); colormap(gray); hold on;
plotH=zeros(length(roiList),1);
for jj=1:length(roiList)
    figure(figH);
    
    plotH(jj)=plot(roiOut(jj).rfMotion+mean(roiList(jj).search),trackcolors{jj},'Linewidth',2);    
    %plotH(jj)=plot(cumsum([roiOut(jj).corrMatch(1); medfilt1(roiOut(jj).corrMatch(2:end),3)]),trackcolors{jj},'Linewidth',2);
    
    plot(repmat(jj*2,length(roiList(jj).search),1),roiList(jj).search,trackcolors{jj},'Linewidth',1);
        
    if showRailHit && any(roiOut(jj).hitRail)
        plot(find(roiOut(jj).hitRail),roiOut(jj).rfMotion(roiOut(jj).hitRail)+mean(roiList(jj).search),[trackcolors{jj} 'o'],'Linewidth',2);
    end
    
end
titleStr=caseStr;
if showMaxCorr
    plot(roiOut(jj+1).rfMotion,trackcolors{jj+1},'Linewidth',4);
    titleStr =[titleStr ' Bold line is max corr.'];    
else
    %do nothing
end

if showRailHit
    titleStr =[titleStr ' o=Rail hits.'];    
else
    %do nothing
end
    
title(titleStr,'interpreter','none')
hold off;
xlabel('frames')
ylabel('lateral distance')


axis tight;
%ylim([min([reshape([roiOut(:).rfMotion],[],1);1]) max([reshape([roiOut(:).rfMotion],[],1); size(mmodeImg,1)])])

roiString={};
for jj=1:length(roiList)
    switch(legendOption)
        case 'name'
            roiString{end+1}=['r' num2str(jj)]; %#ok<*AGROW>
        case 'name_template_search'
            roiString{end+1}=['roi' num2str(jj) ' t(' num2str(roiList(jj).template(1)) ',' num2str(roiList(jj).template(end)) ') s(' num2str(roiList(jj).search(1)) ','  num2str(roiList(jj).search(end)) ')'];
        case 'off'
            %don't add anything
        otherwise
            error(['Invalid legendOption of ' legendOption])
    end
end
if ~isempty(roiString)
    legend(plotH,roiString);
end
