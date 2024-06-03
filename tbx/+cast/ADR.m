classdef ADR
    %ADP Aircraft Design Requirements
    
    properties
        PAX
        Crew
        Range
        Payload
        ExtraPayload = 0;
        CrewMass
        V_app % approach speed
        V_climb % climb speed (CAS)
        GroundRun
        GroundRunLanding
        M_c % cruise Mach number
        Alt_max % max altitude in m
        Alt_cruise
    end

    properties
        M_alt % Mach number at each alititude to be limited by either M_c or V_climb
    end

    % alternate airport diversion properties
    properties
        Alt_alternate = 22e3./cast.SI.ft;
        Range_alternate = 200./cast.SI.Nmile;
        Loiter = 30./cast.SI.min; % 30 minutes in seconds
    end
    methods(Static)
        function obj = A320(PAX,Range,TargetPayload)
            arguments
                PAX
                Range
                TargetPayload = nan;
            end
            obj = cast.ADR();
            obj.PAX = PAX;
            obj.Range = Range./cast.SI.Nmile;% m (from nautical miles)
            obj.GroundRun = 2100; %m
            obj.GroundRunLanding = 1500; %m
            obj.M_c = 0.78;
            obj.Alt_max = 39e3./cast.SI.ft; %m (39,000ft)
            obj.Alt_cruise = 31e3./cast.SI.ft;
            obj.Crew = 2 + ceil(PAX/50);
            if ~isnan(TargetPayload)
                obj.Payload = TargetPayload;
                obj.ExtraPayload = obj.Payload - (82+20)*obj.PAX;
                if obj.ExtraPayload<0
                    warning("passenger payload greater than target payload")
                end
            else
                obj.Payload = (80+luggage)*obj.PAX;
                obj.ExtraPayload = 0;
            end
            obj.CrewMass = (80+10)*obj.Crew;
            obj.V_app = 100;
            obj.V_climb = 290/cast.SI.knt;
        end
    end
end

