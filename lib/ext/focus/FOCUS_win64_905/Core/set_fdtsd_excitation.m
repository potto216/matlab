function excitation=set_fdtsd_excitation(signal, sample_period, spectral_clipping_threshold)
%argument order is [signal, sample_period, pulse_width, spectral_clipping_threshold]
% signal: A 1-D vector containing the excitation function's value at each
% time point
% sample_period: The time between samples in seconds
% spectral_clipping_threshold: The threshold below which FFT values will be
% ignored. Negative values are assumed to be in dB, positive values should
% be between 0 and 1.

if (nargin() ~= 3)
	error('This function requires exactly 3 arguments: set_fdtsd_signal(signal, sample_period, spectral_clipping_threshold).');
else
    excitation.signal = signal;
    excitation.ts = sample_period;
    excitation.w = sample_period * length(signal);
    excitation.clip_threshold = spectral_clipping_threshold;
end
end
