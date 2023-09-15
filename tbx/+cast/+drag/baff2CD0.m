function [CD0] = baff2CD0(model,S_ref,alt,Mach,opts)
arguments
    model
    S_ref
    alt
    Mach
    opts.pLamFuselage = 0.05;
    opts.pLamWing = 0.1;
    opts.pWingMaxThickness = 0.5;
end
CD0 = 0;
for i = 1:length(model.Orphans)
    CD0 = CD0 + element2CD0(model.Orphans(i),S_ref,alt,Mach,'pLamFuselage',opts.pLamFuselage,...
        'pLamWing',opts.pLamWing,'pWingMaxThickness',opts.pWingMaxThickness);
end

end

function [CD0] = element2CD0(ele,S_ref,alt,Mach,opts)
arguments
    ele
    S_ref
    alt
    Mach
    opts.pLamFuselage = 0.05;
    opts.pLamWing = 0.1;
    opts.pWingMaxThickness = 0.5;
end
[rho,a,~,~,nu] = cast.util.atmos(alt);
switch class(ele)   
    case 'cast.drag.DraggableBluffBody'
        D = max([ele.Stations.Radius])*2;
        f = ele.EtaLength/D;
        cLen = ele.EtaLength;
        R = rho*Mach*a*cLen/nu;
        R_cutoff = 44.62*(ele.EtaLength/(0.634e-5))^1.053*Mach^1.16;
        Cf = GetCf(R,R_cutoff,Mach,opts.pLamFuselage);
        Q = ele.InterferanceFactor;
        if contains(ele.Name,'fuselage','IgnoreCase',true)
            FF = 1 + 60/f^3 + f/400; % Raymer 12.31
        else
            FF = 1 + 0.35/f;    % Raymer 12.32
        end
        CD0 = Cf*FF*Q*ele.WettedArea/S_ref;
    case 'cast.drag.DraggableWing'
        [cLens,trs] = ele.AeroStations.GetMGCs;
        R = rho*Mach*a.*cLens./nu;
        R_cutoff = 44.62*(cLens./(0.634e-5)).^1.053.*Mach^1.16;
        Cf = GetCf(R,R_cutoff,Mach,opts.pLamWing);
        % get sweep at max thickness
        cEta = opts.pWingMaxThickness;
        % get sweep at max thickness
        sweeps = ele.GetSweepAngles(cEta);
        % calc average form factor
        FF = (1+0.6/cEta.*trs+100.*trs.^4).*(1.34*Mach^0.18.*cosd(sweeps).^0.28); % Raymer 12.30
        Q = ele.InterferanceFactor;
        S_wet = ele.AeroStations.GetNormWettedAreas().*ele.EtaLength;
        CD0 = sum(Cf.*FF.*Q.*S_wet./S_ref);
    otherwise
        CD0 = 0;
end
for i = 1:length(ele.Children)
    CD0 = CD0 + element2CD0(ele.Children(i),S_ref,alt,Mach,'pLamFuselage',opts.pLamFuselage,...
        'pLamWing',opts.pLamWing,'pWingMaxThickness',opts.pWingMaxThickness);
end
end

function Cf = GetCf(R,R_cutoff,Mach,pLaminer)
    C_fl = 1.328./sqrt(R);   % Raymer 12.26
    R = min([R_cutoff;R]);
    C_ft = 0.455./(log10(R).^2.58.*(1+0.144*Mach^2)^0.65); % Raymer 12.27
    Cf =  C_fl.*pLaminer + C_ft.*(1-pLaminer);
end
