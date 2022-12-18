function signal = get_chirp(f1, f2, dt, w)
%GENERATE_CHIRP Generate a chirp signal and return a set of time samples
%describing it

% Initialize the signal to zeros
nsamples = ceil(w/dt);
signal = zeros(1,nsamples);
k = (f2 - f1) / w;
% Calculate the value of the signal at each time point
for i = 1:nsamples
    t = dt*i;
    signal(i) = sin(2*pi*(f1*t + k/2 * t^2));
end
end
