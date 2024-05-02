classdef Contingency < cast.mission.Segment
    %CRUISE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartAlt
        Time
        Mach
    end
    
    methods
        function obj = Contingency(StartAlt,Time,Mach)
             obj.StartAlt = StartAlt;
             obj.Time = Time;
             obj.Mach = Mach;
        end
    end
end

