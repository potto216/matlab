function err = calc_peak_error(ref,comp,fsref,fscomp,debug)
% Description
%     Calculates the peak error for the B-mode data compared to the reference data.
% Usage
%     error = calc_peak_error(ref, comp, fsref, fscomp, debug)
% Arguments
%     ref: The reference B-mode data.}
%     comp: The B-mode data of the compared data.
%     fsref: Frequency used to generate the reference data.
%     fscomp: Frequency used to generate the compared data.
%     debug: Optional, set  debug=1 to plot the reference, compared, and 10x difference for each line.
% Output Parameters
%     Error: The peak error of the B-mode data of the compared signal to the reference signal.
% Notes
%     This function will ONLY works well if GCD(fsref,fscomp) = MIN(fsref,fscomp)

if nargin < 5
    debug = 0;
end

RFendtime=min([(size(ref,1))/fsref (size(comp,1))/fscomp]);
CD=gcd(fsref,fscomp);
temp_length=floor(RFendtime*CD);
new_refdata=zeros(temp_length,size(ref,2));
new_compdata=zeros(temp_length,size(ref,2));

maxpeakerr=0;

for m=1:size(ref,2)
    new_refdata(1:temp_length,m)=ref(fsref/CD*(0:temp_length-1)+1,m);
    new_compdata(1:temp_length,m)=comp(fscomp/CD*(0:temp_length-1)+1,m);

    errsingle =  max(abs(new_compdata(:,m)-new_refdata(:,m)))/max(abs(new_refdata(:,m)));
    
    
    maxpeakerr = max(errsingle,maxpeakerr);
    
    if debug
        disp(['Error Calc - Progress : ' num2str(100*m/size(ref,2)) '%']);
        figure(11+2*m)
        plot(1:temp_length,new_refdata(:,m),'o-',1:temp_length,new_compdata(:,m),'x-',1:temp_length,-10*(new_compdata(:,m)-new_refdata(:,m)),'rv-');
        legend('Reference','Compared Signal','10xDifference');
    end
    
end

err = maxpeakerr;

%fprintf('RMS Error: %07.4f%%\n', err*100);