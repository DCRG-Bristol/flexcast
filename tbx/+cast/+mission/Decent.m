classdef Decent < cast.mission.Segment
    %CLIMB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartAlt;
        EndAlt;
        ROC;
        Mach;
        Percentage = nan;
    end
    
    methods
        function obj = Decent(StartAlt,EndAlt,ROC)
            obj.StartAlt = StartAlt;
            obj.EndAlt = EndAlt;
            obj.ROC = ROC;
        end
    end
end
