classdef Loiter < cast.mission.Segment
    %CRUISE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartAlt
        Time
        Mach
        e_delta = 0;
    end
    
    methods
        function obj = Loiter(StartAlt,Time,Mach,e_delta)
            arguments
                StartAlt
                Time
                Mach
                e_delta = 0;
            end
            obj.StartAlt = StartAlt;
            obj.Time = Time;
            obj.Mach = Mach;
            obj.e_delta = e_delta;
        end
    end
end

