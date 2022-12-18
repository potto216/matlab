function [ ptsInsideRectusFemorisIdx ] = phantomPointBetweenSplines( topSpline,bottomSpline,phantomData,pointList,verbose,fid)
%PHANTOMPOINTBETWEENSPLINES  Now we want to remove the background scatters from the rectusFemoris image
%we override the sides so they strech to eliminate any background scatters
%at the edges

%%


chkDistTopx=[topSpline.x_m(1:end-1).';topSpline.x_m(2:end).'];
chkDistTopx(1,1)=phantomData.xLim_m(1);
chkDistTopx(2,end)=phantomData.xLim_m(2);

chkDistTopz=[topSpline.z_m(1:end-1,1).';topSpline.z_m(2:end,1).'];

chkDistBottomx=[bottomSpline.x_m(1:end-1).';bottomSpline.x_m(2:end).'];
chkDistBottomx(1,1)=phantomData.xLim_m(1);
chkDistBottomx(2,end)=phantomData.xLim_m(2);

chkDistBottomz=[bottomSpline.z_m(1:end-1).';bottomSpline.z_m(2:end).'];

dprodTop=zeros(length(pointList.x_m),1);
dprodBottom=zeros(length(pointList.x_m),1);

%We remove the points by seeing if they fall in the range of top and bottom
%and then checking to see if dot

if verbose
    fprintf(fid,'Removing background points in the rectusFemoris boundary.  This may take a while.\n');
end
for tt=1:length(pointList.x_m)
    topIndex=find((pointList.x_m(tt)>=chkDistTopx(1,:)) &  (pointList.x_m(tt)<chkDistTopx(2,:)));
    bottomIndex=find((pointList.x_m(tt)>=chkDistBottomx(1,:)) &  (pointList.x_m(tt)<chkDistBottomx(2,:)));
    
    if length(topIndex)~=1 || length(bottomIndex)~=1
        dprodTop(tt)=1;
        dprodBottom(tt)=1;
    else
        vt=diff([-chkDistTopz(:,topIndex) chkDistTopx(:,topIndex)]',1,2);
        vts=diff([chkDistTopx(1,topIndex) pointList.x_m(tt); chkDistTopz(1,topIndex) pointList.z_m(tt)],1,2);
        
        vb=diff([-chkDistBottomz(:,topIndex) chkDistBottomx(:,topIndex)]',1,2);
        vbs=diff([chkDistBottomx(1,topIndex) pointList.x_m(tt); chkDistBottomz(1,topIndex) pointList.z_m(tt)],1,2);
        
        %figure; plot([0 vt(1)],[0,vt(2)],'b'); hold on; plot([0 vts(1)],[0,vts(2)],'r:');
        dprodTop(tt)=vt'*vts/sqrt(vt'*vt*(vts'*vts));
        dprodBottom(tt)=vb'*vbs/sqrt(vb'*vb*(vbs'*vbs));
        %         if ~((dprodTop(tt)>0  & dprodBottom(tt)<0))
        %             disp('fail')
        %         end
        
    end
    
end


ptsInsideRectusFemorisIdx=(dprodTop>0  & dprodBottom<0);

end

