classdef GroundOp < cast.mission.Segment
    %STARTUP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TaxiTime = 20./SI.min;
        TakeOffTime = 1./SI.min;
    end
    
    methods
        function obj = GroundOp()
        end
    end
    methods(Static)
        function obj = FromGate()
            obj = cast.mission.GroundOp();
        end
        function obj = ToGate()
            obj = cast.mission.GroundOp();
            obj.TaxiTime = 15./SI.min;
            obj.TakeOffTime = 0./SI.min;
        end
    end
end

