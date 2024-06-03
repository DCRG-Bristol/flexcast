classdef Meta
    %META Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % paylaod
        PAX
        Crew
        Payload
        Payload_asym


        Range_Design
        Range_harm
        Range_asym
        Range_ferry


        MTOM
        MZFM
        MFRES
        MLND
        OEM


        Fuel_capacity
        Fuel_block
        Fuel_trip

        WingArea
        Span
        AspectRatio
        Length
        FuselageRadius

        Thrust
        SpecificEnergy
        CostPerKilo

        M_c % cruise Mach number
        Alt_max % max altitude in m
        Alt_cruise

        % Aero
        LD_c
        CD0
        CL_c
        e

        HingeEta
    end
    methods
        function m = PrintInfo(obj)
            m = [];
            m(1) = obj.PAX;
            m(end+1) = obj.Range_Design.*cast.SI.Nmile;
            m(end+1) = obj.Range_harm.*cast.SI.Nmile;
            m(end+1) = obj.Range_asym.*cast.SI.Nmile;
            m(end+1) = obj.Range_ferry.*cast.SI.Nmile;
            m(end+1) = obj.MTOM.*cast.SI.Tonne;
            % m(end+1) = obj.OEM.*cast.SI.Tonne;
            m(end+1) = obj.Payload.*cast.SI.Tonne;
            m(end+1) = obj.Payload_asym.*cast.SI.Tonne;
            m(end+1) = obj.MZFM.*cast.SI.Tonne;
            m(end+1) = obj.MLND.*cast.SI.Tonne;
            m(end+1) = obj.Fuel_capacity.*cast.SI.Tonne;
            m(end+1) = obj.Fuel_block.*cast.SI.Tonne;
            m(end+1) = obj.Fuel_trip.*cast.SI.Tonne;
            m(end+1) = obj.WingArea;
            m(end+1) = obj.Span;
            m(end+1) = obj.AspectRatio;
            m(end+1) = obj.Length;
            m(end+1) = obj.FuselageRadius;
            m(end+1) = obj.Thrust;
            m(end+1) = obj.SpecificEnergy;
            m(end+1) = obj.CostPerKilo;
            m(end+1) = obj.CL_c;
            m(end+1) = obj.LD_c;
            m(end+1) = obj.e;
            m(end+1) = obj.CD0.*cast.SI.DragCount;
            num2clip(m');
        end
        function m = PrintNames(obj)
            m = "PAX";
            m(end+1) = "Design Range [nm]";
            m(end+1) = "Harmonic Range [nm]";
            m(end+1) = "Asym. Range [nm]";
            m(end+1) = "Ferry Range [nm]";
            m(end+1) = "MTOM [tn]";
            % m(end+1) = "OEM [tn]";
            m(end+1) = "Payload [tn]";
            m(end+1) = "Payload Asym. [tn]";
            m(end+1) = "MZFM [tn]";
            m(end+1) = "MLND [tn]";
            m(end+1) = "Fuel Cap. [tn]";
            m(end+1) = "Block Fuel [tn]";
            m(end+1) = "Trip Fuel [tn]";
            m(end+1) = "Wing Area [m]";
            m(end+1) = "Wingspan [m]";
            m(end+1) = "Aspect Ratio";
            m(end+1) = "Length [m]";
            m(end+1) = "Fus. Radius [m]";
            m(end+1) = "Thrust [N]";
            m(end+1) = "Specific Energy";
            m(end+1) = "Cost per Kilo";
            m(end+1) = "C_l cruise";
            m(end+1) = "L/D Cruise";
            m(end+1) = "oswald eff. Factor";
            m(end+1) = "CD0 [cnts]";
            clipboard('copy',strjoin(m,'\n'))
        end
    end
end

