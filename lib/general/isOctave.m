%Searches for a package name of Octave
function [octaveOnlyRunning]=isOctave()

ocatveFound=~isempty(ver('Octave'));
matlabFound=~isempty(ver('Matlab'));

if ocatveFound && matlabFound
	warning('Found both Matlab and Octave in the version information so assuming Octave is running.')
	octaveOnlyRunning=true;
elseif ~ocatveFound && matlabFound
	octaveOnlyRunning=false;
elseif ocatveFound && ~matlabFound
	octaveOnlyRunning=true;
elseif ocatveFound && matlabFound
	error('Version did not find either Matlab or Octave')
end

return