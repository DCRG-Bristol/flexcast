classdef Decent < cast.mission.Segment
    %CLIMB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartAlt;
        EndAlt;
        ROC;
        Mach;
        Percentage = nan;
        CAS = nan;
    end
    
    methods
        function obj = Decent(StartAlt,EndAlt,Mach,ROC,CAS)
            arguments
                StartAlt
                EndAlt
                Mach
                ROC
                CAS = nan;
            end
            obj.StartAlt = StartAlt;
            obj.EndAlt = EndAlt;
            obj.ROC = ROC;
            obj.Mach = Mach;
            obj.CAS = CAS;
        end
        function [alt,M,TAS] = DecentProperties(obj);
            delta_h = obj.EndAlt - obj.StartAlt;

            alt = fliplr(unique([obj.EndAlt:500/cast.SI.ft:obj.StartAlt,obj.EndAlt]));
            [rho,a,T,P,~,~,~] = ads.util.atmos(alt);
            [rho_s,a_s,T_s,P_s,~,~,~] = ads.util.atmos(0);
            VCAS = ads.util.calibrated_airspeed(obj.Mach,P,P_s,a_s,1.4);
            TAS = ads.util.true_airspeed(obj.Mach,a,T,T_s);
            % if no CAS defined assume CAS at cruise
            if isempty(obj.CAS)
                obj.CAS = VCAS(end);
            elseif isnan(obj.CAS)
                obj.CAS = VCAS(end);
            end
            % change TAS at alts where velocity is limited by CAS not Mach
            idx = VCAS>=obj.CAS; 
            TAS(idx) = ads.util.equivelent_true_airspeed(P(idx),rho(idx),P_s,rho_s,1.4,obj.CAS);
            M = TAS./a;
        end
        function [r,t] = distanceEstimate(obj,M_c)
            delta_h = obj.EndAlt - obj.StartAlt;
            t = delta_h/obj.ROC;
            % get cruise CAS
            [alt,M,TAS] = DecentProperties(obj);
            %esimate time in each region
            dAlt = alt(2:end)-alt(1:end-1);
            dt = abs(dAlt./obj.ROC);
            %estimate distance traveled
            r = sum(dt.*(TAS(2:end)+TAS(1:end-1))./2);
        end
    end
end
