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

            [~,a_s,T_s,P_s,~,~,~] = cast.util.atmos(0);
            % get cruise CAS
            [~,~,~,P,~,~,~] = cast.util.atmos(obj.EndAlt);
            CAS = cast.util.calibrated_airspeed(M_c,P,P_s,a_s,1.4);
            %get change in TAS with Alt
            alt = fliplr(unique([obj.StartAlt,obj.StartAlt:1000/cast.SI.ft:obj.EndAlt,obj.EndAlt]));
            [~,a,T,P,~,~,~] = cast.util.atmos(alt);
            TAS = zeros(size(alt));
            M_last = M_c;
            for i = 1:length(alt)
                func = @(x)abs(cast.util.calibrated_airspeed(x,P(i),P_s,a_s,1.4)-CAS);
                M_last = fminsearch(func,M_last);
                TAS(i) = cast.util.true_airspeed(M_last,a(i),T(i),T_s);
            end
            %esimate time in each region
            dAlt = alt(2:end)-alt(1:end-1);
            dt = abs(dAlt./obj.ROC);
            %estimate distance traveled
            r = sum(dt.*(TAS(2:end)+TAS(1:end-1))./2);
        end
    end
end

