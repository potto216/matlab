function c = fftconv(a, b)

n_c = pow2(nextpow2(length(a)+length(b)-1));
c=ifft(reshape(fft(a,n_c),1,n_c).*reshape(fft(b,n_c),1,n_c),'symmetric');
c=c(1:length(a)+length(b)-1);
