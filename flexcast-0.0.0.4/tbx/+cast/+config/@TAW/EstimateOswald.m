function e = EstimateOswald(obj,Mach,Method)
arguments
    obj
    Mach
    Method string {mustBeMember(Method,["Obert","Schaufele","NitaCompressible","Nita"])}
end
KeM = 1;
switch Method
    case "Obert"
        Q = 1.05;
        P = 0.007;
    case "Schaufele"
        Q = 1.03;
        P = 0.38*obj.CD0;
    case "NitaCompressible"
        [~,Q,P,KeM] = obj.NitaOswald(Mach);
    case "Nita"
        [~,Q,P,~] = obj.NitaOswald(Mach);
end
e = KeM/(Q+P*pi*obj.AR);
% geometric considerations
KeGamma = (1/cosd(obj.Dihedral))^2; % (Eq. 49) from Nita
%winbglet consideration
KeWinglet = (1+2/3.29*obj.WingletHeight/obj.Span)^2;

e = e * KeGamma * KeWinglet;
end

