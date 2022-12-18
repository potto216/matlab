

if objFieldII.xmit.elementTotalActive~=objFieldII.rcv.elementTotalActive
    error('the xmit and rcv active element sizes must be equal')
end


objFieldII.collect.numberOfLines=objFieldII.probe.elementTotalPhysical; %(objFieldII.probe.elementTotalPhysical-objFieldII.xmit.elementTotalActive);
dx_m=objFieldII.probe.element.width_m+objFieldII.probe.element.kerf_m;
objFieldII.collect.imageWidth_m=objFieldII.collect.numberOfLines*dx_m;
numberOfLines=objFieldII.collect.numberOfLines;
%objFieldII.collect.phantomOffsetZ_m=offsetZ_m;

objFieldII=objFieldIIPackageSetup(objFieldII,objPhantom,fieldIIRFDataFullFilepath,trialName);
maxFrames=phantomGetTotalFrames(objPhantom);

parfor ii=1:numberOfLines %(1:numberOfLines)
%for ii=1:numberOfLines %(1:numberOfLines)
    field_init(0);
    objFieldIIConfigure(objFieldII);
    
    for pp=1:maxFrames
                
        phantom=phantomGetPosition(objPhantom,pp,'all-scatters');
        
        
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
            
%             [rfData, tstart_sec]=calc_scat(objFieldII.xmit.deviceHandle, objFieldII.rcv.deviceHandle, ...
%                 [phantom.x_m phantom.y_m (phantom.z_m+objFieldII.collect.phantomOffsetZ_m)], ...
%                  phantom.amplitude);
            [rfData, tstart_sec]=calc_scat(objFieldII.xmit.deviceHandle, objFieldII.rcv.deviceHandle, ...
                [phantom.x_m phantom.y_m (phantom.z_m)], ...
                 phantom.amplitude);
             
            objFieldIIPackageSaveScanLine(objFieldII,pp,ii,rfData, tstart_sec,{'xmitApodization',xmitApodization,'rcvApodization',rcvApodization});
            
            
        else
            disp(['Line ',num2str(ii),' is being made by another machine.'])
        end
        
        
        
        disp('You should now run make_image to display the image')
        
    end
end

