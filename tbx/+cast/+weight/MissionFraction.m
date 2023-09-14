function [EWF,fs] = MissionFraction(Segments,ADP)
arguments
    Segments cast.mission.Segment
    ADP cast.ADP
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
            f = 1 - ADP.Engine.SFC_TO*9.81*(s.TaxiTime*ADP.TW_idle + s.TakeOffTime*TW);  % Snorri Eq. 6-32 (p.155)
        case 'cast.mission.Climb'
            deltaH = s.EndAlt-s.StartAlt;
            [~,a] = cast.util.atmos(s.StartAlt+deltaH/2);
            TW = 1/(ADP.LD_c)+s.ROC/(ADP.ADR.M_c*a);
            f = 1 - deltaH*ADP.Engine.SFC_cruise*9.81*TW/s.ROC;              % Snorri Eq. 6-34 (p. 155)
        case 'cast.mission.Cruise'
            [~,a] = cast.util.atmos(s.StartAlt);
            f = exp(-s.Range*9.81*ADP.Engine.SFC_cruise/(s.Mach*a*ADP.LD_c));        % Rearranged Brequet
        case 'cast.mission.Decent'
            deltaH = s.StartAlt-s.EndAlt;
            TW = ADP.TW_idle; % assume idle power
            f = 1 - deltaH*ADP.Engine.SFC_cruise*9.81*TW/s.ROC;              % Snorri Eq. 6-34 (p. 155)
        case 'cast.mission.Loiter'
            f = exp(-s.Time*9.81*ADP.Engine.SFC_TO/ADP.LD_app);
    end
    fs(i) = f;
    EWF = EWF*f;
end
end

