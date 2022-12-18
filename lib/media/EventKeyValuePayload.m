classdef EventKeyValuePayload < event.EventData
    %NEWPROCESSSTREAMEVENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        keyValuePayload
    end
    
    methods
        function this = EventKeyValuePayload(varargin)
            this.keyValuePayload=varargin;
        end
    end
    
end

