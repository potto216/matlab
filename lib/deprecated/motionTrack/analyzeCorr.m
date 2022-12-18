%This function compares the IR data to the RF track
function analyzeCorr(caseFile,trackFilename,roiIndex)

switch(nargin)
    case 3
        %do nothing
    otherwise
        error('Invalid number of input arguments.')
end

[metadata]=loadCaseData(caseFile);
caseStr=getCaseName(metadata);

disp(metadata.irFilename);
%% Load the data and setup the default regions
[roiList,roiOut,mmodeImg]=loadTrackBlock(metadata,trackFilename); %#ok<NASGU>


figH=figure;
set(figH,'Name',caseStr);


%interpFunction='interp'
% imH=imagesc(mmodeImg); colormap(gray); hold on;
% plotH=zeros(length(roiList),1);
interpFunction='interp1';
interpFactor=100;
for jj=roiIndex:roiIndex
    figure(figH);
    %plotH(jj)=plot(roiOut(jj).rfMotion,trackcolors{jj},'Linewidth',2);
    %plot(repmat(jj*2,length(roiList(jj).search),1),roiList(jj).search,trackcolors{jj},'Linewidth',1);
    a=roiOut(jj).corr;
    
    %skip first value because that is just for alignment
    for jjj=2:size(a,2)
        figure(figH);
        %a=roiOut(jj).corr(:,roiOut(jj).hitRail);
        av=a(:,jjj);
        plot((1:length(av)),av,'bo-')
        hold on
         switch(interpFunction)
            case 'interp1'
                xi=linspace(1,length(av),interpFactor*length(av));
                ai=interp1((1:length(av)),av,xi,'spline');
                plot(xi,ai,'r' )
            case 'interp'
                xi=linspace(1,length(av)+1,interpFactor*length(av));
                ai=interp(av,interpFactor);
                plot(xi,ai,'r' )
            otherwise
                error(['Invalid method of ' interpFunction])
         end
         newIdx=(roiOut(jj).corrMatch(jjj)-(roiList(jj).search(1)-roiList(jj).template(1)))+1;
         [goodVal, goodIdx]=min(abs(xi-newIdx));
        plot(newIdx,ai(goodIdx),'rd')
        hold off
        if roiOut(jj).hitRail(jjj)
            rmsg='rail hit';
        else
            rmsg='no rail hit';
        end
        title([interpFunction ' roi ' num2str(jj) ' and corr ' num2str(jjj) ' of '  num2str(size(a,2)) ' ' rmsg ' corr shift=' num2str(roiOut(jj).corrMatch(jjj))]);
        pause
%         if jjj==3
%             keyboard
%         end
        
        
        
    end
    
end
