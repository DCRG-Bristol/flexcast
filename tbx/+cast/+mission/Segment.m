classdef Segment < matlab.mixin.Heterogeneous
    %SEMENT Summary of this class goes here
    %   Detailed explanation goes here
    properties
        WingConfig cast.aero.WingConfig = cast.aero.WingConfig.Clean;
    end
    methods
        function obj = setConfig(obj,WingConfig)
            arguments
                obj
                WingConfig cast.aero.WingConfig
            end
            obj.WingConfig = WingConfig;
        end
    end
end

