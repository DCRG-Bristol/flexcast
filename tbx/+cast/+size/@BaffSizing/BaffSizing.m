classdef BaffSizing < handle
    %AircraftSizing Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %baff model
        Baff baff.Model = baff.Model.empty;
        WingBoxParams cast.size.WingBoxSizing = cast.size.WingBoxSizing.empty;
        Name = '';
        RibPitch = 0.6;

        LoadsSurrogate cast.size.AbstractLoads = cast.size.NullLoads.empty;


    end

    properties(Abstract)
        Tags
    end
    
    methods
    end
end

