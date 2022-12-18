%########################################################################%
%
% Function:  value = TwosComplement(x, numBits)
%
% Purpose:  value = TwosComplement(x, numBits) computes the two's
%           complement value from an unsigned integer value input, where
%           the number of bits of the input must be specified.
%
% Notes:   There is a difference between the number of bits used to
%          represent a number in Matlab, and the number of bits allocated
%          for a particular integer that you are decoding.  Matlab normally
%          represents everything in double precision, which is usually 64
%          bits.  However, to make this routine able to accomodate cases
%          where the machine word length is different.
%
% Author:  Chad Webb
% Date:    07 May 2007
%########################################################################%
function value = TwosComplement(x, numBits)

    % Check the value of the MSB.  To accomodate any data word size, we
    % perform bit shifting operations, rather than trying select the
    % position of the bit
    msb = bitshift(x, -(numBits - 1) );
    
    % A negative number will have a '1' for the MSB.  A positive number
    % will simply have the same output as the input.
    if (true == msb)
        % Dealing with a negative number.  To determine what
        % it is a negative of, take the one's complement and
        % add 1, per standard 2's complement encoding convention
        value = -1 * ( bitcmp(x, numBits) + 1 );
    else
        value = x;
    end
    
end