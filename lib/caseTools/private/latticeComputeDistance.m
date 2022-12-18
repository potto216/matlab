%TODO fix use remote
function [newLateral_mm,newAxial_mm,validTracks]=latticeComputeDistance(df,lateral_mm,axial_mm)

latticeInfo=load(cleanUltraspeckPath(fullfile(df.generateLatticeData.matFilepath.root,df.generateLatticeData.matFilepath.relative,df.generateLatticeData.matFilepath.trialFolder,df.matLatticeFilename),'useRemote'),'processingTable');


%spInfo2=load(cleanUltraspeckPath(df.generateLatticeData.processingTable.Data{df.processingTableIndex,latticeInfo.processingTable.Column.dataFilename}),'samplePoints_rc','caseFile');
%We want to load the lattice file used to actually sample the data
%Test
spInfo=load(cleanUltraspeckPath(latticeInfo.processingTable.Data{df.processingTableIndex,latticeInfo.processingTable.Column.dataFilename}),'samplePoints_rc','caseFile');
%spInfo=load(cleanUltraspeckPath(latticeInfo.processingTable.Data{2,latticeInfo.processingTable.Column.dataFilename}),'samplePoints_rc','caseFile');
warning('Please fix ')

lr_rc=diff(permute(squeeze(spInfo.samplePoints_rc(1,:,:)),[2 1]),1,1);
lc_rc=diff(permute(squeeze(spInfo.samplePoints_rc(2,:,:)),[2 1]),1,2);

%The goal is to match the diff x and diff y lattice by trimming the end
%point
lc_rc=lc_rc(1:end-1,:);
lr_rc=lr_rc(:,1:end-1);
%distanceMap=sqrt((lateral_mm*lc_rc).^2+(axial_mm*lr_rc).^2);

newLateral_mm=lateral_mm*mode(lc_rc(:));
newAxial_mm=axial_mm*mode(lr_rc(:));

warning('This function will only work for cmm oversampling of 10.  Please fix');
tendonPolygon=splineGetPolygon(cleanUltraspeckPath(spInfo.caseFile.sourceMetaFilename,'useLocal'));
if size(df.track(10).pt_rc,2)==1
    warning('The validTracks hack for length 1 needs to be fixed.');
    validTracks=true;
elseif (lateral_mm/newLateral_mm)>9 %assume curved mmode
    validTracks=true(1,size(df.track(10).pt_rc,2));
else
    %This better be speckle tracking
    
    upperleft_rc=[min(reshape(spInfo.samplePoints_rc(1,:,:),[],1)); min(reshape(spInfo.samplePoints_rc(2,:,:),[],1))];
    validTracks=colvecfun(@(x) inpolygon(x(2,:)+upperleft_rc(2,1),x(1,:)+upperleft_rc(1,1), ...
        (lateral_mm/newLateral_mm)*tendonPolygon.x,(axial_mm/newAxial_mm)*tendonPolygon.y), ...
        df.track(10).pt_rc);
    if false
        %%
        figure; plot((lateral_mm/newLateral_mm)*tendonPolygon.x,(axial_mm/newAxial_mm)*tendonPolygon.y,'r')
        hold on;
        plot(reshape(df.track(10).pt_rc(2,:,:),[],1)+upperleft_rc(2),reshape(df.track(10).pt_rc(1,:,:),[],1)+upperleft_rc(1),'b.');
    end
    
end




if false
    
    %validTracks
    [validRow,validColumn]=ind2sub([size(spInfo.samplePoints_rc,2),size(spInfo.samplePoints_rc,3)],find(validTracks));
    t1=sub2ind(size(spInfo.samplePoints_rc),1*ones(size(validRow)),validRow,validColumn);
    t2=sub2ind(size(spInfo.samplePoints_rc),2*ones(size(validRow)),validRow,validColumn);
    f1=figure;
    %subplot(3,2,[1 2 3 4])
    plot(lateral_mm*reshape(spInfo.samplePoints_rc(2,:,:),[],1),axial_mm*reshape(spInfo.samplePoints_rc(1,:,:),[],1),'.')
    set(get(f1,'CurrentAxes'),'YDir','reverse');
    xlabel('lateral(mm)')
    ylabel('axial(mm)')
    title('Sample Point Sample Positions')
    axis tight
    hold on
    iii=10
    plot(lateral_mm*(df.track(iii).pt_rc(2,validTracks)+spInfo.samplePoints_rc(2,1)),axial_mm*(df.track(iii).pt_rc(1,validTracks)++spInfo.samplePoints_rc(1,1)),'go')
    legend('sample points','tracking points')
    
    df.track(iii).pt_rc(2,validTracks),  df.track(iii).pt_rc(1,validTracks)
    
    %subplot(3,2,[5 6])
    figure;
    imagesc(sqrt((lateral_mm*lc_rc).^2+(axial_mm*lr_rc).^2)); c1=colorbar;
    xlabel('lateral(column)')
    ylabel('axial(row)')
    title('x/y sample point spacing (mm).')
    axis tight
    
    
    
    
    %%
    figure;
    subplot(2,2,[1 3]);
    imagesc(sqrt((lateral_mm*lc_rc).^2+(axial_mm*lr_rc).^2)); c1=colorbar;
    xlabel('lateral(column)')
    ylabel('axial(row)')
    title('x/y sample point spacing (mm).')
    ylabel(c1,'mm','Rotation',0)
    
    subplot(2,2,2);
    hist(lateral_mm*lc_rc(:),101);
    xlabel('sample point spacing(mm)')
    ylabel('count #')
    title(['Histogram of column spacing in mm.'])
    
    subplot(2,2,4);
    hist(axial_mm*lr_rc(:),101);
    xlabel('sample point spacing(mm)')
    ylabel('count #')
    title(['Histogram of column spacing in mm.'])
end