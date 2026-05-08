function TW = ROC_Mach(WS,ADP,M,theta,alt)

%ROC TRate of Climb Constraint from General Aviation Aircraft Design
% WS - wing loading
% V - flight speed
% theta - climb gradient in degrees
% alt - altitude in metres

[rho,a] = ads.util.atmos(alt);
V = M*a;
q = 1/2*rho*V^2;
CD0 = ADP.CD0;
k = 1/(pi*ADP.AR*ADP.e);
TW = sind(theta) + q./WS.*CD0+k/q.*WS;
end

