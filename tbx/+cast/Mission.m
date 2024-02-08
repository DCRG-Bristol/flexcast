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
            % approach data
            [rho_a,a_a,T_a,P_a,nu_a,z_a,sigma_a] = cast.util.atmos(FL015);
            
            %check if climb and decent are too long
            function [dist,climb,decent] = checkDist(x)
                climb = cast.mission.Climb(FL015,x,CR015);
                decent = cast.mission.Decent(x,FL015,CR015);
                dist = climb.distanceEstimate(ADR.M_c) + decent.distanceEstimate(ADR.M_c);
            end
            dist = checkDist(ADR.Alt_cruise);
            if dist > Range
                if (checkDist(FL015)-Range)>0
                    error('bad')
                end
                Alt = fzero(@(x)checkDist(x)-Range,[FL015,ADR.Alt_cruise]);
                dist = checkDist(Alt);
            else
                Alt = ADR.Alt_cruise;
            end

            % make mission profile
            obj = cast.Mission();
            obj.Segments(1) = cast.mission.GroundOp.FromGate();
            obj.Segments(2) = cast.mission.Climb(0,Alt,CR015);
            %estimate distance travelled whilst climbing
            obj.Segments(3) = cast.mission.Cruise(Alt,Range-dist,ADR.M_c);
            obj.Segments(4) = cast.mission.Decent(Alt,FL015,CR015);
            obj.Segments(5) = cast.mission.Loiter(Alt,10./cast.SI.min,ADR.V_app/a_a); % land + contingency fuel
            obj.Segments(6) = cast.mission.Climb(FL015,ADR.Alt_alternate,CR015);
            r = obj.Segments(6).distanceEstimate(ADR.M_c);
            obj.Segments(7) = cast.mission.Cruise(ADR.Alt_alternate,max(0,ADR.Range_alternate-r*2),ADR.M_c);
            obj.Segments(8) = cast.mission.Decent(ADR.Alt_alternate,FL015,CR015);
            obj.Segments(9) = cast.mission.Loiter(FL015,ADR.Loiter,ADR.V_app/a_a); % Reserve fuel
            obj.Segments(10) = cast.mission.Decent(FL015,0,0.03*ADR.V_app); % Land (3% gradient)
            obj.Segments(11) = cast.mission.GroundOp.ToGate();            
        end
    end
end

