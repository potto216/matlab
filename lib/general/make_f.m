% MAKE_F Computes the frequencies evaluated by the FFT.
%     MAKE_F Computes the frequencies evaluated by the FFT when given the
%     number of samples and the sample rate.  This function correctly
%     handles when N is odd or even (when it is evaluated at fs/2 or not).
%     Rememeber to apply FFTSHIFT to the output if you apply FFTSHIFT to
%     the FFT.
%  
%     f = MAKE_F(N,fs) returns N frequencies between (or at) -fs/2 to fs/2
%     
%  Examples:
%    >> [f]=make_f(4,4) %returns 0, 1*fs/4, 2*fs/4, 3*fs/4,
%
%  See also FFT, FFTSHIFT

% Author: Paul Otto
%  $Revision: 1.0 $Date: 2005/04/21 yyyy/mm/dd $
function [f]=make_f(N,fs)
%Compute the frequencies evaluted by the fft.  These are (for example N=4)
%0, 1*fs/4, 2*fs/4, 3*fs/4,
%f=[0:length(Pxx)-1]*(fs/length(Pxx));
f=[0:N-1]*(fs/N);

% now we have to adjust the frequencies correctly.
% If even, the frequency range should be remapped from
% [0 ... fs/2 ... fs-delta]=>[0 ... -fs/2 ... -delta]
% This is done by noting the fs/2 falls at the middle + 1.
% If odd, the frequency range should be remapped from
% [0 ... fs/2-delta ... fs-delta]=>[0 fs/2+delta ... -delta]
% This is done by noting the fs/2-delta falls at the middle + 1.

neg_freq_start=(length(f)+mod(length(f),2))/2+1;
f(neg_freq_start:end)=f(neg_freq_start:end)-fs;

% if iseven(length(f))
%     f(fix(end/2)+1:end)=f(fix(end/2)+1:end)-fs;
% else %if odd
%     f(fix(end/2)+1+1:end)=f(fix(end/2)+1+1:end)-fs;
% end

