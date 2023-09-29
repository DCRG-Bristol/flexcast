classdef Fuel
    %ENGINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        SpecificEnergy
        CostPerKilo
    end
    methods
        function obj = Fuel(Name,SpecificEnergy,CostPerKilo)
            obj.Name = Name;
            obj.SpecificEnergy = SpecificEnergy;
            obj.CostPerKilo = CostPerKilo;
        end
    end
    
    methods(Static)  
        function obj = LH2()
            obj = cast.config.Fuel("LH2",120,4.016);
        end
        function obj = JA1()
            obj = cast.config.Fuel("JA1",43.2,1.009);
        end
    end
end

