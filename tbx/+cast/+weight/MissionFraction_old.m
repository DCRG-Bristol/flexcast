function [EWF,fs] = MissionFraction(Segments,ADP,opts)
arguments
    Segments cast.mission.Segment
    ADP cast.ADP
    opts.M_TO = ADP.MTOM;
    opts.OverideLD = false;
end
EWF = 1;   % empty weight fraction
fs = zeros(1,length(Segments));
for i = 1:length(Segments)
    s = Segments(i);
    if isempty(ADP.Thrust)
        TW = 0.3;
    else
        TW = ADP.Thrust/(ADP.MTOM*9.81);
    end
    switch class(s)
        case 'cast.mission.GroundOp'
            f = 1 - ADP.Engine.TSFC(0,0)*9.81*(s.TaxiTime*ADP.TW_idle + s.TakeOffTime*TW);  % Snorri Eq. 6-32 (p.155)
        case 'cast.mission.Climb'
            deltaH = s.EndAlt-s.StartAlt;
            [rho,a] = cast.util.atmos(s.StartAlt+deltaH/2);
            if opts.OverideLD
                CL_c = EWF*opts.M_TO*9.81/(1/2*rho*(a*ADP.ADR.M_c)^2*ADP.WingArea);
                CD_c = ADP.CD0 + CL_c^2/(pi*ADP.AR*ADP.e);
                LD_c = CL_c/CD_c;
            else
                LD_c = ADP.LD_c;
            end
            TW = 1/(ADP.LD_c)+s.ROC/(ADP.ADR.M_c*a);
            f = 1 - deltaH*ADP.Engine.TSFC(ADP.ADR.M_c,s.StartAlt+deltaH/2)*9.81*TW/s.ROC;              % Snorri Eq. 6-34 (p. 155)
        case 'cast.mission.Cruise'
            [rho,a] = cast.util.atmos(s.StartAlt);
            if opts.OverideLD
                CL_c = EWF*opts.M_TO*9.81/(1/2*rho*(a*s.Mach)^2*ADP.WingArea);
                CD_c = ADP.CD0 + CL_c^2/(pi*ADP.AR*ADP.e);
                LD_c = CL_c/CD_c;
            else
                LD_c = ADP.LD_c;
            end
            f = exp(-s.Range*9.81*ADP.Engine.TSFC(s.Mach,s.StartAlt)/(s.Mach*a*LD_c));        % Rearranged Brequet
        case 'cast.mission.Decent'
            deltaH = s.StartAlt-s.EndAlt;
            TW = ADP.TW_idle; % assume idle power
            f = 1 - abs(deltaH)*ADP.Engine.TSFC(ADP.ADR.M_c,s.StartAlt-deltaH/2)*9.81*TW/s.ROC;              % Snorri Eq. 6-34 (p. 155)
        case 'cast.mission.Loiter'
            f = exp(-s.Time*9.81*ADP.Engine.TSFC(0.3,5e3./cast.SI.ft)/ADP.LD_app);
    end
    fs(i) = f;
    EWF = EWF*f;
end
end

