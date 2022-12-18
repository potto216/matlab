function objFieldIIShutdown( objFieldII )
%This function will shutdown the simulation enviroment.  After this
%objFieldIIConfigure will need to be called again
try
    xdc_free (objFieldII.xmit.deviceHandle);
    xdc_free (objFieldII.rcv.deviceHandle);
catch
    disp('Unable to shut down Field II');
end

end

