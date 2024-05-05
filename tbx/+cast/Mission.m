classdef Mission
    %MISSION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Segments cast.mission.Segment
    end

    methods
        function obj = Mission()
        end
    end
    methods(Static)
        function obj = StandardWithAlternate(ADR,Range)
            arguments
                ADR
                Range = ADR.Range;
            end
            FL015 = 1500./cast.SI.ft;
            CR015 = 1500./cast.SI.ft.*cast.SI.min; % climb rate of 1500ft/min in SI;
            CR020 = 2000./cast.SI.ft.*cast.SI.min; % climb rate of 1500ft/min in SI;
            % approach data
            [rho_a,a_a,T_a,P_a,nu_a,z_a,sigma_a] = ads.util.atmos(FL015);
            % make mission profile
            obj = cast.Mission();
            %% trip fuel
            obj.Segments(1) = cast.mission.GroundOp.FromGate();
            % check if climb and decent are too long
            Alt_c = ADR.Alt_cruise;
            if Range == 0
                obj.Segments(2) = cast.mission.Climb(0,0,CR015);
                obj.Segments(3) = cast.mission.Cruise(0,0,ADR.M_c);
                obj.Segments(4) = cast.mission.Decent(0,0,CR020);
                obj.Segments(5) = cast.mission.Decent(0,0,CR020);
                obj.Segments(6) = cast.mission.GroundOp.ToGate();
            else
                while true
                    % get max altitude you can reach on alternate flight
                    obj.Segments(2) = cast.mission.Climb(0,Alt_c,CR015);
                    obj.Segments(4) = cast.mission.Decent(Alt_c,FL015,CR020);
                    r = obj.Segments(2).distanceEstimate(ADR.M_c) + obj.Segments(4).distanceEstimate(ADR.M_c);
                    if r>Range
                        Alt_c = Alt_c-1000/cast.SI.ft;
                        if Alt_c<0
                            error('Cannot reach cruise altitude with given range')
                        end
                    else
                        obj.Segments(3) = cast.mission.Cruise(Alt_c,Range-r,ADR.M_c);
                        break
                    end
                end
                % landing
                obj.Segments(5) = cast.mission.Decent(FL015,0,0.03*ADR.V_app); % Land (3% gradient)
                obj.Segments(6) = cast.mission.GroundOp.ToGate();
            end

            %% contingency fuel
            obj.Segments(7) = cast.mission.Contingency(FL015,5./cast.SI.min,ADR.V_app/a_a); % Reserve fuel
            %% alternate fuel
            Alt_alternate = ADR.Alt_alternate;
            while true
                % get max altitude you can reach on alternate flight
                obj.Segments(8) = cast.mission.Climb(FL015,Alt_alternate,CR015);
                obj.Segments(10) = cast.mission.Decent(Alt_alternate,FL015,CR020);
                r = obj.Segments(8).distanceEstimate(ADR.M_c) + obj.Segments(10).distanceEstimate(ADR.M_c);
                if r>ADR.Range_alternate
                    Alt_alternate = Alt_alternate-1000/cast.SI.ft;
                else
                    obj.Segments(9) = cast.mission.Cruise(Alt_alternate,ADR.Range_alternate-r,ADR.M_c);
                    break
                end
            end
            obj.Segments(11) = cast.mission.Decent(FL015,0,0.03*ADR.V_app); % Land (3% gradient)
            %% reserve fuel
            obj.Segments(12) = cast.mission.Loiter(FL015,ADR.Loiter,ADR.V_app/a_a); % Reserve fuel
        end
    end
end

