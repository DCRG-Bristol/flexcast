classdef LoadsSurrogate < cast.size.AbstractLoads
    %BASESIZING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %baff model
        fe ads.fe.Component = ads.fe.Component.empty;
    end

    properties
        CleanUp logical = true
        Silent logical = true
        BinFolder string = "";
        Verbose logical = false;

    end

    properties(Abstract)
        Tags
    end
    
    methods
    end
end

