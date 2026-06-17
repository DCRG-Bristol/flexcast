classdef Oswald < cast.aero.AbstractPolar
    %OSWALD Summary of this class goes here
    %   Detailed explanation goes here

    properties
        e   % Oswald efficency factor
        CD0 
    end

    methods
        function obj = Oswald(e)
            %OSWALD Construct an instance of this class
            %   Detailed explanation goes here
            obj.e = e;
        end
        function Cd0  = Get_Wing_Cd0(obj)
            Cd0 = obj.CD0; % Retrieve the zero-lift drag coefficient
        end
        function Cd = Get_Cd(obj,Cl,~,~)
            Cd = obj.CD0 + (Cl^2 / (pi * obj.e)); % Example formula for drag coefficient
        end
    end
end