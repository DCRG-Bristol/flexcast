function WS = LandingDistance(ADP,alt,WSi)
%LANDINGDISTANCE Landing distance constraint from General Aviation Aircraft Design
% WS - wing loading
% BankAngle - Desired bank angle in degrees
% V - flight speed
% theta - climb gradient in degrees
% alt - altitude in metres

rho = cast.util.atmos(alt);
CL_max = ADP.CL_max;
tau = 5; % assume takes 5 seconds to apply brakes
g = 9.80665;
mu = 0.3;
% assuming takes 
A = rho*CL_max;
f = 1.21/(g*(0.605/CL_max *(ADP.CD_LDG - mu*ADP.CL_LDG)+mu-ADP.TWgr));
S_LGR = @(WS)WS/A*(0.01583 + 1.556*tau*sqrt(A/WS)+f);

WS = fminsearch(@(x)(S_LGR(x)-ADP.ADR.GroundRunLanding)^2,WSi);
end

