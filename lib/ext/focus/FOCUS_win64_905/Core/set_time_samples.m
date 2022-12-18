function time_struct = set_time_samples(varargin)
%function time_struct = set_time_samples(varargin)
% time_struct = set_time_samples; no arguments given - enter values at the command prompt
% time_struct = set_time_samples(time_sample_vector); one argument given - time samples are
% contained in 'time_sample_vector'
% time_struct = set_time_samples(deltat, tmin, tmax); three arguments
% given, where the first indicates the uniform time spacing and (tmin,
% tmax) specify the time duration.
% 
% set_time_samples([t1 t2 t3]) is quite different from set_time_samples(deltat, tmin, tmax) - 
% note that the input consists of 3 comma separated values and not a vector
% in the latter case.

if nargin()==0,
	disp('Enter the following variables:')
	disp('deltat, tmin, tmax')
	deltat = input('deltat: ');
	tmin = input('tmin: ');
	tmax = input('tmax: ');
	time_struct = set_time_samples(deltat, tmin, tmax);
    
elseif nargin()==3,    
    time_struct.deltat = varargin{1};
    time_struct.tmin = varargin{2};
    time_struct.tmax = varargin{3};

%    time_struct.vector_flag = -1; % not a vector of time points

    if time_struct.deltat < 0,
        error('deltat must be nonnegative, but %f given', time_struct.deltat)
    end

    if (time_struct.tmin > time_struct.tmax),
        error('min time value must be < max time value')
    elseif (time_struct.tmin == time_struct.tmax),
% make sure subsequent codes avoid divide by zero problems by
% forcing dt = 0 when there is only one time sample 
        time_struct.deltat = 0;
    end

elseif nargin()==1, % vector containing the time samples
    time_struct.time_samples = varargin{1};
    ifind = find(diff(time_struct.time_samples) <= 0);
    if ~isempty(ifind),
        if length(time_struct.time_samples) == 3,
            disp(' ');
            warning('WARNING! Warning: In FOCUS, the behavior of set_time_samples([t1 t2 t3]) is quite different from set_time_samples(deltat, tmin, tmax) - note that the input consists of 3 comma separated values and not a vector in the latter case.')
            disp(' ');
        end
        error('expecting strictly increasing values for the vector of time samples in ''set_time_samples''\n, but the values decreased at index %d and in %d other location(s)', ifind(1) + 1, length(ifind) - 1);
    end

%    time_struct.deltat = 0; % prefer not to do it this way
%    time_struct.tmin = 0;
%    time_struct.tmax = 0;

%    time_struct.vector_flag = 1;

    return
    
else
    error('incorrect number of arguments for ''set_time_samples''\n  expecting 0, 1, or 3 input arguments, but %d given', nargin())

end



