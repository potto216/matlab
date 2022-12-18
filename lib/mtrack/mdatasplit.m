%This function takes a data file which is a collection of frames and will
%split it into multiple frame files in the MAT format and which contains
%the meta-information.  This allows for overlap of frames between files so
%the tracking algorithms can be primed with whatever priori information
%that they need.
%
%The method also has the ability to create new run data files by finding
%the location the file is specified and then replacing it with the split
%file.  The new data file is given a new name postfixed with an underline
%that indicates the order the files should be recombined.
%
%When the method saves the frame information it will save the as
function mdatasplit

end