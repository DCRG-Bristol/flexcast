classdef BaseSizing < handle
    %BASESIZING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %baff model
        Baff baff.Model = baff.Model.empty;
        fe ads.fe.Component = ads.fe.Component.empty;
        WingBoxParams cast.size.WingBoxSizing = cast.size.WingBoxSizing.empty;
        Name = '';
    end

    properties(Abstract)
        Tags
    end
    
    methods
    end
end

