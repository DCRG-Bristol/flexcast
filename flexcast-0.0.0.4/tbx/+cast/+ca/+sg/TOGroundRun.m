function TW = TOGroundRun(WS,ADP,alt)
%TOGroundRun Take-off ground run constraint from General Aviation Aircraft
% Design
g = 9.80665;
mu = 0.04;
rho = ads.util.atmos(alt);
S_g = ADP.ADR.GroundRun;
CL_max = ADP.CL_TOmax;
TW = 1.21/(CL_max*rho*g*S_g).*WS + 0.605/CL_max*(ADP.CD_TO-mu*ADP.CL_TO)+mu;
TW = TW/(0.75*16/15); % account for avergae T over take-off (Raymer 17.114) 
end

