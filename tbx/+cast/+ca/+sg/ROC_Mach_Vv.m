function TW = ROC_Mach_Vv(WS,ADP,M,Vv,alt)

%ROC TRate of Climb Constraint from General Aviation Aircraft Design
% WS - wing loading
% V - flight speed
% theta - climb gradient in degrees
% alt - altitude in metres

[~,a] = cast.util.atmos(alt);
V = M*a;
theta = asind(Vv/V);
TW = cast.ca.sg.ROC_Mach(WS,ADP,M,theta,alt);
end

