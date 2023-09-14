function TW = ROC_VSR(WS,ADP,factor,CL_max,theta,alt)

%ROC TRate of Climb Constraint from General Aviation Aircraft Design
% WS - wing loading
% V - flight speed
% theta - climb gradient in degrees
% alt - altitude in metres
rho = cast.util.atmos(alt);
V = factor*sqrt(WS.*2/(rho*CL_max));
q = 1/2*rho*V.^2;
CD0 = ADP.CD0;
k = 1/(pi*ADP.AR*ADP.e);
TW = sind(theta) + q./WS.*CD0+k./q.*WS;
end

