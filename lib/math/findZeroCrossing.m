function [ shiftForZero ] = findZeroCrossing( velocity_mmPerSec )
%FINDZEROCROSSING Summary of this function goes here
%   Detailed explanation goes here
            zeroCrossings=crossing(velocity_mmPerSec);
            
            beforeMriShiftForZero=mod(zeroCrossings-100,length(velocity_mmPerSec));
            afterMriShiftForZero=mod(zeroCrossings+100,length(velocity_mmPerSec));
            
            %slopeMeasure=diff(filtfilt(hamming(200),1,velocity_mmPerSec));
            avgMeasure=(filtfilt(ones(200,1),1,velocity_mmPerSec));
            if false
                figure;
                subplot(1,2,1)
                plot(avgMeasure,'b');
                hold on
                plot(beforeMriShiftForZero,avgMeasure(beforeMriShiftForZero),'ob');
                plot(zeroCrossings,avgMeasure(zeroCrossings),'og');
                plot(afterMriShiftForZero,avgMeasure(afterMriShiftForZero),'or');
                
                
                subplot(1,2,2)
                plot(velocity_mmPerSec,'b');
                hold on
                plot(beforeMriShiftForZero,velocity_mmPerSec(beforeMriShiftForZero),'ob');
                plot(zeroCrossings,velocity_mmPerSec(zeroCrossings),'og');
                plot(afterMriShiftForZero,velocity_mmPerSec(afterMriShiftForZero),'or');
                
            end
            
            mriShiftForZeroBest=zeroCrossings(find((avgMeasure(beforeMriShiftForZero)>0) & (avgMeasure(afterMriShiftForZero)<0)));
            mriShiftForZeroBest=mriShiftForZeroBest(1);
            shiftForZero=length(velocity_mmPerSec)-mriShiftForZeroBest;

end

