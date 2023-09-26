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
        FuelBurn_Design

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
    end
    methods
        function PrintInfo(obj)
            m = [];
            m(1) = obj.PAX;
            m(end+1) = obj.Range_Design.*cast.SI.Nmile;
            m(end+1) = obj.Range_harm.*cast.SI.Nmile;
            m(end+1) = obj.Range_asym.*cast.SI.Nmile;
            m(end+1) = obj.Range_ferry.*cast.SI.Nmile;
            m(end+1) = obj.MTOM.*cast.SI.Tonne;
            m(end+1) = obj.Payload.*cast.SI.Tonne;
            m(end+1) = obj.Payload_asym.*cast.SI.Tonne;
            m(end+1) = obj.MZFM.*cast.SI.Tonne;
            m(end+1) = obj.MLND.*cast.SI.Tonne;
            m(end+1) = obj.Fuel_capacity.*cast.SI.Tonne;
            m(end+1) = obj.FuelBurn_Design.*cast.SI.Tonne;
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
    end
end

