%This fucntion will execute a list of instructions sequenctially.  The
%called functions cannot take any parameters
function lseq(varargin)
for ii=1:length(varargin)
    varargin{ii}();
end
end