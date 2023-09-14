function [VSR,rho] = VSR(WS,CL_max,alt)
%VSR Summary of this function goes here
%   Detailed explanation goes here
rho = cast.util.atmos(alt);
VSR = factor*sqrt(WS.*2/(rho*CL_max));
end

