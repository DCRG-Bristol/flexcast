function TW = CVT_Mach(WS,ADP,BankAngle,M,theta,alt)
%CVT Constant Velocity Turn from General Aviation Aircraft Design
% WS - wing loading
% BankAngle - Desired bank angle in degrees
% V - flight speed
% theta - climb gradient in degrees
% alt - altitude in metres

[rho,a] = cast.util.atmos(alt);
V = M*a;
q = 1/2*rho*V^2;
CD0 = ADP.CD0;
k = 1/(pi*ADP.AR*ADP.e);
n = 1/cosd(BankAngle);

TW = q*(CD0/WS+k*(n/q)^2*WS)+cast.sg.ROC_Mach(WS,ADP,M,theta,alt);
end

