%  Make the scatteres for a simulation and store
%  it in a file for later simulation use

%   Joergen Arendt Jensen, Feb. 26, 1997

[phantom_positions, phantom_amplitudes] = feu_pha(2000);
save pht_data.mat phantom_positions phantom_amplitudes
