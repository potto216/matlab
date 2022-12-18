clear
close all



useParallelProcessing=true;
computerInformation=loadComputerSpecificData();

if useParallelProcessing
    localCoresToUse=min(computerInformation.numCores,8); %#ok<UNRCH>
    disp(['Opening ' num2str(localCoresToUse) ' cores.'])
    matlabpool('open','local',localCoresToUse);
end

phantomName='phantomFiniteElement';
phantomName='phantomWithBallNotStiffFiniteElement';
%phantomName='phantomWithNoBallFiniteElement';
%phantomName='phantomWithStiffBallFiniteElement';
phantomObjectFilename=[phantomName '.mat'];
[ objFieldII ] = objFieldIISetup('ultrasonix');


if exist(phantomObjectFilename,'file')
    disp(['Loading ' phantomObjectFilename ' from disk']);
    load(phantomObjectFilename,'objPhantom');
    
    ytmp=objPhantom.pointArray(2,:);
    objPhantom.pointArray(2,:)=objPhantom.pointArray(3,:);
    objPhantom.pointArray(3,:)=ytmp;
    
    objPhantom.bounds = ...
        [min(permute(min(objPhantom.pointArray,[],2),[ 1 3 2]),[],2) ...
        max(permute(max(objPhantom.pointArray,[],2),[ 1 3 2]),[],2) ];
    
    pointArray=objPhantom.pointArray;
    
    pointArray(1,:)=(objPhantom.pointArray(1,:)-objPhantom.bounds(1,1))/diff(objPhantom.bounds(1,:));
    pointArray(2,:)=(objPhantom.pointArray(2,:)-objPhantom.bounds(2,1))/diff(objPhantom.bounds(2,:));
    pointArray(3,:)=(objPhantom.pointArray(3,:)-objPhantom.bounds(3,1))/diff(objPhantom.bounds(3,:));
    objPhantom.pointArray=[];
    
    %flip the Z
    pointArray(3,:)=-(pointArray(3,:)-1);
    
    
    xSize_m = 30/1000;   %  Width of phantom [mm]
    ySize_m = 5/1000;   %  Transverse width of phantom [mm]
    zSize_m = 20/1000;   %  Height of phantom [mm]
    
    bounds = ...
        [min(permute(min(pointArray,[],2),[ 1 3 2]),[],2) ...
        max(permute(max(pointArray,[],2),[ 1 3 2]),[],2) ];
    
    pointArray(1,:)=(pointArray(1,:)-0.5)*xSize_m;
    pointArray(2,:)=(pointArray(2,:)-0.5)*ySize_m;
    pointArray(3,:)=(pointArray(3,:))*zSize_m;
    
    objPhantom.bounds = ...
        [min(permute(min(pointArray,[],2),[ 1 3 2]),[],2) ...
        max(permute(max(pointArray,[],2),[ 1 3 2]),[],2) ];
    objPhantom.scatterPosition=pointArray;
    objPhantom.scatterAmplitude=randn(size(objPhantom.scatterPosition,2),1);
    %objPhantom.scatterPosition(1,1:10,:)=0/1000;
    objPhantom.scatterPosition(1,1:10,:)=repmat(rand(1,10),[1 1 size(objPhantom.scatterPosition,3)])/1000;
    objPhantom.scatterPosition(2,1:10,:)=repmat(rand(1,10),[1 1 size(objPhantom.scatterPosition,3)])/1000;
    objPhantom.scatterPosition(3,1:10,:)=5/1000;
    objPhantom.scatterAmplitude(1)=10;
    if false
        %% display
        f1=figure;
        for ii=1:size(objPhantom.scatterPosition,3);
            figure(f1); plot3(objPhantom.scatterPosition(1,:,ii),objPhantom.scatterPosition(2,:,ii),objPhantom.scatterPosition(3,:,ii),'b.')
            xlabel('x')
            ylabel('y')
            zlabel('z')
            pause(0.4)
            
        end
    end    
else
    error(['Unable to open: ' phantomObjectFilename]);
end



if objFieldII.xmit.elementTotalActive~=objFieldII.rcv.elementTotalActive
    error('the xmit and rcv active element sizes must be equal')
end




