function [EWF,fs,ts] = FuelFraction(ADP,Segments,opts)
    arguments
        ADP cast.ADP
        Segments cast.mission.Segment
        opts.M_TO = ADP.MTOM;
        opts.OverideLD = false;
        opts.TW = 0.3;
    end
    EWF = 1;   % empty weight fraction
    fs = zeros(1,length(Segments));
    ts = zeros(1,length(Segments));
    for i = 1:length(Segments)
        s = Segments(i);
        switch class(s)
            case 'cast.mission.GroundOp'
                if isempty(ADP.Thrust)
                    warning('Please set a MaxThrust value in the Thrust Property')
                    ADP.Thrust = ADP.MTOM*SI.g*0.31;
                end
                TW = ADP.Thrust/(ADP.MTOM*SI.g);
                f = 1 - ADP.Engine.TSFC(0,0)*9.81*(s.TaxiTime*ADP.TW_idle + s.TakeOffTime*TW);  % Snorri Eq. 6-32 (p.155)
                t = s.TaxiTime + s.TakeOffTime;
            case 'cast.mission.Climb'
                [hs,M] = s.ClimbProperties();
                %calc properties in each section
                deltaH = hs(2:end)-hs(1:end-1);
                h_mean = (hs(2:end)-hs(1:end-1))/2;
                [rho,a] = dcrg.aero.atmos(h_mean);
                M = (M(2:end)+M(1:end-1))/2;
                deltaf = 1;
                t = 0;
                for j = 1:length(deltaH)
                    if opts.OverideLD
                        CL_c = EWF*deltaf*opts.M_TO*9.81/(1/2*rho(j)*(a(j)*M(j))^2*ADP.WingArea);
                        CD_c = ADP.Polar.Get_Cd(CL_c,M(j),s.WingConfig);
                        LD_c = CL_c/CD_c;
                    else
                        LD_c = ADP.LD_c;
                    end
                    TW = 1/(LD_c)+s.ROC/(M(j)*a(j));
                    deltaf = deltaf*(1 - deltaH(j)*ADP.Engine.TSFC(M(j),h_mean(j))*9.81*TW/s.ROC); % Snorri Eq. 6-34 (p. 155)
                    t = t + deltaH(j)/s.ROC;
                end      
                f = deltaf;        
            case 'cast.mission.Cruise'
                [rho,a,~,P] = dcrg.aero.atmos(s.StartAlt);
                [rho_s,a_s,~,P_s] = dcrg.aero.atmos(0);
                VCAS = dcrg.aero.v.calibrated(s.Mach,P,P_s,a_s,1.4);
                if ~isnan(s.CAS) && VCAS>s.CAS
                    TAS = dcrg.aero.v.equivelent(P,rho,P_s,rho_s,1.4,s.CAS);
                    M_cruise = TAS/a;
                else
                    M_cruise = s.Mach;
                end
                if opts.OverideLD
                    CL_c = EWF*opts.M_TO*9.81/(1/2*rho*(a*M_cruise)^2*ADP.WingArea);
                    CD_c = ADP.Polar.Get_Cd(CL_c,M_cruise,s.WingConfig);
                    LD_c = CL_c/CD_c;
                else
                    LD_c = ADP.LD_c;
                end
                f = exp(-s.Range*9.81*ADP.Engine.TSFC(M_cruise,s.StartAlt)/(M_cruise*a*LD_c));        % Rearranged Brequet
                t = s.Range/(M_cruise*a);
            case 'cast.mission.Decent'

                [hs,M] = s.DecentProperties();
                deltaH = abs(hs(2:end)-hs(1:end-1));
                h_mean = (hs(2:end)+hs(1:end-1))/2;
                M = (M(2:end)+M(1:end-1))/2;

                deltaf = 1;
                TW = ADP.TW_idle; % assume idle power
                t = 0;
                for j = 1:length(deltaH)
                    deltaf = deltaf * (1-abs(deltaH(j))*ADP.Engine.TSFC(M(j),h_mean(j))*9.81*TW/s.ROC);              % Snorri Eq. 6-34 (p. 155)
                    t = t + abs(deltaH(j))/s.ROC;
                end
                f = deltaf;
            case 'cast.mission.Loiter'
                [rho,a,~,P] = dcrg.aero.atmos(s.StartAlt);
                if opts.OverideLD
                    CL = EWF*opts.M_TO*9.81/(1/2*rho*(a*s.Mach)^2*ADP.WingArea);
                    CD = ADP.Polar.Get_Cd(CL,s.Mach,s.WingConfig);
                    LD = CL/CD;
                else
                    LD = ADP.LD_app;
                end
                f = exp(-s.Time*9.81*ADP.Engine.TSFC(s.Mach,s.StartAlt)/LD);
                t = s.Time;
            case 'cast.mission.Contingency'
                % assumes all sections prior make up trip fuel and add 5 minutes 
                % loiter or 3% trip fuel, whichever is higher
                [rho,a] = dcrg.aero.atmos(s.StartAlt);
                if opts.OverideLD
                    CL = EWF*opts.M_TO*9.81/(1/2*rho*(a*s.Mach)^2*ADP.WingArea);
                    CD = ADP.Polar.Get_Cd(CL,s.Mach,s.WingConfig);
                    LD = CL/CD;
                else
                    LD = ADP.LD_app;
                end
                % calc fuel for 5 minute loiter
                f1 = exp(-s.Time*9.81*ADP.Engine.TSFC(0.3,5e3./SI.ft)/LD);
                % calc 5% of current fuel burn
                df = (1-EWF)*0.03;
                f2 = 1-df/EWF;
                % take largest of either 5 min loiter or 3% fuel burn
                f = max(f1,f2);
                t = s.Time;
            case 'cast.mission.Nothing'
                f = 1;
                t = 0;
        end
        fs(i) = f;
        ts(i) = t;
        EWF = EWF*f;
    end
end