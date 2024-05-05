classdef Climb < cast.mission.Segment
    %CLIMB Summary of this class goes here
    %   Detailed explanation goes here

    properties
        StartAlt;
        EndAlt;
        ROC;
    end

    methods
        function obj = Climb(StartAlt,EndAlt,ROC)
            obj.StartAlt = StartAlt;
            obj.EndAlt = EndAlt;
            obj.ROC = ROC;
        end
        function [r,t] = distanceEstimate(obj,M_c)
            delta_h = obj.EndAlt - obj.StartAlt;
            t = delta_h/obj.ROC;

            [rho_0,a_0,T_0,P_0,~,~,~] = ads.util.atmos(0);
            % get cruise CAS
            [~,~,~,P,~,~,~] = ads.util.atmos(obj.EndAlt);
            CAS = ads.util.calibrated_airspeed(M_c,P,P_0,a_0,1.4);
            %get change in TAS with Alt
            alt = fliplr(unique([obj.StartAlt,obj.StartAlt:1000/cast.SI.ft:obj.EndAlt,obj.EndAlt]));
            [rhos,~,~,Ps,~,~,~] = ads.util.atmos(alt);
            TAS = ads.util.equivelent_true_airspeed(Ps,rhos,P_0,rho_0,1.4,CAS);
            %esimate time in each region
            dAlt = alt(2:end)-alt(1:end-1);
            dt = abs(dAlt./obj.ROC);
            %estimate distance traveled
            r = sum(dt.*(TAS(2:end)+TAS(1:end-1))./2);
        end
    end
end

