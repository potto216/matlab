function  maxFrames=phantomGetTotalFrames(objPhantom)
%phantomGetTotalFrames Compute the total number of frames in the sequence
%
%INPUT
%objPhantom
%
%OUTPUT
%maxFrames - the total number of frames in the sequence


switch(objPhantom.name)
    case 'tendon'        
        error('Please Add');              
        
    case {'rectusFemoris','rectusFemoris_sphereScatter','rectusFemoris_fascicle'} %models and their subtypes
        maxFrames=length(objPhantom.rectusFemoris.motion.offset_m);        
        
    case 'trapezius'        
        error('Please Add');
        
    case 'cyst'        
       maxFrames=length(objPhantom.parameters.offset_mPerSec);
        
    otherwise
        error(['The phantom name of ' objPhantom.name ' is not supported.'])
end

end

