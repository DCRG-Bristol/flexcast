classdef Cruise < cast.mission.Segment
    %CRUISE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartAlt
        Range
        Mach
    end
    
    methods
        function obj = Cruise(StartAlt,Range,Mach)
             obj.StartAlt = StartAlt;
             obj.Range = Range;
             obj.Mach = Mach;
        end
    end
end

