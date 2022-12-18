classdef shearwaveObject < handle
    %SHEARWAVEOBJECT The purpose of this class is to compute shearwave data
    %from ultrasound data.
    
    properties (Constant=true)
        validObjectType_Data='data';
        validObjectType_RF='rf';
        rsqThreshold=.7
    end
    
    properties (Access=private)
        dataBlock=[]; %the dimensions are distance in the first two and rad/sec in the third
        phaseBlock=[]; %the dimensions are distance in the first two and rad/sec in the third
        shearwaveSpeed_mPerSec=[];;
        rRsq;
    end
    
    
    properties (GetAccess=public, SetAccess=private)
        blockFrameList_base0=[];
        phaseBlockFreqAxis_Hz=[];
        selectedPhaseBlockFreqBinIndex=[];
        temporalFrequency_Hz;
        shearwaveCorrectionMap_rad=[];
        peakFrequencyMap_Hz=[];
        peakFrequencyMap_Mag=[];
        peakFrequencyMap_Index=[];
        caseObj=[];
        tScanLineOverride_sec=[];
    end
    
    properties (GetAccess=public, SetAccess=public)
        
        temporalFrequencyMode='auto';
        shearwaveRunLength=7;
        useShearwaveCorrection=true;
        useReflectionSuppression=false;
        shearwaveGeneratorPosition='left';  %this is left or right for ultrasound transducer
        calcShearwaveAlgorithm='calcShearwaveAssumingPlaneWavePropagation'; %'calcShearwaveWithDirection','calcShearwaveAssumingPlaneWavePropagation'
    end
    
    
    properties (Dependent = true, GetAccess = public)
        lateralAxis_mm;
        axialAxis_mm;
        
        %         lateralStep_mm;
        %         axialStep_mm;
    end
    
    
    methods
        function set.temporalFrequency_Hz(sObj,value_Hz) % Handle class
            
            if isempty(sObj.phaseBlockFreqAxis_Hz) %#ok<MCSUP>
                error('First a block must be loaded before this function can be called.')
            end
            [~,sObj.selectedPhaseBlockFreqBinIndex]=min(abs(sObj.phaseBlockFreqAxis_Hz-value_Hz)); %#ok<MCSUP>
        end
        
        function value_Hz=get.temporalFrequency_Hz(sObj) % Handle class
            value_Hz=sObj.phaseBlockFreqAxis_Hz(sObj.selectedPhaseBlockFreqBinIndex);
        end
        
        function set.temporalFrequencyMode(sObj,value) % Handle class
            switch(lower(value))
                case 'auto'
                    sObj.temporalFrequencyMode='auto';
                case 'manual'
                    sObj.temporalFrequencyMode='manual';
                otherwise
                    error(['Unsupported temporalFrequencyMode of ' value]);
            end
            
        end
        
        function set.useShearwaveCorrection(sObj,value)
            if ~islogical(value)
                error('useShearwaveCorrection must be a logical value')
            end
            sObj.useShearwaveCorrection=value;
        end
        
        function set.useReflectionSuppression(sObj,value)
            if ~islogical(value)
                error('useReflectionSuppression must be a logical value')
            end
            sObj.useReflectionSuppression=value;
        end
        
        function [axis_mm]=get.axialAxis_mm(sObj)
            if isempty(sObj.caseObj.axialStep_mm)
                error('axialStep_mm must be set first')
            end
            
            if isempty(sObj.dataBlock)
                warning('get.axialAxis_mm dataBlock must be set first with load data')
            end
            axis_mm=linspace(0,(size(sObj.dataBlock,1)*sObj.caseObj.axialStep_mm),size(sObj.dataBlock,1));
        end
        
        function [axis_mm]=get.lateralAxis_mm(sObj)
            if isempty(sObj.caseObj.lateralStep_mm)
                error('lateralStep_mm must be set first')
            end
            
            if isempty(sObj.dataBlock)
                warning('get.lateralAxis_mm.  dataBlock must be set first with load data')
            end
            axis_mm=linspace(0,(size(sObj.dataBlock,2)*sObj.caseObj.lateralStep_mm),size(sObj.dataBlock,2));
        end
        
        %         function [axis_mm]=get.axialStep_mm(sObj)
        %             axis_mm=sObj.caseObj.axialStep_mm;
        %         end
        %
        %         function [lateral_mm]=get.lateralStep_mm(sObj)
        %             lateral_mm=sObj.caseObj.lateralStep_mm;
        %         end
        
        function set.shearwaveGeneratorPosition(sObj,value)
            switch(value)
                case {'left','right'}
                    sObj.caseObj.caseData.shearwave.vibratorPosition=value;
                otherwise
                    error(['Property shearwaveGeneratorPosition has an invalid value of ' value]);
            end
            
        end
        
        function value=get.shearwaveGeneratorPosition(sObj)
            value=sObj.caseObj.caseData.shearwave.vibratorPosition;
            
        end
        
        function value=get.peakFrequencyMap_Hz(sObj)
            value=sObj.peakFrequencyMap_Hz;
        end
        
        function value=get.peakFrequencyMap_Index(sObj)
            value=sObj.peakFrequencyMap_Index;
        end
        
        %a value of empty disables the override
        function value=set.tScanLineOverride_sec(sObj,value)
            sObj.tScanLineOverride_sec=value;
        end
        
        function value=get.peakFrequencyMap_Mag(sObj)
            value=sObj.peakFrequencyMap_Mag;
        end
        
        
        
    end
    
    methods (Access=private)
        
        %The output of this function will be a valid phase plot and
        %frequency
        function calcPhaseBlock(sObj,dataBlock)
            imgAngle_rad=angle(dataBlock(:,1:end,1:(end-1)).*conj(dataBlock(:,1:end,2:end)));
            imgAngleFilt_rad=zeros(size(imgAngle_rad));
            for k = 1:size(imgAngle_rad,3)
                imgAngleFilt_rad(:,:,k) = medfilt2(imgAngle_rad(:,:,k),[5,3]);
                imgAngleFilt_rad(:,:,k) = conv2(imgAngleFilt_rad(:,:,k),ones(10,1)/10,'same');  %axial averaging filter
            end
            sObj.phaseBlock=imgAngleFilt_rad-repmat(mean(imgAngleFilt_rad,3),[1, 1, size(imgAngleFilt_rad,3)]);
            sObj.phaseBlock=sObj.phaseBlock.*repmat(permute(hanning(size(imgAngleFilt_rad,3)),[3 2 1]),[size(imgAngleFilt_rad,1) size(imgAngleFilt_rad,2) 1]);
            sObj.phaseBlock=fft(sObj.phaseBlock,size(sObj.phaseBlock,3),3);
            sObj.phaseBlockFreqAxis_Hz=make_f(size(sObj.phaseBlock,3),sObj.caseObj.frameRate_Hz);
        end
        
        function velocitySign=velocityCorrectionSign(sObj)
            if isempty( sObj.shearwaveGeneratorPosition)
                error('shearwaveGeneratorPosition is not set');
            else
                switch(sObj.shearwaveGeneratorPosition)
                    case 'left'
                        %positive phase correction because the transducer is reading in the
                        %same direction as wave propagation.
                        velocitySign=1;
                    case 'right'
                        %negative phase correction because the transducer is reading in the
                        %opposite direction as wave propagation.
                        velocitySign=-1;
                    otherwise
                        error(['Invalid setting for shearwaveGeneratorPosition of ' sObj.shearwaveGeneratorPosition]);
                end
                
            end
        end
        
        
        function pStore=calcReflectionSuppresion(sObj,pStore,nt,Nt)
            %pStore contains (3xNt) frames. Each frame is (Nx x Ny)
            %% k-space
            switch(nargin)
                case 2
                    Nt = size(pStore,3); % I want to work on 100 frames only
                    nt = 1; % this means I will use frames from 101 to 200
                case 4
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            
            Nx = size(pStore,1);
            Ny = size(pStore,2);
            %% implement k_space filter to kill reflections in the y-direction
            for nx = 1:Nx
                Y = fft2(squeeze(pStore(nx,:,1+(nt-1)*Nt:nt*Nt)));
                Y = fftshift(Y);
                % generate the k_filter
                % [kfilt]=k_filter(N, Nsmooth) where Nsmooth is possibly an even number
                kfilt = k_filter([Ny,Nt],1);
                % apply filter to the k_space
                Y_filt = squeeze(Y).*kfilt;
                Y_filt = ifftshift((Y_filt));
                %     keyboard
                pStore(nx,:,1+(nt-1)*Nt:nt*Nt) = (ifft2(Y_filt));
            end
            %% implement k_space filter to kill reflections in the x-direction
            for ny = 1:Ny
                Y = fft2(squeeze(pStore(:,ny,1+(nt-1)*Nt:nt*Nt)));
                Y = fftshift(Y);
                % generate the k_filter
                % [kfilt]=k_filter(N, Nsmooth) where Nsmooth is possibly an even number
                kfilt = k_filter([Nx,Nt],1);
                % apply filter to the k_space
                Y_filt = squeeze(Y).*kfilt;
                Y_filt = ifftshift((Y_filt));
                %     keyboard
                pStore(:,ny,1+(nt-1)*Nt:nt*Nt) = (ifft2(Y_filt));
            end
        end
    end
    
    
    methods (Access=public)
        %This function creates the shearwave object and sets up the
        %input object.  Default values are set, but no data is loaded
        %
        %INPUT
        %caseObj - (string, swCaseObject, or empty) this specifies the input
        %data.  For the arguments used to generate caseObj the choices are
        %1. The raw rf data file (must have a .rf extension)
        %2. The case file (must have a .m) extension
        %Ex: loading a case file
        %>>shearwaveObjectswCase(swCase('c:\file.m'))
        %empty[] - this means the data block will be passed to it in
        %loadblock
        %
        %OUTPUT
        %sObj - the output object
        function sObj=shearwaveObject(caseObj,varargin)
            
            p = inputParser;   % Create an instance of the class.
            p.addRequired('caseObj',@(x) ischar(x) || isa(x,'swCase'));
            %             p.addParamValue('sampleFs_Hz',[],@(x) isnumeric(x) || isscalar(x));
            %             p.addParamValue('frameRate_Hz',[],@(x) isnumeric(x) || isscalar(x));
            %             swCase
            %             p.addParamValue('probeName',[],@(x) ischar(x) || isempty(x));
            %             probeName
            
            p.parse(caseObj,varargin{:});
            
            
            
            %rfFullPathFilename=[];
            sObj.caseObj=[];
            %first determine the type of argument
            if isempty(caseObj)
                error('This should have been caught.');
                
            else
                switch(class(caseObj))
                    case 'char'
                        sObj.caseObj=swCase(caseObj);
                        
                        %                         [filePath,fileBasename,fileExt]=fileparts(caseObj);
                        %                         switch(lower(fileExt))
                        %                             case '.rf'
                        %                                 sObj.objectType='rf';
                        %                                 rfFullPathFilename=fullfile(filePath,[fileBasename fileExt]);
                        %                             case '.m'
                        %                                 error('.m is not supported');
                        %                             otherwise
                        %                                 error(['Unsupported fileExt of: ' fileExt]);
                        %                         end
                    case 'swCase'
                        sObj.caseObj=caseObj;
                        
                    otherwise
                        error(['Unsupported class of ' class(caseObj)]);
                end
            end
            
            %             if isempty(sObj.objectType)
            %                 error('objectType should not be empty')
            %             end
            
            %             sObj.caseObj.rfFullPathFilename=rfFullPathFilename; %for now just the rf filename is saved as the input object
            %             [~,sObj.caseObj.rfHeader]=uread(rfFullPathFilename,-1);
            
            
        end
        
        %This function will load a block of data and process it.  The end
        %result will be the phase block but no phase map, shearwave info
        %etc.  You must run analyze for that
        %
        %INPUT
        %blockFrameList_base0 - the list of frames to load starting with a
        %first index of 0.
        %
        %blockStart_base0 is where to start loading the block.
        %blockLength is the number of frames in the block.
        %
        %dataBlock -  the raw data with the 1,2 dim for the (axial,lateral)
        %and the third dim is the frame number)
        function loadBlock(sObj,varargin)
            switch (nargin)
                case 1
                    sObj.blockFrameList_base0=(0:(size(sObj.dataBlock,3)-1));
                    sObj.dataBlock=varargin{1};
                case 2
                    sObj.blockFrameList_base0=varargin{1};
                    [sObj.dataBlock]=uread(sObj.caseObj.caseData.rfFilename,sObj.blockFrameList_base0,'frameFormatComplex',true);
                case 3
                    blockStart_base0=varargin{1};
                    blockLength=varargin{2};
                    sObj.blockFrameList_base0=(0:(blockLength-1))'+blockStart_base0;
                    [sObj.dataBlock]=uread(sObj.caseObj.caseData.rfFilename,sObj.blockFrameList_base0,'frameFormatComplex',true);
                otherwise
                    error('Invalid number of input arguments.');
            end
            if sObj.useReflectionSuppression
                %Run the reflection suppression code on the datablock
                sObj.dataBlock=sObj.calcReflectionSuppresion(sObj.dataBlock);
            else
                %do nothing
            end
            sObj.calcPhaseBlock(sObj.dataBlock);
        end
        
        %This si called by the user so the user must have run analayze
        %first
        function temporalFrequency_Hz=findTemporalFrequency_Hz(sObj)
            if strcmp(sObj.temporalFrequencyMode,'auto')
                
                
                %
                %                 %fft_frequency = peakIndex;
                %                 commonPeakIndex=mode(sObj.peakFrequencyMap_Index(:));
                %                 badPeakIdx=find(commonPeakIndex~=sObj.peakFrequencyMap_Index(:));
                %                 peaksNoMatch=length(badPeakIdx)/(size(sObj.peakFrequencyMap_Index,1)*size(sObj.peakFrequencyMap_Index,2));
                %
                %                 sObj.selectedPhaseBlockFreqBinIndex=commonPeakIndex;
                %
                %
                disp(['The most common frequency found is ' num2str(sObj.phaseBlockFreqAxis_Hz(sObj.selectedPhaseBlockFreqBinIndex)) 'Hz.'])
                disp([num2str(peaksNoMatch*100) '% of the freqs do not match']);
            else
                %no need to do anything to correct
            end
            temporalFrequency_Hz=sObj.phaseBlockFreqAxis_Hz(sObj.selectedPhaseBlockFreqBinIndex);
        end
        
        %Here you set how the analysis should be performed and what to
        %compute.
        %
        %INPUT
        %temporalFrequency_Hz - this is the temporal frequency to run the
        %phase map on.  If empty then it is automatically detected.
        %
        %
        function percentOfImageUsed=analyze(sObj,varargin)
            %             p = inputParser;   % Create an instance of the class.
            %             p.addParamValue('temporalFrequency_Hz',[],@(x) isscalar(x) && isnumeric(x));
            %             p.parse(varargin{:});
            
            
            
            if strcmp(sObj.temporalFrequencyMode,'auto')
                [sObj.peakFrequencyMap_Mag,sObj.peakFrequencyMap_Index]=max(abs(sObj.phaseBlock(:,:,1:floor(end/2))),[],3); %#ok<ASGLU>
                %                [peakVal,peakIndex]=max(abs(sObj.phaseBlock(:,:,1:floor(end/2))),[],3); %#ok<ASGLU>
                sObj.peakFrequencyMap_Hz=sObj.phaseBlockFreqAxis_Hz(sObj.peakFrequencyMap_Index);
                
                %fft_frequency = peakIndex;
                commonPeakIndex=mode(sObj.peakFrequencyMap_Index(:));
                badPeakIdx=find(commonPeakIndex~=sObj.peakFrequencyMap_Index(:));
                peaksNoMatch=length(badPeakIdx)/(size(sObj.peakFrequencyMap_Index,1)*size(sObj.peakFrequencyMap_Index,2));
                
                sObj.selectedPhaseBlockFreqBinIndex=commonPeakIndex;
                
                
                disp(['The most common frequency found is ' num2str(sObj.phaseBlockFreqAxis_Hz(sObj.selectedPhaseBlockFreqBinIndex)) 'Hz.'])
                disp([num2str(peaksNoMatch*100) '% of the freqs do not match']);
            else
                %no need to do anything to correct
            end
            
            savedState=sObj.useShearwaveCorrection;
            sObj.useShearwaveCorrection=false;
            sObj.calcShearwave;
            sObj.useShearwaveCorrection=savedState;
            
            if sObj.useShearwaveCorrection
                
                %to correct we compute the slowest (worst case) time
                %from the start of a scan line to the start of the next
                %scan line.
                %tScanLine_sec=(1/sObj.caseObj.frameRate_Hz)/size(sObj.phaseBlock,2);  %worst case
                
                if isempty(sObj.tScanLineOverride_sec)
                    distance_m=2*sObj.caseObj.axialStep_mm*sObj.caseObj.caseData.rf.header.h/1000;
                    tScanLine_sec=distance_m/1540;
                else
                    %tScanLine_sec= (2*2.5e-3)/1540; %m/(m/s)=s  %the 2.5
                    %should have been 25mm not 2.5mm
                    tScanLine_sec=sObj.tScanLineOverride_sec;
                end
                
                cf_rad=(2*pi*sObj.temporalFrequency_Hz)*ones(size(sObj.phaseBlock,1),1)*((0:(size(sObj.phaseBlock,2)-1))*tScanLine_sec);
                
                %                 repColLeft=find(~isinf(sObj.shearwaveSpeed_mPerSec(1,:)),1,'first');
                %                 repColRight=find(~isinf(sObj.shearwaveSpeed_mPerSec(1,:)),1,'last');
                %                 shearwaveVelocitySign=sObj.shearwaveSpeed_mPerSec;
                %
                %                 shearwaveVelocitySign(:,1:(repColLeft-1))=repmat(shearwaveVelocitySign(:,repColLeft),1,(repColLeft-1));
                %                 shearwaveVelocitySign(:,(repColRight+1):end)=repmat(shearwaveVelocitySign(:,repColRight),1,(size(shearwaveVelocitySign,2)-repColRight));
                %
                %                 %figure; imagesc(shearwaveVelocitySign); caxis([-2 10])
                %                 %figure; imagesc(cf_rad); colorbar
                %
                %                 if any(isinf(shearwaveVelocitySign(:)))
                %                     error('Not all the infinities were removed.');
                %                 end
                %                 %sObj.shearwaveCorrectionMap_rad=sign(shearwaveVelocitySign).*cf_rad;
                sObj.shearwaveCorrectionMap_rad=sObj.velocityCorrectionSign.*cf_rad;
                %figure; imagesc(sObj.shearwaveCorrectionMap_rad); colorbar
                sObj.calcShearwave;
                
            else
                %do nothing since already computed for the uncorrected
                %figure; imagesc(sObj.shearwaveSpeed_mPerSec); caxis([-2 10])
            end
            
            
            
            percentOfImageUsed=sum(sum(sObj.rRsq>=sObj.rsqThreshold))/(size(sObj.rRsq,1)*size(sObj.rRsq,2));
        end
        
        
        
        
        
        
        function calcShearwave(sObj)
            switch(sObj.calcShearwaveAlgorithm)
                case 'calcShearwaveAssumingPlaneWavePropagation'
                    sObj.calcShearwaveAssumingPlaneWavePropagation;
                case 'calcShearwaveWithDirection'
                    sObj.calcShearwaveWithDirection;
                otherwise
                    error(['Unsupported calcShearwaveAlgorithm of ' sObj.calcShearwaveAlgorithm]);
            end
            
        end
        
        %This function computes the shear wave based on a least squares fit
        %of the unwrapped phase horizontally.  This assumes that the data
        %was collected simultanously so it must be corrected.
        function calcShearwaveWithDirection(sObj)
            
            
            PhiBasic=sObj.imPhaseRaw_rad;
            
            
            %% c
            
            oversample=1;
            Phi=zeros(size(PhiBasic,1),size(PhiBasic,2)*oversample);
            xx=linspace(1,size(PhiBasic,2),oversample*size(PhiBasic,2));
            
            for rr=1:size(PhiBasic,1)
                pp=spline(1:size(PhiBasic,2),unwrap(PhiBasic(rr,:)));
                yy = ppval(pp,xx);
                Phi(rr,:)=yy;
            end
            %yy = polyval(pp,xx);
            
            if false
                figure;
                imagesc((Phi))
                hold on;
                plot(xx,yy,'r')
            end
            
            nt=1;
            % dh = spatial step
            %This is only for the case for a line density of 64 and a sector size of 50%
            %there end up being 33 pixel columns.  So for each pixel we have the line
            %distance as 18.2/33=0.55mm
            dh_x=0.55e-3;
            dh_y=mean(diff(sObj.axialAxis_mm))*1e-3;
            %[gradPhiX(:, :, nt),gradPhiY(:, :, nt)] = gradient(unwrap(Phi(:,:,nt)));  % estimate the gradient of the unwrapped phase
            [gradPhiX(:, :, nt),gradPhiY(:, :, nt)] = gradient((Phi(:,:,nt)));  % estimate the gradient of the unwrapped phase
            
            %Here comFreq is the peak frequency in Hz of the entire
            %cs(:, :, nt)= 2*pi*dh./(gradPhiX(:, :, nt)).*sObj.temporalFrequency_Hz(:,:,nt); % estimate speed (old fashion: the formula we are using now)
            cs(:, :, nt)= 2*pi*(dh_x/oversample)./(gradPhiX(:, :, nt)).*mean(mean(sObj.temporalFrequency_Hz(:,:,nt))); % estimate speed (old fashion: the formula we are using now)
            
            %Theta(:, :, nt) = atan(((dh_x/oversample)*gradPhiY(:, :, nt))./(dh_y*gradPhiX(:, :, nt))); % angle between x-axis(lateral distance) and the normal to the iso-phase (direction of wave propagation)
            Theta(:, :, nt) = atan((dh_y*gradPhiX(:, :, nt))./((dh_x/oversample)*gradPhiY(:, :, nt))); % angle between x-axis(lateral distance) and the normal to the iso-phase (direction of wave propagation)
            %Theta(:, :, nt) = atan2(((dh_x/oversample)*gradPhiY(:, :, nt)),(dh_y*gradPhiX(:, :, nt))); % angle between x-axis(lateral distance) and the normal to the iso-phase (direction of wave propagation)
            cs_correct = cs(:,:,nt).*cos(Theta(:,:,nt)); % correct the speed accounting for the angle of propagation
            cs_correctFiltered=medfilt2(cs_correct,[119 3])
            sObj.shearwaveSpeed_mPerSec=cs_correct;
            
        end
        
        
        function calcShearwaveAssumingPlaneWavePropagation(sObj)
            unwrappedFrameOfInterest_rad=sObj.imPhase_rad;  %The phase is unwrapped
            
            runLength=sObj.shearwaveRunLength;
            startStopIdx=[1 (size(unwrappedFrameOfInterest_rad,2)-runLength)];
            rSlope=zeros(size(unwrappedFrameOfInterest_rad));
            rIntercept=zeros(size(unwrappedFrameOfInterest_rad));
            sObj.rRsq=zeros(size(unwrappedFrameOfInterest_rad));
            
            
            calcShearwaveMethod='ls';
            switch(calcShearwaveMethod)
                case 'regress'
                    regressFitMap=@(y) regress(y',[ ones(length(y),1) (0:(length(y)-1))']);
                    
                    for ii=startStopIdx(1):startStopIdx(2)
                        dataForFit=mat2cell(unwrappedFrameOfInterest_rad(:,ii:(ii+runLength-1)),repmat(1,size(unwrappedFrameOfInterest_rad,1),1),repmat(runLength,1,1)); %#ok<RPMT1>
                        [rbList,rbintList,rrList,rrintList,rstatList] =cellfun(regressFitMap,dataForFit,'UniformOutput',false); %#ok<ASGLU>
                        
                        rbLine=cell2mat(rbList')';
                        rstatList=cell2mat(rstatList);
                        rSlope(:,ii+(runLength-1)/2)=rbLine(:,2);
                        rIntercept(:,ii+(runLength-1)/2)=rbLine(:,1);
                        sObj.rRsq(:,ii+(runLength-1)/2)=rstatList(:,1);
                        
                    end
                    
                case 'ls'
                    
                    A=[ones(1,runLength); 0:(runLength-1)]';
                    Ap=pinv(A'*A)*A';
                    tic
                    for ii=startStopIdx(1):startStopIdx(2)
                        dataForFit=mat2cell(unwrappedFrameOfInterest_rad(:,ii:(ii+runLength-1)),repmat(1,size(unwrappedFrameOfInterest_rad,1),1),repmat(runLength,1,1)); %#ok<RPMT1>
                        
                        fbi=cellfun(@(x) Ap*x.',dataForFit,'UniformOutput',false);
                        Y=cell2mat(dataForFit).';
                        residuals=A*cell2mat(fbi.')-Y;
                        % There are several ways to compute R^2, all equivalent for a
                        % linear model where X includes a constant term, but not equivalent
                        % otherwise.  R^2 can be negative for models without an intercept.
                        % This indicates that the model is inappropriate.
                        SSE = sum((residuals).^2);              % Error sum of squares.
                        TSS = sum((Y-repmat(mean(Y),size(Y,1),1)).^2);     % Total sum of squares.
                        sObj.rRsq(:,ii+(runLength-1)/2) = reshape(1 - SSE./TSS,[],1);            % R-square statistic.
                        
                        %figure; plot(fRsq/max(fRsq),'b'); hold('on'); plot(rstatList(:,1)/max(rstatList(:,1)),'r:');
                        
                        rbLine=cell2mat(fbi')';
                        
                        
                        rSlope(:,ii+(runLength-1)/2)=rbLine(:,2);
                    end
                otherwise
                    error(['Unsupported calcShearwaveMethod of ' calcShearwaveMethod]);
            end
            
            %This is only for the case for a line density of 64 and a sector size of 50%
            %there end up being 33 pixel columns.  So for each pixel we have the line
            %distance as 18.2/33=0.55mm
            %keyboard
            rslope_mm=(rSlope/0.55); %(rad/column)/(0.55mm/column) =rad/mm
            sObj.shearwaveSpeed_mPerSec=(2*pi*sObj.temporalFrequency_Hz)./rslope_mm/1000; %(rad/sec)/(rad/mm)*(1m/1000mm)=m/sec
            
            
            
        end
        
        function im=imBmode(sObj,index_base1)
            im=abs(sObj.dataBlock(:,:,index_base1));
        end
        
        function im=imPhase_rad(sObj)
            if ~sObj.useShearwaveCorrection || isempty(sObj.shearwaveCorrectionMap_rad)
                im=unwrap(angle(sObj.phaseBlock(:,:,sObj.selectedPhaseBlockFreqBinIndex)),[],2);
            else
                im=unwrap(angle(sObj.phaseBlock(:,:,sObj.selectedPhaseBlockFreqBinIndex)),[],2)+sObj.shearwaveCorrectionMap_rad;
            end
        end
        
        
        %The raw phase has the shearwave correction applied to the raw
        %phase, this is unlike imPhase_rad
        function im=imPhaseRaw_rad(sObj)
            if ~sObj.useShearwaveCorrection || isempty(sObj.shearwaveCorrectionMap_rad)
                im=angle(sObj.phaseBlock(:,:,sObj.selectedPhaseBlockFreqBinIndex));
            else
                im=angle(sObj.phaseBlock(:,:,sObj.selectedPhaseBlockFreqBinIndex))+sObj.shearwaveCorrectionMap_rad;
            end
            
        end
        function im=imPhase_mag(sObj)
            
            %Really the phase correct should not change the magnitude
            %values
            if ~sObj.useShearwaveCorrection || isempty(sObj.shearwaveCorrectionMap_rad)
                im=abs(sObj.phaseBlock(:,:,sObj.selectedPhaseBlockFreqBinIndex));
            else
                im=abs(sObj.phaseBlock(:,:,sObj.selectedPhaseBlockFreqBinIndex)+sObj.shearwaveCorrectionMap_rad);
            end
            
            
        end
        
        
        
        function im=imRsq(sObj)
            im=sObj.rRsq;
        end
        
        function setSampleFs_Hz(sObj,value) % Handle class
            if ~strcmp(sObj.objectType,sObj.validObjectType_Data)
                warning('shearwaveObject:cannotSet','Cannot set property because object must be data type');
            else
                sObj.sampleFs_Hz=value;
            end
        end
        
        function im=imShearSpeed_mPerSec(sObj)
            im=sObj.shearwaveSpeed_mPerSec;
            im(sObj.rRsq<sObj.rsqThreshold)=-inf;
            
        end
        
        function freqLine_Hz=imPhaseIndexFreqProfile_Hz(sObj,axialIndex,lateralIndex)
            freqLine_Hz=squeeze(sObj.phaseBlock(axialIndex,lateralIndex,:));
        end
        
        function value=frequencyMapEnergy(sObj)
            [value]=sum(abs(sObj.phaseBlock(:,:,:)),3);
        end
        
    end
    
end

