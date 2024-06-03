classdef Cruise < cast.mission.Segment
    %CRUISE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartAlt
        Range
        Mach
        CAS = nan
    end
    
    methods
        function obj = Cruise(StartAlt,Range,Mach,CAS)
            arguments
                StartAlt
                Range
                Mach
                CAS = nan;
            end
             obj.StartAlt = StartAlt;
             obj.Range = Range;
             obj.Mach = Mach;
             obj.CAS = CAS;
        end
    end
end

