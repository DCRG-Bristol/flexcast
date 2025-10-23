function [VSR,rho] = VSR(WS,CL_max,alt)
%VSR Summary of this function goes here
%   Detailed explanation goes here
rho = dcrg.aero.atmos(alt);
VSR = factor*sqrt(WS.*2/(rho*CL_max));
end

