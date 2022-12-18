%This function will compute the vibration phase delay over a collection of
%ultrasound RF frames.  The phase is computed for a specified temporal frequency 
%and if none is specified then the most common one is choosen.
%
%INPUTS: 
%imgBlock - This is a 3 dim block of data where the row and columns are the
%   image dimensions and the third dimension is time.
%imgBlockType - {'time','frequency'} This defines the block to be a temporal or frequency.  The
% frequency block is useful when just updating the selected frequency bin
%fs - The sample rate
%temporalFrequency - if this is empty it will be automatic for choosing the
%  most common frequency with the greatest amplitude
%
%
%TODO rename variables
%make sure freq can do automatic
function [fftPhase, selectedFrequency, sig,fftBinFreqToRealFreq,imgAngleFilt_rad]=swPhaseMap(imgBlock,imgBlockType,fs,temporalFrequency)

switch(imgBlockType)
    case 'time'
        imgAngle_rad=angle(imgBlock(:,1:end,1:(end-1)).*conj(imgBlock(:,1:end,2:end)));
        imgAngleFilt_rad=zeros(size(imgAngle_rad));
        for k = 1:size(imgAngle_rad,3)
            imgAngleFilt_rad(:,:,k) = medfilt2(imgAngle_rad(:,:,k),[5,3]);
            imgAngleFilt_rad(:,:,k) = conv2(imgAngleFilt_rad(:,:,k),ones(10,1)/10,'same');
        end
        sig=imgAngleFilt_rad-repmat(mean(imgAngleFilt_rad,3),[1, 1, size(imgAngleFilt_rad,3)]);
        sig=sig.*repmat(permute(hanning(size(imgAngleFilt_rad,3)),[3 2 1]),[size(imgAngleFilt_rad,1) size(imgAngleFilt_rad,2) 1]);
        sig=fft(sig,size(sig,3),3);
        
    case 'frequency'
        
        sig=imgBlock;
        
    otherwise
        error(['Unsupported block type of ' imgBlockType])
end
%% here there are several possablities.
%1. Compute the frequency and look for the max value
%2.Process the data at a set frequency
%Either way we will have to take the ffts of the data but the only
%difference is whether we find the max value or not.

fftPhase = zeros(size(imgAngleFilt_rad,1),size(imgAngleFilt_rad,2));
%fft_frequency = zeros(size(imgAngleFilt_rad,1),size(imgAngleFilt_rad,2));
fftBinFreqToRealFreq=make_f(size(imgAngleFilt_rad,3),fs);



if isempty(temporalFrequency)
    [fund_peak_val,fund_peak]=max(abs(sig(:,:,1:floor(end/2))),[],3); %#ok<ASGLU>
    for k=1:size(sig,1);
        for l=1:size(sig,2)
            fftPhase(k,l) = angle(sig(k,l,fund_peak(k,l)));
        end;
    end
    fft_frequency = fund_peak;
    commonFreqBin=mode(fft_frequency(:));
    badFreqIdx=find(commonFreqBin~=fft_frequency(:));
    freqsNoMatch=length(badFreqIdx)/(size(fft_frequency,1)*size(fft_frequency,2));
    
    %This can be optimized away
    for k=1:length(badFreqIdx)
        
        [badRow,badColumn] = ind2sub(size(fft_frequency),badFreqIdx(k));
        sig2 = squeeze(imgAngleFilt_rad(badRow,badColumn,:));
        sig2 = sig2 - mean(sig2);
        sig2 = sig2.*hanning(length(sig2));
        imgAngleFilt_rad_fft = (fft(sig2));
        
        fftPhase(badRow,badColumn) = angle(imgAngleFilt_rad_fft(commonFreqBin));
        %fft_frequency(badRow,badColumn) = commonFreqBin;
        
    end
    disp(['The most common frequency found is ' num2str(fftBinFreqToRealFreq(commonFreqBin)) 'Hz.'])
    disp([num2str(freqsNoMatch*100) '% of the freqs do not match']);
    
else
    %We will have to adjust to the nearest freq bin
    [d1,commonFreqBin]=min(abs(fftBinFreqToRealFreq-temporalFrequency)); %#ok<ASGLU>
    fftPhase=angle(sig(:,:,commonFreqBin));
    %fft_frequency=repmat(commonFreqBin,[size(sig,1) size(sig,2)]);

end
selectedFrequency=fftBinFreqToRealFreq(commonFreqBin);

