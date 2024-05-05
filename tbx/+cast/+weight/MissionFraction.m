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
                % split climb into 1000ft sections
                dh = 1000/cast.SI.ft;
                hs = unique([s.StartAlt:dh:s.EndAlt,s.EndAlt]);
                if length(hs) == 1
                    hs = [hs,hs];
                end
                deltaH = hs(2:end)-hs(1:end-1);
                deltaf = 1;
                for j = 1:length(deltaH)
                    h_mean = (hs(j)+hs(j+1))/2;
                    [rho,a,T] = ads.util.atmos(h_mean);
                    if opts.OverideLD
                        CL_c = EWF*deltaf*opts.M_TO*9.81/(1/2*rho*(a*ADP.ADR.M_c)^2*ADP.WingArea);
                        CD_c = ADP.CD0 + CL_c^2/(pi*ADP.AR*ADP.e);
                        LD_c = CL_c/CD_c;
                    else
                        LD_c = ADP.LD_c;
                    end
                    TW = 1/(LD_c)+s.ROC/(ADP.ADR.M_c*a);
                    deltaf = deltaf*(1 - deltaH(j)*ADP.Engine.TSFC(ADP.ADR.M_c,h_mean)*9.81*TW/s.ROC); % Snorri Eq. 6-34 (p. 155)
                end      
                f = deltaf;        
            case 'cast.mission.Cruise'
                [rho,a] = ads.util.atmos(s.StartAlt);
                if opts.OverideLD
                    CL_c = EWF*opts.M_TO*9.81/(1/2*rho*(a*s.Mach)^2*ADP.WingArea);
                    CD_c = ADP.CD0 + CL_c^2/(pi*ADP.AR*ADP.e);
                    LD_c = CL_c/CD_c;
                else
                    LD_c = ADP.LD_c;
                end
                f = exp(-s.Range*9.81*ADP.Engine.TSFC(s.Mach,s.StartAlt)/(s.Mach*a*LD_c));        % Rearranged Brequet
            case 'cast.mission.Decent'
                dh = -1000/cast.SI.ft;
                hs = fliplr(unique([s.StartAlt:dh:s.EndAlt,s.EndAlt]));
                if length(hs) == 1
                    hs = [hs,hs];
                end
                deltaH = hs(2:end)-hs(1:end-1);
                deltaf = 1;
                TW = ADP.TW_idle; % assume idle power
                for j = 1:length(deltaH)
                    h_mean = (hs(j)+hs(j+1))/2;
                    deltaf = deltaf * (1-abs(deltaH(j))*ADP.Engine.TSFC(ADP.ADR.M_c,h_mean)*9.81*TW/s.ROC);              % Snorri Eq. 6-34 (p. 155)
                end
                f = deltaf;
            case 'cast.mission.Loiter'
                f = exp(-s.Time*9.81*ADP.Engine.TSFC(s.Mach,s.StartAlt)/ADP.LD_app);
            case 'cast.mission.Contingency'
                % assumes all sections prior make up trip fuel and add 5 minutes 
                % loiter or 5% trip fuel, whichever is higher

                % calc fuel for 5 minute loiter
                f1 = exp(-s.Time*9.81*ADP.Engine.TSFC(0.3,5e3./cast.SI.ft)/ADP.LD_app);
                % calc 5% of current fuel burn
                df = (1-EWF)*0.03;
                f2 = 1-df/EWF;
                f = max(f1,f2);
        end
        fs(i) = f;
        EWF = EWF*f;
    end
    end
    
    