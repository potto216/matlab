%This function will calcalte theshear wave freq the rf motion for the ultrasound
%
%caseFile - The filename of the case
%
%ultrasonixGetFrameParms - The parameters to configure the ultrasonix get
%
%%displayFcn - this is the function used to display the results on the
%screen for the user.  Its default is @(x) = abs(x).^0.5 which reduces the dynamic
%range of the image, but to see the full range of the RF (+-) you could
%pass in a function @(x) absIfIM(x).  The key point is this should be an
%anonymous function.

%frame function.
%
function calcShearWaveFreq(caseFile,varargin)

p = inputParser;   % Create an instance of the class.
p.addRequired('caseFile', @(x) ischar(x) || isstruct(x));
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);
p.addParamValue('displayFcn',@(x) abs(x).^0.5,@(x) isa(x,'function_handle'));

p.parse(caseFile,varargin{:});

ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;
displayFcn = p.Results.displayFcn;

%% Load the data and setup the default regions
[metadata]=loadCaseData(caseFile);
caseStr=getCaseName(metadata);


framesToProcess=metadata.validFramesToProcess;

if isempty(framesToProcess)
    [header] = ultrasonixGetInfo(metadata.rfFilename);    
end

%% Setup the sampling points which will be used
%plot image incase need to get new values
maxMemoryForArrayInSamples=1500*32*128;
maxFrames=floor(maxMemoryForArrayInSamples/(header.w*header.h));
maxFramesToProcess=min(header.nframes,maxFrames);
[imgBlock,header] = ultrasonixGetFrame(metadata.rfFilename,[0:(maxFramesToProcess-1)],ultrasonixGetFrameParms{:});

%imgBlock(:,:,2)=imgBlock(:,:,1).*cumsum(ones(size(imgBlock(:,:,1)))*exp(j*pi/8),2);
frameNumber=1;
img=imgBlock(:,:,frameNumber);


%% Sample the image with the spline points and



imgAngle_rad=angle(imgBlock(:,1:end,1:(end-1)).*conj(imgBlock(:,1:end,2:end)));

imgAngleFilt_rad=zeros(size(imgAngle_rad));
for k = 1:size(imgAngle_rad,3)
    imgAngleFilt_rad(:,:,k) = medfilt2(imgAngle_rad(:,:,k),[5,3]);
    imgAngleFilt_rad(:,:,k) = conv2(imgAngleFilt_rad(:,:,k),ones(10,1)/10,'same');
    
end
%imgAngleFilt_rad=imgAngle_rad;


%imgAngleFilt_rad


fft_phase = zeros(size(imgAngleFilt_rad,1),size(imgAngleFilt_rad,2));
fft_frequency = zeros(size(imgAngleFilt_rad,1),size(imgAngleFilt_rad,2));
fftBinFreqToRealFreq=make_f(size(imgAngleFilt_rad,3),header.dr);
for k=1:size(imgAngleFilt_rad,1); 
    for l=1:size(imgAngleFilt_rad,2) 
        sig = squeeze(imgAngleFilt_rad(k,l,:)); 
        sig = sig - mean(sig);
        sig = sig.*hanning(length(sig));
%         imgAngleFilt_rad_interp = interp(sig,5);
        imgAngleFilt_rad_fft = (fft(sig));
        
        %only look at the positive frequencies
        [fund_peak_val,fund_peak] = max(abs(imgAngleFilt_rad_fft(1:floor(end/2)))); 
        
        fft_phase(k,l) = angle(imgAngleFilt_rad_fft(fund_peak));
        fft_frequency(k,l) = fund_peak;
    end; 
end

commonFreqBin=mode(fft_frequency(:));
badFreqIdx=find(commonFreqBin~=fft_frequency(:));
freqsNoMatch=length(badFreqIdx)/(size(fft_frequency,1)*size(fft_frequency,2));
disp(['Case ' caseStr ' total frames processed ' num2str(maxFramesToProcess)])
disp(['The most common frequency found is ' num2str(fftBinFreqToRealFreq(commonFreqBin)) 'Hz.'])
disp([num2str(freqsNoMatch*100) '% of the freqs do not match']);

end