objFieldII.collect.numberOfLines=objFieldII.probe.elementTotalPhysical; %(objFieldII.probe.elementTotalPhysical-objFieldII.xmit.elementTotalActive);
dx_m=objFieldII.probe.element.width_m+objFieldII.probe.element.kerf_m;
objFieldII.collect.imageWidth_m=objFieldII.collect.numberOfLines*dx_m;
numberOfLines=objFieldII.collect.numberOfLines;
objFieldII.collect.phantomOffsetZ_m=6/1000;

objFieldII=objFieldIIPackageSetup(objFieldII,objPhantom,pwd,[phantomName]);

parfor ii=1:numberOfLines %(1:numberOfLines)
    %for ii=1:numberOfLines %(1:numberOfLines)
    field_init(0);
    objFieldIIConfigure(objFieldII);
    
    for pp=1:size(objPhantom.scatterPosition,3)
        
        
        
        
        phantomPositions_m=objPhantom.scatterPosition(:,:,pp).';
        phantomPositions_m(:,3)=phantomPositions_m(:,3)+objFieldII.collect.phantomOffsetZ_m;
        phantomAmplitudes=objPhantom.scatterAmplitude;
        
        if length(objFieldII.probe)~=1
            error('This code only supports one probe.')
        else
            probe=objFieldII.probe;
        end
        
        [scanLineStarted, failReason]=objFieldIIPackageSetupScanLine(objFieldII,pp,ii);
        
        if  scanLineStarted
            
            disp(['Now making line ',num2str(ii) ' of ' num2str(numberOfLines)])
            
            %  The the imaging direction
            
            x_m= -objFieldII.collect.imageWidth_m/2 +(ii-1)*dx_m;
            
            %   Set the focus for this direction with the proper reference point
            
            xdc_center_focus (objFieldII.xmit.deviceHandle, [x_m 0 0]);
            xdc_focus (objFieldII.xmit.deviceHandle, 0, [x_m 0 objFieldII.rcv.focalPoint_m(3)]);
            xdc_center_focus (objFieldII.rcv.deviceHandle, [x_m 0 0]);
            Nf=length(objFieldII.rcv.focalZones_m);
            xdc_focus (objFieldII.rcv.deviceHandle, objFieldII.rcv.focalTimes_sec, [x_m*ones(Nf,1), zeros(Nf,1), objFieldII.rcv.focalZones_m]);
            
            %  Calculate the apodization
            
            N_pre  = round(x_m/(probe.element.width_m+probe.element.kerf_m) + probe.elementTotalPhysical/2 - objFieldII.xmit.elementTotalActive/2);
            N_post = probe.elementTotalPhysical - N_pre - objFieldII.xmit.elementTotalActive;
            %apo_vector=[zeros(1,N_pre) apo zeros(1,N_post)];
            %When all the way to the left then don't the first
            
            es=1-min(N_pre,0);
            ee=objFieldII.xmit.elementTotalActive+min(N_post,0);
            activeElementsIndex=es:ee;
            %activeElementsIndex( :an)
            xmitApodization=[zeros(1,N_pre) objFieldII.xmit.apodization(activeElementsIndex).' zeros(1,N_post)];
            rcvApodization=[zeros(1,N_pre) objFieldII.rcv.apodization(activeElementsIndex).' zeros(1,N_post)];
            if (length(xmitApodization)~=probe.elementTotalPhysical) || (length(rcvApodization)~=probe.elementTotalPhysical)
                error(['  Either the rcv or the xmit apodization is not equal to ' num2str(probe.elementTotalPhysical)])
            else
                %do nothing
            end
            xdc_apodization (objFieldII.xmit.deviceHandle, 0, xmitApodization);
            xdc_apodization (objFieldII.rcv.deviceHandle, 0, rcvApodization);
            
            %   Calculate the received response
            
            [rfData, tstart_sec]=calc_scat(objFieldII.xmit.deviceHandle, objFieldII.rcv.deviceHandle, phantomPositions_m, phantomAmplitudes);
            
            objFieldIIPackageSaveScanLine(objFieldII,pp,ii,rfData, tstart_sec,{'xmitApodization',xmitApodization,'rcvApodization',rcvApodization});
            
            
        else
            disp(['Line ',num2str(ii),' is being made by another machine.'])
        end
        
        
        
        disp('You should now run make_image to display the image')
        
    end
end

objFieldIIShutdown( objFieldII );
if useParallelProcessing
    matlabpool('close') %#ok<UNRCH>
end

