classdef NullPolar < cast.aero.AbstractPolar
    %NULLPOLAR Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function Cd0  = Get_Wing_Cd0(obj)
            error('Not implemented');
        end
        function Cd = Get_Cd(obj,Cl,~,~)
            error('Not implemented');
        end
    end
end